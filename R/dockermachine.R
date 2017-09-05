#' dockermachine
#'
#' An R interface to docker-machine.
#' @references \url{https://docs.docker.com/machine/reference}
#'
"_PACKAGE"



## the docker-machine functions:

#' docker-machine active
#'
#' See which machine is “active” (a machine is considered active
#'  if the DOCKER_HOST environment variable points to it).
#'
#' @inherit machine_config
#' @references \url{https://docs.docker.com/machine/reference/active/}
#' @examples
#'
#' machine_active(help = TRUE)
#'
#' @export
machine_active <- function(help = FALSE, env = character(), ...){
  machine_cmd(c("active", bool_to_arg(help)), env = env)
}

#' docker-machine config
#'
#' Print the connection config for machine
#'
#' @param name the machine name, default is 'machine', but can also be
#' set using \code{options("DOCKERMACHINE_NAME" = "<PICK-A-NAME>")}
#' @param swarm logical, default FALSE. Display the Swarm config instead
#'  of the Docker daemon
#' @param env Additional character vector of name=value strings to set
#'  environment variables.
#' @param help logical, default FALSE. Set to TRUE to display help
#'  information for the command instead of executing the command.
#' @param ... Additional arguments to \code{\link{system2}}
#' @return If stdout = TRUE or stderr = TRUE, a character vector giving
#'  the output of the command, one line per character string. (Output
#'  lines of more than 8095 bytes will be split.) If the command could
#'  not be run an R error is generated. If command runs but gives a
#'  non-zero exit status this will be reported with a warning and in
#'  the attribute "status" of the result: an attribute "errmsg" may
#'  also be available.
#'
#'  In other cases, the return value is an error code (0 for success),
#'  given the invisible attribute (so needs to be printed explicitly).
#'  If the command could not be run for any reason, the value is 127.
#'  Otherwise if wait = TRUE the value is the exit status returned by
#'  the command, and if wait = FALSE it is 0 (the conventional success
#'  value).
#'
#' @references \url{https://docs.docker.com/machine/reference/config/}
#'  @examples
#'  machine_config(help = TRUE)
#' @export
machine_config <- function(name = getOption("DOCKERMACHINE_NAME", "machine"),
                           swarm = FALSE,
                           help = FALSE,
                           env = character(),
                           ...){
  args <- c("config",
            bool_to_arg(swarm),
            bool_to_arg(help),
            name)

  machine_cmd(args, env = env, ...)
}



#' docker-machine create
#'
#' Create a machine. Requires the --driver flag to indicate which provider
#' (VirtualBox, DigitalOcean, AWS, etc.) the machine should be created on,
#' and an argument to indicate the name of the created machine.
#'
#' @inherit machine_config
#' @param driver name of the driver (cloud platform) to create machine with
#' @param engine_conf list of additional arguments for docker driver,
#'  see details
#' @param driver_conf list of additional arguments for docker driver config,
#'  see \code{machine_help("drivername")} for driver-specific arguments.
#' @param swarm_conf list of additional arguments for docker swarm config,
#'  see details
#'
#' @references \url{https://docs.docker.com/machine/reference/create/}
#'  @details
#' --driver, -d "none"                                                                                  Driver to create machine with.
#' --engine-install-url "https://get.docker.com"                                                        Custom URL to use for engine installation [$MACHINE_DOCKER_INSTALL_URL]
#' --engine-opt [--engine-opt option --engine-opt option]                                               Specify arbitrary flags to include with the created engine in the form flag=value
#' --engine-insecure-registry [--engine-insecure-registry option --engine-insecure-registry option]     Specify insecure registries to allow with the created engine
#' --engine-registry-mirror [--engine-registry-mirror option --engine-registry-mirror option]           Specify registry mirrors to use [$ENGINE_REGISTRY_MIRROR]
#' --engine-label [--engine-label option --engine-label option]                                         Specify labels for the created engine
#' --engine-storage-driver                                                                              Specify a storage driver to use with the engine
#' --engine-env [--engine-env option --engine-env option]                                               Specify environment variables to set in the engine
#' --swarm                                                                                              Configure Machine with Swarm
#' --swarm-image "swarm:latest"                                                                         Specify Docker image to use for Swarm [$MACHINE_SWARM_IMAGE]
#' --swarm-master                                                                                       Configure Machine to be a Swarm master
#' --swarm-discovery                                                                                    Discovery service to use with Swarm
#' --swarm-strategy "spread"                                                                            Define a default scheduling strategy for Swarm
#' --swarm-opt [--swarm-opt option --swarm-opt option]                                                  Define arbitrary flags for swarm
#' --swarm-host "tcp://0.0.0.0:3376"                                                                    ip/socket to listen on for Swarm master
#' --swarm-addr                                                                                         addr to advertise for Swarm (default: detect and use the machine IP)
#' --swarm-experimental

