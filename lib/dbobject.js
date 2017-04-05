var checks = [

];

(function(config){

  var file = loadWithNewGlobal("https://raw.githubusercontent.com/mennooo/sqlcl/master/lib/file.js?v=" + config.version);

  function _isDBObject(file){
    print(1, file.extension)
  };



  function check(release){
    var files = file.filesInDir(release);
    print(files)
    files.forEach(function(file){
      _isDBObject(file);
    })

  };

  return {
    check: check
  };

}).apply(this, arguments);
