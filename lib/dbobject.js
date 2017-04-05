var checks = [

];

(function(config){

  var file = loadWithNewGlobal("https://raw.githubusercontent.com/mennooo/sqlcl/master/lib/file.js?v=" + config.version);

  function _isDBObject(filename){
    var ext = file.extension(filename);
    print(ext)
  };



  function check(release){
    _isDBObject(release)
  };

  return {
    check: check
  };

}).apply(this, arguments);
