module ymtimport;

import std.stdio: File, writefln;
import std.file: exists;
import std.conv: to;
import std.traits: isNumeric;
import std.string: format;
import std.array: empty, split, array, replace;
import std.typecons: tuple;
import std.algorithm: map, each, joiner, remove, among;

import ymtcommon;

/++ Imports a CSV file to DB

    Params:
        path = path to CSV file
        header = contains header
        sep = char separator
+/
void dbImportCSV(in string path, in char sep = ';', in bool header = true) {
    // check if basedir and db exist
    if(!ymtIsInit("import")) {
        return;
    }

    // read data
    immutable data = path.csvRead(sep, header).to!(immutable(string[][]));

    // prepare query
    enum query = q{
        INSERT INTO Receipts (Date, Type, Name, Receipt) 
        VALUES ("%s", "%s", "%s", %s)
    };

    // add data
    uint counter = 0;
    foreach(line; data) {
        immutable entry = tuple(line[0], line[1], line[2], line[3]);

        try {
            dbRun(query.format(entry.expand));
            counter++;
        } catch(Exception e) {
            writefln(
                "#ymt import: failed to add receipt value [ %s | %s | %s | %s ] => %s",
                entry.expand, 
                e.msg
            );
        }
    }
    writefln("#ymt import: %s entries added.", counter);
}

/++
    Read a CSV file into memory

    Params:
        filename = path to the file
        sep = seperator (default: ';')
        header = does CSV contain a header (default: true)
        preallocate = pre-allocate N number of rows (default: 100)

    Returns: 'string[][]' upon success, 'null' upon failure

    Note: if a CSV file contains less/more entries than in the first row, empty entries are appended/removed.
+/
T[][] csvRead(T = string)(in string filename, in char sep = ';', bool header = true, in size_t preallocate = 100) {
    // opening a file
    File file = File(filename, "r");
    scope(exit) { file.close(); }

    // check if file was opened
    if(!file.isOpen) {
        writefln("#ymt import: cannot open <%s>!".format(filename));
        return null;
    }

    // reading data from the file
    size_t previousEntriesLen = 0;
    T[][] data; data.reserve(preallocate);
    foreach(record; file.byLine.map!(row => row.replace("\"", "").split(sep))) {
        record = record.array.remove!(row => row.empty);

        // if header is present, skip
        if(header) {
            header = false;
            continue;
        }

        // save number of entries in the first row
        if(previousEntriesLen == 0) {
            previousEntriesLen = record.length;
        }

        // if CSV file is damaged, try to fix it
        if(record.length < previousEntriesLen) {
            // add empty entries
            while(record.length < previousEntriesLen) {
                record ~= "".to!(char[]);
            }
        } else {
            // remove entries
            record = record[0..previousEntriesLen];
        }

        // save the row
        try {
            data ~= record.map!(
                entry => (entry.empty || entry.among("N/A", "n/a", "na")) ? (isNumeric!T ? "nan" : "NA") : (entry)
            ).array.to!(T[]);
        } catch(Exception e) {
            writefln(
                "#ymt import: <%s> file is damaged. Unable to repair the CSV file. Error: %s"
                .format(filename, e.msg)
            );
        }
    }

    return data;
}


