module ymtplot;

import std.stdio: writefln;
import std.array: array, empty;
import std.string: capitalize;
import std.format: format;

import ggplotd.aes;
import ggplotd.axes;
import ggplotd.ggplotd;
import ggplotd.geom;

import ymtcommon;

/++ Plots data

    Params: 
        period = time period in days
        typeID = category ID
        periodGroupBy = dayily, monthly, yearly
        path = save path with plot name
+/
void dbPlot(in string type, in char periodGroupBy, in string path) {
    // check if basedir and db exist
    if(!ymtIsInit("plot")) {
        return;
    }

    if(!type.empty) {
        // check if type specified exists in DB (providing type is mandatory)
        auto result = dbExecute(checkTypeExistsQuery.format(type));
        if(!result.front["Result"].as!bool) {
            writefln("#ymt plot: <%s> does not exist in the Database!", type);
            writefln("#ymt plot: Cancelled!", type);
            return;
        }
    }

    // create query
    immutable dateFmt = periodGroupBy == 'd' ? `strftime('%Y-%m-%d', Date) as Date`
        : periodGroupBy == 'm' ? `strftime('%Y-%m', Date) as Date`
        : `strftime('%Y', Date) as Date`;
    immutable query = type.empty ? `SELECT %s, SUM(Receipt) FROM Receipts GROUP BY Date`.format(dateFmt) : `
        SELECT %s, s FROM (
            SELECT Date, Type, SUM(Receipt) as s FROM Receipts
            WHERE Type="%s"
            GROUP BY Date
        )
    `.format(dateFmt, type);

    // create data structure
    struct dbData { string[] dates; double[] receipts; } 
    dbData data;

    // get data
    auto results = dbExecute(query);
    foreach(row; results) {
        // get data
        data.dates ~= row.peek!string(0);
        data.receipts ~= row.peek!float(1);
    }

    // plotting
    import std.range: zip;
    import std.algorithm: map, maxElement;
    zip(data.dates, data.receipts)
        .map!(a => aes!("x", "y")(a[0], a[1]))
        .geomLine
        .putIn(GGPlotD())
        .put(yaxisRange(0, data.receipts.maxElement))
        .put(xaxisTextAngle(30))
        .save(path);
    
    writefln("#ymt plot: saved plot to <%s>", path);
}


