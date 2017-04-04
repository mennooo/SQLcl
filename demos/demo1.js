/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

var connection = loadWithNewGlobal("https://raw.githubusercontent.com/mennooo/sqlcl/master/lib/connection.js");

var myConnection = connection.init(arguments[0]);

myConnection.ctx.write('The following query will be executed: select table_name from user_tables where rownum < 4;\n');

myConnection.sqlcl.setStmt("select table_name from user_tables where rownum < 4;");
myConnection.sqlcl.run();

