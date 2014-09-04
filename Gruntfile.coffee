module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      assets:
        expand: true
        cwd: 'assets/js'
        src: [ '**/*.coffee' ]
        dest: 'public'
        ext: '.js'
    sass:
      assets:
        options:
          compass: true
        expand: true
        cwd: 'assets/css'
        src: [ '**/*.sass' ]
        dest: 'public'
        ext: '.css'
    haml:
      assets:
        expand: true
        cwd: 'assets/html'
        src: [ '**/*.haml' ]
        dest: 'public'
        ext: '.html'
    watch:
      coffee:
        files: 'assets/js/**/*.coffee'
        tasks: 'coffee:assets'
      sass:
        files: 'assets/css/**/*.sass'
        tasks: 'sass:assets'
      haml:
        files: 'assets/html/**/*.haml'
        tasks: 'haml:assets'
    clean:
      assets: [ "public/*", "!public/bower_components" ]

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-haml'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-notify'
  grunt.loadNpmTasks 'grunt-contrib-clean'

  grunt.registerTask 'default', [
    'coffee'
    'sass'
    'haml'
  ]
