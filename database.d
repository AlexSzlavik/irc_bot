import std.file;
import std.stdio;
public import d2sqlite3;

Database db;

void
Open_database( string database_name )
{
	try
	{
		if( exists(database_name) )
			remove( database_name );

		if( !exists(database_name) )
			Create_database( database_name );

		db = Database( database_name );
		db.execute( "PRAGMA foreign_keys=true;" );
	}
	catch( SqliteException e )
	{
		throw e;
	}
}

void
Create_database( string name )
{
	Database db = Database( name );
	db.execute( "PRAGMA foreign_keys=true;" );
	db.execute( "CREATE TABLE Users( id integer primary key autoincrement, name text, last_login text )" );
	db.execute( "CREATE TABLE Profanity_words( id integer primary key autoincrement, word text unique )" );
	db.execute( "CREATE TABLE Profanity_users( userid integer references Users(id), wordid integer references Profanity_words(id), count integer )" );
	db.close();
}
