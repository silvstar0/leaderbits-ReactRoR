//= require rails-ujs
//= require jquery
//= require foundation_minimal
//= require momentjs
//= require chartist
//= require timeago
//= require unobtrusive_flash

var timeoutId;
$(document).on("input propertychange change", ".admin_notes", function(event) {
  var container = $('.admin-notes-status', event.target.parentElement.parentElement);
  $(container).css('visibility', 'hidden');

  clearTimeout(timeoutId);
  timeoutId = setTimeout(function() {
    // Runs 1 second (1000 ms) after the last change
    saveToDB(event.target);
  }, 1000);
});

function saveToDB(textarea) {
  var container = $('.admin-notes-status', textarea.parentElement.parentElement);
  $(container).find('.text').hide();
  $(container).find('time').hide();
  $(container).find('.text.saving').show();
  $(container).css('visibility', 'visible');

  Rails.fire(textarea.closest("form"), "submit");

  setTimeout(function() {
    $(container).find('.text').hide();

    $(container).find('time').timeago('update', new Date()).show();
    $("time.timeago").timeago();
    $(container).find('.text.last-updated').show();
  }, 1000);
}
