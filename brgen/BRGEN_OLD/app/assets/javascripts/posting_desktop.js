$(document).on('pagecontainershow', function() {
  var newTopic = function() {
    var trigger = globalVar.activePage.find('.new_topic_trigger'),
      expanded = trigger.next('.new_topic_expanded');

    trigger.on('tap', function() {
      trigger.hide();

      // expanded.find('label').inFieldLabels();

      // expanded.find('select').selectize({
      //   plugins: ['optgroup_packery']
      // });

      expanded.slideDown('fast');
    });

    $.triggerDescriptions(trigger.find('.add_photo_trigger'));
  }();

  /* -------------------------------------------------- */

  // $.hideOnOutsideClick({
  //   container: newTopic,
  //   newTopic: true
  // });

  // $.hideOnOutsideClick({
  //   container: newReply,
  //   newTopic: false
  // });
});

