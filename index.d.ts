import ImageData = require('@canvas/image-data')

/**
 * @param source - The BMP data
 * @returns Decoded width, height and pixel data
 */
export function decode (source: Uint8Array): ImageData
