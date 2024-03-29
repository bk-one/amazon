// Generated by CoffeeScript 1.6.3
var folderMount, livereloadSnippet, path;

path = require('path');

livereloadSnippet = require('grunt-contrib-livereload/lib/utils').livereloadSnippet;

folderMount = function(connect, point) {
  return connect["static"](path.resolve(point));
};

module.exports = function(grunt) {
  grunt.initConfig({
    project: {
      src: "scripts",
      staging: "temp",
      components: "bower_components",
      vendor: "vendor",
      release: "cordova/www",
      test: "test"
    },
    clean: {
      build: ["<%= project.staging %>"],
      dist: ["<%= project.release %>/js"]
    },
    connect: {
      server: {
        options: {
          port: 9001,
          middleware: function(connect, options) {
            return [livereloadSnippet, folderMount(connect, '.')];
          }
        }
      }
    },
    mocha: {
      test: {
        src: ["test/index.html"]
      }
    },
    watch: {
      options: {
        livereload: true
      },
      stylesheets: {
        files: '**/*.scss',
        tasks: ['sass']
      },
      html: {
        files: '**/*.html'
      }
    },
    lint: {
      files: ["<%= project.staging %>/**/*.js", "<%= project.test %>/spec/**/*.js"]
    },
    jshint: {
      options: {
        curly: true,
        eqeqeq: true,
        immed: true,
        latedef: true,
        newcap: true,
        noarg: true,
        sub: true,
        undef: true,
        boss: true,
        eqnull: true,
        browser: true
      },
      globals: {
        Zepto: true
      }
    },
    requirejs: {
      compile: {
        options: {
          baseUrl: "<%= project.src %>",
          mainConfigFile: "<%= project.src %>/config.js",
          stubModules: ["cs", "text"],
          out: "<%= project.staging %>/app.js",
          optimize: "uglify2",
          preserveLicenseComments: false,
          generateSourceMaps: true,
          name: "../bower_components/almond/almond",
          include: ["app"],
          exclude: ["coffee-script"],
          wrap: {
            startFile: ["parts/start.frag"],
            endFile: ["parts/end.frag"]
          }
        }
      }
    },
    sass: {
      compile: {
        options: {
          style: "compressed"
        },
        files: {
          '<%= project.release %>/css/base.css': ['styles/base.scss']
        }
      }
    },
    copy: {
      dist: {
        files: [
          {
            src: ["<%= project.staging %>/*"],
            dest: "<%= project.release %>/js/",
            flatten: true,
            expand: true
          }, {
            src: ['images/**'],
            expand: true,
            dest: "<%= project.release %>/"
          }
        ]
      }
    }
  });
  grunt.loadNpmTasks("grunt-contrib-clean");
  grunt.loadNpmTasks("grunt-contrib-copy");
  grunt.loadNpmTasks("grunt-contrib-connect");
  grunt.loadNpmTasks("grunt-contrib-jshint");
  grunt.loadNpmTasks("grunt-contrib-sass");
  grunt.loadNpmTasks("grunt-contrib-watch");
  grunt.loadNpmTasks("grunt-contrib-requirejs");
  grunt.loadNpmTasks("grunt-mocha");
  grunt.registerTask("default", ["watch"]);
  grunt.registerTask("build", ["clean", "requirejs", "sass", "copy"]);
  return grunt.registerTask("test", ["mocha"]);
};
