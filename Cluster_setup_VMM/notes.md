#podman sample command to build container image
podman build -t ansible-ubuntu .


#podman sample command to run ansible container
podman run --rm -it \
  -v $PWD:/workspace:Z \
  -v $HOME/.ssh:/root/.ssh:Z \
  ansible-ubuntu ansible-playbook -i inventory playbook.yml