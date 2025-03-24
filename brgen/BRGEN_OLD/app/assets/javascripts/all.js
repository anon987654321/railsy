//= require i18n
//= require i18n/translations
//= require jquery
//= require jquery-ujs
//= require jquery_mobile_1.4.5.custom.min
//= require cssfx
//= require enquire
//= require nprogress
//= require embedly-jquery/jquery.embedly.js
//= require jquery.oembed
//= require jquery-bridget
//= require ev-emitter
//= require imagesloaded
//= require get-size
//= require desandro-matches-selector
//= require fizzy-ui-utils
//= require outlayer/item
//= require outlayer
//= require packery/rect
//= require packery/packer
//= require packery/item
//= require packery
//= require jquery.visible/jquery.visible.js
//= require jquery.ellipsis
//= require jquery-infield-label/jquery.infieldlabel.min.js
//= require microplugin
//= require sifter
//= require selectize
//= require optgroup_packery
//= require speakingurl
//= require jquery-slugify/slugify.js
//= require Autolinker.js/Autolinker.js
//= require caman
//= require jquery-deserialize
//= require seedrandom
//= require jquery.center.js/jquery.center.min
//= require jquery.caro
//= require_self
//= require posting
//= require posting_photo_editor
//= require photo_editor
//= require photo_filters
//= require affiliate_products
//= require help
//= require facebook
//= require add-to-homescreen

/* -------------------------------------------------- */

// http://jquerymobile.com/download-builder/
//
//   Core: `Init`
//   Transitions: `Slide`, `Slideup`, `Pop`
//   Widgets: `Toolbars: Fixed`, `Toolbars: Fixed: Workarounds`, `Popups`

/* -------------------------------------------------- */

// Packery dependencies: https://github.com/metafizzy/packery/blob/master/examples/basics.html#L118-L130

/* -------------------------------------------------- */

var GLOBAL_CONFIG = {
  isDraft: false,
  isDesktop: false,
  isMobile: false,
  hasRegularFeed: false,
  hasMediaFeed: false,
  isRootPath: false,
  isForumShowPath: false,
  isTopicShowPath: false,
  isMobileNewPostPath: false,
  isLoading: false
};

/* -------------------------------------------------- */

var globalVar = {};

/* -------------------------------------------------- */

var detectMobile = function() {

  // Corresponds to `mobile?` in `application_controller.rb`

  // http://goo.gl/dHcixr

  // Android, Windows and webOS tablet support:

  // http://goo.gl/ZuN2Lu, http://goo.gl/huJLKE, http://goo.gl/qUp3UU

  if(/mobile|android|touch|webos|hpwos/i.test(navigator.userAgent.toLowerCase())) {
    GLOBAL_CONFIG.isMobile = true;
  } else {
    GLOBAL_CONFIG.isDesktop = true;
  }
}();

/* -------------------------------------------------- */

var mobileLoader = function() {
  globalVar.doubleBounceLoader = $('.spinkit_parent_wrapper');
}();

/* -------------------------------------------------- */

var matchDrafts = function() {

  // http://goo.gl/mSsQ1x

  if(window.location.href.indexOf('draft') > -1) {
    GLOBAL_CONFIG.isDraft = true;

    // Always assume `isMobile` for `draft/mobile/` despite user-agent

    if(window.location.href.indexOf('mobile') > -1) {
      GLOBAL_CONFIG.isMobile = true;
      GLOBAL_CONFIG.isDesktop = false;
    }
  }
}();

/* -------------------------------------------------- */

$(document).on('pagecontainerbeforeshow', function() {

  // Stop any previous loader instances

  NProgress.done();

  if(GLOBAL_CONFIG.isMobile) {
    globalVar.doubleBounceLoader.hide();
  }
});

/* -------------------------------------------------- */

