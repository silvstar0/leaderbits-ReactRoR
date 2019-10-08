// NOTE: this block has to be loaded *after* notifyjs & *unobtrusive_flash*
flashHandler = function(e, params) {
  //Why it is done this way:
  // * async trigger workflow(backend and could be websocket in the future).
  // * single way(wrapper) to display them all(regular flash messages, notifyjs msgs and achievements)
  if (params.type.indexOf('achievement|') == 0) {
    // NOTE: keep route in sync with config/routes.rb if you want to change it
    $.ajax({
      url: '/achievement-modal',
      data: { type: params.type },
      dataType: 'script',
    });
  } else if (params.type.indexOf('notify|') == 0) {
    var splitted = params.type.split('|');
    var _type = splitted[0];
    //success,info,warn,error
    var className = splitted[1];
    var identifier = splitted[2];
    var position = splitted[3];

    //TODO add checks(development env only?) that ensures identifier element existence. Catch errors early

    if (
      (
        document.documentElement.textContent ||
        document.documentElement.innerText
      ).indexOf(params.message) == 0
    ) {
      //flash is already displayed
      return;
    }

    $(identifier).notify(params.message, className, { position: position });
  } else {
    //TODO Check how it handles use case there are several flash messages to be displayed

    if (params.message == '') {
      // that's a workaround to start with blank Sign In page rather than "You need to sign in or sign up before continuing."
      // trying to be nice to new users
      return;
    }

    var newNode = document.createElement('p');
    newNode.classList.add('system-alert');
    newNode.classList.add('flash-' + params.type);
    newNode.textContent = params.message;

    var referenceNode = document.querySelector('.top-header-section');
    referenceNode.prepend(newNode);
  }
};
$(window).bind('rails:flash', flashHandler);
