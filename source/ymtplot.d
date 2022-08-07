module ymtplot;

import std.array: array;
import std.string: capitalize;
import std.format: format;
import std.algorithm.searching: canFind;
import plt = matplotlibd.pyplot;

import ymtcommon;

void dbPlot(in int period, in string plotType, in bool[3] periodGroupBy, in string savepath) {
    // check if basedir and db exist
    if(!ymtIsInit("plot")) {
        return;
    }

    // get data
    auto data = dbGetData(
        period, 
        plotType,
        periodGroupBy[2] ? "strftime('%Y', r.date)"
            : periodGroupBy[1] ? "strftime('%Y-%m', r.date)"
            : "strftime('%Y-%m-%d', r.date)"
    );

    // plotting
    plt.figure(["figsize" :[21, 12]]);
    switch(plotType) {
        case "bar":
            plt.bar(data.dbX, data.dbY);
            break;
        case "barh":
            plt.barh(data.dbX, data.dbY);
            break;
        case "line":
            plt.plot(data.dbX, data.dbY);
            writefln("%s\n", data);
            break;
        default:
            writefln("#ymt export: Unrecognized option %s!", plotType);
            break;
    }

    // save plot
    plt.savefig(savepath);
    plt.clear();
}

private auto dbGetData(in int period, in string plotType, in string periodGroupBy) {
    // data
    struct dbData { string[] dbX; double[] dbY; }

    // check if basedir and db exist
    if(!ymtIsInit("export")) {
        return dbData();
    }

    // open db
    auto db = Database(basedir.buildPath(dbname));

    // prepare a query
    immutable query = !plotType.canFind("bar") ? 
            `SELECT ` ~ periodGroupBy ~ ` as rdate, SUM(r.Receipt) as s FROM Receipt r `
            ~ (period < 0 ? "" 
                : period == 0 ? `WHERE r.date=CURRENT_DATE ` 
                : `WHERE r.date>=strftime('%Y-%m-%d', datetime('now','-` 
            ~ `%s day')) AND r.date<=CURRENT_DATE `.format(period)) 
            ~ `GROUP BY rdate ORDER BY rdate ASC`
        : 
            `SELECT t.Type, SUM(r.Receipt) as s FROM Receipt r
            LEFT OUTER JOIN Type t on t.ID=r.TypeID `
            ~ (period < 0 ? "" 
            : period == 0 ? `WHERE r.date=CURRENT_DATE ` 
            : `WHERE r.date>=strftime('%Y-%m-%d', datetime('now','-` 
            ~ `%s day')) AND r.date<=CURRENT_DATE `.format(period)) 
            ~ `GROUP BY t.Type ORDER BY s DESC`;

    // retreive all types
    dbData data;
    auto results = db.execute(query);
    foreach(row; results) {
        data.dbX ~= row.peek!string(0);
        data.dbY ~= row.peek!double(1);
    }

    return data;
}



