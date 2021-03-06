# Deploying Optima on dedicated Virtual Machines
The following instructions walks you through the deployment of an Optima server and a Docker cloud. This installation option assumes you own and are familiar with a virtualization environment (private or public) of your choice.

## Deploying the Optima Server
**Prerequisites**:
* Dedicated virtual machine
* Ubuntu 14.04 LTS
* CPU: 4 or more
* Memory: 8 GB or more
* Storage: 50 GB or more

If you are deploying your own and dedicated Ubuntu 14.04 based EC2 instance in AWS, the recommended AWS instance type is _c4.xlarge_.

**Follow these steps**:

The Ubuntu server where Optima is to be deployed must have access to the Internet to download the Optima installation software package.

1. Download the software installation package to an Ubuntu server:

   ```
   $ wget https://s3-us-west-1.amazonaws.com/optima-distribution/Optima+1.0.8/optima_install.tgz
   $ tar -xzvf optima_install.tgz
   ```

1. Start the installation script:

   ```
   $ cd mosaix_install
   $ ./optima_install.sh
   ```
   Port 8090 must be open on the Optima server for the Optima CLI to be able to reach the Optima server remotely.

The installation script downloads and installs the necessary third party components and starts the Optima server. Depending on your Internet network bandwidth, this installation may take up to 10 minutes. If the installation script did not complete, run it one more time (likely due to a timeout in the downloads).

## Deploying a Docker cloud
Optima's free edition allows you to control a Docker cloud with up to 5 Docker hosts. The following instructions explain how to deploy a single Docker host. You can repeat the same steps on multiple VMs to deploy more than one Docker host.

### Prerequisites:
 * Networking:
   * The Optima server must be able to reach the Docker hosts over IP.
 * Firewall (a.k.a. security groups):
   * Optima communicates to each Docker host via the Docker Remote API, which port (4342 or 2575 or custom) must be open on each Docker host.

### Creating and configuring a Docker host:
  1. Create a virtual machine based on a standard Ubuntu 14.04 LTS.
  1. Allow TCP connections to port 4243 from the Optima server's IP address
  1. From your favorite terminal, login via SSH to this VM:
  1. Download the provided [docker-host-install.sh](../scripts/docker-host-install.sh) bash script to this VM:

     ```
     $ wget https://github.com/MosaixSoft/optima-staging/blob/master/scripts/docker-host-install.sh
     ```

  1. Run the docker-host-install script:

     ```
     $ ./docker-host-install.sh
     ```

     This bash script basically does the following:
        * Installs docker (version 17.03.1-ce)
        * Activates Docker Remote API
        * Generates a unique ID for the Docker engine

  Repeat from step 1 for each docker host you want to deploy.

Take note of the IP address for each Docker host deployed, as it will be used later to connect the Optima server to these docker hosts. Use an IP address which can be reached over IP by the Optima server.

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
The IP address of the Optima server (*<optima_host_ip>*) must be accessible from the system where the Optima CLI is installed. Port 8090 must be open on the Optima server.

   In addition, the Optima server must be able to reach the Docker hosts over IP. Optima communicates to each Docker host via the Docker Remote API which port (4342 or 2575 or custom) must be open on each Docker host that will be connected to Optima.

### Connect Optima to your Docker cloud:

1. **Identify the IP address of each host member of your Docker cloud**

   You want to make sure those IP addresses are reachable from the Optima server. If Optima is not deployed in the same subnet/network as your Docker hosts, you want to use the public IP address of each Docker host as the endpoints.

1. **Create the following _cloud.yaml_ file:**

   ```yaml
   cloud:
      # name of the mounted cloud
      name: cloud1
      provider: docker
      # username and password of the machine where optima is running
      # The username must have the sudo privileges
      username: mosaix
      password: mosaix
      # docker hosts (up to 5)
      endpoints: http://<docker-host-ip1>:4243/, http://<docker-host-ip2>:4243/, http://<docker-host-ip3>:4243/, http://<docker-host-ip4>:4243/, http://<docker-host-ip5>:4243/
      # CPU and memory overcommit ratios
      cpuovercommit: 2    # (Default 1)
      memoryovercommit: 2 # (Default 1)
   ```

   You can add up to 5 endpoints in this trial version, which correspond to the IP address of each Docker host.
   The *cpuovercommit* and *memoryovercommit* are ratios set to define the maximum number of resources (CPU, memory) Optima is allowed to allocate per host, relative to actual amount of resources available on each host (quota = overcommit x actual).

1. **Connect Optima to your Docker cloud**:

   Using Optima CLI:

   ```
   $ optima target
   IP address []: <optima-host-ip>
   Port number [8090]:
   Target was set successfully to <optima-host-ip>:8090
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
    You should obtain the an output that is similar to the following:
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
       "NumberOfHosts": 5,
       "Provider": "DOCKER",
       "Status": "Discovered"
    }
    ```
    Note that the output shown previously is for a cloud that has 5 docker hosts. If few hosts were mounted, then the "NumberOfHosts" would have a value that is equal to the number of mounted docker hosts.

    To see a list of the mounted hosts and their resource capacity, run:
    ```
    $ optima host ls
    ```
    You should obtain the an output that is looks like:
    ```
    Host Name      Status    CPU    Memory    Disk    Cloud Name
    -------------  --------  -----  --------  ------  ------------
    host1  UP        0/2    0/1026    0/0     my-cloud
    host2  UP        0/2    0/1026    0/0     my-cloud
    host3  UP        0/2    0/1026    0/0     my-cloud
    host4  UP        0/2    0/1026    0/0     my-cloud
    host5  UP        0/2    0/1026    0/0     my-cloud
    ```
    Note that the output shown previously is for a cloud that has 5 docker hosts. If few hosts were mounted, then output would be slightly different depending on the number of docker hosts and the resource capacity of the VMs where docker was installed.

    Optima is now ready to be used with your Docker cloud! Follow the instructions in this [tutorial](../tutorial.md) to launch your first service, or check the commands in the 'Usage' section at [here](../README.md#usage) to launch services or inspect the hosts in your Docker cloud.
