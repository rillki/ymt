<img src="imgs/money.png" width="64" height="64" align="left"></img>
# YTM
Your Money Tracker - a simple command line accounting utility.

### Features
* Add data
* Remove data
* List data
* Query data
* Plotting [soon]

For a more detailed overview, run `ymt help`:
```
ymt version 0.1 - Your Money Tracker.
  init <dbname>  initializes a new database
remove <dbname>  removes an existing database
switch <dbname>  switches to the specified database
   add [OPTIONS] use -h to read the usage manual on adding data
  list [OPTIONS] use -h to read the usage manual on listing data
 query [OPTIONS] use -h to read the usage manual on querying data
 clean           delete all data
  help           this help manual

EXAMPLE: ymt init crow.db
```

### Dependencies
* `sqlite3`

### Build
Modify the `dub.json` configuration file to tell `DUB` where to find the `sqlite3` library:
```
"lflags": ["-L/usr/local/Cellar/sqlite/3.38.0/lib/"]
```

Modify the `lflags` section accordingly. Then build the project:
```
dub build --build=release
```

Your will find the binary in the `bin/` folder.

### LICENSE
All code is licensed under the MIT license.
