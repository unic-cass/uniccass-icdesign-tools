# UNIC-CASS IC Design Tools

[![Latest Release](https://img.shields.io/docker/v/isaiassh/unic-cass-tools/0.1.2?style=for-the-badge)](https://hub.docker.com/r/isaiassh/unic-cass-tools/tags)
[![License](https://img.shields.io/github/license/unic-cass/uniccass-icdesign-tools?style=for-the-badge)](LICENSE)
[![Issues](https://img.shields.io/github/issues/unic-cass/uniccass-icdesign-tools?style=for-the-badge)](https://github.com/unic-cass/uniccass-icdesign-tools/issues)
[![Pull Requests](https://img.shields.io/github/issues-pr/unic-cass/uniccass-icdesign-tools?style=for-the-badge)](https://github.com/unic-cass/uniccass-icdesign-tools/pulls)
[![Contributors](https://img.shields.io/github/contributors/unic-cass/uniccass-icdesign-tools?style=for-the-badge)](https://github.com/unic-cass/uniccass-icdesign-tools/graphs/contributors)


---

The UNIC-CASS IC Design Tools repository provides a comprehensive, open-source suite of tools for Integrated Circuit (IC) design, simulation, and verification. This project is part of the Universalization of IC Design from CASS (UNIC-CASS) program—a structured, end-to-end IC design-to-test experiential learning initiative.

We welcome contributions from the global IC design community!

---

## Supported Operating Systems

- **Linux** (recommended)
- **Windows** (via WSL)
- **macOS** (experimental, community support encouraged)

---

## Prerequisites

- **Git** (for cloning the repository)
- **Docker** (for containerized tool environments)
- **Python 3.7+** (for scripting and automation)
- **WSL 2** (for Windows users, recommended)

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
2. **Clone the repository inside your WSL environment:**
   ```bash
   git clone https://github.com/unic-cass/uniccass-icdesign-tools.git
   cd uniccass-icdesign-tools
   ```

3. **Build and run:**
   ```bash
   make start
   ```
   **Alternatively, you can use the provided `start.bat` script:**
   - Double-click `start.bat` in Windows Explorer, or
   - Run it from the command prompt:
     ```cmd
     start.bat
     ```

4. **For GUI tools, use [VcXsrv](https://sourceforge.net/projects/vcxsrv/) or similar X server.**

### macOS

1. **Clone the repository:**
   ```bash
   git clone https://github.com/unic-cass/uniccass-icdesign-tools.git
   cd uniccass-icdesign-tools
   ```

2. **Install Docker Desktop for Mac.**
3. **Build and run:**
   ```bash
   make
   ```

4. **Note:** Some tools may require additional configuration or may not be fully supported.

---

## Installed Tools / PDKs

| Tool         | Description                                         |
|--------------|-----------------------------------------------------|
| ngspice      | SPICE analog and mixed-signal simulator             |
| xschem       | Schematic Editor                                    |
| magic        | Layout editor with DRC/Extraction capabilities      |
| klayout      | Layout viewer and editor for GDS                    |
| netgen       | Netlist Comparison                                  |
| cvc          | Circuit validity checker                            |
| cace         | Circuit Characterization engine                     |
| gdsfactory   | Python module for GDS generation                    |
| glayout      | Python module for PDK-agnostic layout automation    |
| pygmid       | Python module for systematic circuit sizing         |
| openvaf      | Verilog-A to OSDI compiler                          |

The image also contains the `sky130A`, `gf180mcuD`, and `ihp-sg13g2` PDKs. To change between PDKs, use the `set_pdk` command, e.g., `set_pdk sky130A`. The IHP PDK requires the compilation of OSDI files, which is performed when starting a bash terminal. If the compilation fails, simply open another bash terminal.

Versions and commit references for all tools and PDKs are specified in the `Dockerfile`.

---

## Additional Details

- **Documentation:**  
  Each tool directory contains specific documentation and usage instructions.
- **Community & Support:**  
  Please use [GitHub Issues](https://github.com/unic-cass/uniccass-icdesign-tools/issues) for questions, bug reports, or feature requests.
- **Contributing:**  
  We welcome contributions! Please read our [CONTRIBUTING.md](CONTRIBUTING.md) (to be created) for guidelines.
- **License:**  
  This project is licensed under the [MIT License](LICENSE).

