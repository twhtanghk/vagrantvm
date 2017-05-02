module.exports =
  routes:
    # user routes
    'GET /api/user':
      controller: 'UserController'
      action: 'find'
      sort:
        email: 'desc'
    'GET /api/user/:email':
      controller: 'UserController'
      action: 'findOne'

    # vm routes
    'GET /api/vm':
      controller: 'VmController'
      action: 'find'
      sort:
        name: 'desc'
    'GET /api/vm/:id':
      controller: 'VmController'
      action: 'findOne'
    'POST /api/vm':
      controller: 'VmController'
      action: 'create'
    'PUT /api/vm/:id/up':
      controller: 'VmController'
      action: 'up'
    'PUT /api/vm/:id/down':
      controller: 'VmController'
      action: 'down'
    'PUT /api/vm/:id/halt':
      controller: 'VmController'
      action: 'down'
    'PUT /api/vm/:id/restart':
      controller: 'VmController'
      action: 'restart'
    'PUT /api/vm/:id/reload':
      controller: 'VmController'
      action: 'restart'
    'PUT /api/vm/:id/suspend':
      controller: 'VmController'
      action: 'suspend'
    'PUT /api/vm/:id/resume':
      controller: 'VmController'
      action: 'resume'
    'GET /api/vm/:id/backup':
      controller: 'VmController'
      action: 'backup'
    'PUT /api/vm/:id/restore':
      controller: 'VmController'
      action: 'restore'
    'DELETE /api/vm/:id':
      controller: 'VmController'
      action: 'destroy'
