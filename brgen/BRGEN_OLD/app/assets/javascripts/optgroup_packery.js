
// Selectize.js option groups with Packery

// Based on `optgroup_columns` by Simon Hewitt

Selectize.define('optgroup_packery', function(options) {
  var self = this;

  options = $.extend({
    equalizeWidth: true,
    equalizeHeight: true
  }, options);

  this.getAdjacentOption = function(option, direction) {
    var options = option.closest('[data-group]').find('[data-selectable]'),
      index = options.index(option) + direction;

    return index >= 0 && index < options.length ? options.eq(index) : $();
  };

  this.onKeyDown = (function() {
    var original = self.onKeyDown;

    return function(e) {
      var index, option, options, optgroup;

      if(this.isOpen && (e.keyCode === KEY_LEFT || e.keyCode === KEY_RIGHT)) {
        self.ignoreHover = true;
        optgroup = this.$activeOption.closest('[data-group]');
        index = optgroup.find('[data-selectable]').index(this.$activeOption);

        if(e.keyCode === KEY_LEFT) {
          optgroup = optgroup.prev('[data-group]');
        } else {
          optgroup = optgroup.next('[data-group]');
        }

        options = optgroup.find('[data-selectable]');
        option = options.eq(Math.min(options.length - 1, index));

        if(option.length) {
          this.setActiveOption(option);
        }
        return;
      }

      return original.apply(this, arguments);
    };
  })();

  var pack = function() {
    var i, n, height_max, width, width_last, width_parent, optgroups;

    optgroups = $('[data-group]', self.$dropdown_content);
    n = optgroups.length;

    if(!n || !self.$dropdown_content.width()) return;

    var p = self.$dropdown_content.data('packery');

    if(p) {
      p.reloadItems();
      p.layout();
    } else {
      self.$dropdown_content.packery({
        itemSelector: '.optgroup',
        gutter: 0,
        transitionDuration: 0
      });
    }
  };

  var after = function(self, method, fn) {
    var original = self[method];

    self[method] = function() {
      var result = original.apply(self, arguments);
      fn.apply(self, arguments);
      return result;
    };
  };

  after(this, 'positionDropdown', pack);
  after(this, 'refreshOptions', pack);
});

