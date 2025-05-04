# 512-bit FPGA Arithmetic System

## Overview

This project was developed for the KU Leuven Digital Design Complex course.
The system implements 512-bit addition and comparison operations on a Pynq-Z2 FPGA, comparing performance characteristics of various adder architectures (Ripple Carry, Carry Look-Ahead, Carry Bypass, and Carry Save). We freely choose which adders and features we wanted to implement.

## How It Works

The system uses UART communication to receive operation mode and operands, then performs the requested calculation:

1. **Mode Selection**: First 64 bytes determine operation (0xFF = addition, 0x00 = comparison)
2. **Operand Input**: Two 512-bit operands are received sequentially
3. **Processing**: Selected operation is performed using configurable adder architecture
4. **Result**: 65-byte result (512 bits + carry/comparison bit) is returned via UART

The comparison function checks if two 512-bit numbers are equal, returning a 1-bit result indicating equality. The multi-precision adder processes operands in configurable bit-width chunks.

## Files

- `mp_adder.v` - Multi-precision adder core
- `mp_CMP.v` - Multi-precision comparator
- `uart_top.v` - System controller with UART interface
- `uart_tx.v`, `uart_rx.v` - UART modules
- `cla/cba/csa_adder_Nb.v` - Parameterized adder implementations
- `test_script.py` - Python testing 
