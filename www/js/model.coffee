require 'PageableAR'

angular.module 'starter.model', ['PageableAR']

	.factory 'resources', (pageableAR) ->



		class BusinessProcess extends pageableAR.Model
			$idAttribute: 'id'
			
			$urlRoot: "api/businessProcess"

		# BusinessProcessList
		class BusinessProcessList extends pageableAR.PageableCollection

			model: BusinessProcess
			
			$urlRoot: "api/businessProcess"

		class User extends pageableAR.Model
			$idAttribute: 'username'
			
			$urlRoot: "api/user"
			
			_me = null
			
			@me: ->
				_me ?= new User username: 'me'
		
		# UserList
		class UserList extends pageableAR.PageableCollection

			model: User
			
			$urlRoot: "api/user"

		class Processins extends pageableAR.Model
			$idAttribute: 'id'
			
			$urlRoot: "api/processins"
		
		# ProcessinsList
		class ProcessinsList extends pageableAR.PageableCollection
			model: Processins
		
			$urlRoot: "api/processins"	
		
		#
		class ProcessinsHistoryList extends pageableAR.PageableCollection
			model: Processins
		
			$urlRoot: "api/processinsHistory"

		class WorkflowTask extends pageableAR.Model
			$idAttribute: 'id'
			
			$urlRoot: "api/workflowtask"
		
		# WorkflowTaskList
		class WorkflowTaskList extends pageableAR.PageableCollection
			model: WorkflowTask
		
			$urlRoot: "api/workflowtask"		
						
		BusinessProcess:		BusinessProcess
		BusinessProcessList:	BusinessProcessList
		User:		User
		UserList:	UserList
		Processins:				Processins
		ProcessinsList:			ProcessinsList
		ProcessinsHistoryList:	ProcessinsHistoryList
		WorkflowTask:			WorkflowTask
		WorkflowTaskList:		WorkflowTaskList