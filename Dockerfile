FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# ---- Core toolchain (Ch. 1-3, 7-10) ----
#   gcc, make, gdb, binutils: compiling/inspecting/debugging C and assembly
#   valgrind: memory-bug hunting (Ch. 9 memory bugs, malloc lab)
#   libc6-dev: headers + .a static archives for glibc itself (confirmed via
#   Launchpad package description — this ships glibc's own static lib,
#   distinct from the libstdc++-static question below)
RUN apt-get update && \
    apt-get install -y \
        gcc \
        g++ \
        make \
        gdb \
        valgrind \
        binutils \
        libc6-dev \
    && rm -rf /var/lib/apt/lists/*

# ---- Best-effort extra static libs ----
# Sources disagreed on whether these are separate packages or already
# bundled in libc6-dev. Rather than assume, install what's available and
# let test_environment.sh report the real state, instead of asserting
# static linking works when it might not have been verified.
RUN apt-get update && \
    (apt-get install -y libc6-static || echo "[build] libc6-static not available in this repo — noted for test script") && \
    (apt-get install -y libstdc++6-static || echo "[build] libstdc++6-static not available in this repo — noted for test script") && \
    rm -rf /var/lib/apt/lists/*

# ---- Y86-64 / HCL toolchain (Ch. 4) ----
#   flex/bison: needed to build the CS:APP student sim.tar (yas assembler, ssim/psim)
#   tcl/tk: the GUI psim/ssim simulators are Tcl/Tk-based
RUN apt-get update && \
    apt-get install -y \
        flex \
        bison \
        tcl \
        tk \
    && rm -rf /var/lib/apt/lists/*

# ---- Performance tooling (Ch. 5-6) ----
# NOTE: perf on Ubuntu is NOT a standalone package the way it is on Fedora.
# It's tied to linux-tools-<exact-kernel-version>, and inside a Docker
# container `uname -r` reports the HOST's kernel, which essentially never
# matches an exact linux-tools-<version> package available in Ubuntu's
# noble repos. A hard `apt-get install perf` or `linux-tools-generic` step
# here would be genuinely likely to fail the build outright, not just
# produce a missing tool. So this is deliberately best-effort, exactly
# like the static-lib install above, and test_environment.sh checks and
# reports the real outcome rather than the Dockerfile asserting success.
RUN apt-get update && \
    (apt-get install -y linux-tools-generic linux-tools-common || \
        echo "[build] perf/linux-tools not available for this kernel — see test_environment.sh output for whether it actually works, and consider installing perf on the HOST and using that instead of inside the container") && \
    rm -rf /var/lib/apt/lists/*

# ---- Networking tools (Ch. 8, 11-12) ----
# NOTE: Ubuntu's package is `iproute2`, not `iproute` (that naming
# difference from Fedora is real, not a typo).
RUN apt-get update && \
    apt-get install -y \
        net-tools \
        iproute2 \
        curl \
        netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# ---- Scripting/support (lab driver scripts, e.g. cache lab's driver.pl) ----
RUN apt-get update && \
    apt-get install -y \
        perl \
        python3 \
    && rm -rf /var/lib/apt/lists/*

# ---- General utilities ----
RUN apt-get update && \
    apt-get install -y \
        wget \
        tar \
        gzip \
        diffutils \
        patch \
        man-db \
        manpages-dev \
        vim \
        git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
CMD ["/bin/bash"]