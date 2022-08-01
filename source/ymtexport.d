module ymtexport;

import ymtcommon;
import std.array: join;
import std.format: format;

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

void dbExportExcel(in string savepath = basedir) {
    import std.conv: to;
    import libxlsxd: newWorkbook;

    // check if savepath exists
    if(!savepath.exists) {
        writefln("#ymt export: %s does not exist!", savepath);
        return;
    }

    // get data
    auto dbData = dbGetData();

    // files
    immutable sheet_dbTypes = dbData.dbTypes.stringof;
    immutable sheet_dbNames = dbData.dbNames.stringof;
    immutable sheet_dbReceipts = dbData.dbReceipts.stringof;

    // create workbook
    auto workbook  = newWorkbook(savepath.buildPath(dbname ~ ".xlsx"));
    
    /// Write data to CSV
    void arr2excel(typeof(workbook) wb, in string sheetName, in string[][] data) {
        auto worksheet = wb.addWorksheet(sheetName);
        foreach(i, row; data) {
            foreach(j, d; row) {
                worksheet.writeString(i.to!uint, j.to!ushort, d);
            }
        }
    }

    // save dbTypes, dbNames, dbReceipts
    arr2excel(workbook, sheet_dbTypes, dbData.dbTypes);
    arr2excel(workbook, sheet_dbNames, dbData.dbNames);
    arr2excel(workbook, sheet_dbReceipts, dbData.dbReceipts);
}

auto dbGetData() {
    // data
    struct dbData { string[][] dbTypes, dbNames, dbReceipts; }

    // check if basedir and db exist
    if(!ymtIsInit("export")) {
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

