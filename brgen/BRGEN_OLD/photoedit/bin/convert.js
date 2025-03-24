#!/usr/bin/env node
'use strict';

var VERSION = require('../package.json').version;

var program = require('commander');
var convert = require('../lib/convert');

program.
  version(VERSION).
  option('-i, --input <input image>').
  option('-f, --fx <effects JSON>').
  option('-o, --output <output image>').
  option('-s, --silent').
  parse(process.argv);

main(program);

function main(p) {
  var out = p.silent? id: console.log;

  out('photoedit ' + VERSION + '\n');

  if(!p.input) {
    return console.log('Missing input');
  }
  if(!p.output) {
    return console.log('Missing output');
  }
  if(!p.fx) {
    return console.log('Missing effects');
  }

  convert(p.input, p.output, require('../' + p.fx), out);
}

function id(a) { return a; }

