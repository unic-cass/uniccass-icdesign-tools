# Based on https://github.com/iic-jku/IIC-OSIC-TOOLS/blob/main/_build/Dockerfile

ARG BASE_IMAGE=ubuntu:22.04

# Jan 11, 2025 (ngspice-44.2)
ARG NGSPICE_REPO_URL="https://github.com/danchitnis/ngspice-sf-mirror"
ARG NGSPICE_REPO_COMMIT="ngspice-44.2"
ARG NGSPICE_NAME="ngspice"

ARG XYCE_REPO_URL="https://github.com/Xyce/Xyce.git"
ARG XYCE_REPO_COMMIT="Release-7.8.0"
ARG XYCE_TRILINOS_REPO_URL="https://github.com/trilinos/Trilinos"
ARG XYCE_TRILINOS_REPO_COMMIT="trilinos-release-12-12-1"
ARG XYCE_NAME="xyce"

# Aug 16, 2024 (master)
ARG OPEN_PDKS_REPO_URL="https://github.com/RTimothyEdwards/open_pdks"
ARG OPEN_PDKS_REPO_COMMIT="0fe599b2afb6708d281543108caf8310912f54af"
ARG OPEN_PDKS_NAME="open_pdks"

# Feb 23, 2025 (8.3.522)
ARG MAGIC_REPO_URL="https://github.com/RTimothyEdwards/magic.git"
ARG MAGIC_REPO_COMMIT="8.3.522"
ARG MAGIC_NAME="magic"

# Apr 15, 2025 (dev)
ARG IHP_PDK_REPO_URL="https://github.com/IHP-GmbH/IHP-Open-PDK.git"
ARG IHP_PDK_REPO_COMMIT="e1ccb16b29c386dd2d7c41ac555c32f347b9364a"
ARG IHP_PDK_NAME="ihp-sg13g2"

# Oct 30, 2023 (master)
ARG OPENVAF_REPO_URL="https://github.com/iic-jku/OpenVAF.git"
ARG OPENVAF_REPO_COMMIT="a9697ae7780518f021f9f64e819b3a57033bd39f"
ARG OPENVAF_DOWNLOAD="https://openva.fra1.cdn.digitaloceanspaces.com/openvaf_23_5_0_linux_amd64.tar.gz"
ARG OPENVAF_NAME="openvaf"

# Mar 05, 2025 (v0.29.12)
ARG KLAYOUT_REPO_URL="https://github.com/KLayout/klayout"
ARG KLAYOUT_REPO_COMMIT="v0.29.12"
ARG KLAYOUT_DOWNLOAD="https://www.klayout.org/downloads/Ubuntu-22/klayout_0.30.1-1_amd64.deb"
ARG KLAYOUT_NAME="klayout"

# Mar 14, 2025 (master)
ARG XSCHEM_REPO_URL="https://github.com/StefanSchippers/xschem.git"
ARG XSCHEM_REPO_COMMIT="313acc8e2974c38be80549203a555bed0fd4e30f"
ARG XSCHEM_NAME="xschem"

# Apr 21, 2024 ()
ARG OPENROAD_APP_REPO_URL="https://github.com/The-OpenROAD-Project/OpenROAD.git"
ARG OPENROAD_APP_REPO_COMMIT="d423155d69de7f683a23f6916ead418a615ad4ad"
ARG OPENROAD_APP_NAME="openroad"

# Mar 10, 2025 (1.5.293)
ARG NETGEN_REPO_URL="https://github.com/rtimothyedwards/netgen"
ARG NETGEN_REPO_COMMIT="1.5.293"
ARG NETGEN_NAME="netgen"

# Oct 25, 2023 (main)
ARG GAW3_XSCHEM_REPO_URL="https://github.com/StefanSchippers/xschem-gaw.git"
ARG GAW3_XSCHEM_REPO_COMMIT="640c672e1ad768b92eb6a15943459a1d2214e1dc"
ARG GAW3_XSCHEM_NAME="gaw3-xschem"

# Aug 6, 2024 (yosys-0.44)
ARG YOSYS_REPO_URL="https://github.com/YosysHQ/yosys"
ARG YOSYS_REPO_COMMIT="yosys-0.44"
ARG YOSYS_NAME="yosys"
ARG YOSYS_EQY_REPO_URL="https://github.com/YosysHQ/eqy.git"
ARG YOSYS_EQY_NAME="yosys_eqy"
ARG YOSYS_SBY_REPO_URL="https://github.com/YosysHQ/sby.git"
ARG YOSYS_SBY_NAME="yosys_sby"
ARG YOSYS_MCY_REPO_URL="https://github.com/YosysHQ/mcy.git"
ARG YOSYS_MCY_NAME="yosys_mcy"

# May 8, 2023 (v1.1.5)
ARG CVC_RV_REPO_URL="https://github.com/d-m-bailey/cvc"
ARG CVC_RV_REPO_COMMIT="v1.1.5"
ARG CVC_RV_NAME="cvc_rv"

