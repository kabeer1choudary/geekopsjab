# Step 1:
- Run the shell script **vm_provision/vm_provisioning.sh** to create 3 VMs with below configs with sudo
  - 2 vCPU, 2048MB RAM, 12GB Disk, virbr0 Network (Bridge network), virbr1 Network (Isolated network)
  - 1 vCPU, 1024MB RAM, 10GB Disk, virbr1 Network (Isolated network)
  - 1 vCPU, 1024MB RAM, 10GB Disk virbr1 Network (Isolated network)

# Step 2:
- Post running the script, open up the Virtual Machine Manager to configure and apply VM level changes (setting up user creds, selecting network configs, packages, etc.)

- Change the Virtual Network Interface (NIC) of Bastion node from **bridge device** to **default:NAT** and **isolated network**, in case if the network did not update by default

- Change the Virtual Network Interface (NIC) of Worker nodes from **bridge device** to **isolated network**, in case if the network did not update by default

# Step 3:
- Run the shell script **vm_config/run_tasks.sh** to build container image with name ansible-ubuntu2204 and imventroy file for Ansible Playbook

- Compare and convert the inventory.ini file, based on the inventory_sample file. Where [virbr0] group would be changed to [bastion] and [virbr1] would be changes to [worker]. Verify the ip addresses of bastion and worker nodes from VMM.

- Post running the script, use podman to spin up a container to run the ansible playbook

    _podman command to start ansible container and run playbook_
    ```
    $ podman run --rm -it -v $PWD:/workspace:Z ansible-ubuntu2204 ansible-playbook -i inventory.ini ansible-playbook.yml -k -K -vv
    ```