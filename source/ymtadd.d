module ymtadd;

import ymtcommon;
import std.format: format;

void dbAddType(in string type) {
    // check if basedir exists
    if(!basedir.exists) {
        writefln("#ymt add: error! Initialize ymt first!");
        return;
    }

    // check if db exists
    if(!basedir.buildPath(dbname).exists) {
        writefln("#ymt add: error! %s does not exist, you need to initialize one!", dbname);
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
    // check if basedir exists
    if(!basedir.exists) {
        writefln("#ymt add: error! Initialize ymt first!");
        return;
    }

    // check if db exists
    if(!basedir.buildPath(dbname).exists) {
        writefln("#ymt add: error! %s does not exist, you need to initialize one!", dbname);
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

void dbAddReceipt(in float receipt, in uint nameID, in uint typeID) {
    // check if basedir exists
    if(!basedir.exists) {
        writefln("#ymt add: error! Initialize ymt first!");
        return;
    }

    // check if db exists
    if(!basedir.buildPath(dbname).exists) {
        writefln("#ymt add: error! %s does not exist, you need to initialize one!", dbname);
        return;
    }

    // open db
    auto db = Database(basedir.buildPath(dbname));

    // prepare a query
    immutable query = `
        INSERT INTO Receipt (Date, NameID, TypeID, Receipt) VALUES (CURRENT_DATE, %s, %s, %s)
    `;

    // add a new entry to database
    try {
        db.run(query.format(nameID, typeID, receipt));
    } catch(Exception e) {
        writefln("#ymt add: %s", e.msg);
    }
}
