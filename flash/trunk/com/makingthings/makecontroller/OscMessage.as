﻿/********************************************************************************* Copyright 2006 MakingThings Licensed under the Apache License,  Version 2.0 (the "License"); you may not use this file except in compliance  with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License. *********************************************************************************//** 	An OscMessage simply includes an address and a list of arguments.*/class com.makingthings.makecontroller.OscMessage{	private var address:String;	private var args:Array;	/**	Constructor	*/	function OscPacket( address:String, arg )	{		if( address == undefined )			this.address = "";		else			this.address = address;					this.args = new Array( );		if( arg == undefined )			return;		else			this.args[0] = arg;	}		/**	Add an argument to an OscMessage.	The given argument is added to the array of arguments	*/	public function addArgument( arg )	{		if( arg != undefined )			this.args.push( arg );	}		/**	Get the number of arguments in an OscMessage.	/return A number specifying how many arguments are included in the OscMessage.	*/	public function numberOfArgs( ):Number	{		return this.args.length;	}		/**	Return a string representing an OscMessage - not implemented.	/return The OscMessage as a string.	This will look something like \verbatim "/address arg1 (arg2)..." \endverbatim	*/	public static function OscMessageToString( oscM:OscMessage ):String	{		return "";	}		/**	Get the address of an OscMessage.	\return The address of an OscMessage as a string.	*/	public function getAddress( ):String	{		return this.address;	}		/**	Set the address of an OscMessage.	\param addr A string representing the OSC address of an OscMessage.	If an address already exists for the given OscMessage, this will replace it.	*/	public function setAddress( addr:String )	{		this.address = addr;	}		/**	Reset and clear out an OscMessage for reuse.	*/	public function clear( )	{		this.address = "";		for( var i = 0; i < this.args.length; i++ )			this.args.pop();	}}