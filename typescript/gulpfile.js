var gulp = require('gulp');
var ts = require('gulp-typescript');
var del = require('del');
var merge2 = require('merge2');
var browserify = require('browserify');
var source = require('vinyl-source-stream');

var tsconfig = require("./tsconfig.json");


gulp.task('build:ts', () => {
  var tsResult = gulp.src(tsconfig.files)
      .pipe(ts(tsconfig.compilerOptions));

  return merge2(
    tsResult.js
        .pipe(gulp.dest(tsconfig.compilerOptions.outDir)),
    tsResult.dts
        .pipe(gulp.dest(tsconfig.compilerOptions.outDir))
    );
});

gulp.task('build', ['build:ts'], () => {
  var b = browserify({
    entries: "./lib/index.js",
    standalone: "CBB",
    debug: true
  });
  
  return b.bundle()
    .pipe(source('CBBDataBus.js'))
    .pipe(gulp.dest("build"));
});

gulp.task('clean', del.bind(null, [tsconfig.compilerOptions.outDir]))
