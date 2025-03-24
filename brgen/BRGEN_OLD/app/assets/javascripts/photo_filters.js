function getFilters(_t) {
  _t = _t || function() {};

  // Warning: Renaming IDs will render old data obsolete

  return replaceRenders([

    // Usage: filter(<id>, <i18n id>)

    none('none', 'photo_editor_js.choose_effect'),

    // TODO: Tweak `lowerBound` and `upperBound`

    // carefulMassage('careful_massage', 'photo_editor_js.careful_massage'),
    filmGrain('film_grain', 'photo_editor_js.film_grain'),
    colorWaves('color_waves', 'photo_editor_js.color_waves'),
    winterNight('winter_night', 'photo_editor_js.winter_night'),
    that70sShow('that_70s_show', 'photo_editor_js.that_70s_show'),
    that70sShowBw('that_70s_show_bw', 'photo_editor_js.that_70s_show_bw'),
    studioShoot('studio_shoot', 'photo_editor_js.studio_shoot'),
    studioShootBw('studio_shoot_bw', 'photo_editor_js.studio_shoot_bw')
  ]);

  /* -------------------------------------------------- */

  function replaceRenders(filters) {
    for(var i = 0, len = filters.length; i < len; i++) {
      var filter = filters[i];

      if(filter.min || filter.max) replaceRange(filter);
    }

    function replaceRange(filter) {
      var oldRender = filter.render;

      if(oldRender) {
        filter.render = function(filters, c) {
          return oldRender(filters, c, filter.value);
        };
      }
      else {
        filter.render = function(filters, c) {
          return c;
        };
      }
    }

    return filters;
  }

  function none(id, i18n) {
    return {
      name: _t(i18n), id: id,
      render: noop
    };
  }

  /* -------------------------------------------------- */

  function carefulMassage(id, i18n) {

    // http://goo.gl/urzQkp

    // http://goo.gl/f9AjNA

    return {
      name: _t(i18n), id: id,
      value: 50, min: 0, max: 70,
      render: colorFilter(function(c) {
        c.filter.carefulMassage();
      })
    };
  }

  /* -------------------------------------------------- */

  function filmGrain(id, i18n) {

    // http://goo.gl/rWjUzO

    // http://goo.gl/k4Ldjg

    return {
      name: _t(i18n), id: id,
      value: 10, min: 0, max: 40,
      render: function(filters, c, v) {
        return c.newLayer(function() {
          this.setBlendingMode('overlay');

          this.fillColor('#777777');
          this.filter.noise(70);
          this.filter.stackBlur(1);

          this.opacity(v);
        });
      }
    };
  }

  /* -------------------------------------------------- */

  function colorWaves(id, i18n) {

    // http://goo.gl/U40G5A

    return {
      name: _t(i18n), id: id,
      value: 50, min: 0, max: 100,
      render: function(filters, c, v) {
        return c.newLayer(function() {
          var a = v / 100 * 0.7;
          var c1 = { r: 220, g: 205, b: 214 };
          var c2 = { r: 236, g: 228, b: 196 };

          this.setBlendingMode('softLight');

          this.filter.horizontalGradient(
            [0, extend(c1, { a: a / 3 })],
            [0.15, extend(c1, { a: a })],
            [0.30, extend(c1, { a: a / 3 })],
            [0.40, extend(c2, { a: a / 3 })],
            [0.65, extend(c2, { a: a })],
            [0.90, extend(c2, { a: a / 3 })],
            [1, { r: 0, g: 0, b: 0, a: 0 }]
          );
        });
      }
    };

    function extend(a, b) {
      var ret = {};

      for(var o in a) {
        ret[o] = a[o];
      }

      for(var o in b) {
        ret[o] = b[o];
      }

      return ret;
    }
  }

  /* -------------------------------------------------- */

  function winterNight(id, i18n) {

    // http://goo.gl/KUApmm

    return {
      name: _t(i18n), id: id,
      value: 50, min: 0, max: 100,
      render: colorFilter(function(c) {
        c.filter.curves('rgb', [0, 0], [85, 140], [255, 255], [255, 255]).
          curves('g', [0, 0], [70, 100], [150, 170], [255, 255]).
          curves('b', [0, 0], [30, 200], [50, 230], [255, 255]);
        c.newLayer(function() {
          this.setBlendingMode('multiply');
          this.opacity(100);

          this.fillColor('#fadcaf');
        });
      })
    };
  }

  /* -------------------------------------------------- */

  // http://goo.gl/4pzuY5

  function that70sShow(id, i18n) {
    return {
      name: _t(i18n), id: id,
      value: 50, min: 0, max: 100,
      render: colorFilter(that70sShowCore)
    };
  }

  function that70sShowBw(id, i18n) {
    return {
      name: _t(i18n), id: id,
      value: 50, min: 0, max: 100,
      render: colorFilter(function(c) {
        that70sShowCore(c);

        c.filter.greyscale();
        c.filter.brightness(-20);
        c.filter.contrast(80);
      })
    };
  }

  function that70sShowCore(c) {
    c.newLayer(function() {
      this.copyParent();
      this.filter.curves('rgb', [1, 54], [41, 60], [125, 140], [255, 224]);
      this.filter.colorize(150, 150, 0, 5);
      this.filter.brightness(20);
      this.filter.contrast(-9);

      c.newLayer(function() {
        this.setBlendingMode('overlay');
        this.opacity(30);

        this.copyParent();

        this.filter.channels({ red: 80, green: 50 });
        this.filter.saturation(100);
      });
    });
  }

  /* -------------------------------------------------- */

  // http://goo.gl/A9lZXZ

  function studioShoot(id, i18n) {
    return {
      name: _t(i18n), id: id,
      value: 50, min: 0, max: 100,
      render: colorFilter(function(c) {
        c.filter.saturation(-25);
        c.filter.curves('r', [0, 0], [49, 37], [175, 192], [255, 255]).curves('g', [0, 10], [46, 39], [176, 192], [255, 255]).curves('b', [1, 26], [43, 47], [200, 213], [255, 255]);
      })
    };
  }

  function studioShootBw(id, i18n) {
    return {
      name: _t(i18n), id: id,
      value: 50, min: 0, max: 100,
      render: colorFilter(function(c) {
        c.filter.greyscale();

        c.newLayer(function() {
          this.setBlendingMode('screen');
          this.opacity(40);
          this.copyParent();
          this.filter.sepia(100);
          this.filter.contrast(40);
        });
      })
    };
  }

  /* -------------------------------------------------- */

  function colorFilter(fn) {
    return function(filters, c, v) {
      return c.newLayer(function() {
        this.opacity(v);
        this.copyParent();

        fn(this, v);
      });
    };
  }

  function noop() {}
}
if(typeof exports !== "undefined") exports.getFilters = getFilters;

