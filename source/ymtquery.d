module ymtquery;

import std.file: readText, exists;
import std.path: buildPath;
import std.stdio: writefln;

import ymtcommon;

void dbQuery(const string query) {
	// check if got valid query
	if(query is null) {
        writefln("#ymt query: no query provided!");
        return;
	}

	// check if basedir exists
    if(!basedir.exists) {
        writefln("#ymt query: error! Initialize ymt first!");
        return;
    }

    // read config file to get db name
    immutable dbname = basedir.buildPath(configFile).readText;

    // check if db exists
    if(!basedir.buildPath(dbname).exists) {
        writefln("#ymt: error! %s does not exist, you need to initialize one!", dbname);
        return;
    }

    // open db
    auto db = Database(basedir.buildPath(dbname));
	
	// execute query
	writefln("");
    try {
		writefln("#ymt query: executed \"%s\"", query);

        auto results = db.execute(query);
		foreach(row; results) {
			writefln("%s", row);
		}
    } catch(Exception e) {
        writefln("#ymt query: %s", e.msg);
    }
	writefln("");
}