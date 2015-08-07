import irc_client;
import std.exception, std.stdio, std.regex, std.file, std.conv, std.string;
import database;

class Profanity_listener : IRC_Module
{
	public:
		this( string new_config_file = "" )
		{
			config_file = (new_config_file.length)?new_config_file:config_file;

			try
			{

				//Seed the databse with the config words
				if( db.execute( "select * from Profanity_words" ).empty() )
				{
					char[] data = to!(char[])(read( config_file ) );
					dictonary = split!string(to!string(data));

					string update = "insert into Profanity_words(word) values ";
					foreach( string e; dictonary )
						update ~= "('" ~ e ~ "'),";
					update = chomp( update, "," );
					db.execute( update );
				}
				else
				{
					//Read out the dictonary from the DB
					auto res = db.execute( "select word from Profanity_words" );
				}
			}
			catch( FileException e )
			{
				stderr.writeln( e.msg );
				throw e;
			}

			catch( SqliteException e )
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
		Add_words( string[] words, IRC_Client c, string sender )
		{
			string response = "PROF: Added ( ";
			if( words.length == 0 ) Usage ( c, sender );
			dictonary ~= words;

			//Update the database
			auto update = db.prepare("insert into Profanity_words(word) values(?) ");
			foreach( string word; words )
			{
				try
				{
					update.inject(word);
					response ~= word ~ " ";
				}
				catch( SqliteException e )
				{
					update.clearBindings();
					c.Send_message( "Can't insert \"" ~ word ~ "\" into the DB. Probably already exists", sender );
				}
			}

			response ~= " ) to the naughty list";
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
			string[] params = split( msg.Message_text, " " );
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
		string 		config_file = "profanity.cfg";
		string[] 	dictonary;
}
