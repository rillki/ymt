module ymtlist;

import std.file: readText, exists;
import std.path: buildPath;
import std.stdio: writefln;
import std.format: format;
import std.math: abs;

import ymtcommon;

void dbList(const string data) {
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

    // prepare a query
    immutable query = `
        SELECT * FROM %s
    `;

    // retrieve data
    if(data == "types") {
        auto results = db.execute(query.format("ProductType"));
        
        // list data
        writefln("%5s   %s", "ID", "Type");
        foreach(row; results) {
            auto id = row["ID"].as!uint;
            auto type = row["ProductType"].as!string;
            writefln("%5s   %s", id, type);
        }
    } else if(data == "names") {
        auto results = db.execute(query.format("ProductName"));
        
        // list data
        writefln("%5s   %6s   %s", "ID", "TypeID", "Name");
        foreach(row; results) {
            auto id = row["ID"].as!uint;
            auto typeID = row["ProductTypeID"].as!uint;
            auto name = row["ProductName"].as!string;
            writefln("%5s   %6s   %s", id, typeID, name);
        }
    }  else if(data == "layout") {
        writefln(
            "\n#ymt list: table layout\n\n%s\n%s\n%s", 
            "ProductType:\n--------------------\n| ProductType | ID |\n--------------------\n", 
            "ProductName:\n------------------------------------\n| ProductName | ProductTypeID | ID |\n------------------------------------\n", 
            "Receipt:\n--------------------------------------------------\n| Date | ProductTypeID | ProductNameID | Receipt |\n--------------------------------------------------\n"
        );
    } else {
        auto results = db.execute(query.format("Receipt"));
        
        // list data
        writefln("%10s   %6s   %6s   %s", "Date", "TypeID", "NameID", "Receipt");
        foreach(row; results) {
            auto date = row["Date"].as!string;
            auto typeID = row["ProductTypeID"].as!uint;
            auto nameID = row["ProductNameID"].as!string;
            auto receipt = row["Receipt"].as!long;
            writefln("%10s   %6s   %6s   %s", date, typeID, nameID, receipt);
        }
    }
}