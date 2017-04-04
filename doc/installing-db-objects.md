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

## What do we need the script to do
- Collect all database objects in the release
- Check if the release complies with our demands
- Install the database objects in the correct schema
- Recompile invalid objects
- Create a logfile with a summary

## Lets transform this into required JavaScript Libraries
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
- file.js
- dbobject.js
- output.js
