module ymtlist;

import std.math: abs;
import std.file: readText, exists;
import std.path: buildPath;
import std.stdio: writefln;
import std.format: format;
import std.string: isNumeric;
import std.algorithm.searching: canFind;

import ymtcommon;

void dbList(in string command, in string filtercmd) {
    // check if basedir exists
    if(!basedir.exists) {
        writefln("#ymt list: error! Initialize ymt first!");
        return;
    }

    // read config file to get db name
    immutable dbname = basedir.buildPath(configFile).readText;

    // check if db exists
    if(!basedir.buildPath(dbname).exists) {
        writefln("#ymt: error! %s does not exist, you need to initialize one!", dbname);
        return;
    }

    // open db
    auto db = Database(basedir.buildPath(dbname));

    // prepare a generic query
    string query = `SELECT * FROM %s`;

    // retrieve command
    if(command == "types") {
        // if we filtering is specified
        if(filtercmd.isNumeric) {
            query ~= ` ORDER BY ID `~ 
                (filtercmd[0] == '-' ? "DESC" : "ASC") ~ 
                ` LIMIT ` ~ 
                (filtercmd[0] == '-' ? filtercmd[1..$] : filtercmd);
        }
        
        // execute query
        auto results = db.execute(query.format("Type"));
        
        // list command
        writefln("%6s   %s", "ID", "Type");
        foreach(row; results) {
            auto id = row["ID"].as!uint;
            auto type = row["Type"].as!string;
            writefln("%6s   %s", id, type);
        }
    } else if(command == "names") {
        // if we filtering is specified
        if(filtercmd.isNumeric) {
            query ~= ` WHERE TypeID=` ~ filtercmd;
        }

        // execute query
        auto results = db.execute(query.format("Name"));
        
        // list command
        writefln("%6s   %6s   %s", "ID", "TypeID", "Name");
        foreach(row; results) {
            auto id = row["ID"].as!uint;
            auto typeID = row["TypeID"].as!uint;
            auto name = row["Name"].as!string;
            writefln("%6s   %6s   %s", id, typeID, name);
        }
    }  else if(command == "layout") {
        writefln(
            "\n#ymt list: DB layout\n\n%s\n%s\n%s", 
            "Type:\n-------------\n| Type | ID |\n-------------\n", 
            "Name:\n----------------------\n| Name | TypeID | ID |\n----------------------\n", 
            "Receipt:\n------------------------------------\n| Date | TypeID | NameID | Receipt |\n------------------------------------\n"
        );
    } else {
        // if filtering is specified
        switch(filtercmd) {
            case "-t":
            case "--today":
                query ~= ` WHERE date=CURRENT_DATE`;
                break;
            case "-w":
            case "--lastweek":
                query ~= ` WHERE date<=CURRENT_DATE AND date>=CURRENT_DATE-6`;
                break;
            case "-m":
            case "--lastmonth":
                query ~= ` WHERE date<=CURRENT_DATE AND date>=CURRENT_DATE-30`;
                break;
            default:
                break;
        }

        // execute query
        auto results = db.execute(query.format("Receipt"));
        
        // list command
        writefln("%10s   %6s   %6s   %s", "Date", "TypeID", "NameID", "Receipt");
        foreach(row; results) {
            auto date = row["Date"].as!string;
            auto typeID = row["TypeID"].as!uint;
            auto nameID = row["NameID"].as!string;
            auto receipt = row["Receipt"].as!long;
            writefln("%10s   %6s   %6s   %s", date, typeID, nameID, receipt);
        }
    }
}