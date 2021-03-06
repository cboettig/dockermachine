% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dockermachine.R
\name{machine_stop}
\alias{machine_stop}
\title{docker-machine stop}
\usage{
machine_stop(name = getOption("DOCKERMACHINE_NAME", "machine"),
  swarm = FALSE, env = character(), ...)
}
\arguments{
\item{name}{the machine name, default is 'machine', but can also be
set using \code{options("DOCKERMACHINE_NAME" = "<PICK-A-NAME>")}}

\item{swarm}{logical, default FALSE. Display the Swarm config instead
of the Docker daemon}

\item{env}{Additional character vector of name=value strings to set
environment variables.}

\item{...}{Additional arguments to \code{\link{system2}}}
}
\value{
If stdout = TRUE or stderr = TRUE, a character vector giving
 the output of the command, one line per character string. (Output
 lines of more than 8095 bytes will be split.) If the command could
 not be run an R error is generated. If command runs but gives a
 non-zero exit status this will be reported with a warning and in
 the attribute "status" of the result: an attribute "errmsg" may
 also be available.

 In other cases, the return value is an error code (0 for success),
 given the invisible attribute (so needs to be printed explicitly).
 If the command could not be run for any reason, the value is 127.
 Otherwise if wait = TRUE the value is the exit status returned by
 the command, and if wait = FALSE it is 0 (the conventional success
 value).
}
\description{
Gracefully stop a machine
}
\references{
\url{https://docs.docker.com/machine/reference/stop/}
}
