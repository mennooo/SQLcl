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

loads: command.js, release.js

2: command.js

loads nothing

3: release.js

loads: file.js, dbobject.js and output.js

```javascript
// file: add_install_command.js

var release = loadWithGlobal("release.js");
var command = loadWithGlobal("command.js");

// Possible commands
// install list: list the possible releases
// install check <release>: check if the release complies
// install <release> start the installation

var cmd,
    release;

for (arg in arguments) {
  if (arg === 0) {
    command = arguments[0];
  }
  if (arg === 1) {
    release === arguments[1];
  }
}

if (command === "check") {
  release.check(release);
};



```

```javascript
// file: release.js

//var file = loadWithGlobal("file.js");
var dbobject = loadWithGlobal("dbobject.js");
var output = loadWithGlobal("output.js");

function check(release) {
  dbobject.check(release);
};

function install(release) {
  dbobject.install(release);
}
```
