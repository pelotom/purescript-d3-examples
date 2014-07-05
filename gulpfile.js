'use strict'

var gulp      	= require('gulp')
  , purescript 	= require('gulp-purescript')
	, rimraf 			= require('rimraf')
  , connect     = require('gulp-connect')
  ;

var jsFileName = 'examples.js';

var paths = {
	purescripts: ['src/*.purs'],
	javascripts: ['src/' + jsFileName],
  htmls: ['htmls/**/*'],
	bowerSrc: [
	  'bower_components/purescript-*/src/**/*.purs'
	]
};

gulp.task('clean-htmls', function (cb) {
  rimraf('app/**/*.html', cb);
});

gulp.task('compile', function(cb) {
	var psc = purescript.psc({
		// Compiler options
		output: "examples.js",
    module: "Graphics.D3.Examples"
	});
  psc.on('error', function(e) {
    cb(e.message); // Build failed
  });
  gulp.src(paths.purescripts.concat(paths.bowerSrc))
    .pipe(psc)
    .pipe(gulp.dest("app"))
    .on('data', function () {
      cb(); // Completed successfully
    })
    ;
});

gulp.task('copy-d3', function() {
  return gulp.src('bower_components/d3/*.js').pipe(gulp.dest('app'));
});

gulp.task('copy-htmls', ['clean-htmls'], function () {
  return gulp.src('htmls/**/*').pipe(gulp.dest('app'));
});

gulp.task('connect', ['copy-d3', 'copy-htmls'], function() {
  connect.server({
    root: 'app',
    port: 8083,
    livereload: true
  });
});

gulp.task('reload', ['compile', 'copy-htmls'], function () {
  gulp.src(paths.htmls).pipe(connect.reload());
});

gulp.task('watch', ['connect'], function() {
  var allSrcs = paths.purescripts
    .concat(paths.bowerSrc)
    .concat(paths.javascripts)
    .concat(paths.htmls)
    ;
	gulp.watch(allSrcs, ['reload']);
});

gulp.task('default', ['watch']);
