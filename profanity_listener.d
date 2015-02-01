import irc_client;
import std.exception;
import std.regex;

class Profanity_listener : IRC_Module
{
	public:
		void Handle_event( IRC_Message msg, IRC_Client c )
		{
			IRC_PRIVMSG priv = cast(IRC_PRIVMSG)msg;
			enforce( msg.Message_type == IRC_Message.Type.PRIVMSG, "Profanity listener: Invalid message type" );
			auto reg = ctRegex!("shit|fuck|god damn|ass|asshole|dick");
			auto found = matchAll( priv.Message_text, reg );
			if( found )
			{
				c.Send_message( priv.Sender["nickname"] ~ ": Bad Boy!" );
			}
		}

		@property IRC_Message.Type[] Handled_types()
		{
			IRC_Message.Type[] types;
			types ~= IRC_Message.Type.PRIVMSG;
			return types;
		}
}
