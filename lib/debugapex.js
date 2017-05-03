/*

  debugapex: Live debugging of an APEX session

*/



  ctx.setSubstitutionOn(true);

  var DBUtil  = Java.type("oracle.dbtools.db.DBUtil"),
      DriverManager = Java.type("java.sql.DriverManager"),
      ScriptExecutor  = Java.type("oracle.dbtools.raptor.newscriptrunner.ScriptExecutor"),
      Thread = Java.type('java.lang.Thread'),
      conn2  = ctx.cloneCLIConnection(),
      sqlcl2 = new ScriptExecutor(conn2),
      util2 = DBUtil.getInstance(conn2);

  function debug(user, sessionId){

    var debugLine = util.executeReturnOneCol("select apex_monitoring.receive('" + user + "', " + sessionId + ") from dual");

    print(debugLine);

    // recursive
    debug(user, sessionId);

  };



  // EXAMPLE 2 - Thread Only
  new Thread(function () {
      debug(args[1], args[2]);
  }).start();
