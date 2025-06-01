
// jQuery Mobile infinite scrolling

// http://goo.gl/ZK9b5x

/* -------------------------------------------------- */

// https://api.jquerymobile.com/scrollstop/

$(document).on('scrollstop', function() {
  var contentHeight = globalVar.activePage.find('.ui-content').outerHeight(),
    screenHeight = $(window).height(),
    scrollStart = $(window).scrollTop(),
    scrollEnd = contentHeight - screenHeight;

  /* -------------------------------------------------- */

  // Calculate when we're 350px from the page bottom

  if(scrollStart >= scrollEnd - 350 && !GLOBAL_CONFIG.isLoading) {
    if(GLOBAL_CONFIG.isRootPath && GLOBAL_CONFIG.hasRegularFeed) {
      $.scrolling.getNextPageRegularFeed();
    }

    if(GLOBAL_CONFIG.hasMediaFeed) {
      $.scrolling.getNextPageMediaFeed();
    }

    /* -------------------------------------------------- */

    if(GLOBAL_CONFIG.isDraft) {
      console.log('Bottom reached');
    }
  }
});

