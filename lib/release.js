// file: release.js
(function() {

    var file = load(config.baseDir + "lib/file.js"),
        dbobject = load(config.baseDir + "lib/dbobject.js"),
        utils = load(config.baseDir + "lib/utils.js");

    var baseDir = config.releaseDir,
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

    function _checkBaseDir(cb) {
        if (!file.dirExists(baseDir)) {
            print("Please set a valid releases directory first: install dir <directory>");
            return false;
        }
        cb();
    };

    function listAll() {

        _checkBaseDir(function() {
            releases = file.listDirs(baseDir);
            print("\nAvailable releases:\n");
            releases.forEach(function(release) {
                print(release);
            });
            print();
        });

    }

    function check(release) {

        _checkBaseDir(function() {
            // step 1: get files in release folder
            var files = file.filesInDir({
                dir: baseDir + release,
                subDirectories: true
            });

            if (!files) {
                return false;
            }

            // Step 2: filter only database objects
            var dbObjects = files.filter(dbobject.isDbObject);

            // Step 3: check each file
            dbobject.checkObjects(dbObjects);
        });

    };

    function install(release) {

        _checkBaseDir(function() {
            // step 1: get files in release folder
            var files = file.filesInDir({
                dir: baseDir + release,
                subDirectories: true
            });

            if (!files) {
                return false;
            }

            // Step 2: filter only database objects
            var dbObjects = files.filter(dbobject.isDbObject);

            // Step 2: set logfile
            var logFile = release + "_" + utils.dateTimeString(new Date()) + '.log';
            dbobject.setLogFile(logFile);

            // Step 3: install database objects
            dbobject.installObjects(dbObjects);
        });

    };

    function setOutputMethod(outputMethod) {
      dbobject.setOutputMethod(outputMethod.toString());
    };

    return {
        setBaseDir: setBaseDir,
        listAll: listAll,
        check: check,
        install: install,
        setOutputMethod: setOutputMethod
    }

})();
