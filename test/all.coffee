tape = require 'tape'
assload = require '../index'
_ = require 'lodash'
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

  it 'should return an object that has .bundle defined', (t) ->
    loader = assload()
    t.true typeof loader?.bundle is 'function'
    t.end()

  it 'should return a promise when bundle().load is called', (t) ->
    loader = assload()
    t.true Q.isPromise loader.bundle().load()
    t.end()

  it 'should fail when attempting to load unspecified asset types', (t) ->
    loader = assload()
    
    failed = false

    loader.bundle
      unspecified:
        test: 'unspecified'
    .load().catch (err) ->
      failed = true
    .fin ->  
      t.true failed
      t.end()

  it 'should succeed when loading an asset type specified by .use', (t) ->
    loader = assload()

    data =
      test: 42

    loader.use
      custom: (name, resolve) ->
        resolve data[name]
    
    loader.bundle
      custom:
        test: 'test'
    .load()
    .then (assets) ->
      t.equal assets.custom.test, data.test
      t.end()

  it 'should be able to load multiple assets', (t) ->
    loader = assload()

    data =
      'a.custom': 'AAA'
      'b.custom': 'BBB'
      'c.custom': 'CCC'

    loader.use
      custom: (name, resolve) ->
        resolve data[name]
    
    loader.bundle
      custom:
        a: 'a.custom'
        b: 'b.custom'
        c: 'c.custom'
    .load()
    .then (assets) ->
      t.deepEqual assets.custom,
        a: 'AAA'
        b: 'BBB'
        c: 'CCC'
      t.end()

  it 'should emit asset.complete once for each asset that loads', (t) ->
    loader = assload()

    data =
      'a.custom': 'AAA'
      'b.custom': 'BBB'
      'c.custom': 'CCC'

    loader.use
      custom: (name, resolve, reject) ->
        resolve data[name]
    
    complete = 0
    
    notLoaded = ['a', 'b', 'c']

    bundle = loader.bundle
      custom:
        a: 'a.custom'
        b: 'b.custom'
        c: 'c.custom'
    
    bundle.on 'asset.complete', (info) ->
      complete += 1
      
      t.equal info.type, 'custom'
      t.true info.name in notLoaded
      t.equal info.params, info.name + '.custom'

      notLoaded = _.without notLoaded, info.name

    bundle.load()
    .fin ->
      t.equal notLoaded.length, 0
      t.end()

  it 'should emit asset.progress whenever a loader calls a `notify`', (t) ->
    loader = assload()

    data =
      a: 'AAA'
      b: 'BBB'
      c: 'CCC'

    notLoaded = ['a', 'b', 'c']

    loader.use
      custom: (name, resolve, reject, notify) ->
        for i in [1...3]
          do (i) ->
            setTimeout ->
              notify i / 3
            , i

        setTimeout ->
          resolve data[name]
        , 4
    
    bundle = loader.bundle
      custom:
        a: 'a.custom'
        b: 'b.custom'
        c: 'c.custom'

    bundle.on 'asset.progress', (info) ->
      t.true info.amount >= 0
      t.equal info.type, 'custom'
      t.true info.name in notLoaded
      t.equal info.params, info.name + '.custom'

      if info.amount >= 1
        notLoaded = _.without notLoaded, info.name

    bundle.load().fin ->
      t.equal notLoaded.length, 0
      t.end()
