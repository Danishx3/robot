import json
import queue
import os
import sounddevice as sd
from vosk import Model, KaldiRecognizer

class Voice:
    def __init__(self, model_path, sample_rate=16000):
        if not os.path.isdir(model_path):
            raise FileNotFoundError(
                f"Vosk model not found: {model_path}\n"
                "Download a small English Vosk model and extract it there."
            )
        self.model = Model(model_path)
        self.rec = KaldiRecognizer(self.model, sample_rate)
        self.q = queue.Queue()
        self.sample_rate = sample_rate

    def _callback(self, indata, frames, time_info, status):
        if status:
            print("[MIC]", status)
        self.q.put(bytes(indata))

    def listen_once(self, seconds=7):
        self.rec.Reset()
        print("Listening...")
        with sd.RawInputStream(
            samplerate=self.sample_rate,
            blocksize=8000,
            dtype="int16",
            channels=1,
            callback=self._callback
        ):
            import time
            end = time.time() + seconds
            while time.time() < end:
                try:
                    data = self.q.get(timeout=0.5)
                except queue.Empty:
                    continue
                if self.rec.AcceptWaveform(data):
                    result = json.loads(self.rec.Result())
                    text = result.get("text", "").strip()
                    if text:
                        return text
            result = json.loads(self.rec.FinalResult())
            return result.get("text", "").strip()