#' @export
#' @examples
#' \dontrun{
#' machine_create("virtualbox")
#' }
#'
machine_create <- function(driver = c("none","virtualbox", "amazonec2", "digitalocean",
                                      "exoscale", "generic", "google", "softlayer",
                                      "azure", "hyperv", "openstack", "rackspace",
                                      "vmwarefusion", "vmwarevcloudair", "vmwarevsphere"),
                           name = getOption("DOCKERMACHINE_NAME", "machine"),
                           driver_conf = list(),
                           engine_conf = list(install_url = "https://get.docker.com",
                                       opt = character(),
                                       insecure_registry = character(),
                                       regsitry_mirror = character(),
                                       label = character(),
                                       storage_driver = character(),
                                       env = character()),
                           swarm = FALSE,
                           swarm_conf = list(image = "swarm:latest",
                                           master = character(),
                                           discovery = character(),
                                           strategy = "spread",
                                           opt = character(),
                                           host = "tcp://0.0.0.0:3376",
                                           addr = character(),
                                           experimental = character()),
                           help = FALSE,
                           env = character(),
                           ...){
  driver <- match.arg(driver)
  args <- c("create",
            opts_to_args(list(driver = driver)),
            opts_to_args(driver_conf),
            opts_to_args(engine_conf, "engine"),
            bool_to_arg(swarm),
            opts_to_args(swarm_conf, 'swarm'),
            bool_to_arg(help),
            name)
  machine_cmd(args, env = env, ...)
}

# docker-machine env
#
# Set environment variables to dictate that docker should run a command against a particular machine.
# @references \url{https://docs.docker.com/machine/reference/env/}
# @inherit machine_config
machine_env <- function(name = getOption("DOCKERMACHINE_NAME", "machine"),
                        swarm = FALSE,
                        shell = c("bash", "fish", "cmd", "powershell", "tcsh"),
                        unset = FALSE,
                        no_proxy = FALSE,
                        help = FALSE,
                        env = character(),
                        ...)
{
  shell <- match.arg(shell)
  args <- c("env",
            bool_to_arg(swarm),
            opts_to_args(list(shell = shell)),
            bool_to_arg(unset),
            bool_to_arg(no_proxy),
            bool_to_arg(help),
            name)
  machine_cmd(args, env, ...)

}

#' docker-machine help
#'
#' Shows a list of commands or help for one command
#' @inherit machine_create
#' @references \url{https://docs.docker.com/machine/reference/help/}
#' @export
machine_help <- function(name = getOption("DOCKERMACHINE_NAME", "machine"),
                         swarm = FALSE,
                         env = character(),
                         ...){
  args <- c("help",
            bool_to_arg(swarm),
            name)
  machine_cmd(args, env = env, ...)
}

#' docker-machine inspect
#'
#' Inspect information about a machine
#' @inherit machine_create
#' @param format a Go formatting string
#' @references \url{https://docs.docker.com/machine/reference/inspect/}
#' @export
machine_inspect <- function(name = getOption("DOCKERMACHINE_NAME", "machine"),
                            swarm = FALSE,
                            format = list(),
                            env = character(),
                            ...){
  args <- c("inspect",
            bool_to_arg(swarm),
            opts_to_args(format, "format"),
            name)
  machine_cmd(args, env = env, ...)
}

#' docker-machine ip
#'
#' Get the IP address of one or more machines.
#' @inherit machine_create
#' @references \url{https://docs.docker.com/machine/reference/ip/}
#' @export
machine_ip  <- function(name = getOption("DOCKERMACHINE_NAME", "machine"),
                        swarm = FALSE,
                        env = character(),
                        ...){
  args <- c("ip",
            bool_to_arg(swarm),
            name)
  machine_cmd(args, env = env, ...)
}


#' docker-machine kill
#'
#' Kill (abruptly force stop) a machine
#' @inherit machine_create
#' @references \url{https://docs.docker.com/machine/reference/kill/}
#' @export
machine_kill  <- function(name = getOption("DOCKERMACHINE_NAME", "machine"),
                          swarm = FALSE,
                          env = character(),
                          ...){
  args <- c("kill",
            bool_to_arg(swarm),
            name)
  machine_cmd(args, env = env, ...)
}

#' docker-machine ls
#'
#' List machines
#' @inherit machine_create
#' @references \url{https://docs.docker.com/machine/reference/ls/}
#' @export
machine_ls <- function(name = getOption("DOCKERMACHINE_NAME", "machine"),
                       swarm = FALSE,
                       env = character(),
                       ...){
  # FIXME add the additional arguments

  args <- c("ls",
            bool_to_arg(swarm),
            name)
  machine_cmd(args, env = env, ...)
}


#' Re-run provisioning on a created machine.

#' Sometimes it may be helpful to re-run Machine’s provisioning
#'  process on a created machine.
#'
#' Reasons for doing so may include a failure during the original
#'  provisioning process, or a drift from the desired system state
#'  (including the originally specified Swarm or Engine configuration).
#'
#' @inherit machine_create
#' @references \url{https://docs.docker.com/machine/reference/provision/}
#' @export
machine_provision  <- function(name = getOption("DOCKERMACHINE_NAME", "machine"),
                               swarm = FALSE,
                               env = character(),
                               ...){
  args <- c("provision",
            bool_to_arg(swarm),
            name)
  machine_cmd(args, env = env, ...)
}

