$.feeds = {
  embedly: function(options) {
    var finishedItem = $.Deferred(),
      element = options.element,
      embedWidth;

    if(options.feedType === 'regular') {
      embedWidth = globalVar.regularFeedMediaWidth;
    } else if(options.feedType === 'media') {

      // Max size of YouTube thumbnails

      maxEmbedWidth = 480;

      if(GLOBAL_CONFIG.isDesktop) {

        // Random size

        embedWidth = Math.min(maxEmbedWidth, Math.floor(Math.random() * 181 + 300));
      } else {
        var windowWidth = $(window).width();

        // Ensure full width on smaller displays

        if(windowWidth < maxEmbedWidth) {
          embedWidth = $(window).width();
        } else {
          embedWidth = maxEmbedWidth;
        }

        embedWidth = Math.min(maxEmbedWidth, Math.floor(Math.random() * 181 + 300) / 2.5);
      }
    }

    element.embedly({
      key: '383fdf10a63f41dabc1d37e384dd54ea',
      query: {
        maxwidth: embedWidth,
        autoplay: true
      },
      display: function(data) {
        if(data.thumbnail_url && (data.type == 'video' || data.type == 'rich')) {
          element.addClass('embed');

          element.width(embedWidth);

          // Replace embed with thumbnail

          element.html('<img src="' + data.thumbnail_url + '" />');

          // Mark and hide YouTube and BandCamp media for later on

          if(data.original_url.indexOf('youtube.com') !== -1) {
            element.addClass('youtube')
              .css('opacity', 0);
          } else if(data.original_url.indexOf('bandcamp.com') !== -1) {
            element.addClass('bandcamp')
              .css('opacity', 0);
          }

          // Play button

          element.append('<span class="play_arrow" />')
            .find('.play_arrow')
            .css('width', embedWidth)
            .css('height', '100%');
        }

        // TODO: http://embed.ly/docs/tutorials/gif

        if(data.type == 'photo') {

          // ...

        }
      },
      done: function(results) {
        if(options.feedType === 'regular') {
          var topic = element.closest('.topic'),
            firstPost = topic.find('.first_post'),
            firstPostUserTextarea = firstPost.find('> .user_textarea');

          // Apply only to embeds

          if(element.hasClass('embed')) {
            element.imagesLoaded(function() {

              // Make sure we're on the front page and that the element hasn't already been previewed

              if(GLOBAL_CONFIG.isRootPath && !topic.hasClass('has_embed_preview')) {
                $.feeds.embedPreview(firstPostUserTextarea);
              }

              if(element.hasClass('youtube')) {
                $.feeds.cropForYouTube(element);
                element.css('opacity', 1);
              } else if(element.hasClass('bandcamp')) {
                $.feeds.fixBandCampWidth(element);
                element.css('opacity', 1);
              }

              $.feeds.splitParagraphs(topic);

              if(GLOBAL_CONFIG.isRootPath || GLOBAL_CONFIG.isForumShowPath) {
                topic.find('.first_post > .user_textarea').hide();
              }

              if(GLOBAL_CONFIG.isRootPath || GLOBAL_CONFIG.isForumShowPath || GLOBAL_CONFIG.isTopicShowPath) {
                $.feeds.truncateReplies({ container: topic });
              }

              if(options.insertAfterPageLoad) {
                $.feeds.slideDownAndFadeIn({
                  container: topic
                });
              } else {
                topic.css('opacity', 1);
              }
            });
          } else {
            if(GLOBAL_CONFIG.isRootPath || GLOBAL_CONFIG.isForumShowPath) {
              topic.find('.first_post > .user_textarea').hide();
            }

            if(GLOBAL_CONFIG.isRootPath || GLOBAL_CONFIG.isForumShowPath || GLOBAL_CONFIG.isTopicShowPath) {
              $.feeds.truncateReplies({ container: topic });
            }

            if(options.insertAfterPageLoad) {
              $.feeds.slideDownAndFadeIn({
                container: topic
              });
            } else {
              topic.css('opacity', 1);
            }
          }

          /* -------------------------------------------------- */

        } else if(options.feedType === 'media') {
          if(element.hasClass('embed')) {
            element.imagesLoaded(function() {

              // Clone and hide

              packeryItem = element.wrap('<a class="packery_item" />').closest('.packery_item').clone(true).css('opacity', 0).appendTo(globalVar.mediaFeed);

              // Assign title

              if(GLOBAL_CONFIG.isDesktop) {
                element.closest('.topic').find('.title').clone().css('opacity', 0).appendTo(packeryItem).hide();
              }

              /* -------------------------------------------------- */

              if(GLOBAL_CONFIG.isDesktop) {

                // Progressive disclosure for topic titles

                packeryItem.hoverIntent({
                  over: function() {
                    $(this).find('.title').show();
                  },
                  out: function() {
                    $(this).find('.title').hide();
                  },
                  timeout: 500
                });

                // Remove topic titles when clicking thumbnails

                packeryItem.find('.play_arrow').on('tap', function() {
                  $(this).closest('.packery_item').find('.title').remove();
                });
              }

              /* -------------------------------------------------- */

              var youtube = packeryItem.find('.youtube'),
                bandcamp = packeryItem.find('.bandcamp');

              if(youtube.length) {
                $.feeds.cropForYouTube(youtube);
                youtube.css('opacity', 1);
              } else if(bandcamp.length) {
                $.feeds.fixBandCampWidth(bandcamp);
                bandcamp.css('opacity', 1);
              }

              /* -------------------------------------------------- */

              // Update Packery

              globalVar.pckry.appended(packeryItem);

              if(GLOBAL_CONFIG.isDesktop) {
                packeryItem.find('.title').css('opacity', 1);
              }
            });
          }
        }

        // Let the outside know we're done

        finishedItem.resolve(results);
      }
    }).on('tap', function() {

      // Apply only to embeds

      if($(this).hasClass('embed')) {

        // Replace thumbnail with corresponding media

        var data = $(this).data('embedly');
        $(this).replaceWith(data.html);

        if(options.feedType === 'media') {

          // Reload Packery

          globalVar.pckry.layout();
        }

        return false;
      }
    });

    return finishedItem.promise();
  },

  /* -------------------------------------------------- */

  hasPhotos: function(container) {
    return container.closest('.topic').find('.photos').not('.new_reply .photos').length
  },

  /* -------------------------------------------------- */

  hasEmbed: function(container) {
    return container.find('.embed').length
  },

  /* -------------------------------------------------- */

  hasImmediateText: function(container) {

    // http://goo.gl/A29ZiF

    return Array.prototype.some.call(container.contents(), function(element) {
      return element.nodeType === 3;
    });
  },

  /* -------------------------------------------------- */

  // Split paragraphs that have both text and embeds

  splitParagraphs: function(container) {
    var seen = [];

    container.find('p').each(function() {
      if($.feeds.hasImmediateText($(this)) && $.feeds.hasEmbed($(this))) {
        if(seen.indexOf(this) >= 0) {
          return;
        }

        var paragraph = $(this).find('.embed'),
          parentParagraph = paragraph.parent(),
          parentParagraphContainer = parentParagraph.parent(),
          content = parentParagraph.contents();

        var newContainer = $('<div />'),
          item;

        content.each(function() {
          var paragraph = $(this),
            embed = paragraph.filter('.embed');

          if(embed.length) {
            seen.push(embed.get(0));
          }

          if(this.nodeType == 3) {
            item = $('<p />').text($.trim(paragraph.text()))
          } else if(paragraph.is('a')) {
            item = $('<p />').append(paragraph.clone())
          }

          newContainer.append(item);
        });

        newContainer.insertAfter(parentParagraph);

        // http://goo.gl/zKmEGN

        newContainer.contents().unwrap();

        parentParagraph.remove();
      }
    });
  },

  /* -------------------------------------------------- */

  truncateDesktop: function(container, maxWords) {
    if(!container.hasClass('truncated')) {
      var paragraphsOrLists = container.find('p, ul, ol'),
        totalConsumedWordCount = 0;

      paragraphsOrLists.each(function() {
        var paragraphOrList = $(this),
          words = paragraphOrList.text().split(' '),
          totalWordCount = totalConsumedWordCount + words.length;

        if(totalWordCount > maxWords) {
          paragraphOrList.ellipsis({
            visible: Math.abs(totalConsumedWordCount - maxWords),
            more: '... <a>(mer)</a>',
            // more: '... <a>(' + I18n('more') + ')</a>',
            moreClass: 'unhide_trigger',
            atFront: false
          });

          paragraphOrList.nextAll('p, ul, ol').hide();

          return false;
        }

        totalConsumedWordCount = totalWordCount;
      });

      // Mark as truncated

      container.addClass('truncated');

      // Untruncation

      container.find('.unhide_trigger').on('tap', function() {
        paragraphsOrLists.show();

        container.removeClass('truncated');
      });
    }
  },

  /* -------------------------------------------------- */

  // http://goo.gl/Ghhys

  truncateMobile: function(reply, initialHeight) {
    if(!reply.hasClass('truncated')) {
      var userTextarea = reply.find('.user_textarea'),
        paragraphsOrLists = userTextarea.find('p, ul, ol');

      var fullHeight = 0;

      // Set initial height

      userTextarea.css('max-height', initialHeight);

      // Measure total height of content

      paragraphsOrLists.each(function() {
        fullHeight += $(this).outerHeight(true);
      });

      if(fullHeight > initialHeight) {
        userTextarea.append('<div class="fade_overlay"></div>');

        // TODO: I18n

        $('<a class="unhide_trigger">Vis</a>').prependTo(reply.find('.post_options'));

        var fadeOverlay = userTextarea.find('.fade_overlay'),
          duration = 100,
          unhideTrigger = reply.find('.unhide_trigger');

        function unhideToggle(target) {
          target.on('tap', function() {
            var userTextarea = $(this).closest('.reply').find('.user_textarea');

            if(!userTextarea.hasClass('expanded')) {
              userTextarea.css('height', userTextarea.height())
                .css('max-height', 9999);

              userTextarea.animate({
                'height': fullHeight
              });

              fadeOverlay.fadeOut(duration);
              // unhideTrigger.fadeOut(duration);

              paragraphsOrLists.show();

              userTextarea.addClass('expanded');
            } else {
              userTextarea.animate({
                'height': initialHeight
              });

              fadeOverlay.fadeIn(duration);
              // unhideTrigger.fadeIn(duration);

              paragraphsOrLists.slice(1).hide();

              userTextarea.removeClass('expanded');
            }
          });
        }

        unhideToggle(userTextarea);
        unhideToggle(unhideTrigger);

        // Mark as truncated

        reply.addClass('truncated');
      }
    }
  },

  /* -------------------------------------------------- */

  truncateReplies: function(options) {
    var container = options.container;

    /* -------------------------------------------------- */

    function truncateReplies(reply) {
      if(GLOBAL_CONFIG.isDesktop) {
        if(GLOBAL_CONFIG.isRootPath || GLOBAL_CONFIG.isForumShowPath) {
          $.feeds.truncateDesktop(reply, 18);
        } else {
          $.feeds.truncateDesktop(reply, 40);
        }
      } else {
        if(GLOBAL_CONFIG.isRootPath || GLOBAL_CONFIG.isForumShowPath) {
          $.feeds.truncateMobile(reply, 60);
        } else {
          $.feeds.truncateMobile(reply, 120);
        }
      }

      reply.find('.user_textarea').find('p, ul, ol').not(':first').hide();
    }

    if(options.insertAfterPageLoad) {

      // Corresponds to `$.feeds.processPost` in `posting.js`

      truncateReplies(container)
    } else {

      // Process entire topic on page load

      container.find('.reply').each(function() {
        truncateReplies($(this))
      });
    }
  },

  /* -------------------------------------------------- */

  // Remove black borders from YouTube videos

  cropForYouTube: function(element) {
    var currentWidth = element.width(),
      currentHeight = element.height();

    element.css('overflow', 'hidden')
      .css('position', 'relative');

    element.width(currentWidth)
      .find('img')
      .css('position', 'absolute')
      .css('max-width', 'none')
      .css('width', currentWidth + 20)
      .css('left', -10);

    // Get rid of 4:3 black bars by cropping height at 16:9 w/ a 5px top and bottom error margin

    // TODO: Make error margin relative to thumbnail size

    var newHeight = (currentWidth / 16) * 9 - 10;

    // http://goo.gl/1FuJDi

    element.height(newHeight)
      .find('img')
      .css('top', (newHeight - currentHeight) / 2 - 5);

    // Mark as processed incase of page change

    element.addClass('processed');
  },

  // Make BandCamp thumbnails the same width as their parent elements

  fixBandCampWidth: function(element) {
    var thumbnail = element.find('img'),
      thumbnailWidth = thumbnail.width(),
      elementWidth = element.width();

    if(elementWidth != thumbnailWidth) {
      thumbnail.css('width', elementWidth);
    }
  },

  /* -------------------------------------------------- */

  embedPreview: function(container) {
    var paragraph = container.find('p'),
      firstParagraph = paragraph.first();

    if(!$.feeds.hasPhotos(container) && $.feeds.hasEmbed(container)) {
      $('<div class="embed_preview" />').insertAfter(container);

      var embedPreviewContainer = container.closest('.topic').find('.embed_preview'),
        embedPreview = paragraph.find('.embed').first().clone(true).appendTo(embedPreviewContainer);

      embedPreview.imagesLoaded(function() {
        if(embedPreview.hasClass('youtube')) {
          $.feeds.cropForYouTube(embedPreview);

          embedPreview.css('opacity', '1');
        } else if(embedPreview.hasClass('bandcamp')) {
          $.feeds.fixBandCampWidth(embedPreview);

          embedPreview.css('opacity', '1');
        }
      });
    }

    // Mark as processed

    container.closest('.topic').addClass('has_embed_preview');
  },

  /* -------------------------------------------------- */

  processAttachments: function(container) {
    var photos = container.find('.photos'),
      photo = photos.find('img'),
      thumbnails = container.closest('.topic').find('.thumbnails'),
      thumbnail = thumbnails.find('img');

    if(photo.length > 1) {
      photo.hide();
      photo.first().show();

      thumbnails.show();

      function selectPhoto() {
        var photos = thumbnail.closest('.topic').find('.photos')[0];

        $('img', photos).hide();
        $('img:eq(' + $(this).index() + ')', photos).show();
      }

      thumbnail.on('mouseenter touchstart', selectPhoto);
    }

    // MP4 playback

    var video = container.find('video');

    function autoPlayIfVisible() {
      if(video.visible()) {
        video.get(0).play();
      } else {
        video.get(0).pause();
      }
    }

    if(video.length) {
      if(GLOBAL_CONFIG.isDesktop) {
        $(document).scroll(function() {
          autoPlayIfVisible();
        });
      } else {
        globalVar.regularFeedScroller.on('scroll', function() {
          autoPlayIfVisible();
        });
      }
      autoPlayIfVisible();
    }
  },

  /* -------------------------------------------------- */

  postHover: function(container) {
    var postTriggers = container.find('.post_options');

    container.mouseenter(function() {
      postTriggers.find('.progressive').css('visibility', 'visible');
    }).mouseleave(function() {
      postTriggers.find('.progressive').css('visibility', 'hidden');
    });

    /* -------------------------------------------------- */

    postTriggers.find('.trigger').each(function() {
      $.triggerDescriptions($(this));
    });

    /* -------------------------------------------------- */

    postTriggers.find('.item').on('tap', function() {
      var trigger = $(this).closest('div');

      trigger.find('.trigger').addClass('hovered');
      trigger.find('.sub').css('visibility', 'visible');
    });

    $.hideOnOutsideClick({
      container: postTriggers.find('.sub'),
      trigger: postTriggers.find('.more_trigger'),
      hasActiveClass: true
    });
  },

  /* -------------------------------------------------- */

  fetchReplies: function(container) {
    var replies = container,
      firstPost = replies.closest('.topic').find('.first_post'),
      fetchRepliesTrigger = firstPost.find('.fetch_replies_trigger'),
      hideRepliesTrigger = firstPost.find('.hide_replies_trigger');

    fetchRepliesTrigger.on('tap', function() {
      if(!replies.hasClass('processed')) {

        // SpinKit

        var spinner_wave = $('<div class="spinner_wave fetch_replies_spinner_wave" />').insertAfter(fetchRepliesTrigger);

        $('<div class="box_1" />').appendTo(spinner_wave);
        $('<div class="box_2" />').appendTo(spinner_wave);
        $('<div class="box_3" />').appendTo(spinner_wave);
        $('<div class="box_4" />').appendTo(spinner_wave);
        $('<div class="box_5" />').appendTo(spinner_wave);

        // Get replies from topic path

        var topicPathUrl = firstPost.find('.title').attr('href');

        $.get(topicPathUrl, function(html) {
          $(html).find('.replies .reply').slice(0, -2).prependTo(replies);

          newReplies = replies.find('.reply').slice(0, -2);

          newReplies.each(function() {
            var reply = $(this);

            $.feeds.processPost({
              feedType: 'regular',
              container: reply,
              insertAfterPageLoad: true
            });

            $.posting.prepareReplyComposeForms(reply.find('form'));
          });

          spinner_wave.remove();
          hideRepliesTrigger.show();

          replies.addClass('processed');
        });
      } else {

        // If already fetched and hidden

        newReplies.show();
        hideRepliesTrigger.show();
      }

      fetchRepliesTrigger.hide();
    });

    hideRepliesTrigger.on('tap', function() {
      newReplies.hide();
      hideRepliesTrigger.hide();

      fetchRepliesTrigger.show();
    });
  },

  /* -------------------------------------------------- */

  slideDownAndFadeIn: function(options) {
    var post = options.container;

    // Scroll to post incase it's off the screen

    // Disable for new topics due to slide up on completion

    // if(options.formType === 'reply') {
    //   $.scrollToContainer(post);
    // }

    post.imagesLoaded(function() {

      // Simultaneous slide down and fade in required due to existing opacity

      // http://goo.gl/YlXIjl

      post.hide();

      post.slideDown('fast').animate({
        opacity: 1
      }, {
        queue: false,
        duration: 'fast'
      });

      NProgress.done();

      if(GLOBAL_CONFIG.isMobile) {
        globalVar.doubleBounceLoader.hide();
      }
    });
  },

  /* -------------------------------------------------- */

  processPost: function(options) {
    NProgress.start();

    if(GLOBAL_CONFIG.isMobile) {
      globalVar.doubleBounceLoader.show();
    }

    if(options.feedType === 'regular') {
      var post = options.container,
        userTextarea = post.find('.user_textarea');

      // Hide while processing

      post.css('opacity', 0);

      // Process posts that has links

      // Skip posts with external media, those are for jquery-oembed-all and not embedly-jquery

      if(userTextarea.find('a').length && !post.hasClass('external_media')) {
        globalVar.finishedItemsArrayRegular = userTextarea.find('a').map(function() {
          var element = $(this),
            time = 250;

          // Add slight delay to play nice with Embedly

          // http://goo.gl/w1eYjW

          setTimeout(function() {
            $.feeds.embedly({
              feedType: 'regular',
              element: element
            });
          }, time);

          time += 250;
        });
      }

      if(GLOBAL_CONFIG.isRootPath || GLOBAL_CONFIG.isForumShowPath) {
        post.find('.first_post > .user_textarea').hide();
      }

      if(GLOBAL_CONFIG.isRootPath || GLOBAL_CONFIG.isForumShowPath || GLOBAL_CONFIG.isTopicShowPath) {
        if(options.insertAfterPageLoad) {
          $.feeds.truncateReplies({
            container: post,

            // Pass on the variable

            insertAfterPageLoad: true
          });
        } else {
          $.feeds.truncateReplies({ container: post });
        }

        post.find('.oembed_twitter').oembed();
      }

      // Unhide or reveal

      if(options.insertAfterPageLoad) {
        $.feeds.slideDownAndFadeIn({
          container: post
        });
      } else {
        post.css('opacity', 1);
      }

      if(post.find('.photos, video').length) {
        $.feeds.processAttachments(post);
      }

      if(GLOBAL_CONFIG.isDesktop) {
        $.feeds.postHover(post);
      }
    } else if(options.feedType === 'media') {
      if(GLOBAL_CONFIG.isDraft) {

        // Clone content from regular feed if we haven't already

        if(!globalVar.temporaryStorage.find('#regular_feed').length) {
          $('#regular_feed').clone().appendTo(globalVar.temporaryStorage);
        }
      }

      /* -------------------------------------------------- */

      // Initialize Packery

      globalVar.pckry;

      globalVar.mediaFeed.packery({
        itemSelector: '.packery_item',
        transitionDuration: '0.2s'
      });

      globalVar.pckry = globalVar.mediaFeed.data('packery');

      var target = '.user_textarea a';

      if(options.infiniteScroll) {
        target = '.topic.incoming .user_textarea a';
      }

      globalVar.finishedItemsArrayMedia = globalVar.temporaryStorage.find(target).not('.source').map(function() {
        var element = $(this),
          time = 250;

        // Add slight delay to play nice with Embedly

        // http://goo.gl/w1eYjW

        setTimeout(function() {
          $.feeds.embedly({
            feedType: 'media',
            element: element
          });
        }, time);

        time += 250;

        if(options.infiniteScroll) {

          // Remove incoming flag

          element.closest('.topic').removeClass('incoming');
        }
      });
    }
  },

  /* -------------------------------------------------- */

  finalizeArray: function(options) {
    var feed;

    if(GLOBAL_CONFIG.hasRegularFeed) {
      feed = globalVar.regularFeed;
    } else if(GLOBAL_CONFIG.hasMediaFeed) {
      feed = globalVar.mediaFeed;
    }

    $.when.apply($, options.array).done(function() {
      feed.imagesLoaded(function() {
        NProgress.done();

        if(GLOBAL_CONFIG.isMobile) {
          globalVar.doubleBounceLoader.hide();

          // Refresh iScroll

          setTimeout(function() {
            if(GLOBAL_CONFIG.hasRegularFeed) {
              globalVar.regularFeedScroller.refresh();
            } else if(GLOBAL_CONFIG.hasMediaFeed) {
              globalVar.mediaFeedScroller.refresh();
            }
          }, 500);
        }
      });

      if(GLOBAL_CONFIG.hasRegularFeed) {

        // Mark as processed incase of page change, unless topic show path was visited directly

        if(!GLOBAL_CONFIG.isTopicShowPath) {
          globalVar.regularFeed.addClass('processed');
        }
      }

      // For infinite scrolling

      if(GLOBAL_CONFIG.isLoading) {

        // Let the outside know we're done

        GLOBAL_CONFIG.isLoading = false;
      }

      // Clean up

      options.array = [];
    });
  }
}

