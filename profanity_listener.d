import irc_client;
import std.exception, std.stdio, std.regex, std.file, std.conv, std.string;

class Profanity_listener : IRC_Module
{
	public:
		this( string new_config_file = "" )
		{
			config_file = (new_config_file.length)?new_config_file:config_file;

			try
			{
				char[] data = to!(char[])(read( config_file ) );
				dictonary = split!string(to!string(data));
			}
			catch( FileException e )
			{
				stderr.writeln( e.msg );
				throw e;
			}
		}

		void Handle_event( IRC_Message msg, IRC_Client c )
		{
			IRC_PRIVMSG priv = cast(IRC_PRIVMSG)msg;
			enforce( msg.Message_type == IRC_Message.Type.PRIVMSG, "Profanity listener: Invalid message type" );

			// Super aweful O(n*m) algorithm, n dictornary, m word count in string
			foreach( string word; split( priv.Message_text, " " ) )
			{
				foreach( string dic_word; dictonary )
				{
					if( dic_word.toUpper() == word.toUpper() )
					{
						c.Send_message( priv.Sender["nickname"] ~ ": Bad Boy!" );
						c.Send_message( priv.Sender["nickname"] ~ ": Bad Boy!", priv.Sender["nickname"] );
					}
				}
			}
		}

		@property IRC_Message.Type[] Handled_types()
		{
			IRC_Message.Type[] types;
			types ~= IRC_Message.Type.PRIVMSG;
			return types;
		}

	private:
		string config_file = "profanity.cfg";
		string dictonary[];
}
