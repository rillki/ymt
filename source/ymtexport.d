module ymtexport;
/+
import ymtcommon;

/++ Exports database to CSV file

    Params:
        path = save path with filename
        sep = char separator

+/
void dbExportCSV(in string path, in char sep = ';') {
    import std.array: join;

    // check if basedir and db exist
    if(!ymtIsInit("export")) {
        return;
    }

    // get data
    auto dbData = dbGetData();
    
    // transform data
    string data = ["Dates", "Receipts", "Types", "Names\n"].join(sep);
    foreach(row; dbData) {
        data ~= row.join(sep) ~ "\n";
    }

    // write data to file
    path.fileWrite(data);
}

/++ Returns database data
    Returns: string[4][] = [Dates, Receipts, Types, Names]
+/
private string[][] dbGetData() {
    // open db
    auto db = Database(basedir.buildPath(dbname));

    // prepare a query
    immutable query = `
        SELECT data.Date, data.Receipt, data.Type, data.Name FROM (
            SELECT * FROM Receipt AS r
            JOIN 
                Type AS t ON r.TypeID=t.ID, 
                Name AS n ON r.NameID=n.ID
        ) AS data
    `;

    // query data
    auto results = db.execute(query);

    // save data
    string[][] dbData;
    foreach(row; results) {
        dbData ~= [row[0].as!string, row[1].as!string, row[2].as!string, row[3].as!string];
    }

    return dbData;
}


+/