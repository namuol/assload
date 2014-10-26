Q = require 'q'

assload = ->
  loaders = {}

  instance =
    use: (_loaders) ->
      for own type,loader of _loaders
        loaders[type] = loader
        @[type] ?= {}

      return @

    load: (allAssets) ->
      all = []

      for own type,assets of allAssets
        if not loaders[type]?
          return Q.reject new Error "No loader specified for type '#{type}'. Provide one with assets.use(...)."
          
        for own name,data of assets
          do (name, data) =>
            all.push loaders[type](data).then (asset) =>
              @[type][name] = asset

      return Q.all all

  return instance

module.exports = assload
