// Built with DMD v2.100.0
module app;

import std.stdio: writefln;
import std.conv: to;
import std.file: getcwd;
import std.path: dirName;
import std.array: empty;
import std.string: format, split, toUpper;
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
        version(Windows) {} else {
            case "e":
            case "export":
                parseExport(args);
                break;
        }
        case "p":
        case "plot":
            parsePlot(args);
            break;
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
            writefln("e   export [OPTIONS] use -h to read the usage manual on exporting data");
            writefln("p     plot [OPTIONS] use -h to read the usage manual on plotting data");
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
        type = null,
        name = null,
        date = null;
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
            "date|d", "specify date Y-m-d", &date,
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
        writefln("         ymt add --receipt 523.2 --typeID 1 --nameID 1 --date 2022-08-07");
        return;
    }

    if(type !is null) {
        dbAddType(type);
    } else if(name !is null) {
        dbAddName(name, typeID);
    } else {
        dbAddReceipt(receipt, nameID, typeID, date);
    }
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
    immutable subCommandsList = (command == "types" || command == "t") ? ["-l", "--limit"] :
        (command == "names" || command == "n") ? ["-x", "--typeID"] : [
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
            writefln("t    types list available categories");
            writefln("           -l --limit list last N rows");
            writefln("n    names list names within those categories");
            writefln("           -x --typeID filter using type id");
            writefln("r receipts list receipt data");
            writefln("           -t     --today list data added today");
            writefln("           -w  --lastweek list data for past 7 days");
            writefln("           -m --lastmonth list data for past 30 days");
            writefln("           -a       --all list all available data");
            writefln("l   layout show database table layout");
            writefln("s  savedir show YMT save directory\n");
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

void parseDescribe(string[] args) {
    if(args.length <= 2) {
        writefln("#ymt describe: no option is specified! See \'ymt describe -h\' for more info.");
        return;
    }

    // commands
    int period = 7;
    bool detailed = false;
    bool descending = false;

    // parsing command line arguments
    args = args.remove(1);
    GetoptResult argInfo;
    try {
        argInfo = getopt(
            args,
            "period|p", "time period in days", &period,
            "detailed|d", "detailed report (default: false)", &detailed,
            "desc", "descending order (default: false)", &descending,
        );
    } catch(Exception e) {
        writefln("#ymt describe: error! %s", e.msg);
        return;
    }

    // print ymt usage
    if(argInfo.helpWanted) {
        defaultGetoptPrinter("ymt describe version %s -- describe data.".format(YMT_VERSION), argInfo.options);
        writefln("\nEXAMPLE: ymt describe --period=30 --detailed --desc");
        return;
    }

    // describe data
    dbDescribe(period, detailed, descending);
}

void parseExport(string[] args) {
    if(args.length <= 2) {
        writefln("#ymt export: no option is specified! See \'ymt export -h\' for more info.");
        return;
    }

    // commands
    string type = "csv";
    string savepath = basedir;

    // parsing command line arguments
    args = args.remove(1);
    GetoptResult argInfo;
    try {
        version(Windows) {
            argInfo = getopt(
                args,
                "savepath|s", "specify the save path", &savepath,
            );
        } else {
            argInfo = getopt(
                args,
                "type|t", "export type <csv, excel>", &type,
                "savepath|s", "specify the save path", &savepath,
            );
        }
    } catch(Exception e) {
        writefln("#ymt export: error! %s", e.msg);
        return;
    }

    // print ymt usage
    if(argInfo.helpWanted) {
        defaultGetoptPrinter("ymt export version %s -- add your data.".format(YMT_VERSION), argInfo.options);
        writefln("\nEXAMPLE: ymt export --type=csv --savepath=../Desktop");
        return;
    }

    version(Windows) {
        dbExportCSV(savepath);
    } else {
        // export data
        if(type == "csv") {
            dbExportCSV(savepath);
        } else if(type == "excel") {
            dbExportExcel(savepath);
        } else {
            writefln("#ymt export: Unrecognized option %s!", type);
            return;
        }
    }

    // done
    writefln("#ymt export: data saved as %s file to %s", type.toUpper, savepath);
}

void parsePlot(string[] args) {
    if(args.length <= 2) {
        writefln("#ymt plot: no option is specified! See \'ymt plot -h\' for more info.");
        return;
    }

    // commands
    int period = 7,
        typeID = -1;
    bool daily = false, 
        montly = false,
        yearly = false;
    string plotType = "bar",
        savepath = basedir.buildPath("plot.png");

    // parsing command line arguments
    args = args.remove(1);
    GetoptResult argInfo;
    try {
        version(Windows) {
            argInfo = getopt(
                args,
                "period|p", "time period in days (if -1 is specified, all data is taken)", &period,
                "typeID|x", "filter using type id", &typeID,
                "daily|d", "group data on a daily basis", &daily,
                "monthly|m", "group data a monthly basis", &montly,
                "yearly|y", "group data on a yearly basis", &yearly,
                "save|s", "save path with plot name (default: <ymt savedir>/plot.png)", &savepath,
            );
        } else {
            argInfo = getopt(
                args,
                "period|p", "time period in days (if -1 is specified, all data is taken)", &period,
                "plt", "plot type <bar, barh, line>", &plotType,
                "typeID|x", "filter using type id", &typeID,
                "daily|d", "group data on a daily basis", &daily,
                "monthly|m", "group data a monthly basis", &montly,
                "yearly|y", "group data on a yearly basis", &yearly,
                "save|s", "save path with plot name (default: <ymt savedir>/plot.png)", &savepath,
            );
        }
    } catch(Exception e) {
        writefln("#ymt plot: error! %s", e.msg);
        return;
    }

    // print ymt usage
    if(argInfo.helpWanted) {
        defaultGetoptPrinter("ymt plot version %s -- describe data.".format(YMT_VERSION), argInfo.options);
        writefln("\nEXAMPLE: ymt plot --period=30 --typeID=id --daily");
        return;
    }

    // check if savepath exists
    immutable spath = savepath.canFind("~") ? savepath.expandTilde : getcwd.buildPath(savepath);
    if(!spath.dirName.exists) {
        writefln("#ymt plot: save path <%s> does not exist!", savepath);
        return;
    }

    // plot data
    dbPlot(period, typeID, plotType, [daily, montly, yearly], spath);
}
