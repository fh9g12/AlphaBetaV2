const int DIR = 32;
const int STEP = 33;
const int  steps_per_rev = 2000;

void setup()
{
  Serial.begin(115200);
  pinMode(STEP, OUTPUT);
  pinMode(DIR, OUTPUT);
}
void loop()
{
  digitalWrite(DIR, HIGH);
  Serial.println("Spinning Clockwise...");
  
  for(int i = 0; i<steps_per_rev; i++)
  {
    digitalWrite(STEP, HIGH);
    delayMicroseconds(1000);
    digitalWrite(STEP, LOW);
    delayMicroseconds(1000);
  }
  delay(1000); 
  
  digitalWrite(DIR, LOW);
  Serial.println("Spinning Anti-Clockwise...");

  for(int i = 0; i<steps_per_rev; i++)
  {
    digitalWrite(STEP, HIGH);
    delayMicroseconds(1000);
    digitalWrite(STEP, LOW);
    delayMicroseconds(1000);
  }
  delay(1000);
}
