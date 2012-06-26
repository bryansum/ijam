del bin\OscGroupClient.exe
del bin\OscGroupServer.exe
mkdir bin

g++ OscGroupClient.cpp md5.cpp ..\oscpack\osc\OscOutboundPacketStream.cpp ..\oscpack\osc\OscTypes.cpp ..\oscpack\osc\OscReceivedElements.cpp ..\oscpack\ip\win32\NetworkingUtils.cpp ..\oscpack\ip\win32\UdpSocket.cpp ..\oscpack\ip\IpEndpointName.cpp -Wall -I..\oscpack -lws2_32 -lwinmm -o bin\OscGroupClient.exe

g++ OscGroupServer.cpp GroupServer.cpp ..\oscpack\osc\OscOutboundPacketStream.cpp ..\oscpack\osc\OscTypes.cpp ..\oscpack\osc\OscReceivedElements.cpp ..\oscpack\ip\win32\NetworkingUtils.cpp ..\oscpack\ip\win32\UdpSocket.cpp ..\oscpack\ip\IpEndpointName.cpp -Wall -I..\oscpack\ -lws2_32 -lwinmm -o bin\OscGroupServer.exe




