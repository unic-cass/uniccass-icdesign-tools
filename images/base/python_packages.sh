#!/bin/bash

set -ex

pip install uv

uv pip install --system --strict --compile-bytecode --no-cache \
    "numpy<2" \
    gdsfactory \
    glayout \
    cace \
    pandas \
    ojson \
    networkx \
    pytest \
    scipy \
    gdstk \
    svgutils \
    prettyprinttree \
    pyspice \
    volare==0.18.1 \
    spyci \
    jupyter \
    jupyterlab \
    ipython \
    ipykernel \
    ipywidgets \
    docopt \
    klayout \
    pygmid \
    kfactory \
    ruff \
    click \
    "pygobject<3.52.0" \
    xdot