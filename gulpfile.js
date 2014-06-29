'use strict'

var gulp      	= require('gulp')
  , purescript 	= require('gulp-purescript')
	, browserify 	= require('gulp-browserify')
	, rimraf 			= require('rimraf')
  , connect     = require('gulp-connect')
  ;

var jsFileName = 'examples.js';

var paths = {
	purescripts: ['src/*.purs'],
	javascripts: ['src/' + jsFileName],
  htmls: ['htmls/**/*'],
	dest: 'build/node_modules',
	bowerSrc: [
	  'bower_components/purescript-*/src/**/*.purs'
	]
};

gulp.task('clean', function (cb) {
  return rimraf('build/', cb);
});

gulp.task('compile', ['clean'], function() {
	var psc = purescript.pscMake({
		// Compiler options
		output: paths.dest
	});
	psc.on('error', function(e) {
		console.error(e.message);
		psc.end();
	});
	return gulp.src(paths.purescripts.concat(paths.bowerSrc)).pipe(psc)
});

gulp.task('preBrowserify', ['compile'], function() {
	// Copy examples.js into the build directory
	return gulp.src('src/' + jsFileName).pipe(gulp.dest('build'));
});

gulp.task('browserify', ['preBrowserify'], function() {
  // Single entry point to browserify
  return gulp.src(['build/' + jsFileName])
    .pipe(browserify({
    	standalone: 'examples'
      // insertGlobals : true,
      // debug : !gulp.env.production
    }))
    .pipe(gulp.dest('app'));
});

gulp.task('copy-d3', function() {
  return gulp.src('bower_components/d3/*.js').pipe(gulp.dest('app'));
});

gulp.task('copy-htmls', ['browserify'], function () {
  return gulp.src('htmls/**/*').pipe(gulp.dest('app'));
});

gulp.task('connect', ['copy-d3', 'copy-htmls'], function() {
  connect.server({
    root: 'app',
    port: 8083,
    livereload: true
  });
});

gulp.task('reload', ['browserify', 'copy-htmls'], function () {
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
