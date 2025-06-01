'use strict';
var upndown = require('upndown');

module.exports = function(content, cb) {
  var und = new upndown();

  und.convert(content, cb);
};
