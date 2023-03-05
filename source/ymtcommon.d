module ymtcommon;

import d2sqlite3: Database, ResultRange;
import std.stdio: writefln;
import std.path: expandTilde, buildPath;
import std.file: readText, exists;
import std.process: env = environment;

public enum YMT_VERSION = "0.2.4";
public enum configFile = "ymt.config";
public enum checkTypeExistsQuery = q{
    SELECT EXISTS(
        SELECT 1 FROM Name WHERE Name = "%s"
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

    dbname = basedir.exists ? basedir.buildPath(configFile).readText : "";
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
+/
void dbRun(in string query) {
    if(!ymtIsInit("__internal_operation__")) {
        return;
    }

    // open DB if it's the first time
    if(db == db.init) {
        db = Database(basedir.buildPath(dbname));
    }

    // execute query
    db.run(query);
}

/++ Executes a DB query and returns the result 

    Params:
        query = SQL query

    Returns: ResultRange
+/
ResultRange dbExecute(in string query) {
    if(!ymtIsInit("__internal_operation__")) {
        return ResultRange.init;
    }

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

