/*

  debugapex: Live debugging of an APEX session

*/

(function() {

    var DBUtil = Java.type("oracle.dbtools.db.DBUtil"),
        DriverManager = Java.type("java.sql.DriverManager"),
        ScriptExecutor = Java.type("oracle.dbtools.raptor.newscriptrunner.ScriptExecutor"),
        Runnable = Java.type("java.lang.Runnable"),
        Thread = Java.type('java.lang.Thread'),
        conn2 = ctx.cloneCLIConnection(),
        sqlcl2 = new ScriptExecutor(conn2),
        util2 = DBUtil.getInstance(conn2);

    var output = load(config.baseDir + "lib/output.js"),
        server = load(config.baseDir + "lib/server.js"),
        gDebugLevels = {
            error: 1,
            warn: 2,
            info: 4
        },
        gThread,
        gSessionId,
        gDebugLevel,
        gStopMsg = "sqlcl:stop",
        gPageViewId,
        gCurrentPageViewId = 0,
        gAllowOutput = true,
        gPageViewIdentifier = "sqlcl:pageviewid=";

    function _setPageViewId(line){
      gCurrentPageViewId = Number(line.replace(gPageViewIdentifier, ""));
      // only output new debug lines
      print(gCurrentPageViewId, gPageViewId);
      if (gCurrentPageViewId > gPageViewId || !gPageViewId) {
        gPageViewId = gCurrentPageViewId;
        gAllowOutput = true;
      } else {
        gAllowOutput = false;
      }
    }

    function _monitor(sessionId) {

        var debugLine = util2.executeReturnOneCol("select apex_monitoring_pkg.receive(:sessionid) from dual", {
            sessionid: sessionId
        });

        print(debugLine)

        if (debugLine === gStopMsg){
          print("stopping the debug session", gSessionId);
          return;
        }

        if (debugLine.indexOf(gPageViewIdentifier) === 0){
          _setPageViewId(debugLine);
        } else {
          if (gAllowOutput) {
            //print(debugLine);
            server.websocket.send(debugLine + '\n');
          }
        }

        // recursive
        _monitor(sessionId);

    };

    function _setDebug(sessionId, debugLevel) {
        util2.execute("begin apex_monitoring_pkg.enable_debug(:session, :level); end;", {
            session: sessionId,
            level: debugLevel
        });

        print("\nDebug for session", sessionId, "is enabled at level", debugLevel);
    };

    function _send(sessionId, msg){
      util.execute("begin apex_monitoring_pkg.send(:text, :session); end;", {
          text: msg,
          session: sessionId
      });
    };

    function monitor(sessionArgs) {

        gSessionId = sessionArgs[0];
        gDebugLevel = sessionArgs[1];

        _setDebug(gSessionId, gDebugLevels[gDebugLevel]);

        gThread = new Thread(new Runnable() {
            run: function() {
                server.websocket.start(function() {
                    server.websocket.setAppend();
                    _monitor(gSessionId);
                });
            }
        });

        gThread.start();

    };

    function stop() {
      util.execute("begin apex_monitoring_pkg.disable_debug(:session); end;", {
          session: gSessionId
      });
      _send(gSessionId, gStopMsg);
      gPageViewId = null;
      server.websocket.stop("The debugging of session " + gSessionId + " has stopped.");
    };

    return {
        monitor: monitor,
        stop: stop
    }

})();
