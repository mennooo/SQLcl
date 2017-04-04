# The alias command
Purpose: make commonly used SQL statements available via an alias.

The alias command is persistent. This means when you start a new SQLcl session, it will load all your previously declared aliases.

Aliases are stored in your Application Data folder. For example:

`C:\Users\mhoogendijk\AppData\Roaming\sqlcl\aliases.xml`

## Create an alias

## import an alias
Purpose: Adding a new alias from an XML file

This allows you to add previously created aliases, maybe created by others.

alias load <alias.xml>



