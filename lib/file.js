/*

 Library to work with files and directories

 */


/* global Java */

(function() {

  var File = Java.type('java.io.File'),
    FileReader = Java.type('java.io.FileReader');

  var gRealFiles = [];

  // returns the content as an array of lines
  function _getContent(file) {

    return function() {

      var fr = new FileReader(file),
          crs = [/*10, */13],
          char = fr.read(),
          content = [],
          lineContent = '',
          lines = 0;

      while (char !== -1) {

        if (crs.indexOf(char) > -1) {
          content.push(lineContent);
          lineContent = '';
        } else {
          lineContent = lineContent + String.fromCharCode(char);
        }
        char = fr.read();
      }
      content.push(lineContent);

      fr.close();
      return content;
    }

  };

  // returns a file as an object
  function _realFile(file) {

    var fileParts = file.split(config.fileSeparator),
        fileNameWithExtension = fileParts.pop(),
        fileName = fileNameWithExtension.split("."),
        extension = fileName.pop(),
        path = fileParts.join(config.fileSeparator);

    return {
      fullPath: file.trim(),
      path: path,
      name: fileName.toString(),
      extension:extension,
      fileNameWithExtension: fileNameWithExtension,
      getContent: _getContent(file),
      fileParts: fileParts
    };

  };

  function getDir(dir) {
    return new File(dir);
  };

  function dirExists(dir) {
    return getDir(dir).exists();
  };

  // list all directories in a directory
  function listDirs(dir) {

    var currDir = getDir(dir),
        fileList = Java.from(currDir.listFiles()),
        dirs = [];

    // Get directories
    fileList.forEach(function(file) {
      currFile = new File(file);
      if (currFile.isDirectory()) {
        dirs.push(currFile.getName());
      };
    });

    return dirs;

  };

  function filesInDir(options) {

    // default settings
    var settings = {
      dir: "",
      subDirectories: false,
      recursive: false
    };


    // extend settings with options
    for (obj in settings) {
      if (options.hasOwnProperty(obj)) {
        settings[obj] = options[obj];
      }
    }

    if(!settings.recursive) {
      // Reset files
      gRealFiles = [];
    }

    // We want all real files from dir and subdirs
    var dir = getDir(settings.dir),
      fileList = Java.from(dir.listFiles()),
      currFile;

    if (!dir.exists()) {
      print("The directory does not exist:", settings.dir);
      return false;
    }

    // Get files
    fileList.forEach(function(file) {

      currFile = new File(file);
      // Get files in subdirectories
      if (currFile.isDirectory() && options.subDirectories) {
        var filesInSubDir = filesInDir({
          dir: currFile.getAbsolutePath(),
          subDirectories: settings.subDirectories,
          recursive: true
        });
      } else if (currFile.isFile()) {
        gRealFiles.push(_realFile(file.toString()));
      };
    });

    return gRealFiles;

  };

  function appendText(file, text){
    var FileWriter = java.io.FileWriter;
    var fw = new FileWriter(file, true);
    fw.write(java.lang.System.getProperty( "line.separator" ));
    fw.write(text);
    fw.close();
  };

  function createFile(file, text){
    var FileWriter = java.io.FileWriter;
    var fw = new FileWriter(file, false);
    //fw.write(java.lang.System.getProperty( "line.separator" ));
    fw.write(text);
    fw.close();
  };

  function getFileContent(file) {
    return _getContent(file)();
  };

  return {
    getDir: getDir,
    dirExists: dirExists,
    listDirs: listDirs,
    filesInDir: filesInDir,
    appendText: appendText,
    createFile: createFile,
    getFileContent: getFileContent
  };

})();
