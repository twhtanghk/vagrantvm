# vagrantvm
Web App to create/up/down/restart/suspend/resume/delete vagrant vm on top of libvirtd and kvm

Web Service API
---------------
## vm

* attributes
  see [api/models/Vm.coffee]

* api
```
get /api/vm - list vm created by current login user
get /api/vm/:id - get vm details and status
post /api/vm - create vm with specified attribute values
put /api/vm/:id/up - vagrant up vm with specified id
put /api/vm/:id/[down|halt] - vagrant halt vm with specified id
put /api/vm/:id/[restart|reload] - vagrant reload vm with specified id
put /api/vm/:id/suspend - vagrant suspend vm with specified id
put /api/vm/:id/resume - vagrant resume vm with specified id
delete /api/vm/:id - vagrant destroy vm with specified id
```

Configuration
-------------
* update /etc/modules to auto load kvm and kvm_intel modules on host server
* add /etc/modprobe.d/kvm-nested.conf with nested vm enabled on host server
```
options kvm_intel nested=1
```
* Download docker-compose.yml and .env
* Customize env variables defined in .env [.env]
* Customize port mapping for container and host port (e.g. 80:1337) in docker-compose.yml
* docker-compose -f docker-compose.yml up -d
* open browser to visit http://serverUrl:80
