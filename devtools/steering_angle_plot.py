#!/usr/bin/env python3

import rospy
import numpy as np
from matplotlib import pyplot as plt
import time
import sys
import os

from std_msgs.msg import *
from sensor_msgs.msg import *

plt.ion()

steering_wheel_angle = 0.0
def on_steering_wheel_angle(msg):
    global steering_wheel_angle
    steering_wheel_angle = msg.data

angular_velocity = 0.0
def on_imu_data(msg):
    global angular_velocity
    angular_velocity = angular_velocity * 0.9 + msg.angular_velocity.z*0.1

speed = 0.0
def on_speed(msg):
    global speed
    speed = msg.data / 3.6 # km/h to m/s

rospy.init_node('plot_steering')

sub_steering_wheel_angle = rospy.Subscriber("/vehicle/steering_wheel_angle", Float32, on_steering_wheel_angle)
sub_speed = rospy.Subscriber("/vehicle/speed", Float32, on_speed)
sub_imu_data = rospy.Subscriber("/imu/data", Imu, on_imu_data)

swas = []
rs = []

seq = 0
rate = rospy.Rate(10)
while not rospy.is_shutdown():
    rate.sleep()
    seq += 1
    radius = speed / angular_velocity
    if radius == 0:
        continue

    invradius = 1.0 / radius
    print(speed, angular_velocity, invradius, steering_wheel_angle)
    swas.append(steering_wheel_angle)
    rs.append(invradius)
    if seq % 10 == 0:
        plt.clf()
        plt.scatter(swas, rs)
        plt.show()
        plt.pause(0.001)
