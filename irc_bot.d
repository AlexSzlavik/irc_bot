import std.stdio, std.socket;
import std.algorithm;
import std.regex;
import std.container;
import std.conv;
import std.array;

import message;

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

		void
		Join_channel( string channel, string pass = "" )
		{
			bool joined = false;
			IRC_Channel = channel;
			IRC_Socket.send( "NICK "~IRC_User_name~"\r\n" );
			IRC_Socket.send( "USER "~IRC_User_name~" 8 * :Bot\r\n" );
			IRC_Socket.send( "JOIN "~IRC_Channel~" "~pass~"\r\n" );

			// Wait for JOIN ack from the server
			while( !joined )
			{
				string s;
				while( (s = Get_next_message()) != ""  )
				{
					writeln( s );
					IRC_Message msg = IRC_Message.Parse_message( s );
					if( msg.Message_type == IRC_Message.Type.JOIN )
					{
						joined = true;
						break;
					}
				}
				Get_data();
			}
			writeln( "JOINED - Handoff" );
		}

		void
		Send_message( string message, string receipient = IRC_Channel )
		{
			string data = "PRIVMSG "~receipient~" :"~message~"\r\n";
			IRC_Socket.send( data );
		}

		void
		Get_data()
		{
			char data[512];
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
						case IRC_Message.Type.PRIVMSG:
							IRC_PRIVMSG priv_msg = cast(IRC_PRIVMSG)msg;
							writeln( priv_msg.Sender["nickname"]~": "~priv_msg.Message_text);
							break;

						case IRC_Message.Type.PING:
							IRC_PING ping_msg = cast(IRC_PING)msg;
							IRC_Socket.send( "PONG "~ping_msg.Ping_sender~"\r\n" );
							writeln( msg );
							break;

						default:
							writeln( s );
							//assert( false );
					}
				}
				Get_data();
			}
		}

	private:
		TcpSocket 		IRC_Socket;
		string			IRC_Channel;
		string			IRC_User_name;
		Message_buffer	IRC_Buffer = new Message_buffer();
}

void
main( string args[] )
{
	IRC_Client client = new IRC_Client( "irc.freenode.org", 6667, "bclab_bot" );
	client.Join_channel( "#baconator", "bacon" );

	client.Process_requests();
}
