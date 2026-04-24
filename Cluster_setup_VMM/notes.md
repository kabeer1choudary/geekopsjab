Step1:
- Use the shell script vm_provision/vm_provisioning.sh to create 3 VMs with below configs with sudo
  i) 2 vCPU, 2048MB RAM, 15GB Disk, virbr0 Network ()
  ii) 1 vCPU, 1024MB RAM, 12GB Disk 
  iii) 1 vCPU, 1024MB RAM, 12GB Disk 

- Post running the script, open up the Virtual Machine Manager to configure and apply VM level changes (setting up user creds, selecting network & )

Step2:



#podman sample command to build container image with name ansible-ubuntu
podman build -t ansible-ubuntu .


#podman sample command to start ansible container and run playbook
podman run --rm -it \
  -v $PWD:/workspace:Z \
  -v $HOME/.ssh:/root/.ssh:Z \
  ansible-ubuntu ansible-playbook -i inventory playbook.yml