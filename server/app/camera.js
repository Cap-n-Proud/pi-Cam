   var nconf = require('nconf');
nconf.argv()
    .env()
    .file({ file: __dirname + '/config.json' });

var nodeLib = nconf.get('server:nodeLib');
var exec = require('child_process').exec;
var debugLevel = nconf.get('server:debugLevel');
var fs = require(nodeLib + 'safefs');


   
 

   
   
   // exports ======================================================================
  //exports.snapShotTL = snapShotTL;
  //exports.snapShot = snapShot;
  //exports.startTL = startTL;
     
