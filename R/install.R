## Heavily based on https://github.com/rstudio/blogdown/blob/master/R/install.R,
# (c) Yihui, GPL-3


#' Install dockermachine
#'
#' Download the appropriate dockermachine executable for your platform from Github and
#' try to copy it to a system directory so \pkg{blogdown} can run the
#' \command{dockermachine} command to build a site. \code{update_dockermachine()} is a wrapper of
#' \code{install_dockermachine(force = TRUE)}.
#'
#' This function tries to install dockermachine to \code{Sys.getenv('APPDATA')} on
#' Windows, \file{~/Library/Application Support} on macOS, and \file{~/bin/} on
#' other platforms (such as Linux). If these directories are not writable, the
#' package directory \file{dockermachine} of \pkg{dockermachine} will be used. If it still
#' fails, you have to install dockermachine by yourself and make sure it can be found via
#' the environment variable \code{PATH}.
#'
#' This is just a helper function and may fail to choose the correct dockermachine
#' executable for your operating system, especially if you are not on Windows or
#' Mac or a major Linux distribution. When in doubt, read the docker-machine documentation
#' and install it by yourself: \url{https://docs.docker.com/machine/}.
#' @param version The dockermachine version number, e.g., \code{0.26}; the special value
#'   \code{latest} means the latest version (fetched from Github releases).

#' @param force Whether to install dockermachine even if it has already been installed.
#'   This may be useful when upgrading dockermachine
#' @export
install_dockermachine = function(
  version = 'latest', use_brew = Sys.which('brew') != '', force = FALSE
) {

  if (Sys.which('docker-machine') != '' && !force) {
    message('It seems docker-machine has been installed. Use force = TRUE to reinstall or upgrade.')
    return(invisible())
  }

  # in theory, should access the Github API using httr/jsonlite but this
  # poor-man's version may work as well
  if (version == 'latest') {
    h = readLines('https://github.com/docker/machine/releases/latest', warn = FALSE)
    r = '^.*?releases/tag/v([0-9.]+)".*'
    version = gsub(r, '\\1', grep(r, h, value = TRUE)[1])
    message('The latest docker-machine version is ', version)
  } else if (use_brew) warning(
    "when use_brew = TRUE, only the latest version of docker-machine can be installed"
  )
  version = gsub('^[vV]', '', version)  # pure version number
  version2 = as.numeric_version(version)
  bit = if (grepl('64', Sys.info()[['machine']])) '64bit' else '32bit'
  base = sprintf('https://github.com/docker/machine/releases/download/v%s/', version)
  owd = setwd(tempdir())
  on.exit(setwd(owd), add = TRUE)
  unlink(sprintf('docker-machine_%s*', version), recursive = TRUE)

  download_zip = function(OS, type = 'zip') {
    zipfile = sprintf('docker-machine_%s_%s-%s.%s', version, OS, bit, type)
    download2(paste0(base, zipfile), zipfile, mode = 'wb')
    switch(type, zip = utils::unzip(zipfile), tar.gz = {
      files = utils::untar(zipfile, list = TRUE)
      utils::untar(zipfile)
      files
    })
  }

  files = if (is_windows()) {
    download_zip('Windows')
  } else if (is_osx()) {
    download_zip(
      if (version2 >= '0.18') 'macOS' else 'MacOS',
      if (version2 >= '0.20.3') 'tar.gz' else 'zip'
    )
  } else {
    download_zip('Linux', 'tar.gz')  # _might_ be Linux; good luck
  }
  exec = files[grep(sprintf('^dockermachine_%s.+', version), basename(files))][1]
  if (is_windows()) {
    file.rename(exec, 'docker-machine.exe')
    exec = 'docker-machine.exe'
  } else {
    file.rename(exec, 'docker-machine')
    exec = 'docker-machine'
    Sys.chmod(exec, '0755')  # chmod +x
  }

  success = FALSE
  dirs = bin_paths()
  for (destdir in dirs) {
    dir.create(destdir, showWarnings = FALSE)
    success = file.copy(exec, destdir, overwrite = TRUE)
    if (success) break
  }
  file.remove(exec)
  if (!success) stop(
    'Unable to install docker-machine to any of these dirs: ',
    paste(dirs, collapse = ', ')
  )
  message('docker-machine has been installed to ', normalizePath(destdir))
}

#' @export
#' @rdname install_dockermachine
update_dockermachine = function() install_dockermachine(force = TRUE)




# possible locations of the dockermachine executable
bin_paths = function(dir = 'dockermachine', extra_path = getOption('dockermachine.dir')) {
  if (is_windows()) {
    path = Sys.getenv('APPDATA', '')
    path = if (dir_exists(path)) file.path(path, dir)
  } else if (is_osx()) {
    path = '~/Library/Application Support'
    path = if (dir_exists(path)) file.path(path, dir)
  } else {
    path = '~/bin'
  }
  path = c(extra_path, path, pkg_file(dir, mustWork = FALSE))
  path
}

# find an executable from PATH, APPDATA, system.file(), ~/bin, etc
find_exec = function(cmd, dir, info = '') {
  for (d in bin_paths(dir)) {
    exec = if (is_windows()) paste0(cmd, ".exe") else cmd
    path = file.path(d, exec)
    if (utils::file_test("-x", path)) break else path = ''
  }
  if (path == '') {
    path = Sys.which(cmd)
    if (path == '') stop(
      cmd, ' not found. ', info, call. = FALSE
    )
    return(cmd)  # do not use the full path of the command
  }
  normalizePath(path)
}

find_dockermachine = local({
  path = NULL  # cache the path to dockermachine
  function() {
    if (is.null(path)) {
      path <<- find_exec(
        'dockermachine', 'dockermachine', 'You can install it via blogdown::install_dockermachine()'
      )
      ver = dockermachine_version()
      if (is.numeric_version(ver) && ver < '0.18') stop(
        'Found dockermachine at ', path, ' but the version is too low (', ver, '). ',
        'You may try blogdown::install_dockermachine(force = TRUE).'
      )
    }
    path
  }
})