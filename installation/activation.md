# Optima Activation

The following instructions walk you through the steps needed for activating Optima. The activation is needed only once after Optima is installed and allows you to mount a cloud which in turn allows you to submit and manage your container services.

1. **Set the CLI to target commands to Optima controller**:

   We will be using <optima-host-ip> to refer to the IP address of the host where Optima is installed. Replace \<optima-host-ip\> by the IP address of optima host (e.g. 192.168.1.10).
   
   Run the following command:
   ```
   $ optima target
   IP address []: <optima-host-ip>
   Port number [8090]: 8090
   Target was set successfully to <optima-host-ip>:8090
   ```
1. **Activate with Key**

   You must register via MosaixSoft.com to obtain your activation key. Go to http://www.mosaixsoft.com/optima to request your activitation key, which will be then submitted to you via the email your provided. Once you received your activation key, please complete the following instructions:
   
   Run the following command:
   ```
   $ optima activate <optima-key>
   The key has been verified successfully
   ```
   The last message confirms that optima was activated successfully!
  
