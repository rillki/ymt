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

