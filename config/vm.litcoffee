    module.exports =

      vm:

url to access api for http reverse proxy 

        url: 'https://abc.com/vm'
        
model to acccess http reverse proxy api

        model: ->
          stamp = sails.config
            .armodel sails.config.vm.url
            .statics
              fetchFull: (opts) ->
                yield @fetchAll _.defaults url: "#{@baseUrl}/full", opts
            .methods
              status: ->
                @save {}, url: path.join stamp.url('update'), 'status'
              up: ->
                @save {}, url: path.join stamp.url('update'), 'up'
              down: ->
                @save {}, url: path.join stamp.url('update'), 'down'
              restart: ->
                @save {}, url: path.join stamp.url('update'), 'restart'
              suspend: ->
                @save {}, url: path.join stamp.url('update'), 'suspend'
              resume: ->
                @save {}, url: path.join stamp.url('update'), 'resume'
              passwd: (passwd) ->
                @save passwd: passwd, url: path.join stamp.url('update'), 'passwd'
            .use sails.config.api().use sails.config.oauth2.getOpts
