module ymtquery;

import ymtcommon;

void dbQuery(in string query) {
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
		writefln("#ymt query: executing \"%s\"", query);

        auto results = db.execute(query);
		foreach(row; results) {
			writefln("%s", row);
		}
    } catch(Exception e) {
        writefln("#ymt query: %s", e.msg);
    }
	writefln("ymt query: done.");
}