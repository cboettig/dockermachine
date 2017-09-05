
<!-- README.md is generated from README.Rmd. Please edit that file -->
dockermachine
=============

The goal of dockermachine is to provide a convenient interface to `docker-machine` from the R command line. This will allow R users to easily create, control, and destroy cloud instances across a wide variety of providers.

Installation
------------

You can install dockermachine from github with:

``` r
# install.packages("devtools")
devtools::install_github("cboettig/dockermachine")
```

Once you have installed the R package, use the helper function `install_machine()` to install the latest version of `docker-machine` on your platform, if you have not already installed it some other way:

``` r
library("dockermachine")
install_machine()
It seems docker-machine has been installed. Use force = TRUE to reinstall or upgrade.
```

The sister function `update_machine()` can be used to get a more recent version of `docker_machine()`.

Getting started
---------------

To experiment with `docker-machine`, locally, we recommend installing VirtualBox for your platform and testing out the commands using the `virtualbox` driver.

``` r
machine_create("virtualbox")
 [1] "Running pre-create checks..."                                                                                                                                                             
 [2] "Creating machine..."                                                                                                                                                                      
 [3] "(machine) Copying /Users/cboettig/.docker/machine/cache/boot2docker.iso to /Users/cboettig/.docker/machine/machines/machine/boot2docker.iso..."                                           
 [4] "(machine) Creating VirtualBox VM..."                                                                                                                                                      
 [5] "(machine) Creating SSH key..."                                                                                                                                                            
 [6] "(machine) Starting the VM..."                                                                                                                                                             
 [7] "(machine) Check network to re-create if needed..."                                                                                                                                        
 [8] "(machine) Waiting for an IP..."                                                                                                                                                           
 [9] "Waiting for machine to be running, this may take a few minutes..."                                                                                                                        
[10] "Detecting operating system of created instance..."                                                                                                                                        
[11] "Waiting for SSH to be available..."                                                                                                                                                       
[12] "Detecting the provisioner..."                                                                                                                                                             
[13] "Provisioning with boot2docker..."                                                                                                                                                         
[14] "Copying certs to the local machine directory..."                                                                                                                                          
[15] "Copying certs to the remote machine..."                                                                                                                                                   
[16] "Setting Docker configuration on the remote daemon..."                                                                                                                                     
[17] "Checking connection to Docker..."                                                                                                                                                         
[18] "Docker is up and running!"                                                                                                                                                                
[19] "To see how to connect your Docker Client to the Docker Engine running on this virtual machine, run: /Users/cboettig/Library/Application Support/docker-machine/docker-machine env machine"
```

This may take up to a few minutes to get your first machine created. By default, this creates a machine named `machine`. You can change this name (e.g. when working with many remote machines through the same client) by passing a different name to the `name` string of most any `machine_*()` command.

Once our machine is up and running, we can list all machines:

``` r
machine_ls()
[1] "NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER        ERRORS"
[2] "machine   -        virtualbox   Running   tcp://192.168.99.100:2376           v17.07.0-ce   "      
```

We are also ready now to use the `harbor` R package (or any system commands to the `docker` engine) to deploy custom R images and run R commands on the remote machines.

Use the command `machine_scp` to copy data to your local computer before destroying the remote machine, or push your results to the cloud using your preferred platform such as GitHub, Amazon S3, Google Cloud Storage, or DropBox (all accessible through the R command line with the appropriate additional packages.)

``` r
file.create("file.txt")
machine_scp("file.txt", "machine:~/filecopy.txt")
machine_scp("machine:~/filecopy.txt", ".")
```

When we're all done, we can stop and remove the machine.

``` r
machine_stop()
[1] "Stopping \"machine\"..."          "Machine \"machine\" was stopped."
machine_rm()
[1] "About to remove machine"                                                   
[2] "WARNING: This action will delete both local reference and remote instance."
[3] "Successfully removed machine"                                              
```

This step is crucial to avoid continuing to accumulate charges from a cloud provider. By combining these commands with commands to `harbor` to run code on a remote machine, this allows a user to create R scripts which can deploy long-running instances remotely and shut them down when they are finished.

Once you comfortable creating machines, controlling those machines with docker (see the `harbor` package by Winston Chang), and terminating those machines, then consider trying out one of the remote providers using your Amazon EC2, Google Cloud, Digital Ocean, Azure, openstack, or other credentials.
