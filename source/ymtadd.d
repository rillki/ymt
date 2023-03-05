module ymtadd;

import ymtcommon;
import std.stdio: writef, writefln, readln;
import std.string: strip;
import std.array: empty;
import std.format: format;
import std.datetime.date: Date;

void dbAdd(in string type, in string name, in float receipt, in string date) {
    // check if basedir and db exist
    if(!ymtIsInit("add")) {
        return;
    }

    // check if type is null
    auto result = dbExecute(checkTypeExistsQuery.format(type));
    if(type is null) {
        writefln("#ymt add: <type> must be specified!");
        return;
    }

    // check if type specified exists in DB
    if(!result.front["Result"].as!bool) {
        writefln("#ymt add: <%s> does not exist in the Database!");
        writef("#ymt add: Add <%s> to the Database? (y/N): ", type);
        
        // get input
        char answer = readln.strip;
        if(answer != 'y' || answer != 'Y') {
            writefln("#ymt add: cancelled.");
            return;
        }

        // add a new type to the database
        dbAddType(type);
    }
}

private:

// TODO: modify the query
void dbAddType(in string type) {
    // check if basedir and db exist
    if(!ymtIsInit("add")) {
        return;
    }

    // open db
    auto db = Database(basedir.buildPath(dbname));

    // prepare a query
    immutable query = `
        INSERT INTO Type (Type) VALUES ("%s")
    `;

    // add a new entry to database
    try {
        db.run(query.format(type));
    } catch(Exception e) {
        writefln("#ymt add: %s", e.msg);
    }
}

/+

void dbAddName(in string name, in uint typeID) {
    // check if basedir and db exist
    if(!ymtIsInit("add")) {
        return;
    }

    // open db
    auto db = Database(basedir.buildPath(dbname));

    // prepare a query
    immutable query = `
        INSERT INTO Name (Name, TypeID) VALUES ("%s", %s)
    `;

    // add a new entry to database
    try {
        db.run(query.format(name, typeID));
    } catch(Exception e) {
        writefln("#ymt add: %s", e.msg);
    }
}

void dbAddReceipt(in float receipt, in uint nameID, in uint typeID, in string date) {
    // check if basedir and db exist
    if(!ymtIsInit("add")) {
        return;
    }

    // check if receipt is not 0
    if(receipt == 0) {
        writefln("#ymt add: receipt value cannot be 0!");
        return;
    }

    // check if date specified is in correct format
    if(!date.empty) {
        try {
            auto tmp = Date.fromISOExtString(date);
        } catch(Exception e) {
            writefln("#ymt add: %s", e.msg);
            return;
        }
    }

    // open db
    auto db = Database(basedir.buildPath(dbname));

    // prepare a query
    immutable query = `
        INSERT INTO Receipt (Date, NameID, TypeID, Receipt) 
        VALUES (%s, %s, %s, %s)
    `;

    // add a new entry to database
    try {
        db.run(query.format((date.empty ? "CURRENT_DATE" : "\"" ~ date ~ "\""), nameID, typeID, receipt));
    } catch(Exception e) {
        writefln("#ymt add: %s", e.msg);
    }
}

+/


