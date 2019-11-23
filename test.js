/* eslint-env mocha */

const assert = require('assert')
const fs = require('fs')

const ImageData = require('@canvas/image-data')
const lodepng = require('lodepng')

const nsbmp = require('./')

const fixtures = ['linux', 'ns']

describe('libnsbmp', () => {
  for (const fixture of fixtures) {
    it(`decodes "${fixture}.bmp"`, async () => {
      const referenceSource = fs.readFileSync(`fixtures/${fixture}_ref.png`)
      const reference = await lodepng.decode(referenceSource)

      const source = fs.readFileSync(`fixtures/${fixture}.bmp`)
      const result = nsbmp.decode(source)

      assert(result instanceof ImageData)
      assert.strictEqual(result.width, reference.width)
      assert.strictEqual(result.height, reference.height)
      assert.deepStrictEqual(result.data, new Uint8ClampedArray(reference.data))
    })
  }
})