# Jun 15, 2024 (v5.026)
ARG VERILATOR_REPO_URL="https://github.com/verilator/verilator"
ARG VERILATOR_REPO_COMMIT="cd693ce02b914151fcc761eaecd15af96d2006ad"
ARG VERILATOR_NAME="verilator"

# Sep 7, 2024 (master)
ARG IVERILOG_REPO_URL="https://github.com/steveicarus/iverilog.git"
ARG IVERILOG_REPO_COMMIT="25a84d5cfcecf67bfb7734929a1df98c4b137ce6"
ARG IVERILOG_NAME="iverilog"

# Sep 7, 2024 (master)
ARG GTKWAVE_REPO_URL="https://github.com/gtkwave/gtkwave.git"
ARG GTKWAVE_REPO_COMMIT="0a800de96255f7fb11beadb6729fdf670da76ecb"
ARG GTKWAVE_NAME="gtkwave"

# Jul 27, 2024 (master)
ARG ORFS_REPO_URL="https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts"
ARG ORFS_REPO_COMMIT="a0615e8f0e00649cf642861e4e1e1951fa33df02"
ARG ORFS_NAME="OpenROAD-flow-scripts"

#######################################################################
# Basic configuration for base and builder
#######################################################################

FROM ${BASE_IMAGE} AS common
ARG CONTAINER_TAG=unknown
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Vienna \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    TOOLS=/opt \
    PDK_ROOT=/opt/pdks

USER root


#######################################################################
# Setup base image
#######################################################################
FROM common AS base

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

ENV PATH="$TOOLS/common/bin:$PATH" \
    LD_LIBRARY_PATH="$TOOLS/common/lib64:$TOOLS/common/lib:$LD_LIBRARY_PATH"


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
# Compile openroad
#######################################################################
FROM builder AS openroad

ARG OPENROAD_APP_REPO_URL \
    OPENROAD_APP_REPO_COMMIT \
    OPENROAD_APP_NAME

RUN --mount=type=bind,source=images/openroad,target=/images/openroad \
    bash /images/openroad/install.sh


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
# Compile OpenROAD Flow Scripts
#######################################################################
FROM builder AS orfs

ARG ORFS_REPO_URL \
    ORFS_REPO_COMMIT \
    ORFS_NAME

RUN --mount=type=bind,source=images/orfs,target=/images/orfs \
    bash /images/orfs/install.sh


#######################################################################
# Final output container
#######################################################################
FROM base AS usm-vlsi-tools
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

RUN --mount=type=bind,source=images/final_structure/configure,target=/images/final_structure/configure \
    cd /images/final_structure/configure/ \
    && bash tool_configuration.sh

COPY --from=open_pdks  ${PDK_ROOT}                  ${PDK_ROOT}
COPY --from=ihp_pdk    ${PDK_ROOT}/${IHP_PDK_NAME}  ${PDK_ROOT}/${IHP_PDK_NAME}
COPY --from=builder    ${TOOLS}/common              ${TOOLS}/common
COPY --from=ihp_pdk    ${TOOLS}/openvaf             ${TOOLS}/openvaf
COPY --from=ngspice    ${TOOLS}/ngspice             ${TOOLS}/ngspice
COPY --from=xschem     ${TOOLS}/xschem              ${TOOLS}/xschem
COPY --from=magic      ${TOOLS}/magic               ${TOOLS}/magic
COPY --from=netgen     ${TOOLS}/netgen              ${TOOLS}/netgen
COPY --from=gaw        ${TOOLS}/gaw3-xschem         ${TOOLS}/gaw3-xschem
COPY --from=cvc_rv     ${TOOLS}/cvc_rv              ${TOOLS}/cvc_rv
COPY --from=verilator  ${TOOLS}/verilator           ${TOOLS}/verilator
COPY --from=iverilog   ${TOOLS}/iverilog            ${TOOLS}/iverilog
COPY --from=yosys      ${TOOLS}/yosys               ${TOOLS}/yosys
COPY --from=openroad   ${TOOLS}/openroad            ${TOOLS}/openroad
COPY --from=orfs       ${TOOLS}/OpenROAD-flow-scripts   ${TOOLS}/OpenROAD-flow-scripts


RUN --mount=type=bind,source=images/final_structure/configure,target=/images/final_structure/configure \
    cd /images/final_structure/configure/ \
    && bash modify_user.sh

RUN --mount=type=bind,source=images/final_structure/configure,target=/images/final_structure/configure \
    bash -c 'cat images/final_structure/configure/.bashrc' >> /home/designer/.bashrc && \
    bash -c 'cat images/final_structure/configure/.bashrc' >> /root/.bashrc

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

FROM usm-vlsi-tools AS usm-vlsi-tools-temp
USER root

USER designer
