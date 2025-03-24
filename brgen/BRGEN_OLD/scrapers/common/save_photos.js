'use strict';

var fs = require('fs'),
  path = require('path'),
  qs = require('querystring'),
  async = require('async'),
  mkdirp = require('mkdirp').sync,
  request = require('requestretry');

var photoedit = require('../../photoedit');

// Return photo URLs if scraping from a remote location
  
// TODO: Requires API integration

var returnPhotoURLs = false;

// Saves photos from given URLs and returns paths to them on filesystem

module.exports = function(photoUrls, config, cb) {
  photoUrls = photoUrls || [];

  if(returnPhotoURLs) {
    return cb(null, photoUrls);
  }

  var photoDirectory = config.photos;

  if(!photoDirectory) {
    return cb(new Error('Missing photo directory'));
  }

  var effects = config.effects || [];

  mkdirp(photoDirectory);

  async.mapLimit(photoUrls.filter(id), 4, function(bp, cb) {
    var base = bp.split('/'),
      name = qs.escape(base[base.length - 1] || base[base.length - 2]),
      op = path.join(photoDirectory, name),
      pp = path.join(photoDirectory, 'edited_' + name);

    // Use `requestretry` in case of failing images

    // https://npmjs.com/package/requestretry

    var r = request({ url: bp, maxAttempts: 10, retryDelay: 20000 }, function(err) {
      if(err) {
        return console.error('Failed to fetch', bp);
      }
    }).pipe(fs.createWriteStream(op));

    r.on('finish', function() {
      photoedit(op, pp, effects, function(err, out) {
        if(err) {
          return cb();
        }

        cb(null, {
          'original_photo': op,
          'processed_photo': out
        });
      });
    });
  }, function(err, d) {
    if(err) {
      return cb(err);
    }

    cb(null, d.filter(id));
  });
};

function id(a) { return a; }

