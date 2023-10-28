module ymtadd;

import std.stdio: writef, writefln, readln;
import std.array: empty;
import std.string: toLower;
import std.format: format;
import std.datetime.date: Date;
import std.datetime.systime: Clock;

import ymtcommon;

void dbAdd(in string type, in string name, in float receipt, in string date) {
    // check if basedir and db exist
    if(!ymtIsInit("add")) {
        return;
    }

    // check if type is null
    if(type.empty) {
        writefln("#ymt add: <type> must be specified!");
        return;
    }

    // check if type specified exists in DB (providing type is mandatory)
    auto result = dbExecute(checkTypeExistsQuery.format(type));
    if(!result.front["Result"].as!bool) {
        writefln("#ymt add: <%s> does not exist in the Database!", type);
        writef("#ymt add: Add <%s> to the Database? (y/N): ", type);
        
        // get input
        immutable answer = readln[0].toLower;
        if(answer != 'y') {
            writefln("#ymt add: cancelled.");
            return;
        }
    }

    // check if receipt is not 0
    if(receipt == 0) {
        writefln("#ymt add: receipt value cannot be 0!");
        return;
    }

    // check if date specified is in correct format
    if(!date.empty) {
        try {
            auto tmp = Date.fromISOExtString(date);
        } catch(Exception e) {
            writefln("#ymt add: %s", e.msg);
            return;
        }
    }

    // prepare query
    enum query = q{
        INSERT INTO Receipts (Date, Type, Name, Receipt) 
        VALUES (%s, "%s", "%s", %s)
    };

    // now add the receipt
    try {
        dbRun(query.format(
            (date.empty ? "CURRENT_DATE" : "\"" ~ date ~ "\""), 
            type,
            name, 
            receipt
        ));
        
        writefln(
            "#ymt add: receipt value [ %s | %s | %s | %s ] added.", 
            (date.empty ? Clock.currTime.toISOExtString()[0 .. 10] : date), 
            type,
            name.empty ? "-" : name, 
            receipt
        );
    } catch(Exception e) {
        writefln("#ymt add: %s", e.msg);
    }
}


