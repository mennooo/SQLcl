# Example: Installing database objects (via the script command)

Purpose:

In an OTAP environment, we want to automate the task of installing database object of a release.

A release could include:
- packages
- views
- triggers
- functions
- procedures
- synonyms
- types

Our demands:
- the filename of the object should correspond with the object name
- the version of the db object should be equal or higher than the current version

Not in the scope:
- ALTER statements
- DML statements
- Install APEX apps and JavaScript/CSS files

## What do we need the script to do
- Add to SQLcl as custom command
- Collect all database objects in the release
- Check if the release complies with our demands
- Install the database objects in the correct schema
- Recompile invalid objects
- Create a logfile with a summary

## Lets transform this into required JavaScript Libraries

### Add to SQLcl as custom command
command.js: Register a custom command

### Collect all database objects in the release
file.js: collect all files in release directory

### Check if the release complies with our demands
dbobject.js: Perform checks on file content

### Install the database objects in the correct schema

This can be done with common SQLcl: `@<filename>`

### Recompile invalid objects
Execute statement: `dbms_utility.compile_schema`

### Create a logfile with a summary
output.js: Redirect OutputStream to a logfile

So we need three JavaScript libraries to create this script:
- command.js
- file.js
- dbobject.js
- output.js

## The script

I've chosen to work in several layers. This keeps things nice and tidy.

1: add_install_command.js

Purpose: configure the 'install' command for SQLcl

2: command.js

Purpose: adds a new custom command

3: releases.js

Purpose: list all posible releases to install

4: release.js

Purpose: code to install a release

```javascript
// file: add_install_command.js

// Runs on startup

va gCommand = "install";

var releases = loadWithGlobal("releases.js");
var release = loadWithGlobal("release.js");
var command = loadWithGlobal("command.js", ctx);

// Possible commands
// install list: list the possible releases
// install check <release>: check if the release complies
// install release <release> start the installation

command.add({
  handle: {
    command: gCommand,
    actions: [
        "list": releases.list
        "check": release.check
        "release": release.install
    ]
  }
});


```

```javascript
// file: release.js

(function() {

    var dbobject = loadWithGlobal("dbobject.js");
    var output = loadWithGlobal("output.js");

    function check(release) {
      dbobject.check(release);
    };

    function install(release) {
      dbobject.install(release);
    }

})();

```
