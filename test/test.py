# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 0

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    dut.kypd_rows.value = 7

    await ClockCycles(dut.clk, 1000000)

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 100)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    
    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
