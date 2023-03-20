module ymtdescribe;

import ymtcommon;
import std.conv: to;
import std.stdio: writefln;
import std.format: format;

void dbDescribe(in int period, in bool detailed) {
    // check if basedir and db exist
    if(!ymtIsInit("describe")) {
        return;
    }

    enum w = 15; // width indentation

    // short summary
    immutable queryShortSummary = `
        SELECT "MAX" AS opertaion, Type, MAX(Receipt) as s FROM Receipts
        WHERE Date>=strftime('%Y-%m-%d', datetime('now','-` ~ period.to!string ~ ` day')) AND Date<=CURRENT_DATE
        UNION
        SELECT "MIN" AS opertaion, Type, MIN(Receipt) as s FROM Receipts
        WHERE Date>=strftime('%Y-%m-%d', datetime('now','-` ~ period.to!string ~ ` day')) AND Date<=CURRENT_DATE
        UNION
        SELECT "AVG" AS opertaion, "", AVG(Receipt) as s FROM Receipts
        WHERE Date>=strftime('%Y-%m-%d', datetime('now','-` ~ period.to!string ~ ` day')) AND Date<=CURRENT_DATE
    `;

    // count purchases
    immutable queryCountSumPurchases = `
        SELECT COUNT(Receipt) as c, SUM(Receipt) as s FROM Receipts 
        WHERE Date>=strftime('%Y-%m-%d', datetime('now','-` ~ period.to!string ~ ` day')) AND Date<=CURRENT_DATE 
    `;

    // detailed summary query
    immutable queryDetailedSummary = `
        SELECT Type, SUM(Receipt) as s FROM Receipts 
        WHERE Date>=strftime('%Y-%m-%d', datetime('now','-` ~ period.to!string ~` day')) AND Date<=CURRENT_DATE 
        GROUP BY Type
        ORDER BY s ASC
    `;
    
    // verbose output
    writefln("SUMMARY FOR THE PAST %s DAYS:", period);
    writefln("%*s   %s", w, "SUM(Receipt)", "Type");

    // detailed output
    if(detailed) {
        auto results = dbExecute(queryDetailedSummary);
        foreach(row; results) {
            // get data
            auto type = row.peek!string(0);
            auto receipt = row.peek!float(1);
            
            // output results
            writefln("%*.2,f   %s", w, receipt, type);
        }
    }
    writefln("---------------");

    // summary
    auto results = dbExecute(queryShortSummary);
    foreach(row; results) {
        // get data
        immutable operation = row.peek!string(0);
        immutable type = row.peek!string(1);
        immutable value = "%.2,f".format(row.peek!double(2));

        // display results
        writefln("%*s   %s (%s)", w, value, operation, type);
    }

    // output overall spent
    results = dbExecute(queryCountSumPurchases);
    writefln("%*.2,f   OVERALL (%s purchases)", w, results.front.peek!float(1), results.front.peek!int(0));
}


