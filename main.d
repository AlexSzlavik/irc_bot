import std.stdio;
import std.getopt;
import std.file;
import std.exception;
import std.conv;
import std.string;
import std.regex;
import core.stdc.stdlib;

import message;
import irc_client;

// Modules
import ping_counter;
import profanity_listener;

struct Options
{
	string 	IRC_Hostname;
	ushort	IRC_Port 				= 6667;
	string 	IRC_Botname				= "bclab_bot";
	string	IRC_Channel;
	string	IRC_Channel_password;
}

void
Usage( string name )
{
	stderr.writeln( "Usage: " ~ name ~ " [-c <config-file>]" );
	exit(1);
}

void
Configure( string args [], Options* options )
{
	string config_file = "config.cfg";
	string lines[];

	getopt( args,
			"c", &config_file );

	// Open the config file and parse it
	try
	{
		char[] data = to!(char[])(read( config_file ));
		lines = split!string(to!string(data));
	}
	catch( FileException e )
	{
		stderr.writeln( e.msg );
		exit(1);
	}

	// Extract options
	foreach( string s; lines )
	{
		auto reg = ctRegex!("=");
		string values[] = split( s, reg );
		switch( values[0] )
		{
			case "hostname":
				options.IRC_Hostname = values[1].strip();
				break;
			case "port":
				options.IRC_Port = to!ushort(values[1].strip());
				break;
			case "channel":
				options.IRC_Channel = values[1].strip();
				break;
			case "channel_password":
				options.IRC_Channel_password = values[1].strip();
				break;
			case "botname":
				options.IRC_Botname = values[1].strip();
				break;
			default:
		}
	}
}

void
Register_modules( ref IRC_Client client )
{
	Ping_handler pinger = new Ping_handler();
	Profanity_listener pl = new Profanity_listener();

	//client.Register_event_handler( pinger );
	client.Register_event_handler( pl );
}

void
main( string args[] )
{
	Options *opt = new Options();
	Configure( args, opt );

	IRC_Client client = new IRC_Client( opt.IRC_Hostname, opt.IRC_Port, opt.IRC_Botname );

	// Add modules
	try
	{
		Register_modules( client );
	}
	catch ( Exception e )
	{
		stderr.writeln( "Error initializing modules" );
		exit(1);
	}

	// Main loop, never exits
	client.Join_channel( opt.IRC_Channel, opt.IRC_Channel_password );
	client.Process_requests();
}
