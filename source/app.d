// Built with DMD v2.100.0
module app;

import std.stdio: writefln;
import std.conv: to;
import std.array: empty;
import std.string: format, split;
import std.getopt: getopt, GetoptResult, defaultGetoptPrinter;
import std.algorithm.searching: canFind;

import ymtcommon;
import ymtinit;
import ymtadd;
import ymtlist;
import ymtquery;

void main(string[] args) {
    if(args.length < 2) {
        writefln("#ymt: no commands provided! See \'ymt help\' for more info.");
        return;
    }

    // get dbname
    immutable dbname = args.length > 2 ? args[2] : null;

    // check which case is it
    switch(args[1]) {
        case "i":
        case "init":
            dbInit(dbname);
            break;
        case "r":
        case "remove":
            dbRemove(dbname);
            break;
        case "s":
        case "switch":
            dbSwitch(dbname);
            break;
        case "a":
        case "add":
            parseAdd(args);
            break;
        case "l":
        case "list":
            parseList(args);
            break;
        case "q":
        case "query":
            parseQuery(args);
            break;
        case "c":
        case "clean":
            dbClean();
            break;
        case "v":
        case "version":
            import std.compiler: version_major, version_minor;
            writefln("ymt version %s - Your Money Tracker.", YMT_VERSION);
            writefln("Built with %s v%s.%s on %s", __VENDOR__, version_major, version_minor, __TIMESTAMP__);
            break;
        case "h":
        case "help":
            writefln("ymt version %s - Your Money Tracker.", YMT_VERSION);
            writefln("i    init <dbname>  initializes a new database");
            writefln("r  remove <dbname>  removes an existing database");
            writefln("s  switch <dbname>  switches to the specified database");
            writefln("a     add [OPTIONS] use -h to read the usage manual on adding data");
            writefln("l    list [OPTIONS] use -h to read the usage manual on listing data");
            writefln("q   query [OPTIONS] use -h to read the usage manual on querying data");
            writefln("c   clean           delete all data");
            writefln("v version           display current version");
            writefln("h    help           this help manual\n");
            writefln("EXAMPLE: ymt init crow.db");
            break;
        default:
            writefln("#ymt: Unrecognized option %s!", args[1]);
            break;
    }
}

/// Parses 'add' command
void parseAdd(string[] args) {
    if(args.length < 3) {
        writefln("#ymt add: no option is specified! See \'ymt add -h\' for more info.");
        return;
    }

    // commands
    string 
        type = null,
        name = null;
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
            "receipt|r", "add receipt", &receipt,
        );
    } catch(Exception e) {
        writefln("#ymt add: error! %s", e.msg);
        return;
    }

    // print ymt usage
    if(argInfo.helpWanted) {
        defaultGetoptPrinter("ymt add version %s -- add your data.".format(YMT_VERSION), argInfo.options);
        writefln("\nEXAMPLE: ymt add --type=Dairy");
        writefln("         ymt add --name Milk --typeID 1");
        writefln("         ymt add --receipt 523.2 --typeID 1 --nameID 1");
        return;
    }

    if(type !is null) {
        dbAddType(type);
    } else if(name !is null) {
        dbAddName(name, typeID);
    } else {
        dbAddReceipt(receipt, nameID, typeID);
    }
}

/// Parses 'list' command
void parseList(string[] args) {
    if(args.length <= 2) {
        writefln("#ymt list: no option is specified! See \'ymt list -h\' for more info.");
        return;
    }

    // list command
    immutable command = args[2];
    immutable subCommandsList = command == "types" ? ["-l", "--limit"] :
        command == "names" ? ["-x", "--typeID"] : [
            "-t", "--today",
            "-w", "--lastweek",
            "-m", "--lastmonth",
            "-a", "--all"
        ];
    
    // filter subcommand
    string filtercmd = args.length > 3 ? args[3] : "";
    if(filtercmd.canFind("=") && subCommandsList.canFind(filtercmd.split("=")[0])) {
        filtercmd = filtercmd.split("=")[$-1];
    } else if(subCommandsList.canFind(filtercmd)) {
        filtercmd = args.length > 4 ? args[4] : filtercmd;
    } else if(args.length > 3) {
        writefln("#ymt list: Unrecognized option %s!", filtercmd);
        return;
    }

    // check case
    switch(command) {
        case "-h":
        case "--help":
            writefln("ymt list version %s -- list database data.", YMT_VERSION);
            writefln("OPTIONS:");
            writefln("   types list available categories");
            writefln("         -l --limit list last N rows");
            writefln("   names list names within those categories");
            writefln("         -x --typeID filter using type id");
            writefln("receipts list receipt data");
            writefln("         -t     --today list data added today");
            writefln("         -w  --lastweek list data for past 7 days");
            writefln("         -m --lastmonth list data for past 30 days");
            writefln("         -a       --all list all available data");
            writefln("  layout show database table layout");
            writefln(" savedir show YMT save directory\n");
            writefln("EXAMPLE: ymt list [OPTIONS]");
            break;
        case "types":
        case "names":
        case "receipts":
        case "layout":
            dbList(command, filtercmd);
            break;
        case "savedir":
            writefln("%s", basedir);
            break;
        default:
            writefln("#ymt list: Unrecognized option %s!", command);
            break;
    }
}

/// Parses 'query' command
void parseQuery(const string[] args) {
    if(args.length <= 2) {
        writefln("#ymt query: no option is specified! See \'ymt query -h\' for more info.");
        return;
    }

    // commands
    immutable command = args[2];
    immutable query = args.length > 3 ? args[3] : null;

    // check case
    switch(command) {
        case "-h":
        case "--help":
            writefln("ymt query version %s -- use custom query.", YMT_VERSION);
            writefln("   -e --execute \"your MySQL query\"");
            writefln("EXAMPLE: ymt query -e \"INSERT INTO Type (Type) VALUES (\\\"Cake\\\")\"");
            break;
        case "-e":
        case "--execute":
            dbQuery(query);
            break;
        default:
            writefln("#ymt query: Unrecognized option %s!", command);
            break;
    }
}




