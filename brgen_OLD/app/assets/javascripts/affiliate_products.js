$.affiliateProducts = {
  banner: function(container) {
    if(GLOBAL_CONFIG.isRootPath || GLOBAL_CONFIG.isForumShowPath || GLOBAL_CONFIG.isTopicShowPath) {

      // Guard against multipage reprocessing

      if(!container.hasClass('processed')) {
        container.imagesLoaded(function() {
          slides = container.find('.slide');

          // Start playing when visible

          // Corresponds to `scrolling_mobile.js` on mobile

          $(document).scroll(function() {
            if(!container.hasClass('slides_changed')) {
              if(container.visible()) {
                $.affiliateProducts.changeBannerSlide(1, container);

                container.addClass('slides_changed')
              }
            }
          });

          /* -------------------------------------------------- */

          if(GLOBAL_CONFIG.isDesktop) {
            $.affiliateProducts.products({
              container: container,
              displayType: 'banner'
            });

            /* -------------------------------------------------- */

            slides.on('tap', function() {
              container.find('.launch_jqm_popup').click();
            });
          } else {
            $.affiliateProducts.products({ container: container });

            /* -------------------------------------------------- */

            slides.on('tap', function() {
              document.location.href = '#affiliate_products_jqm_page'
            });
          }
        });
      }
    }
  },

  /* -------------------------------------------------- */

  changeBannerSlide: function(numberOfSlides, container) {
    setTimeout(function() {
      var banner = container,
        bannerWidth = banner.outerWidth(),
        currentSlide = slides.eq(numberOfSlides),
        previousSlide = slides.eq(numberOfSlides - 1);

      previousSlide.css('visibility', 'hidden')
        .css('left', -bannerWidth);

      currentSlide.css('visibility', 'visible')
        .css('left', 0);

      // Do not slide last item

      if(numberOfSlides < banner.size() - 1) {
        changeBannerSlide(numberOfSlides + 1, banner);
      }

      // Slide last item

      // changeBannerSlide(numberOfSlides + 1, banner);
    }, 1000);
  },

  /* -------------------------------------------------- */

  jqmPopup: function(container) {
    if(!container.hasClass('processed')) {
      this.products({
        container: container,
        displayType: 'jqmPopup'
      });
    }
  },

  /* -------------------------------------------------- */

  jqmPage: function() {

    // ...

  },

  /* -------------------------------------------------- */

  products: function(options) {
    var container = options.container;

    var products = container.find('.products'),
      productsWithLogos = products.clone(true),
      product = productsWithLogos.find('.product'),
      logoTemplate = container.find('.logo_template .logo'),
      logoInstances = 4;

    product.each(function() {
      var product = $(this);

      // Apply random Parallax depths

      product.attr('data-depth', Math.floor(Math.random() * 30) / 200);
    });

    /* -------------------------------------------------- */

    if(options.displayType === 'banner' || options.displayType === 'jqmPopup') {

      // Insert logos

      var element = $();

      for(var i = 0; i < logoInstances; i++) {
        function getElements() {
          element = product.eq(Math.floor(Math.random() * product.length));

          var next = element.next(),
            previous = element.prev(),
            all = element.add(next, previous);

          if(element.hasClass('logo') || next.hasClass('logo') || previous.hasClass('logo')) {
            getElements();
          }
        };
        getElements();

        element.before(logoTemplate.clone(true));
      }

      products.replaceWith(productsWithLogos);
    }

    /* -------------------------------------------------- */

    if(options.displayType === 'jqmPopup') {
      function expandProducts(product) {
        var productWidth = product.width(),
          productHeight = product.height();

        product.addClass('active');

        // Bring to front

        product.css('z-index', '2000');

        // Show info

        product.find('.retailer, .price, .name').show();

        // Size the overlays

        product.find('.retailer, .price').css('height', productHeight / 2)
          .css('width', productWidth);

        product.find('.price').css('top', productHeight / 2);

        // Remove price overlay for smaller images

        if(product.find('img').height() < 160) {
          product.find('.price').remove();

          // Resize the remaining overlay

          product.find('.retailer').css('height', productHeight);
        }
      }

      /* -------------------------------------------------- */

      product.each(function() {
        var product = $(this);

        // Resize on mobile

        if(GLOBAL_CONFIG.isMobile) {
          product.css('width', '15%');
        }

        // Hide with JS instead of CSS to preserve `display: flex;`

        product.find('.retailer, .price, .name').hide();

        // Expand on hover and touch

        if(GLOBAL_CONFIG.isDesktop) {
          product.bind('mouseenter touchstart', function() {
            expandProducts(product);
          }).mouseleave(function() {

            // Undo the above

            product.removeClass('active');
            product.css('z-index', '100');
            product.find('.retailer, .price, .name').hide();
          });

          // Remove overlays if hovering product name

          product.find('.name').bind('mouseenter touchstart', function() {
            product.find('.retailer, .price').hide();

            // Re-expand

            product.find('img').bind('mouseenter touchstart', function() {
              expandProducts(product);
            });
          });
        }
      });

      $.affiliateProducts.parallax({
        container: container,
        displayType: 'jqmPopup'
      });
    } else if(options.displayType === 'banner') {
      $.affiliateProducts.parallax({
        container: container,
        displayType: 'banner'
      });
    }

    /* -------------------------------------------------- */

    if(GLOBAL_CONFIG.isDesktop) {
      productsWithLogos.imagesLoaded(function() {
        $.affiliateProducts.packery(productsWithLogos);
        $.affiliateProducts.makeProductsVisible(container);
      });
    } else if(GLOBAL_CONFIG.isMobile) {
      products.imagesLoaded(function() {
        $.affiliateProducts.packery(products);
        $.affiliateProducts.makeProductsVisible(container);
      });
    }

    // Mark as processed

    container.addClass('processed');
  },

  /* -------------------------------------------------- */

  parallax: function(options) {
    if(options.displayType === 'banner') {
      options.container.parallax({
        scalarX: 100,
        scalarY: 200,
        invertX: true,
        invertY: true
      });
    } else if(options.displayType === 'jqmPopup') {
      options.container.parallax({
        scalarX: 10,
        scalarY: 200,
        invertX: true,
        invertY: true
      });
    }
  },

  /* -------------------------------------------------- */

  packery: function(container) {
    container.packery({
      itemSelector: '.product'
    });
  },

  /* -------------------------------------------------- */

  // Prevent flash of unstyled content

  makeProductsVisible: function(container) {

    // Corresponds to `all.css.erb`

    setTimeout(function() {
      container.find('.products').css('visibility', 'visible');
    }, 4000);
  }
}

