# Approx-T: Design Methodology for Approximate Multiplication Units via Taylor-Expansion

This repository contains the source code and related files for the Approx-T methodology. Below is the directory structure and its contents:

## Directory Structure

### `/rtl`
The `/rtl` directory contains the Approx-T HDL source code, which includes:
- **Unsigned Integer Multiplication**
  - `Approx_T`
  - `leading_one_detector`
  - `bit_mask_sel`

- **Floating-Point Multiplication**
  - `Approx_T`

### `/tb`
The `/tb` directory contains the corresponding RTL testbenches for the Approx-T implementations.

### `/model`
The `/model` directory contains the Approx-T error model.

### `/fpga`
The `/fpga` directory contains:
- Bitstreams and test files for FPGA implementation.
- All designs are based on the **PYNQ framework** and use the **Ultra96v2 FPGA**.
