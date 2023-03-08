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
    } else if(command == "layout") {
        writefln(
            "#ymt list: DB layout\n%s", 
            "--------------------------------\n| Date | Type | Name | Receipt |\n--------------------------------"
        );
    } else {
        // construct the query
        string query = q{
            SELECT * FROM Receipts 
        };

        // if filtering is specified
        writefln("-----------%s", filtercmd);
        switch(filtercmd) {
            case "-t":
            case "--today":
                query ~= q{ WHERE date=CURRENT_DATE };
                break;
            case "-w":
            case "--lastweek":
                query ~= q{ WHERE date>strftime("%Y-%m-%d", datetime("now","-7 day")) AND date<=CURRENT_DATE };
                break;
            case "-m":
            case "--lastmonth":
                query ~= q{ WHERE date>strftime("%Y-%m-%d", datetime("now","-30 day")) AND date<=CURRENT_DATE };
                break;
            default:
                break;
        }

        // execute query
        auto results = dbExecute(query);
        
        // list command
        enum w = 12; // width identation
        uint id = 0;
        writefln("%3s %10s %*s %*s %s", "#", "Date", w, "Type", w, "Name", "Receipt");
        foreach(row; results) {
            immutable date = row["Date"].as!string;
            immutable type = row["Type"].as!string;
            immutable name = row["Name"].as!string;
            immutable receipt = row["Receipt"].as!float;
            writefln(
                "%3s %10s %*s %*s %.2,f", 
                id++, 
                date, 
                w, type.length > w-3 ? type[0 .. w-3] ~ ".." : type, 
                w, name.length > w-3 ? name[0 .. w-3] ~ ".." : name, 
                receipt
            );
        }
    }
}


