CXX			= dmd
CXXFLAGS	= -w -g -debug -c

BINARY		= irc_bot
MODULES		= ping_counter.o profanity_listener.o greeter.o magic8.o
SQLITE		= d2sqlite3.o sqlite3.o

OBJECTS 	= irc_client.o message.o database.o main.o $(MODULES) $(SQLITE)
LIBS		= -L-lsqlite3

all: $(BINARY)

clean:
	-rm $(OBJECTS) $(BINARY)

$(BINARY): $(OBJECTS)
	$(CXX) $^ $(LIBS) -of$@

%.o: %.d
	$(CXX) $(CXXFLAGS) $?
