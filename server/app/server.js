// sudo udevadm control --reload-rules
// to refresh the port allocation

//--------------- Requires ---------------

var nconf = require('nconf');
nconf.argv()
       .env()
       .file({ file: __dirname + '/config.json' });

var nodeLib = nconf.get('server:nodeLib');

var events = require('events');
var eventEmitter = new events.EventEmitter();
var express = require('/usr/local/lib/node_modules/express');
var app = express();
var http = require('http').Server(app);
var fs = require(nodeLib + 'safefs');
var piblaster = require(nodeLib + 'pi-blaster.js');
var bunyan = require(nodeLib + 'bunyan');
var io = require('/usr/local/lib/node_modules/socket.io')(http);

//--------------- Variable definition ---------------


var logfilePath = nconf.get('server:logfilePath');
var TLFolder = nconf.get('server:TLFolder');
var SNFolder = nconf.get('server:SNFolder');
var SEPARATOR = nconf.get('telemetry:SEPARATOR');
var installPath = nconf.get('server:installPath');
var serverPort = nconf.get('server:serverPort');
var version = nconf.get('server:version');
var MJPGPort = nconf.get('MJPG:MJPGPort');
var sys = require('sys');
var exec = require('child_process').exec;

var pw = nconf.get('hardware:pw'); // pulsewidth in microseconds
var SERVO_1_GPIO = nconf.get('hardware:SERVO_1_GPIO');
var SERVO_2_GPIO = nconf.get('hardware:SERVO_2_GPIO');

var TLimgWidth = nconf.get('camera:TLimgWidth'); 
var TLimgHeight = nconf.get('camera:TLimgHeight'); 
var SNimgWidth = nconf.get('camera:SNimgWidth'); 
var SNimgHeight = nconf.get('camera:SNimgHeight'); 
var TLInterval = nconf.get('camera:TLInterval'); 


var serverADDR = 'N/A';
var TLIntervalVar = "";

//--------------- Logging middleware ---------------
var log = bunyan.createLogger({
  name: 'Pi-Cam',
  streams: [
    /*{
      level: 'debug',
      stream: process.stdout            // log INFO and above to stdout
    },*/
    //Log should be outside app folders
    {
      path: logfilePath + 'PiCamlog.log'  // log ERROR and above to a file
    }
  ]
});


//--------------------------------------


//Get IP address and saves to serverADDR (http://stackoverflow.com/questions/3653065/get-local-ip-address-in-node-js)
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


//--------------- Custom functions & routes---------------
var systemModules = require(installPath + 'server/app/systemModules');
var functions = require(installPath + 'server/app/functions');
var camera = require(installPath + 'server/app/camera');

require('./routes')(app);



//--------------- Main application ---------------


var mkdirSync = function(path) {
    try {
        fs.mkdirSync(path);
    } catch (e) {
        if (e.code != 'EEXIST') throw e;
    }
}

app.use(express.static(installPath + 'server/wwwroot'));
io.on('connection', function(socket) {
      var myDate = new Date();
   
   var startMessage = 'Connected ' + myDate.getHours() + ':' + myDate.getMinutes() + ':' + myDate.getSeconds()+ ' v' + version + ' @' + serverADDR;
     socket.emit('connected', startMessage, serverADDR, serverPort, MJPGPort);
   socket.emit('serverADDR', serverADDR);
    console.log('New socket.io connection - id: %s', socket.id);
    //socket.emit('serverADDR', require('os').networkInterfaces().eth0[0].address);

    function puts(error, stdout, stderr) {
        sys.puts(stdout)
    }
    exec('sudo /home/pi/pi-blaster/pi-blaster 4 17');



    socket.on('Video', function(Video) {
        socket.emit('CMD', Video);
        //console.log(Video);

        function puts(error, stdout, stderr) {
            sys.puts(stdout)
        }
        exec('sudo bash ' + installPath + 'server/app/bin/' + Video, puts);
    });


    socket.on('REBOOT', function() {
        function puts(error, stdout, stderr) {
            sys.puts(stdout)
        }
        exec('sudo reboot now');
        sockets.emit('Info', "Rebooting")
    });

    socket.on('move', function(dX, dY) {
        piblaster.setPwm(17, (rescale(parseFloat(dX), -100, 100, 0.07, 0.20)));
        piblaster.setPwm(4, (rescale(parseFloat(dY), -100, 100, 0.06, 0.19)));
	
	//console.log(rescale(parseFloat(dY),-50,50,0.06,0.15));
        //console.log(rescale(parseFloat(dX),-100,100,0.07,0.20));
    });

    socket.on('TLInterval', function(T) {
        TLInterval = T * 1000;
        socket.emit('Info', 'timelapse set to ' + TLInterval/1000 + 's')
    });

    socket.on('TLStart', function() {
      startTL(TLimgWidth, TLimgHeight, TLInterval, TLFolder, functions.timeStamp()) 
  
        //socket.emit('Info', 'Time-lapse started' + fileName + '.jpg');
        socket.emit('Folder', TLfolderName);
       });

    socket.on('TLStop', function() {
        clearInterval(TLIntervalVar);
        socket.emit('Info', 'Time-lapse stopped');

    });
    
    eventEmitter.on('Folder', function(Folder) {
        
        socket.emit('Folder', Folder);

    });
    
    eventEmitter.on('Info', function(info) {
        
        socket.emit('Info', info);

    });

    socket.on('takeSnapShot', function() {
	//snapShot(SNimgWidth, SNimgHeight, SNFolder, 'SN_' + timeStamp());
    	snapShot(SNimgWidth, SNimgHeight, SNFolder, 'SN_' + functions.timeStamp(), serverADDR, MJPGPort)

    });

});


http.listen(serverPort, function() {
    console.log('listening on ' + serverADDR + ':' + serverPort); //
});

function startTL(imgWidth, imgHeight, TLInterval, TLFolder, timeStamp) {
       TLfolderName = TLFolder + 'TL_' + timeStamp;
       TLfileName = 'TL_' + timeStamp;
       fs.mkdir(TLfolderName);
       
       //console.log(TLfolderName);
       //log.info('Time-Lapse started ' + TLFolder + 'TL_' + timeStamp);
             eventEmitter.emit('Folder', TLfolderName + '.jpg');
       TLIntervalVar = setInterval(function() {
           snapShot(imgWidth, imgHeight, TLfolderName, functions.timeStamp())
       }, TLInterval);

   }
   

  

function snapShot(imgWidth, imgHeight, folderName, fileName) {

  function puts(error, stdout, stderr) {
        sys.puts(stdout)
    }
    exec('sudo raspistill -w ' + imgWidth + ' -h ' + imgHeight + ' -o ' + folderName + '/' + fileName + '.jpg  -sh 40 -awb auto -mm average -v');
    //console.log('sudo raspistill -w ' + imgWidth + ' -h ' + imgHeight + ' -o ' + TLfolderName + '/' + TLfileName + '_' + MyTimeStamp +  '.jpg  -sh 40 -awb auto -mm average -v');
    eventEmitter.emit('Info', fileName + '.jpg');
    eventEmitter.emit('Folder', folderName);

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
