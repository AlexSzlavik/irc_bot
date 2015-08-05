import irc_client;
import std.stdio;
import std.conv;


class Greeter : IRC_Module
{
	public:
		void
		Handle_event( IRC_Message msg, IRC_Client client )
		{
			IRC_QUIT quit_msg = cast(IRC_QUIT)msg;
			client.Send_message( "See ya later " ~ quit_msg.Sender );
		}

		@property IRC_Message.Type[] Handled_types()
		{
			IRC_Message.Type[] handled;
			handled ~= IRC_Message.Type.QUIT;
			return handled;
		}

	private:
		uint counter;
}
