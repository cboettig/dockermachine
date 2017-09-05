## Heavily based on https://github.com/rstudio/blogdown/blob/master/R/install.R,
# (c) Yihui, GPL-3


#' Install docker-machine
#'
#' Download the appropriate docker-machine executable for your platform from Github and
#' try to copy it to a system directory. \code{update_machine()} is a wrapper of
#' \code{install_machine(force = TRUE)}.
#'
#' This function tries to install docker-machine to \code{Sys.getenv('APPDATA')} on
#' Windows, \file{~/Library/Application Support} on macOS, and \file{~/bin/} on
#' other platforms (such as Linux). If these directories are not writable, the
#' package directory \file{dockermachine} of \pkg{dockermachine} will be used. If it still
#' fails, you have to install docker-machine by yourself and make sure it can be found via
#' the environment variable \code{PATH}.
#'
#' This is just a helper function and may fail to choose the correct docker-machine
#' executable for your operating system, especially if you are not on Windows or
#' Mac or a major Linux distribution. When in doubt, read the docker-machine documentation
#' and install it by yourself: \url{https://docs.docker.com/machine/}.
#' @param version The docker-machine version number, e.g., \code{0.12.2}; the special value
#'   \code{latest} means the latest version (fetched from Github releases).

#' @param force Whether to install docker-machine even if it has already been installed.
#'   This may be useful when upgrading docker-machine
#' @export
#'
#' @importFrom utils download.file
install_machine = function(
  version = 'latest', force = FALSE
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
  }
  version = gsub('^[vV]', '', version)  # pure version number
  version2 = as.numeric_version(version)
  bit = system2("uname", "-m", stdout = TRUE)
    #if (grepl('64', Sys.info()[['machine']])) '64bit' else '32bit'
  base = sprintf('https://github.com/docker/machine/releases/download/v%s/', version)
  owd = setwd(tempdir())
  on.exit(setwd(owd), add = TRUE)
  unlink(sprintf('docker-machine_%s*', version), recursive = TRUE)

  ## not a zip file, but ready-to-go binary
  download_zip = function(OS) {
    sourcefile = sprintf('docker-machine-%s-%s', OS, bit)
    download2(paste0(base, sourcefile), sourcefile, mode = 'wb')
    sourcefile

  }

  files = if (is_windows()) {
    download_zip('Windows')
  } else {
    download_zip(
      system2("uname", "-s", stdout = TRUE)
    )
  }
  exec = files[grep(sprintf('^docker-machine-.+'), basename(files))][1]
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
#' @rdname install_machine
update_machine = function() install_machine(force = TRUE)




# possible locations of the docker-machine executable
bin_paths = function(dir = 'docker-machine', extra_path = getOption('dockermachine.dir')) {
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

find_machine = local({
  path = NULL  # cache the path to dockermachine
  function() {
    if (is.null(path)) {
      path <<- find_exec(
        'docker-machine', 'docker-machine', 'You can install it via dockermachine::install_machine()'
      )
      ver = machine_version()
    }
    path
  }
})

#' machine_cmd
#'
#' Run an arbitrary docker-machine command
#' @param ... Arguments to be passed to \code{system2('docker-machine', ...)}, e.g.
#'   \code{new_content(path)} is basically \code{machine_cmd(c('new', path))} (i.e.
#'   run the command \command{docker-machine new path}).
#' @export
#' @describeIn machine_cmd Run an arbitrary docker-machine command.
machine_cmd = function(args = character(), env = character(), stdout = TRUE, ...) {
  system2(find_machine(), args = args, env = env, stdout = stdout, ...)
}

#' @export
#' @describeIn machine_cmd Return the version number of docker-machine if possible, which is
#'   extracted from the output of \code{machine_cmd('version')}.
machine_version = function() {
  x = machine_cmd('version', stdout = TRUE)
  r = '^.*version ([0-9.]{3,}).*$'
  if (grepl(r, x)) return((gsub(r, '\\1', x)))
  warning('Cannot extract the version number from docker-machine:')
  cat(x, sep = '\n')
}



## utils ##########################


opts_to_args <- function(x, prefix=character()){
  if(length(prefix) > 0)  prefix <- paste0(prefix, "-")
  # drop empty arguments
  x <- x[vapply(x, length, integer(1)) > 0]
  out <- character()
  for(i in seq_along(x)){
    out <- c(out,
             paste0("--", prefix, gsub("_", "-", names(x[i])), " ", x[[i]]))
  }
  out
}

# swarm = TRUE ==> "--swarm"
bool_to_arg <- function(bool){
  if(bool)
    paste0("--", gsub("_", "-", deparse(substitute(bool))))
  else
    character()
}

####################################
