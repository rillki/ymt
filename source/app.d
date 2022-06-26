module app;

// Built with DMD v2.100.0
import std.stdio: writefln;
import std.getopt: getopt, GetoptResult, defaultGetoptPrinter;

import ymtinit;
import ymtadd;

void main(string[] args) {
    if(args.length < 2) {
        writefln("#ymt: no commands provided! See \'ymt -h\' for more info.");
        return;
    }

    // get dbname
    immutable dbname = args.length > 2 ? args[2] : null;

    // check which case is it
    switch(args[1]) {
        case "init":
            dbInit(dbname);
            break;
        case "remove":
            dbRemove(dbname);
            break;
        case "switch":
            dbSwitch(dbname);
            break;
        case "clean":
            dbClean();
            break;
        case "add":
            parseArgs(args[2..$]);
            break;
        default:
            writefln("#ymt: Unrecognized option %s!", args[1]);
            break;
    }
}

void parseArgs(string[] args) {
    // commands
    //...

    /+
    // parsing command line arguments
    GetoptResult argInfo;
    try {
        argInfo = getopt(
            args,
            "init|i", "initialize a database", &bInit,
            "remove|r", "remove a database", &bRemove,
            "switch|s", "switch from one database to another", &bSwitch,
            "clean|c", "delete ymt directory with all databases and configs", &bClean,
            "add|a", "add a data entry to a database", &bAdd
        );
    } catch(Exception e) {
        writefln("\n#ymt: error! %s\n", e.msg);
        return;
    }

    // print ymt usage
    if(argInfo.helpWanted) {
        defaultGetoptPrinter("\nymt version v0.1 -- Your Money Tracker.", argInfo.options);
        writefln("\nEXAMPLE:\n\t%s\n\t%s\n\t%s\n\t%s\n\n", 
            "ymt --init dbname.db", 
            "ymt --remove dbname.db",
            "ymt --switch new.db",
            "ymt --clean"
        );
        return;
    }+/
}




