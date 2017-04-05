// SQLCL's Command Registry
var CommandRegistry = Java.type("oracle.dbtools.raptor.newscriptrunner.CommandRegistry");

// CommandListener for creating any new command
var CommandListener =  Java.type("oracle.dbtools.raptor.newscriptrunner.CommandListener");

(function(){

  function getArgs(argString){
    return argString.split(" ");
  };

  function getCommand(args){
    return args[0];
  };

  function getAction(args){
    return args[1];
  };

  function getActionArguments(args){
    return args.shift();
  };

  function add(newCommand){
    // Broke the .js out from the Java.extend to be easier to read
    var cmd = {};

    // Called to attempt to handle any command
    cmd.handle = function (conn,ctx,cmd) {

      var args = getArgs(cmd.getSql().trim());

      // Check that the command is what we want to handle
      if ( getCommand(args) === newCommand.command ){

        var action = getAction(args);

        for (i = 0; i < newCommand.actions.length; i++) {
          if (newCommand.actions[i].name === action){
            newCommand.actions[i].action(getActionArguments(args));
            return true;
          }
        }

        // Add action to display info if no action speficied
        ctx.write(newCommand.info);

        // return TRUE to indicate the command was handled
        return true;
      }
      // return FALSE to indicate the command was not handled
      // and other commandListeners will be asked to handle it
      return false;
    }

    for (obj in newCommand){
      print(obj)
    }

    // fired before ANY command
    cmd.begin = function (conn,ctx,cmd) {
       //newCommand.begin();
    }

    // fired after ANY Command
    cmd.end = function (conn,ctx,cmd) {
       //newCommand.end();
    }

    // Actual Extend of the Java CommandListener

    var MyCmd2 = Java.extend(CommandListener, {
    		handleEvent: cmd.handle,
        beginEvent: cmd.begin,
        endEvent: cmd.end
    });

    // Registering the new Command
    CommandRegistry.addForAllStmtsListener(MyCmd2.class);

  };

  return {
    getCommand: getCommand,
    getActionArguments: getActionArguments,
    add: add
  }

})();
