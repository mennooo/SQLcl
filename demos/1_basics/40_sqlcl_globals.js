/*

  SQLcl gives you four global objects to use:
  - args (user arguments)
  - sqlcl (run statements)
  - ctx (writing output)
  - util (getting values from the database)

*/

print("printing your arguments..")
for (idx in args){
  print("argument " + idx + " " + args[idx]);
}

print("Object sqlcl resides in: " + sqlcl.getClass());
print("Object ctx resides in: " + ctx.getClass());
print("Object util resides in: " + util.getClass());
