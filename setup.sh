#!/bin/bash
git submodule init --update --recursive
cd system
./install-tensorflow.sh
./install-pytorch.sh
./install-ros.sh
./install-apt.sh
./install-pip.sh
./install-root.sh
