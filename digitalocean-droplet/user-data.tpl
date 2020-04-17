#cloud-config
apt_update: true
apt_upgrade: true
apt_reboot_if_required: true

apt_sources:
  - source: "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${ubuntu_codename} stable"
    filename: docker.list
    keyid: 0EBFCD88

packages:
  # docker deps
  - apt-transport-https
  - ca-certificates
  - gnupg-agent
  - software-properties-common
  # docker
  - containerd.io
  - docker-ce
  - docker-ce-cli
  - python
  - python-pip
  # standard
  - curl
  - sudo
  - ssh-import-id
  - vim
  - wget

groups:
  - users

users:
  - name: vtse
    primary_group: users
    groups: sudo,docker
    ssh_import_id: gh:vincetse
    shell: /bin/bash

write_files:
  - path: /etc/sudoers.d/sudo
    owner: root:root
    permissions: "0600"
    content: |
      %sudo  ALL=(ALL) NOPASSWD:ALL

runcmd:
  - pip install --system docker-compose
  - apt-get -y -qq autoremove --purge

final_message: finito
