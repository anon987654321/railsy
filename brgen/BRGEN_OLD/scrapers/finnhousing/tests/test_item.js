'use strict';

var assert = require('assert');

var read = require('./utils').read,
  item = require('../scrapers/item');

tests();

function tests() {
  testStjern();
  testMinde();
}

function testStjern() {
  read('stjern', function(data) {
    item(data, function(err, result) {
      if(err) {
        return console.error(err);
      }

      assert.equal(result.title, 'SJØSTJERNEN - 31 eksklusive leiligheter med fantastisk utsikt mot fjorden, sentrum og byfjellene.');

      assert.equal(result.address.address, 'SJØSTJERNEN');
      assert.equal(result.address.zip, '5058 Bergen');

      assert.equal(result.details.price1, '3 890 000,-');
      assert.equal(result.details.price2, '10 290 000,-');
      assert.equal(result.details.size, '66 - 161 m²');
      assert.equal(result.details.type, 'Leilighet');
      assert.equal(result.details.bedrooms, '2 - 4');
      assert.equal(result.details.tenure, 'Eier (Selveier)');

      // source link cannot be scraped. instead, it has to be injected at a higher level where the request is made
      //assert.equal(result.details['source_link'], 'http://m.finn.no/realestate/newbuildings/ad.html?finnkode=58041120&location=1.20013.20220&location=0.20013&ref=fas');

      assert.equal(result.contacts.length, 2);

      assert.equal(result.contacts[0].name, 'Kari Berland');
      assert.equal(result.contacts[0].role, 'Avdelingsleder nybygg / Megler MNEF');
      assert.equal(result.contacts[0].phone, '+4741073038');
      assert.equal(result.contacts[0]['contact_link'], 'http://m.finn.no/realestate/newbuildings/contact.html?finnkode=58041120&ci=0');

      assert.equal(result.contacts[1].name, 'Sissel Brattfjord');
      assert.equal(result.contacts[1].role, 'Jurist / Megler MNEF, nybygg');
      assert.equal(result.contacts[1].phone, '+4748223642');
      assert.equal(result.contacts[1]['contact_link'], 'http://m.finn.no/realestate/newbuildings/contact.html?finnkode=58041120&ci=1');
    });
  });
}

function testMinde() {
  read('minde', function(data) {
    item(data, function(err, result) {
      if(err) {
        return console.error(err);
      }

      assert.equal(result.title, 'MINDE - 20 attraktive og urbane leiligheter like ved bybanen. Byggestart vedtatt!');

      assert.equal(result.address.address, 'WERGELAND HAGE');
      assert.equal(result.address.zip, '5063 Bergen');

      assert.equal(result.details.price1, '2 900 000,-');
      assert.equal(result.details.price2, '7 290 000,-');
      assert.equal(result.details.size, '58 - 129 m²');
      assert.equal(result.details.type, 'Leilighet');
      assert.equal(result.details.bedrooms, '1 - 4');
      assert.equal(result.details.tenure, 'Eier (Selveier)');

      assert.equal(result.contacts.length, 2);

      assert.equal(result.contacts[0].name, 'Thor Kristian Johannessen');
      assert.equal(result.contacts[0].role, '');
      assert.equal(result.contacts[0].phone, '+4791688655');
      assert.equal(result.contacts[0]['contact_link'], 'http://m.finn.no/realestate/newbuildings/contact.html?ci=0&ref=fas&finnkode=56877192&location=2.20013.20220.20465&location=1.20013.20220&location=0.20013');

      assert.equal(result.contacts[1].name, 'Dag Tore Raknes');
      assert.equal(result.contacts[1].role, '');
      assert.equal(result.contacts[1].phone, '+4791688655');
      assert.equal(result.contacts[1]['contact_link'], 'http://m.finn.nosms:+4795788885');
    });
  });
}
