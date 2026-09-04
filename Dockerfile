# Based on https://github.com/iic-jku/IIC-OSIC-TOOLS/blob/main/_build/Dockerfile

ARG BASE_IMAGE

# ngspice
ARG NGSPICE_REPO_URL
ARG NGSPICE_REPO_COMMIT
ARG NGSPICE_NAME

# Xyce
ARG XYCE_REPO_URL
ARG XYCE_REPO_COMMIT
ARG XYCE_TRILINOS_REPO_URL
ARG XYCE_TRILINOS_REPO_COMMIT
ARG XYCE_NAME

# Open PDKs
ARG OPEN_PDKS_REPO_URL
ARG OPEN_PDKS_REPO_COMMIT
ARG OPEN_PDKS_NAME

# Magic
ARG MAGIC_REPO_URL
ARG MAGIC_REPO_COMMIT
ARG MAGIC_NAME

# IHP Open PDK
ARG IHP_PDK_REPO_URL
ARG IHP_PDK_REPO_COMMIT
ARG IHP_PDK_REPO_BRANCH
ARG IHP_PDK_NAME

# OpenVAF
ARG OPENVAF_REPO_URL
ARG OPENVAF_REPO_COMMIT
ARG OPENVAF_DOWNLOAD
ARG OPENVAF_NAME

# KLayout
ARG KLAYOUT_REPO_URL
ARG KLAYOUT_REPO_COMMIT
ARG KLAYOUT_DOWNLOAD
ARG KLAYOUT_NAME

# xschem
ARG XSCHEM_REPO_URL
ARG XSCHEM_REPO_COMMIT
ARG XSCHEM_NAME

# Netgen
ARG NETGEN_REPO_URL
ARG NETGEN_REPO_COMMIT
ARG NETGEN_NAME

# gaw3 for xschem
ARG GAW3_XSCHEM_REPO_URL
ARG GAW3_XSCHEM_REPO_COMMIT
ARG GAW3_XSCHEM_NAME

# Yosys
ARG YOSYS_REPO_URL
ARG YOSYS_REPO_COMMIT
ARG YOSYS_NAME
ARG YOSYS_EQY_REPO_URL
ARG YOSYS_EQY_NAME
ARG YOSYS_SBY_REPO_URL
ARG YOSYS_SBY_NAME
ARG YOSYS_MCY_REPO_URL
ARG YOSYS_MCY_NAME

# CVC-RV
ARG CVC_RV_REPO_URL
ARG CVC_RV_REPO_COMMIT
ARG CVC_RV_NAME

# Verilator
ARG VERILATOR_REPO_URL
ARG VERILATOR_REPO_COMMIT
ARG VERILATOR_NAME

# Icarus Verilog
ARG IVERILOG_REPO_URL
ARG IVERILOG_REPO_COMMIT
ARG IVERILOG_NAME

# GTKWave
ARG GTKWAVE_REPO_URL
ARG GTKWAVE_REPO_COMMIT
ARG GTKWAVE_NAME

# OpenROAD
ARG OPENROAD_REPO_URL
ARG OPENROAD_REPO_COMMIT
ARG OPENROAD_NAME

# OpenROAD-flow-scripts
ARG ORFS_REPO_URL
ARG ORFS_REPO_COMMIT
ARG ORFS_NAME

ARG NIX_INSTALLER_URL
ARG NIX_SUBSTITUTER_URL
ARG NIX_SUBSTITUTER_PUBLIC_KEY
ARG LIBRELANE_REPO_URL
ARG LIBRELANE_REPO_COMMIT
ARG ENABLE_GUI
ARG MAX_BUILD_JOBS

#######################################################################
# Basic configuration for base and builder
#######################################################################

FROM ${BASE_IMAGE} AS common
# Limit build parallelism to reduce RAM usage (default: 2 for memory-constrained builds)
ARG MAX_BUILD_JOBS
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Vienna \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    TOOLS=/opt \
    PDK_ROOT=/opt/pdks \
    MAX_BUILD_JOBS=${MAX_BUILD_JOBS}

USER root


#######################################################################
# Setup base image
#######################################################################
FROM common AS base

ARG ENABLE_GUI
ENV ENABLE_GUI=${ENABLE_GUI}

# From build/images/base/Dockerfile IIC_OSIC_TOOLS
ENV VNC_PORT=5901 \
    NO_VNC_PORT=80
EXPOSE $VNC_PORT $NO_VNC_PORT 

