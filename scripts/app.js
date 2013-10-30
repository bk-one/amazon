// Requiring and return the CoffeeScript App module.
// Nested requires mean we can use a separate config.js
require(['cs!csapp'], function (App) {
  return App;
});
