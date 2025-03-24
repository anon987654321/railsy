$(document).on('pagecontainershow', function() {
  var photoEditor = $('#photo_editor'),
    photoContainer = photoEditor.find('#photo_container'),
    previewPhoto = photoEditor.find('#preview_photo');

  var addPhoto = function() {
    $('.add_photo_trigger').off('tap').on('tap', function(event) {
      event.preventDefault();

      selectPhotos($(this).parent().find('.add_photo_file_field'), $(this).closest('form'), function(err, $images, $activeForm) {
        if(err) {
          return console.error(err);
        }

        initEditor($images, $activeForm);
      });
      return;
    });
  }();

  /* -------------------------------------------------- */

  function initEditor($images, $activeForm) {
    photoEditorTransition({
      $images: $images
    }, photoEditorFlow, $activeForm, addPhotos);
  }

  /* -------------------------------------------------- */

  function photoEditorFlow(o, done) {
    var $images = o.$images,
      $image = $images.shift(),
      data = [];

    next();

    function next() {
      o.$parent.hide();

      $().photoEditor({
        $parent: o.$parent,
        template: o.template,
        $image: $image,
        done: function(err, d) {
          if(err) {
            return done(err);
          }

          data.push(d);

          $image = $images.shift();

          if($image) {
            next();
          } else {
            done(null, data);
          }
        },
        init: function(err) {
          if(err) {
            return console.error(err);
          }

          o.$parent.show();

          $('#photo_editor-popup').center();

          NProgress.done();
        }
      });
    }
  }

  /* -------------------------------------------------- */

  function addPhotos(err, data, $activeForm) {
    if(err) {
      return console.error(err);
    }

    var $photos = $activeForm.find('.photos');

    if(!$photos.length) {
      return console.warn('`.photos` missing');
    }

    data.forEach(function(d) {
      var $photo = $('<div>', { 'class': 'photo' }).prependTo($photos),
        $image = $('<img>', { src: d.canvasData.toDataURL() }).appendTo($photo),
        $triggers = $('<div>', { 'class': 'triggers' }).appendTo($photo);

      if(GLOBAL_CONFIG.isDesktop) {
        var editClasses = 'edit',
          deleteClasses = 'delete';
      } else {
        var editClasses = 'edit button',
          deleteClasses = 'delete button';
      }

      $photo.data('data', d);

      // TODO: I18n

      $('<a>', { 'class': editClasses, 'href': '#' }).text('Edit').on('tap', function(e) {
        e.preventDefault();

        editPhoto($photo, d);
      }).appendTo($triggers);

      $('<a>', { 'class': deleteClasses, 'href': '#' }).text('Delete').on('tap', function(e) {
        e.preventDefault();

        $photo.remove();
      }).appendTo($triggers);

      if(GLOBAL_CONFIG.isDesktop) {
        $.triggerDescriptions($triggers.find('.edit'));
        $.triggerDescriptions($triggers.find('.delete'));
      }
    });
  }

  /* -------------------------------------------------- */

  function editPhoto($photo, data) {
    console.log('Edit photo now', data);

    photoEditorTransition({
      $image: data.$image,
      stack: data.stack
    }, function(o, done) {
      o.$parent.hide();

      $().photoEditor($.extend(o, {
        done: done,
        init: function(err) {
          if(err) return console.error(err);

          o.$parent.show();
        }
      }));
    }, function(err, d) {
      if(err) return console.error(err);

      console.log('Received data', d);

      $photo.attr('src', d.canvasData.toDataURL());
      $photo.data(d);
    });
  }

  /* -------------------------------------------------- */

  function photoEditorTransition(o, editor, $activeForm, done) {
    var template = $.parseHTML($('#template_photo_editor').html()),
      $page = $('<div id="photo_editor">');

    var editorDefaults = $.extend({
      $parent: $page,
      template: template
    }, o);

    photoEditor.html($page);

    if(GLOBAL_CONFIG.isDesktop) {

      // Open popup with delay so images get loaded and popup gets centered to viewport

      // TODO: Use `imagesLoaded` instead?

      setTimeout(function() { photoEditor.popup('open'); }, 250);
    } else {
      $.mobile.pageContainer.pagecontainer('change', photoEditor);
    }

    editor(editorDefaults, function(err, data) {
      if(GLOBAL_CONFIG.isDesktop) {
        photoEditor.popup('close');
      } else {
        $(':mobile-pagecontainer').pagecontainer('back');
      }
      done(err, data, $activeForm);
    });
  }
});

/* -------------------------------------------------- */

function selectPhotos($e, $activeForm, done) {
  $e.off('change').on('change', function(e) {
    loadPhotos($e, $activeForm, done);
  }).click();
}

function loadPhotos($e, $activeForm, done) {
  parallel(function(file, done) {
    var reader = new FileReader();

    if(!file) {
      return done('loadPhotos: File not found');
    }

    if(!file.type.match('image.*')) {
      return done('loadPhotos: Invalid file type');
    }

    reader.onloadend = function(f) {
      var data = f.currentTarget.result,
        $image = $('<img>').data('name', file.name).data('type', file.type);

      $image.on('load', function() {
        done(null, $image);
      }).on('error', function() {
        done('loadPhotos: Failed to load image');
      }).attr('src', data);
    };

    reader.readAsDataURL(file);
  }, $e.prop('files'), $activeForm, done);
}

/* -------------------------------------------------- */

function parallel(fn, data, $activeForm, done) {
  var accumulateData = [];

  for(var i = 0, len = data.length; i < len; i++) {
    fn(data[i], accumulate);
  }

  function accumulate(err, d) {
    if(err) {
      return done(err);
    }

    accumulateData.push(d);

    if(accumulateData.length == len) {
      done(null, accumulateData, $activeForm);
    }
  }
}

/* -------------------------------------------------- */

// http://goo.gl/c2UnI

function dataURItoBlob(dataURI) {

  // Convert `Base64` to raw binary data held in a string

  // Doesn't handle URL encodes

  var byteString = atob(dataURI.split(',')[1]);

  // Separate `MIME` component

  var mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0];

  // Write the bytes of the string to an `ArrayBuffer`

  var arrayBuffer = new ArrayBuffer(byteString.length),
    array = new Uint8Array(arrayBuffer);

  for(var i = 0; i < byteString.length; i++) {
    array[i] = byteString.charCodeAt(i);
  }

  // Write the `ArrayBuffer` to a blob

  return new Blob([arrayBuffer], { type: mimeString });
}

