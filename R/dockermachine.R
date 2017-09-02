#' dockermachine
#'
#' An R interface to docker-machine.
#'
"_PACKAGE"


## utils ##########################

dockermachine <- function(args=character(), env=character()){
  system2("docker-machine", args=args, env=env)
}

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


####################################


## the docker-machine functions:

machine_active <- function(env = character()){
  dockermachine("active", env=env)
}

machine_config <- function(swarm = FALSE, env = character()){
  args <- "config"
  if(swarm){
    args <- paste(args, "--swarm")
  }
  dockermachine(args, env=env)
}


# --driver, -d "none"                                                                                  Driver to create machine with.
# --engine-install-url "https://get.docker.com"                                                        Custom URL to use for engine installation [$MACHINE_DOCKER_INSTALL_URL]
# --engine-opt [--engine-opt option --engine-opt option]                                               Specify arbitrary flags to include with the created engine in the form flag=value
# --engine-insecure-registry [--engine-insecure-registry option --engine-insecure-registry option]     Specify insecure registries to allow with the created engine
# --engine-registry-mirror [--engine-registry-mirror option --engine-registry-mirror option]           Specify registry mirrors to use [$ENGINE_REGISTRY_MIRROR]
# --engine-label [--engine-label option --engine-label option]                                         Specify labels for the created engine
# --engine-storage-driver                                                                              Specify a storage driver to use with the engine
# --engine-env [--engine-env option --engine-env option]                                               Specify environment variables to set in the engine
# --swarm                                                                                              Configure Machine with Swarm
# --swarm-image "swarm:latest"                                                                         Specify Docker image to use for Swarm [$MACHINE_SWARM_IMAGE]
# --swarm-master                                                                                       Configure Machine to be a Swarm master
# --swarm-discovery                                                                                    Discovery service to use with Swarm
# --swarm-strategy "spread"                                                                            Define a default scheduling strategy for Swarm
# --swarm-opt [--swarm-opt option --swarm-opt option]                                                  Define arbitrary flags for swarm
# --swarm-host "tcp://0.0.0.0:3376"                                                                    ip/socket to listen on for Swarm master
# --swarm-addr                                                                                         addr to advertise for Swarm (default: detect and use the machine IP)
# --swarm-experimental

# FIXME driver should list all possible drivers and then match.arg
machine_create <- function(driver = "none",
                           engine = list(install_url = "https://get.docker.com",
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
                           env = character()){

  args <- "create"
  args <- c(args, engine, "engine")
  if(swarm) args <- paste(args, "--swarm")
  args <- c(args, opts_to_args(swarm_conf, 'swarm'))

  dockermachine(args, env=env)
}


#
# machine_env
# machine_help
# machine_inspect
# machine_ip
# machine_kill
# machine_ls
# machine_provision
# machine_regenerate_certs
# machine_restart
# machine_rm
# machine_scp
# machine_ssh
# machine_start
# machine_status
# machine_stop
# machine_upgrade
# machine_url
