import requests

class AI:
    def __init__(self, url, model):
        self.url = url
        self.model = model
        self.history = []

    def answer(self, user_text):
        prompt = (
            "You are a friendly small home robot. "
            "Reply naturally and briefly, usually one or two sentences. "
            "Do not claim to physically do something unless the robot software "
            "has actually commanded it. User says: " + user_text
        )
        try:
            r = requests.post(
                self.url,
                json={
                    "model": self.model,
                    "prompt": prompt,
                    "stream": False
                },
                timeout=20
            )
            r.raise_for_status()
            data = r.json()
            answer = data.get("response", "").strip()
            if answer:
                return answer
        except Exception as e:
            print("[AI unavailable]", e)

        return self.fallback(user_text)

    def fallback(self, text):
        t = text.lower()
        if "hello" in t or "hi" in t:
            return "Hello! Nice to see you."
        if "how are you" in t:
            return "I'm doing great and ready to play."
        if "your name" in t:
            return "I'm your little robot companion."
        if "move forward" in t:
            return "Okay, moving forward."
        if "stop" in t:
            return "Okay, stopping."
        if "happy" in t:
            return "I'm happy too!"
        return "I heard you. My AI service is not connected yet."
