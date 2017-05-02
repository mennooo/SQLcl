/*

  Demo for redirecting output to a string

*/

var BufferedOutputStream = Java.type('java.io.BufferedOutputStream'),
    ByteArrayOutputStream = Java.type('java.io.ByteArrayOutputStream'),
    Charsets = Java.type('java.nio.charset.StandardCharsets'),
    byteOutputStream,
    bufferedOutputStream,
    output;

byteOutputStream = new ByteArrayOutputStream(Charsets.UTF_8);
bufferedOutputStream = new BufferedOutputStream(byteOutputStream);

sqlcl.setOut(bufferedOutputStream);

sqlcl.setStmt("apex export 100");
sqlcl.run();

bufferedOutputStream.flush();

output = byteOutputStream.toString();

//print(output);
