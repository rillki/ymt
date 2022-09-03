module ymtplot;

version(Windows) {} else {
    import std.array: array, empty;
    import std.string: capitalize;
    import std.format: format;
    import plt = matplotlibd.pyplot;

    import ymtcommon;

    void dbPlot(in int period, in int typeID, in string plotType, in bool[3] periodGroupBy, in string savepath) {
        // check if basedir and db exist
        if(!ymtIsInit("plot")) {
            return;
        }

        // get data
        auto data = dbGetData(
            period, 
            typeID,
            plotType,
            periodGroupBy[2] ? "strftime('%Y', r.date)"
                : periodGroupBy[1] ? "strftime('%Y-%m', r.date)"
                : "strftime('%Y-%m-%d', r.date)"
        );

        // add labels
        void addValueLabels(in string plotType, in double[] values) {
            foreach(i, value; values) {
                if(plotType == "barh") {
                    plt.text(value, i, value, ["va": "center"]);
                } else {
                    plt.text(i, value, value, ["ha": "center"]);
                }
            }
        }

        // plotting
        plt.figure(["figsize" :[15, 9]]);
        switch(plotType) {
            case "bar":
                plt.bar(data.dbX, data.dbY);
                break;
            case "barh":
                plt.barh(data.dbX, data.dbY);
                break;
            case "line":
                plt.plot(data.dbX, data.dbY);
                break;
            default:
                writefln("#ymt export: Unrecognized option %s!", plotType);
                break;
        }

        // add labels and save plot
        addValueLabels(plotType, data.dbY);
        plt.savefig(savepath);
        plt.clear();
    }

    private auto dbGetData(in int period, in int typeID, in string plotType, in string periodGroupBy) {
        // data
        struct dbData { string[] dbX; double[] dbY; }

        // check if basedir and db exist
        if(!ymtIsInit("export")) {
            return dbData();
        }

        // open db
        auto db = Database(basedir.buildPath(dbname));

        // prepare a query
        immutable query = (plotType == "line") ? 
                `SELECT ` ~ periodGroupBy ~ ` as rdate, SUM(r.Receipt) as s FROM Receipt r `
                ~ (period < 0 ? "" 
                    : period == 0 ? `WHERE r.date=CURRENT_DATE ` 
                    : `WHERE r.date>=strftime('%Y-%m-%d', datetime('now','-` 
                ~ `%s day')) AND r.date<=CURRENT_DATE `.format(period)) 
                ~ (typeID < 0 ? "" : `WHERE r.TypeID=%s `.format(typeID))
                ~ `GROUP BY rdate ORDER BY rdate ASC`
            : 
                `SELECT t.Type, SUM(r.Receipt) as s FROM Receipt r
                LEFT OUTER JOIN Type t on t.ID=r.TypeID `
                ~ (period < 0 ? "" 
                : period == 0 ? `WHERE r.date=CURRENT_DATE ` 
                : `WHERE r.date>=strftime('%Y-%m-%d', datetime('now','-` 
                ~ `%s day')) AND r.date<=CURRENT_DATE `.format(period)) 
                ~ (typeID < 0 ? "" : ` AND r.TypeID=%s `.format(typeID))
                ~ `GROUP BY t.Type ORDER BY s DESC`;

        // retreive all types
        dbData data;
        auto results = db.execute(query);
        foreach(row; results) {
            immutable tmp = row.peek!string(0);
            if(typeID > -1 && tmp.empty) {
                continue;
            }

            // save data
            data.dbX ~= tmp.empty ? "N/A" : tmp;
            data.dbY ~= row.peek!double(1);
        }

        return data;
    }
}


