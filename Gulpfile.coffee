gulp = require 'gulp'
browserify = require 'browserify'
streamify = require 'gulp-streamify'
source = require 'vinyl-source-stream'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
uglify = require 'gulp-uglify'
concat = require 'gulp-concat'
sass = require 'gulp-sass'
minifyCss = require 'gulp-minify-css'
rename = require 'gulp-rename'
rework = require 'gulp-rework'
reworkNPM = require 'rework-npm'
templateCache = require 'gulp-angular-templatecache'

_ = require 'lodash'
fs = require 'fs'
util = require 'util'
stream = require 'stream'

config = (params) ->
  attrs = [
    'AUTHURL'
    'VERIFYURL'
    'SCOPE'
    'SSHURL'
    'DISK'
    'DISKMAX'
    'MEMORY'
    'MEMORYMAX'
  ]
  _.defaults params,
    _.pick process.env, attrs
  fs.writeFileSync 'www/js/config.json', util.inspect(params)

class StringStream extends stream.Readable
  constructor: (@str) ->
    super()

  _read: (size) ->
    @push @str
    @push null
    
gulp.task 'default', ['coffee', 'css']

gulp.task 'scssAll', ->
  gulp.src 'scss/ionic.app.scss'
    .pipe sass()
    .pipe concat 'scss.css'
    .pipe gulp.dest 'www/css'

gulp.task 'cssAll', ->
  gulp.src 'www/css/index.css'
    .pipe rework reworkNPM shim: 'angular-toastr': 'dist/angular-toastr.css'
    .pipe concat 'css.css'
    .pipe gulp.dest 'www/css'

gulp.task 'css', ['cssAll', 'scssAll'], ->
  gulp.src ['www/css/css.css', 'www/css/scss.css']
    .pipe concat 'ionic.app.css'
    .pipe gulp.dest 'www/css'
    .pipe minifyCss keepSpecialComments: 0
    .pipe rename extname: '.min.css'
    .pipe gulp.dest 'www/css'

gulp.task 'coffee', ['template'],  ->
  config CLIENT_ID: process.env.WEB_CLIENT_ID
  browserify entries: ['www/js/app.coffee']
    .transform 'coffeeify'
    .transform 'debowerify'
    .bundle()
    .pipe source 'index.js'
    .pipe gulp.dest 'www/js'
    .pipe streamify uglify()
    .pipe rename extname: '.min.js'
    .pipe gulp.dest 'www/js'
  
  
gulp.task 'template', ->
  Form = require 'sails.form'
  form = new Form
    model: require './api/models/Vm.coffee'
    include: ['name', 'disk', 'memory']
  fs.writeFileSync 'www/templates/vm/createForm.html', form.html()
  gulp.src './www/templates/**/*.html'
    .pipe templateCache(root: 'templates', standalone: true)
    .pipe gulp.dest 'www/js'
