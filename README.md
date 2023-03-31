<img src="imgs/money.png" width="64" height="64" align="left"></img>
# YTM
Your Money Tracker - a simple command line accounting utility. Download [precompiled](https://github.com/rillki/ymt/releases) binaries.

## Features
```
$ ymt help
ymt version 0.2.5 - Your Money Tracker.
i     init  <dbname> initializes a new database
r   remove  <dbname> removes an existing database
s   switch  <dbname> switches to the specified database
a      add [OPTIONS] use -h to read the usage manual on adding data
l     list [OPTIONS] use -h to read the usage manual on listing data
q    query [OPTIONS] use -h to read the usage manual on querying data
d describe [OPTIONS] use -h to read the usage manual on getting summary output
p     plot [OPTIONS] use -h to read the usage manual on plotting data
e   export [OPTIONS] use -h to read the usage manual on exporting data
m   import [OPTIONS] use -h to read the usage manual on importing data
c    clean           delete all data
v  version           display current version
h     help           this help manual

EXAMPLE: ymt init crow.db
```

## Dependencies
You need to install `sqlite3` and `cairo` libraries. 

#### Linux
```
sudo apt install libsqlite3-dev
sudo apt install libcairo2-dev
```

#### MacOS
`sqlite3` comes preinstalled on macOS. You only need to install `cairo` using brew package manager:
```
brew install cairo
```

#### Windows
Both `sqlite3` and `cairo` libraries come with the `ymt` binary. You don't need to install anything. Find the `ddl` libraries in the `libs` folder and put them into the same folder as your `ymt` binary.

## Build
```
dub build
```

## LICENSE
All code is licensed under the MIT license.
