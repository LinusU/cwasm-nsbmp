FROM ubuntu:18.04

#########################
# Install prerequisites #
#########################

RUN \
  apt-get update && \
  apt-get install -y ca-certificates curl git

########################
# Install WASI SDK 8.0 #
########################

RUN curl -L https://github.com/CraneStation/wasi-sdk/releases/download/wasi-sdk-8/wasi-sdk-8.0-linux.tar.gz | tar xz --strip-components=1 -C /

#####################
# Build actual code #
#####################

WORKDIR /code

RUN git clone git://git.netsurf-browser.org/libnsbmp.git && cd libnsbmp && git checkout release/0.1.5
ADD decode.c .

# Relase build
RUN clang --sysroot=/share/wasi-sysroot --target=wasm32-unknown-wasi -Ilibnsbmp/include/ -Oz     -o libnsbmp.wasm -nostartfiles -fvisibility=hidden -Wl,--no-entry,--demangle,--export=malloc,--export=free,--export=decode_bmp,--strip-all -- decode.c libnsbmp/src/libnsbmp.c

# Debug build
# RUN clang --sysroot=/share/wasi-sysroot --target=wasm32-unknown-wasi -Ilibnsbmp/include/ -O0 -g3 -o libnsbmp.wasm -nostartfiles -fvisibility=hidden -Wl,--no-entry,--demangle,--export=malloc,--export=free,--export=decode_bmp,             -- decode.c libnsbmp/src/libnsbmp.c

CMD base64 --wrap=0 libnsbmp.wasm