#' docker-machine regenerate-certs
#'
#' Regenerate TLS Certificates for a machine
#' @inherit machine_create
#' @references \url{https://docs.docker.com/machine/reference/regenerate-certs/}
#' @export
machine_regenerate_certs  <- function(name = getOption("DOCKERMACHINE_NAME", "machine"),
                                      swarm = FALSE,
                                      env = character(),
                                      ...){
  args <- c("regenerate-certs",
            bool_to_arg(swarm),
            name)
  machine_cmd(args, env = env, ...)
}


#' docker-machine restart
#'
#' Restart a machine
#' @inherit machine_create
#' @references \url{https://docs.docker.com/machine/reference/restart/}
#' @export
machine_restart  <- function(name = getOption("DOCKERMACHINE_NAME", "machine"),
                             swarm = FALSE,
                             env = character(),
                             ...){
  args <- c("restart",
            bool_to_arg(swarm),
            name)
  machine_cmd(args, env = env, ...)
}

#' docker-machine rm
#'
#' Remove a machine
#' @inherit machine_create
#' @param force force removal rather than asking first, logical, default TRUE
#' @references \url{https://docs.docker.com/machine/reference/rm/}
#' @export
machine_rm  <- function(name = getOption("DOCKERMACHINE_NAME", "machine"),
                        swarm = FALSE,
                        force = TRUE,
                        help = FALSE,
                        env = character(),
                        ...){
  args <- c("rm",
            bool_to_arg(swarm),
            bool_to_arg(force),
            bool_to_arg(help),
            name)
  machine_cmd(args, env = env, ...)
}

#' docker-machine scp
#'
#' Copy files to a machine over scp
#' @param from source machine, the notation is \code{machinename:/path/to/files}
#' @param to target machine
#' @inherit machine_create
#' @references \url{https://docs.docker.com/machine/reference/scp/}
#' @export
machine_scp  <- function(from, to,
                         swarm = FALSE,
                         env = character(),
                         ...){
  args <- c("scp",
            bool_to_arg(swarm),
            from,
            to)
  machine_cmd(args, env = env, ...)
}


#' docker-machine ssh
#'
#' ssh into a machine a machine
#' @inherit machine_create
#' @references \url{https://docs.docker.com/machine/reference/ssh/}
## FIXME needs interactive use to open terminal (?)
machine_ssh  <- function(name = getOption("DOCKERMACHINE_NAME", "machine"),
                         swarm = FALSE,
                         env = character(),
                         ...){
  args <- c("ssh",
            bool_to_arg(swarm),
            name)
  machine_cmd(args, env = env, ...)
}

#' docker-machine start
#'
#' Start a machine
#' @inherit machine_create
#' @references \url{https://docs.docker.com/machine/reference/start/}
#' @export
machine_start  <- function(name = getOption("DOCKERMACHINE_NAME", "machine"),
                           swarm = FALSE,
                           env = character(),
                           ...){
  args <- c("start",
            bool_to_arg(swarm),
            name)
  machine_cmd(args, env = env, ...)
}

#' docker-machine status
#'
#' Get the status of a machine
#' @inherit machine_create
#' @references \url{https://docs.docker.com/machine/reference/status/}
#' @export
machine_status  <- function(name = getOption("DOCKERMACHINE_NAME", "machine"),
                            swarm = FALSE,
                            env = character(),
                            ...){
  args <- c("status",
            bool_to_arg(swarm),
            name)
  machine_cmd(args, env = env, ...)
}

#' docker-machine stop
#'
#' Gracefully stop a machine
#' @inherit machine_create
#' @references \url{https://docs.docker.com/machine/reference/stop/}
#' @export
machine_stop  <- function(name = getOption("DOCKERMACHINE_NAME", "machine"),
                          swarm = FALSE,
                          env = character(),
                          ...){
  args <- c("stop",
            bool_to_arg(swarm),
            name)
  machine_cmd(args, env = env, ...)
}

#' docker-machine upgrade
#'
#' Upgrade to the latest version of docker on the machine
#' @inherit machine_create
#' @references \url{https://docs.docker.com/machine/reference/upgrade/}
#' @export
machine_upgrade  <- function(name = getOption("DOCKERMACHINE_NAME", "machine"),
                             swarm = FALSE,
                             env = character(),
                             ...){
  args <- c("upgrade",
            bool_to_arg(swarm),
            name)
  machine_cmd(args, env = env, ...)
}

#' docker-machine url
#'
#' Get the URL of a host
#' @inherit machine_create
#' @references \url{https://docs.docker.com/machine/reference/url/}
#' @export
machine_url  <- function(name = getOption("DOCKERMACHINE_NAME", "machine"),
                         swarm = FALSE,
                         env = character(),
                         ...){
  args <- c("url",
            bool_to_arg(swarm),
            name)
  machine_cmd(args, env = env, ...)
}

