import serial
import time

class Robot:
    def __init__(self, port, baud=115200):
        self.ser = serial.Serial(port, baud, timeout=1)
        time.sleep(2)

    def send(self, command):
        command = command.strip()
        self.ser.write((command + "\n").encode("utf-8"))
        print("[ESP32]", command)

    def move(self, direction):
        self.send(f"MOVE {direction}")

    def stop(self):
        self.send("MOVE S")

    def arm(self, action):
        self.send(f"ARM {action}")

    def head(self, position):
        self.send(f"HEAD {position}")

    def gesture(self, name):
        self.send(f"GESTURE {name}")

    def say_start(self):
        if True:
            self.arm("BOTH_UP")

    def say_end(self):
        self.arm("BOTH_DOWN")

    def close(self):
        try:
            self.stop()
            self.arm("BOTH_DOWN")
            self.ser.close()
        except Exception:
            pass
