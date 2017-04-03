<img src="../master/optima-logo.png" alt="Optima logo" width="90">

# Optima

## Introduction
Optima is a polydimensional container scheduler for Docker. Polydimensional scheduling generates superior results compared to previous schedulers by considering a rich set of system and policy dimensions, and by using linear algebra to properly value the impact of each. Optima is also uniquely adaptable to dynamic and hybrid environments. Plus, its scheduling syntax is simpler than with previous schedulers. All of this makes it uniquely powerful for today's complex world of diverse apps running in heterogenous environments.

For more information about Optima: http://www.mosaixsoft.com/optima.

#### Free trial
Optima is currently offered as a free 30-day trial, limited to deploying up to 20 containers on up to 5 Docker hosts. If you wish to evaluate Optima deploying more than 20 containers or to more than 5 hosts, please contact MosaixSoft at [optima@mosaixsoft.com](mailto:optima@mosaixsoft.com).

## Installation

Optima is installed on a dedicated server (virtual or physical) using a software installation package which can be downloaded only after registering at [http://www.mosaixsoft.com/optima](http://www.mosaixsoft.com/optima).
After installing Optima, the Optima CLI can be installed separately to run Optima commands remotely against the Optima server.

### Installing Optima

**Prerequisites**:
* Dedicated server (virtual or physical)
* Ubuntu 14.04 LTS
* CPU: 8 or more
* Memory: 16 GB or more
* Storage: 50 GB or more

The recommended instance type in AWS is "m4.2xlarge".

**Follow these steps**:

The Ubuntu server where Optima is to be deployed must have access to the Internet to download the Optima installation software package.

1. Download the software installation package to an Ubuntu server:

   ```
   $ wget <URL-to-optima-server-software-installation-package>
   $ tar -xzvf optima_install.tgz
   ```
   To obtain this URL, register at [http://www.mosaixsoft.com/optima](http://www.mosaixsoft.com/optima).

1. Start the installation script:

   ```
   $ cd mosaix_install
   $ ./optima_install.sh
   ```
   Port 8090 must be open on the Optima server for the Optima CLI to be able to reach the Optima server remotely.

The installation script downloads and installs the necessary third party components and starts the Optima server. Depending on your Internet network bandwidth, this installation may take up to 10 minutes. If the installation script did not complete, run it one more time (likely due to a timeout in the downloads).

### Optima CLI installation:

Install the Optima CLI to a system from where you want to launch Optima commands from.

**Prerequisites**:
* Ubuntu 14.04 (recommended) or any Linux OS
* Python 3

**Follow these steps**:

  From an Ubuntu 14.04 LTS server supporting Python version 3, download and install the Optima CLI:

  ```
  $ wget <URL-to-optima-CLI-installation-package>
  $ tar -xzvf cli-4.0.3.tar.gz
  $ cd optima-cli
  $ ./install.sh
  ```
  To obtain this URL, register at [http://www.mosaixsoft.com/optima](http://www.mosaixsoft.com/optima).

## Getting started

Optima must be connected to a Docker cluster with Docker hosts running Docker version 1.10 or higher. Docker Swarm is not required.

#### User interfaces
   Optima scheduling services are accessible via:
   * [Optima CLI](#optima-cli)
   * [Optima RESTful APIs](#optima-restful-apis)

#### Networking
   The IP address of the Optima server (*<optima_host_ip>*) must be accessible from the system where the Optima CLI is installed. Port 8090 must be open on the Optima server.

   In addition, the Optima server must be able to reach the Docker hosts over IP. Optima communicates to each Docker host via the Docker Remote API which port (4342 or 2575 or custom) must be open on each Docker host that will be connected to Optima.

### Connect Optima to your Docker cluster:

1. **Identify the IP address of each host member of your Docker cluster**

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

1. **Connect Optima to your Docker cluster**:

   Using Optima CLI:

   ```yaml
   $ optima target
   IP address []: <optima-host-ip>
   Port number [8090]:
   Target was set successfully to <optima-host-ip>:8090
   $ optima cloud mount cloud.yaml
   ```

   Using Optima Restful API:

   ```
   $ curl -X POST --data-binary @cloud.yaml -H "Content-type: text/plain" http://<optima-host-ip>:8090/optima/cloud

   {message : "Discovery for the cloud started."}
   ```

## Placement strategies

Your multi-container application can be comprised of one or more containers. Optima allows you to pick the optimal placement strategy, combined with workload and host constraints, that works best for your application workload.

All strategies take into account CPU and memory as default constraints. Optima automatically looks for a Docker host with available room for each container to be deployed based on its CPU and memory requirements at the time of the service request.

1. Container placement strategies (*policy* tag): pick one!

   * minimize-hosts: maximizes efficiency by packing the workload on a few servers starting from the fullest.
   * balance-hosts: maximizes performance by spreading the workload evenly, factoring in existing workloads.
   * optimize-network: _future Optima release_.

   By default, these placement strategies operate in **'*optima*'** *mode*, which provides the optimal placement solution (*mode* tag), including delivering the most efficient resource utilization. The alternative *mode* is **'*cluster*'**, which yields results comparable to traditional cluster-based container schedulers such as Docker Swarm, Kubernetes or Mesosphere.

   To force the above placement strategies to operating in the "cluster" mode, you must set the *mode* tag to "cluster". See [examples](#examples) below.

Optionally, you can combine your placement strategy with the following supported constraints:

2. Workload constraints:

   * workload-affinity: specify containers to start on the same host
   * workload-anti-affinity: specify containers that should not start on the same host

3. Host constraints:

   * host-affinity: explicitly specify the host where you want your containers to be placed
   * host-anti-affinity: explicitly specify the host(s) where you don't want your container to be placed

### CPU and Memory quotas on Optima
When connecting Optima to your Docker cluster the first time, the *cpuovercommit* and *memorycommit* ratios define the maximum number of virtual CPU count and virtual memory each Docker host can be allocated by Optima:
   * The total number of CPU per host reported by Optima is therefore the actual CPU count of each host multiplied by the *cpuovercommit* ratio.
   * The total amount of memory per host reported by Optima is the actual memory of each host multiplied by the *memorycommit* ratio.


## Usage

### Optima CLI

See instructions on how to download Optima CLI [here]#installation.

* Point your Optima CLI to your Optima server:
```yaml
$ optima target
IP address []: <xxx.xxx.xxx.xxx>
Port number [8090]: 8090
```


* Mount a cloud:
```
$ optima cloud mount <yaml_file>
```
* Unmount the cloud, if any exists:
```
$ optima cloud unmount
```
* Check status of the cloud:
```
$ optima cloud status
```
* Submit a service to your Docker cluster via Optima:
```
$ optima service submit <yaml_file>
```
* List services submitted via Optima (excluding terminated ones):
```
$ optima service ls
```
* List services submitted via Optima (including terminated ones):
```
$ optima service ls -a
```
* Inspect a service:
```
$ optima service inspect <service-id>
```
* Terminate a service:
```
$ optima service terminate <service-id>
```
* Terminate all services:
```
$ optima service terminate -a
```
* Show Docker cluster resources:
```
$ optima host ls
```
* Inspect a host:
```
$ optima host inspect <hostname>
```
* Show list of containers created in your Docker cluster (excluding terminated ones):
```
$ optima container ls
```
* Show list of containers created in your Docker cluster (including terminated ones):
```
$ optima container ls -a
```

### Optima RESTful APIs

By default, Optima listens to port 8090 for the RESTful APIs:
   * Port 8090 must be open on your server running Optima (firewall settings).
   * Replace the *<host-ip>* with the IP address of the Optima server.

**Complete list of supported APIs**:

* Mount a cloud to Optima:
```
$ curl -X POST --data-binary @cloud.yaml -H "Content-type: text/plain" http://<optima-ip>:8090/optima/cloud
```
* Unmount the cloud:
```
$ curl -X DELETE -d "password=<admin_password>" http://<optima-ip>:8090/optima/cloud
```
* Get the status of the cloud:
```
$ curl http://<optima-ip>:8090/optima/cloud
```
* Submit a service to your Docker cluster via Optima:
```
$ curl -X POST --data-binary @service.yaml -H "Content-type: text/plain" http://<optima-ip>:8090/optima/services
```
* List services submitted via Optima:
```
$ curl http://<optima-ip>:8090/optima/services
```
* Inspect a service:
```
$ curl http://<optima-ip>:8090/optima/services/<service-id>
```
* Terminate a service:
```
$ curl -X DELETE http://<optima-ip>:8090/optima/services/<service-id>
```
* Terminate all services:
```
$ curl -X DELETE http://<optima-ip>:8090/optima/services
```
* List all hosts:
```
$ curl http://<optima-ip>:8090/optima/hosts
```
* List all containers:
```
$ curl http://<optima-ip>:8090/optima/containers
```

## Examples

### Example 1: [tc-service-1.yml](../master/tc-service-1.yml) file
This example deploys multiple containers for maximum performance. It does this by distributing the containers across all Docker servers while maintaining the workload affinity between the load-balancer and the database. The containers in this example are:
  * load-balancer (nginx)
  * database (mysql)
  * webserver (tomcat)

You can download this example [here](../master/tc-service-1.yml).

```yaml

workloads:

  - name: loadbalancer
    type: CONTAINER
    image: "nginx"
    cpu: 1
    memory: 256
    ports:
      - "80:80"

  - name: database
    type: CONTAINER
    image: "mysql"
    cpu: 1
    memory: 256
    disk: 0
    environment:
      - "MYSQL_ROOT_PASSWORD=my-secret-pw"

  - name: webserver
    type: CONTAINER
    image: "tomcat"
    cpu: 1
    memory: 512
    count: 4

policy:
  name: "balance-hosts"

workload_affinity_constraint:
  - workloads:
    - loadbalancer
    - database
```

### Example 2: [tc-service-2.yml](../master/tc-service-2.yml) file
This example maximizes resource efficiency. It does this by deploying containers to a minimal number of Docker servers while maintaining the workload affinity between the load-balancer and the database. The containers in this example are:
  * load-balancer (nginx)
  * database (mysql)
  * webserver (tomcat)

You can download this example [here](../master/tc-service-2.yml).

```yaml
workloads:

  - name: loadbalancer
    type: CONTAINER
    image: "nginx"
    cpu: 1
    memory: 256
    ports:
      - "80:80"

  - name: database
    type: CONTAINER
    image: "mysql"
    cpu: 1
    memory: 256
    disk: 0
    environment:
      - "MYSQL_ROOT_PASSWORD=my-secret-pw"

  - name: webserver
    type: CONTAINER
    image: "tomcat"
    cpu: 1
    memory: 512
    count: 4

policy:
  name: "minimize-hosts"

workload_affinity_constraint:
  - workloads:
    - loadbalancer
    - database
```

## Optima Service Compose Reference

```yaml
# Define a set of workloads to be scheduled
# At least one workload MUST be requested
# Each workload MUST have a unique name within the yaml file
# The name is used to identify affinity/anti-affinity constraints
# The name is also used as a prefix name for the created container
workloads:
  - name: container1
    type: CONTAINER
    # Docker image name (MUST be specified)
    image: "hello-world"
    # Resource Demands
    # CPU and Memory resources MUST be specified
    cpu: 1
    memory: 512
    disk: 0
    # Number of instances (Default 1)
    count: 1
    # Entrypoint command and environment variables (Optional)
    command: "sleep 1000"
    environment:
      - "variable1=value1"
      - "variable2=value2"
    # Subnet and Ports (Optional)
    subnet: host
    ports:
      - "80:8080"
      - "60:6060"

  - name: container2
    type: CONTAINER
    image: "hello-world"
    cpu: 1
    memory: 256

  - name: container3
    type: CONTAINER
    image: "hello-world"
    cpu: 1
    memory: 256

  - name: container4
    type: CONTAINER
    image: "hello-world"
    cpu: 1
    memory: 1024

# Scheduling policy
policy:
  # Two policies are available:
  #  - "minimize-hosts" for using as few hosts as possible (Default)
  #  - "balance-hosts" for spreading the workload across the hosts
  name: "minimize-hosts"
  # The mode is one of two:
  #   - "optima" for finding optimal placements (Default)
  #   - "cluster" for heuristic placements found in existing cluster managers
  mode: "optima"
  # Timeout for finding placements in seconds (Default 60 seconds)
  # If timeout is exceeded, sub-optimal placements will be returned.
  timeout: 60

# Host affinity constraints (Optional)
# Forces one or more workload to be placed on a certain host or on one of a set of hosts
host_affinity_constraint:
  # This constraint informs the scheduler to place container1
  # and container2 on either host-name1 or host-name2
  - workloads:
    - container1
    - container2
    hosts:
    - host-name1
    - host-name2
  # This constraint informs the scheduler to place container3 on host-name3 or host-name2
  - workloads:
    - container3
    hosts:
    - host-name3
    - host-name2

# Host anti-affinity constraints (Optional)
# Forces one or more workload not be placed on a certain host or on a set of hosts
host_anti_affinity_constraint:
  # This constraint informs the scheduler not to place container4 on host-name3
  - workloads:
    - container4
    hosts:
    - host-name3

# Workload anti-affinity constraints (Optional)
# Prevents a workload from being placed with other workloads
workload_anti_affinity_constraint:
  # Informs the scheduler not to place container1
  # and container2 on the same host
  - workloads:
    - container1
    - container2

# Workload affinity constraints (Optional)
# Informs the scheduler to place a certain set of workloads on the same host
workload_affinity_constraint:
  # Informs the scheduler to place conainer2 and container3 on the same host
  - workloads:
    - container2
    - container3
```

## Service and Container states

### Service States

| Status | Description | Notes |
| ------ | ----------- | ----- |
| PENDING | At least one container is pending. No failed containers. | Run ‘optima service inspect <pending-service-id>’ to check the state of the PENDING service.|
| RUNNING | All service’s containers are running. |  |
| STOPPED | All services's containers are stopped. | <ul><li>No resources (e.g. CPU, memory, etc.) are used by stopped containers but the containers can still be seen on the hosts when executing “docker ps -a”.</li> <li>A stopped service can be terminated to remove the containers from the hosts where they were running (so that they don’t appear when executing docker ps -a on the hosts). </li></ul>|
| FAILED | At least one of the service’s containers failed. | <ul><li>Run ‘optima service inspect <failed-service-id>’, then check the ErrorMessage.</li><li>A FAILED service can be terminated (to release resources used by non-failed workloads).</li></ul> |
| PARTIALLY_RUNNING | No failed containers. Some containers in the service are running, while others are stopped (due to the completion of their tasks) | No resources are used by stopped containers but the containers can still be seen on the hosts when executing “docker ps -a”. |
| REQUESTED_TO_TERMINATE | All service’s containers were requested to be terminated and will be terminated soon. Any reserved resources will be released and any running/stopped containers will be removed. |  |
| TERMINATED | All service’s containers were terminated. This means that all the running container were stopped and all containers (running/stopped) were removed from the hosts. |  |

### Container states

| Status | Description |
| ------ | ----------- |
| PENDING | Container is about to be provisioned. |
| RUNNING | Container is running. |
| STOPPED | Container stopped due to the completion of its task (basically exit(0)). Stopped container don’t use any resources. |
| FAILED | Container failed to be provisioned. To see what the error is, run ‘optima service inspect <service that has the failed container>’ then check ‘State’ field under ‘WorkloadStatus’ |
| REQUESTED_TO_TERMINATE | Container was marked for termination but was not yet removed from host. |
| TERMINATED | Container was completely removed from host. |

## Troubleshooting

  Please refer to the [Troubleshooting guide for Optima](../master/TROUBLESHOOTING.md).

## Support

Contact MosaixSoft at [optima@mosaixsoft.com](mailto:optima@mosaixsoft.com)

## Provide feedback

You can submit your questions and suggestions [here](http://www.mosaixsoft.com/optima).

## For more information

Contact MosaixSoft at [optima@mosaixsoft.com](mailto:optima@mosaixsoft.com)

## FAQs

* Can I deploy Optima with more than 5 hosts?

  Optima is currently available as a free trial. If you would like to evaluate Optima with more than 5 Docker hosts (dozens to hundreds), please contact MosaixSoft directly at [optima@mosaixsoft.com](mailto:optima@mosaixsoft.com).

* Which network/subnet should I use for my containers?

  By default, Optima picks the Docker's default "bridge" network. However, Optima supports any network types you created in your Docker cluster. Please refer to Docker's [online reference manual](https://docs.docker.com/engine/userguide/networking/) for more information about how to create networks. If you want to deploy your containers in a specific network, you must use the "subnet" YAML tag in your Optima service compose file.

* What happens when I exceed the maximum limit of containers supported with the free trial?

  The free trial for Optima is limited to 5 Docker hosts and 20 containers maximum. If you submit a service which will exceed the limit of 20 containers, the service will be submitted (a.k.a. allocation requested) successfully, however its status will be "FAILED". If you inspect the service ($ optima service inspect <service_id>), the "ErrorMessage" field will indicate that you can't exceed the number of 20 containers".
  If you would like to evaluate Optima with more than 5 Docker hosts (dozens to hundreds), please contact MosaixSoft directly at [optima@mosaixsoft.com](mailto:optima@mosaixsoft.com).

* Are there open source plans for Optima?  

  Open source is important to us, so we are being prudent about which parts of our system to release that way. Let us know at [optima@mosaixsoft.com](mailto:optima@mosaixsoft.com) if you'd like to collaborate.
