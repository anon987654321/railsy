'use strict';

var fs = require('fs');

var caman = require('caman').Caman,
  mmm = require('mmmagic'),
  magic = new mmm.Magic(mmm.MAGIC_MIME_TYPE);

require('seedrandom');

// Alternatively a symlink could be used

// Will break if the directory structure changes

var filters = require('../../app/assets/javascripts/photo_filters');

filters.registerFilters(caman);

function convert(input, output, effects, cb) {
  cb = cb || noop;

  var stack = filters.initializeStack({
    initialStack: effects
  }, filters.getFilters());

  magic.detectFile(input, function(err, format) {
    if(err) {
      return cb(err);
    }

    if(format === 'image/jpeg' || format === 'image/png') {
      caman(input, function() {
        filters.renderFilters({
          finishCb: function(c) {
            c.save(output);

            cb(null, output);
          }
        }, this, stack);
      });
    } else if(format === 'image/gif') {

      // Don't edit

      cb();
    } else {
      cb(new Error('Invalid image format'));
    }
  });
}
module.exports = convert;

function noop() {}

