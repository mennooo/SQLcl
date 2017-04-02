# Content
- [SQLcl - Scripting](#sqlcl-scripting)
- [Configure SQLcl](#configure-sqlcl)
- [Testing Nashorn scripts with Netbeans IDE](#testing-nashorn-scripts-with-netbeans-ide)
- [Useful resources](#useful-resources)

# SQLcl - Scripting
Learn how to create custom scripts for SQLcl.

SQLcl allows you to execute scripts. The main reason is to extend its functionality and automate your tasks as developer. This way you can interact with both the Database and local files (such as Database Objects and SQL scripts)

You can use scripts in two ways:
1. Via the ```script``` command
2. Inside an ```alias```

This project shows you 
- a way to test your SQLcl scripts in Netbeans IDE
- Lots of examples

# Configure SQLcl

## login.sql

# Using the Script Command
You can load scripts and add them as custom commands.
In this section is you'll learn how to load and execute a script.

[Basic Nashorn scripts](doc/script.md)

# Using the Alias Command
Aliases are persistent (as opposed to scripts).
In this section is you'll learn how to create, import and execute an alias.

[Basic Nashorn scripts](doc/alias.md)

# Testing Nashorn scripts with Netbeans IDE

## Basic Nashorn scripts
In this section is you'll learn the basics of writing Nashorn scripts and how to install Netbeans EDI.

[Basic Nashorn scripts](doc/netbeans.md)

## Advanced Nashorn scripts to interact with the SQLcl libraries
In this section I've explored the way to test your SQLcl scripts without use of the commandline tool.

[Advanced Nashorn scripts for SQLcl](doc/netbeans-sqlcl.md)

# Useful resources
These are resources I found useful for preparing this project.

### OTN
- http://www.oracle.com/technetwork/developer-tools/sqlcl/overview/index.html

### Blogs
- http://krisrice.blogspot.com/
- http://www.thatjeffsmith.com/
- http://dermotoneill.blogspot.com/
- http://www.n-k.de/riding-the-nashorn/

### Examples
- https://github.com/mpkincai/sqlcl
- https://github.com/oracle/oracle-db-tools/tree/master/sqlcl
- https://github.com/oradoc/sqlcl

### Utilities
- https://github.com/vincentmorneau/apex-publish-static-files
