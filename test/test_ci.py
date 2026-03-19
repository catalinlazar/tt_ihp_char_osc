# test_ci.py  ← only for GitHub Actions
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_fast(dut):
    clock = Clock(dut.clk, 100, unit="ns")
    cocotb.start_soon(clock.start())
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 20)
    dut.rst_n.value = 1

    # Quick functional check — only 2000 cycles instead of 100k
    dut.ui_in.value = 0b0000_0001  # flavor 0 + enable
    await ClockCycles(dut.clk, 2500)

    # Just check that counter moved at all
    assert dut.uo_out.value.to_unsigned() != 0, "Counter is dead"
