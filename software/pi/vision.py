import cv2
import threading
import time

class Vision:
    def __init__(self, camera_index=0):
        self.cap = cv2.VideoCapture(camera_index)
        self.face_cascade = cv2.CascadeClassifier(
            cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
        )
        self.running = False
        self.face_seen = False

    def run(self):
        if not self.cap.isOpened():
            print("[VISION] Camera unavailable")
            return

        self.running = True
        while self.running:
            ok, frame = self.cap.read()
            if not ok:
                time.sleep(0.1)
                continue

            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            faces = self.face_cascade.detectMultiScale(
                gray, scaleFactor=1.2, minNeighbors=5, minSize=(50, 50)
            )
            self.face_seen = len(faces) > 0

            # This is intentionally a lightweight detector.
            # Do not use it as a safety-critical obstacle detector.
            for (x, y, w, h) in faces:
                cv2.rectangle(frame, (x,y), (x+w,y+h), (0,255,0), 2)

            cv2.imshow("Robot Vision", frame)
            if cv2.waitKey(1) & 0xFF == ord("q"):
                self.stop()

        self.cap.release()
        cv2.destroyAllWindows()

    def stop(self):
        self.running = False
