const assert = require('node:assert/strict');
const fs = require('fs');
const argv = require('minimist')(process.argv.slice(2));

if (argv._.length !== 2)
  throw new Error('lvldata_convert.js: Expected two arguments');

const inFileName = argv._[0];
const outFileName = argv._[1];

// Split a 16*n width graphics layer into n 16 width pages
const splitMap = (layer) => {
  const numPages = layer.width / 16;

  const pages = [... new Array(numPages)].map(_ => new Uint8Array(256));

  let layerIx = 0;
  for (let i = 0; i < layer.height; i++) {
    for (let j = 0; j < numPages; j++) {
      for (let k = 0; k < 16; k++) {
        // NOTE tiled's tile indices appear to be one-indexed rather than
        // zero-indexed. 1 is subtracted here to account for this
        pages[j][(i * 16) + k] = layer.data[layerIx++] - 1;
      }
    }
  }

  return pages;
}

const mkHeader = (mapPages) => {
  // Our header will be exactly one page
  // This ensures each following page will be page-aligned
  // when the entirety of leveldata is page-aligned
  const buf = new Uint8Array(256);
  buf[0] = mapPages.length;

  return buf;
}

const file = fs.readFileSync(inFileName);
const levelData = JSON.parse(file);

// We're looking for a layer named "Graphics" for our graphics data
const graphicsLayer = levelData.layers.find(layer => layer.name === 'Graphics');

assert(graphicsLayer, 'Level data lacking a layer named "Graphics".');
assert.equal(graphicsLayer.type, 'tilelayer', 'Graphics layer expected to be a "tilelayer".');
assert.equal(graphicsLayer.height, 16, 'Graphics layer height expected to be 16.');
assert.equal(graphicsLayer.width % 16, 0, 'Graphics layer width expected to be divisble by 16.');

const mapPages = splitMap(graphicsLayer);

for (const page of mapPages) {
  assert.equal(page.length, 256, 'Every map page expected to be exactly 256 bytes long');
}

const header = mkHeader(mapPages);

assert.equal(header.length, 256, 'Header expected to be exactly 256 bytes long');

const outputSize = mapPages.reduce((acc, pg) => acc + pg.length, 0) + header.length;

assert.equal(outputSize % 256, 0, 'Output size expected to be a divisble by 256 (a whole number of pages).');

const outputBuf = new Uint8Array(outputSize);
outputBuf.set(header, 0);

for (const [ix, val] of Object.entries(mapPages)) {
  outputBuf.set(val, 256 + (256 * ix));
}

fs.writeFileSync(outFileName, outputBuf);
