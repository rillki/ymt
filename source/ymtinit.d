module ymtinit;

import std.string: format;
import std.path: buildPath;
import std.file: mkdir, remove, rmdirRecurse, exists;
import std.stdio: File, writefln;
import std.algorithm: endsWith;

import ymtcommon;

/// Creates a .ymt folder, db and a config file
void dbInit(in string dbname) {
    if(dbname is null) {
        writefln("#ymt init: dbname not provided! See \'ymt -h\' for more info!", dbname);
        return;
    }

    // check for invalid DB name
    if(!dbname.endsWith(".db")) {
        writefln("#ymt init: invalid dbname provided! Must end with \'.db\'!", dbname);
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

    // create Receipts table
    dbRun(q{
        CREATE TABLE "Receipts" (
            "Date"      Date NOT NULL,
            "Type"      TEXT NOT NULL,
            "Name"      TEXT,
            "Receipt"   REAL NOT NULL
        );
    }, dbname);

    // save config file to tell which db is used by default
    auto file = File(basedir.buildPath(configFile), "w");
    file.write(dbname);
    file.close();

    // verbose output
    writefln("#ymt init: created ymt/%s!", dbname);
}

/// Removes db
void dbRemove(in string dbname) {
    if(dbname is null) {
        writefln("#ymt remove: dbname not provided! See \'ymt -h\' for more info!", dbname);
        return;
    }

    // check if basedir exists
    if(!basedir.exists) {
        writefln("#ymt remove: error! Initialize ymt first!");
        return;
    }

    // check for invalid DB name
    if(!dbname.endsWith(".db")) {
        writefln("#ymt remove: invalid dbname provided! Must end with \'.db\'!", dbname);
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
void dbSwitch(in string dbname) {
    if(dbname is null) {
        writefln("#ymt switch: dbname not provided! See \'ymt -h\' for more info!", dbname);
        return;
    }

    // check if basedir exists
    if(!basedir.exists) {
        writefln("#ymt switch: error! Initialize ymt first!");
        return;
    }

    // check for invalid DB name
    if(!dbname.endsWith(".db")) {
        writefln("#ymt switch: invalid dbname provided! Must end with \'.db\'!", dbname);
        return;
    }

    // check if we are at that db already
    if(basedir.buildPath(.dbname).endsWith(dbname)) {
        writefln("#ymt switch: already at %s!", dbname);
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
    writefln("#ymt switch: switched to %s!", dbname);
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