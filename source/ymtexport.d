module ymtexport;

import std.stdio: writefln;
import std.file: readText, exists;
import std.path: buildPath;
import std.array: join;
import std.format: format;

import ymtcommon;

void dbExportCSV(in string savepath = basedir, in char sep = ';') {
    // check if savepath exists
    if(!savepath.exists) {
        writefln("#ymt export: %s does not exist!", savepath);
        return;
    }

    // get data
    auto dbData = dbGetData();

    // files
    immutable csv_dbTypes = savepath.buildPath(dbData.dbTypes.stringof ~ ".csv");
    immutable csv_dbNames = savepath.buildPath(dbData.dbNames.stringof ~ ".csv");
    immutable csv_dbReceipts = savepath.buildPath(dbData.dbReceipts.stringof ~ ".csv");
    
    /// Write data to CSV
    void arr2csv(in string filename, in string[][] data) {
        string tmp = null;
        foreach(row; data) {
            tmp ~= row.join(sep) ~ '\n';
        }
        filename.fileWrite(tmp);
    }

    // save dbTypes, dbNames, dbReceipts
    arr2csv(csv_dbTypes, dbData.dbTypes);
    arr2csv(csv_dbNames, dbData.dbNames);
    arr2csv(csv_dbReceipts, dbData.dbReceipts);
}

void dbExportExcel() {}

private auto dbGetData() {
    // data
    struct dbData { string[][] dbTypes, dbNames, dbReceipts; }

    // check if basedir exists
    if(!basedir.exists) {
        writefln("#ymt add: error! Initialize ymt first!");
        return dbData();
    }

    // read config file to get db name
    immutable dbname = basedir.buildPath(configFile).readText;

    // check if db exists
    if(!basedir.buildPath(dbname).exists) {
        writefln("#ymt add: error! %s does not exist, you need to initialize one!", dbname);
        return dbData();
    }

    // open db
    auto db = Database(basedir.buildPath(dbname));

    // prepare a query
    immutable query = `SELECT * FROM %s`;

    // retreive all types
    string[][] dbTypes = [["ID", "Type"]];
    auto results = db.execute(query.format("Type"));
    foreach(row; results) {
        dbTypes ~= [row[dbTypes[0][0]].as!string, row[dbTypes[0][1]].as!string];
    }

    // retreive all names
    string[][] dbNames = [["ID", "TypeID", "Name"]];
    results = db.execute(query.format("Name"));
    foreach(row; results) {
        dbNames ~= [row[dbNames[0][0]].as!string, row[dbNames[0][1]].as!string, row[dbNames[0][2]].as!string];
    }

    // retreive all receipts
    string[][] dbReceipts = [["Date", "TypeID", "NameID", "Receipt"]];
    results = db.execute(query.format("Receipt"));
    foreach(row; results) {
        dbReceipts ~= [
            row[dbReceipts[0][0]].as!string, 
            row[dbReceipts[0][1]].as!string, 
            row[dbReceipts[0][2]].as!string,
            row[dbReceipts[0][3]].as!string
        ];
    }

    return dbData(dbTypes, dbNames, dbReceipts);
}

