module ymtquery;

import std.stdio: writefln;
import std.array: empty;

import ymtcommon;

void dbQuery(in string query) {
    // check if basedir and db exist
    if(!ymtIsInit("query")) {
        return;
    }

    // check if got valid query
    if(query.empty) {
        writefln("#ymt query: no query provided!");
        return;
    }
    
    // execute query
    try {
        writefln("#ymt query: executing \"%s\"", query);

        auto results = dbExecute(query);
        foreach(row; results) {
            writefln("%s", row);
        }
        
        writefln("ymt query: done.");
    } catch(Exception e) {
        writefln("#ymt query: %s", e.msg);
    }
}


