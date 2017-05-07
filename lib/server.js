/*

	Extending SQLcl with a webserver for websockets

*/
(function() {

    var WebServers = Java.type('org.webbitserver.WebServers'),
				StaticFileHandler = Java.type('org.webbitserver.handler.StaticFileHandler'),
				BaseWebSocketHandler = Java.type('org.webbitserver.BaseWebSocketHandler'),
				application = load(config.baseDir + "lib/application.js");

    var WebSocketHandler = Java.extend(BaseWebSocketHandler),
				gConnection,
				websocket,
				webServer;

		function _stringToHTML(string) {
			var lines = string.split('\n');
			return lines.join('<br>');
		};

    function start(cb) {
      websocket = new WebSocketHandler() {

          onOpen: function(connection) {
              gConnection = connection;
              connection.send("Your output will be here soon!");
              cb();
          }
      };

      webServer = WebServers.createWebServer(9000);

      webServer.add("/websockets", websocket);
      webServer.add(new StaticFileHandler(config.publicDir));



      print("\nServer running at " + webServer.getUri());

      application.run('web', webServer.getUri());
      webServer.start();
    };

    function send(msg) {
      gConnection.send(_stringToHTML(msg));
    };

    function setAppend() {
      gConnection.send("websocket:append");
    };

    function stop(msg){
      gConnection.send("websocket:replace");
      gConnection.send(msg);
      //webServer.stop();
    }

		return {
			websocket: {
				start: start,
				send: send,
        setAppend: setAppend,
        stop: stop
			}
		}

})();
