# Testing SQLcl scripts with Netbeans IDE 8.2

You can test SQLcl scripts with Netbeans without using the commandline tool.

## 

* [Requirements](#requirements)
* [Add SQLcl JAR files](#add-sqlcl-jar-files)
* [Test](#test)

## Requirements
Make sure you have created a new project as described here.

[Testing Nashorn scripts with Netbeans IDE 8.2](netbeans.md)

Download and extract SQLcl.

http://www.oracle.com/technetwork/developer-tools/sqlcl/downloads/index.html

## Add SQLcl JAR files
We need to add the SQLcl JAR files to our project.
Rightclick **Libraries** and select **Add JAR/Folder**.

![Add SQLcl libraries](../img/add_jars.png)

Go to the folder where you unzipped SQLcl and select all JAR files.

![Add SQLcl libraries](../img/select_jars.PNG)

## Test 
Add this line in your JavaScript file and replace the options with your database connection details:

```javascript
loadWithNewGlobal(
    "https://raw.githubusercontent.com/mennooo/sqlcl/master/demos/demo1.js", 
    {
        sid: "ORCL",
        host: "localhost",
        port: "1521",
        username: "hr",
        password: "hr"
    }
);
```
