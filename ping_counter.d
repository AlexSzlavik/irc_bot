import irc_client;
import std.stdio;
import std.conv;


class Ping_handler : IRC_Module
{
	public:
		void
		Handle_event( IRC_Message msg, IRC_Client client )
		{
			++counter;
			//client.Send_message( "Pings: " ~ to!string(counter) );
			writeln( "Pinging" );
		}

		@property IRC_Message.Type[] Handled_types()
		{
			IRC_Message.Type[] handled;
			handled ~= IRC_Message.Type.PING;
			return handled;
		}

	private:
		uint counter;
}
