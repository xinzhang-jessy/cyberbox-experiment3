/* DIGF 6037 Creation & Computation
 * Kate Hartman & Nick Puckett
 * 
 * 
 * This example interfaces with the Adafruit MPR121 capacitive board: https://learn.adafruit.com/adafruit-mpr121-12-key-capacitive-touch-sensor-breakout-tutorial/overview
 * Reads all 12 pins and writes a 1 or 0 separated by commas
 * 
 * Based on the MPR121test.ino example file
 * 
  */
#include <Wire.h>
#include "Adafruit_MPR121.h"

#ifndef _BV
#define _BV(bit) (1 << (bit)) 
#endif

Adafruit_MPR121 cap = Adafruit_MPR121();

// Keeps track of the last pins touched
uint16_t currtouched = 0;

int tp = 12; //change this if you aren't using them all, start at pin 0

void setup() 
{
  Serial.begin(9600);

  if (!cap.begin(0x5A)) {
    Serial.println("MPR121 not found, check wiring?");
    while (1);
  }
  Serial.println("MPR121 found!");
}

void loop() 
{
//run the function to check the cap interface
checkAllPins(tp);

//make a new line to separate the message
 Serial.println();
   // put a delay so it isn't overwhelming
 delay(100);
}

void checkAllPins(int totalPins)
{
  // Get the currently touched pads
  currtouched = cap.touched();
  
  for (uint8_t i=0; i<totalPins; i++) 
  {
    // it if *is* touched set 1 if no set 0
    if ((currtouched & _BV(i)))
    {
      Serial.print(1); 
    }
    else
    {
      Serial.print(0);
    }

  ///adds a comma after every value but the last one
  if(i<totalPins-1)
  {
    Serial.print(",");
  }

  
}

  
}
