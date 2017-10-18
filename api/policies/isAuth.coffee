{isAuth} = require 'sails_policy'

module.exports = (req, res, next) ->
  isAuth req, res, ->
    sails.models.user
      .findOrCreate req.user
      .then ->
        next()
      .catch res.negotiate
