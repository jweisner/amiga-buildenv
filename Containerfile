# Stage 1: build the bebbo amiga-gcc toolchain
FROM debian:bookworm-slim AS builder

RUN apt-get -y update && \
    apt-get -y install --no-install-recommends \
        make wget git gcc g++ lhasa patch \
        libgmp-dev libmpfr-dev libmpc-dev \
        flex bison gettext texinfo \
        ncurses-dev autoconf rsync \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/amiga && \
    git clone https://codeberg.org/bebbo/amiga-gcc && \
    cd amiga-gcc && \
    make update -j && \
    make min -j$(nproc) NDK=3.2 && \
    rm -rf /amiga-gcc

# Stage 2: lean runtime image
FROM debian:bookworm-slim

RUN apt-get -y update && \
    apt-get -y install --no-install-recommends \
        make git lhasa \
        libgmp10 libmpfr6 libmpc3 \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/amiga /opt/amiga

ENV PATH="/opt/amiga/bin:${PATH}"

WORKDIR /work

CMD ["/bin/bash"]
