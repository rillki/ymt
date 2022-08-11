module ymtadd;

import ymtcommon;
import std.array: empty;
import std.format: format;
import std.datetime.date: Date;

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
    try {
        auto tmp = Date.fromISOExtString(date);
    } catch(Exception e) {
        writefln("#ymt add: %s", e.msg);
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
