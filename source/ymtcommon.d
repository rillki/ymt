module ymtcommon;

import d2sqlite3: Database, ResultRange;
import std.stdio: writefln;
import std.path: expandTilde, buildPath;
import std.file: readText, exists;
import std.process: env = environment;
import std.string: strip;

public enum YMT_VERSION = "0.2.5";
public enum configFile = "ymt.config";
public enum checkTypeExistsQuery = q{
    SELECT EXISTS(
        SELECT 1 FROM Receipts WHERE Type = "%s"
    ) as Result
};
public enum checkNameExistsQuery = q{
    SELECT EXISTS(
        SELECT 1 FROM Receipts WHERE Name = "%s"
    ) as Result
};

public string basedir;
public string dbname;

static this() {
    version(Windows) {
        basedir = env.get("USERPROFILE", "C:\\Users\\Public").buildPath(".ymt");
    } else {
        basedir = env.get("HOME", "~".expandTilde).buildPath(".ymt");
    }

    dbname = basedir.exists ? basedir.buildPath(configFile).readText.strip : "";
}

/++ Check if YMT was initialized

    Params:
        cmd = command that was used (needed for error output)

    Returns: `true` is YMT was initialized
 +/
bool ymtIsInit(in string cmd) {
    // check if basedir exists
    if(!basedir.exists) {
        writefln("#ymt %s: error! Initialize ymt first!", cmd);
        return false;
    }

    // check if db exists
    if(!basedir.buildPath(dbname).exists) {
        writefln("#ymt %s: error! %s does not exist, you need to initialize one!", cmd, dbname);
        return false;
    }

    return true;
}

private Database db;

/++ Executes a DB query 

    Params:
        query = SQL query
        db_name = database name

    Note: if `db_name` not provided, uses the global `dbname`
+/
void dbRun(in string query, in string db_name = null) {
    // open DB if it's the first time
    if(db == db.init) {
        db = Database(basedir.buildPath(db_name is null ? dbname : db_name));
    }

    // execute query
    db.run(query);
}

/++ Executes a DB query and returns the result 

    Params:
        query = SQL query

    Returns: `ResultRange`
+/
ResultRange dbExecute(in string query) {
    // open DB if it's the first time
    if(db == db.init) {
        db = Database(basedir.buildPath(dbname));
    }

    // execute query
    return db.execute(query);
}

/++ Writes data to file

    Params:
        filename = filename
        data = data to write to file in one go
+/
void fileWrite(in string filename, in string data) {
    import std.stdio: File;
    auto file = File(filename, "w");
    file.write(data);
    file.close();
}

