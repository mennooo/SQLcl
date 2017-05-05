// file: add_install_command.js

// Runs on startup
var gCommand = "debugapex";

// library to add a custom command
var command = load(config.baseDir + "lib/command.js");

// Library to install releases
var debugapex = load(config.baseDir + "lib/debugapex.js");


// Possible commands
// install list: list the possible releases
// install check <release>: check if the release complies
// install release <release> start the installation

command.add({
    command: gCommand,
    info: '\nDebug APEX sessions\nThe following commands are available:\nTo debug a session: debugapex monitor <username> <session_id>\n\n',
    actions: [{
            name: "monitor",
            action: debugapex.monitor
        }
    ],
    begin: function() {},
    end: function() {}
});
