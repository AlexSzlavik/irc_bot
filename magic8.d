import irc_client;
import std.stdio;
import std.conv;
import std.string;
import std.random;

string Answers[] = [ 
	"I don't know",
	"Only time will tell",
	"Probably",
	"No way!",
	"Absolutly",
	"Who do you think I am?"
	];

class Magic8 : IRC_Module
{
	public:
		void
		Handle_event( IRC_Message msg, IRC_Client client )
		{
			IRC_PRIVMSG priv = cast(IRC_PRIVMSG)msg;

			// See if this is a question for us
			if( startsWith( priv.Message_text, client.Nickname ) &&
					endsWith( priv.Message_text, "?" ) )
			{
				auto i = randomSample( Answers, 1 );
				client.Send_message( priv.Sender["nickname"]~": "~ Answers[i.index] );
			}
		}

		@property IRC_Message.Type[] Handled_types()
		{
			IRC_Message.Type handled[];
			handled ~= IRC_Message.Type.PRIVMSG;
			return handled;
		}
}
