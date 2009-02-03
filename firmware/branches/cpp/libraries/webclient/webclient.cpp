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

#include "config.h"
#ifdef MAKE_CTRL_NETWORK

#include "stdlib.h"
#include "string.h"
#include <stdio.h>
#include "webclient.h"
#include "rtos_.h"
#include "lwip/api.h"

#define WEBCLIENT_INTERNAL_BUFFER_SIZE 200
char WebClient_InternalBuffer[ WEBCLIENT_INTERNAL_BUFFER_SIZE ];

/** \defgroup webclient Web Client
  A very simple web client for HTTP operations.

  The web client system allows the Make Controller to get/post data to a webserver.  This
  makes it straightforward to use the Make Controller as a source of data for your web apps.
  
  Note that these functions make liberal use of printf-style functions, which can require 
  lots of memory to be allocated to the task calling them.

  There's currently not a method provided for name resolution - you can always ping the 
  server you want to communicate with to see its IP address, and just use that.
  
  See Network_DnsGetHostByName() for a way to get the address of a particular web site.

	\ingroup Libraries
	@{
*/

WebClient::WebClient(int address, int port)
{
  this->address = address;
  this->port = port;
}

void WebClient::setAddress(int address, int port)
{
  this->address = address;
  this->port = port;
}

/**	
	Performs an HTTP GET operation to the path at the address / port specified.  
  
  Reads through the HTTP header and copies the data into the buffer you pass in.  Because
  sites can often be slow in their responses, this will wait up to 1 second (in 100 ms. intervals)
  for data to become available.

  Some websites seem to reject connections occassionally - perhaps because we don't supply as
  much info to the server as a browser might, for example.  Simpler websites should be just fine.
  
  Note that this uses lots of printf style functions and may require a fair amount of memory to be allocated
  to the task calling it.  The result is returned in the specified buffer.

  @param hostname A string specifying the name of the host to connect to.  When connecting to a server
  that does shared hosting, this will specify who to connect with.
  @param path The path on the server to connect to.
  @param buffer A pointer to the buffer read back into.  
	@param buffer_size An integer specifying the actual size of the buffer.
  @return the number of bytes read, or < 0 on error.

  \par Example
  \code
  int addr = IP_ADDRESS( 72, 249, 53, 185); // makingthings.com is 72.249.53.185
  int bufLength = 100;
  char myBuffer[bufLength];
  int getSize = WebClient_Get( addr, 80, "www.makingthings.com", "/test/path", myBuffer, bufLength );
  \endcode
  Now we should have the results of the HTTP GET from \b www.makingthings.com/test/path in \b myBuffer.
*/
int WebClient::get( char* hostname, char* path, char* buffer, int buffer_size )
{
  char* b = WebClient_InternalBuffer;
  if ( socket.connect( address, port ) )
  {
    // construct the GET request
    int send_len = snprintf( b, WEBCLIENT_INTERNAL_BUFFER_SIZE, "GET %s HTTP/1.1\r\n%s%s%s\r\n", 
                                path,
                                ( hostname != NULL ) ? "Host: " : "",
                                ( hostname != NULL ) ? hostname : "",
                                ( hostname != NULL ) ? "\r\n" : ""  );
    if ( send_len > WEBCLIENT_INTERNAL_BUFFER_SIZE )
    {
      socket.close( );
      return CONTROLLER_ERROR_INSUFFICIENT_RESOURCES;
    }
    
    // send the GET request
    if(!socket.write( b, send_len ))
    {
      socket.close( );
      return CONTROLLER_ERROR_WRITE_FAILED;
    }
    
    // read the data into the given buffer until there's none left, or the passed in buffer is full
    int total_bytes_read = readResponse(buffer, buffer_size);
    socket.close( );
    return total_bytes_read;
  }
  else
    return CONTROLLER_ERROR_BAD_ADDRESS;
}

