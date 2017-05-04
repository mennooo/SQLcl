/*
    This is a javascript library to handle files on windows
*/

(function(){

  function dateTimeString(dateTime){
    var month = ("0" + (dateTime.getMonth() + 1)).slice(-2);
    var day = ("0" + dateTime.getDate()).slice(-2);
    var year = dateTime.getFullYear();
    var hours = ("0" + dateTime.getHours()).slice(-2);
    var minutes = ("0" + dateTime.getHours()).slice(-2);
    var seconds = ("0" + dateTime.getSeconds()).slice(-2);

    return year + month + day + '_' + hours + minutes + seconds;
  }

  return {
    dateTimeString: dateTimeString
  };

})();
