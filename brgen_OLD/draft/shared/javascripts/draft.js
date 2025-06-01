$(document).on('pagecontainershow', function() {
  var NProgressDemo = function() {
    NProgress.start();

    setTimeout(function() {
      NProgress.done();
    }, 1500);
  }();

  /* -------------------------------------------------- */

  /* -------------------------------------------------- */

  var inFieldLabelsDemo = function() {
    $('label').inFieldLabels();
  }();

  /* -------------------------------------------------- */

  var postingDemo = function() {

    // No need for iScroll here

    $('.new_topic select').selectize({
      plugins: ['optgroup_packery'],
      onInitialize: function() {
        selectizeInput = $('.selectize-input').find('input');
          originalPlaceholder = selectizeInput.attr('placeholder');
      },
      onDropdownOpen: function() {

        // Remove any pre-existing items

        selectizeInput.parent().find('.item').hide();

        // TODO: I18n

        selectizeInput.attr('placeholder', 'Search...');

        // TODO: This should be fixed in the latest Selectize

        selectizeInput.css('width', 'auto');
      },
      onDropdownClose: function() {
        selectizeInput.parent().find('.item').show();

        selectizeInput.attr('placeholder', originalPlaceholder);

        // TODO: This should be fixed in the latest Selectize

        selectizeInput.css('width', 'auto');
      },
    });
  }();

  /* -------------------------------------------------- */

  var photoEditorDemo = function() {

    // iOS7 range sliders

    // http://goo.gl/R5V0cZ

    $('input[type="range"]').bind('input change', function(event) {
      var item = event.target,
        value = (item.value - item.min) / (item.max - item.min);

      $(this).css(
        'background-image',
        '-webkit-gradient(linear, left top, right top, color-stop(' + value + ', #007aff), color-stop(' + value + ', #b8b7b8)'
      );
    }).trigger('change');
  }();
});

/* -------------------------------------------------- */

$(document).on('pagecreate', function(event) {
  var searchAutocompleteDemo = function() {
    var substringMatcher = function(strs) {
      return function findMatches(q, cb) {
        var matches, substrRegex;

        // Array for substring matches

        matches = [];

        // Regex to determine if a string contains the substring `q`

        substrRegex = new RegExp(q, 'i');

        // Add strings containing `q` to the `matches` array

        $.each(strs, function(i, str) {
          if (substrRegex.test(str)) {
            matches.push({ value: str });
          }
        });

        cb(matches);
      };
    };

    var states = [
      'Alabama',
      'Alaska',
      'Arizona',
      'Arkansas',
      'California',
      'Colorado',
      'Connecticut',
      'Delaware',
      'Florida',
      'Georgia',
      'Hawaii',
      'Idaho',
      'Illinois',
      'Indiana',
      'Iowa',
      'Kansas',
      'Kentucky',
      'Louisiana',
      'Maine',
      'Maryland',
      'Massachusetts',
      'Michigan',
      'Minnesota',
      'Mississippi',
      'Missouri',
      'Montana',
      'Nebraska',
      'Nevada',
      'New Hampshire',
      'New Jersey',
      'New Mexico',
      'New York',
      'North Carolina',
      'North Dakota',
      'Ohio',
      'Oklahoma',
      'Oregon',
      'Pennsylvania',
      'Rhode Island',
      'South Carolina',
      'South Dakota',
      'Tennessee',
      'Texas',
      'Utah',
      'Vermont',
      'Virginia',
      'Washington',
      'West Virginia',
      'Wisconsin',
      'Wyoming'
    ];

    $('.search input', event.target).typeahead({
      hint: true,
      highlight: true,
      minLength: 1
    }, {
      name: 'states',
      displayKey: 'value',
      source: substringMatcher(states)
    });
  }();
});

