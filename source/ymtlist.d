module ymtlist;

import std.conv: to;
import std.math: abs;
import std.stdio: writefln;
import std.format: format;
import std.string: isNumeric;
import std.algorithm.searching: canFind;

import ymtcommon;

void dbList(in string command, in string filtercmd) {
    // check if basedir and db exist
    if(!ymtIsInit("list")) {
        return;
    }

    // retrieve command
    if(command == "types") {
        if(!filtercmd.isNumeric || filtercmd.to!int < 0) {
            writefln("#ymt list: --limit=<%s> must be a positive numerical value!", filtercmd);
            return;
        }

        // construct the query
        enum query = q{
            SELECT DISTINCT Type FROM Receipts 
            ORDER BY Type ASC LIMIT %s
        };
        
        // execute query
        auto results = dbExecute(query.format(filtercmd));
        
        // list contents
        uint id = 0;
        writefln("%3s %s", "#", "Type");
        foreach(row; results) {
            immutable type = row["Type"].as!string;
            writefln("%3s %s", id++, type);
        }
    } else if(command == "names") {
        if(!filtercmd.isNumeric || filtercmd.to!int < 0) {
            writefln("#ymt list: --limit=<%s> must be a positive numerical value!", filtercmd);
            return;
        }

        // construct the query
        enum query = q{
            SELECT DISTINCT Name, Type  FROM Receipts 
            WHERE Name IS NOT ""
            ORDER BY Type ASC LIMIT %s
        };
        
        // execute query
        auto results = dbExecute(query.format(filtercmd));
        
        // list contents
        enum w = 12; // width identation
        uint id = 0;
        writefln("%3s %*s %s", "#", w, "Name", "Type");
        foreach(row; results) {
            immutable name = row["Name"].as!string;
            immutable type = row["Type"].as!string;
            writefln(
                "%3s %*s %s", 
                id++, 
                w, name.length > w-3 ? name[0 .. w-3] ~ ".." : name, 
                type,
            );
        }
    } // else if(command == "layout") {
    //     writefln(
    //         "\n#ymt list: DB layout\n\n%s\n%s\n%s", 
    //         "Type:\n-------------\n| Type | ID |\n-------------\n", 
    //         "Name:\n----------------------\n| Name | TypeID | ID |\n----------------------\n", 
    //         "Receipt:\n------------------------------------\n| Date | TypeID | NameID | Receipt |\n------------------------------------\n"
    //     );
    // } else {
    //     // init query
    //     query = query.format("Receipt");
    //     // if filtering is specified
    //     switch(filtercmd) {
    //         case "-t":
    //         case "--today":
    //             query ~= ` WHERE date=CURRENT_DATE`;
    //             break;
    //         case "-w":
    //         case "--lastweek":
    //             query ~= ` WHERE date>strftime('%Y-%m-%d', datetime('now','-7 day')) AND date<=CURRENT_DATE`;
    //             break;
    //         case "-m":
    //         case "--lastmonth":
    //             query ~= ` WHERE date>strftime('%Y-%m-%d', datetime('now','-30 day')) AND date<=CURRENT_DATE`;
    //             break;
    //         default:
    //             break;
    //     }

    //     // execute query
    //     auto results = db.execute(query);
        
    //     // list command
    //     writefln("%10s   %6s   %6s   %s", "Date", "TypeID", "NameID", "Receipt");
    //     foreach(row; results) {
    //         auto date = row["Date"].as!string;
    //         auto typeID = row["TypeID"].as!string;
    //         auto nameID = row["NameID"].as!string;
    //         auto receipt = row["Receipt"].as!double;
    //         writefln("%10s   %6s   %6s   %.1,f", date, typeID, nameID, receipt);
    //     }
    // }
}
