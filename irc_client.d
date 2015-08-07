import std.stdio, std.socket;
import std.algorithm;
import std.regex;
import std.container;
import std.conv;
import std.array;
import std.exception;
import std.string;

public import message;

interface IRC_Module
{
	public:
		void Handle_event( IRC_Message msg, IRC_Client c );
		@property IRC_Message.Type[] Handled_types();
}

class IRC_Client
{
	public:
		this( TcpSocket socket, string name )
		{
			IRC_Socket = socket;
			IRC_User_name = name;
		}

		this( string hostname, ushort port, string name )
		{
			IRC_Socket = new TcpSocket( new InternetAddress( hostname, port ) );
			this( IRC_Socket, name );
		}

		@property string Nickname()
		{
			return IRC_User_name;
		}

		@property string Channel()
		{
			return IRC_Channel;
		}
		

		void
		Join_channel( string channel, string pass = "" )
		{
			enforce( channel != "", "No channel name given" );

			bool joined = false;
			IRC_Channel = channel;
			IRC_Socket.send( "NICK "~IRC_User_name~"\r\n" );
			IRC_Socket.send( "USER "~IRC_User_name~" 8 * :Bot\r\n" );

			// Wait for JOIN ack from the server
			while( !joined )
			{
				string s;
				IRC_Socket.send( "JOIN "~IRC_Channel~" "~pass~"\r\n" );
				while( (s = Get_next_message()) != ""  )
				{
					writeln( s );
					IRC_Message msg = IRC_Message.Parse_message( s );
					if( msg.Message_type == IRC_Message.Type.JOIN )
					{
						if( msg.Message_paramaters.indexOf( IRC_Channel ) != -1 )
						{
							writeln("Found");
							joined = true;
							break;
						}
					}
					if( msg.Message_type == IRC_Message.Type.PING )
					{
						IRC_PING ping_msg = cast(IRC_PING)msg;
						IRC_Socket.send( "PONG "~ping_msg.Ping_sender~"\r\n" );
						break;
					}
				}
				Get_data();
			}
			writeln( "JOINED - Handoff" );
		}

		void
		Send_message( string message, string receipient = "" )
		{
			if( receipient == "" ) receipient = IRC_Channel;
			string data = "PRIVMSG "~receipient~" :"~message~"\r\n";
			IRC_Socket.send( data );
		}

		void
		Get_data()
		{
			char[512] data;
			auto amount = IRC_Socket.receive( data );
			
			string r = to!string(data[0..amount]);
			if( amount > 0 )
				IRC_Buffer.Add_data( r );
		}

		string
		Get_next_message()
		{
			return IRC_Buffer.Get_message();
		}

		void
		Register_event_handler( IRC_Module mod )
		{
			foreach( IRC_Message.Type t; mod.Handled_types )
				IRC_Event_listeners[ t ] ~= &mod.Handle_event;
		}

		void
		Process_requests()
		{
			while(true)
			{
				string s;
				while( (s = Get_next_message()) != ""  )
				{
					IRC_Message msg = IRC_Message.Parse_message( s );
					msg.Append_original( s );
					
					switch( msg.Message_type )
					{
						case IRC_Message.Type.PING:
							IRC_PING ping_msg = cast(IRC_PING)msg;
							IRC_Socket.send( "PONG "~ping_msg.Ping_sender~"\r\n" );
							writeln( msg );
							break;

						default:
							writeln( s );
					}
					
					if( msg.Message_type in IRC_Event_listeners )
						foreach( CC e; IRC_Event_listeners[msg.Message_type] )
							e( msg, this );
				}
				Get_data();
			}
		}

		alias CC = void delegate( IRC_Message msg, IRC_Client c );

	private:
		TcpSocket 					IRC_Socket;
		string						IRC_Channel;
		string						IRC_User_name;
		Message_buffer				IRC_Buffer = new Message_buffer();
		CC[][ IRC_Message.Type ]	IRC_Event_listeners;
}
