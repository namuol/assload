# assload [![Build Status](https://drone.io/github.com/gitsubio/assload/status.png)](https://drone.io/github.com/gitsubio/assload/latest) [![devDependency Status](https://david-dm.org/gitsubio/assload/dev-status.svg?style=flat-square)](https://david-dm.org/gitsubio/assload#info=devDependencies)

Modular, extensible asset manager with preloading capabilities.

**NOTE:** This is experimental software; use at your own risk. (And please [report issues](http://github.com/gitsubio/assload/issues))

```js
var assload = require('assload'),
    loadImages = require('assload-image'),
    loadAudio = require('assload-audio'),
    assets, loader, music;

assets = assload();

assets.use({
  images: loadImages(),
  sounds: loadAudio({preload: 'full'}),
  music: loadAudio()
});

loader = assets.bundle({
  images: {
    bacon: 'bacon.png',
    eggs: 'eggs.jpg'
  },
  sounds: {
    quack: ['quack.ogg', 'quack.wav']
  }
});

loader.on('asset.progress', function (info) {
  console.log(info.type + ':' + info.name + ': %' + Math.round(info.amount*100) + ' complete');
});

loader.on('asset.complete', function (info) {
  console.log(info.totalComplete + ' out of ' + info.totalCount + ' assets loaded');
});

loader.load().catch(function (err) {
  throw err;
}).then(function () {
  console.log('Bacon:', assets.images.bacon); // Bacon: <img src='bacon.png' />
  console.log('Eggs:', assets.images.eggs);   // Eggs: <img src='eggs.jpg' />
  console.log('Quack:', assets.sounds.quack); // Quack: <audio src='quack.ogg' />
});

assets.load({
  music: {
    level1: ['level1.ogg', 'level1.mp3', 'level1.m4a'],
    battle: ['battle.ogg', 'battle.mp3', 'battle.m4a']
  }
}).catch(function (err) {
  console.log('Failed to load music', err);
}).done(function () {
  console.log('All music finished loading.');
});
```

## API

```js
var assload = require('assload');
```

### Create a new asset manager

```js
var assets = assload();
```

### Configure an asset manager to load specific asset types

Assload, on its own, knows nothing about how to load specific types of assets.

You must supply a loader function for any type of asset you wish to load.

```js
assets.use({
  images: loadImage,
  sounds: loadAudio,
  foobars: loadFoobars
});
```

See also: [Create a custom loader](#create-a-custom-loader)

### Load a collection of assets

```js
assets.load({
  images: {
    bacon: 'bacon.png',
    eggs: 'eggs.jpg'
  },
  sounds: {
    quack: ['quack.ogg', 'quack.mp3', 'quack.wav']
  }
}).catch(function (err) {
  console.error(err);
}).done(function () {
  console.log('All assets have been loaded!');
});
```

`load()` returns a [Q](https://github.com/kriskowal/q) promise that resolves when all assets have completed.

You can use `.progress` to listen for progressive load updates, as well.

### Create a custom loader

<a name='create-a-custom-loader' />

Loader functions take on the following format:

```js
function (whatToLoad, resolve, reject, notify) {
  // load the asset here
}
```

> **`whatToLoad`**
> A value passed from `assets.load(...)`; this is usually a filename/uri, but can be any value.

> **`resolve(asset)`**
> A function to call when the asset has successfully loaded.
>
> > **`asset`**
> > The loaded asset.

> **`reject(reason)`**
> A function to call when the asset failed to load.
>
> > **`reason`**
> > A `new Error` with a message describing why the asset failed to load.

> **`notify(progress)`**
> A function to optionally call periodically as the asset progressively loads.
> 
> > **`progress`**
> > Value from 0 to 1 representing the percentage of the asset that has loaded.

## License

MIT

## Install

```bash
npm install assload --save
```

----

[![Analytics](https://ga-beacon.appspot.com/UA-33247419-2/assload/README.md)](https://github.com/igrigorik/ga-beacon)
