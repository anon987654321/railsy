$.scrolling = {
  getNextPageRegularFeed: function() {

    // Find next page

    var nextPageUrl = globalVar.activePage.find('a.pagination').attr('href');

    // Proceed if next page is found

    if(nextPageUrl) {
      NProgress.start();

      if(GLOBAL_CONFIG.isMobile) {
        globalVar.doubleBounceLoader.show();
      }

      GLOBAL_CONFIG.isLoading = true;

      // Fetch next page as raw HTML

      $.get(nextPageUrl, function(html) {

        // Update pagination link

        globalVar.activePage.find('a.pagination').remove();
        $(html).find('a.pagination').appendTo(globalVar.regularFeed);

        /* -------------------------------------------------- */

        // Insert new topics

        globalVar.finishedItemsArrayRegular = $(html).find('.topic').addClass('incoming').appendTo(globalVar.regularFeed);

        globalVar.finishedItemsArrayRegular.map(function() {
          var topic = $(this);

          $.feeds.processPost({
            feedType: 'regular',
            container: topic,
            infiniteScroll: true
          });

          /* -------------------------------------------------- */

          // Reinitialize jQuery Mobile popups

          if(GLOBAL_CONFIG.isMobile) {
            topic.find('#popup_more').popup();
          }
          
          /* -------------------------------------------------- */

          // Reinitialize form labels

          topic.find('.first_post .new_reply label').inFieldLabels();

          /* -------------------------------------------------- */

          // Remove incoming flag

          topic.removeClass('incoming');
        });

        $.feeds.finalizeArray({
          feedType: 'regular',
          array: globalVar.finishedItemsArrayRegular
        });
      });
    }
  },

  /* -------------------------------------------------- */

  getNextPageMediaFeed: function() {

    // Find next page

    var nextPageUrl = globalVar.activePage.find('a.pagination').attr('href');

    // Proceed if next page is found

    if(nextPageUrl) {
      NProgress.start();

      if(GLOBAL_CONFIG.isMobile) {
        globalVar.doubleBounceLoader.show();
      }

      GLOBAL_CONFIG.isLoading = true;

      // Fetch next page as raw HTML

      $.get(nextPageUrl, function(html) {

        // Update pagination link

        globalVar.mediaFeed.find('a.pagination').remove();
        $(html).find('a.pagination').appendTo(globalVar.mediaFeed);

        // Insert new topics

        globalVar.finishedItemsArrayMedia = $(html).find('.topic').addClass('incoming').appendTo(globalVar.temporaryStorage);

        $.feeds.processPost({
          feedType: 'media',
          infiniteScroll: true,
          insertAfterPageLoad: false
        });

        $.feeds.finalizeArray({
          feedType: 'media',
          array: globalVar.finishedItemsArrayMedia
        });
      });
    }
  }
}

