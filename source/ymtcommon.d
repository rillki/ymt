module ymtcommon;


public {
    import d2sqlite3: Database;
    import std.path: expandTilde;

    enum YMT_VERSION = "0.1";
    enum configFile = "ymt.config";

    string basedir;
    static this() {
        version(Windows) {
            //
        } else {
            basedir = "~/.ymt".expandTilde;
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

