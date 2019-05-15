#!/usr/bin/env python3
from ipm import IPM
import numpy as np
import cv2

ipm = IPM()
r, theta = ipm.get_ground_plane((360,720))
r = np.clip(r, 0.0, 50.0) / 50.0
cv2.imshow('r',r)
print("r", r)
cv2.imshow('theta', theta)
print("theta", theta)
cv2.waitKey(0)
