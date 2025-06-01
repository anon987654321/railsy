
// TODO: http://stackoverflow.com/questions/3437585/best-way-to-add-page-specific-javascript-in-a-rails-3-app

$(document).on('pagecontainershow', function() {
  var helpSlideshow = function() {
    if(globalVar.activePage.hasClass('help')) {
      var slidesWrapper = $('.slides_wrapper');

      slidesWrapper.imagesLoaded(function() {
        slidesWrapper.caro({
          cycle: true,
          classes: {
            currentAmount: 'current_amount',
            totalAmount: 'total_amount'
          }
        });

        // Set height and width for vertical centering of the arrows

        slidesWrapper.find('.previous_next')
          .css('height', slidesWrapper.height())
          .css('width', slidesWrapper.width());
      });
    }
  }();
});