# Environment config
ENV NO_VNC_HOME=/usr/share/novnc \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1680x1050 \
    VNC_PW=abc123 \
    VNC_VIEW_ONLY=false

RUN --mount=type=bind,source=images/base,target=/images/base \
    bash /images/base/base_install.sh
RUN --mount=type=bind,source=images/base,target=/images/base \
    bash /images/base/python_packages.sh


#######################################################################
# Builder image (Has all iic dependencies)
#######################################################################
FROM common AS builder

RUN --mount=type=bind,source=images/builder,target=/images/builder \
    bash /images/builder/exhaustive-install.sh

# Initialize CMAKE_PACKAGE_ROOT_ARGS variable
ENV CMAKE_PACKAGE_ROOT_ARGS=""
ENV CMAKE_PACKAGE_ROOT_ARGS="$CMAKE_PACKAGE_ROOT_ARGS -D SWIG_ROOT=$TOOLS/common -D Eigen3_ROOT=$TOOLS/common -D GTest_ROOT=$TOOLS/common -D LEMON_ROOT=$TOOLS/common -D spdlog_ROOT=$TOOLS/common -D ortools_ROOT=$TOOLS/common"

RUN --mount=type=bind,source=images/boost,target=/images/boost \
    bash /images/boost/install.sh
RUN --mount=type=bind,source=images/swig,target=/images/swig \
    bash /images/swig/install.sh
RUN --mount=type=bind,source=images/eigen,target=/images/eigen \
    bash /images/eigen/install.sh
RUN --mount=type=bind,source=images/cudd,target=/images/cudd \
    bash /images/cudd/install.sh
RUN --mount=type=bind,source=images/cusp,target=/images/cusp \
    bash /images/cusp/install.sh
RUN --mount=type=bind,source=images/lemon,target=/images/lemon \
    bash /images/lemon/install.sh
RUN --mount=type=bind,source=images/spdlog,target=/images/spdlog \
    bash /images/spdlog/install.sh
RUN --mount=type=bind,source=images/gtest,target=/images/gtest \
    bash /images/gtest/install.sh
RUN --mount=type=bind,source=images/ortools,target=/images/ortools \
    bash /images/ortools/install.sh

ENV PATH="$TOOLS/common/bin:$PATH"
ENV LD_LIBRARY_PATH="$TOOLS/common/lib64:$TOOLS/common/lib"

