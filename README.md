<img src="imgs/money.png" width="64" height="64" align="left"></img>
# YTM
Your Money Tracker - a simple command line accounting utility. Download [precompiled](https://github.com/rillki/ymt/releases) binaries.

### Features
```
$ ymt help
ymt version 0.2 - Your Money Tracker.
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
* `sqlite3`
* `python3` + `pandas, numpy, matplotlib` packages

The `sqlite3` library comes preinstalled on macOS. On Linux you need to install the `libsqlite3-dev` package. Don't forget to install `python3` and its packages. 

YMT uses the DUB `d2sqlite3` binding to `sqlite3` C library to communicate with a database, `matplotlib-d`package to plot data and the `xlsxd` excel writer package to export data to an EXCEL file.

### Build
```
dub build --build=release
```

Your will find the binary in the `bin/` folder.

Currently only macOS and Linux platforms have a build configuration. My Windows build configuration fails to build the utility. Try to build it yourself and please report back upon success!!! Read more [here](https://github.com/koji-kojiro/matplotlib-d).

### LICENSE
All code is licensed under the MIT license.
