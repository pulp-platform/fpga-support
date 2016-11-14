# Changelog

## v0.1.0   (2016-11-14)

- Initial public release of three Block RAM (BRAM)-related modules:
  - `BramPort`: the standard interface for Xilinx BRAMs,
  - `TdpBramArray`: an array of Xilinx True Dual-Port BRAM cells with a standard BRAM interface, and
  - `BramDwc`: a Data Width Converter from a narrow master BRAM controller to a wide slave BRAM
    (array).

- Initial public release of the general-purpose `BramLogger` and the `AxiBramLogger` specifically
  for logging events on an AXI bus.  (`AxiBramLogger` is built on `BramLogger`.)
