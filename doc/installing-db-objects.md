# Example: Installing database objects (via the script command)

Purpose:

In an OTAP environment, we want to automate the task of intalling database object of a release.

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
