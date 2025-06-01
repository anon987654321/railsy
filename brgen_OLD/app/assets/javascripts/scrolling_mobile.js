$(document).on('pagecontainershow', function() {
  var scrollingMobile = function() {

    // Enable iScroll on containers with `data-iscroll` attribute

    $('[data-iscroll]').each(function() {
      var dataAttr = $(this);

      if(!dataAttr.hasClass('has_iscroll')) {
        var hasRegularFeedScroller = dataAttr.is('#regular_feed'),
          hasMediaFeedScroller = dataAttr.is('#media_feed_container'),
          isNavScroller = dataAttr.is('footer nav > div'),
          isPanelScroller = dataAttr.is('.snap-drawer'),
          isAffiliateScroller = dataAttr.is('#affiliate_products_jqm_page');

        /* -------------------------------------------------- */

        if(isNavScroller) {

          // https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollWidth

          // Must happen before the creation of containers below

          var navWidth = dataAttr.prop('scrollWidth'),
            navHeight = dataAttr.height();
        }

        /* -------------------------------------------------- */

        // Create containers

        dataAttr.wrapInner("<div class='scroller'></div>")
          .wrapInner("<div class='scroller_wrapper'></div>");

        var scrollerWrapper = dataAttr.find('.scroller_wrapper').first();

        /* -------------------------------------------------- */

        if(hasRegularFeedScroller || hasMediaFeedScroller) {
          var windowHeight = $(window).height(),
            headerHeight = $('header').outerHeight();

          // iScroll requires explicit height

          scrollerWrapper.height(windowHeight);

          // Restore header padding from broken `.ui-page` due to iScroll containers

          scrollerWrapper.css('padding-top', headerHeight);
        }

        /* -------------------------------------------------- */

        if(isNavScroller) {
          var scroller = scrollerWrapper.find('.scroller');

          scroller.width(navWidth);
          scrollerWrapper.height(navHeight);
        }

        /* -------------------------------------------------- */

        function iScrollAttach() {

          // Set vertical scroll for navigation

          var isScrollX = isNavScroller ? 'true' : 'false',
            isScrollY = isNavScroller ? 'false' : 'true';

          // Initiate iScroll

          var scroller = new IScroll(scrollerWrapper.get(0), {
            scrollX: isScrollX,
            scrollY: isScrollY,
            eventPassthrough: false,
            preventDefault: false,
            scrollbars: false,
            bounce: false,
            probeType: 3
          });

          // Use iScroll's probe edition for enhanced scroll detection

          scroller.on('scroll', function() {

            // Prevent links from being tapped while touching

            // Corresponds to `pointer-events: none;` in `mobile.css.erb`

            scrollerWrapper.addClass('scrolling');

            /* -------------------------------------------------- */

            // Hide bars on scroll to free up screen real-estate

            if(hasRegularFeedScroller || hasMediaFeedScroller) {
              var header = globalVar.activePage.find('header'),
                footer = globalVar.activePage.find('footer');

              // When scrolling down

              if(this.directionY == 1) {
                header.addClass('slide_up');
                footer.addClass('slide_down');
              }

              // When scrolling up

              if(this.directionY == -1) {
                header.removeClass('slide_up');
                footer.removeClass('slide_down');
              }

              /* -------------------------------------------------- */

              // Corresponds to `affiliate_products.js`

              if(hasRegularFeedScroller) {
                var banner = globalVar.activePage.find('.affiliate_products_banner');

                if(!banner.hasClass('slides_changed')) {
                  if(banner.visible()) {
                    $.affiliateProducts.changeBannerSlide(1, banner);

                    banner.addClass('slides_changed');
                  }
                }
              }

              /* -------------------------------------------------- */

              // Infinite scrolling

              // Calculate when we're 350px from the page bottom

              // http://goo.gl/TaS9Lf

              // http://goo.gl/K13Pyo

              if((Math.abs(this.maxScrollY) - Math.abs(this.y) < 350) && !GLOBAL_CONFIG.isLoading) {
                if(GLOBAL_CONFIG.hasRegularFeed && GLOBAL_CONFIG.isRootPath) {
                  $.scrolling.getNextPageRegularFeed();
                } else if(GLOBAL_CONFIG.hasMediaFeed) {
                  $.scrolling.getNextPageMediaFeed();
                }

                /* -------------------------------------------------- */

                if(GLOBAL_CONFIG.isDraft) {
                  console.log('Bottom reached');

                  NProgress.start();

                  if(GLOBAL_CONFIG.isMobile) {
                    globalVar.doubleBounceLoader.show();
                  }
                }
              }
            }
          });

          scroller.on('scrollEnd', function() {
            scrollerWrapper.removeClass('scrolling');
          });

          return scroller;
        }

        // Attach iScroll to variables that can be targeted for refreshing later on

        if(hasRegularFeedScroller) {
          globalVar.regularFeedScroller = iScrollAttach();

        } else if(hasMediaFeedScroller) {
          globalVar.mediaFeedScroller = iScrollAttach();

        } else if(isNavScroller) {
          globalVar.navScroller = iScrollAttach();

        } else if(isPanelScroller) {
          globalVar.panelScroller = iScrollAttach();

        } else if(isAffiliateScroller) {
          globalVar.affiliateScroller = iScrollAttach();

        } else {
          globalVar.scroller = iScrollAttach();
        }

        // Mark as processed incase of page change

        $(this).addClass('has_iscroll');
      }
    });

    /* -------------------------------------------------- */

    document.addEventListener('touchmove', function(e) {
      e.preventDefault();
    }, false);
  }();
});

