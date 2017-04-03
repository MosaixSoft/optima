# Troubleshooting Guide for Optima

## Service Error Messages

| Service Error Message  | Description | Solution |
| ------------- | ------------- | ------------- |
| No fitting allocation was found.  | The scheduler could not find hosts that satisfy the service requirements (resource demands + affinity/anti-affinity constraints)  | <lu><li>Run ‘optima host ls’ to see the amount of available resources (CPU + memory + disk). Resubmit a new service with resource demands that can be met by the available resources on the hosts. Or terminate some of the existing services to make room for the new service.</li><li>In case your service has affinity constraints, it is possible that no host in your mounted cloud can meet the specified constraints. You can remove some of those constraints if they are not needed or you could terminate some of the running services.</li>  |
| The total number of containers can't exceed 20 ( Current: 20, Requested: 5).  | Optima’s free version limits the number of running containers to 20  | -  |
| The number of hosts can’t exceed 5 (Current: 6).  | Optima’s free version limits the number of hosts to 5  | Mount a cloud with fewer hosts or contact us for non-free version  |
| Software license is expired  | Optima’s free version is limited for 30 days  | -  |
| -  | -  | -  |

## Workload Error Messages

<table style="width:300">
<tr><td>
Error Message:</td><td>
Failed to create container webserver51c93db6-0899-4bfc-9cb0-de5d107ccae8 (xxx/yyy)\ncom.mosaix.underlay.docker.client.exceptions.ImageNotFoundException: No such image: xxx/yyy:latest
</td></tr><tr><td>
Explanation:</td><td>
Workload’s image does not exist in Docker Hub.
</td></tr><tr><td>
Error Message:</td><td>
Failed to create container databaseb16ddda7-4f20-44b9-b3f1-92e9f524acc6 (xxxxx)\ncom.mosaix.underlay.docker.client.exceptions.ImageNotFoundException: repository xxxxx not found: does not exist or no pull access
</td></tr><tr><td>
Explanation:</td><td>
Workload’s image repository {xxxxx} does not exist or no pullaccess
</td></tr><tr><td>
Error Message:</td><td>
Failed to start container databasefad7d6d4-4b8a-4e84-96f8-9c4f16aa94ee (ubuntu:latest, ID: 38820ddbb9629966938712cb6f7b49416c0700c19f34df5bbae1388b0c3a1919)\ncom.mosaix.underlay.docker.client.exceptions.DockerClientException: driver failed programming external connectivity on endpoint databasefad7d6d4-4b8a-4e84-96f8-9c4f16aa94ee (35349c6b45805a0d2fe32a139bce7c11547c047899ef5da11eecc63ebbe0cb49): Bind for 0.0.0.0:80 failed: port is already allocated
</td></tr><tr><td>
Explanation:</td><td>
Port is already in use. Port binding failed.
</td></tr><tr><td>
Error Message:</td><td>
Failed to start container webserver0fab6da0-c880-4344-9843-35405e1b55cd (mjnoliaee/java8-helloworld:latest, ID: 7195e94b5e05d25394e0c9d78da633523e007451b38f045046873517471afa7f)\ncom.mosaix.underlay.docker.client.exceptions.DockerClientException: invalid header field value \"oci runtime error: container_linux.go:247: starting container process caused \\\"exec: \\\\\\\"bs\\\\\\\": executable file not found in $PATH\\\"\\n
</td></tr><tr><td>
Explanation:</td><td>
Submitted workload with an invalid command
</td></tr><tr><td>
Error Message:</td><td>
Provisioning error. Exited (1)
</td></tr><tr><td>
Explanation:</td><td>
Container exited with non-zero exit code
</td></tr>
</table>
