// file: add_install_command.js

// Runs on startup

var gCommand = "install";

var releases = loadWithNewGlobal("C:\\Users\\mhoogendijk\\Documents\\sqlcl\\lib\\releases.js");
var release = loadWithNewGlobal("C:\\Users\\mhoogendijk\\Documents\\sqlcl\\lib\\release.js");
var command = loadWithNewGlobal("C:\\Users\\mhoogendijk\\Documents\\sqlcl\\lib\\command.js");

// Possible commands
// install list: list the possible releases
// install check <release>: check if the release complies
// install release <release> start the installation

command.add({

    command: gCommand,
    info: "Install new releases.\nTo list all releases type install list\nTo install a release type install <release>",
    actions: [
        {
          name: "list",
          action: releases.list
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
