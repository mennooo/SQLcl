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

    websocket = new WebSocketHandler() {

        onOpen: function(connection) {
						gConnection = connection;
						connection.send("Your output will be here soon!");
        }
    };



		function _stringToHTML(string) {
			var lines = string.split('\n');
			return lines.join('<br>');
		};

		return {
			websocket: {
				start: function() {
					webServer = WebServers.createWebServer(9000);

			    webServer.add("/websockets", websocket);
			    webServer.add(new StaticFileHandler(config.publicDir));



					print("\nServer running at " + webServer.getUri());

					application.run('web', webServer.getUri());
					webServer.start();
				},
				send: function(msg){
					gConnection.send(_stringToHTML(msg))
				}
			}
		}

})();
