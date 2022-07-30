module ymtcommon;

public {
    import d2sqlite3: Database;
    import std.stdio: writefln;
    import std.path: expandTilde, buildPath;
    import std.file: readText, exists;

    enum YMT_VERSION = "0.1";
    enum configFile = "ymt.config";

    string basedir;
    string dbname;
    static this() {
        version(Windows) {
            //
        } else {
            basedir = "~/.ymt".expandTilde;
            dbname = basedir.exists ? basedir.buildPath(configFile).readText : "";
        }
    }
}

/// Writes data to file
void fileWrite(in string filename, in string data) {
    import std.stdio: File;
    auto file = File(filename, "w");
    file.write(data);
    file.close();
}

