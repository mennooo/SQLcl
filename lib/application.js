/*

  Library to launch applications from SQLcl

*/

(function() {

  var Runtime = Java.type('java.lang.Runtime');

  var runtime = Runtime.getRuntime(),
      gApplications = {};

  _addApplication({
    name: 'web',
    run: function(startupArgs) {
      runtime.exec(config.applications.web.executable + " " + startupArgs);
    }
  });

  _addApplication({
    name: 'file',
    run: function(startupArgs) {
      runtime.exec(config.applications.file.executable + " " + startupArgs);
    }
  });

  _addApplication({
    name: 'database',
    run: function(startupArgs) {
      runtime.exec(config.applications.database.executable + " " + startupArgs);
    }
  });

  function _addApplication(application){
    gApplications[application.name] = application.run;
  };

  function run(applicationName, startupArgs){
    gApplications[applicationName](startupArgs);
  };

  return {
    run: run
  }

})();
