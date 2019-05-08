// Node to subscribe to topics required by RTKLIB and
// stream them to a tcp server that RTKLIB can connect to (using TCPCLI).
// A separate node to allow realtime rosbag playback into rtklib.


//#include "ublox_gps/node.h"

#include <iostream>
#include <vector>
#include <boost/iostreams/device/array.hpp>
#include <boost/iostreams/stream.hpp>

//TODO Might not be needed, check after code fleshed out
#include <cmath>
#include <string>
#include <sstream>
#include <vector>
#include <set>
// Boost
#include <boost/algorithm/string.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/regex.hpp>
// ROS includes
#include <ros/ros.h>
#include <ros/console.h>
#include <ros/serialization.h>
#include <ublox/serialization/ublox_msgs.h>

#include <ublox_msgs/ublox_msgs.h>

#include <netinet/in.h>
#include <netinet/tcp.h>
#include <sys/poll.h>
#include <errno.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <mutex>
//#include <shared_mutex>

template <typename T>
std::vector<std::pair<uint8_t,uint8_t> > ublox::Message<T>::keys_;

boost::shared_ptr<ros::NodeHandle> nh;

constexpr static int kWriterSize = 2056;
static int const maxConnectionBacklog = 5;
static int const maxClients = 10;
static int port_;
static int socketId;
struct sockaddr_in serverAddr;
struct sockaddr_storage serverStorage;
socklen_t addr_size = sizeof serverStorage;

// mutex for synchronizing our callbacks
std::mutex cbMutex;

struct pollfd fds[maxClients+1];
int nfds;
char buffer[kWriterSize];

int messageRelay(char *message, int messageSize) {
  std::unique_lock<std::mutex> lock(cbMutex);

  int i, nactive;

  ROS_DEBUG("messageRelay Received message 0x%x 0x%x", message[2], message[3]);

  // Check for any activity on open sockets without waiting
  if ((nactive = poll(fds, nfds, 0)) < 0) {
    ROS_ERROR("poll() failed, returned %d", nactive);
    return (-1);
  }

  if (nactive > 0) {
    ROS_DEBUG("poll() returned %d active connections", nactive);
    for (i = nfds-1; i>=0; i--) {
      if (fds[i].revents == 0) continue;
      if (fds[i].revents != POLLIN) {
        ROS_DEBUG("fds[%d].revents=%d not %d, closing connection %d", i, fds[i].revents, POLLIN, fds[i].fd);
        close(fds[i].fd);
        for (int j=i; j<nfds; j++)
          fds[j].fd = fds[j+1].fd;
        nfds--;
        break;
      }
      if (i > 0) {
        // Client sockets
        while (1) {
          // Receive any data sent without waiting.
          int received = recv(fds[i].fd, buffer, sizeof(buffer), MSG_DONTWAIT);
          if (received < 0) {
            if (errno != EWOULDBLOCK)
              ROS_ERROR("recv() failed returning %d with errno %d", received, errno);
            break;
          } else if (received == 0) {
            // Dropped connection, remove the entry
            ROS_DEBUG("Closing connection [%d]=%d", i, fds[i].fd);
            close(fds[i].fd);
            for (int j=i; j<nfds; j++)
              fds[j].fd = fds[j+1].fd;
            nfds--;
            break;
          } else {
            ROS_INFO("Received unexpected data from client: %d bytes", received);
            // Do not try to relay back commands, no generic command access.
            // Do not parse and handle specific calls.
          }
        }
      } else {
        // i == 0, Listener socket
        int newSocket;
        // New connections
        while (1) {
          ROS_DEBUG("Listener socket");
          // Want to clear connection even if refusing it
          newSocket = accept(fds[i].fd, NULL, NULL);
          if (newSocket < 0) {
            if (errno != EWOULDBLOCK)
              ROS_ERROR("accept() failed returning %d", newSocket);
            break;
          }
          if (nfds-1 >= maxClients) {
            ROS_ERROR("Refusing connection after %d", maxClients);
            close(newSocket);
          } else {
            ROS_DEBUG("Opening connection [%d]=%d", nfds, newSocket);
            fds[nfds].fd = newSocket;
            fds[nfds].events = POLLIN;
            nfds++;
          }
        }
      }
    }
  }

  // Relay incoming message to all output streams (not listener in fds[0].fd)
  ROS_DEBUG("Writing %d bytes to %d client connections", messageSize, nfds-1);
  for (i=1; i<nfds; i++) {
    ROS_DEBUG("Writing %d bytes to connection %d", messageSize, fds[i].fd);
    write(fds[i].fd, message, messageSize);
  }
  ROS_DEBUG("Finishing messageRelay");
  return (0);
}


