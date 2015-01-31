CXX			= dmd
CXXFLAGS	= -w -g -debug -c

all: irc_bot

irc_bot: irc_bot.o message.o
	$(CXX) $^ -of$@

irc_bot.o: irc_bot.d 
	$(CXX) $(CXXFLAGS) $?

message.o: message.d
	$(CXX) $(CXXFLAGS) $?
