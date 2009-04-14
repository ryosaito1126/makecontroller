/*********************************************************************************

 Copyright 2006-2008 MakingThings

 Licensed under the Apache License, 
 Version 2.0 (the "License"); you may not use this file except in compliance 
 with the License. You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0 
 
 Unless required by applicable law or agreed to in writing, software distributed
 under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 CONDITIONS OF ANY KIND, either express or implied. See the License for
 the specific language governing permissions and limitations under the License.

*********************************************************************************/

#ifndef MOTOR_H
#define MOTOR_H

#include "pwmout.h"

/**
  The Motor subsystem provides forward/reverse and speed control for up to 4 DC motors across the 8 high current outputs.
  Each motor controller is composed of 2 adjacent Digital Outs on the Make Application Board:
  - motor 0 - Digital Outs 0 and 1.
  - motor 1 - Digital Outs 2 and 3.
  - motor 2 - Digital Outs 4 and 5.
  - motor 3 - Digital Outs 6 and 7.
  
  Other output devices cannot be used simultaneously - for example, the DigitalOuts cannot be called without
  first setting overlapping the DC motor I/O lines to inactive.
  
  See the digital out section of the 
  <a href="http://www.makingthings.com/documentation/tutorial/application-board-overview/digital-outputs">
  Application Board overview</a> for more details.
  \ingroup Libraries
*/
class Motor
{
  public:
    Motor(int index);
    ~Motor();

    int speed();
    bool setSpeed(int speed);

    bool direction();
    bool setDirection(bool forward);

  protected:
    int _index;
    typedef struct {
      PwmOut* pwmout;
      short refcount;
      int direction;
      int speed;
    } MotorInternal;
    static MotorInternal* motors[]; // only ever want to make 4 of these

    void finalize(MotorInternal* m);
};

/* OSC Interface */
const char* MotorOsc_GetName( void );
int MotorOsc_ReceiveMessage( int channel, char* message, int length );

#endif
