# Deploying Optima using Vagrant

The following instructions walks you through the deployment of an Optima server and a 3-host Docker cloud on a single machine using Vagrant. For your convenience, a Vagrantfile is provided [here](Vagrantfile) to automatically create and setup Optima and the 3-host Docker cloud on your machine.

## Prerequisites
The machine where Optima and the 3-host Docker cloud will be deployed must have:
 * At least 8 cores and 16GB of memory.
 * VirtualBox installed. To install VirtualBox follow the instructions [here](https://www.virtualbox.org/wiki/Downloads).
 * Vagrant installed. To install Vagrant follow the instructions [here](https://www.vagrantup.com/docs/installation/).

## Creating Optima and a 3-host Docker cloud
  1. Create a new directory:
     ```
     $ mkdir ~/optima
     ```
  1. Change the working directory to the newly created one:
     ```
     $ cd ~/optima
     ```
  1. Download the Vagrant file ([Vagrantfile](Vagrantfile)) in the directory:
     ```
     $ wget https://github.com/MosaixSoft/optima/blob/master/installation/Vagrantfile
     ```
  1. Deploy all the nodes by running:
     ```
     $ vagrant up
     ```
     This creates four VMs with the following IP addresses:
      * Optima server: 192.168.1.10
      * Docker hosts: 192.168.1.11, 192.168.1.12, 192.168.1.13.

## Installing Optima Client CLI
After deploying your 4 VMs, you want to install the [Optima CLI](../README.md#optima-cli) to a system from where you want to run Optima commands from. If Debian is the operating system of the machine you used to deploy your 4 VMs using Vagrant, the CLI can be installed directly on this machine, otherwise use a separate Vagrant VM that can reach the previously created VM running the Optima server.

Alternatively you can use the [Optima REST API](../README.md#optima-restful-apis) to manage your services. We suggest using the CLI as it is easier than using the REST calls and we include here instructions to install the CLI.

**Prerequisites**:
* Ubuntu 14.04 (recommended) or any Linux OS

**Follow these steps**:

  From your Ubuntu 14.04 LTS virtual machine, download and install the Optima CLI:

  ```
  $ wget https://s3-us-west-1.amazonaws.com/optima-distribution/Optima+1.0.4/cli-4.0.7.tar.gz
  $ tar -xzvf cli-4.0.4.tar.gz
  $ cd optima-cli
  $ ./install.sh
  ```
## Activate Optima
Follow the instruction in [here](activation.md) to activate Optima.


## Mounting the Docker cloud
This section includes instructions to mount the Docker cloud using the installed CLI and to verify that the cloud is mounted and ready to be used.
1. **Create the following _cloud.yaml_ file:**

   ```yaml
   cloud:
      # name of the mounted cloud
      name: my-cloud
      provider: docker
      # username and password of the machine where optima is running
      # The username must have the sudo privileges
      username: mosaix
      password: mosaix
      # docker hosts (up to 5)
      endpoints: http://192.168.1.11:4243/, http://192.168.1.12:4243/, http://192.168.1.13:4243/
      # CPU and memory overcommit ratios
      cpuovercommit: 2    # (Default 1)
      memoryovercommit: 2 # (Default 1)
   ```

   The *cpuovercommit* and *memoryovercommit* are ratios set to define the maximum number of resources (CPU, memory) Optima is allowed to allocate per host, relative to actual amount of resources available on each host (quota = overcommit x actual).

1. **Set the CLI to target commands to Optima controller**:

   Using Optima CLI:

   ```
   $ optima target
   IP address []: 192.168.1.10
   Port number [8090]: 8090
   Target was set successfully to 192.168.1.10:8090
   ```
 1. **Mount the docker hosts as a cloud**:

    ```
    $ optima cloud mount cloud.yaml
    ```
 1. **Verify the mount was successful**:

    Run the following command:
    ```
    $ optima cloud status
    ```
    You should obtain the following output:
    ```
    {
       "CPUOverCommit": 2,
       "MemoryOverCommit": 2,
       "Name": "my-cloud",
       "Networks": [
           "host",
           "bridge",
           "none"
       ],
       "NumberOfHosts": 3,
       "Provider": "DOCKER",
       "Status": "Discovered"
    }
    ```
    To see a list of the mounted hosts and their resource capacity, run:
    ```
    $ optima host ls
    ```
    You should obtain the following output:
    ```
    Host Name      Status    CPU    Memory    Disk    Cloud Name
    -------------  --------  -----  --------  ------  ------------
    vagrant-host2  UP        0/2    0/1026    0/0     my-cloud
    vagrant-host1  UP        0/2    0/1026    0/0     my-cloud
    vagrant-host3  UP        0/2    0/1026    0/0     my-cloud
    ```
    Optima is now ready to be used with your Docker cloud! Follow the instructions in this [tutorial](../tutorial.md) to launch your first service, or check the commands in the 'Usage' section at [here](../README.md#usage) to launch services or inspect the hosts in your Docker cloud.
