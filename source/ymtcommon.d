module ymtcommon;

public {
	import d2sqlite3: Database;
    import std.path: expandTilde;

    version(Windows) {
        //
    } else {
        enum basedir = "~/.ymt";
    }
    
	enum YMT_VERSION = "0.1";
	enum configFile = "ymt.config";
}

