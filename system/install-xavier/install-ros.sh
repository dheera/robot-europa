#!/bin/bash
cd installROSXavier
installROS.sh
setupCatkinWorkspace.sh
sudo apt-get update
sudo apt-get install ros-melodic-web-video-server ros-melodic-rosbridge-suite ros-melodic-diagnostic-updater
