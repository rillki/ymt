module ymtdescribe;

import ymtcommon;
import std.array: empty, join;
import std.format: format;
import std.string: split;

void dbDescribe(in int period, in bool detailed, in bool descending) {
    // check if basedir and db exist
    if(!ymtIsInit("describe")) {
        return;
    }

    // open db
    auto db = Database(basedir.buildPath(dbname));

    // summary query
    immutable querySummary = `
        SELECT t.Type, SUM(r.Receipt) as s FROM Receipt r
        LEFT OUTER JOIN Type t on t.ID=r.TypeID ` ~ 
        (period < 0 
        ? "" 
        : period == 0 
        ? `WHERE r.date=CURRENT_DATE ` 
        : `WHERE r.date>=strftime('%Y-%m-%d', datetime('now','-` 
        ~ `%s day')) AND r.date<=CURRENT_DATE `.format(period)) 
        ~ `GROUP BY t.Type ORDER BY s ` ~ (descending ? "DESC" : "ASC");
    
    // query max/min/avg receipt value
    immutable queryDetails = 
        // MAX receipt value
        `SELECT Type, MAX(s), "MAX" FROM (%s)`.format(querySummary) ~
        " UNION " ~
        // MIN receipt value
        `SELECT Type, MIN(s), "MIN" FROM (%s)`.format(querySummary) ~
        " UNION " ~ 
        // AVG receipt value
        `SELECT Type, AVG(s), "AVG" FROM (%s)`.format(querySummary);
    
    // query count purchases
    immutable queryCountPurchases = `
        SELECT COUNT(*) FROM Receipt ` ~
            (period < 0 
            ? "" 
            : period == 0 
            ? `WHERE date=CURRENT_DATE `
            : `WHERE date>=strftime('%Y-%m-%d', datetime('now','-` 
            ~ `%s day')) AND date<=CURRENT_DATE `.format(period));

    // execute query
    auto results = db.execute(querySummary);

    // output summary
    writefln("SUMMARY FOR THE PAST %s DAYS:", period);
    writefln("%14s   %s", "SUM(Receipt)", "Type");
    double overallSpent = 0;
    foreach(row; results) {
        // get data
        auto type = row.peek!string(0);
        auto receipt = row.peek!double(1);

        // sum
        overallSpent += receipt;

        // output results
        writefln("%14.1,f   %s", receipt, (type.empty ? "N/A" : type));
    }

    // summary
    writefln("--------------");

    // detailed summary
    if(detailed) {
        results = db.execute(queryDetails);
        foreach(row; results) {
            // get data
            auto type = row.peek!string(0);
            auto value = "%.1,f".format(row.peek!double(1));
            auto operation = row.peek!string(2);

            // display results
            writefln("%14s   %s (%s)", value, operation, (operation == "AVG" ? "" : type));
        }
    }

    // output overall spent
    results = db.execute(queryCountPurchases);
    writefln("%14.1,f   OVERALL (%s purchases)", overallSpent, results.oneValue!string);
}