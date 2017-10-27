module.exports = 
  policies:
    VmController:
      '*': false
      findOne: ['isAuth', 'isOwner']
      find: ['isAuth', 'filterByOwner']
      listAll: ['isAuth', 'isAdmin']
      create: ['isAuth', 'setCreatedBy']
      destroy: ['isAuth', 'isOwner']
      cmd: ['isAuth', 'isOwner']
    UserController:
      '*': false
      find: true
      findOne: ['isAuth', 'user/me']
