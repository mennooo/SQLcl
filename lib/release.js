// file: release.js
(function() {

var file = load(config.baseDir + "lib/file.js");
var dbobject = load(config.baseDir + "lib/dbobject.js");

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
  print("\nAvailable releases:\n");
  releases.forEach(function(release) {
    print(release);
  });
  print();
}

function check(release) {

  // step 1: get files in release folder
  var files = file.filesInDir({
    dir: baseDir + "/" + release,
    subDirectories: true
  });

  // Step 2: filter only database objects
  var dbObjects = files.filter(dbobject.isDbObject);

  // Step 3: check each file
  dbobject.checkObjects(dbObjects);
};

function install(release) {

  // step 1: get files in release folder
  var files = file.filesInDir({
    dir: baseDir + "/" + release,
    subDirectories: true
  });

  // Step 2: filter only database objects
  var dbObjects = files.filter(dbobject.isDbObject);

  // Step 3: install database objects
  dbobject.installObjects(dbObjects);
};

return {
  setBaseDir: setBaseDir,
  listAll: listAll,
  check: check,
  install: install
}

})();
