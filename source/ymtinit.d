module ymtinit;

import std.string: format;
import std.file: exists, mkdir, remove, rmdirRecurse;
import std.path: buildPath;
import std.stdio: File, writefln;

import ymtcommon;

/// Creates a .ymt folder, db and a config file
void dbInit(const string dbname) {
    if(dbname is null) {
        writefln("#ymt init: dbname not provided! See \'ymt -h\' for more info!", dbname);
        return;
    }

    // create .ymt folder exists along with a config file
    if(!basedir.exists) {
        basedir.mkdir();
    }

    // check if db exists
    if(basedir.buildPath(dbname).exists) {
        writefln("#ymt init: %s already exists!", dbname);
        return;
    }

    // create a db file
    auto db = Database(basedir.buildPath(dbname));

    // create Type table
    db.run(`
        CREATE TABLE "Type" (
            "Type" 	TEXT NOT NULL UNIQUE,
            "ID" 	INTEGER NOT NULL UNIQUE, PRIMARY KEY("ID" AUTOINCREMENT)
        );
    `);

    // create Name table
    db.run(`
        CREATE TABLE "Name" (
            "Name"	 TEXT NOT NULL UNIQUE,
            "ID"	 INTEGER NOT NULL UNIQUE, 
            "TypeID" INTEGER NOT NULL, PRIMARY KEY("ID" AUTOINCREMENT)
        );
    `);

    // create RegionPricing table
    db.run(`
        CREATE TABLE "Receipt" (
            "Date"		Date NOT NULL,
            "TypeID"	INTEGER NOT NULL,
            "NameID"	INTEGER,
            "Receipt"	REAL NOT NULL
        );
    `);

    // save config file to tell which db is used by default
    auto file = File(basedir.buildPath(configFile), "w");
    file.write(dbname);
    file.close();

    // verbose output
    writefln("#ymt init: created ymt/%s!", dbname);
}

/// Removes db
void dbRemove(const string dbname) {
    if(dbname is null) {
        writefln("#ymt remove: dbname not provided! See \'ymt -h\' for more info!", dbname);
        return;
    }

    // remove db
    basedir.buildPath(dbname).remove;

    // modify the config file
    auto file = File(basedir.buildPath(configFile), "w");
    file.write("none");
    file.close();

    // verbose output
    writefln("#ymt remove: removed %s!", basedir.buildPath(dbname));
}

/// Switch from one db to another (modifies the config file)
void dbSwitch(const string dbname) {
    if(dbname is null) {
        writefln("#ymt switch: dbname not provided! See \'ymt -h\' for more info!", dbname);
        return;
    }

    // check if db exists
    if(!basedir.buildPath(dbname).exists) {
        writefln("#ymt switch: %s does not exist!", dbname);
        return;
    }

    // switch db
    auto file = File(basedir.buildPath(configFile), "w");
    file.write(dbname);
    file.close();

    // verbose output
    writefln("#ymt switch: switched to ymt/%s!", dbname);
}

/// Delete the entire '.ymt' directory with all db's and configs
void dbClean() {
    if(basedir.exists) {
        basedir.rmdirRecurse();
    } else {
        writefln("#ymt clean: canceled! %s was not found!", basedir);
        return;
    }

    // verbose output
    writefln("#ymt clean: %s was removed!", basedir);
}