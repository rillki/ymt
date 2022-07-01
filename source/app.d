// Built with DMD v2.100.0
module app;

import std.stdio: writefln;
import std.conv: to;
import std.getopt: getopt, GetoptResult, defaultGetoptPrinter;

import ymtinit;
import ymtadd;

void main(string[] args) {
    if(args.length < 2) {
        writefln("#ymt: no commands provided! See \'ymt help\' for more info.");
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
            parseArgs(args);
            break;
        case "help":
            writefln("\nymt version 0.1 - Your Money Tracker.");
            writefln("  init <dbname>  initializes a new database");
            writefln("remove <dbname>  removes an existing database");
            writefln("switch <dbname>  switches to the specified database");
            writefln("   add [OPTIONS] use -h to read the usage manual on adding data");
            writefln(" clean           delete all data");
            writefln("  help           this help manual\n");
            writefln("EXAMPLE: ymt init crow.db\n");
            break;
        default:
            writefln("#ymt: Unrecognized option %s!", args[1]);
            break;
    }
}

void parseArgs(string[] args) {
    if(args.length < 3) {
        writefln("#ymt add: no commands provided! See \'ymt add -h\' for more info.");
        return;
    }

    // commands
    string 
        type = null,
        name = null,
        list = null;
    uint 
        typeID = 0, 
        nameID = 0;
    float receipt = 0;

    // parsing command line arguments
    GetoptResult argInfo;
    try {
        argInfo = getopt(
            args,
            "type|t", "add category name", &type,
            "name|n", "add category member", &name,
            "typeID|x", "category ID", &typeID,
            "nameID|z", "category member ID", &nameID,
            "list|l", "list data: [types, names, receipts]", &list,
            "receipt|r", "add receipt", &receipt,
        );
    } catch(Exception e) {
        writefln("\n#ymt: error! %s\n", e.msg);
        return;
    }

    // print ymt usage
    if(argInfo.helpWanted) {
        defaultGetoptPrinter("\nymt add -- add your data.", argInfo.options);
        writefln("\nEXAMPLE: ymt add --type=Dairy");
        writefln("         ymt add --name Milk --typeID 1");
        writefln("         ymt add --receipt 523.2 --typeID 1 --nameID 1");
        writefln("         ymt list types");
        writefln("         ymt list names\n");
        return;
    }

    if(list !is null) {
        dbList(list);
    } else if(type !is null) {
        dbAddType(type);
    } else if(name !is null) {
        dbAddName(name, typeID);
    } else {
        dbAddReceipt(receipt, nameID, typeID);
    }
}




