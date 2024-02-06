#include "EspMQTTClient.h"
#include "FastAccelStepper.h"
#include "AVRStepperPins.h" // Only required for AVR controllers

#define dirPinStepper     14
#define enablePinStepper  15
#define BrakeEnablePin    12
#define BrakeLightPin     13
#define stepPinStepper    32
#define EStopPin          33

FastAccelStepperEngine engine = FastAccelStepperEngine();
FastAccelStepper *stepper = NULL;


long lastSample = 0;
int sampleInterval = 10;

float encoderSum;
float encoderValues[20];
int encoderMaxIdx = 20;
int encoderIdx = 0;

long lastMsg = 0;
int messageInterval = 200;

int pos = 0;

int motorSpeed = 1000;
const int motorSpeedMax = 3000;
const int motorSpeedMin = 50;

int motorAcceleration = 200;
const int motorAccelMax = 500;
const int motorAccelMin = 50;

enum MotorState {Disconnected,Disabled,Enabled,Moving};
bool lastEstopVal = false;

MotorState mState = Disconnected;

EspMQTTClient client(
  "WT_7x5_Instrumentation",
  "WindTunnel22",
  "192.168.1.61",    // MQTT Broker server ip
  "FlowSurveyMotor",  // Client name that uniquely identify your device
  1883                // MQTT Broker Port
);

bool MotorEnable(uint8_t enablePin,uint8_t value){
  digitalWrite(enablePin,value);
//    delay(200);
    digitalWrite(BrakeEnablePin,value==HIGH?LOW:HIGH);
    digitalWrite(BrakeLightPin,value==HIGH?LOW:HIGH); 
//  if(value){
//    digitalWrite(enablePin,value);
//    delay(200);
//    digitalWrite(BrakeEnablePin,value==HIGH?LOW:HIGH);
//    digitalWrite(BrakeLightPin,value==HIGH?LOW:HIGH); 
//  }
//  else{
//    digitalWrite(BrakeEnablePin,value==HIGH?LOW:HIGH);
//    digitalWrite(BrakeLightPin,value==HIGH?LOW:HIGH); 
//    delay(200);
//    digitalWrite(enablePin,value);
//  }
  return value;
}

void setState(MotorState new_state){
  if (mState != new_state){
    mState = new_state;
    client.publish("FlowSurvey/Motor/State", String(mState),true);
  }
}

void setup() {
  // Brake Setup
  pinMode(BrakeEnablePin, OUTPUT);
  pinMode(BrakeLightPin, OUTPUT);
  pinMode(EStopPin, INPUT);
  digitalWrite(BrakeEnablePin, true);
  digitalWrite(BrakeLightPin, true);
  lastEstopVal = digitalRead(EStopPin);
  setState(lastEstopVal?Disabled:Enabled);
  
  Serial.begin(115200);
  client.enableDebuggingMessages(); // Enable debugging messages sent to serial output
  client.enableHTTPWebUpdater(); // Enable the web updater. User and password default to values of MQTTUsername and MQTTPassword. These can be overridded with enableHTTPWebUpdater("user", "password").
  client.enableOTA(); // Enable OTA (Over The Air) updates. Password defaults to MQTTPassword. Port is the default OTA port. Can be overridden with enableOTA("password", port).

  engine.init();
  stepper = engine.stepperConnectToPin(stepPinStepper);
  if (stepper) {
    stepper->setDirectionPin(dirPinStepper);
    stepper->setEnablePin(enablePinStepper);
    stepper->setAutoEnable(true);  
    stepper->setSpeedInHz(motorSpeed);       // 500 steps/s
    stepper->setAcceleration(motorAcceleration);    // 100 steps/s²
    stepper->setExternalEnableCall(MotorEnable);
  }
}