/**	
	Performs an HTTP POST operation to the path at the address / port specified.  The actual post contents 
  are found read from a given buffer and the result is returned in the same buffer.
  @param hostname A string specifying the name of the host to connect to.  When connecting to a server
  that does shared hosting, this will specify who to connect with.
  @param path The path on the server to post to.
	@param buffer A pointer to the buffer to write from and read back into.  
	@param buffer_length An integer specifying the number of bytes to write.
	@param buffer_size An integer specifying the actual size of the buffer.
  @return status.

  \par Example
  \code
  // we'll post a test message to www.makingthings.com/post/path
  int addr = IP_ADDRESS( 72, 249, 53, 185); // makingthings.com is 72.249.53.185
  int bufLength = 100;
  char myBuffer[bufLength];
  sprintf( myBuffer, "A test message to post" );
  int result = WebClient_Post( addr, 80, "www.makingthings.com", "/post/path", 
                                    myBuffer, strlen("A test message to post"), bufLength );
  \endcode
*/
int WebClient::post( char* hostname, char* path, char* buffer, int buffer_length, int buffer_size )
{
  char* b = WebClient_InternalBuffer;
  if ( socket.connect( address, port ) )
  { 
    int send_len = snprintf( b, WEBCLIENT_INTERNAL_BUFFER_SIZE, 
                                "POST %s HTTP/1.1\r\n%s%s%sAccept: application/json\r\nContent-Length: %d\r\n\r\n", 
                                path, 
                                ( hostname != NULL ) ? "Host: " : "",
                                ( hostname != NULL ) ? hostname : "",
                                ( hostname != NULL ) ? "\r\n" : "",
                                buffer_length );
    if ( send_len > WEBCLIENT_INTERNAL_BUFFER_SIZE )
    {
      socket.close( );
      return CONTROLLER_ERROR_INSUFFICIENT_RESOURCES;
    }

    if ( socket.write( b, send_len ) == 0 ) // send the headers
    {
      socket.close( );
      return CONTROLLER_ERROR_WRITE_FAILED;
    }

    socket.write( buffer, buffer_length ); // send the body
    
    // read back the response
    int buffer_read = readResponse(buffer, buffer_size);
    socket.close( );
    return buffer_read;
  }
  else
    return CONTROLLER_ERROR_BAD_ADDRESS;
}

int WebClient::readResponse( char* buf, int size )
{
  // read back the response
  char* b = WebClient_InternalBuffer;
  int content_length = 0;
  int b_len;
  bool chunked = true;
  
  // read through the headers - figure out the content length scheme
  while ( ( b_len = socket.readLine( b, WEBCLIENT_INTERNAL_BUFFER_SIZE ) ) )
  {
    if ( !strncmp( b, "Content-Length", 14 ) ) // check for content length
      content_length = atoi( &b[ 16 ] );
    else if( !strncmp( b, "Transfer-Encoding: chunked", 26 ) ) // check to see if we're chunked
      chunked = true;
    else if ( strncmp( b, "\r\n", 2 ) == 0 )
      break;
  }

  if(b_len <= 0)
    return 0;
  
  int content_read = 0;
  
  // read the actual response data into the caller's buffer, if there's any to grab
  if(chunked ) // first see if it's chunked
  {
    int len = 1;
    while(len != 0)
    {
      b_len = socket.readLine( b, WEBCLIENT_INTERNAL_BUFFER_SIZE );
      if(sscanf(b, "%x", &len) != 1) // the first part of the chunk should indicate the chunk's length (hex)
        break;
      if(len == 0) // an empty chunk indicates the end of the transfer
        break;
      content_read += socket.read(buf, len);
      socket.readLine(b, WEBCLIENT_INTERNAL_BUFFER_SIZE); // slurp out the remaining newlines
    }
  }
  else if ( content_length > 0 ) // otherwise see if we got a content length
  {
    while ( ( b_len = socket.read( buf, size - content_read ) ) )
    {
      content_read += b_len;
      buf += b_len;
      if ( content_read >= content_length )
        break;
    }
  }
  else // lastly, just try to read until we get cut off
  {
    while( content_read < size )
    {
      b_len = socket.read( buf, size - content_read );
      if(b_len <= 0)
        break;
      content_read += b_len;
      buf += b_len;
    }
  }
  return content_read;
}

/** @}
*/

#endif // MAKE_CTRL_NETWORK



