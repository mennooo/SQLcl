// file: add_install_command.js

// Runs on startup
var gCommand = "addobject";

// library to add a custom command
var command = load(config.baseDir + "lib/command.js");

// Library to install releases
var addobject = load(config.baseDir + "lib/addobject.js");


// Possible commands
// install list: list the possible releases
// install check <release>: check if the release complies
// install release <release> start the installation

command.add({
    command: gCommand,
    info: '\nCreate a new database object and open the file\n',
    actions: [{
            name: "package",
            action: addobject.package
        }
    ],
    begin: function() {},
    end: function() {}
});
