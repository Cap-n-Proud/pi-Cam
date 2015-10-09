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
var io = require('/usr/local/lib/node_modules/socket.io')(http);
var sys = require('sys');
var exec = require('child_process').exec;

//--------------- Variable definition ---------------


var logfilePath = nconf.get('server:logfilePath');
var TLFolder = nconf.get('server:TLFolder');
var SNFolder = nconf.get('server:SNFolder');
var SEPARATOR = nconf.get('telemetry:SEPARATOR');
var installPath = nconf.get('server:installPath');
var serverPort = nconf.get('server:serverPort');
var version = nconf.get('server:version');
var videoFeedPort = nconf.get('MJPG:MJPGPort');
var sys = require('sys');
var exec = require('child_process').exec;

var serverADDR = 'N/A';
var myVar = "";

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
app.use(express.static(installPath + 'server/wwwroot'));

io.on('connection', function(socket) {
    
  console.log('New socket.io connection - id: %s', socket.id);
  

});


http.listen(serverPort, function() {
    console.log('listening on ' + serverADDR + ':' + serverPort); //
});