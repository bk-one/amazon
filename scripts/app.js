var init = function() {
    // Requiring and return the CoffeeScript App module.
    require(['cs!csapp'], function (App) {
      return App;
    });
};

if (window.cordova) {
    document.addEventListener('deviceready', init, false);
} else {
    init();
}

