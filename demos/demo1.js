/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

var connection = loadWithNewGlobal("https://github.com/mennooo/sqlcl/blob/master/lib/connection.js");
var output = loadWithNewGlobal("https://github.com/mennooo/sqlcl/blob/master/lib/output.js");

var myConnection = connection.init({
    sid: 'ORCL',
    username: 'hr',
    password: 'hr'
});

myConnection.ctx.write('Hello world\n');

myConnection.sqlcl.setStmt("select * from user_objects;");
myConnection.sqlcl.run();
