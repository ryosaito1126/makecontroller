/*********************************************************************************

 Copyright 2006-2010 MakingThings

 Licensed under the Apache License,
 Version 2.0 (the "License"); you may not use this file except in compliance
 with the License. You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed
 under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 CONDITIONS OF ANY KIND, either express or implied. See the License for
 the specific language governing permissions and limitations under the License.

*********************************************************************************/

#ifndef SERIAL_H
#define SERIAL_H

#include "types.h"

#ifdef __cplusplus
extern "C" {
#endif
void serialInit(void);
void serialEnableDefault(int port);
void serialEnable(int port, int baud, int parity, int charbits, int stopbits, bool handshake);
void serialDisable(int port);
int  serialAvailable(int port);
int  serialRead(int port, char* buf, int len, int timeout);
char serialGet(int port, int timeout);
int  serialWrite(int port, char* buf, int len, int timeout);
int  serialPut(int port, char c, int timeout);
#ifdef __cplusplus
}
#endif
#endif // SERIAL_H