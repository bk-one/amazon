document.addEventListener('deviceready', function() {
    // Requiring and return the CoffeeScript App module.
    require(['cs!csapp'], function (App) {
      return App;
    });
    setTimeout(function() {
        navigator.splashscreen.hide();
    }, 2000);

}, false);