/* -------------------------------------------------- */

function registerFilters(caman) {
  caman.Plugin.register('horizontalGradient', function() {
    var w = this.dimensions.width,
      args = [],
      i, arg;

    // Parse arguments

    for(i = 0; i < arguments.length; i++) {
      arg = arguments[i];

      args.push({
        x: arg[0] * w,
        rgba: arg[1]
      });
    }

    var gradient = calculateGradient(args, w);

    this.process('horizontalGradient', function(rgba) {
      var x = rgba.locationXY().x,
        val = gradient[x],
        fac = val.a,
        nfac = 1 - fac;

      rgba.r = rgba.r * nfac + val.r * fac;
      rgba.g = rgba.g * nfac + val.g * fac;
      rgba.b = rgba.b * nfac + val.b * fac;

      return rgba;
    });

    function calculateGradient(values, length) {
        var ret = [],
          cur = 0,
          i, next, v1, v2;

        for(i = 0; i < length; i++) {
          v1 = values[cur];
          v2 = values[cur + 1];

          ret.push(lerp(v2.rgba, v1.rgba, (i - v1.x) / (v2.x - v1.x)));

          if(i > v2.x) {
            cur++;
          }
        }

        return ret;
    }

    function lerp(a, b, fac) {
        var nFac = 1 - fac;

        return {
            r: a.r * fac + b.r * nFac,
            g: a.g * fac + b.g * nFac,
            b: a.b * fac + b.b * nFac,
            a: a.a * fac + b.a * nFac
        };
    }
  });

  /* -------------------------------------------------- */

  caman.Filter.register('horizontalGradient', function() {
    this.processPlugin('horizontalGradient', arguments);
  });

  /* -------------------------------------------------- */

  caman.Filter.register('carefulMassage', function() {
    var canvas = this.canvas,
      hist = initArray(256, 0),
      lowerBound = Math.ceil(256 * 0.05),
      upperBound = Math.floor(256 * 0.95),
      a = 10,
      b = 10,
      pixels, i, len, data, ctx;

    ctx = canvas.getContext('2d');
    data = ctx.getImageData(0, 0, ctx.canvas.width, ctx.canvas.height);
    pixels = data.data;

    for(i = 0, len = pixels.length; i < len; i += 4) {

      // Luminosity grayscale + histogram

      hist[0.21 * pixels[i] + 0.71 * pixels[i + 1] + 0.07 * pixels[i + 2]]++;
    }

    var lowerSum = hist.slice(0, lowerBound).reduce(add),
      upperSum = hist.slice(0, upperBound).reduce(add);

    var contrast = 255 / (upperSum - lowerSum) * a,
      intensity = 255 * lowerSum / (upperSum - lowerSum) * -b;

    this.process('carefulMassage', function(rgba) {
      rgba.r = rgba.r * contrast + intensity;
      rgba.g = rgba.g * contrast + intensity;
      rgba.b = rgba.b * contrast + intensity;

      return rgba;
    });

    function add(a, b) { return a + b; }
    function initArray(len, val) {
      var ret = [];

      for(var i = 0; i < len; i++) ret.push(val);

      return ret;
    }
  });
}
if(typeof exports !== "undefined") exports.registerFilters = registerFilters;

