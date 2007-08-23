﻿/*********************************************************************************
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

import com.makingthings.makecontroller.OscMessage;
import com.makingthings.makecontroller.AddressHandler;
import com.makingthings.makecontroller.Board;
import mx.utils.Delegate;

/** 
	The interface to the FLOSC server.
	
	Mchelper (Make Controller Helper) is a separate application that must be run simultaneously with your Flash application.
	Because Flash can't connect to external devices by itself, Mchelper is a necessary intermediate step - 
	it can connect to the Make Controller over the network, and then it formats communication with the board
	into XML that can be fed in and out of Flash.  
	
	FLOSC needs to know about a few values concerning the network configuration:
	- <b>mchelperAddress</b> is the IP address of the machine that FLOSC and your Flash application are running on.
	- <b>mchelperPort</b> is the port that your computer is listening on - the default is <b>10000</b>.
	- <b>remoteAddress</b> is the address of the Make Controller that you're communicating with - the default is <b>192.168.0.200</b>
	- <b>remotePort</b> is the port that the Make Controller is listening on for incoming messages - the default is <b>10000</b>.
	
	These are the values that are loaded up by default when you create a new Flosc object.  It's easy to change them for your setup
	however, as you'll see below.
	
	
*/

class com.makingthings.makecontroller.McFlashConnect 
{
	private var mchelperAddress; // whatever the IP address of your machine is most likely to be
	private var mchelperPort;  //Make Controller default
	private var remoteAddress;  //Make Controller default
	private var remotePort;  //Make Controller default
	private var registeredAddresses:Array; // list of registered addresses and functions to call if a message with that address shows up
	private var connectedBoards:Array;
	
	
	private var mySocket:XMLSocket;
	public var connected:Boolean; 
	
  //Constructor - initialize a bit of state.
  function McFlashConnect( remoteAddress:String, remotePort:Number )
  {
		connected = false;
		mchelperAddress = "localhost"
		mchelperPort = 11000;
		this.remoteAddress = remoteAddress;
		this.remotePort = remotePort;
		registeredAddresses = new Array( );
		connectedBoards = new Array( );
  }
	
	/**
	* Query the local address that has been set.
	* \return A string specifying the current address.
	
	<h3>Example</h3>
	\code
	var myMchelperAddress:String;
	myAddress = flosc.getMchelperAddress( );
	\endcode
 	*/
	public function getMchelperAddress( ):String
	{
		return mchelperAddress;
	}
	/**
	* Set the address of the computer that is connecting to FLOSC.
	* \param addr A string specifying the address.
	
	<h3>Example</h3>
	\code
	flosc.setMchelperAddress( "192.168.0.215" );
	\endcode
 	*/
	public function setMchelperAddress( addr:String ):Void
	{
		mchelperAddress = addr;
	}
	/**
	* Query the port that has been set.
	* \return A number specifying the current port.
	
	<h3>Example</h3>
	\code
	var myMchelperPort:Number;
	myMchelperPort = flosc.getMchelperPort( );
	\endcode
 	*/
	public function getMchelperPort( ):Number
	{
		return mchelperPort;
	}
	/**
	* Set the port that the local computer should listen on.
	* By default, this should be \b 10000 for use with the Make Controller.
	* \param port A number specifying the port.
	<h3>Example</h3>
	\code
	// listen on port 10101
	flosc.setMchelperPort( 10101 );
	\endcode
 	*/
	public function setMchelperPort( port:Number ):Void
	{
		mchelperPort = port;
	}
	
	/**
	* Query the IP address that the local computer has been told to send messages to.
	* The default address of the Make Controller is 192.168.0.200
	* \return A string specifying the IP address of the device you're sending to
	
	<h3>Example</h3>
	\code
	var myRemoteAddress:String;
	myRemoteAddress = flosc.getRemoteAddress( );
	\endcode
 	*/
	public function getRemoteAddress( ):String
	{
		return remoteAddress;
	}
	
