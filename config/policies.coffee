
module.exports = 
	policies:
		VmController:
			'*':		false
			find:		['isAuth']	
			findOne:	['isAuth']			
			create:		['isAuth']
			destroy: 	['isAuth']
			update:		['isAuth']
		