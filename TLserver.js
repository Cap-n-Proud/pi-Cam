// sudo udevadm control --reload-rules
// to refresh the port allocation
var events = require('events');
var eventEmitter = new events.EventEmitter();
var TLFolder = "/home/pi/Documents/TL/"
var SNFolder = "/home/pi/Documents/SN/"


var serPort = "/dev/ttyACM0";
var serBaud = 38400;
var serverPort = 999;

var LogR = 0;
var TelemetryFN = "";
var prevTel = "";
var prevPitch = "";

var SEPARATOR = ","
var version = "0.6";

var ArduHeader;
var ArduRead = {};

//--------------------------------------

var express = require('/usr/local/lib/node_modules/express');
var app = express();
var http = require('http').Server(app);
var io = require('/usr/local/lib/node_modules/socket.io')(http);
var fs = require('/usr/local/lib/node_modules/safefs');
var piblaster = require('/usr/local/lib/node_modules/pi-blaster.js');

//var PiFastGpio = require('/usr/local/lib/node_modules/pi-fast-gpio//index.js');

var SERVO_1_GPIO = 4;
var SERVO_2_GPIO = 18;
var HOST = '127.0.0.1';
var serverADDR = 'N/A';
var PORT = 8888;

var pw = 2000; // pulsewidth in microseconds
var change = 20;

//var gpio = new PiFastGpio();

var sys = require('sys');
var exec = require('child_process').exec;

var TLimgWidth = 2592; // Max = 2592
var TLimgHeight = 1944; //# Max = 1944

var SNimgWidth = 320; // Max = 2592
var SNimgHeight = 240; //# Max = 1944


var TLInterval = 10000;

//Get IP address http://stackoverflow.com/questions/3653065/get-local-ip-address-in-node-js

var os = require('os');
var ifaces = os.networkInterfaces();

Object.keys(ifaces).forEach(function (ifname) {
  var alias = 0
    ;

  ifaces[ifname].forEach(function (iface) {
    if ('IPv4' !== iface.family || iface.internal !== false) {
      // skip over internal (i.e. 127.0.0.1) and non-ipv4 addresses
      return;
    }

    if (alias >= 1) {
      // this single interface has multiple ipv4 addresses
      console.log(ifname + ':' + alias, iface.address);
    } else {
      // this interface has only one ipv4 adress
      serverADDR = iface.address;
    }
  });
});
//---------------


app.use(express.static(__dirname + '/public'));
// Routers
{
    app.get('/', function(req, res) {
        res.sendFile(__dirname + '/public/index.html');
        res.end;
    });

    app.get('/vj', function(req, res) {
        res.sendFile(__dirname + '/public/robotj.html');
        res.end;
    });

    app.get('/REBOOT', function(req, res) {
        var postData = req.url;

        function puts(error, stdout, stderr) {
            sys.puts(stdout)
        }
        exec('sudo reboot now');
        sockets.emit('Info', "Rebooting")
            //console.log(postData);
        res.end;
    });


}

// Logging middleware

var mkdirSync = function(path) {
    try {
        fs.mkdirSync(path);
    } catch (e) {
        if (e.code != 'EEXIST') throw e;
    }
}


io.on('connection', function(socket) {
    var myDate = new Date();
    socket.emit('connected', 'Connected ' + myDate.getHours() + ':' + myDate.getMinutes() + ':' + myDate.getSeconds()+ ' v' + version + ' @' + serverADDR);
    socket.emit('serverADDR', serverADDR);
    console.log('New socket.io connection - id: %s', socket.id);
    //socket.emit('serverADDR', require('os').networkInterfaces().eth0[0].address);

    function puts(error, stdout, stderr) {
        sys.puts(stdout)
    }
    exec('sudo /home/pi/pi-blaster/pi-blaster 4 17');



    socket.on('Video', function(Video) {
        socket.emit('CMD', Video);
        console.log(Video);

        function puts(error, stdout, stderr) {
            sys.puts(stdout)
        }
        exec('sudo bash /home/pi/time-lapse-server/scripts/' + Video, puts);
    });


    socket.on('REBOOT', function() {
        function puts(error, stdout, stderr) {
            sys.puts(stdout)
        }
        exec('sudo reboot now');
        sockets.emit('Info', "Rebooting")
    });

    socket.on('move', function(dX, dY) {
        //console.log('event: ', dX, dY);
        //Need a value -100, 100
        //piblaster.setPwm(17, (rescale(parseFloat(dX), -100, 100, 0.07, 0.20)));
        //piblaster.setPwm(4, (rescale(parseFloat(dY), -100, 100, 0.06, 0.19)));
	
	gpio.setServoPulsewidth(SERVO_1_GPIO, rescale(parseFloat(dX), -100, 100, 1000, 2000));
	gpio.setServoPulsewidth(SERVO_2_GPIO, rescale(parseFloat(dY), -100, 100, 1000, 2000));
      
        //console.log(parseFloat(dX));
        //console.log(parseFloat(dY));

        //console.log(rescale(parseFloat(dY),-50,50,0.06,0.15));
        //console.log(rescale(parseFloat(dX),-100,100,0.07,0.20));
    });

    socket.on('TLInterval', function(T) {
        TLInterval = T * 1000;
        socket.emit('Info', 'timelapse set to ' + T + 's')
    });

    
    function timeStamp(){
      
     var MyDate = new Date();
        var MyDateString;
        var MyTimeStamp;
        MyDateString = ('0' + MyDate.getFullYear()).slice(-2) + '-' + ('0' + (MyDate.getMonth() + 1)).slice(-2) + '-' + ('0' + (MyDate.getUTCDate())).slice(-2);
        MyTimeStamp = ('0' + MyDate.getHours()).slice(-2) + '-' + ('0' + (MyDate.getMinutes())).slice(-2) + '-' + ('0' + (MyDate.getSeconds())).slice(-2);

      return MyDateString + '_' + MyTimeStamp      
    }
    
    
    function snapShot(imgWidth, imgHeight, folderName, fileName) {
       
      function puts(error, stdout, stderr) {
            sys.puts(stdout)
        }
        exec('sudo raspistill -w ' + imgWidth + ' -h ' + imgHeight + ' -o ' + folderName + '/' + fileName + '.jpg  -sh 40 -awb auto -mm average -v');
        //console.log('sudo raspistill -w ' + imgWidth + ' -h ' + imgHeight + ' -o ' + TLfolderName + '/' + TLfileName + '_' + MyTimeStamp +  '.jpg  -sh 40 -awb auto -mm average -v');
        socket.emit('Info', fileName + '.jpg');
	  socket.emit('Folder', folderName);

    }

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

    var myVar = "";
    socket.on('TLStart', function() {
        // function puts(error, stdout, stderr) { sys.puts(stdout) }
       
        TLfolderName = TLFolder + 'TL_' + timeStamp();
        TLfileName = 'TL_' + timeStamp();
        fs.mkdir(TLfolderName);
        socket.emit('Folder', TLfolderName);
        //console.log(TLfolderName);
        myVar = setInterval(function() {
            snapShot(TLimgWidth, TLimgHeight, TLfolderName, TLfileName)
        }, TLInterval);
	socket.emit('Info', 'Time-lapse started');

    });

    socket.on('TLStop', function() {
        clearInterval(myVar);
        socket.emit('Info', 'Time-lapse stopped');

    });

    socket.on('takeSnapShot', function() {
	snapShot(SNimgWidth, SNimgHeight, SNFolder, 'SN_' + timeStamp());
    
    });

});


http.listen(serverPort, function() {
    console.log('listening on *: ', serverPort); //


});