	/**
	* Set the address of the device you're sending to.
	* The default address of the Make Controller is 192.168.0.200.  This will be the address used by defult when sending messages
	unless you use a method that allows you to specify an address explicitly.
	* \param addr A string specifying the address.
	
	<h3>Example</h3>
	\code
	flosc.setRemoteAddress( "192.168.0.210" );
	// now the normal send() method will send to 192.168.0.210
	flosc.send( "/appled/0/state", "1" );
	\endcode
 	*/
	public function setRemoteAddress( addr:String ):Void
	{
		remoteAddress = addr;
	}
	
	/**
	* Query the port that the local machine has been told to send messages on.
	* \return A number specifying the current port.
	
	<h3>Example</h3>
	\code
	var myRemotePort:Number;
	myRemotePort = flosc.getRemotePort( );
	\endcode
 	*/
	public function getRemotePort( ):Number
	{
		return remotePort;
	}
	
	/**
	* Set the port to send messages on.
	* The default port that the Make Controller is listening on is 10000
	* \param port A number specifying the port.
	
	<h3>Example</h3>
	\code
	// send messages on port 10101
	flosc.setRemotePort( 10101 );
	\endcode
 	*/
	public function setRemotePort( port:Number ):Void
	{
		remotePort = port;
	}
	
	/**
	Register a handler for messages coming from a given OSC address.
	You can create a function of your own that will get called whenever an incoming OSC message matches
	a particular address.  This saves you from checking the address of all incoming OSC messages.
	
	Your callback should be in the form:
	\code myCallback( args:String ); \endcode
	
	\param addr The OSC address to match.
	\param callback The function that you want to be called back on.
	
	\par Example
	\code
	setAddressHandler( "/analogin/7/value", onTrimpot );
	
	function onTrimpot( value:String ) // this will get called whenever a message from /analogin/7/value is received.
	{
		trace( "trimpot is at value " + value );
	}
	\endcode
 	*/
	public function addAddressListener( addr:String, callback:Function )
	{
		var handler = new AddressHandler( addr, callback );
		registeredAddresses.push( handler );
	}
	
	
	// ************************************************************************************************************************************
	// OSC stuff
	// ************************************************************************************************************************************
	
	// ** parse messages from an XML-encoded OSC packet
	private function parseMessages( node:XMLNode ) : Void //this is called when we get OSC packets back from FLOSC.
	{	
		var time:Number = node.attributes.TIME;
		var addr:String = node.attributes.ADDRESS;
		var message:XMLNode = node.firstChild;
		while( message != null )
		{
			if (message.nodeName == "MESSAGE")
			{
				var msgName:String = message.attributes.NAME;		
				var oscData:Array = [];
				for (var child:XMLNode = message.firstChild; child != null; child=child.nextSibling)
				{
					if (child.nodeName == "ARGUMENT")
					{
						var type:String = child.attributes.TYPE;
						//float
						if (type=="f") {
							oscData.push(parseFloat(child.attributes.VALUE));
						} else 
						// int
						if (type=="i") {
							oscData.push(parseInt(child.attributes.VALUE));
						} else 
						//string
						if (type=="s") {
							oscData.push(child.attributes.VALUE);
						}	
						//trace( "Address: " + node.attributes.NAME + ", Arg: " + child.attributes.VALUE );
					}
				}
				var msg:OscMessage = new OscMessage( msgName, oscData );
				msg.from = addr;
				msg.time = time;
				//trace( "name: " + msg.address + ", arg: " + msg.args[0] + ", from: " + msg.fromIpAddress );
				doCallback( msg );
				message = message.nextSibling; // move to the next MESSAGE node, if there is one
			}
		}
	}
	
	private function doCallback( msg:OscMessage ) : Void
	{
		var knownAddresses:Number = registeredAddresses.length;
		var calledBack:Boolean = false;
		for( var i = 0; i < knownAddresses; i++ )
		{
			if( registeredAddresses[i].address == msg.address )
			{
				registeredAddresses[i].callback( msg );
				calledBack = true;
			}
		}
		if( !calledBack )
			onMessageIn( msg );
	}
	
