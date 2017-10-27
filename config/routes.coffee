module.exports =
  routes:
    # user routes
    'GET /api/user':
      controller: 'UserController'
      action: 'find'
      sort:
        email: 'desc'
    'GET /api/user/:id':
      controller: 'UserController'
      action: 'findOne'

    # vm routes
    'GET /api/vm/full':
      controller: 'VmController'
      action: 'listAll'
      sort:
        name: 'desc'
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
    'PUT /api/vm/:id/:cmd':
      controller: 'VmController'
      action: 'cmd'
    'DELETE /api/vm/:id':
      controller: 'VmController'
      action: 'destroy'
