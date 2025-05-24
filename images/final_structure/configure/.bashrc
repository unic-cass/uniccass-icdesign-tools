
function _path_add_tool_bin() {
    tool_name=$1
    for d in "$TOOLS/$tool_name"/*/ ; do
        if [ -d "${d}bin" ]; then
            export PATH=$PATH:${d}bin
        fi
    done
}

function _path_add_tool() {
    tool_name=$1
    for d in "$TOOLS/$tool_name"/*/ ; do
        if [ -d "${d}" ]; then
            export PATH=$PATH:${d%/}
        fi
    done
}

function _path_add_tool_custom() {
    custom_path=$1
    for d in $TOOLS/$custom_path/ ; do
        if [ -d "${d}" ]; then
            export PATH=$PATH:${d%/}
        fi
    done
}

function _path_add_tool_python() {
    tool_name=$1
    for d in "$TOOLS/$tool_name"/*/local/lib/python3*/dist-packages ; do
        if [ -d "${d}" ]; then
            export PYTHONPATH=$PYTHONPATH:${d}
        fi
    done
}

# _path_add_tool_bin      "covered"
_path_add_tool_bin      "cvc_rv"
_path_add_tool_bin      "gaw3-xschem"
# _path_add_tool_bin      "gds3d"
# _path_add_tool_bin      "ghdl"
# _path_add_tool_bin      "gtkwave"
# _path_add_tool_bin      "irsim"
_path_add_tool_bin      "iverilog"
# _path_add_tool          "klayout"
# _path_add_tool_custom   "libman"
_path_add_tool_bin      "magic"
_path_add_tool_bin      "netgen"
_path_add_tool_bin      "ngspice"
# _path_add_tool_bin      "nvc"
_path_add_tool_bin      "openroad"
# _path_add_tool_bin      "opensta"
_path_add_tool_bin	    "openvaf"
# _path_add_tool_custom   "osic-multitool"
# _path_add_tool_bin      "padring"
# _path_add_tool_bin      "pyopus"
# _path_add_tool_bin      "qflow"
# _path_add_tool_bin      "qucs-s"
# _path_add_tool_custom   "rftoolkit/bin"
# _path_add_tool_bin      "slang"
_path_add_tool_bin      "verilator"
_path_add_tool_bin      "xschem"
# _path_add_tool_bin      "xyce/Parallel"
_path_add_tool_bin      "yosys"
_path_add_tool_custom   "yosys/bin"


# ------------------
# SET PDK PARAMETERS
# ------------------

# Compile OSDI file if it doesn't exists
IHP_OPENVAF_DIR=$PDK_ROOT/ihp-sg13g2/libs.tech/ngspice/openvaf
if [ ! -f "$IHP_OPENVAF_DIR/psp103_nqs.osdi" ]; then
    echo "Compiling ihp-sg13g2 osdi files"
    openvaf $IHP_OPENVAF_DIR/psp103_nqs.va --output /tmp/psp103_nqs.osdi

    if [ $? -eq 0 ]; then
        echo "Compilation succeded"
        sudo mv /tmp/psp103_nqs.osdi $IHP_OPENVAF_DIR
    else
        echo "Compilation failed, reopen another terminal"
    fi
fi

set_pdk () {
    case "$1" in
    gf180mcuC) echo "gf180mcuC is not supported, only D variant" ;;
    gf180mcuD) export STD_CELL_LIBRARY=gf180mcu_fd_sc_mcu7t5v0 ;;
    sky130A)   export STD_CELL_LIBRARY=sky130_fd_sc_hd ;;
    ihp-sg13g2)    export STD_CELL_LIBRARY=sg13g2_stdcell ;;
    *)         echo "PDK $PDK NOT RECOGNIZED" && return ;;
    esac

    export PDK=$1
    export PDKPATH=$PDK_ROOT/$PDK
    export SPICE_USERINIT_DIR=$PDK_ROOT/$PDK/libs.tech/ngspice
    export KLAYOUT_HOME=$PDK_ROOT/$PDK/libs.tech/klayout
    export KLAYOUT_PATH=$KLAYOUT_HOME:$(realpath $TOOLS/klayout/download)

    alias xschem='xschem --rcfile $PDK_ROOT/$PDK/libs.tech/xschem/xschemrc'
    alias xschemtcl='xschem --rcfile $PDK_ROOT/$PDK/libs.tech/xschem/xschemrc'
    alias magic='magic -rcfile $PDK_ROOT/$PDK/libs.tech/magic/*.magicrc'

    echo "PDK set to $PDK"
}

if [ "$PDK" == "" ]; then
    echo "PDK not defined, using default one"
    set_pdk sky130A
else
    set_pdk $PDK
fi


# ------------------
# SET PROMPT
# ------------------

function git_branch {
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [ "$branch" != "" ]; then
      echo "[$branch]"
    fi
}

c_res='\[\033[00m\]'      # Reset
c_bla='\[\033[01;30m\]'   # Black
c_red='\[\033[01;31m\]'   # Red
c_gre='\[\033[01;32m\]'   # Green
c_yel='\[\033[01;33m\]'   # Yellow
c_blu='\[\033[01;34m\]'   # Blue
c_pur='\[\033[01;35m\]'   # Purple
c_cya='\[\033[01;36m\]'   # Cyan
c_whi='\[\033[01;37m\]'   # White

# export PS1="${c_pur}\w $(git_branch)\n${c_res}\$ " ## This dont work :(
PS1="${c_cya}\u ${c_pur}\w \n${c_res}\$ " ## This dont work :(
    

# --------------------------------
# USEFUL ENV VARIABLES AND ALIASES
# --------------------------------

alias ls="ls --color=auto -XF"
alias grep="grep --color=auto"

export USER=designer

export CMAKE_PACKAGE_ROOT_ARGS="$CMAKE_PACKAGE_ROOT_ARGS -D SWIG_ROOT=$TOOLS/common -D Eigen3_ROOT=$TOOLS/common -D GTest_ROOT=$TOOLS/common -D LEMON_ROOT=$TOOLS/common -D spdlog_ROOT=$TOOLS/common -D ortools_ROOT=$TOOLS/common"
export PATH="$TOOLS/common/bin:$PATH"
export LD_LIBRARY_PATH="$TOOLS/common/lib64:$TOOLS/common/lib:$LD_LIBRARY_PATH"

# ORFS Makefile overwrited variables
export ORFS_DIR=$TOOLS/OpenROAD-flow-scripts
export OPENROAD_EXE=openroad
export YOSYS_EXE=yosys
export YOSYS_CMD=yosys
export OPENSTA_EXE=sta
