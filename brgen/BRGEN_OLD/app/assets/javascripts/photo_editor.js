$(function() {
  var maxValue;

  if(GLOBAL_CONFIG.isDesktop) {
    maxValue = 640;
  } else {
    maxValue = 290;
  }

  var CONFIG = {
    initialStack: [
      // { filter: 'careful_massage', value: 25 },
      { filter: 'film_grain', value: 20 }
    ],
    layers: {
      amount: 3
    },
    preview: {
      maxHeight: maxValue,
      maxWidth: maxValue
    }
  };

  /* -------------------------------------------------- */

  registerFilters(Caman);

  /* -------------------------------------------------- */

  $.fn.photoEditor = function(options) {
    function _t(n) {
      return I18n.t(n);
    }

    init(options);

    function init(o) {
      if(!o.$image) return o.done('No image provided');
      if(!o.initialStack) o.initialStack = CONFIG.initialStack;
      if(!o.init) o.init = noop;

      var type = o.$image.data('type');

      // TODO: remove once you know check against type works
      console.log('image type', type);

      // if this doesn't work, we can try to check out against extension
      // data('name').split('.').slice(-1)
      if(type === 'image/gif' || type === 'video/mpeg') {
        return storeData(o, [], o.done);
      }

      initUI(o);
    }

    /* -------------------------------------------------- */

    function initUI(o) {
      o.$parent.empty();
      o.$parent.append($(o.template));

      attachElements(o);

      loadControls(o, o.$image, o.init);
    }

    /* -------------------------------------------------- */

    function attachElements(o) {
      var $p = o.$parent;

      o.$photoContainer = $('#photo_container', $p);
      o.$canvas = $('#edited_photo', $p);
      o.$preview = $('#preview_photo', $p);
      o.$effects = $('#effects', $p);
      o.$apply = $('#apply_effects', $p);
      o.$skip = $('#skip', $p);
      o.$crop = $('#crop_photo', $p);
    }

    /* -------------------------------------------------- */

    function loadControls(o, $image, done) {
      var filters = getFilters(_t),
        stack = initializeStack(o, filters, CONFIG.layers.amount);

      loadImage(o, $image, function(err) {
        if(err) return done(err);

        initFiltersUI(o, stack);
        initApply(o, stack);
        initSkip(o);
        initCrop(o);

        done();
      });
    }

    /* -------------------------------------------------- */

    function initApply(o, stack) {
      o.$apply.on('tap', function() {
        storeData(o, stack, o.done);
      });
    }

    function initSkip(o) {
      o.$skip.on('tap', function() {
        storeData(o, [], o.done);
      });
    }

    /* -------------------------------------------------- */

    function initCrop(o) {
      o.$photoContainer.on('mousemove touchmove', function(e) {
        if(!isProcessing()) {
          var parentOffset = $(this).parent().offset(),
            cw = o.$canvas.width(),
            w = e.pageX - parentOffset.left;

          o.$crop.css('width', cw - w);
          o.$canvas.css('margin-left', -w);
        }
      });
    }

    /* -------------------------------------------------- */

    function isProcessing() {
      return $('.processing').first().is(':visible');
    }

    /* -------------------------------------------------- */

    function loadImage(o, $image, done) {
      resize($image, CONFIG.preview.maxWidth, CONFIG.preview.maxHeight, function(err, data) {
        if(err) return done(err);

        o.$preview.attr({
          src: data
        }).on('load', function() {
          o.$preview.css({
            'margin-bottom': -o.$preview[0].height
          });

          done();
        }).on('error', function() {
          done('Failed to load photo');
        });
      });
    }

    /* -------------------------------------------------- */

    function storeData(o, stack, done) {
      done = done || noop;

      var $image = o.$image,
        caman = Caman(o.$canvas[0], $image.attr('src'));

      evaluateStack(o, caman, stack, function() {
        var imageName = $image.data('name');

        done(null, {
          $image: o.$image,
          imageName: imageName,
          imageData: imageToCanvas($image[0]),
          canvasName: 'processed_' + imageName,
          canvasData: o.$canvas[0],
          stack: cloneArray(stack)
        });
      });
    }

    /* -------------------------------------------------- */

    function cloneArray(a) {
      return a.slice();
    }

    /* -------------------------------------------------- */

    function initFiltersUI(o, stack) {
      var $p = o.$effects,
        i, len;

      var caman = Caman(o.$canvas[0], o.$preview.attr('src'), function() {
        evaluator();
      });

      var evaluator = evaluateStack.bind(undefined, o, caman, stack);

      for(i = 0, len = stack.length; i < len; i++) {
        initFilter($p, stack[i], evaluator);
      }
    }

    /* -------------------------------------------------- */

    function initFilter($p, layer, evaluator) {
      var selIndex = layer.selectedFilter || 0;

      if(GLOBAL_CONFIG.isDesktop){
        var $div = $('<div>', { 'class': 'effect' }).appendTo($p),
          $filters = $('<select>', { 'class': 'filters' }).appendTo($div),
          filter = layer[selIndex];

        var $range = initializeRange(filter, evaluator).appendTo($div);

        if(!selIndex) {
          $range.hide();
        }

        $filters.on('change', function() {
          var i = $('option:selected', $(this)).index();

          layer.selectedFilter = i;
          filter = layer[i];

          if(filter.id == 'none') {
            $range.hide();
          } else {
            $range.attr({
              min: filter.min,
              max: filter.max
            }).trigger('change').val(filter.value).show();
          }

          evaluator();
        });

        $.each(layer, function(i, f) {
          $('<option>', {
            'class': 'filter',
            selected: selIndex == i && 'selected',
            value: f.id
          }).text(f.name).appendTo($filters);

          if(selIndex == i) {
            filter = f;
          }
        });
      } else {
        var $layer = $('<div>', { 'class': 'layer' }).appendTo($p),
          $previousNext = $('<div>', { 'class': 'previous_next' }).appendTo($layer),
          $previous = $('<a>', { 'class': 'previous' }).text(_t('previous')).appendTo($previousNext),
          $next = $('<a>', { 'class': 'next' }).text(_t('next')).appendTo($previousNext),
          $slides = $('<div>', { 'class': 'slides' }).appendTo($layer);

        $.each(layer, function(i, filter) {
          var $filterContainer = $('<div>', { 'class': 'filter' })
            .appendTo($slides), filterId = 'filter_' + i, $filter;

          $('<label>', { 'for': filterId }).text(filter.name).appendTo($filterContainer);

          $filter = initializeRange(filter, evaluator).appendTo($filterContainer);

          if(!filter.min || !filter.max) {
            $filter.attr('disabled');
          }

          $filter.attr('name', filterId);
          $filter.bind('update', evaluator);
        });

        $layer.caro({
           cycle: true,
           initialSlide: selIndex
        }).on('updateSlide', function(e, currentSlide) {
          layer.selectedFilter = currentSlide;

          evaluator();
        });
      }
    }

    // iOS7 range sliders

    // http://goo.gl/R5V0cZ

    function initializeRange(filter, evaluator) {
      return $('<input>', {
        'class': 'range',
        type: 'range',
        step: 1,
        min: filter.min || 0,
        max: filter.max || 100
      }).bind('input change', function(event) {
        var item = event.target,
          value = (item.value - item.min) / (item.max - item.min);

        $(this).css(
          'background-image',
          '-webkit-gradient(linear, left top, right top, color-stop(' + value + ', #007aff), color-stop(' + value + ', #b8b7b8)'
        );
      }).val(filter.value).on('mouseup', function() {
        filter.value = parseInt($(this).val(), 10);

        evaluator();
      }).trigger('change');
    }

    /* -------------------------------------------------- */

    function resize($source, w, h, cb) {
      var canvas = $('<canvas>')[0],
        ctx = canvas.getContext('2d');

      var img = new Image();

      img.onload = function() {
        var ratio = img.width / img.height;

        if(ratio > 1) h = w / ratio;
        else w = h * ratio;

        h = Math.min(h, img.height);
        w = Math.min(w, img.width);

        canvas.width = w;
        canvas.height = h;

        ctx.drawImage(img, 0, 0, img.width, img.height, 0, 0, w, h);

        cb(null, canvas.toDataURL('image/png'));
      };

      img.src = $source.attr('src');
    }

    /* -------------------------------------------------- */

    function imageToCanvas(image) {
      var $canvas = $('<canvas>', { width: image.width, height: image.height }),
        canvas = $canvas[0],
        ctx = canvas.getContext('2d');

      ctx.drawImage(image, 0, 0);

      return canvas;
    }

    /* -------------------------------------------------- */

    function evaluateStack(o, caman, stack, done) {
      done = done || noop;

      var processingClass = 'processing',
        $progress = $getProgress(o.$photoContainer, o.$preview);

      renderFilters({
        startCb: function() {
          console.log('Evaluating stack', stack);

          // NProgress.start();

          $progress.show();

          o.$canvas.addClass(processingClass);
        },
        evalCb: function(c, i) {
          // NProgress.set(i);
        },
        finishCb: function() {
          // NProgress.done();

          $progress.hide();

          o.$canvas.removeClass(processingClass);

          console.log('Finished processing');

          done();
        }
      }, caman, stack);
    }

    /* -------------------------------------------------- */

    function $getProgress($p, $preview) {
      var $e = $('.progress:first', $p);

      if(!$e.length) $e = $('<div>', { 'class': 'progress' }).prependTo($p);

      return $e.width($preview.width()).height($preview.height());
    }

    function noop() {}
  };
});

