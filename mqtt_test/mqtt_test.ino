#include "EspMQTTClient.h"

long lastMsg = 0;
int pos = 0;

EspMQTTClient client(
  "BT-M8ATFF",
  "A3vLURaktctcDq",
  "192.168.1.123",    // MQTT Broker server ip
  "FlowSurveyMotor",  // Client name that uniquely identify your device
  1883                // MQTT Broker Port
);

void setup() {
  Serial.begin(115200);
  client.enableDebuggingMessages(); // Enable debugging messages sent to serial output
  client.enableHTTPWebUpdater(); // Enable the web updater. User and password default to values of MQTTUsername and MQTTPassword. These can be overridded with enableHTTPWebUpdater("user", "password").
  client.enableOTA(); // Enable OTA (Over The Air) updates. Password defaults to MQTTPassword. Port is the default OTA port. Can be overridden with enableOTA("password", port).
  }

void onConnectionEstablished() {

  client.subscribe("FlowSurveyMotor/Enable",onTestMessageReceived);
  client.publish("FlowSurveyMotor/Position", String(pos));
}

void onTestMessageReceived(const String& message) {
  Serial.print("message received from FlowSurveyMotor/Enable: " + message);
}


void loop() {
  client.loop();
  if(client.isConnected()){
  long now = millis();
  if (now - lastMsg > 1000) {
    lastMsg = now;
    client.publish("FlowSurveyMotor/Position", String(++pos),true);
  }
  }
}
