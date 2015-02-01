CXX			= dmd
CXXFLAGS	= -w -g -debug -c

BINARY		= irc_bot
MODULES		= ping_counter.o profanity_listener.o
OBJECTS 	= irc_client.o message.o main.o $(MODULES)

all: $(BINARY)

clean:
	-rm $(OBJECTS) $(BINARY)

$(BINARY): $(OBJECTS)
	$(CXX) $^ -of$@

%.o: %.d
	$(CXX) $(CXXFLAGS) $?
