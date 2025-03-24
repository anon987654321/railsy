'use strict';

var logic = require('../logic');

module.exports = function(o, cb) {
  o.pages = parseInt(o.pages, 10);

  logic.catalog(o, cb);
};

