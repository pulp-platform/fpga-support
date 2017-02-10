# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/), and this project adheres to
[Semantic Versioning](http://semver.org).

## v0.1.0 - 2016-11-14

### Added

- Three Block RAM (BRAM)-related modules:
  - `BramPort`: the standard interface for Xilinx BRAMs,
  - `TdpBramArray`: an array of Xilinx True Dual-Port BRAM cells with a standard BRAM interface, and
  - `BramDwc`: a Data Width Converter from a narrow master BRAM controller to a wide slave BRAM
    (array).

- `BramLogger`: a logger that writes events to a `TdpBramArray`.

- `AxiBramLogger`: a logger to keep track of events on an AXI bus.  This module is build on
  `BramLogger`.
