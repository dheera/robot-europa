#!/bin/bash
sudo apt-get update
sudo apt-get install libhdf5-serial-dev hdf5-tools python3-pip python-pip
sudo apt-get install zlib1g-dev zip libjpeg8-dev libhdf5-dev
sudo pip3 install -U pip
sudo pip3 install -U numpy grpcio absl-py py-cpuinfo psutil portpicker grpcio six mock requests gast h5py astor termcolor

sudo pip3 install --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v42 tensorflow-gpu
