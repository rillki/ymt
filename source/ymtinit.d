module ymtinit;

import d2sqlite3: Database;
import std.file: exists, mkdir, remove, rmdirRecurse;
import std.path: buildPath;
import std.stdio: File, writefln;

import ymtcommon;

/// Creates a .ymt folder, db and a config file
void dbInit(const string dbname) {
    if(dbname is null) {
        writefln("#ymt: dbname not provided! See \'ymt -h\' for more info!", dbname);
        return;
    }

    // create .ymt folder exists along with a config file
    version(Windows) {
        //...
    } else {
        if(!basedir.exists) {
            basedir.mkdir();
        }
    }

    // check if db exists
    if(basedir.buildPath(dbname).exists) {
        writefln("#ymt: %s already exists!", dbname);
        return;
    }

    // create a db file
    auto db = Database(basedir.buildPath(dbname));

    // create ProductType table
    db.run(`
        CREATE TABLE "ProductType" (
            "ProductType" 	TEXT NOT NULL UNIQUE,
            "ID" 			INTEGER NOT NULL UNIQUE, PRIMARY KEY("ID" AUTOINCREMENT)
        );
    `);

    // create ProductName table
    db.run(`
        CREATE TABLE "ProductName" (
            "ProductName"	TEXT NOT NULL UNIQUE,
            "ID"			INTEGER NOT NULL UNIQUE, 
            "ProductTypeID" INTEGER NOT NULL, PRIMARY KEY("ID" AUTOINCREMENT)
        );
    `);

    // create RegionPricing table
    db.run(`
        CREATE TABLE "Receipt" (
            "Date"			Date NOT NULL,
            "ProductTypeID"	INTEGER NOT NULL,
            "ProductNameID"	INTEGER,
            "Receipt"		REAL NOT NULL, PRIMARY KEY("ProductTypeID")
        );
    `);

    // save config file to tell which db is used by default
    auto file = File(basedir.buildPath(configFile), "w");
    file.write(dbname);
    file.close();

    // verbose output
    writefln("#ymt: created ymt/%s!", dbname);
}

/// Removes db
void dbRemove(const string dbname) {
    if(dbname is null) {
        writefln("#ymt: dbname not provided! See \'ymt -h\' for more info!", dbname);
        return;
    }

    // remove db
    basedir.buildPath(dbname).remove;

    // modify the config file
    auto file = File(basedir.buildPath(configFile), "w");
    file.write("none");
    file.close();

    // verbose output
    writefln("#ymt: removed ymt/%s!", dbname);
}

/// Switch from one db to another (modifies the config file)
void dbSwitch(const string dbname) {
    if(dbname is null) {
        writefln("#ymt: dbname not provided! See \'ymt -h\' for more info!", dbname);
        return;
    }

    // check if db exists
    if(!basedir.buildPath(dbname).exists) {
        writefln("\n#ymt: %s does not exist!\n", dbname);
        return;
    }

    // switch db
    auto file = File(basedir.buildPath(configFile), "w");
    file.write(dbname);
    file.close();

    // verbose output
    writefln("#ymt: switched to ymt/%s!", dbname);
}

/// Delete the entire '.ymt' directory with all db's and configs
void dbClean() {
    if(basedir.exists) {
        basedir.rmdirRecurse();
    }

    // verbose output
    writefln("#ymt: removed all data!");
}