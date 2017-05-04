// file: add_install_command.js

// Runs on startup
var gCommand = "debugapex";

// library to add a custom command
var command = load(config.baseDir + "lib/command.js");

// Library to install releases
var release = load(config.baseDir + "lib/release.js");


// Possible commands
// install list: list the possible releases
// install check <release>: check if the release complies
// install release <release> start the installation

command.add({
    command: gCommand,
    info: '\nDebug APEX sessions\nThe following commands are available:\nTo debug a session: debugapex <username> <session_id>\n\n',
    actions: [{
            name: "list",
            action: release.listAll
        },
        {
            name: "check",
            action: release.check
        },
        {
            name: "release",
            action: release.install
        },
        {
          name: "dir",
          action: release.setBaseDir
        }
    ],
    begin: function() {},
    end: function() {}
});
