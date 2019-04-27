import serial
import time
import threading

class RoboteqSteering(object):
    def __init__(self, device = '/dev/roboteq0', baudrate = 115200, logerr = lambda x: print(x)):

        self.logerr = logerr
        self.ser = None

        try:
            self.ser = serial.Serial(device, baudrate = baudrate, timeout = 1)
        except serial.serialutil.SerialException:
            self.logerr("unable to open serial port")
            exit(1)

        self.thread_read_loop = threading.Thread(target = self._read_loop, daemon = True)
        self.thread_read_loop.start()

    def __del__(self):
        if self.ser and self.ser.is_open:
            self.ser.close()

    def _write(self, command_string):
        if not self.ser.is_open:
            self.logerr("exiting: serial port closed")
            exit(1)
        try:
            self.ser.write((command_string + '\r').encode())
        except serial.serialutil.SerialException:
            self.logerr("serial port error")
            exit(1)
        return True

    def command(self, power):
        if power > 1000:
            power = 1000
        if power < -1000:
            power = -1000
        self._write("!G 1 %d" % power)

    def query_ff(self):
        self._write("?FF")

    def _read_loop(self):
        while True:
            line = self.ser.readline()

