// file: add_install_command.js

// Runs on startup
var gCommand = "install";

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
    info: '\nInstall new releases. The following commands are available:\nTo set the base directory: install dir <base_dir>\nTo list all releases: install list\nTo install a release: install release <release>\nTo validate an install: install check <release>\n\n',
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
