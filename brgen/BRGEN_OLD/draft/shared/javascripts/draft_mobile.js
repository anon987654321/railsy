$(document).on('pagecontainershow', function() {
  var photoEffects = function() {
    if($('#photo_editor').length) {
      $('.layer').caro({
        cycle: true
      });
    }
  }();

  /* -------------------------------------------------- */

  /* These are originally run from `polling.js` which is not included in this draft */

  var affiliateProductsDemo = function() {
    $.affiliateProducts.banner(globalVar.activePage.find('.affiliate_products_banner'));
    $.affiliateProducts.jqmPage(globalVar.activePage.find('#affiliate_products_jqm_page'));
  }();
});

