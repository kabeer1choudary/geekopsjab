# Step1:
- Use the shell script **vm_provision/vm_provisioning.sh** to create 3 VMs with below configs with sudo
  - 2 vCPU, 2048MB RAM, 15GB Disk, virbr0 Network (Bridge network), virbr1 Network (Isolated network)
  - 1 vCPU, 1024MB RAM, 12GB Disk, virbr1 Network (Isolated network)
  - 1 vCPU, 1024MB RAM, 12GB Disk virbr1 Network (Isolated network)

- Post running the script, open up the Virtual Machine Manager to configure and apply VM level changes (setting up user creds, selecting network configs, packages, etc.)

# Step2:
- Use podman, spin up a container to run the ansible playbook

    _podman command to build container image with name ansible-ubuntu_
    
    $ podman build -t ansible-ubuntu .

    _podman command to start ansible container and run playbook_
    
    $ podman run --rm -it \
      -v $PWD:/workspace:Z \
      -v $HOME/.ssh:/root/.ssh:Z \
      ansible-ubuntu ansible-playbook -i inventory playbook.yml