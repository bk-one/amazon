'use strict';

require.config({
  paths: {

    // Third-part libs
    jquery: '../bower_components/zepto/zepto',
    underscore: '../bower_components/lodash/dist/lodash.underscore',
    backbone: '../bower_components/backbone-amd/backbone',
    cs: '../bower_components/require-cs/cs',
    'coffee-script': '../bower_components/require-cs/coffee-script',
    text: '../bower_components/requirejs-text/text',
    localstorage: '../bower_components/backbone.localStorage/backbone.localStorage',
    hammer: '../bower_components/hammerjs/dist/hammer',
    'jquery.hammer': '../bower_components/hammerjs/plugins/jquery.hammer'
  },
  // Shims for non-AMD modules
  shim: {
    underscore: {
      exports: '_'
    },
    // this shim actually for zepto...
    jquery: {
      exports: '$'
    },
    localstorage: {
      deps: ['backbone'],
      exports: 'Backbone.LocalStorage'
    },
    hammer: {
        exports: 'Hammer'
    },
    'jquery.hammer': {
        deps: ['hammer', 'jquery']
    }
  },
});
