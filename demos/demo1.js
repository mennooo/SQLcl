/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


var connection = loadWithNewGlobal("lib/connection.js");
var output = loadWithNewGlobal("lib/output.js");


var myConnection = connection.init({
    sid: 'ORCL',
    username: 'hr',
    password: 'hr'
});


myConnection.ctx.write('Hello world\n');

output.setFileOutput(myConnection.ctx, 'D:\\oracle\\output.txt');

myConnection.sqlcl.setStmt("DDL departments");
myConnection.sqlcl.run();