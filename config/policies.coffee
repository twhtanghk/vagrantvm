module.exports = 
  policies:
    VmController:
      '*': false
      findOne: ['isAuth', 'isOwner']
      find: ['isAuth', 'filterByOwner']
      listAll: ['isAuth', 'isAdmin']
      create: ['isAuth', 'setCreatedBy']
      passwd: ['isAuth', 'isOwner']
      up: ['isAuth', 'isOwner']
      down: ['isAuth', 'isOwner']
      restart: ['isAuth', 'isOwner']
      suspend: ['isAuth', 'isOwner']
      resume: ['isAuth', 'isOwner']
      destroy: ['isAuth', 'isOwner']
    UserController:
      '*': false
      find: true
      findOne: ['isAuth', 'user/me']
