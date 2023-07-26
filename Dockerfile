FROM ubuntu:22.04

#########################
# Install prerequisites #
#########################

RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl git libxml2

#########################
# Install WASI SDK 15.0 #
#########################

RUN curl -L https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-15/wasi-sdk-15.0-linux.tar.gz | tar xzk --strip-components=1 -C /

#########################
# Install binaryen v110 #
#########################

RUN curl -L https://github.com/WebAssembly/binaryen/releases/download/version_110/binaryen-version_110-x86_64-linux.tar.gz | tar xzk --strip-components=1 -C /

#####################
# Build actual code #
#####################

WORKDIR /code

RUN git clone git://git.netsurf-browser.org/libnsbmp.git && cd libnsbmp && git checkout release/0.1.5
ADD decode.c .

# Relase build
RUN clang --sysroot=/share/wasi-sysroot --target=wasm32-unknown-wasi -Ilibnsbmp/include/ -flto -Oz     -o libnsbmp.wasm -mexec-model=reactor -fvisibility=hidden -Wl,--export=malloc,--export=free,--export=decode_bmp,--strip-all -- decode.c libnsbmp/src/libnsbmp.c

# Debug build
# RUN clang --sysroot=/share/wasi-sysroot --target=wasm32-unknown-wasi -Ilibnsbmp/include/ -flto -O0 -g3 -o libnsbmp.wasm -mexec-model=reactor -fvisibility=hidden -Wl,--export=malloc,--export=free,--export=decode_bmp             -- decode.c libnsbmp/src/libnsbmp.c

RUN wasm-opt -Oz libnsbmp.wasm -o libnsbmp.wasm

CMD base64 --wrap=0 libnsbmp.wasm
