# assload [![Build Status](https://drone.io/github.com/gitsubio/assload/status.png)](https://drone.io/github.com/gitsubio/assload/latest) [![devDependency Status](https://david-dm.org/gitsubio/assload/dev-status.svg?style=flat-square)](https://david-dm.org/gitsubio/assload#info=devDependencies)

Modular, extensible asset manager with preloading capabilities.

**NOTE:** This has not been battle tested yet; use at your own risk. (And please [report issues](http://github.com/gitsubio/assload/issues))

```js
var assload = require('assload'),
    images = require('assload-images'),
    assets;

assets = assload({
  images: images({base: 'img'})
});

assets.load({
  images: {
    bacon: 'bacon.png',
    eggs: 'eggs.jpg'
  }
}).fail(function (err) {
  console.error('Failed to load asset:', err);
}).progress(function (asset, amount, number, total) {
  console.log('Loading ' + asset + ': %' + Math.round(amount*100) + ' complete');
  console.log(number + ' out of ' + total + ' assets loaded.');
}).done(function () {
  console.log('Bacon:', assets.images.bacon); // Bacon: <img src='img/bacon.png' />
  console.log('Eggs:', assets.images.eggs);   // Eggs: <img src='img/eggs.jpg' />
});
```

## API

```js
var assload = require('assload');
```

## License

MIT

## Install

```bash
npm install assload --save
```

----

[![Analytics](https://ga-beacon.appspot.com/UA-33247419-2/assload/README.md)](https://github.com/igrigorik/ga-beacon)
