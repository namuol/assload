tape = require 'tape'
assload = require '../index'
Q = require 'q'

describe = (item, cb) ->
  it = (capability, test) ->
    tape.test item + ' ' + capability, (t) ->
      test(t)

  cb it

describe 'assload', (it) ->
  it 'should have a main export that is a function', (t) ->
    t.true typeof assload is 'function'
    t.end()

  it 'should return an object that has .load defined', (t) ->
    assets = assload()
    t.true typeof assets?.load is 'function'
    t.end()

  it 'should return a promise when .load is called', (t) ->
    assets = assload()
    t.true Q.isPromise assets.load()
    t.end()

  it 'should fail when attempting to load unspecified asset types', (t) ->
    assets = assload()
    
    failed = false

    assets.load
      unspecified:
        test: 'unspecified'
    .fail (err) ->
      failed = true
    .fin ->  
      t.true failed
      t.end()

  it 'should succeed when loading an asset type specified by .use', (t) ->
    assets = assload()

    data =
      test: 42

    assets.use
      specified: (name) ->
        deferred = Q.defer()
        deferred.resolve data[name]
        return deferred.promise
    
    succeeded = false

    assets.load
      specified:
        test: 'test'
    .fin ->
      t.equal assets.specified.test, data.test
      t.end()
