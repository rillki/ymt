module app;

import std.stdio: writefln;
import std.conv: to;
import std.path: isValidPath, buildPath;
import std.file: getcwd, isDir, exists;
import std.array: empty;
import std.string: format, split, toUpper, toLower, startsWith;
import std.getopt: getopt, GetoptResult, defaultGetoptPrinter;
import std.algorithm.mutation: remove;
import std.algorithm.searching: canFind;

import ymtcommon;
import ymtinit;
import ymtadd;
import ymtlist;
import ymtquery;
import ymtdescribe;
import ymtplot;
import ymtexport;

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
        case "d":
        case "describe":
            parseDescribe(args);
            break;
        // case "e":
        // case "export":
        //     parseExport(args);
        //     break;
        // case "p":
        // case "plot":
        //     parsePlot(args);
        //     break;
        case "c":
        case "clean":
            dbClean();
            break;
        case "v":
        case "version":
            import std.compiler: version_major, version_minor;
            writefln("ymt version %s - Your Money Tracker.", YMT_VERSION);
            writefln("Built with %s v%s.%s on %s", __VENDOR__, version_major, version_minor, __DATE__);
            break;
        case "h":
        case "help":
            writefln("ymt version %s - Your Money Tracker.", YMT_VERSION);
            writefln("i     init <dbname>  initializes a new database");
            writefln("r   remove <dbname>  removes an existing database");
            writefln("s   switch <dbname>  switches to the specified database");
            writefln("a      add [OPTIONS] use -h to read the usage manual on adding data");
            writefln("l     list [OPTIONS] use -h to read the usage manual on listing data");
            writefln("q    query [OPTIONS] use -h to read the usage manual on querying data");
            writefln("d describe [OPTIONS] use -h to read the usage manual on getting summary output");
            // writefln("e   export [OPTIONS] use -h to read the usage manual on exporting data");
            // writefln("p     plot [OPTIONS] use -h to read the usage manual on plotting data");
            writefln("c    clean           delete all data");
            writefln("v  version           display current version");
            writefln("h     help           this help manual\n");
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
        opt_type = null,
        opt_name = null,
        opt_date = null;
    float 
        opt_receipt = 0;

    // parsing command line arguments
    GetoptResult argInfo;
    try {
        argInfo = getopt(
            args,
            "type|t", "add category name", &opt_type,
            "name|n", "add category member", &opt_name,
            "receipt|r", "add receipt", &opt_receipt,
            "date|d", "specify date Y-m-d", &opt_date,
        );
    } catch(Exception e) {
        writefln("#ymt add: error! %s", e.msg);
        return;
    }

    // print ymt usage
    if(argInfo.helpWanted) {
        defaultGetoptPrinter("ymt add version %s -- add your data.".format(YMT_VERSION), argInfo.options);
        writefln("\nEXAMPLE: ymt add --type=Dairy --name=Milk --receipt 523.2 --date 2022-08-07");
        return;
    }

    // add receipt data
    dbAdd(opt_type, opt_name, opt_receipt, opt_date);
}

/// Parses 'list' command
void parseList(string[] args) {
    if(args.length <= 2) {
        writefln("#ymt list: no option is specified! See \'ymt list -h\' for more info.");
        return;
    }

    // list command
    immutable command = args[2] == "t" ? "types" 
        : args[2] == "n" ? "names" 
        : args[2] == "r" ? "receipts" 
        : args[2] == "l" ? "layout" 
        : args[2] == "s" ? "savedir"
        : args[2] == "d" ? "dbdir" 
        : args[2]; 
    immutable subCommandsList =
        ((command == "types" || command == "t") || (command == "names" || command == "n")) 
        ? ["-l", "--limit"] 
        : [
            "-t", "--today",
            "-w", "--lastweek",
            "-m", "--lastmonth",
            "-a", "--all"
        ];
    
    // filter subcommand
    string filtercmd = args.length > 3 ? args[3] : "10";
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
            writefln("t    types list available categories");
            writefln("           -l --limit list N rows");
            writefln("n    names list names within those categories");
            writefln("           -l --limit list N rows");
            writefln("r receipts list receipt data");
            writefln("           -t     --today list data added today");
            writefln("           -w  --lastweek list data for past 7 days");
            writefln("           -m --lastmonth list data for past 30 days");
            writefln("           -a       --all list all available data");
            writefln("l   layout show database table layout");
            writefln("s  savedir show YMT save directory");
            writefln("d    dbdir show DB location\n");
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
        case "dbdir":
            writefln("%s", dbname);
            break;
        default:
            writefln("#ymt list: Unrecognized option %s!", command);
            break;
    }
}


