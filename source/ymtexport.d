module ymtexport;

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
    auto dbData = dbExecute("SELECT * FROM Receipts");
    
    // transform data
    string data = ["Dates", "Types", "Names", "Receipts", "\n"].join(sep);
    foreach(row; dbData) {
        data ~= [row[0].as!string, row[1].as!string, row[2].as!string, row[3].as!string].join(sep) ~ "\n";
    }

    // write data to file
    path.fileWrite(data);
}


