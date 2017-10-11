#!/bin/sh

libvirtd -d
virsh pool-define-as default dir --target /var/lib/libvirt/images/
virsh pool-autostart default
virsh pool-start default
npm start
