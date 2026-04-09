#podman sample command to build container image with name ansible-ubuntu
podman build -t ansible-ubuntu .


#podman sample command to start ansible container and run playbook
podman run --rm -it \
  -v $PWD:/workspace:Z \
  -v $HOME/.ssh:/root/.ssh:Z \
  ansible-ubuntu ansible-playbook -i inventory playbook.yml