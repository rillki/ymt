<img src="imgs/money.png" width="64" height="64" align="left"></img>
# YTM
Your Money Tracker - a simple command line accounting utility.

### Features
```
$ ymt help
ymt version 0.1 - Your Money Tracker.
i     init <dbname>  initializes a new database
r   remove <dbname>  removes an existing database
s   switch <dbname>  switches to the specified database
a      add [OPTIONS] use -h to read the usage manual on adding data
l     list [OPTIONS] use -h to read the usage manual on listing data
q    query [OPTIONS] use -h to read the usage manual on querying data
e   export [OPTIONS] use -h to read the usage manual on exporting data
d describe [OPTIONS] use -h to read the usage manual on getting summary output
p     plot [OPTIONS] use -h to read the usage manual on plotting data
c    clean           delete all data
v  version           display current version
h     help           this help manual

EXAMPLE: ymt init crow.db
```

### Dependencies
YMT uses the DUB `d2sqlite3` binding to `sqlite3` C library. Make sure you have `sqlite3` installed on your system.

Note: I'll soon add proper support for Windows and Linux platforms as well. Alternatively, you could adjust the dub.json file yourself down below.

### Build
Modify the `dub.json` configuration file to tell `DUB` where to find the `sqlite3` library:
```
"lflags": ["-L/usr/local/Cellar/sqlite/3.38.0/lib/"]
```

Then build the project:
```
dub build --build=release
```

Your will find the binary in the `bin/` folder.

### LICENSE
All code is licensed under the MIT license.
