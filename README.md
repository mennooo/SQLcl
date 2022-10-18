# Content
- [SQLcl - Scripting](#sqlcl-scripting)
- [Configure SQLcl](#configure-sqlcl)
- [Using the Script Command](#using-the-script-command)
- [Using the Alias Command](#using-the-alias-command)
- [Testing Nashorn scripts with Netbeans IDE](#testing-nashorn-scripts-with-netbeans-ide)
- [Exploring the Java Libraries](#exploring-the-java-libraries)
- [Real-world examples](#real-world-examples)
- [Useful resources](#useful-resources)

# SQLcl - Scripting
Learn how to create custom scripts for SQLcl.

SQLcl allows you to execute scripts. The main reason is to extend its functionality and automate your tasks as developer. This way you can interact with both the Database and local files (such as Database Objects and SQL scripts)

The JavaScript Engine for SQLcl is Oracle Nashorn.

You can use scripts in two ways:
1. Via the ```script``` command
2. Inside an ```alias```

This project shows you:
- a way to test your SQLcl scripts in Netbeans IDE
- Lots of examples for `script` and `alias` commands

Download SQLcl at:
- [http://www.oracle.com/technetwork/developer-tools/sqlcl/overview/index.html](http://www.oracle.com/technetwork/developer-tools/sqlcl/overview/index.html)

# Configure SQLcl

## Add to PATH
In order to use SQLcl from the command-line in any given directory, you need to add the `sqlcl/bin` folder to the PATH variable. 

## login.sql
The login.sql and glogin.sql scripts are executed when you start SQLcl.
This is the place where you load your SQLcl scripts at startup.

```sql
SET sqlprompt "_user'@'_connect_identifier > "
SET sqlformat ansiconsole

-- Load script
cd D:\sqlcl\scripts
script helloworld.js
```

More info:
- [http://www.adp-gmbh.ch/ora/sqlplus/login.html](http://www.adp-gmbh.ch/ora/sqlplus/login.html)
- [http://www.talkapex.com/2015/05/sqlcl-and-loginsql/](http://www.talkapex.com/2015/05/sqlcl-and-loginsql/)

# Using the Script Command
You can load scripts and add them as custom commands. 

Purpose: perfect for automating developer tasks.

In this section is you'll learn how to load and execute a script.

- [The script command](doc/script.md)

# Using the Alias Command
Aliases are persistent (as opposed to scripts).

Purpose: perfect for creating shortcuts for SQL statements.

In this section is you'll learn how to create, import/export and execute an alias.

- [The alias command](doc/alias.md)

# Testing Nashorn scripts with Netbeans IDE

It can be a lot quicker to write and test Nashorn scripts with Netbeans IDE. The advantage is that you don't have to save and rerun your script in SQLcl everytime. It also provides debugging options.

The Nashorn JavaScript engine is included in Java JDK 8.

## Basic Nashorn scripts
In this section is you'll learn the basics of writing Nashorn scripts and how to install Netbeans EDI.

- [Basic Nashorn scripts](doc/netbeans.md)

## Advanced Nashorn scripts to interact with the SQLcl libraries
In this section I've explored the way to test your SQLcl scripts without use of the command-line tool.

- [Advanced Nashorn scripts for SQLcl](doc/netbeans-sqlcl.md)

# Exploring the Java Libraries
SQLcl offers tons of methods in its Java Libraries. In advanced scripts, you might want to use some of them.

In this section I've explored some relevant methods of the Java types.

- [Exploring the Java Libraries](doc/java-libraries.md)

# Real-world examples
Here are some examples to demostrate the power of SQLcl combined with scripts

## Example: Installing database objects (via the script command)
I'm actually using this script at my client to automate the installation of database objects in an OTAP environment.

In this section I've explained the way to use this custom command.

- [Example: installing database objects](doc/installing-db-objects.md)

## Example: Realtime APEX monitoring (via the alias command)
Let SQLcl output your debug & error messages while running an APEX app.

In this section I've explained the way to use this alias.

- [Example: APEX monitoring](doc/apex-monitoring.md)

# Useful resources
These are resources I found useful for preparing this project.

### OTN
- http://www.oracle.com/technetwork/developer-tools/sqlcl/overview/index.html
- http://docs.oracle.com/database/sql-developer-4.2/SQCQR/toc.htm

### Blogs
- http://krisrice.blogspot.com/
- http://www.thatjeffsmith.com/
- http://dermotoneill.blogspot.com/
- http://www.n-k.de/riding-the-nashorn/
- https://www.scaler.com/topics/sql/

### Examples
- https://github.com/mpkincai/sqlcl
- https://github.com/oracle/oracle-db-tools/tree/master/sqlcl
- https://github.com/oradoc/sqlcl

### Utilities
- https://github.com/vincentmorneau/apex-publish-static-files
