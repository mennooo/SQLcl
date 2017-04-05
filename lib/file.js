/*

 Library to work with files and directories

 */


/* global Java */

var File = Java.type('java.io.File'),
    FileReader = Java.type('java.io.FileReader');

(function() {

    var realFiles = [];

    // returns the content as an array of lines
    function _getContent(file) {

        return function() {

            var fr = new FileReader(file);

            //carriage returns
            var crs = [10, 13];

            var char = fr.read();

            var content = [];

            var lineContent = '';
            var lines = 0;

            while (char !== -1) {

                if (crs.indexOf(char) > -1) {
                    content.push(lineContent);
                    lineContent = '';
                } else {
                    lineContent = lineContent + String.fromCharCode(char);
                }

                char = fr.read();
            }
            fr.close();
            return content;
        }

    };

    // returns a file as an object
    function _realFile(file) {

        return {
            path: file,
            name: '',
            getContent: _getContent(file)
        };

    };

    function getDir(dir) {
        return new File(dir);
    };

    // list all directories in a directory
    function listDirs(dir){

      var currDir = getDir(dir),
          fileList = Java.from(currDir.listFiles()),
          dirs = [];

      print(fileList)

        // Get directories
        fileList.forEach(function(file) {
            currFile = new File(file);
            if (currFile.isDirectory()) {
                dirs.push[currFile.getName()];
            };
        });

        return dirs;

    };

    function filesInDir(options) {

        // default settings
        var settings = {
            dir: "",
            subDirectories: false
        };

        // extend settings with options
        for (obj in settings) {
            if (options.hasOwnProperty(obj)) {
                settings[obj] = options[obj];
            }
        }

        // We want all real files from dir and subdirs
        var dir = getDir(options.dir),
            fileList = Java.from(dir.listFiles()),
            currFile;


        // Get files
        fileList.forEach(function(file) {
            currFile = new File(file);
            // Get files in subdirectories
            if (currFile.isDirectory() && options.subDirectories) {
                var filesInSubDir = filesInDir(currFile.getAbsolutePath());
            } else if (currFile.isFile()) {
                realFiles.push(_realFile(file));
            };
        });

        return realFiles;

    };

    return {
        getDir: getDir,
        listDirs: listDirs,
        filesInDir: filesInDir
    };

})();
