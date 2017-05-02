/*

  Most advanced usage of loadWithNewGlobal
  Executes some code and returns a function (or any other object for that matter) to the script that loaded this

*/

// Execute the outer function immediate with parameters and return the inner function
(function(loadArgs) {

  // print this when the script is loaded
  print(loadArgs);

  // Return something to use by the other script
  return function() {
    print("An an extra function");
  };

})(arguments);
