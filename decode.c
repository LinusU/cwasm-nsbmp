#include <stdlib.h>

#include "libnsbmp.h"

#define BYTES_PER_PIXEL 4
#define TRANSPARENT_COLOR 0xffffffff

void *bitmap_create(int width, int height, unsigned int state) {
  return calloc(width * height, BYTES_PER_PIXEL);
}

void bitmap_destroy(void *bitmap) {
  // The data is NOT freed here since we are passing it back and want it to live longer than the `bmp_image`
}

unsigned char *bitmap_get_buffer(void *bitmap) {
  return bitmap;
}

size_t bitmap_get_bpp(void *bitmap) {
  return BYTES_PER_PIXEL;
}

bmp_result decode_bmp(unsigned char** out, unsigned* w, unsigned* h, uint8_t* in, size_t insize) {
  bmp_bitmap_callback_vt bitmap_callbacks = {
    bitmap_create,
    bitmap_destroy,
    bitmap_get_buffer,
    bitmap_get_bpp
  };

  bmp_result code;
  bmp_image bmp;

  /* create our bmp image */
  bmp_create(&bmp, &bitmap_callbacks);

  /* analyse the BMP */
  code = bmp_analyse(&bmp, insize, in);
  if (code != BMP_OK) goto cleanup;

  /* decode the image */
  code = bmp_decode(&bmp);
  if (code != BMP_OK) goto cleanup;

  *out = bmp.bitmap;
  *w = bmp.width;
  *h = bmp.height;

cleanup:
  if (code != BMP_OK) free(bmp.bitmap);
  bmp_finalise(&bmp);
  return code;
}
