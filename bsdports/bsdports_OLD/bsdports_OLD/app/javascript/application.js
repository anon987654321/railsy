import "@hotwired/turbo-rails"
import "./channels"
import "./controllers"

// import "./jquery"

$(document).on("turbo:load", function() {
  var searchMakeup = function() {
    $("#search input").on("focus blur", function() {
      $(this)
        .parent()
        .parent()
        .toggleClass("focus");
    });
  }

  // --

  var showSites = function() {
    function changeSite() {
      const sites = new Array(
        "brgen.no",
        "oshlo.no",
        "stvanger.no",
        "trndheim.no"
      );

      let randomSite = sites[Math.floor(Math.random() * sites.length)];

      $("footer span").fadeOut(1000, () => $("footer span").text(randomSite));
      $("footer span").fadeIn();

      setTimeout(changeSite, 2000);
    }
    changeSite();
  }
});

