CXX			= dmd
CXXFLAGS	= -w -g -debug -c

BINARY		= irc_bot
OBJECTS 	= irc_client.o message.o main.o 

all: $(BINARY)

clean:
	-rm $(OBJECTS) $(BINARY)

$(BINARY): $(OBJECTS)
	$(CXX) $^ -of$@

%.o: %.d
	$(CXX) $(CXXFLAGS) $?
