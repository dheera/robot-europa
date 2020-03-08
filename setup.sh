#!/bin/bash
git submodule init --update --recursive
cd system
./install-apt.sh
./install-tensorflow.sh
./install-pytorch.sh
./install-ros.sh
./install-pip.sh
./install-root.sh
