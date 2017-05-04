/*

 Library to change the output of sqlcl

 */

/* global Java */

(function() {

  var BufferedOutputStream = Java.type('java.io.BufferedOutputStream'),
      PrintStream = Java.type('java.io.PrintStream'),
      System = Java.type("java.lang.System"),
      FileOutputStream = Java.type('java.io.FileOutputStream'),
      WrapListenBufferOutputStream = Java.type('oracle.dbtools.raptor.newscriptrunner.WrapListenBufferOutputStream');


  function setDefaultOutput(ctx){

      var output = new BufferedOutputStream(new PrintStream(System.out, true));

      ctx.setOutputStreamWrapper(output);

  };

  function setFileOutput(ctx, file){

      var output = new WrapListenBufferOutputStream(new BufferedOutputStream(new FileOutputStream(file)));

      ctx.setOutputStreamWrapper(output);
  };

  return {
      setDefaultOutput: setDefaultOutput,
      setFileOutput: setFileOutput
  };

})();
