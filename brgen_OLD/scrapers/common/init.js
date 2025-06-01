'use strict';

var path = require('path');

module.exports = function(o, cb) {
  o.token = process.env['SCRAPERS_API_KEY'];

  if(!o.token) {
    return cb(new Error('Missing scraper `SCRAPERS_API_KEY`'));
  }

  if(!o.site) {
    return cb(new Error('Missing `site` field in configuration'));
  }

  if(!o['brgen_forum']) {
    return cb(new Error('Missing `brgen_forum id`'));
  }

  if(!o['effects']) {
    return cb(new Error('Missing effects'));
  }

  o.id = o['source_forum'];

  o.photos = o.photos || 'photos';
  o.photos = path.join(process.cwd(), o.photos, o.site);

  o.effects = require(path.resolve(o.effects));

  cb();
};