void onEStopChanged(bool val){
  if(val){
    stepper->forceStopAndNewPosition(0);
    digitalWrite(BrakeEnablePin, true);
    digitalWrite(BrakeLightPin, true);
    setState(Disabled);
  }
  else{
    setState(Enabled);
  }  
}
void onConnectionEstablished() {
  logMessage("FlowSurvey Microcontroller up and Running");
  client.subscribe("FlowSurvey/Motor/Target",onTargetMessageReceived);
  client.subscribe("FlowSurvey/Motor/Interval",onIntervalReceived);
  client.subscribe("FlowSurvey/Motor/Speed/Set",onSpeedMessageReceived);
  client.subscribe("FlowSurvey/Motor/Accel/Set",onAccelMessageReceived);
  client.subscribe("FlowSurvey/Brake/Enable",onBrakeEnableMessageReceived);
  client.subscribe("FlowSurvey/Brake/Stop",onStopMessageReceived);
  client.subscribe("FlowSurvey/Brake/HardStop",onHardStopMessageReceived);
  client.publish("FlowSurvey/Motor/Position", String(0));
  client.publish("FlowSurvey/Motor/Speed/Set", String(motorSpeed));
  client.publish("FlowSurvey/Motor/Accel/Set", String(motorAcceleration));
}


void logMessage(String str){
  Serial.println(str);
  client.publish("FlowSurvey/Log",str);
}

void onHardStopMessageReceived(const String& message) {
  logMessage("message received from FlowSurvey/Motor/Speed: " + message);
  if (stepper){
    onEStopChanged(true);
  }
}

void onStopMessageReceived(const String& message) {
  logMessage("message received from FlowSurvey/Motor/Speed: " + message);
  if (stepper){
    stepper->stopMove();
  }
}

void onSpeedMessageReceived(const String& message) {
  logMessage("message received from FlowSurvey/Motor/Speed: " + message);
  if (stepper){
    int tmpMotorSpeed = constrain(message.toInt(),motorSpeedMin,motorSpeedMax);
    stepper->setSpeedInHz(tmpMotorSpeed);
    client.publish("FlowSurvey/Motor/Speed/Get",String(tmpMotorSpeed));
  }
}

void onAccelMessageReceived(const String& message) {
  logMessage("message received from FlowSurvey/Motor/Accel: " + message);
  if (stepper){
    int tmpAccel = constrain(message.toInt(),motorAccelMin,motorAccelMax);
    stepper->setAcceleration(tmpAccel);
    client.publish("FlowSurvey/Motor/Accel/Get",String(tmpAccel));
  }
}

void onIntervalReceived(const String& message) {
  logMessage("message received from FlowSurvey/Motor/Interval: " + message);
  messageInterval = message.toInt();
}

void onTargetMessageReceived(const String& message) {
  if (mState == Enabled){
    stepper->moveTo(message.toInt());
    logMessage("message received from FlowSurvey/Motor/Target: " + message + ", Sending Target!");
  }
  else{
    logMessage("message received from FlowSurvey/Motor/Target: " + message + ", Ignored as not Enabled!");
  }
}

void onBrakeEnableMessageReceived(const String& message) {
  digitalWrite(BrakeEnablePin, message.toInt()==1);
  digitalWrite(BrakeLightPin, message.toInt()==1);
  logMessage("message received from FlowSurvey/Brake/Enable: " + message);
}

void loop() {
  // Estop Loop
  bool isStop = digitalRead(EStopPin);
  if(isStop != lastEstopVal)
  {
    onEStopChanged(isStop);
  }
  lastEstopVal = isStop;
  if(stepper){
    if(isStop) setState(Disabled);
    else{
      setState(stepper->isRunning()?Moving:Enabled);
    }
  }
  else{
    setState(Disconnected);
  }
  // main loop
  client.loop();
  if(client.isConnected()){
  long now = millis();
  if (now - lastSample > sampleInterval) {
    lastSample = now;
    encoderSum -= encoderValues[encoderIdx];
    encoderValues[encoderIdx] = float(analogRead(A2));
    encoderSum += encoderValues[encoderIdx++];
    if(++encoderIdx >= encoderMaxIdx) encoderIdx = 0;
  }
  if (now - lastMsg > messageInterval) {
    lastMsg = now;
    if (stepper) {
      client.publish("FlowSurvey/Motor/Position", String(stepper->getCurrentPosition()),true);
      client.publish("FlowSurvey/Encoder/Counts", String(encoderSum/encoderMaxIdx,2),true);
    }
  }
  }
}