/// Parses 'query' command
void parseQuery(string[] args) {
    if(args.length <= 2) {
        writefln("#ymt query: no option is specified! See \'ymt query -h\' for more info.");
        return;
    }

    // commands
    immutable opt_command = args[2];
    immutable opt_query = args.length > 3 ? args[3] : null;

    // check case
    switch(opt_command) {
        case "-h":
        case "--help":
            writefln("ymt query version %s -- execute custom query.", YMT_VERSION);
            writefln("   -e --execute execute your MySQL query to get results");
            writefln("EXAMPLE: ymt query -e %s", q{"SELECT * FROM Receipts"});
            break;
        case "-e":
        case "--execute":
            dbQuery(opt_query);
            break;
        default:
            writefln("#ymt query: Unrecognized option %s!", opt_command);
            break;
    }
}

void parseDescribe(string[] args) {
    if(args.length <= 2) {
        writefln("#ymt describe: no option is specified! See \'ymt describe -h\' for more info.");
        return;
    }

    // commands
    int 
        opt_period = 7;
    bool 
        opt_detailed = false;

    // parsing command line arguments
    args = args.remove(1);
    GetoptResult argInfo;
    try {
        argInfo = getopt(
            args,
            "period|p", "time period in days", &opt_period,
            "detailed|d", "detailed report (default: false)", &opt_detailed,
        );
    } catch(Exception e) {
        writefln("#ymt describe: error! %s", e.msg);
        return;
    }

    // print ymt usage
    if(argInfo.helpWanted) {
        defaultGetoptPrinter("ymt describe version %s -- describe data.".format(YMT_VERSION), argInfo.options);
        writefln("\nEXAMPLE: ymt describe --period=30 --detailed");
        return;
    }

    // describe data
    dbDescribe(opt_period, opt_detailed);
}

/+
void parseExport(string[] args) {
    // commands
    string opt_path = basedir;
    char opt_separator = ';';

    // parsing command line arguments
    args = args.remove(1);
    GetoptResult argInfo;
    try {
        argInfo = getopt(
            args,
            "path|p", "specify the save path (default: <ymt savedir>/dbData.csv)", &opt_path,
            "separator|s", "specify data separator (default: \';\')", &opt_separator,
        );
    } catch(Exception e) {
        writefln("#ymt export: error! %s", e.msg);
        return;
    }

    // print ymt usage
    if(argInfo.helpWanted) {
        defaultGetoptPrinter("ymt export version %s -- add your data.".format(YMT_VERSION), argInfo.options);
        writefln("\nEXAMPLE: ymt export path=../Desktop");
        return;
    }

    // check if savepath exists
    if(!opt_path.isValidPath || !(opt_path.exists && opt_path.isDir)) {
        writefln("#ymt export: directory <%s> does not exist!", opt_path);
        return;
    }

    // export data
    dbExportCSV(opt_path.buildPath("dbData.csv"), opt_separator);
    writefln("#ymt export: data saved to <%s>", opt_path.buildPath("dbData.csv"));
}

void parsePlot(string[] args) {
    if(args.length <= 2) {
        writefln("#ymt plot: no option is specified! See \'ymt plot -h\' for more info.");
        return;
    }

    // commands
    int 
        opt_grab = -1,
        opt_typeID = -1;
    string 
        opt_interval = "monthly",
        opt_path = basedir;

    // parsing command line arguments
    args = args.remove(1);
    GetoptResult argInfo;
    try {
            argInfo = getopt(
                args,
                "grab|g", "grab time period in days (default: all)", &opt_grab,
                "typeID|x", "filter using type id", &opt_typeID,
                "interval|i", "group data [ daily, monthly, yearly ] (default: monthly)", &opt_interval,
                "path|p", "save path (default: <ymt savedir>/plot.png)", &opt_path,
            );

    } catch(Exception e) {
        writefln("#ymt plot: error! %s", e.msg);
        return;
    }

    // print ymt usage
    if(argInfo.helpWanted) {
        defaultGetoptPrinter("ymt plot version %s -- plot data.".format(YMT_VERSION), argInfo.options);
        writefln("\nEXAMPLE: ymt plot --grab=30 --typeID=id --interval=monthly --path ../pics");
        return;
    }

    // check if the specified interval is valid
    opt_interval = opt_interval.toLower();
    if(!opt_interval.startsWith("d", "m", "y")) {
        writefln("#ymt plot: interval specified <%s> isn't supported!", opt_interval);
        return;
    }

    // check if savepath exists
    if(!opt_path.isValidPath || !(opt_path.exists && opt_path.isDir)) {
        writefln("#ymt plot: directory <%s> does not exist!", opt_path);
        return;
    }

    // plot data
    dbPlot(opt_grab, opt_typeID, opt_interval[0], opt_path.buildPath("plot.png"));
    writefln("#ymt plot: saved plot to <%s>", opt_path.buildPath("plot.png"));
}
+/