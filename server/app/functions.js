    function rescale(x, in_min, in_max, out_min, out_max) {
        var output;
        output = (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
        //console.log(output);
        if (output < out_min) {
            output = out_min;
        } else if (output > out_max) {
            output = out_max;
        } else {
            //Nothing
        }

        return output

    }
  
    function timeStamp(){
      
     var MyDate = new Date();
        var MyDateString;
        var MyTimeStamp;
        MyDateString = ('0' + MyDate.getFullYear()).slice(-2) + '-' + ('0' + (MyDate.getMonth() + 1)).slice(-2) + '-' + ('0' + (MyDate.getUTCDate())).slice(-2);
        MyTimeStamp = ('0' + MyDate.getHours()).slice(-2) + '-' + ('0' + (MyDate.getMinutes())).slice(-2) + '-' + ('0' + (MyDate.getSeconds())).slice(-2);

      return MyDateString + '_' + MyTimeStamp      
    }


   // exports ======================================================================
  exports.timeStamp = timeStamp;
  exports.rescale = rescale;
