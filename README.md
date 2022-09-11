<img src="imgs/money.png" width="64" height="64" align="left"></img>
# YTM
Your Money Tracker - a simple command line accounting utility. Download [precompiled](https://github.com/rillki/ymt/releases) binaries.

## Features
```
$ ymt help
ymt version 0.2.3 - Your Money Tracker.
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

## Dependencies
#### Linux and MacOS
* `sqlite3`
* `python3` + `pandas, numpy, matplotlib` packages

The `sqlite3` library comes preinstalled on macOS. On Linux you need to install the `libsqlite3-dev` package. Python and its packages are used for plotting.

#### Windows
On Windows you need `sqlite3` and `cairo` libraries. Both come with the `ymt` binary. You don't need to install anything. For plotting on Windows the `ggplotd` DUB package is used instead of `matplotlib-d`.

## Build
```
dub build --build=release
```

Your will find the binary in the `bin/` folder. On Windows you need both the `ymt` binary and the `dll` libraries listed in `libs` folder. Put them along side each other.

### Note
`ymt` supports macOS, Linux and Windows 10. However, since my Windows 10 build configuration fails to build the `xlsxwriter` utility, exporting data from database is unavailable. Everything else functions as normal.

## LICENSE
All code is licensed under the MIT license.
