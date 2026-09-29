#include <Arduino.h>
#include <ESP32Servo.h>

// ============================================================
// Mini AI Robot V1 - ESP32 controller
// Rear wheels = drive
// Front wheels = lifting "hands"
// Head = pan servo
//
// IMPORTANT:
// The front arms are mechanically load-bearing. Use a bearing/pin
// at the arm pivot. The servo should rotate the arm, not carry
// the robot's weight directly.
// ============================================================

// -------- TB6612FNG / compatible H-bridge --------
const int AIN1 = 25;
const int AIN2 = 26;
const int PWMA = 27;

const int BIN1 = 32;
const int BIN2 = 33;
const int PWMB = 14;

const int STBY = 13;

const int PWM_FREQ = 20000;
const int PWM_RES  = 8;
const int CH_A = 0;
const int CH_B = 1;

// -------- Servos --------
const int LEFT_ARM_SERVO  = 18;
const int RIGHT_ARM_SERVO = 19;
const int HEAD_SERVO      = 21;

Servo leftArm;
Servo rightArm;
Servo headServo;

// Calibrate these AFTER mounting the arms.
// Never force an arm against a mechanical stop.
int LEFT_DOWN  = 20;
int LEFT_UP    = 100;
int RIGHT_DOWN = 160;
int RIGHT_UP   = 80;

bool driving = false;

void pwmWriteA(int value) {
  ledcWrite(CH_A, constrain(value, 0, 255));
}

void pwmWriteB(int value) {
  ledcWrite(CH_B, constrain(value, 0, 255));
}

void motorA(int speed) {
  speed = constrain(speed, -255, 255);

  if (speed > 0) {
    digitalWrite(AIN1, HIGH);
    digitalWrite(AIN2, LOW);
    pwmWriteA(speed);
  } else if (speed < 0) {
    digitalWrite(AIN1, LOW);
    digitalWrite(AIN2, HIGH);
    pwmWriteA(-speed);
  } else {
    digitalWrite(AIN1, LOW);
    digitalWrite(AIN2, LOW);
    pwmWriteA(0);
  }
}

void motorB(int speed) {
  speed = constrain(speed, -255, 255);

  if (speed > 0) {
    digitalWrite(BIN1, HIGH);
    digitalWrite(BIN2, LOW);
    pwmWriteB(speed);
  } else if (speed < 0) {
    digitalWrite(BIN1, LOW);
    digitalWrite(BIN2, HIGH);
    pwmWriteB(-speed);
  } else {
    digitalWrite(BIN1, LOW);
    digitalWrite(BIN2, LOW);
    pwmWriteB(0);
  }
}

void stopMotors() {
  motorA(0);
  motorB(0);
  driving = false;
}

void drive(String d) {
  const int SPEED = 145;

  // Do not drive while front wheel-hands are raised.
  // This is a simple state protection for the prototype.
  if (d != "S") {
    // Keep arms down before driving.
    leftArm.write(LEFT_DOWN);
    rightArm.write(RIGHT_DOWN);
  }

  if (d == "F") {
    motorA(SPEED);
    motorB(SPEED);
    driving = true;
  }
  else if (d == "B") {
    motorA(-SPEED);
    motorB(-SPEED);
    driving = true;
  }
  else if (d == "L") {
    motorA(-SPEED);
    motorB(SPEED);
    driving = true;
  }
  else if (d == "R") {
    motorA(SPEED);
    motorB(-SPEED);
    driving = true;
  }
  else {
    stopMotors();
  }
}

void armsDown() {
  leftArm.write(LEFT_DOWN);
  rightArm.write(RIGHT_DOWN);
}

void armsUp() {
  // Safety: don't lift while driving.
  if (driving) {
    stopMotors();
  }

  leftArm.write(LEFT_UP);
  rightArm.write(RIGHT_UP);
}

void gestureHello() {
  stopMotors();

  armsUp();
  delay(450);

  // Small alternating wave.
  for (int i = 0; i < 2; i++) {
    leftArm.write(LEFT_UP - 18);
    delay(180);
    leftArm.write(LEFT_UP);
    delay(180);
    rightArm.write(RIGHT_UP + 18);
    delay(180);
    rightArm.write(RIGHT_UP);
    delay(180);
  }

  armsDown();
}

void gestureHappy() {
  stopMotors();
  armsUp();
  delay(500);
  armsDown();
}

void gestureThink() {
  stopMotors();
  leftArm.write(LEFT_UP);
  delay(700);
  leftArm.write(LEFT_DOWN);
}

void gestureGoodbye() {
  stopMotors();
  armsUp();
  delay(700);
  armsDown();
}

void gesture(String name) {
  name.trim();

  if (name == "HELLO") gestureHello();
  else if (name == "HAPPY") gestureHappy();
  else if (name == "THINK") gestureThink();
  else if (name == "GOODBYE") gestureGoodbye();
}

void handleCommand(String line) {
  line.trim();
  if (line.length() == 0) return;

  if (line.startsWith("MOVE ")) {
    drive(line.substring(5));
  }
  else if (line.startsWith("ARM ")) {
    String a = line.substring(4);

    if (a == "BOTH_UP") armsUp();
    else if (a == "BOTH_DOWN") armsDown();
    else if (a == "L_UP") {
      stopMotors();
      leftArm.write(LEFT_UP);
    }
    else if (a == "L_DOWN") leftArm.write(LEFT_DOWN);
    else if (a == "R_UP") {
      stopMotors();
      rightArm.write(RIGHT_UP);
    }
    else if (a == "R_DOWN") rightArm.write(RIGHT_DOWN);
  }
  else if (line.startsWith("HEAD ")) {
    String h = line.substring(5);

    if (h == "L") headServo.write(60);
    else if (h == "C") headServo.write(90);
    else if (h == "R") headServo.write(120);
  }
  else if (line.startsWith("GESTURE ")) {
    gesture(line.substring(8));
  }
}

void setup() {
  Serial.begin(115200);

  pinMode(AIN1, OUTPUT);
  pinMode(AIN2, OUTPUT);
  pinMode(PWMA, OUTPUT);
  pinMode(BIN1, OUTPUT);
  pinMode(BIN2, OUTPUT);
  pinMode(PWMB, OUTPUT);
  pinMode(STBY, OUTPUT);

  ledcSetup(CH_A, PWM_FREQ, PWM_RES);
  ledcSetup(CH_B, PWM_FREQ, PWM_RES);
  ledcAttachPin(PWMA, CH_A);
  ledcAttachPin(PWMB, CH_B);

  digitalWrite(STBY, HIGH);

  leftArm.setPeriodHertz(50);
  rightArm.setPeriodHertz(50);
  headServo.setPeriodHertz(50);

  leftArm.attach(LEFT_ARM_SERVO, 500, 2500);
  rightArm.attach(RIGHT_ARM_SERVO, 500, 2500);
  headServo.attach(HEAD_SERVO, 500, 2500);

  armsDown();
  headServo.write(90);
  stopMotors();

  Serial.println("ROBOT_READY");
}

void loop() {
  if (Serial.available()) {
    String line = Serial.readStringUntil('\n');
    handleCommand(line);
    Serial.println("OK");
  }
}
