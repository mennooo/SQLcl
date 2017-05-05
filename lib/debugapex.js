/*

  debugapex: Live debugging of an APEX session

*/

(function() {

  var DBUtil  = Java.type("oracle.dbtools.db.DBUtil"),
      DriverManager = Java.type("java.sql.DriverManager"),
      ScriptExecutor  = Java.type("oracle.dbtools.raptor.newscriptrunner.ScriptExecutor"),
      Thread = Java.type('java.lang.Thread'),
      conn2  = ctx.cloneCLIConnection(),
      sqlcl2 = new ScriptExecutor(conn2),
      util2 = DBUtil.getInstance(conn2);

  function _monitor(workspaceId, sessionId){

    var debugLine = util.executeReturnOneCol("select apex_monitoring.receive(:workspace, :session) from dual", {
      workspace: workspaceId,
      session: sessionId
    });

    print(debugLine);

    // recursive
    monitor(workspaceId, sessionId);

  };

  function monitor(sessionArgs) {
    // EXAMPLE 2 - Thread Only
    new Thread(function () {
        _monitor(sessionArgs[0], sessionArgs[1]);
    }).start();
  };

  return {
    monitor: monitor
  }

})();
