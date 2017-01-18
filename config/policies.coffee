
module.exports = 
	policies:
		VmController:
			'*':		true
			findOne:	['isAuth']			
			create:		['setCreatedBy']
		UserController:
			'*':		false
			find:		true
			findOne:	['isAuth', 'user/me']