/* -------------------------------------------------- */

function renderFilters(o, caman, stack) {
  if(!caman) return console.error('Caman object was not passed to renderFilters');

  stack = stack? stack.slice().reverse(): [];

  var startCb = o.startCb || noop,
    finishCb = o.finishCb || noop,
    evalCb = o.evalCb || noop;

  // Do not change the seed or it will break rendering

  Math.seedrandom('default');
  startCb();

  caman.revert(false);

  // Evaluate

  var step = 1 / stack.length,
    i = 0;

  caman.newLayer(function() {
    stack.forEach(evalLayer.bind(null, this));
  });

  function evalLayer(c, layer) {
    var filter = layer[layer.selectedFilter];

    if(!filter) return;
    if(filter.id != 'none') c.copyParent();

    c.setBlendingMode('normal');

    filter.render(layer, c);

    i += step;

    evalCb(c, i);
  }

  caman.render(function() {
    finishCb(this);
  });

  function noop() {}
}
if(typeof exports !== "undefined") exports.renderFilters = renderFilters;

/* -------------------------------------------------- */

function initializeStack(o, filters, amount) {
  if(o.stack && o.stack.length > 0) return o.stack;
  if(!o.initialStack) return console.warn('Missing `o.initialStack` at `initializeStack`');
  if(!amount) amount = o.initialStack.length;

  var ret = [],
    arr, initial, filter;

  for(var i = 0; i < amount; i++) {
    arr = cloneArray(filters);
    initial = o.initialStack[i];

    if(initial && initial.filter) {
      arr.selectedFilter = getFilterIndex(filters, initial.filter);

      filter = arr[arr.selectedFilter];

      if(!filter) console.warn('Missing filter', initial.filter);
      else if(!initial) console.warn('Initial filter ID not found', initial);
      else if(initial.value) filter.value = initial.value;
    }

    ret.push(arr);
  }

  return ret;

  function getFilterIndex(filters, name) {
    var i, len;

    for(i = 0, len = filters.length; i < len; i++) {
      if(filters[i].id == name) return i;
    }
  }

  function cloneArray(a) {
    return a.slice();
  }
}
if(typeof exports !== "undefined") exports.initializeStack = initializeStack;

