// file: add_install_command.js

// Runs on startup

var gCommand = "install";

// lirabry to add a custom command
var command = loadWithNewGlobal("C:/Users/mhoogendijk/Documents/sqlcl/lib/command.js");

// Library to install releases
var release = loadWithNewGlobal("C:\\Users\\mhoogendijk\\Documents\\sqlcl\\lib\\release.js");

// Set the baseDir
release.setBaseDir("C:\\Users\\mhoogendijk\\stack\\Qualogy\\presentation\\sqlcl\\releases");

// Possible commands
// install list: list the possible releases
// install check <release>: check if the release complies
// install release <release> start the installation

command.add({
    command: gCommand,
    info: "Install new releases.\nTo list all releases type install list\nTo install a release type install <release>",
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
        }
    ],
    begin: function() {},
    end: function() {}
});
