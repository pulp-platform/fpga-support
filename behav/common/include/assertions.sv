/**
 * Assertions for Actual/Expected Comparisons in Testbenches
 *
 * Copyright (c) 2016 ETH Zurich and University of Bologna.  All rights reserved.
 *
 * Current Maintainers:
 * - Andreas Kurth  <akurth@iis.ee.ethz.ch>
 * - Pirmin Vogel   <vogelpi@iis.ee.ethz.ch>
 */

`ifndef ASSERTIONS_SV
`define ASSERTIONS_SV

`define assert_equal(actual, expected) \
  assert (actual == expected) \
    else $error("Failed assertion: %0d == %0d", actual, expected);

`define assert_equal_msg(actual, expected, msg, ln) \
  assert (actual == expected) \
    else $error("Failed assertion (ExpResp LN %04d, %s): %x == %x", \
        ln, msg, actual, expected);

`endif // ASSERTIONS_SV

// vim: nosmartindent autoindent
