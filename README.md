# vagrantvm
Web App to maintain vagrant vm

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
* Install required packages on host machine [https://github.com/vagrant-libvirt/vagrant-libvirt#installation]
* Download docker-compose.yml and .env
* Customize env variables defined in .env [.env]
* docker-compose -f docker-compose.yml up -d
