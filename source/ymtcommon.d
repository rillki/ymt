module ymtcommon;

public {
    import d2sqlite3: Database;
    import std.stdio: writefln;
    import std.path: expandTilde, buildPath;
    import std.file: readText, exists;
    import std.process: env = environment;

    enum YMT_VERSION = "0.2.1";
    enum configFile = "ymt.config";

    string basedir;
    string dbname;
    static this() {
        version(Windows) {
            basedir = env.get("HOMEPATH", "PUBLIC").buildPath(".ymt");
        } else {
            basedir = env.get("HOME", "~".expandTilde).buildPath(".ymt");
        }

        dbname = basedir.exists ? basedir.buildPath(configFile).readText : "";
    }

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
}

/// Writes data to file
void fileWrite(in string filename, in string data) {
    import std.stdio: File;
    auto file = File(filename, "w");
    file.write(data);
    file.close();
}

