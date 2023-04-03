#!/bin/bash
set -eux

readonly IMAGE_NAME=libc-cvoid-example:latest

declare -a build_args
if getopts 'f' arg; then
  build_args+=(--no-cache)
fi

docker build "${build_args[@]}" -t "${IMAGE_NAME}" .
docker run -it "${IMAGE_NAME}" ./run.sh
