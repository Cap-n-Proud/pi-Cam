// sudo udevadm control --reload-rules
// to refresh the port allocation
var events = require('events');
var eventEmitter = new events.EventEmitter();
var TLFolder = "/home/pi/Documents/TL/"


var serPort = "/dev/ttyACM0";
var serBaud = 38400;
var serverPort = 999;

var LogR = 0;
var TelemetryFN = "";
var prevTel = "";
var prevPitch = "";

var SEPARATOR = ","
var version = "0.5";

var ArduHeader;
var ArduRead = {};

//--------------------------------------

var express = require('/usr/local/lib/node_modules/express');
var app = express();
var http = require('http').Server(app);
var io = require('/usr/local/lib/node_modules/socket.io')(http);
var fs = require('/usr/local/lib/node_modules/safefs');
var piblaster = require('/usr/local/lib/node_modules/pi-blaster.js');

var sys = require('sys');
var exec = require('child_process').exec;

var imgWidth = 2592; // Max = 2592
var imgHeight = 1944; //# Max = 1944
var TLInterval = 10000;

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
    socket.emit('connected', 'Connected ' + myDate.getHours() + ':' + myDate.getMinutes() + ':' + myDate.getSeconds()+ ' v' + version + ' @' + require('os').networkInterfaces().eth0[0].address);
    socket.emit('serverADDR', require('os').networkInterfaces().eth0[0].address);
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
        piblaster.setPwm(17, (rescale(parseFloat(dX), -100, 100, 0.07, 0.20)));
        piblaster.setPwm(4, (rescale(parseFloat(dY), -100, 100, 0.06, 0.19)));
	
        //console.log(parseFloat(dX));
        //console.log(parseFloat(dY));

        //console.log(rescale(parseFloat(dY),-50,50,0.06,0.15));
        //console.log(rescale(parseFloat(dX),-100,100,0.07,0.20));
    });

    socket.on('TLInterval', function(T) {
        TLInterval = T * 1000;
        socket.emit('Info', 'timelapse set to ' + T + 's')
    });

    function TLF() {
        var MyDate = new Date();
        var MyTimeStamp;
        MyTimeStamp = ('0' + MyDate.getHours()).slice(-2) + '-' + ('0' + (MyDate.getMinutes())).slice(-2) + '-' + ('0' + (MyDate.getSeconds())).slice(-2);

        function puts(error, stdout, stderr) {
            sys.puts(stdout)
        }
        exec('sudo raspistill -w ' + imgWidth + ' -h ' + imgHeight + ' -o ' + TLfolderName + '/' + TLfileName + '_' + MyTimeStamp + '.jpg  -sh 40 -awb auto -mm average -v');
        //console.log('sudo raspistill -w ' + imgWidth + ' -h ' + imgHeight + ' -o ' + TLfolderName + '/' + TLfileName + '_' + MyTimeStamp +  '.jpg  -sh 40 -awb auto -mm average -v');
        socket.emit('Info', TLfileName + '_' + MyTimeStamp + '.jpg');

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
        var MyDate = new Date();
        var MyDateString;
        var MyTimeStamp;
        MyDateString = ('0' + MyDate.getFullYear()).slice(-2) + '-' + ('0' + (MyDate.getMonth() + 1)).slice(-2) + '-' + ('0' + (MyDate.getUTCDate())).slice(-2);
        MyTimeStamp = ('0' + MyDate.getHours()).slice(-2) + '-' + ('0' + (MyDate.getMinutes())).slice(-2) + '-' + ('0' + (MyDate.getSeconds())).slice(-2);

        TLfolderName = TLFolder + 'TL_' + MyDateString + '_' + MyTimeStamp;
        TLfileName = 'TL_' + MyDateString;
        fs.mkdir(TLfolderName);
        socket.emit('Folder', TLfolderName);
        //console.log(TLfolderName);
        myVar = setInterval(function() {
            TLF()
        }, TLInterval);
	socket.emit('Info', 'Time-lapse started');

    });

    socket.on('TLStop', function() {
        clearInterval(myVar);
        socket.emit('Info', 'Time-lapse stopped');

    });

});


http.listen(serverPort, function() {
    console.log('listening on *: ', serverPort); //


});