#define DECLARE_UBLOX_RTKLIB_MESSAGE(package, message) \
void cb##message(const package::message::ConstPtr &msg) { \
  std::vector<unsigned char> out(kWriterSize); \
  ublox::Writer writer(out.data(), out.size()); \
  if (!writer.write(*msg)) { \
    ROS_ERROR("Failed to encode config message 0x%02x / 0x%02x", \
              msg->CLASS_ID, msg->MESSAGE_ID); \
  } else { \
    messageRelay(reinterpret_cast<char*>(&out[0]), writer.end()-out.data()); \
  } \
} \

#define SUBSCRIBE_RTKLIB(topic, message) \
  ros::Subscriber sub##message = nh->subscribe(topic, 10, cb##message);


DECLARE_UBLOX_RTKLIB_MESSAGE(ublox_msgs, NavSOL);
DECLARE_UBLOX_RTKLIB_MESSAGE(ublox_msgs, NavTIMEGPS);
DECLARE_UBLOX_RTKLIB_MESSAGE(ublox_msgs, RxmRAW);
DECLARE_UBLOX_RTKLIB_MESSAGE(ublox_msgs, RxmSFRB);
DECLARE_UBLOX_RTKLIB_MESSAGE(ublox_msgs, RxmRAWX);
DECLARE_UBLOX_RTKLIB_MESSAGE(ublox_msgs, RxmSFRBX);

// Not handled by standard RTKLIB but Events handled by rtkexplorer fork.
DECLARE_UBLOX_RTKLIB_MESSAGE(ublox_msgs, TimTM2);

//TODO Not handled by RTKLIB, but useful for testing on M8U
DECLARE_UBLOX_RTKLIB_MESSAGE(ublox_msgs, NavPVT);

int main(int argc, char** argv) {
  ros::init(argc, argv, "rtklibsrv");
  nh.reset(new ros::NodeHandle("~"));
  nh->param("port", port_, 52010);

  // Set up TCP listener
  if ((socketId = socket(AF_INET, SOCK_STREAM, 0)) <= 0) {
    ROS_ERROR("socket failed");
    exit(EXIT_FAILURE);
  }
  int on = 1;
  if (setsockopt(socketId, SOL_SOCKET, SO_REUSEADDR, (char *)&on, sizeof(on)) < 0) {
    ROS_ERROR("setsockopt SO_REUSEADDR failed");
    close(socketId);
    exit(EXIT_FAILURE);
  }
  if (setsockopt(socketId, IPPROTO_TCP, TCP_NODELAY, (char *)&on, sizeof(on)) < 0) {
    ROS_ERROR("setsockopt TCP_NODELAY failed");
    close(socketId);
    exit(EXIT_FAILURE);
  }
  if (ioctl(socketId, FIONBIO, (char *)&on) < 0) {
    ROS_ERROR("ioctl failed");
    close(socketId);
    exit(EXIT_FAILURE);
  }
  bzero((char*)&serverAddr, sizeof(serverAddr));
  serverAddr.sin_family = AF_INET;
  serverAddr.sin_port = htons(port_);
  serverAddr.sin_addr.s_addr = INADDR_ANY;
  if (bind(socketId, (struct sockaddr *)&serverAddr, sizeof(serverAddr)) < 0) {
    ROS_ERROR("bind failed");
    close(socketId);
    exit(EXIT_FAILURE);
  }
  if (listen(socketId, maxConnectionBacklog) < 0) {
    ROS_ERROR("listen failed");
    close(socketId);
    exit(EXIT_FAILURE);
  }
  bzero((char*)fds, sizeof(fds));
  // Make the master listener the first socket
  nfds = 1;
  fds[0].fd = socketId;
  fds[0].events = POLLIN;

  SUBSCRIBE_RTKLIB("navsol", NavSOL);
  SUBSCRIBE_RTKLIB("navtimegps", NavTIMEGPS);
  SUBSCRIBE_RTKLIB("rxmraw", RxmRAW);
  SUBSCRIBE_RTKLIB("rxmsfrb", RxmSFRB);
  SUBSCRIBE_RTKLIB("rxmrawx", RxmRAWX);
  SUBSCRIBE_RTKLIB("rxmsfrbx", RxmSFRBX);
  SUBSCRIBE_RTKLIB("timtm2", TimTM2);

  SUBSCRIBE_RTKLIB("navpvt", NavPVT);

  ros::spin(); // Wait for callbacks
  return 0;
}
