//= require iscroll/iscroll-probe.js
//= require snapjs
//= require_self
//= require scrolling
//= require scrolling_mobile
//= require feeds
//= require polling
//= require affiliate_products

/* -------------------------------------------------- */

$(document).on('pagecreate', function() {
  var touchIndicator = function() {
    var touchIndicator = $('.touch_indicator'),
      touchIndicatorTemplate = $('.touch_indicator_template');

    $('a, button, input[type="submit"]').on('touchstart', function(event) {
      touchIndicator.html(touchIndicatorTemplate.html());

      // Position to touch

      // Corresponds to the radius in `_touch_indicator.html.erb`

      touchIndicator.css('left', event.originalEvent.changedTouches[0].pageX - 30);
      touchIndicator.css('top', event.originalEvent.changedTouches[0].pageY - 30);
    });
  }();
});

$(document).on('pagecontainerbeforeshow', function() {

  // Hide previous Snap.js instances

  $('.snap-drawers').hide();
});

/* -------------------------------------------------- */

$(document).on('pagecontainershow', function(event, data) {

  // TODO: iScroll integration?

  var navPopups = function() {
    $('[data-role="popup"]').on({
      popupbeforeposition: function() {
        var maxHeight = $(window).height() - 120;

        $('[data-role="popup"] .ui-content').height(maxHeight);
      }
    });
  }();

  /* -------------------------------------------------- */

  // Snap.js replaces jQuery Mobile's panel widget

  // Revert come jQuery Mobile 1.7 (#5493)

  // http://jquerymobile.com/roadmap/

  var overflowPanel = function() {
    if(globalVar.activePage.find('header .overflow_panel_trigger').length) {
      var drawers = $('.snap-drawers'),
        drawersCloned = drawers.clone(true).show();

      // Remove Snap.js completely and re-inject dynamically due to page change

      // drawers.remove();

      // $(data.toPage).before(drawersCloned);

      // var snapper = new Snap({
      //   element: $(data.toPage)[0],
      //   hyperextensible: false
      // });

      // var snapper = new Snap({
      //   element: $('.ui-page')[0],
      //   hyperextensible: false
      // });

      /* -------------------------------------------------- */

      // Initialize click listeners

      $('.overflow_panel_trigger').off('tap').on('tap', function() {
        snapper.open('left');
      });

      $('.panel_wrapper .close_trigger').off('tap').on('tap', function() {
        snapper.close();
      });

      $('.panel .item > a').off('tap').on('tap', function() {
        $(this).parent().toggleClass('active');

        $(this).parent().find('.sub').slideToggle(400, function() {
          globalVar.panelScroller.refresh();
        });
      });
    }
  }();

  /* --------------------------------------------------

  var backToTop = function() {
    $(window).scroll(function() {
      if ($(this).scrollTop()) {
        $('#back_to_top').fadeIn();
      } else {
        $('#back_to_top').fadeOut();
      }
    });

    $('#back_to_top').on('tap', function() {
      $('html, body').animate({
        scrollTop: 0
      }, {
        duration: 300
      });
    });
  }();

  -------------------------------------------------- */
});

