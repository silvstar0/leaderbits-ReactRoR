//= require shared
//= require jquery-ui/core
//= require jquery-ui/widget
//= require jquery-ui/position
//= require jquery-ui/widgets/sortable
//= require unobtrusive_flash_ui_admin
//= require jquery.tablesorter.min
//= require trix
//= require_self

jQuery.fn.autoShorten = function() {
  return this.each(function() {
    if ($(this).text().length > 100) {
      var words = $(this)
        .text()
        .substring(0, 100)
        .split(' ');
      var shortText = words.slice(0, words.length - 1).join(' ') + '...';
      $(this)
        .data('replacementText', $(this).text())
        .text(shortText)
        .css({ cursor: 'pointer' })
        .hover(
          function() {
            $(this).css({ textDecoration: 'underline' });
          },
          function() {
            $(this).css({ textDecoration: 'none' });
          }
        )
        .click(function() {
          var tempText = $(this).text();
          $(this).text($(this).data('replacementText'));
          $(this).data('replacementText', tempText);
        });
    }
  });
};

$(function() {
  $(document).foundation();

  $('time.timeago').timeago();

  $('.auto-shorten').autoShorten();

  //schedule leaderbits, instant queue leaderbits
  $('.do-sortable').sortable({
    axis: 'y',
    handle: '.handle',
    update: function() {
      $.post($(this).data('update-url'), $(this).sortable('serialize'));
    },
  });

  $('.admin-leaderbits #organization_id, .admin-leaderbits #user_uuid').change(
    function() {
      if ($(this).val() != '') {
        window.location.href = $(this).val();
      }
    }
  );
});
