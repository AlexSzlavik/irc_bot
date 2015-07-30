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

			if( priv.Message_destination == c.Nickname )
			{
				Handle_pm( priv, c );
				return;
			}

			// Super aweful O(n*m) algorithm, n dictornary, m word count in string
			// Might be better of constructing a regex here
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

		void
		Add_words( string words[], IRC_Client c, string sender )
		{
			if( words.length == 0 ) Usage ( c, sender );
			dictonary ~= words;

			string response = "PROF: Added ( ";
			foreach( string word; words )
				response ~= word ~" ";
			response ~= ") to the naughty list";

			c.Send_message( response, sender );
		}

		void
		Usage( IRC_Client c, string sender )
		{
			c.Send_message( "Usage: PROF", sender ); 
		}

		void
		Handle_pm( IRC_PRIVMSG msg, IRC_Client c )
		{
			string params[] = split( msg.Message_text, " " );
			string sender = msg.Sender["nickname"];

			writeln( params );

			// Check if the msssage is for us
			if( params[0] != "PROF" )
				return;
			if( params.length < 2 )
			{
				Usage( c, sender );
				return;
			}

			switch( params[1] )
			{
				case "add": 	// add a word to the list
					Add_words( params[2..$], c, sender );
					break;

				case "help":
				default:
					Usage( c, sender );
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
