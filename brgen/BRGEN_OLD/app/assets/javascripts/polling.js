
globalVar.firstRequest = true;
globalVar.lastModifiedDate;

/* -------------------------------------------------- */

$.insertPosts = function(html, container) {
  var existingPosts = $.map(container, function(post) {
    return post.id;
  });

  var newPost = $(html).find('.topic').not('#' + existingPosts.join(', #'));

  if(GLOBAL_CONFIG.isRootPath) {
    globalVar.newTopic = newPost.insertBefore(globalVar.regularFeed.find(container).first()).hide();
  } else if(GLOBAL_CONFIG.isTopicShowPath) {
    globalVar.newReply = newPost.insertAfter(globalVar.regularFeed.find(container).last()).hide();
  }
}

/* -------------------------------------------------- */

$.postPoller = {
  timer: function() {
    // console.log('Ran `$.postPoller.timer`');

    // Run once every 20 seconds

    setTimeout(this.request, 20000);
  },

  /* -------------------------------------------------- */

  request: function() {
    // console.log('Ran `$.postPoller.request`');

    var dataUrl = globalVar.regularFeed.data('url');

    // console.log('Data URL: ' + dataUrl);

    // http://goo.gl/olmjPn

    $.ajax({
      url: dataUrl,
      type: 'GET',
      cache: true,
      ifModified: true,
      tryCount: 0,
      retryLimit: 3,
      beforeSend: function(xhr) {
        if(!globalVar.firstRequest) {
          // console.log('Set request header');

          // Set `If-Modified-Since` so Rails can return `200 OK` or `304 Not Modified`

          // Corresponds to `fresh_when` in `forums_controller_decorator.rb`

          xhr.setRequestHeader('If-Modified-Since', globalVar.lastModifiedDate);
        }
      },
      success: function(html, textStatus, xhr) {
        // console.log('Received Ajax response');

        globalVar.lastModifiedDate = xhr.getResponseHeader('Last-Modified');

        if(globalVar.firstRequest) {
          // console.log('First response');

          // Start again

          $.postPoller.timer();

          globalVar.firstRequest = false;

        } else {
          // console.log('Subsequent response');

          if(textStatus != 'notmodified') {
            // console.log('200 OK: We have change');

            // Add topics with the HTML we've received

            $.postPoller.add(html);
          } else {
            // console.log('304 Not Modified: Do nothing');

            // Start again

            $.postPoller.timer();
          }
        }
      },
      error: function(xhr, textStatus, errorThrown) {
        // console.log(textStatus, errorThrown);

        // Retry on 504 Gateway Timeout

        if(textStatus == 'timeout') {
          $.postPoller.timer();
        }
      }
    });
  },

  /* -------------------------------------------------- */

  add: function(html) {
    // console.log('Adding post...');

    if(GLOBAL_CONFIG.isRootPath) {
      $.insertPosts(html, globalVar.activePage.find('.topic'));

      $.feeds.processPost({
        feedType: 'regular',
        container: globalVar.newTopic
      });

      $.feeds.slideDownAndFadeIn({
        container: globalVar.newTopic
      });
    } else {
      $.insertPosts(html, globalVar.activePage.find('.reply'));

      $.feeds.processPost({
        feedType: 'regular',
        container: globalVar.newReply
      });

      $.feeds.slideDownAndFadeIn({
        container: newReply
      });
    }

    /* -------------------------------------------------- */

    NProgress.done();

    // console.log('New post was added');

    // Start again

    this.timer();
  }
};

/* -------------------------------------------------- */

$.delayedPaperclipPoller = {
  poll: function() {
    // console.log('Ran `$.delayedPaperclipPoller.poll`');

    setTimeout(this.request, 5000);
  },

  /* -------------------------------------------------- */

  request: function(photo_id) {
    // console.log('Ran `$.delayedPaperclipPoller.request`');

    // Corresponds to `photo.id` in `_post.html.erb`

    if(photo_id) {
      globalVar.photoId = photo_id;
    }

    $.ajax({
      url: '/check-photo-processing/' + globalVar.photoId,
      type: 'GET',
      success: function() {
        // console.log('Attachment processing complete');

        $.delayedPaperclipPoller.add();
      },
      error: function() {

        // Start again

        $.delayedPaperclipPoller.poll();
      }
    });
  },

  /* -------------------------------------------------- */

  add: function(html) {
    // console.log('Ran `$.delayedPaperclipPoller.add`');

    var dataUrl = $('#topics').data('url');

    $.get(dataUrl, function(html) {

      // ...

      $(html).find('video').insertAfter($('#topics'));
    });

    // console.log('New media was added');
  }
};

/* -------------------------------------------------- */

$.affiliateProductsPoller = {
  request: function() {
    // console.log('Ran `$.affiliateProductsPoller.request`');

    $.ajax({
      url: '/affiliate-products-banner',
      type: 'GET',
      success: function(html) {
        // console.log('Fetched affiliate products for banner');

          $.affiliateProductsPoller.add({
            html: html,
            displayType: 'banner'
          });
      },
      error: function() {
        // console.log('Unable to fetch affiliate products for banner');
      }
    });

    if(GLOBAL_CONFIG.isDesktop) {
      $.ajax({
        url: '/affiliate-products-jqm-popup',
        type: 'GET',
        success: function(html) {
          // console.log('Fetched affiliate products for jQuery Mobile popup');

          $.affiliateProductsPoller.add({
            html: html,
            displayType: 'jqmPopup'
          });
        },
        error: function() {
          // console.log('Unable to fetch affiliate products for jQuery Mobile popup');
        }
      });
    } else {
      $.ajax({
        url: '/affiliate-products-jqm-page',
        type: 'GET',
        success: function(html) {
          // console.log('Fetched affiliate products for jQuery Mobile page');

          $.affiliateProductsPoller.add({
            html: html,
            displayType: 'jqmPage'
          });
        },
        error: function() {
          // console.log('Unable to fetch affiliate products for jQuery Mobile page');
        }
      });
    }
  },

  /* -------------------------------------------------- */

  add: function(options) {
    // console.log('Ran `$.affiliateProductsPoller.add`');

    var container;

    if(options.displayType === 'banner') {
      container = globalVar.activePage.find('.affiliate_products_banner');

    } else if(options.displayType === 'jqmPopup') {
      container = $('#affiliate_products_jqm_popup');

    } else if(options.displayType === 'jqmPage') {
      container = $('#affiliate_products_jqm_page');
    }

    $(options.html).find('.product').appendTo(container.find('.products'));

    // console.log('New products were added');

    /* -------------------------------------------------- */

    if(options.displayType === 'banner') {
      $.affiliateProducts.banner(container);

    } else if(options.displayType === 'jqmPopup') {
      $.affiliateProducts.jqmPopup(container);

    } else if(options.displayType === 'jqmPage') {
      // $.affiliateProducts.jqmPage(container);
    }
  }
};

/* -------------------------------------------------- */

$(document).on('pagecontainershow', function() {
  if(GLOBAL_CONFIG.hasRegularFeed) {
    globalVar.regularFeed.imagesLoaded(function() {

      // Give things time to settle

      setTimeout(function() {
        // console.log('Starting `$.postPoller`...');

        $.postPoller.timer();
      }, 5000);
    });

    /* -------------------------------------------------- */

    if(GLOBAL_CONFIG.isRootPath || GLOBAL_CONFIG.isForumShowPath) {
      $.affiliateProductsPoller.request();
    }
  }
});

