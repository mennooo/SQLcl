/* 
 
 Library to start a connection to an Oracle Database
 
 */


/* global Java */


var output = loadWithNewGlobal("https://github.com/mennooo/sqlcl/blob/master/lib/output.js");

(function() {
    
    
    // Java types required to create a connection
    var ScriptRunnerContext = Java.type('oracle.dbtools.raptor.newscriptrunner.ScriptRunnerContext'),
        ScriptExecutor = Java.type('oracle.dbtools.raptor.newscriptrunner.ScriptExecutor'),
        DriverManager = Java.type('java.sql.DriverManager'),
        DBUtil = Java.type('oracle.dbtools.db.DBUtil'),
        SqlCli = Java.type('oracle.dbtools.raptor.scriptrunner.cmdline.SqlCli');
        
    
    function init(options) {
        
        var settings = {
          host: 'localhost',
          port: 1521,
          sid: '',
          username: '',
          password: ''
        };
        
        // Extend settings with options
        for (obj in settings) {
            if (options.hasOwnProperty(obj)){
                settings[obj] = options[obj];
            }
        }
        
        // Generate jdbc connection url
        var url = "jdbc:oracle:thin:@" + settings.host + ":" + settings.port + ":" + settings.sid;
        
        // Create a connection
        var ctx = new ScriptRunnerContext(),
            cli = new SqlCli(),
            conn = DriverManager.getConnection(url, settings.username, settings.password),
            util = DBUtil.getInstance(conn),
            sqlcl = new ScriptExecutor(conn);

        // Attach context to scriptExecutor
        sqlcl.setScriptRunnerContext(ctx);
        ctx.consumerRuning(true);
        
        // Set default output
        output.setDefaultOutput(ctx);
        
        // Only return useful objects on initialization
        return {
            ctx: ctx,
            util: util,
            sqlcl: sqlcl
        };
    }

    // Return function to initialize a connection
    return {
        init: init
    };

})();
