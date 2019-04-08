#!/usr/bin/env python3

import math
import time

class PID:
    """
    Discrete-time PID control.
    """

    def __init__(self, KP=1.0, KI=1.0, KD=1.0, I_LIMIT = 100., \
      circular = False, debug_callback = None):

        # PID constants
        self.KP = KP
        self.KI = KI
        self.KD = KD

        # maximum absolute value the I term can take
        self.I_LIMIT = abs(I_LIMIT)

        # true if we are dealing with an angle and need 2pi wrapping
        self.circular = circular

        # a function to callback with a string including PID debug info
        # useful for PID tuning.
        # PID(..., debug_callback = rospy.logdebug) is a good choice.
        self.debug_callback = debug_callback

        # set point
        self.__target = 0.0

        # current measured input
        self.current = 0.0

        # index to current array element to update in errors and times
        self.index = 0

        # recent error values
        self.errors = [ 0.0 ] * 5

        # recent timestamp values (parallel array to above)
        self.times = [ 0.0 ] * 5

        self.error_p = 0.0
        self.error_i = 0.0
        self.error_d = 0.0

    def update(self, current):
        """
        Perform one iteration of PID feedback for given measured input.
        Returns feedback output.
        """

        self.times[self.index] = time.time()

        self.current = current

        # for circular PID, keep values within [-pi, pi]
        if self.circular:
          while self.current > 2*math.pi:
            self.current = self.current - 2*math.pi
          while self.current < 0:
            self.current = self.current + 2*math.pi

        # COMPUTE PROPORTIONAL

        self.error_p = self.__target - self.current

        # for circular PID, keep error values within [-pi, pi]
        if self.circular:          
          while self.error_p > math.pi:
            self.error_p = self.error_p - 2*math.pi
          while self.error_p < -math.pi:
            self.error_p = self.error_p + 2*math.pi

        self.errors[self.index] = self.error_p
        if callable(self.debug_callback):
            self.debug_callback(self.errors)

        # COMPUTE INTEGRAL

        # time step here is only the diff between current and past sample
        time_step = self.times[self.index] - self.times[(self.index - 1) % 5]
        # impose upper bound on time step (to avoid jump from 0 to unix time)
        time_step = min(time_step, 0.1)
        self.error_i += self.error_p * time_step
        self.error_i = max(min(self.error_i, self.I_LIMIT), -self.I_LIMIT)

        # COMPUTE DIFFERENTIAL

        # time_step here is over all 5 samples
        time_step = self.times[self.index] - self.times[(self.index + 1) % 5]
        # impose lower bound on time step (to avoid divide by zero error)
        time_step = max(time_step, 0.001)
        self.error_d = (self.errors[self.index] \
                    - self.errors[(self.index + 1) % 5]) \
                    / (time_step)

        # increment index for next irritation
        self.index = (self.index + 1) % 5

        # COMPUTE CORRECTION

        correction = self.KP * self.error_p \
             + self.KI * self.error_i \
             + self.KD * self.error_d

        # safety feature in case update() is not called frequently enough
        if time_step > 0.2:
          if callable(self.debug_callback):
              self.debug_callback("infrequent updates, returning 0")
          return 0

        if callable(self.debug_callback):
          self.debug_callback("target = {:2.4f} current = {:2.4f}".format( \
             self.__target, self.current))
          self.debug_callback("errors = " + str(self.errors))
          self.debug_callback("e = {:2.4f} e_i = {:2.4f} e_d = {:2.4f} corr = {:2.4f}".format( \
             self.error_p, self.error_i, self.error_d, correction))

        return correction

    @property
    def target(self):
        """
        Property getter for target. Do not call directly.
        Access pid_instance.target as a property which is more Pythonic.
        """
        return self.__target

    @target.setter
    def target(self, target):
        """
        Property setter for target. Do not call directly.
        pid_instance.target = value is more Pythonic.
        """
        self.__target = float(target)

    def reset(self):
        """
        Resets the PID controller error history and integral value.
        Consider calling this if the target is abruptly changed to a new
        value without a smooth transition, or upon starting/stopping motion.
        """
        self.error_p = 0.0
        self.error_i = 0.0
        self.error_d = 0.0
        self.errors = [ 0.0 ] * 5
        if callable(self.debug_callback):
            self.debug_callback("reset")
