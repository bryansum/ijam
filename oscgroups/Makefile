CLIENT=OscGroupClient
SERVER=OscGroupServer


# should be either OSC_HOST_BIG_ENDIAN or OSC_HOST_LITTLE_ENDIAN
# Apple: OSC_HOST_BIG_ENDIAN
# Win32: OSC_HOST_LITTLE_ENDIAN
# i386 LinuX: OSC_HOST_LITTLE_ENDIAN

ENDIANESS=OSC_HOST_LITTLE_ENDIAN


SERVERSOURCES = \
	../oscpack/osc/OscTypes.cpp  \
	../oscpack/osc/OscOutboundPacketStream.cpp \
	../oscpack/osc/OscReceivedElements.cpp \
	../oscpack/ip/posix/NetworkingUtils.cpp  \
	../oscpack/ip/IpEndpointName.cpp \
	../oscpack/ip/posix/UdpSocket.cpp \
	./GroupServer.cpp \
	./OscGroupServer.cpp
SERVEROBJECTS = $(SERVERSOURCES:.cpp=.o)

CLIENTSOURCES = \
	../oscpack/osc/OscTypes.cpp \
	../oscpack/osc/OscOutboundPacketStream.cpp \
	../oscpack/osc/OscReceivedElements.cpp \
	../oscpack/ip/posix/NetworkingUtils.cpp \
	../oscpack/ip/IpEndpointName.cpp \
	../oscpack/ip/posix/UdpSocket.cpp \
	./OscGroupClient.cpp \
	./md5.cpp 
CLIENTOBJECTS = $(CLIENTSOURCES:.cpp=.o)

SCRIPTS = \
    ./OscGroupServerStartStop.sh \
    ./run_client.sh \
    ./run_server.sh


INCLUDES = -I../oscpack
COPTS  = -Wall -O3
CDEBUG = -Wall -g 
CXXFLAGS = $(COPTS) $(INCLUDES) -D$(ENDIANESS)
LIBS = -lpthread

all:	server client

server : $(SERVEROBJECTS)
	@if [ ! -d bin ] ; then mkdir bin ; fi
	$(CXX) -o bin/$(SERVER) $+ $(LIBS) 

client : $(CLIENTOBJECTS)
	@if [ ! -d bin ] ; then mkdir bin ; fi
	$(CXX) -o bin/$(CLIENT) $+ $(LIBS) 


# set executable bit on scripts
scripts:
	chmod +x $(SCRIPTS) 

# install the daemon on linux. make sure you
# edit the script with the right path information first
install_daemon : OscGroupServerStartStop.sh
	ln -s ./OscGroupServerStartStop.sh /etc/init.d/OscGroupServer
	update-rc.d OscGroupServer defaults

clean:
	rm -rf bin $(SERVEROBJECTS) $(CLIENTOBJECTS)


