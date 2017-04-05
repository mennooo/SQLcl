(function(config){

  var file = loadWithNewGlobal("https://raw.githubusercontent.com/mennooo/sqlcl/master/lib/file.js?v=" + config.version);

  function check(release){
    print(release)
  };

  return {
    check: check
  };

}).apply(this, arguments);
