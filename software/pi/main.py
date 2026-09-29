import threading
import time

from config import *
from robot import Robot
from voice import Voice
from tts import Speaker
from ai import AI
from face import Face

def handle_motion_command(robot, text):
    t = text.lower()

    if "stop" in t:
        robot.stop()
        return True

    if "move forward" in t or "go forward" in t:
        robot.move("F")
        return True

    if "move backward" in t or "go backward" in t or "reverse" in t:
        robot.move("B")
        return True

    if "turn left" in t or "go left" in t:
        robot.move("L")
        return True

    if "turn right" in t or "go right" in t:
        robot.move("R")
        return True

    return False

def handle_gesture_command(robot, text):
    t = text.lower()

    if "wave" in t or "say hello" in t or "greet" in t:
        robot.gesture("HELLO")
        return True

    if "happy" in t:
        robot.gesture("HAPPY")
        return True

    if "goodbye" in t or "bye" in t:
        robot.gesture("GOODBYE")
        return True

    return False

def main():
    robot = Robot(SERIAL_PORT, BAUD)
    speaker = Speaker()
    voice = Voice(VOSK_MODEL_PATH, SAMPLE_RATE)
    ai = AI(OLLAMA_URL, OLLAMA_MODEL)
    face = Face()

    face_thread = threading.Thread(target=face.loop, daemon=True)
    face_thread.start()

    # Vision is optional; uncomment after camera setup.
    # from vision import Vision
    # vision = Vision(CAMERA_INDEX)
    # threading.Thread(target=vision.run, daemon=True).start()

    face.set("happy")
    speaker.speak(
        "Hello! I am ready.",
        on_start=lambda: robot.arm("BOTH_UP"),
        on_end=lambda: robot.arm("BOTH_DOWN")
    )

    try:
        while True:
            text = voice.listen_once()
            if not text:
                continue

            print("YOU:", text)

            if text in ("quit", "exit", "shutdown robot"):
                break

            if handle_motion_command(robot, text):
                continue

            if handle_gesture_command(robot, text):
                continue

            face.set("thinking")
            response = ai.answer(text)

            if ARM_WHILE_SPEAKING:
                start = lambda: (face.set("happy"), robot.arm("BOTH_UP"))
                end = lambda: robot.arm("BOTH_DOWN")
            else:
                start = lambda: face.set("happy")
                end = lambda: None

            speaker.speak(response, on_start=start, on_end=end)

    except KeyboardInterrupt:
        pass
    finally:
        robot.close()
        face.stop()

if __name__ == "__main__":
    main()
