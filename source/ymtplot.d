module ymtplot;

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
void dbPlot(in int period, in int typeID, in char periodGroupBy, in string path) {
    // check if basedir and db exist
    if(!ymtIsInit("plot")) {
        return;
    }

    // get data
    auto data = dbGetData(
        period, 
        typeID,
        periodGroupBy == 'y' ? "strftime('%Y', r.date)"
            : periodGroupBy == 'm' ? "strftime('%Y-%m', r.date)"
            : "strftime('%Y-%m-%d', r.date)"
    );

    // plotting
    import std.range: zip;
    import std.algorithm: map, maxElement;
    zip(data.dates, data.receiptValues)
        .map!(a => aes!("x", "y")(a[0], a[1]))
        .geomLine
        .putIn(GGPlotD())
        .put(yaxisRange(0, data.receiptValues.maxElement))
        .put(xaxisTextAngle(30))
        .save(path);
}

/++ Returns Dates and Receipt values

    Params:
        period = time period in days
        typeID = category ID
        periodGroupBy = dayily, monthly, yearly
    
    Returns: dbData { string[] dates; double[] receiptValues }
+/
private auto dbGetData(in int period, in int typeID, in string periodGroupBy) {
    struct dbData { string[] dates; double[] receiptValues; }

    // open db
    auto db = Database(basedir.buildPath(dbname));

    // prepare a query
    immutable query = 
            `SELECT %s as rdate, SUM(r.Receipt) as s FROM Receipt r 
                %s 
                %s 
             GROUP BY rdate ORDER BY rdate ASC
            `.format(
                periodGroupBy,
                (
                    period < 0 
                        ? "" 
                        : period == 0 
                            ? `WHERE r.date=CURRENT_DATE ` 
                            : `WHERE r.date>=strftime('%Y-%m-%d', datetime('now','-%s day')) AND r.date<=CURRENT_DATE `
                            .format(period)
                ), 
                (
                    typeID < 0 
                        ? "" 
                        : `WHERE r.TypeID=%s `
                        .format(typeID)
                )
            );

    // retreive all types
    dbData data;
    auto results = db.execute(query);
    foreach(row; results) {
        immutable tmp = row.peek!string(0);
        if(typeID > -1 && tmp.empty) {
            continue;
        }

        // save data
        data.dates ~= tmp.empty ? "N/A" : tmp;
        data.receiptValues ~= row.peek!double(1);
    }

    return data;
}


