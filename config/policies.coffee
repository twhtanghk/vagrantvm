module.exports = 
  policies:
    VmController:
      '*': false
      passwd: ['isAuth', 'isOwner']
      findOne: ['isAuth', 'isOwner']
      find: ['isAuth', 'filterByOwner']
      listAll: ['isAuth', 'isAdmin']
      create: ['isAuth', 'setCreatedBy']
      up: ['isAuth', 'isOwner']
      down: ['isAuth', 'isOwner']
      restart: ['isAuth', 'isOwner']
      suspend: ['isAuth', 'isOwner']
      resume: ['isAuth', 'isOwner']
      backup: ['isAuth', 'isOwner']
      restore: ['isAuth', 'isOwner']
      destroy: ['isAuth', 'isOwner']
    UserController:
      '*': false
      find: true
      findOne: ['isAuth', 'user/me']
