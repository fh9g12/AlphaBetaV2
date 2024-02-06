#include "FastAccelStepper.h"
#include "AVRStepperPins.h" // Only required for AVR controllers

#define dirPinStepper    32
#define enablePinStepper 14
#define stepPinStepper   33
#define A1               25

// If using an AVR device use the definitons provided in AVRStepperPins
//    stepPinStepper1A
//
// or even shorter (for 2560 the correct pin on the chosen timer is selected):
//    stepPinStepperA

FastAccelStepperEngine engine = FastAccelStepperEngine();
FastAccelStepper *stepper = NULL;

int trgt = 2000;

void setup() {
   engine.init();
   stepper = engine.stepperConnectToPin(stepPinStepper);
   if (stepper) {
      stepper->setDirectionPin(dirPinStepper);
      stepper->setEnablePin(enablePinStepper);
      stepper->setAutoEnable(true);

      stepper->setSpeedInHz(1000);       // 500 steps/s
      stepper->setAcceleration(200);    // 100 steps/s²
      stepper->move(1000);
   }
}

void loop() {
  if (stepper) {
    if(stepper->isQueueEmpty()){
      if(!(stepper->isRunning())){
        delay(1000);
        stepper->move(trgt);
        trgt = -trgt;
    }
    }    
  }
}
