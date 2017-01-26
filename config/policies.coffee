module.exports = 
  policies:
    VmController:
      '*': false
      findOne: ['isAuth']      
      find: ['isAuth', 'filterByOwner']
      create: ['isAuth', 'setCreatedBy']
      up: ['isAuth', 'isOwner']
      down: ['isAuth', 'isOwner']
      restart: ['isAuth', 'isOwner']
      suspend: ['isAuth', 'isOwner']
      resume: ['isAuth', 'isOwner']
    UserController:
      '*': false
      find: true
      findOne: ['isAuth', 'user/me']
