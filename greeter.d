import irc_client;
import std.stdio;
import std.conv;
import database;


class Greeter : IRC_Module
{
	public:
		void
		Handle_event( IRC_Message msg, IRC_Client client )
		{
			string user = msg.Decouple_origin()["nickname"];
			if( msg.Message_type == IRC_Message.Type.JOIN )
			{
				auto st = db.prepare( "select * from Users where name == :name;" );
				st.bind( ":name", user );
				auto res = st.execute();
				if( res.empty() )
				{
					st = db.prepare( "insert into Users(name,last_login) values(:name,datetime('now'))" );
					st.bind( ":name", user );
					st.execute();
				}
				else
				{
					st = db.prepare( "update Users set last_login=datetime('now') where name==:name");
					st.bind( ":name", user );
					st.execute();
				}
			}
			else if( msg.Message_type == IRC_Message.Type.PART ||
					msg.Message_type == IRC_Message.Type.QUIT )
			{
				client.Send_message( "See ya later " ~ user );
			}
		}

		@property IRC_Message.Type[] Handled_types()
		{
			IRC_Message.Type[] handled;
			handled ~= IRC_Message.Type.PART;
			handled ~= IRC_Message.Type.QUIT;
			handled ~= IRC_Message.Type.JOIN;
			return handled;
		}
}