/* -------------------------------------------------- */

$(document).on('pagecontainershow', function() {
  var feeds = function() {
    if(GLOBAL_CONFIG.isDesktop) {
      $.extend(globalVar, {
        regularFeed: globalVar.activePage.find('#regular_feed'),
        mediaFeed: globalVar.activePage.find('#media_feed_container')
      });
    } else {

      // iScroll containers created by `scrolling_mobile.js` prior to this

      $.extend(globalVar, {
        regularFeed: globalVar.activePage.find('#regular_feed .scroller'),
        mediaFeed: globalVar.activePage.find('#media_feed_container .scroller')
      });
    }

    globalVar.temporaryStorage = globalVar.activePage.find('#temporary_storage');

    /* -------------------------------------------------- */

    var initializeRegularFeed = function() {
      if(GLOBAL_CONFIG.hasRegularFeed) {
        globalVar.regularFeed.find('.topic').each(function() {
          var topic = $(this),
            fetchRepliesTrigger = topic.find('.first_post .fetch_replies_trigger'),
            replies = topic.find('.replies'),
            reply = replies.find('.reply');

          $.feeds.processPost({
            feedType: 'regular',
            container: topic
          });

          if(replies.length) {
            reply.each(function() {
              $.feeds.processPost({
                feedType: 'regular',
                container: $(this)
              });
            });

            if((GLOBAL_CONFIG.isRootPath || GLOBAL_CONFIG.isForumShowPath) && fetchRepliesTrigger.length) {
              $.feeds.fetchReplies(replies);
            }
          }
        });

        // If links are present

        if(globalVar.activePage.find('.user_textarea a').length) {
          $.feeds.finalizeArray({
            feedType: 'regular',
            array: globalVar.finishedItemsArrayRegular
          });
        } else {
          globalVar.regularFeed.imagesLoaded(function() {
            NProgress.done();

            if(GLOBAL_CONFIG.isMobile) {
              globalVar.doubleBounceLoader.hide();
            }
          });
        }
      }

      GLOBAL_CONFIG.hasRegularFeed = true;
    }();

    /* -------------------------------------------------- */

    var initializeMediaFeed = function() {
      if(GLOBAL_CONFIG.hasMediaFeed) {
        if(GLOBAL_CONFIG.isDraft) {

          // Clone content from regular feed if we haven't already

          if(!globalVar.temporaryStorage.find('#regular_feed').length) {
            $('#regular_feed').clone().appendTo(globalVar.temporaryStorage);
          }
        }

        $.feeds.processPost({ feedType: 'media' });

        $.feeds.finalizeArray({
          feedType: 'media',
          array: globalVar.finishedItemsArrayMedia
        });
      }

      GLOBAL_CONFIG.hasMediaFeed = true;
    }();
  }();
});

