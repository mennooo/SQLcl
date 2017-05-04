/*

	Extending SQLcl with a webserver for websockets

*/

var File = Java.type('java.io.File');

var WebServers = Java.type('org.webbitserver.WebServers');
var Thread = Java.type('java.lang.Thread');
var StaticFileHandler = Java.type('org.webbitserver.handler.StaticFileHandler');
var HttpHandler = Java.type('org.webbitserver.HttpHandler');
var BaseWebSocketHandler = Java.type('org.webbitserver.BaseWebSocketHandler');
var Map = Java.type('java.util.HashMap');
var Desktop = Java.type('java.awt.Desktop');

var WebSocketHandler = Java.extend(BaseWebSocketHandler);

var websocket = new WebSocketHandler() {

	connectionCount: 1,
	//note: Webbit is single-threaded
	connections: new Map(),

	onOpen: function (connection) {
		connection.send("Number of active connections: " + this.connectionCount );
		this.connectionCount++;
		this.connections.put(connection.hashCode(), connection);
	},

	onClose: function (connection) {
		this.connectionCount--;
		this.connections.remove(connection.hashCode());
	},

	onMessage: function (connection, message) {
		print("message arrived: "+message);
		var conns = Java.from(this.connections.values());
		for (var i = 0; i < conns.length; i++) {
			conns[i].send(message.toUpperCase());
		}
	}
};


var helloworld = new HttpHandler {
	handleHttpRequest: function (request, response, control) {
		//note: Webbit is single-threaded
		//this essentially means execute this block of code on nextTick
		control.execute(function () {
	            response.content("Hello World").end();
		});
	}
};

var webServer =
					WebServers.createWebServer(9000).
					add("/websockets", websocket).
					add("/hello", helloworld).
					add(new StaticFileHandler("./public"));

webServer.start();

print("Server running at " + webServer.getUri());

var Runtime = Java.type('java.lang.Runtime');
var runtime = Runtime.getRuntime();
runtime.exec("C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe " + webServer.getUri() + "hello")


//Thread.currentThread().join();
