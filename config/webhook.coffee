_ = require 'lodash'
co = require 'co'

module.exports =
  webhook:
    url: 'https://abc.com/vncproxy/reload'
    reload: -> co ->
      api = sails.config.api()
        .use (opts) ->
          _.defaults sails.config.webhook.oauth2, sails.config.oauth2
          ret =
            headers:
              Authorization: "Bearer #{yield sails.config.oauth2.validToken sails.config.webhook.oauth2}"
          _.extend ret, opts
      res = yield api.get sails.config.webhook.url
      sails.log.debug "webhook reload #{res.body.toString()}"
