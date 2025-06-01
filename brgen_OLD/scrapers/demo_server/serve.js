#!/usr/bin/env node
/* jshint browser: false */

'use strict';

var express = require('express');

main();

function main() {
  var app = express(),
    port = process.env.PORT || 3000;

  app.configure(function() {
    app.set('port', port);

    app.use(express.logger('dev'));

    app.use(express.json());

    app.use(app.router);
  });

  app.configure('development', function() {
    app.use(express.errorHandler());
  });

  app.post('/api/scraper/v1/topics', function(req, res) {
    if(authOk(req)) {
      var body = req.body;

      if(!body['forum_name']) {
        console.error('Missing forum_name!');

        return res.send(500);
      }

      console.log(JSON.stringify(body, null, 4));

      return res.send(200);
    }

    res.send(403);
  });

  process.on('exit', terminator);

  [
    'SIGHUP', 
    'SIGINT', 
    'SIGQUIT', 
    'SIGILL', 
    'SIGTRAP', 
    'SIGABRT', 
    'SIGBUS',
    'SIGFPE', 
    'SIGUSR1', 
    'SIGSEGV', 
    'SIGUSR2', 
    'SIGPIPE', 
    'SIGTERM'
  ].forEach(function(element) {
    process.on(element, function() { terminator(element); });
  });

  app.listen(port, function() {
    console.log('%s: Node (version: %s) %s started on %d...', Date(Date.now()), process.version, process.argv[1], port);
  });
}

function authOk(req) {
  return process.env['SCRAPERS_API_KEY'] === req.query['access_token'];
}

function terminator(sig) {
  if(typeof sig === 'string') {
    console.log('%s: Received %s - terminating Node server...',
      Date(Date.now()), sig);

    process.exit(1);
  }

  console.log('%s: Node server stopped.', Date(Date.now()) );
}

