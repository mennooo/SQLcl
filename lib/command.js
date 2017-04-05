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
    var actionArgs = args.slice(2);
    return actionArgs;
  };

  function add(newCommand){

    var commandSettings = {
      command: "customcommand",
      info: "This is a custom command\n",
      actions: [],
      begin: function() {},
      end: function() {}
    };

    // Extend settings with options
    if (typeof newCommand === "undefined") {
      newCommand = {};
    }
    for (obj in commandSettings) {
        if (newCommand.hasOwnProperty(obj)){
            commandSettings[obj] = newCommand[obj];
        }
    }

    // Broke the .js out from the Java.extend to be easier to read
    var cmd = {};

    // Called to attempt to handle any command
    cmd.handle = function (conn,ctx,cmd) {

      var args = getArgs(cmd.getSql().trim());

      // Check that the command is what we want to handle
      if ( getCommand(args) === commandSettings.command ){

        var action = getAction(args);

        for (i = 0; i < commandSettings.actions.length; i++) {
          if (commandSettings.actions[i].name === action){
            commandSettings.actions[i].action(getActionArguments(args));
            return true;
          }
        }

        // Add action to display info if no action speficied
        ctx.write(commandSettings.info);

        // return TRUE to indicate the command was handled
        return true;
      }
      // return FALSE to indicate the command was not handled
      // and other commandListeners will be asked to handle it
      return false;
    }

    // fired before ANY command
    cmd.begin = function (conn,ctx,cmd) {
       commandSettings.begin();
    }

    // fired after ANY Command
    cmd.end = function (conn,ctx,cmd) {
       commandSettings.end();
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