	/**
	* Get called back on this function with any incoming OSC messages.
	* \param address The address of the incoming OSC message as a string.
	* \param argument The value included in the incoming OSC message.
	
	You'll want to set this up with a call to \code setMessageHandler( onMessageIn ) \endcode
	Then, override this method to deal with incoming messages however you like.  Usually, you'll
	want to test the address of the incoming message to see if it's something you're interested in.
	So if you want to listen for the trimpot (analogin 7), you might implement it like...
	
	<h3>Example</h3>
	\code 
	setMessageHandler( onMessageIn );
	
	mcflash.onMessageIn = function( address, arg )
	{
		if( address == "/analogin/7/value" )
			var trimpot = arg;
	}
	\endcode
	Now the <b>trimpot</b> variable holds the value of the trimpot and you can do whatever you like with it. 
 	*/
	public function onMessageIn( msg:OscMessage )
	{
	}
	
	public function onBoardArrived( board:Board )
	{
		//trace( "New board connected: " + board.location );
	}
	
	public function onBoardRemoved( board:Board )
	{
		//trace( "Board removed: " + board.location );
	}
	
	/**
	* Make a connection to the FLOSC server.
	* This will connect using the current values of <b>mchelperAddress</b> and <b>mchelperPort</b>.
	
	<h3>Example</h3>
	\code 
	// use the default network address of the Make Controller (vary as needed)
	flosc.setRemoteAddress( "192.168.0.200" );
	flosc.setRemotePort( 10000 );
	flosc.connect( ); // then connect
	\endcode
 	*/
	public function connect( )
	{
		mySocket = new XMLSocket();
		mySocket.onConnect = Delegate.create( this, handleConnect );
		//mySocket.onClose = handleClose;
		mySocket.onXML = Delegate.create( this, handleIncoming );
	
		if (!mySocket.connect(mchelperAddress, mchelperPort))
			trace( "Can't create XML connection to FLOSC." );
	}
	
	/**
	Disconnect from the FLOSC server.
	This closes the XML connection to FLOSC.  This does not need to be called explicitly before closing your movie.
	
	<h3>Example</h3>
	\code 
	flosc.disconnect( );
	\endcode
 	*/
	public function disconnect( ) 
	{
		if( connected )
		{
			mySocket.close();
			connected = false;
		}
		else
			return;
	}
	
	// *** event handler for incoming XML-encoded OSC packets
  private function handleIncoming (xmlIn)
	{
		// parse out the packet information
		var xmlDoc:XML = new XML( );
		xmlDoc.ignoreWhite = true;
		xmlDoc.parseXML( xmlIn );
		var n:XMLNode = xmlDoc.firstChild;
		if( n != null )
		{
			if( n.nodeName == "OSCPACKET" )
				parseMessages( n );
			else if( n.nodeName == "BOARD_ARRIVAL" || n.nodeName == "BOARD_REMOVAL" )
				updateBoardList( n );
		}
	}
	
	private function updateBoardList( xml:XMLNode ):Void
	{
		var boardMessage:XMLNode = xml.firstChild;
		if( xml.nodeName == "BOARD_ARRIVAL" )
		{
			while( boardMessage != null )
			{
				var newBoard:Board = new Board( boardMessage.attributes.TYPE, boardMessage.attributes.LOCATION );
				connectedBoards.push( newBoard );
				onBoardArrived( newBoard );
				boardMessage = boardMessage.nextSibling;
			}
		}
		else if( xml.nodeName == "BOARD_REMOVAL" )
		{
			while( boardMessage != null )
			{
				for( var i = 0; i < connectedBoards.length; i++ )
				{
					if( connectedBoards[i].location == boardMessage.attributes.LOCATION )
					{
						var newBoard:Board = connectedBoards[i];
						connectedBoards.splice( i, 1 );
						onBoardRemoved( newBoard );
					}
				}
				boardMessage = boardMessage.nextSibling;
			}
		}
	}
	
	// *** event handler to respond to successful connection attempt
	private function handleConnect (succeeded)
	{
		if(succeeded)
			this.connected = true;
		else
		{
			trace( "Connection to Mchelper did not succeed." );
			trace( "** Make sure it's running, and that nothing else is listening on your mchelperPort." );
		}
	}
	
