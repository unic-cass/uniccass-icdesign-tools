# UNIC-CASS IC Design Tools

[![Release](https://img.shields.io/badge/Release-isaiassh%2Funic--cass--tools--1.0.3--nix-blue?style=flat-square&logo=docker)](https://hub.docker.com/r/isaiassh/unic-cass-tools/tags)
[![License: MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat-square)](LICENSE)
[![Issues](https://img.shields.io/github/issues/unic-cass/uniccass-icdesign-tools?style=flat-square&label=Issues&logo=github)](https://github.com/unic-cass/uniccass-icdesign-tools/issues)
[![Pull Requests](https://img.shields.io/github/issues-pr/unic-cass/uniccass-icdesign-tools?style=flat-square&label=PRs&logo=github)](https://github.com/unic-cass/uniccass-icdesign-tools/pulls)
[![Contributors](https://img.shields.io/github/contributors/unic-cass/uniccass-icdesign-tools?style=flat-square&label=Contributors&logo=github)](https://github.com/unic-cass/uniccass-icdesign-tools/graphs/contributors)
[![Docker Pulls](https://img.shields.io/docker/pulls/isaiassh/unic-cass-tools?style=flat-square&label=Pulls&logo=docker)](https://hub.docker.com/r/isaiassh/unic-cass-tools)

---

The UNIC-CASS IC Design Tools repository provides a comprehensive, open-source suite of tools for Integrated Circuit (IC) design, simulation, and verification. This project is part of the Universalization of IC Design from CASS (UNIC-CASS) program—a structured, end-to-end IC design-to-test experiential learning initiative.

This work is based on:

- [Johannes Kepler University (JKU) IIC-OSIC-TOOLS Docker Image](https://github.com/iic-jku/IIC-OSIC-TOOLS)
- [LibreLane ASIC Implementation Flow](https://github.com/librelane/librelane)
- GoCD NGSpice Agents for CICD VLSI Verification
- Open Source Integrated Circuits Docker Stacks

**New in v1.0.3**: This image now integrates **[LibreLane](https://github.com/librelane/librelane)** (v3.0.0.dev40), a modern ASIC implementation flow based on OpenROAD, Yosys, Magic, and Netgen. LibreLane provides a complete RTL-to-GDSII flow with support for IHP-sg13g2, Sky130, and GF180MCU PDKs, powered by the Nix package manager for reproducible builds.

We welcome contributions from the global IC design community!

---

## Supported Operating Systems

- **Linux** (recommended)
- **Windows** (via WSL 2)
- **macOS** (experimental, community support encouraged)

---

## How to Use

### Linux

1. **Clone the repository:**
   ```bash
   git clone https://github.com/unic-cass/uniccass-icdesign-tools.git
   cd uniccass-icdesign-tools
   ```

2. **Build and run the Docker environment:**
   ```bash
   make start
   ```

### Windows (with WSL 2)

1. **Install [WSL 2](https://docs.microsoft.com/en-us/windows/wsl/install) and Ubuntu from the Microsoft Store.**

2. **Install required tools:**
   
   **Git Installation:**
   ```powershell
   winget install --id Git.Git -e --source winget
   ```
   
   **Make Installation:**
   ```powershell
   winget install ezwinports.make
   ```

3. **Clone the repository inside your WSL environment:**
   ```bash
   git clone https://github.com/unic-cass/uniccass-icdesign-tools.git
   cd uniccass-icdesign-tools
   ```

4. **Build and run:**
   ```bash
   make start
   ```
   **Alternatively, you can use the provided `start.bat` script:**
   - Double-click `start.bat` in Windows Explorer, or
   - Run it from the command prompt:
     ```cmd
     start.bat
     ```

5. **XServer Installation for GUI tools:**
   
   Programs that use graphical user interfaces (xschem, magic, ngspice plots, klayout) require an X Server running on the host machine. Windows requires an external server.
   
   **Install VcXsrv:**
   - Download and install the [21.1.10 release](https://github.com/marchaesen/vcxsrv/releases/download/21.1.10/vcxsrv-64.21.1.10.0.installer.exe) from the [VcXsrv releases page](https://github.com/marchaesen/vcxsrv/releases/tag/21.1.10)
   - **Important:** Add the installation directory to your system `Path`:
     1. Open Control Panel and search for environment variables
     2. Select the option that modifies current account
     3. In **User Variables**, add the VcXsrv directory to the `Path` user variable
     4. Reopen each terminal to reload the path
   
   **Note:** We recommend version 21.1.10 as newer versions may have security concerns.

6. **Note:** Some tools may require additional configuration or may not be fully supported.

### macOS (experimental)

1. **Install [XQuartz](https://www.xquartz.org/) for GUI tools:**
   
   Programs that use graphical user interfaces (xschem, magic, ngspice plots, klayout) require an X Server running on the host machine. macOS requires an external server.

2. **Clone the repository:**
   ```bash
   git clone https://github.com/unic-cass/uniccass-icdesign-tools.git
   cd uniccass-icdesign-tools
   ```

3. **Build and run the Docker environment:**
   ```bash
   make start
   ```

4. **Note:** macOS support is experimental. Community support and contributions are encouraged.

---

## Installed Tools / PDKs

| Tool         | Description                                         | Source |
|--------------|-----------------------------------------------------|--------|
| **librelane** | Complete RTL-to-GDSII ASIC implementation flow     | Nix    |
| openroad     | Physical design platform (integrated with LibreLane)| Nix    |
| ngspice      | SPICE analog and mixed-signal simulator             | System |
| xschem       | Schematic Editor                                    | System |
| magic        | Layout editor with DRC/Extraction capabilities      | System |
| klayout      | Layout viewer and editor for GDS                    | Nix    |
| netgen       | Netlist Comparison                                  | System |
| yosys        | RTL synthesis framework                             | System |
| verilator    | Verilog simulator                                   | System |
| iverilog     | Icarus Verilog simulator                            | System |
| cvc          | Circuit validity checker                            | System |
| cace         | Circuit Characterization engine                     | System |
| gdsfactory   | Python module for GDS generation                    | System |
| glayout      | Python module for PDK-agnostic layout automation    | System |
| pygmid       | Python module for systematic circuit sizing         | System |
| openvaf      | Verilog-A to OSDI compiler                          | System |

### LibreLane Integration

[LibreLane](https://github.com/librelane/librelane) is available directly from the command line and provides:
- Complete RTL-to-GDSII automated flow
- Multi-PDK support (IHP-sg13g2, Sky130A, GF180MCU)
- Design exploration and optimization
- Integration with industry-standard EDA tools

**Quick start with LibreLane:**
```bash
librelane --help           # Show available options
librelane --smoke-test     # Run a quick verification test
librelane <config.json>    # Run a design flow
```

### PDK Management

The image contains the `sky130A`, `gf180mcuD`, and `ihp-sg13g2` PDKs. To change between PDKs, use the `set_pdk` command:

```bash
set_pdk ihp-sg13g2   # Default PDK
set_pdk sky130A
set_pdk gf180mcuD
```

The IHP PDK requires the compilation of OSDI files, which is performed automatically when starting a bash terminal. If the compilation fails, simply open another bash terminal.

Versions and commit references for all tools and PDKs are specified in the `Dockerfile`.

---

## Additional Details

- **LibreLane Documentation:**  
  Visit the [official LibreLane documentation](https://librelane.readthedocs.io) for detailed guides on running ASIC flows, configuring designs, and using advanced features.
  
- **Nix Package Manager:**  
  The image uses [Nix](https://nixos.org) for reproducible package management. You can install additional tools using `nix profile install nixpkgs#<package>` or create temporary environments with `nix-shell -p <package>`.

- **Tool Documentation:**  
  Each tool directory contains specific documentation and usage instructions. For LibreLane-specific workflows, refer to the [LibreLane GitHub repository](https://github.com/librelane/librelane).

- **Community & Support:**  
  - For general issues: [GitHub Issues](https://github.com/unic-cass/uniccass-icdesign-tools/issues)
  - For LibreLane-specific questions: [FOSSi Chat Matrix Server](https://matrix.to/#/#openlane:fossi-foundation.org)

- **License:**  
  This project is licensed under the [MIT License](LICENSE). LibreLane is licensed under [Apache License 2.0](https://github.com/librelane/librelane/blob/main/License).

