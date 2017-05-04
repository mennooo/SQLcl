/*

  Library to launch applications from SQLcl

*/

(function() {

  var Runtime = Java.type('java.lang.Runtime');

  var runtime = Runtime.getRuntime(),
      gApplications = {};

  _addApplication({
    name: 'chrome',
    run: function(startupArgs) {
      runtime.exec("C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe " + startupArgs);
    }
  });

  _addApplication({
    name: 'sqldeveloper',
    run: function(startupArgs) {
      runtime.exec("C:\\app\\sqldeveloper\\sqldeveloper.exe " + startupArgs);
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
