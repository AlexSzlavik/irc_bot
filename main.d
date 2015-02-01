import message;
import irc_client;

// Modules
import ping_counter;

void
main( string args[] )
{
	IRC_Client client = new IRC_Client( "irc.freenode.org", 6667, "bclab_bot" );
	client.Join_channel( "#baconator", "bacon" );

	// Add modules
	Ping_handler pinger = new Ping_handler();

	client.Register_event_handler( pinger );

	client.Process_requests();
}
