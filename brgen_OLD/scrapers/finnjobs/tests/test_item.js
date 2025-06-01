'use strict';

var assert = require('assert');

var read = require('./utils').read,
  item = require('../scrapers/item');

tests();

function tests() {
  testSjuke();
  testDeltid();

  // testItem();
  // testButik();
  // testSalgs();
  // testStatoil();
  // testJysk();
}

function testSjuke() {
  read('sjuke', function(data) {
    item(data, function(err, item) {
      if(err) {
        return console.error(err);
      }

      assert.equal(item.title, 'Autorisert sjukepleiar');

      assert.equal(item.titles[0].name, 'Siren-Benedicte Dahl');
      assert.equal(item.titles[0].position, 'Seksjonsleiar');
      assert.equal(item.titles[0].phone, '55 97 61 88/ 55 97 21 45');

      assert.equal(item.titles[1].name, 'Vivian Milde Samdal');
      assert.equal(item.titles[1].position, 'Assisterande Avdelingssjukepleiar');
      assert.equal(item.titles[1].phone, '55 97 05 39/ 55 97 21 45');

      assert.equal(item.company, 'Helse Bergen - Hjarteavdelinga');
      assert.equal(item.address.po, '5021 Bergen');
      assert.equal(item.jobTitle, 'Autorisert sjukepleiar');
      assert.equal(item.starts, '');
      assert.equal(item.sector, 'Offentlig');
      assert.equal(item.duration, 'Fast');
    });
  });
}

function testDeltid() {
  read('deltid', function(data) {
    item(data, function(err, item) {
      if(err) {
        return console.error(err);
      }

      assert.equal(item.titles[0].name, 'Butikksjef Odd Ystebø');
      assert.equal(item.titles[0].phone, '55 93 59 60');

      assert.equal(item.company, 'Dressmann');
      assert.equal(item.address.po, '5116 Ulset');
      assert.equal(item.jobTitle, 'Salgsmedarbeider deltid Dressmann');
      assert.equal(item.starts, 'November');
      assert.equal(item.sector, 'Privat');
      assert.equal(item.duration, 'Fast');
      assert.equal(item.positions, '11');
    });
  });
}

function testItem() {
  read('item', function(data) {
    item(data, function(err, item) {
      if(err) {
        return console.error(err);
      }

      assert.equal(item.title, 'Vil du jobbe i en ny og spennende barnehage?');
      assert.equal(item.company, 'Espira Gruppen AS');
      assert.equal(item.address.address, 'Hovinveien 37 E');
      assert.equal(item.address.po, '0576 Oslo');
      assert.equal(item.phone, '990 05 340');
      assert.equal(item.site, 'http://www.espira.no');
    });
  });
}

function testButik() {
  read('butik', function(data) {
    item(data, function(err, item) {
      if(err) {
        return console.error(err);
      }

      assert.equal(item.description.indexOf('#### '), -1);
    });
  });
}

function testSalgs() {
  read('salgs', function(data) {
    item(data, function(err, item) {
      if(err) {
        return console.error(err);
      }

      assert.equal(item.description.indexOf('\n\n**** \n'), -1);
    });
  });
}

function testStatoil() {
  read('statoil', function(data) {
    item(data, function(err, item) {
      if(err) {
        return console.error(err);
      }

      assert.equal(item.site, '');
    });
  });
}

function testJysk() {
  read('jysk', function(data) {
    item(data, function(err) {
      if(err) {
        return console.error(err);
      }
    });
  });
}

