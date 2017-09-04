
is_windows = function() .Platform$OS.type == 'windows'
is_osx = function() Sys.info()[['sysname']] == 'Darwin'
is_linux = function() Sys.info()[['sysname']] == 'Linux'




# adapted from webshot:::download_no_libcurl due to the fact that
# download.file() cannot download Github release assets:
# https://stat.ethz.ch/pipermail/r-devel/2016-June/072852.html
download2 = function(url, ...) {
  download = function(method = 'auto', extra = getOption('download.file.extra')) {
    download.file(url, ..., method = method, extra = extra)
  }
  if (is_windows())
    return(tryCatch(download(method = 'wininet'), error = function(e) {
      download()  # try default method if wininet fails
    }))

  R340 = getRversion() >= '3.4.0'
  if (R340 && download() == 0) return(0L)
  # if non-Windows, check for libcurl/curl/wget/lynx, call download.file with
  # appropriate method
  res = NA
  if (Sys.which('curl') != '') {
    # curl needs to add a -L option to follow redirects
    if ((res <- download(method = 'curl', extra = '-L')) == 0) return(res)
  }
  if (Sys.which('wget') != '') {
    if ((res <- download(method = 'wget')) == 0) return(res)
  }
  if (Sys.which('lynx') != '') {
    if ((res <- download(method = 'lynx')) == 0) return(res)
  }
  if (is.na(res)) stop('no download method found (wget/curl/lynx)')

  res
}


# on Windows, try system2(), system(), and shell() in turn, and see which
# succeeds, then remember it (https://github.com/rstudio/blogdown/issues/82)
if (is_windows()) system2 = function(command, args = character(), stdout = '', ...) {
  cmd = paste(c(shQuote(command), args), collapse = ' ')
  intern = isTRUE(stdout)
  shell2 = function() shell(cmd, mustWork = TRUE, intern = intern)

  i = getOption('blogdown.windows.shell', 'system2')
  if (i == 'shell') return(shell2())
  if (i == 'system') return(system(cmd, intern = intern))

  if (intern) return(
    tryCatch(base::system2(command, args, stdout = stdout, ...), error = function(e) {
      tryCatch({
        system(cmd, intern = intern)
        options(blogdown.windows.shell = 'system')
      }, error = function(e) {
        shell2()
        options(blogdown.windows.shell = 'shell')
      })
    })
  )

  if ((res <- base::system2(command, args, ...)) == 0) return(invisible(res))

  if ((res <- system(cmd)) == 0) {
    options(blogdown.windows.shell = 'system')
  } else if ((res <- shell2()) == 0) {
    options(blogdown.windows.shell = 'shell')
  }
  invisible(res)
}


pkg_file = function(..., mustWork = TRUE) {
  system.file(..., package = 'dockermachine', mustWork = mustWork)
}

dir_exists = function(x) utils::file_test('-d', x)
