# Exploring the Java Libraries

SQLcl is a bundle of JAR files. These JAR files contain all the Java code to run SQLsl.

In our scripts, we can refer to the Java Classes and use their methods:

```javascript
// Load the class
var StringUtils = Java.type("oracle.dbtools.common.utils.StringUtils");

print(StringUtils.initCapSingle("sqlcl is awesome"));
// Result: Sqlcl is awesome
```

You can use these tools to open and explore the JAR files:
- [Netbeans IDE](https://netbeans.org/downloads/)
- [Java Decompiler](http://jd.benow.ca/)

It's pretty cool to have a look inside but only a couple of classes and methods are worth mentioning. Most of the tasks we want our script to do can be done with the globals provided by SQLcl.

# Globals

These objects are globally exposed in SQLcl.

More info:
- [https://github.com/oracle/oracle-db-tools/tree/master/sqlcl](https://github.com/oracle/oracle-db-tools/tree/master/sqlcl)

You can get the corresponding class with this JavaScript command:

```javascript
print(sqlcl.getClass());
print(ctx.getClass());
print(util.getClass());
```

## sqlcl

`oracle.dbtools.raptor.newscriptrunner.ScriptExecutor`

Located in **oracle.dbtools-common.jar**

## ctx

`oracle.dbtools.raptor.newscriptrunner.ScriptRunnerContext`

Located in **oracle.dbtools-common.jar**


## util

`oracle.dbtools.db.OracleUtil`

Located in **oracle.dbtools-common.jar**

# Other Java Types

## java.io.File
Purpose: Dealing with the filesystem
- Read directories
- Get file properties

Docs: [https://docs.oracle.com/javase/8/docs/api/java/io/File.html](https://docs.oracle.com/javase/8/docs/api/java/io/File.html)

- [file.js] (../blob/master/lib/file.js)

## java.io.FileReader
Purpose: Reading file contents

Docs: [https://docs.oracle.com/javase/8/docs/api/java/io/FileReader.html](https://docs.oracle.com/javase/8/docs/api/java/io/FileReader.html)

- oracle.dbtools.common.utils.FileUtils
Purpose: File utilities for SQLcl
- Useful to get the current working directory

```javascript
var FileUtils = Java.type("oracle.dbtools.common.utils.FileUtils");
var cwd = FileUtils.getCWD(ctx);
```

## java.sql.DriverManager
Purpose: JDBC connections
- Useful to get a JDBC connection

```javascript
var DriverManager = Java.type("java.sql.DriverManager");

// Create a new connection to use for monitoring
// Grab the connect URL from the base connection in sqlcl
var jdbc = conn.getMetaData().getURL();
var user = 'hr';
var pass = 'hr';

//connect
var conn2 = DriverManager.getConnection(jdbc,user,pass);
```

## oracle.dbtools.raptor.newscriptrunner.CommandRegistry
Purpose: Adding custom commands to SQLcl

- [https://github.com/oracle/oracle-db-tools/blob/master/sqlcl/examples/customCommand.js](https://github.com/oracle/oracle-db-tools/blob/master/sqlcl/examples/customCommand.js)

## oracle.dbtools.raptor.newscriptrunner.CommandListener
Purpose: Listening for custom commands in SQLcl

See above