$(document).on('pagecontainershow', function() {

  // http://api.jquerymobile.com/pagecontainer/#method-getActivePage

  globalVar.activePage = $.mobile.pageContainer.pagecontainer('getActivePage');

  /* -------------------------------------------------- */

  // http://en.wikipedia.org/wiki/Flash_of_unstyled_content

  var flashOfUnstyledContent = function() {
    $('body.hide_while_loading').css('visibility', 'visible');
  }();

  /* -------------------------------------------------- */

  var mediaQueries = function() {

    // YouTube thumbnails larger than `480px` will not display correctly

    globalVar.regularFeedMediaWidth = 480;

    enquire.register('screen and (max-width: 640px)', {
      match: function() {

        // Mobile `320px` with `15px` padding

        globalVar.regularFeedMediaWidth = 290;
      }
    });
  }();

  /* -------------------------------------------------- */

  // Similar helpers for eRuby in `application_helper.rb`

  var pageHelpers = function() {

    // Incase coming from other pages

    GLOBAL_CONFIG.hasRegularFeed = false;
    GLOBAL_CONFIG.hasMediaFeed = false;

    if(globalVar.activePage.find('#regular_feed').length) {
      GLOBAL_CONFIG.hasRegularFeed = true;
    }

    if(globalVar.activePage.find('#media_feed_container').length) {
      GLOBAL_CONFIG.hasMediaFeed = true;
    }
  }();

  var pathHelpers = function() {

    // Incase coming from other paths

    GLOBAL_CONFIG.isRootPath = false;
    GLOBAL_CONFIG.isForumShowPath = false;
    GLOBAL_CONFIG.isTopicShowPath = false;
    GLOBAL_CONFIG.isMobileNewPostPath = false;

    if(globalVar.activePage.find('.root_path').length) {
      GLOBAL_CONFIG.isRootPath = true;
    }

    if(globalVar.activePage.find('.forum_show_path').length) {
      GLOBAL_CONFIG.isForumShowPath = true;
    }

    if(globalVar.activePage.find('.topic_show_path').length) {
      GLOBAL_CONFIG.isTopicShowPath = true;
    }

    if(GLOBAL_CONFIG.isMobile && globalVar.activePage.data('url') === '/posting/new') {
      GLOBAL_CONFIG.isMobileNewPostPath = true;
    }
  }();

  /* -------------------------------------------------- */

  var flash = function() {
    setTimeout(function() {
      $('.flash').addClass('slide_up');
    }, 3000);
  }();

  /* -------------------------------------------------- */

  // Move NProgress away from the body due to jQuery Mobile

  // Corresponds to `mobile_page_id` in `application_helper.rb`

  var moveNProgressToHeader = function() {
    NProgress.configure({
      parent: '#' + globalVar.activePage.prop('id') + ' header .progress_wrapper'
    });

    $('.progress_trigger').on('tap', function() {
      NProgress.start();

      if(GLOBAL_CONFIG.isMobile) {
        globalVar.doubleBounceLoader.show();
      }
    });
  }();

  /* -------------------------------------------------- */

  var search = function() {
    var container = globalVar.activePage.find('.search');

    $('.search_trigger').on('tap', function(event) {
      event.preventDefault();

      container.css('visibility', 'visible');

      container.find('input[type=text]').focus();
      container.find('label').inFieldLabels();
    });

    // Provide an exit

    $('.search .close_trigger').on('tap', function(event) {
      container.css('visibility', 'hidden');
    });

    $.hideOnOutsideClick({ container: container });
  }();

  /* -------------------------------------------------- */

  // Corresponds to `process_user_textarea` in `application_helper.rb`

  // http://goo.gl/uRmt1

  // TODO: Move to `feeds.js`

  var makeLinksExternal = function() {
    $('.user_textarea').each(function() {
      $(this).find('a[href^="http://"]').attr('target', '_blank');
    });
  }();

  /* -------------------------------------------------- */

  var embedlyFormPreview = function() {
    var preview = $('form .embed_preview');

    // Protect against injection attacks

    var entityMap = {
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;",
      '"': '&quot;',
      "'": '&#39;',
      "/": '&#x2F;'
    };

    function htmlSafe(string) {
      return String(string).replace(/[&<>"'\/]/g, function(s) {
        return entityMap[s];
      });
    }

    // Hide here instead of with CSS to preserve `display: flex;`

    preview.hide();

    // As soon as somebody starts typing

    $('form textarea').keyup(function() {
      var url = $(this).val().match(/https?:\/\/[^\s]+/);

      // Match first URL

      if(url) {
        var filtered_url = htmlSafe(url[0]);

        // Copy URL to embed preview

        preview.html('<a href="' + filtered_url + '">' + filtered_url + '</a>');

        // Start loaders

        NProgress.start();

        if(GLOBAL_CONFIG.isMobile) {
          globalVar.doubleBounceLoader.show();
        }

        // Embedly

        preview.find('a').embedly({
          key: '7c6cf67ad409446cacd53309d96b66a0',
          display: function(data, element) {
            $(element).addClass('embed');

            // Replace embed with thumbnail

            $(element).html('<img src="' + data.thumbnail_url + '"/>');

            // Insert other data

            $(element).parent().append('<div class="wrapper" />')
              .find('.wrapper')
              .append('<p class="title">' + data.title + '</p>')
              .append('<p class="description">' + data.description + '</p>');
          },
          done: function(results) {
            $('form .embed_preview').slideDown('fast', function() {

              // Stop loaders

              NProgress.done();

              if(GLOBAL_CONFIG.isMobile) {
                globalVar.doubleBounceLoader.hide();
              }
            });
          }
        });
      }

      // Warn against pasting actual embed code

      if($(this).val().match(/<iframe(.*)\/iframe>/g)) {

        // TODO: I18n

        alert("That won't work. Please paste the actual URL instead.");
      }
    });
  }();

  /* -------------------------------------------------- */

  $.scrollToContainer = function(container) {
    var extraHeight = 100;

    // http://goo.gl/Nm9Vj

    $('html, body').animate({
      scrollTop: container.offset().top + extraHeight
    }, 500);
  }

  /* -------------------------------------------------- */

  var localAuthForms = function() {

    // Hide and expand local auth forms

    $('.local_auth').each(function() {
      var popupOrPage = $(this);

      popupOrPage.find('form').hide();

      popupOrPage.find('.button').not('.primary').on('tap', function() {
        var trigger = $(this);

        trigger.hide();
        trigger.parent().find('form').slideDown('fast');
      });
    });
  }();
});

/* -------------------------------------------------- */

$.hideOnOutsideClick = function(options) {
  var container = options.container,
    trigger = options.trigger;

  // http://goo.gl/g472S

  $(document).mouseup(function(event) {

    // If the target isn't the container or its descendant

    if(!container.is(event.target) && !container.has(event.target).length) {
      container.css('visibility', 'hidden');

      /* -------------------------------------------------- */

      if(options.hasActiveClass) {
        trigger.removeClass('active');
      }

      /* -------------------------------------------------- */

      if(options.triggerDescription) {
        trigger.find('.trigger_description').show();
      }

      /* -------------------------------------------------- */

      if(options.newTopic) {
        container.find('.new_topic_expanded').slideUp();
        container.find('.new_topic_trigger').show();
      }
    }
  });
}

/* -------------------------------------------------- */

$.triggerDescriptions = function(container) {
  container.hoverIntent({
    over: function() {
      $(this).find('.trigger_description').css('visibility', 'visible');
    },
    out: function() {
      $(this).find('.trigger_description').css('visibility', 'hidden');
    },
    timeout: 500
  });

  container.on('tap', function() {
    $(this).find('.trigger_description').css('visibility', 'hidden');
  });
}

