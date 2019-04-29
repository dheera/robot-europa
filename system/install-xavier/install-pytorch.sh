#!/bin/bash

cd

wget https://nvidia.box.com/shared/static/m6vy0c7rs8t1alrt9dqf7yt1z587d1jk.whl -O torch-1.1.0a0+b457266-cp27-cp27mu-linux_aarch64.whl
sudo pip install torch-1.1.0a0+b457266-cp27-cp27mu-linux_aarch64.whl

wget https://nvidia.box.com/shared/static/veo87trfaawj5pfwuqvhl6mzc5b55fbj.whl -O torch-1.1.0a0+b457266-cp36-cp36m-linux_aarch64.whl
sudo pip3 install numpy torch-1.1.0a0+b457266-cp36-cp36m-linux_aarch64.whl