	/**
	* Send a message to the board.
	This will send a message to a board at the current <b>remoteAddress</b> and <b>remotePort</b>.
	If you need to specify the IP address and port for each message, use sendToAddress( ).
	\param address The OSC address to send to, as type \b String.
	\param arg The value to be sent.
	
	<h3>Example</h3>
	\code 
	// Specify the OSC address and argument to send - turn on LED 1
	flosc.send( "/appled/1/state", "1" );
	\endcode
 	*/
	public function send( address:String, args:Array )
	{
		sendToAddress( address, args, remoteAddress, remotePort );
	}
	
	/**
	* Send a message to the board, specifying the IP address and port. 
	* \param name The OSC address to send to.
	* \param arg The value to be sent.
	* \param destAddr The IP address of the board you're sending to.
	* \param destPort	 The port to send your message on.
	
	<h3>Example</h3>
	\code 
	// Specify the OSC address and argument to send - turn on LED 1
	// Also include the IP address and port you want to send the message to
	flosc.sendToAddress( "/appled/1/state", "1", "192.168.0.235", 11001 );
	\endcode
 	*/
	public function sendToAddress( address:String, args:Array, destAddr:String, destPort:Number )
	{
		var xmlOut:XML = new XML();
		var packetOut = createPacketOut( xmlOut, 0, destAddr, destPort );
		var xmlMessage = createMessage( xmlOut, packetOut, address );
		parseArguments( xmlOut, xmlMessage, args );
		
		xmlOut.appendChild(packetOut);
	
		if( mySocket && this.connected )
			mySocket.send(xmlOut);
	}
	
	// used internally to prep an XML object to be sent out.
	private function createPacketOut( xmlOut:XML, time:Number, destAddr:String, destPort:Number ):XMLNode
	{
		var packetOut = xmlOut.createElement("OSCPACKET");
		packetOut.attributes.TIME = 0;
		packetOut.attributes.PORT = destPort;
		packetOut.attributes.ADDRESS = destAddr;
		
		return packetOut;
	}
	
	// used internally to create a message element within the xmlOut object
	private function createMessage( xmlOut:XML, packetOut:XMLNode, address:String ):XMLNode
	{
		var xmlMessage = xmlOut.createElement("MESSAGE");
		xmlMessage.attributes.NAME = address;
		packetOut.appendChild(xmlMessage);
		return xmlMessage;
	}
	
	// used internally to determine the type of an argument, and append it to its corresponding message in the outgoing XML object.
	private function parseArguments( xmlOut:XML, xmlMessage:XMLNode, args:Array )
	{
		var argument:XMLNode;
		var argsLength:Number = args.length;
		// NOTE : the server expects all strings to be encoded with the escape function.
		for( var i = 0; i < argsLength; i++ )
		{
			argument = xmlOut.createElement("ARGUMENT");
			var argInt = parseInt(args[i]);
			if(isNaN(argInt))
			{
				argument.attributes.TYPE = "s";
				argument.attributes.VALUE = escape(args[i]);
			} 
			else
			{
				var argString:String = args[i].toString();
				var stringLength:Number = argString.length;
				var float:Boolean = false;
				for( var j = 0; j < stringLength; j++ )
				{
					if( argString.charAt( j ) == "." )
					{
						argument.attributes.TYPE="f";
						argument.attributes.VALUE=parseFloat(argString);
						float = true;
						break;
					}
				}
				if( !float )
				{
					argument.attributes.TYPE="i";
					argument.attributes.VALUE=parseInt(args[i]);
				}
			}
			xmlMessage.appendChild(argument);
		}
	}
	
	/**
	* Send an OscMessage to the board. 
	This will send a message, of type OscMessage, to a board at the current <b>remoteAddress</b> and <b>remotePort</b>.
	If you need to specify the address and port for each message, use sendMessageToAddress( ).
	\param oscM The message, of type OscMessage, to be sent
	
	<h3>Example</h3>
	\code 
	// create an OscMessage
	var turnOnLed:OscMessage = new OscMessage( "/appled/0/state", "1" );
	// now send it
	flosc.sendMessage( turnOnLed );
	\endcode
 	*/
	public function sendMessage( oscM:OscMessage )
	{
		sendMessageToAddress( oscM, remoteAddress, remotePort );
	}
	
