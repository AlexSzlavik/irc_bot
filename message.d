module message;

import std.stdio;
import std.regex;
import std.container;
import std.conv;
import std.array;

class Message_buffer
{
	public:
		string
		Get_message()
		{
			if( messages.empty() )
				return "";

			string ret = messages.front();
			messages.popFront();
			return ret;
		}

		void
		Add_data( string data )
		{
			// Add new data to the left overs from last time
			string_buffer ~= data;

			// Search for terminator in the string
			string [] data1 = split( string_buffer, regex( "\r\n" ) );
			foreach( int i, string a; data1 )
			{
				if( i == data1.length-1 )
					string_buffer = a;
				else
					messages ~= a;
			}
		}

		bool
		Has_message()
		{
			return !messages.empty();
		}

	private:
		string 		string_buffer;
		string[] 	messages;
}

class IRC_Message
{
	public:
		enum Type
		{
			INVALID,
			JOIN,
			PING,
			PRIVMSG,
			PART,
			QUIT
		}

		Type Message_type;
		string Message_paramaters;
		string Message_sender;
		string Original_string;

		override string 
		toString()
		{
			if( Original_string) 
				return Original_string;
			return Message_sender ~ " " ~ Message_paramaters;
		}

		this()
		{
			Message_type = Type.INVALID;
		}
		
		this( Type type )
		{
			Message_type = type;
		}

		this( Type type, string params )
		{
			Message_type = type;
			Message_paramaters = params;
		}

		this( string sender, Type type )
		{
			Message_type = type;
			Message_sender = sender;
		}

		this( string sender, Type type, string params )
		{
			Message_type = type;
			Message_paramaters = params;
			Message_sender = sender;
		}

		string [string]
		Decouple_origin()
		{
			string[string] ret;
			//:nickname[!username[@hostname]]
			auto name = matchFirst( Message_sender, ":([^!@ ]+)(!([^!@ ]+)(@([^!@ ]+)){0,1}){0,1}" );

			ret["nickname"] = name[1];
			ret["username"] = name[3];
			ret["hostname"] = name[5];

			return ret;
		}

		string [string]
		Decouple_origin( string sender )
		{
			string[string] ret;
			//:nickname[!username[@hostname]]
			auto name = matchFirst( sender, ":([^!@ ]+)(!([^!@ ]+)(@([^!@ ]+)){0,1}){0,1}" );

			ret["nickname"] = name[1];
			ret["username"] = name[3];
			ret["hostname"] = name[5];

			return ret;
		}

		void
		Append_original( string msg )
		{
			Original_string = msg;
		}

		static IRC_Message
		Parse_message( string msg )
		{
			string prefix;
			string message;
			string paramaters;
			auto tokens = matchFirst( msg, regex("^(:[^ ]+) ([^ ]+) (.*)$") );
			
			if( !tokens )
				tokens = matchFirst( msg, regex("^([^ ]+) (.*)$") );

			if( tokens.length == 4 )
			{
				prefix = tokens[1];
				message = tokens[2];
				paramaters = tokens[3];
			}
			else if( tokens.length == 3 )
			{
				message = tokens[1];
				paramaters = tokens[2];
			}
			else
				assert( false );

			switch( message )
			{
				case "JOIN":
					return new IRC_JOIN( prefix, paramaters );
				case "PRIVMSG":
					return new IRC_PRIVMSG( prefix, paramaters );
				case "PING":
					return new IRC_PING( paramaters );
				case "PART":
					return new IRC_PART( prefix );
				case "QUIT":
					return new IRC_QUIT( prefix );
				default:
					return new IRC_Message();
			}
			
		}
}

class IRC_PRIVMSG : IRC_Message
{
	public:
		this( string sender, string params )
		{
			super( sender, IRC_Message.Type.PRIVMSG, params );

			auto param_break = matchFirst( params, "([^ ]+) :(.*)" );
			Sender = Decouple_origin( sender );

			Message_text = param_break[2];
			Message_destination = param_break[1];
		}

		string [string] Sender;
		string Message_text;
		string Message_destination;
}

class IRC_PING : IRC_Message
{
	public
		this( string sender )
		{
			super( sender, IRC_Message.Type.PING );
			auto name = matchFirst( sender, ":([^!@ ]*)" );
			Ping_sender = name[1];
		}
	
		string Ping_sender;
}

class IRC_PART : IRC_Message
{
	public:
		this( string sender )
		{
			super( sender, IRC_Message.Type.PART );
			string[string] dec = Decouple_origin( sender );
			Sender = dec["nickname"];
		}

		string Sender;
}

class IRC_QUIT : IRC_Message
{
	public:
		this( string sender )
		{
			super( sender, IRC_Message.Type.QUIT );
			string[string] dec = Decouple_origin( sender );
			Sender = dec["nickname"];
		}

		string Sender;
}

class IRC_JOIN : IRC_Message
{
	public:
		this( string joiner, string channel )
		{
			super( joiner, IRC_Message.Type.JOIN, channel );
			Sender = Decouple_origin()["nickname"];
		}

		string Sender;
}
