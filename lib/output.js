/*

Library to change the output of sqlcl

The output of sqlcl and ctx have to be changed

*/

/* global Java */

(function() {

    var BufferedOutputStream = Java.type('java.io.BufferedOutputStream'),
        PrintStream = Java.type('java.io.PrintStream'),
        System = Java.type("java.lang.System"),
        FileOutputStream = Java.type('java.io.FileOutputStream'),
        WrapListenBufferOutputStream = Java.type('oracle.dbtools.raptor.newscriptrunner.WrapListenBufferOutputStream'),
        ScriptRunnerContext = Java.type("oracle.dbtools.raptor.newscriptrunner.ScriptRunnerContext"),
        BufferedOutputStream = Java.type('java.io.BufferedOutputStream'),
        ByteArrayOutputStream = Java.type('java.io.ByteArrayOutputStream'),
        Charsets = Java.type('java.nio.charset.StandardCharsets');

    var outputMethods = {
      default: 'default',
      file: 'file',
      string: 'string',
      web: 'web'
    };

    function _setScriptRunnerContext(scriptExecutor, bufferedOutputStream) {

        var scriptRunnerContext = scriptExecutor.getScriptRunnerContext(),
            wrapListenBufferOutputStream;

        if (!scriptRunnerContext) {
            scriptRunnerContext = new ScriptRunnerContext();
            scriptRunnerContext.consumerRuning(true);

            wrapListenBufferOutputStream = new WrapListenBufferOutputStream(bufferedOutputStream);
            wrapListenBufferOutputStream.setRemoveForcePrint(true);
            scriptRunnerContext.setOutputStreamWrapper(wrapListenBufferOutputStream);

            scriptExecutor.setScriptRunnerContext(scriptRunnerContext);
        }
    };

    function _setOutput(scriptExecutor, bufferedOutputStream) {
        scriptExecutor.setOut(bufferedOutputStream);
        _setScriptRunnerContext(scriptExecutor, bufferedOutputStream);
    };

    function setDefaultOutput(scriptExecutor) {
        _setOutput(scriptExecutor, new BufferedOutputStream(new PrintStream(System.out, true)));
    };

    function setFileOutput(scriptExecutor, file) {
        _setOutput(scriptExecutor, new BufferedOutputStream(new FileOutputStream(file)));
    };

    function setStringOutput(scriptExecutor) {
        var byteOutputStream = new ByteArrayOutputStream(Charsets.UTF_8);
        _setOutput(scriptExecutor, new BufferedOutputStream(byteOutputStream));
        // We need to be able to flush it later
        return byteOutputStream;
    };

    function setWebOutput(scriptExecutor) {
        return setStringOutput(scriptExecutor);
    };

    function getStringOutput(scriptExecutor, byteOutputStream) {
      var contextOutputStream = scriptExecutor.getScriptRunnerContext().getOutputStream();
      contextOutputStream.flush();
      return byteOutputStream.toString();
    };

    function getWebOutput(scriptExecutor, byteOutputStream) {
      print(byteOutputStream)
      return getStringOutput(scriptExecutor, byteOutputStream);
    };

    return {
        outputMethods: outputMethods,
        setDefaultOutput: setDefaultOutput,
        setFileOutput: setFileOutput,
        setStringOutput: setStringOutput,
        setWebOutput: setWebOutput,
        getStringOutput: getStringOutput,
        getWebOutput: getWebOutput
    };

})();
