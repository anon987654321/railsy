'use strict';

var async = require('async'),
  cheerio = require('cheerio'),
  getText = require('../../common/get_text');

module.exports = function(data, cb) {
  var $ = cheerio.load(data);

  async.map($('#productDetailRowTop .productDetail .description').toArray(),
    function(e, cb) {
      getText($, $(e), false, cb);
    },
    function(err, d) {
      if(err) {
        return cb(err);
      }

      cb(null, d.join('\n'));
    }
  );
};
