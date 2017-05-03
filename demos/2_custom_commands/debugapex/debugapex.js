ctx.setSubstitutionOn(true);
var answer=null;

var File = Java.type("java.io.File");
var path = new File('C:\\Users\\hoogeme\\stack\\presentation\\sqlcl\\mennno.log');
var DBUtil  = Java.type("oracle.dbtools.db.DBUtil");
var DriverManager = Java.type("java.sql.DriverManager");
var ScriptExecutor  = Java.type("oracle.dbtools.raptor.newscriptrunner.ScriptExecutor");

var jdbc = conn.getMetaData().getURL();
var user = 'twqb7';
var pass = 'twqb7';

DBUtil.getInstance(conn);



out.setFileOutput(path);

out.write('test');
out.flush();

function receive_debug() {
  /*var conn2  = DriverManager.getConnection(jdbc,user,pass);
  var sqlcl2 = new ScriptExecutor(conn2);

  var util2 = DBUtil.getInstance(conn2);*/

  var debugLine = util.executeReturnOneCol('select apex_monitoring.receive(\'TVTTwinq\', 16502172028830) from dual');
  print(debugLine)
  return debugLine;
  receive_debug();
}

var line = receive_debug();

while (typeof line == "string" && line.length > 0) {
  print(line);
  line = receive_debug();
}
