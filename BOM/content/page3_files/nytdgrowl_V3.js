var NYTD = NYTD || {};

NYTD.Growl = (function($) {

  $(document).ready(function() {
    // Stuff to do as soon as the DOM is ready;
    var container = $(".nytdGrowlUIContainer");

    //bind a click event that will close container
    container.on('click', '.nytdGrowlNotifyCross', function() {
      container.fadeOut('slow');
    });
  });

})(NYTD.jQuery);