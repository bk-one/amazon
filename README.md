Installing Cordova
------------------

    [sudo] npm install -g cordova

Adding platforms
-------------

    cd cordova
    cordova platforms add ios android

Installing/Updating dependencies
--------------------------------

Install NodeJS dependencies:

    npm install

Install client-side JavaScript components:

    bower install


Building
--------

Using grunt:

    grunt build

This will build the files with the requirejs optimizer, copy everything into cordova/www, then run cordova build


Testing
-------

1) Using PhantomJS:

    grunt test


2) In browser, go to :

    /test/

