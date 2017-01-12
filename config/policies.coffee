
module.exports = 
	policies:
		VmsController:
			'*':		false
			find:		['isAuth']	
			findOne:	['isAuth']			
			create:		['isAuth']
			destroy: 	['isAuth']
			update:		['isAuth']
		UserController:
			'*':		false
			find:		true
			findOne:	['isAuth', 'user/me']
			