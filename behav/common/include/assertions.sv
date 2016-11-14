/**
 * Assertions for Actual/Expected Comparisons in Testbenches
 *
 * Copyright (c) 2016 Integrated Systems Laboratory, ETH Zurich.  This is free software under the
 * terms of the GNU General Public License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.  This software is distributed
 * without any warranty; without even the implied warranty of merchantability or fitness for
 * a particular purpose.
 *
 * Current Maintainers:
 * - Andreas Kurth  <andkurt@ee.ethz.ch>
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

// vim: ts=2 sw=2 sts=2 et nosmartindent autoindent tw=100
