# test_ci.py  ← only for GitHub Actions
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def ci_basic_check(dut):
    clock = Clock(dut.clk, 100, unit="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 20)
    dut.rst_n.value = 1

    # Enable flavor 0 + short wait
    dut.ui_in.value = 0b0000_0001   # global_en + f_sel=00
    await ClockCycles(dut.clk, 5000)  # ~0.5 ms, fast

    # Minimal check: counter advanced at all?
    snapshot = 0
    for bsel in range(3):
        dut.ui_in.value = (dut.ui_in.value.to_unsigned() & 0b111_11001) | (bsel << 3)
        await ClockCycles(dut.clk, 2)
        byte_val = dut.uo_out.value.to_unsigned()
        snapshot |= byte_val << (bsel * 8)

    assert snapshot > 0, "Counter did not increment – oscillator or logic issue"
    dut._log.info(f"CI check OK – snapshot = {snapshot}")
    
