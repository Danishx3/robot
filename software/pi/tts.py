import pyttsx3

class Speaker:
    def __init__(self):
        self.engine = pyttsx3.init()
        self.engine.setProperty("rate", 165)
        self.engine.setProperty("volume", 1.0)

    def speak(self, text, on_start=None, on_end=None):
        if on_start:
            on_start()
        print("ROBOT:", text)
        self.engine.say(text)
        self.engine.runAndWait()
        if on_end:
            on_end()
