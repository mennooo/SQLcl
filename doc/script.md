# The script command

For help in SQLcl type `help script`.

## Inline scripts
Although not very useful, it's the easiest way to execute a script.

1. Start SQLcl

```sql.exe /nolog```

2. Execute script

Type `script` and hit ENTER.
```
script 
ctx.write('My first script\n');
/
```
Output:
```
SQL> script
  2  ctx.write('My first script\n');
  3  /
My first script
SQL>
```
## External scripts
Command: `script <script name>`

## Relative filepaths


## Creating a custom command
SQLcl allows you to add custom commands. For instance:



A good example about how to create a script to add a custom command:
- [https://github.com/oracle/oracle-db-tools/blob/master/sqlcl/examples/customCommand.js](https://github.com/oracle/oracle-db-tools/blob/master/sqlcl/examples/customCommand.js)
