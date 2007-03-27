/*********************************************************************************

 Copyright 2006 MakingThings

 Licensed under the Apache License, 
 Version 2.0 (the "License"); you may not use this file except in compliance 
 with the License. You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0 
 
 Unless required by applicable law or agreed to in writing, software distributed
 under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 CONDITIONS OF ANY KIND, either express or implied. See the License for
 the specific language governing permissions and limitations under the License.

*********************************************************************************/

/*
	RTOS.H

  MakingThings
*/

#ifndef RTOS_H
#define RTOS_H

void  Sleep( int timems );
void* TaskCreate(  void (taskCode)(void*), char* name, int stackDepth, void* parameters, int priority );
void  TaskYield( void );
void  TaskDelete( void* task );
void  TaskEnterCritical( void );
void  TaskExitCritical( void );

void* Malloc( int size );
void Free( void* memory );

#endif
