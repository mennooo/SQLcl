/*

  Load and execute a script file

*/

load("https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.18.1/moment.js");

var sysdate = moment().format("dddd, MMMM Do YYYY, hh:mm:ss");

print(sysdate);
