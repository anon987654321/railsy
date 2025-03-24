'use strict';

var phantom=require('node-phantom-simple');

module.exports = function(url, cb) {
  phantom.create(function(err, ph) {
    if(err) {
      return cb(err);
    }

    ph.createPage(function(err, page) {
      if(err) {
        return cb(err);
      }

      page.open(url, function(err) {
        if(err) {
          return cb(err);
        }

        page.get('content', function(err, html) {
          if(err) {
            return cb(err);
          }

          ph.exit();

          cb(null, html);
        });
      });
    });
  });
};

