FROM ubuntu:focal

RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  git \
  wget \
  rsync \
  python3 \
  lld
RUN apt-get update

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup install beta-2023-03-07
RUN rustup default beta

WORKDIR /example

RUN git clone https://github.com/rust-lang/rust || true
# HEAD as of 2023-03-30
RUN (cd rust && git checkout 516a6d320270f03548c04c0707a00c998787de45)
RUN (cd rust && git submodule update --init --recursive)
RUN (cd rust && python3 x.py build)

ADD run.sh /example
