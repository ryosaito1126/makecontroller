/*********************************************************************************

 Copyright 2006-2009 MakingThings

 Licensed under the Apache License, 
 Version 2.0 (the "License"); you may not use this file except in compliance 
 with the License. You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0 
 
 Unless required by applicable law or agreed to in writing, software distributed
 under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 CONDITIONS OF ANY KIND, either express or implied. See the License for
 the specific language governing permissions and limitations under the License.

*********************************************************************************/

#include "tcpserver.h"

#ifdef MAKE_CTRL_NETWORK
#include "lwip/sockets.h"

/**
  Create a new TcpServer.
  
  \b Example
  \code
  TcpServer server;
  // or allocate one...
  TcpServer* server = new TcpServer();
  \endcode
*/
TcpServer tcpserverNew(int port)
{
  struct sockaddr_in sa;
  sa.sin_family = AF_INET;
  sa.sin_addr.s_addr = INADDR_ANY;
  sa.sin_port = port;

  TcpServer s = lwip_socket(0, SOCK_STREAM, IPPROTO_TCP);
  if( lwip_bind(s, (const struct sockaddr *)&sa, sizeof(sa)) != 0) {
    lwip_close(s);
    return -1;
  }
  return lwip_listen(s, 5);
}

/**
  Close this socket.
  
  @return True on success, false on failure.
  
  \b Example
  \code
  TcpServer server;
  server.listen(80);
  TcpSocket* newConnection = server.accept();
  server.close();
  \endcode
*/
bool tcpserverClose(TcpServer s)
{
  return lwip_close(s) == 0;
}

/**
  Accept an incoming connection.
  This method will block until a new connection is made, and return the new TcpSocket
  that represents the remote connection.
  
  Note - you'll need to delete the TcpSocket returned once you're done with it.
  @return The newly connected socket, or NULL if it failed.
  
  \b Example
  \code
  TcpServer* s = new TcpServer();
  s->listen(8080);
  while(1)
  {
    TcpSocket* client = s->accept();
    // ...do something with the client connection here...
    delete client; // then clean it up
  }
  \endcode
*/
TcpSocket tcpserverAccept(TcpServer s)
{
  return lwip_accept(s, 0, 0);
}

#endif // MAKE_CTRL_NETWORK