	/**
	* Send an OscMessage to the board, specifying the destination IP address and port. 
	* \param oscM The message, of type OscMessage, to be sent
	* \param destAddr The IP address of the board you're sending to.
	* \param destPort	 The port to send your message on.
	
	<h3>Example</h3>
	\code 
	// create an OscMessage
	var turnOffLed:OscMessage = new OscMessage( "/appled/0/state", "0" );
	// now send it to a specified address
	flosc.sendMessageToAddress( turnOffLed, "192.168.0.222", 10000 );
	\endcode
 	*/
	public function sendMessageToAddress( oscM:OscMessage, destAddr:String, destPort:Number )
	{
		var xmlOut:XML = new XML();
		var packetOut = createPacketOut( xmlOut, 0, destAddr, destPort );
		var xmlMessage = createMessage( xmlOut, packetOut, oscM.address );
		for( var i = 0; i < oscM.args.length; i++ )
			parseArguments( xmlOut, xmlMessage, oscM.args );

		xmlOut.appendChild(packetOut);
	
		if( mySocket && this.connected )
			mySocket.send(xmlOut);
	}
	
	/**
	Send an OscBundle to the board. 
	This will send an OscBundle to a board at the current <b>remoteAddress</b> and <b>remotePort</b>.
	It's a good idea to send bundles when possible, in order to reduce the traffic between the board and Flash.
	If you need to specify the address and port for each message, use sendBundleToAddress( ).
	* \param oscB The OscBundle to be sent
	
	<h3>Example</h3>
	\code 
	// create a couple of OscMessages
	var turnOffLed:OscMessage = new OscMessage( "/appled/0/state", "0" );
	var readAnalogIn:OscMessage = new OscMessage( "/analogin/0/value" );
	// create an Array (this Array will be our OscBundle)
	// and stuff our messages into it
	var myOscBundle:Array = new Array( turnOffLed, readAnalogIn );
	// now send it
	flosc.sendBundle( myOscBundle );
	\endcode
 	*/
	public function sendBundle( oscB:Array )
	{
		sendBundleToAddress( oscB, remoteAddress, remotePort );
	}
	
	/**
	* Send an OscBundle to the board, specifying the destination IP address and port. 
	* \param oscB The OscBundle to be sent
	* \param destAddr The IP address of the board you're sending to.
	* \param destPort	 The port to send on.
	
	<h3>Example</h3>
	\code 
	// create a few OscMessages
	var turnOnLed:OscMessage = new OscMessage( "/appled/3/state", "1" );
	var readAnalogIn:OscMessage = new OscMessage( "/analogin/0/value" );
	var readDipswitch:OscMessage = new OscMessage( "/dipswitch/value" );
	// create an Array (this Array will be our OscBundle)
	// and stuff our messages into it
	var myOscBundle:Array = new Array( turnOffLed, readAnalogIn, readDipswitch );
	// now send it to a specified address
	flosc.sendBundleToAddress( myOscBundle, "192.168.0.213", 10000 );
	\endcode
 	*/
	public function sendBundleToAddress( oscB:Array, destAddr:String, destPort:Number )
	{
		var xmlOut:XML = new XML();
		var packetOut = createPacketOut( xmlOut, 0, destAddr, destPort );
		for( var i = 0; i < oscB.length; i++ )
		{
			if( oscB[i] instanceof OscMessage == false )
			{
				trace( "Error - Item #" + i + " in the OscBundle was not an OscMessage...the entire bundle was not sent." );
				return;
			}

			var oscM:OscMessage = oscB[i];
			//trace( "Message " + i + ", address " + oscM.address + ", arg: " + oscM.args[0] );
			var xmlMessage = createMessage( xmlOut, packetOut, oscM.address );
			for( var j = 0; j < oscM.args.length; j++ )
				parseArguments( xmlOut, xmlMessage, oscM.args );
		}

		xmlOut.appendChild(packetOut);
	
		if( mySocket && this.connected )
			mySocket.send(xmlOut);
	}
}




