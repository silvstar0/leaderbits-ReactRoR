import 'babel-polyfill';

// the goal of this method is to be defensive in gon attributes checking and catch errors asap
//@var key - example "Question.Types.SLIDER", this is equivalent of Question::Types::SLIDER in ruby
window.gonFetch = function(key) {
  var chunks = key.split('.');

  var el = gon.global;
  try {
    for (i = 0; i < chunks.length; ++i) {
      el = el[chunks[i]];
    }
    return el;
  } catch (error) {
    console.log(error);

    throw new Error('can not access key: ' + key);
  }
};

// Support component names relative to this directory:
var componentRequireContext = require.context('components', true);

//NOTE: must be accessible from outside. Some actions call it manually via respond_to { format.js }
window.ReactRailsUJS = require('react_ujs');
ReactRailsUJS.useContext(componentRequireContext);
