//= require jquery-hoverIntent
//= require parallax/jquery.parallax.min.js
//= require_self
//= require scrolling
//= require scrolling_desktop
//= require feeds
//= require polling
//= require posting_desktop

$(document).on('pagecontainershow', function(event, data) {
  var header = function() {
    var header = globalVar.activePage.find('header'),
      footer = globalVar.activePage.find('footer'),
      searchTrigger = header.find('.search_trigger'),
      overflowPanelWrapper = header.find('.overflow_panel_wrapper'),
      overflowPanelTrigger = overflowPanelWrapper.find('.overflow_panel_trigger'),
      overflowPanel = overflowPanelWrapper.find('.overflow_panel');

    // Hide panels when their links are clicked

    overflowPanel.find('.item > a, .return').on('tap', function() {
      overflowPanel.css('visibility', 'hidden')
        .removeClass('active');
    });

    overflowPanel.find('a').on('tap', function() {
      overflowPanel.css('visibility', 'hidden')
        .removeClass('active');
    });

    /* -------------------------------------------------- */

    // Open panels on click

    function showOnClick(panelTrigger) {
      panelTrigger.on('tap', function() {
        $(this).parent().find('.panel').css('visibility', 'visible');
        $(this).addClass('active');
      });
    }

    showOnClick(overflowPanelTrigger);

    $.hideOnOutsideClick({
      container: overflowPanel,
      trigger: overflowPanelTrigger,
      hasActiveClass: true
    });
  }
});

/* -------------------------------------------------- */

$(function() {
  var popups = function() {

    // Add scrollbar if larger than screen

    // Corresponds to `overflow-y: scroll;` in `jquery_mobile.css`

    // http://goo.gl/TfBve7

    function setScrollHeight(popup) {
      var maxHeight = $(window).height() - 30;

      $(popup).css('max-height', maxHeight + 'px');
    }

    /* -------------------------------------------------- */

    // http://demos.jquerymobile.com/1.4.5/popup-outside-multipage/

    /* -------------------------------------------------- */

    $('#photo_editor').enhanceWithin().popup({
      beforeposition: function() {
        setScrollHeight('#photo_editor');
      }
    });

    /* -------------------------------------------------- */

    $('#sign_in').enhanceWithin().popup();
    $('#create_account').enhanceWithin().popup();
    // $('#forgot_password').enhanceWithin().popup();

    /* -------------------------------------------------- */

    $('#affiliate_products_jqm_popup').enhanceWithin().popup();

    /* -------------------------------------------------- */

    $('#switch_to_create_account > a').on('tap', function() {
      $('#sign_in').popup('close');
      // $('#forgot_password').popup('close');
      $(this).addClass('opened');
      $('#switch_to_sign_in > a').removeClass('opened');
      // $('#switch_to_forgot_password > a').removeClass('opened');
    });

    $('#switch_to_sign_in > a').on('tap', function() {
      $('#create_account').popup('close');
      // $('#forgot_password').popup('close');
      $(this).addClass('opened');
      $('#switch_to_create_account > a').removeClass('opened');
      // $('#switch_to_forgot_password > a').removeClass('opened');
    });

    // $('#switch_to_forgot_password > a').on('tap', function() {
    //   $('#sign_in').popup('close');
    //   $('#create_account').popup('close');
    //   $(this).addClass('opened');
    //   $('#switch_to_sign_in > a').removeClass('opened');
    //   $('#switch_to_create_account > a').removeClass('opened');
    // });

    $('#sign_in').on({
      popupafterclose: function() {
        if($('#switch_to_create_account > a').hasClass('opened')) {
          setTimeout(function() { $('#create_account').popup('open') }, 100);
          $('#switch_to_create_account > a').removeClass('opened');
        }

        // if($('#switch_to_forgot_password > a').hasClass('opened')) {
        //   setTimeout(function() { $('#forgot_password').popup('open') }, 100);
        //   $('#switch_to_forgot_password > a').removeClass('opened');
        // }
      }
    });

    $('#create_account').on({
      popupafterclose: function() {
        if($('#switch_to_sign_in > a').hasClass('opened')) {
          setTimeout(function() { $('#sign_in').popup('open') }, 100);
          $('#switch_to_sign_in > a').removeClass('opened');
        }

        // if($('#switch_to_forgot_password > a').hasClass('opened')) {
        //   setTimeout(function() { $('#forgot_password').popup('open') }, 100);
        //   $('#switch_to_forgot_password > a').removeClass('opened');
        // }
      }
    });

    // $('#forgot_password').on({
    //   popupafterclose: function() {
    //     if($('#switch_to_sign_in > a').hasClass('opened')) {
    //       setTimeout(function() { $('#sign_in').popup('open') }, 100);
    //       $('#switch_to_sign_in > a').removeClass('opened');
    //     }
    //
    //     if($('#switch_to_create_account > a').hasClass('opened')) {
    //       setTimeout(function() { $('#create_account').popup('open') }, 100);
    //       $('#switch_to_create_account > a').removeClass('opened');
    //     }
    //   }
    // });
  }();
});

