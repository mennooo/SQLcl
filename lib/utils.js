/*
    This is a javascript library to handle files on windows
*/

(function(){

  function _getDateParts(dateTime) {

    var month = ("0" + (dateTime.getMonth() + 1)).slice(-2),
        day = ("0" + dateTime.getDate()).slice(-2),
        year = dateTime.getFullYear(),
        hours = ("0" + dateTime.getHours()).slice(-2),
        minutes = ("0" + dateTime.getHours()).slice(-2),
        seconds = ("0" + dateTime.getSeconds()).slice(-2);

        return {
          year: year,
          month: month,
          day: day,
          hours: hours,
          minutes: minutes,
          seconds: seconds
        };

  };

  function dateTimeString(dateTime){
    var dateParts = _getDateParts(dateTime);
    return dateParts.year + dateParts.month + dateParts.day + '_' + dateParts.hours + dateParts.minutes + dateParts.seconds;
  }

    function dateString(dateTime){
      var dateParts = _getDateParts(dateTime);
      return dateParts.year + '-' + dateParts.month + '-' + dateParts.day;
    }

  return {
    dateTimeString: dateTimeString,
    dateString: dateString
  };

})();
