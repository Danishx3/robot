# FULL SOFTWARE INSTALLATION

## 1. ESP32

Install Arduino IDE.

Install:
- ESP32 board support
- ESP32Servo library

Open:
esp32/robot_controller.ino

Select your ESP32 board and upload.

IMPORTANT:
Before attaching the wheel arms, test the servos with the arms removed.
Adjust LEFT_DOWN, LEFT_UP, RIGHT_DOWN and RIGHT_UP slowly.

## 2. Raspberry Pi

Install Raspberry Pi OS.

Open terminal:

sudo apt update
sudo apt install -y python3-venv python3-pip portaudio19-dev espeak-ng libespeak1

Create environment:

cd pi
python3 -m venv .venv
source .venv/bin/activate

Install:

pip install -r requirements.txt

## 3. Voice model

Create:

pi/models/

Download a small English Vosk model from the official Vosk model list and extract it as:

pi/models/vosk-model-small-en-us-0.15

Then set:

export VOSK_MODEL_PATH="./models/vosk-model-small-en-us-0.15"

## 4. Connect ESP32

Connect ESP32 by USB.

Check:

ls /dev/ttyUSB*
ls /dev/ttyACM*

If needed:

export ROBOT_SERIAL="/dev/ttyUSB0"

## 5. Test hardware first

Run:

python robot.py

If robot.py is not present, use main.py after copying all files in this pi folder.

## 6. Start robot

python main.py

The robot should:
- start with arms down
- say a startup message
- listen
- understand basic movement commands
- answer using local Ollama if available
- raise the front wheel-hands while speaking

## 7. Optional local AI

Install Ollama separately on a computer that the Raspberry Pi can reach.

Set:

export OLLAMA_URL="http://YOUR_AI_COMPUTER_IP:11434/api/generate"
export OLLAMA_MODEL="llama3.2:1b"

The Pi can then send text to that service.

For a Pi Zero 2 W, running the AI model on another computer is usually more practical than running a large language model directly on the Pi.

## 8. First safety test

Put the robot on a stand with wheels off the floor.

1. Test one servo.
2. Test both arm servos.
3. Confirm the arms cannot hit the body.
4. Test motors at low speed.
5. Only then put the robot on the floor.

Never test a lifting arm against a hard stop.
