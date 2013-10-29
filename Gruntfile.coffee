module.exports = (grunt) ->
  # Grunt configuration:
  #
  # https://github.com/cowboy/grunt/blob/master/docs/getting_started.md
  #
  grunt.initConfig

    # Project configuration
    # ---------------------
    project:
      src: "scripts"
      dev: "www"
      staging: "temp"
      components: "bower_components"
      release: "cordova/www"
      test: "test"

    clean:
      build: ["<%= project.staging %>"]
      dist: ["<%= project.release %>/js", "<%= project.release %>/images", "<%= project.release %>/css"]


    # Task configurations
    # -------------------

    # Headless testing through PhantomJS
    mocha:
      test:
        src: ["test/index.html"]


    # Watch configuration
    watch:
      css:
        files: '**/*.scss'
        tasks: ['sass']


    # Lint configuration
    # https://github.com/cowboy/grunt/blob/master/docs/task_lint.md#lint-built-in-task
    lint:
      files: ["<%= project.staging %>/**/*.js", "<%= project.test %>/spec/**/*.js"]

    # JSHint options and globals
    # https://github.com/cowboy/grunt/blob/master/docs/task_lint.md#specifying-jshint-options-and-globals
    jshint:
      options:
        curly: true
        eqeqeq: true
        immed: true
        latedef: true
        newcap: true
        noarg: true
        sub: true
        undef: true
        boss: true
        eqnull: true
        browser: true

      globals:
        Zepto: true

    requirejs:
      compile:
        options:
          baseUrl: "<%= project.src %>"
          mainConfigFile: "<%= project.src %>/config.js"
          stubModules: ["cs", "text"]
          out: "<%= project.staging %>/app.js"
          optimize: "uglify2"
          preserveLicenseComments: false
          generateSourceMaps: true
          name: "../bower_components/almond/almond"
          include: ["app"]
          exclude: ["coffee-script"]
          wrap:
            startFile: ["parts/start.frag"]
            endFile: ["parts/end.frag"]

    sass:
      compile:
        options:
          style: "compressed"
        files:
          '<%= project.dev %>/css/base.css': ['styles/base.scss']

    copy:
      dist:
        files: [

          # JS files
          src: ["<%= project.staging %>/*"]
          dest: "<%= project.release %>/js/"
          flatten: true
          expand: true
        ,

          # Images
          src: ['images/**']
          expand: true
          dest: "<%= project.release %>/"
        ,

          # css
          cwd: 'www/'
          src: ['css/**']
          expand: true
          dest: "<%= project.release %>/"
        # ,

        #   # index.html
        #   cwd: 'www/'
        #   src: 'index.html'
        #   expand: true
        #   dest: '<%= project.release %>/'
        ]

    shell:
      cordovaDeploy:
        command: 'cd cordova; cordova build ios'
      cordovaEmulate:
        command: 'cd cordova; cordova emulate ios'

  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-jshint"
  grunt.loadNpmTasks "grunt-contrib-sass"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-requirejs"
  grunt.loadNpmTasks "grunt-shell"
  grunt.loadNpmTasks "grunt-mocha"

  # Aliases
  # -------
  grunt.registerTask "default", ["watch"]
  grunt.registerTask "build", ["clean", "requirejs", "sass", "copy", "shell:cordovaDeploy", "shell:cordovaEmulate"]
  grunt.registerTask "test", ["mocha"]

