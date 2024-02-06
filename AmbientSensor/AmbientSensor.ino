#include <Wire.h>
#include "Adafruit_BMP3XX.h"
#include <Adafruit_Sensor.h>
#include <SPI.h>
#include "EspMQTTClient.h"

// Replace the next variables with your SSID/Password combination
const char* ssid = "WT_7x5_Instrumentation";
const char* password = "WindTunnel22";

// Add your MQTT Broker IP address, example:
const char* mqtt_server = "192.168.1.61";

EspMQTTClient client(
  "WT_7x5_Instrumentation",
  "WindTunnel22",
  "192.168.1.61",    // MQTT Broker server ip
  "AmbientEsp32",  // Client name that uniquely identify your device
  1883                // MQTT Broker Port
);


long lastMsg = 0;
char msg[50];
int value = 0;

//uncomment the following lines if you're using SPI

#define BMP_SCK 13
#define BMP_MISO 12
#define BMP_MOSI 11
#define BMP_CS 21

#define SEALEVELPRESSURE_HPA (1013.25)

Adafruit_BMP3XX bmp;

float temperature = 0;
float pressure = 0;
float interval = 5000;
int messageTemp;
const int ledPin = 4;

void setup() {
  Serial.begin(115200);
  // default settings
  // (you can also pass in a Wire library object like &Wire2)
  //status = bme.begin();  

  client.enableDebuggingMessages(); // Enable debugging messages sent to serial output
  client.enableHTTPWebUpdater(); // Enable the web updater. User and password default to values of MQTTUsername and MQTTPassword. These can be overridded with enableHTTPWebUpdater("user", "password").
  client.enableOTA(); // Enable OTA (Over The Air) updates. Password defaults to MQTTPassword. Port is the default OTA port. Can be overridden with enableOTA("password", port).



  pinMode(ledPin, OUTPUT);
  

  Serial.begin(115200);
  while (!Serial);
  Serial.println("Adafruit BMP388 / BMP390 test");

  if (! bmp.begin_SPI(BMP_CS)) { 
    Serial.println("Could not find a valid BMP3 sensor, check wiring!");
    while (1);
  }

  // Set up oversampling and filter initialization
  bmp.setTemperatureOversampling(BMP3_OVERSAMPLING_8X);
  bmp.setPressureOversampling(BMP3_OVERSAMPLING_4X);
  bmp.setIIRFilterCoeff(BMP3_IIR_FILTER_COEFF_3);
  bmp.setOutputDataRate(BMP3_ODR_50_HZ);
}

void onConnectionEstablished() {
  client.subscribe("Ambient/Interval",onIntervalMessageReceived);
}

void onIntervalMessageReceived(const String& message) {
  Serial.println("message received from Ambient/Interval: " + message);
  interval = message.toInt();
}

void loop() {
  client.loop();

  long now = millis();

  if (now - lastMsg > interval) {
    lastMsg = now; 
    bmp.performReading();
    temperature = bmp.temperature;

    // Convert the value to a char array
    char tempString[8];
    dtostrf(temperature, 1, 2, tempString);
    Serial.print("Temperature: ");
    Serial.println(tempString);
    client.publish("Ambient/Temperature", tempString);

    pressure = bmp.pressure / 100.0;
    
    // Convert the value to a char array
    char presString[8];
    dtostrf(pressure, 1, 2, presString);
    Serial.print("Pressure: ");
    Serial.println(presString);
    client.publish("Ambient/Pressure", presString);
  }
}
