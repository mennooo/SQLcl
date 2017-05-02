/*

  Demo for redirecting output to something else

*/

var BufferedOutputStream = Java.type('java.io.BufferedOutputStream'),
    FileOutputStream = Java.type('java.io.FileOutputStream');


sqlcl.setOut(new BufferedOutputStream(new FileOutputStream('D:/f100.sql')));

sqlcl.setStmt("apex export 100");
sqlcl.run();
