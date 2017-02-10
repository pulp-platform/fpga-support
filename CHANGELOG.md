# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/), and this project adheres to
[Semantic Versioning](http://semver.org).

## [v0.1.1] - 2017-02-10

### Fixed

- `BramDwc`: address registering.  The address can now be changed between clock edges and the output
  will still correspond to the address applied at the former clock edge.

- `BramDwc`: compatibility of interface port declarations with synthesis tools.  Interface ports are
  now explicitly declared either as `Master` or as `Slave`, so that synthesis tools will not infer
  `inout` connections.

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

[v0.1.1]: https://iis-git.ee.ethz.ch/pulp-project/fpga-support/compare/v0.1.0...v0.1.1
