import message;
import irc_client;

void
main( string args[] )
{
	IRC_Client client = new IRC_Client( "irc.freenode.org", 6667, "bclab_bot" );
	client.Join_channel( "#baconator", "bacon" );

	client.Process_requests();
}
