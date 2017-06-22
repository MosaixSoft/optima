# Optima Tutorial
This tutorial walks you through deploying your first service. The assumption here is that you have completed the installation steps, had the cloud deployed and mounted and have optima CLI installed.

After completing this tutorial, you will be familar with submiting, terminating and removing services from Optima.

## Step 1: List Hosts
   The first thing that we are going to do is to list the hosts in our mounted cloud. To do so run:
   ```
   $ optima host ls
   ```
   You should obtain an output that looks similar to this:
   ```
   Host Name      Status    CPU    Memory    Disk    Cloud Name
   -------------  --------  -----  --------  ------  ------------
   vagrant-host1  UP        0/2    0/1026    0/0     my-cloud
   vagrant-host2  UP        0/2    0/1026    0/0     my-cloud
   vagrant-host3  UP        0/2    0/1026    0/0     my-cloud
   ```
   The output informs you that your mounted cloud "my-cloud" has three docker hosts. The output also shows you the amount of resrouces (e.g. CPU, memory, disk) that are used in addtion to the resource capacity on each host. Note that you may see a different number of hosts or different resource slack / resoure capacity depending on the mounted cloud.

## Step 2: Create Service YAML file
   Create a new file:
   ```
   $ touch ~/my-service.yaml
   ```
   Edit the created file using your favorite editor (e.g. Vim) and paste the following content with the created file:
   
   ```yaml
   workloads:
     - name: my-container # Container's name
       type: "CONTAINER" 
       cpu: 1 # Requested CPU resources
       memory: 512 # Requested Memory resources
       image: ubuntu # container's image
       command: sleep inf # container's entrypoint (i.e., the command to be executed when the container starts)
   ```
   This basically is the simplest service as it requests a single container.

## Step 3: Submit the Service
   ```
   $ optima service submit ~/my-service.yaml
   ```
   You should obtain an output similar to this:
   ```
   $ {"status":"Success","message":"Service request received.","service ID":"1"}
   ```
   This informs you that your service request was received and that your service has the ID 1. The ID that you receive might be different depending on how many requests you have submitted before. For the rest of the tutorial \<serivce-id\> will be used to refer to the ID that was obtained from this step.
## Step 4: Inspect The Service
   To watch how a service gets created and then switches from the PENDING state to the RUNNING state, execute the following command:
   ```
   $ watch optima service ls
   Service ID    Status    Policy Name     Submission Time
   ------------  --------  --------------  ----------------------------
              1  RUNNING   minimize-hosts  Wed May 24 19:38:48 UTC 2017
   ```
   This would show you that a service has been created and it will be in state RUNNING after some time (after the container's image is pulled and the container is started). To exit watching this command, press "ctrl + c".
   Now let's check the hosts after the container is running:
   ```
   $ optima host ls

   Host Name      Status    CPU    Memory    Disk    Cloud Name
   -------------  --------  -----  --------  ------  ------------
   vagrant-host1  UP        1/2    512/1026  0/0     my-cloud
   vagrant-host2  UP        0/2    0/1026    0/0     my-cloud
   vagrant-host3  UP        0/2    0/1026    0/0     my-cloud
   ```
   Observe that the host "vagrant-host1" has now a container deployed there as there is one reserved CPU and 512 MB of memory. 
   Depending on how many hosts you have, and on the capacities of those hosts, your container might be deployed on a different host than the one shown in this tutorial.
   
   You can further inspect the service by running:
   ```
   $ optima service inspect <service-id>
   {
    "HostAffinityConstraints": [],
    "HostAntiAffinityConstraints": [],
    "Policy": {
        "Mode": "optima",
        "Name": "minimize-hosts",
        "Timeout": 60
    },
    "Status": "RUNNING",
    "SubmissionTime": "Wed May 24 19:38:48 UTC 2017",
    "WorkloadAffinityConstraints": [],
    "WorkloadAntiAffinityConstraints": [],
    "Workloads": [
        {
            "CPU": 1,
            "Command": "sleep inf",
            "Count": 1,
            "Disk": 0,
            "Environment": [],
            "Image": "ubuntu",
            "Memory": 512,
            "Name": "my-container",
            "Ports": [],
            "Subnet": "bridge",
            "Type": "CONTAINER",
            "WorkloadsStatus": [
                {
                    "HostName": "vagrant-host1",
                    "State": "RUNNING"
                }
            ]
        }
    ]
   }
   ```
   This basically shows you all the details about the service you requested including where your service is hosted. In case that your service failed to be deployed, there would be an "ErrorMessage" field that explains why the service failed.

## Step 5: Terminate the Service
   We now are done with using that container and we would like to terminate it and release the resources reserved for it.
   To do so, run the following command:
   ```
   $ optima service terminate <service-id>
   Service marked for termination successfully.
   ```
   This informs you that the service is marekd for termination and will be terminated shortly.
   To watch how the service gets terminated, run:
   ```
   $ watch optima service ls
      Service ID   Status    Policy Name    Submission Time
    ------------  --------  -------------  -----------------

   ```
   Observe how the service is now shortly in the state "REQUESTED_TO_TERMINATE" before it disappears from the list. To exit watching the command, press "ctrl + c".
   
   You could also issue the following command to see how the service is no longer occupying resources:
   ```
   $ optima host ls
   Host Name      Status    CPU    Memory    Disk    Cloud Name
   -------------  --------  -----  --------  ------  ------------
   vagrant-host1  UP        0/2    0/1026    0/0     my-cloud
   vagrant-host2  UP        0/2    0/1026    0/0     my-cloud
   vagrant-host3  UP        0/2    0/1026    0/0     my-cloud
   ```
   
## Step 6: Remove the Service
   Although our service got terminated and is not occupying any resources, we can still see it in the list of services if we issue the following command:
   ```
   $ optima service ls -a
      Service ID    Status      Policy Name     Submission Time
    ------------  ----------  --------------  ----------------------------
               1  TERMINATED  minimize-hosts  Wed May 24 19:38:48 UTC 2017
   ```
   the '-a' argument lists all services including those that were terminated.
   
   To remove the service completely from that list, run the following command:  
   ```
   $ optima service remove <service-id>
   ```
   Observe how the service gets removed from that list: 
   ```
   $ optima service ls -a
      Service ID    Status      Policy Name     Submission Time
    ------------  ----------  --------------  ----------------------------
 
   ```



