#cloud-config
apt_update: true
apt_upgrade: true
apt_reboot_if_required: true

packages:
- sudo
- ssh-import-id

groups:
- users

users:
- name: vtse
  primary_group: users
  groups: sudo
  ssh_import_id: gh:vincetse
  shell: /bin/bash

write_files:
- path: /etc/sudoers.d/sudo
  owner: root:root
  permissions: "0600"
  content: |
    %sudo  ALL=(ALL) NOPASSWD:ALL

runcmd:
- apt-get -y -qq autoremove --purge

final_message: finito