# Cleanup: Remove temporary files and build artifacts from builder stage
# Note: Don't delete .a files from /usr as they might be needed for linking
RUN rm -rf /tmp/* /var/tmp/* && \
    find /usr -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true


#######################################################################
# Compile magic (Requirement for sky130 pdk)
#######################################################################
FROM builder AS magic

ARG MAGIC_REPO_URL \
    MAGIC_REPO_COMMIT \
    MAGIC_NAME

RUN --mount=type=bind,source=images/magic,target=/images/magic \
    bash /images/magic/install.sh


#######################################################################
# Build PDKs from open_pdks
#######################################################################
FROM magic AS open_pdks

ARG OPEN_PDKS_REPO_URL \
    OPEN_PDKS_REPO_COMMIT \
    OPEN_PDKS_NAME

RUN --mount=type=bind,source=images/base,target=/images/base \
    bash /images/base/python_packages.sh

RUN --mount=type=bind,source=images/pdks,target=/images/pdks \
    cd /images/pdks/ \
    && bash install_sky130.sh \
    && bash install_gf180mcu.sh

RUN --mount=type=bind,source=images/final_structure/configure,target=/images/final_structure/configure \
    cd /images/final_structure/configure/ \
    && bash patch_pdk_sky130.sh \
    && bash patch_pdk_gf180mcu.sh

#######################################################################
# Compile openvaf (requirement for ihp pdk)
#######################################################################
FROM builder AS openvaf

ARG OPENVAF_REPO_URL \
    OPENVAF_REPO_COMMIT \
    OPENVAF_DOWNLOAD \
    OPENVAF_NAME
ENV OPENVAF_NAME=${OPENVAF_NAME}

RUN --mount=type=bind,source=images/openvaf,target=/images/openvaf \
    bash /images/openvaf/install.sh


#######################################################################
# Build ihp pdk open pdk
#######################################################################
FROM openvaf AS ihp_pdk

ARG IHP_PDK_REPO_URL \
    IHP_PDK_REPO_COMMIT \
    IHP_PDK_REPO_BRANCH \
    IHP_PDK_NAME

RUN --mount=type=bind,source=images/ihp_pdk,target=/images/ihp_pdk \
    bash /images/ihp_pdk/install.sh


#######################################################################
# Compile ngspice
#######################################################################
FROM builder AS ngspice

ARG NGSPICE_REPO_URL \
    NGSPICE_REPO_COMMIT \
    NGSPICE_NAME

RUN --mount=type=bind,source=images/ngspice,target=/images/ngspice \
    bash /images/ngspice/install.sh

#######################################################################
# Compile xyce
#######################################################################
FROM builder AS xyce

ARG XYCE_REPO_URL \
    XYCE_REPO_COMMIT \
    XYCE_NAME \
    XYCE_TRILINOS_REPO_URL \
    XYCE_TRILINOS_REPO_COMMIT

RUN --mount=type=bind,source=images/xyce,target=/images/xyce \
    bash /images/xyce/install.sh
    
#######################################################################
# Compile klayout
#######################################################################
# FROM builder AS klayout

# ARG KLAYOUT_REPO_URL \
#     KLAYOUT_REPO_COMMIT \
#     KLAYOUT_DOWNLOAD \
#     KLAYOUT_NAME

# RUN --mount=type=bind,source=images/klayout,target=/images/klayout \
#     bash /images/klayout/install.sh


#######################################################################
# Compile xschem
#######################################################################
FROM builder AS xschem

ARG XSCHEM_REPO_URL \
    XSCHEM_REPO_COMMIT \
    XSCHEM_NAME

RUN --mount=type=bind,source=images/xschem,target=/images/xschem \
    bash /images/xschem/install.sh


#######################################################################
# Compile yosys
#######################################################################
FROM builder AS yosys

ARG YOSYS_REPO_URL \
    YOSYS_REPO_COMMIT \
    YOSYS_NAME \
    YOSYS_EQY_REPO_URL \
    YOSYS_EQY_NAME \
    YOSYS_SBY_REPO_URL \
    YOSYS_SBY_NAME \
    YOSYS_MCY_REPO_URL \
    YOSYS_MCY_NAME

RUN --mount=type=bind,source=images/yosys,target=/images/yosys \
    bash /images/yosys/install.sh

#######################################################################
# Compile netgen
#######################################################################
FROM builder AS netgen

ARG NETGEN_REPO_URL \
    NETGEN_REPO_COMMIT \
    NETGEN_NAME

RUN --mount=type=bind,source=images/netgen,target=/images/netgen \
    bash /images/netgen/install.sh


#######################################################################
# Compile gaw
#######################################################################
FROM builder AS gaw

ARG GAW3_XSCHEM_REPO_URL \
    GAW3_XSCHEM_REPO_COMMIT \
    GAW3_XSCHEM_NAME

RUN --mount=type=bind,source=images/gaw,target=/images/gaw \
    bash /images/gaw/install.sh


#######################################################################
# Compile gtkwave
#######################################################################
# FROM builder AS gtkwave
# ARG GTKWAVE_REPO_URL \
#     GTKWAVE_REPO_COMMIT \
#     GTKWAVE_NAME

# RUN --mount=type=bind,source=images/gtkwave,target=/images/gtkwave \
#     bash /images/gtkwave/install.sh


#######################################################################
# Compile cvc_rv
#######################################################################
FROM builder AS cvc_rv

ARG CVC_RV_REPO_URL \
    CVC_RV_REPO_COMMIT \
    CVC_RV_NAME

RUN --mount=type=bind,source=images/cvc_rv,target=/images/cvc_rv \
    bash /images/cvc_rv/install.sh


#######################################################################
# Compile verilator
#######################################################################
FROM builder AS verilator

ARG VERILATOR_REPO_URL \
    VERILATOR_REPO_COMMIT \
    VERILATOR_NAME

RUN --mount=type=bind,source=images/verilator,target=/images/verilator \
    bash /images/verilator/install.sh

    
#######################################################################
# Compile iverilog
#######################################################################
FROM builder AS iverilog

ARG IVERILOG_REPO_URL \
    IVERILOG_REPO_COMMIT \
    IVERILOG_NAME

RUN --mount=type=bind,source=images/iverilog,target=/images/iverilog \
    bash /images/iverilog/install.sh


#######################################################################
# Compile OpenROAD (core application)
#######################################################################
FROM builder AS openroad_core

ARG OPENROAD_REPO_URL \
    OPENROAD_REPO_COMMIT \
    OPENROAD_NAME

RUN --mount=type=bind,source=images/openroad,target=/images/openroad \
    bash /images/openroad/install.sh

#######################################################################
# Clone OpenROAD-flow-scripts (ORFS)
#######################################################################
FROM base AS orfs

ARG ORFS_REPO_URL \
    ORFS_REPO_COMMIT \
    ORFS_NAME

RUN --mount=type=bind,source=images/orfs,target=/images/orfs \
    bash /images/orfs/install.sh


#######################################################################
# Final output container
#######################################################################
FROM base AS unic-cass-tools
ARG NGSPICE_REPO_COMMIT \
    OPEN_PDKS_REPO_COMMIT \
    MAGIC_REPO_COMMIT \
    IHP_PDK_REPO_COMMIT \
    IHP_PDK_NAME \
    KLAYOUT_DOWNLOAD \
    XSCHEM_REPO_COMMIT \
    NETGEN_REPO_COMMIT


RUN --mount=type=bind,source=images/final_structure/install,target=/images/final_structure/install \
    bash /images/final_structure/install/install_klayout.sh

# Install libyaml-cpp for OpenROAD (combined with cleanup)
RUN apt-get update && \
    apt-get install -y libyaml-cpp-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*

RUN --mount=type=bind,source=images/final_structure/configure,target=/images/final_structure/configure \
    cd /images/final_structure/configure/ \
    && bash tool_configuration.sh

COPY --from=open_pdks  ${PDK_ROOT}                  ${PDK_ROOT}
COPY --from=ihp_pdk    ${PDK_ROOT}/${IHP_PDK_NAME}  ${PDK_ROOT}/${IHP_PDK_NAME}

# Copy common libraries from builder, excluding compile-time only tools
COPY --from=builder    ${TOOLS}/common              ${TOOLS}/common

# Cleanup compile-time only tools from common (SWIG, GTest are only needed at build time)
RUN rm -rf ${TOOLS}/common/bin/swig* ${TOOLS}/common/share/swig && \
    find ${TOOLS}/common -name "*gtest*" -type f -delete && \
    find ${TOOLS}/common -name "*GTest*" -type f -delete && \
    find ${TOOLS}/common -type d -name "*gtest*" -exec rm -rf {} + 2>/dev/null || true
COPY --from=ihp_pdk    ${TOOLS}/openvaf             ${TOOLS}/openvaf
COPY --from=ngspice    ${TOOLS}/ngspice             ${TOOLS}/ngspice
COPY --from=xschem     ${TOOLS}/xschem               ${TOOLS}/xschem
COPY --from=magic      ${TOOLS}/magic               ${TOOLS}/magic
COPY --from=netgen     ${TOOLS}/netgen              ${TOOLS}/netgen
COPY --from=gaw        ${TOOLS}/gaw3-xschem         ${TOOLS}/gaw3-xschem
COPY --from=cvc_rv     ${TOOLS}/cvc_rv              ${TOOLS}/cvc_rv
COPY --from=verilator  ${TOOLS}/verilator           ${TOOLS}/verilator
COPY --from=iverilog   ${TOOLS}/iverilog            ${TOOLS}/iverilog
COPY --from=yosys      ${TOOLS}/yosys               ${TOOLS}/yosys
COPY --from=openroad_core ${TOOLS}/openroad         ${TOOLS}/openroad
COPY --from=orfs       ${TOOLS}/OpenROAD-flow-scripts ${TOOLS}/OpenROAD-flow-scripts

# Strip binaries to reduce image size (20-30% reduction on executables)
RUN find /opt -type f -executable -not -path "*/common/*" -exec file {} \; | \
    grep -E "(ELF.*executable|shared object)" | \
    cut -d: -f1 | \
    xargs -r strip --strip-unneeded 2>/dev/null || true

# Ensure OpenROAD and OpenVAF are in PATH for all users
ENV PATH="$TOOLS/openroad/bin:$TOOLS/openvaf/bin:$PATH"

RUN --mount=type=bind,source=images/final_structure/configure,target=/images/final_structure/configure \
    cd /images/final_structure/configure/ \
    && bash modify_user.sh

# Create /run/user/1000/ directory for X11 and systemd runtime files
RUN mkdir -p /run/user/1000 && \
    chmod 700 /run/user/1000 && \
    chown designer:designer /run/user/1000

# Fix IHP permissions (after designer user is created)
RUN chown -R designer:designer /opt/pdks/ihp-sg13g2/

RUN --mount=type=bind,source=images/final_structure/configure,target=/images/final_structure/configure \
    bash -c 'cat images/final_structure/configure/.bashrc' >> /home/designer/.bashrc && \
    bash -c 'cat images/final_structure/configure/.bashrc' >> /root/.bashrc

# Patch IHP PDK for KLayout DRC compatibility
RUN --mount=type=bind,source=images/final_structure/configure,target=/images/final_structure/configure \
    cd /images/final_structure/configure/ \
    && bash patch_pdk_ihp.sh

# Run xschem install.py script as designer user
USER designer
RUN cd /opt/pdks/ihp-sg13g2/libs.tech/xschem && \
    PATH="$TOOLS/openvaf/bin:$PATH" USER=designer python install.py

COPY --chmod=755 images/final_structure/configure/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

WORKDIR /home/designer
USER designer

ENV NGSPICE_REPO_COMMIT=${NGSPICE_REPO_COMMIT} \
    OPEN_PDKS_REPO_COMMIT=${OPEN_PDKS_REPO_COMMIT} \
    MAGIC_REPO_COMMIT=${MAGIC_REPO_COMMIT} \
    IHP_PDK_REPO_COMMIT=${IHP_PDK_REPO_COMMIT} \
    KLAYOUT_DOWNLOAD=${KLAYOUT_DOWNLOAD} \
    XSCHEM_REPO_COMMIT=${XSCHEM_REPO_COMMIT} \
    NETGEN_REPO_COMMIT=${NETGEN_REPO_COMMIT}

#######################################################################
# Add Nix package manager and LibreLane
#######################################################################
FROM unic-cass-tools AS unic-cass-tools-nix
ARG NIX_INSTALLER_URL \
    NIX_SUBSTITUTER_URL \
    NIX_SUBSTITUTER_PUBLIC_KEY \
    LIBRELANE_REPO_URL \
    LIBRELANE_REPO_COMMIT
USER root

# Install sudo for Nix installer
RUN apt-get update && apt-get install -y sudo && rm -rf /var/lib/apt/lists/*

# Switch to designer user to install Nix in single-user mode
USER designer

# Install Nix in single-user mode for designer user
RUN curl -L "$NIX_INSTALLER_URL" | sh -s -- --no-daemon --yes

# Configure Nix with custom substituters and enable flakes
RUN mkdir -p ~/.config/nix && \
    echo "extra-substituters = $NIX_SUBSTITUTER_URL" > ~/.config/nix/nix.conf && \
    echo "extra-trusted-public-keys = $NIX_SUBSTITUTER_PUBLIC_KEY" >> ~/.config/nix/nix.conf && \
    echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

# Add USER variable to .profile (required by nix.sh)
RUN sed -i '/if \[ -e \/home\/designer\/.nix-profile/i export USER=designer' ~/.profile

# Clone LibreLane repository
USER root
RUN git clone "$LIBRELANE_REPO_URL" /opt/librelane && \
    git -C /opt/librelane checkout --detach "$LIBRELANE_REPO_COMMIT" && \
    chown -R designer:designer /opt/librelane

# Create /opt/pdks/ciel with proper permissions for LibreLane
RUN mkdir -p /opt/pdks/ciel && chown -R designer:designer /opt/pdks/ciel

USER designer
ENV HOME=/home/designer USER=designer
SHELL ["/bin/bash", "-c"]

# Install the manifest-pinned LibreLane revision using Nix
RUN cd /opt/librelane && \
    source ~/.nix-profile/etc/profile.d/nix.sh && \
    nix profile install . --extra-experimental-features "nix-command flakes"

# Verify LibreLane installation
RUN source ~/.nix-profile/etc/profile.d/nix.sh && \
    librelane --version

# Note: yosys is already installed via the yosys stage, skip Nix installation to avoid rate limits
# RUN source ~/.nix-profile/etc/profile.d/nix.sh && \
#     nix profile install nixpkgs#yosys --extra-experimental-features "nix-command flakes"

# Configure /etc/bash.bashrc for interactive shells and replace .bashrc with Nix-compatible version
USER root
RUN --mount=type=bind,source=images/final_structure/configure,target=/images/final_structure/configure \
    sed 's/\r$//' /images/final_structure/configure/etc_bash.bashrc_nix > /etc/bash.bashrc && \
    sed 's/\r$//' /images/final_structure/configure/.bashrc > /home/designer/.bashrc && \
    chown designer:designer /home/designer/.bashrc

USER designer

FROM unic-cass-tools-nix AS unic-cass-tools-temp
USER root
USER designer
