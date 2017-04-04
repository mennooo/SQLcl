# Exploring the Java Libraries

SQLcl is a bundle of JAR files. These JAR files contain all the Java code to run SQLsl.

In our scripts, we can refer to the Java Classes (via `Java.type()`) and use their methods:

```javascript
// Load the class
var StringUtils = Java.type("oracle.dbtools.common.utils.StringUtils");

print(StringUtils.initCapSingle("sqlcl is awesome"));
// Result: Sqlcl is awesome
```

You can use these tools to open and explore the JAR files:
- [Netbeans IDE](https://netbeans.org/downloads/)
- [Java Decompiler](http://jd.benow.ca/)

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

- java.io.File
- java.io.FileReader
- oracle.dbtools.common.utils.FileUtils
- java.sql.DriverManager
- oracle.dbtools.raptor.newscriptrunner.CommandRegistry
- oracle.dbtools.raptor.newscriptrunner.CommandListener
- java.util.zip.GZIPOutputStream

