// file: release.js

var file = loadWithNewGlobal("https://raw.githubusercontent.com/mennooo/sqlcl/master/lib/file.js"),
    //dbobject = loadWithNewGlobal("https://raw.githubusercontent.com/mennooo/sqlcl/master/lib/dbobject.js"),
    output = loadWithNewGlobal("https://raw.githubusercontent.com/mennooo/sqlcl/master/lib/output.js");

(function() {

    //

    var baseDir = "";

    function _directoryExists(dir) {
      var currDir;
        try {
            currDir = file.getDir(dir);
        } catch (e) {
            return false;
        }
        return true;
    };

    function setBaseDir(dir) {
        // check if directory exists
        if (_directoryExists(dir)) {
            baseDir = dir;
        } else {
            throw new Error("the directory '" + dir + "' does not exist");
        }

    }

    function listAll() {
        print("oja")
        var dirs = file.listDirs(baseDir);
        print("Available releases:\n");
        dirs.forEach(function(dir) {
            print(dir + "\n");
        });
    }

    function check(release) {
        //dbobject.check(release);
    };

    function install(release) {
        //dbobject.install(release);
    };

    return {
        setBaseDir: setBaseDir,
        listAll: listAll,
        check: check,
        install: install
    }

})();
