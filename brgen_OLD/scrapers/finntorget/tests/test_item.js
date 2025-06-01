'use strict';

var assert = require('assert');

var read = require('./utils').read,
  item = require('../scrapers/item');

tests();

function tests() {
  testItem();
  testUbrukt();
  testBaby();
}

function testItem() {
  read('item', function(data) {
    item(data, function(err, item) {
      if(err) {
        return console.error(err);
      }

      assert.deepEqual(item, {
        title: 'Signert oljemalert av Tove Jensen, 2005',
        price: 'kr 500,-',
        description: 'Maleriet er 30 cm høyt og 40 cm bredt.',
        generalInfo: '## Generell info\n\nProduktet befinner seg i Galleri Oslo Sentrum i Tullinsgate 6 (se adressedetaljer til høyre.)  \nÅpningstider: Mandag, tirsdag, onsdag og fredag 11-17. Torsdag 11-18 og lørdag 11-15.  \n\n\nDenne varen er gitt vederlagsfritt til Normisjons gjenbruksbutikk og inntekten går til Normisjons internasjonale arbeid.   \nØnsker du å bidra med en vare, kontakt oss på telefonnummeret øverst til høyre på annonsen.',
        homepage: 'http://normisjon.no/index.php?kat_id=5351',
        phone: '452 13 572'
      });
    });
  });
}

function testUbrukt() {
  read('ubrukt', function(data) {
    item(data, function(err, item) {
      if(err) {
        return console.error(err);
      }

      assert.equal(item.title, 'Ubrukt City bag Supreme 2014');
      assert.equal(item.description.indexOf('## Beskrivelse'), -1);
    });
  });
}

function testBaby() {
  read('baby', function(data) {
    item(data, function(err, item) {
      if(err) {
        return console.error(err);
      }

      assert.equal(item.description, 'Høst jakke til baby str 74 \n\nTilstand: Brukt');
    });
  });
}

