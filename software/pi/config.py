import os

SERIAL_PORT = os.getenv("ROBOT_SERIAL", "/dev/ttyUSB0")
BAUD = 115200

# Voice
VOSK_MODEL_PATH = os.getenv("VOSK_MODEL_PATH", "./models/vosk-model-small-en-us-0.15")
SAMPLE_RATE = 16000

# Optional local AI through Ollama.
# Install Ollama separately and pull a small model such as llama3.2:1b.
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://127.0.0.1:11434/api/generate")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llama3.2:1b")

# Robot behavior
ARM_WHILE_SPEAKING = True
AUTO_GREET = True
CAMERA_INDEX = 0
