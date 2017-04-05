// file: release.js

var file = loadWithNewGlobal("https://raw.githubusercontent.com/mennooo/sqlcl/master/lib/file.js?v=6"),
    dbobject = loadWithNewGlobal("https://raw.githubusercontent.com/mennooo/sqlcl/master/lib/dbobject.js?v=6");

(function() {
    //

    var baseDir = "",
        releases = [];

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
        releases = file.listDirs(baseDir);
        print("Available releases:\n");
        releases.forEach(function(release) {
            print(release);
        });
        print();
    }

    function check(release) {
        dbobject.check(baseDir + "\\" + release);
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
