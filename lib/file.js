/* 
 
 Library to work with files and directories
 
 */


/* global Java */

var File = Java.type('java.io.File'),
    FileReader = Java.type('java.io.FileReader');

(function(){
    
    var realFiles = [];
    
    // returns the content as an array of lines
    function _getContent(file){
        
        return function(){
            
            var fr = new FileReader(file);

            //carriage returns
            var crs = [10,13];

            var char = fr.read();

            var content = [];

            var lineContent = '';
            var lines = 0;

            while (char !== -1){

              if (crs.indexOf(char) > -1){
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
    function _realFile(file){
        
        return {
            path: file,
            name: '',
            getContent: _getContent(file)
        };
        
    };
    
    function filesInDir(dir){
        
        // We want all real files from dir and subdirs
        var dir = new File(dir),
            fileList = Java.from(dir.listFiles()),
            currFile;
        
        
        // Include subdirs
        fileList.forEach(function(file) {
            currFile = new File(file);
            if (currFile.isDirectory()) {
                var filesInSubDir = filesInDir(currFile.getAbsolutePath());
            } else if (currFile.isFile()) {
                realFiles.push(_realFile(file));
            };
        });
        
        return realFiles;
    
    };
    
    return {
        filesInDir: filesInDir
    };
    
})();
