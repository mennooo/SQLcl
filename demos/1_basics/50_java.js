var System = Java.type('java.lang.System');

var username = System.getProperty("user.name");

ctx.write('Hello ' + username + '\n');
