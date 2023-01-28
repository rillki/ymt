<img src="imgs/money.png" width="64" height="64" align="left"></img>
# YTM
Your Money Tracker - a simple command line accounting utility. Download [precompiled](https://github.com/rillki/ymt/releases) binaries.

## Features
```
$ ymt help
ymt version 0.2.4 - Your Money Tracker.
i     init <dbname>  initializes a new database
r   remove <dbname>  removes an existing database
s   switch <dbname>  switches to the specified database
a      add [OPTIONS] use -h to read the usage manual on adding data
l     list [OPTIONS] use -h to read the usage manual on listing data
q    query [OPTIONS] use -h to read the usage manual on querying data
d describe [OPTIONS] use -h to read the usage manual on getting summary output
e   export [OPTIONS] use -h to read the usage manual on exporting data
p     plot [OPTIONS] use -h to read the usage manual on plotting data
c    clean           delete all data
v  version           display current version
h     help           this help manual

EXAMPLE: ymt init crow.db
```

## Dependencies
#### Linux and MacOS
You need `sqlite3` library. It comes preinstalled on macOS. But on Linux you need to install the `libsqlite3-dev` package. 

#### Windows
On Windows you need both `sqlite3` and `cairo` libraries. Both come with the `ymt` binary. You don't need to install anything.

## Build
```
dub build
```

Your will find the binary in the `bin/` folder. On Windows you need both the `ymt` binary and the `dll` libraries listed in `libs` folder. Put them along side each other.

## LICENSE
All code is licensed under the MIT license.
