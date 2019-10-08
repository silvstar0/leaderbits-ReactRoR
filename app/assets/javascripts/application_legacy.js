//= require shared
//= require notifyjs
//= require turbograft
//= require cable
//= require unobtrusive_flash_custom_handler
//= require_self

window.domReadyOrPjaxComplete = function() {
  $("time.timeago").timeago();

  $(document).foundation();
  $(window).trigger("load.zf.sticky");
};

initializeEverything = function() {
  //$(".prepended-pre").remove();
  //$('.prepend-pre').each(function() {
  //  var html = $(this).html().replace(/^\n+|\n+$/g, '').replace(/&lt;/g, '<').replace(/&gt;/, '>');
  //  var n = $('<pre class="prepended-pre"></pre>').text(html);
  //  $(this).before(n);
  //});

  domReadyOrPjaxComplete();
  ReactRailsUJS.mountComponents();
}

document.addEventListener('page:load', function(event) {
  initializeEverything();
  setTimeout(function() {
    Foundation.reInit($('[data-equalizer]'));
  }, 100);
});

document.addEventListener('page:before-partial-replace', function(event) {
  initializeEverything();
});

$(function() {
  initializeEverything();
});


//document.addEventListener("turbolinks:before-render", function(event) {
//  event.data.newBody.className += " no-js";
//});
$(document).on("page:before-partial-replace page:load page:update page:change page:fetch page:receive page:restore turbograft:remote:start turbograft:remote:always turbograft:remote:success turbograft:remote:fail turbograft:remote:fail:unhandled", function(event) {
  //$(".event-stream").prepend("<div>" + event.type + "</div>");
});
