module ymtadd;

import d2sqlite3: Database;
import std.file: readText, exists;
import std.path: buildPath;
import std.stdio: writefln;
import std.format: format;

import ymtcommon;

void dbList(const string data) {
    // check if basedir exists
    if(!basedir.exists) {
        writefln("#ymt: error! Initialize ymt first!");
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

    // prepare a querry
    immutable querry = `
        SELECT * FROM %s
    `;

    // retrieve data
    if(data == "types") {
        auto results = db.execute(querry.format("ProductType"));
        
        // list data
        writefln("\tID\tType");
        foreach(row; results) {
            auto id = row["ID"].as!uint;
            auto type = row["ProductType"].as!string;
            writefln("\t%s\t%s", id, type);
        }
    } else if(data == "names") {
        auto results = db.execute(querry.format("ProductName"));
        
        // list data
        writefln("\tID\tTypeID\tName");
        foreach(row; results) {
            auto id = row["ID"].as!uint;
            auto typeID = row["ProductTypeID"].as!uint;
            auto name = row["ProductName"].as!string;
            writefln("\t%s\t%s\t%s", id, typeID, name);
        }
    } else if(data == "receipts") {
        auto results = db.execute(querry.format("Receipt"));
        
        // list data
        writefln("      Date\tTypeID\tNameID\tReceipt");
        foreach(row; results) {
            auto date = row["Date"].as!string;
            auto typeID = row["ProductTypeID"].as!uint;
            auto nameID = row["ProductNameID"].as!string;
            auto receipt = row["ProductNameID"].as!long;
            writefln("%s\t%s\t%s\t%s", date, typeID, nameID, receipt);
        }
    } else {
        writefln("#ymt: %s is unknown! Choose either \'types\' or \'names\'.", data);
    }
}

void dbAddType(const string type) {
    //...
}

void dbAddName(const string name, const uint typeID) {
    //...
}

void dbAddReceipt(const float receipt, const uint nameID, const uint typeID) {
    //...
}
