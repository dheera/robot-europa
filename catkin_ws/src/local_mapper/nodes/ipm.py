import math
import functools
import json
import numpy as np
import numpy_extra as npe
import os

from scipy.interpolate import griddata

class IPM(object):
    def __init__(self, configuration = "camera_ethernet_imx291", pixels_per_meter = 10.0):
        self.configuration = configuration
        self.configuration_filename = os.path.join(
            os.path.split(__file__)[0],
            "%s.json" % configuration
        )

        if not os.path.exists(self.configuration_filename):
            rospy.logfatal("configuration file not found: %s" % self.configuration_filename)
            exit()

        try:
            with open(self.configuration_filename, "r") as f:
                self.camera = json.loads(f.read())
        except json.decoder.JSONDecodeError:
            rospy.logfatal("malformed configuration: %s" % self.configuration_filename)
            exit()

        pass

    @functools.lru_cache()
    def get_ground_plane(self, shape):
        index_h = np.arange(0, shape[1], dtype = np.uint16) # horizontal indexes
        index_v = np.arange(0, shape[0], dtype = np.uint16) # vertical indexes
        grid_h, grid_v = np.meshgrid(index_h, index_v)
        tilt = self.camera["rotation"][1]
        yaw = self.camera["rotation"][2]
        hfov = self.camera["hfov"] * 3.141592653589/180.0
        vfov = self.camera["vfov"] * 3.141592653589/180.0
        camera_height = 1.5

        theta = - np.arctan(2*(grid_h/shape[1] - 0.5 - yaw/vfov/2) * np.tan(hfov/2)) * math.cos(tilt)
        phi = np.arctan(2*(grid_v/shape[0] - 0.5 + tilt/vfov/2) * np.tan(vfov/2))
        r = np.tan(3.14159265358979/2 - phi) * camera_height

        return r, theta

    @functools.lru_cache()
    def get_ground_plane_interpolated(self, shape):
        pi, pj = np.mgrid[0:shape[0], 0:shape[1]]

        pi_norm = pi / float(shape[0])
        pj_norm = pj / float(shape[1])

        data = np.array(self.camera["ground_plane_keypoints"])
        x = griddata(data[:,2:4][:,::-1], data[:, 0], (pi_norm, pj_norm))
        y = griddata(data[:,2:4][:,::-1], data[:, 1], (pi_norm, pj_norm))
        r = (x**2 + y**2)**0.5
        theta = np.arctan2(y, x)

        return r, theta

