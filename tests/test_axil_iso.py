"""Isolated AXI-Lite reset regression; intentionally independent of model-only test dependencies."""
import subprocess

import pytest


def test_axil_iso_resets_apart():
    """Check reset isolation and demonstrate the bypass failure with deterministic random seeds."""
    from opentpu import rtlsim

    for bypass in (0, 1):
        exe = rtlsim.build(
            "tb_axil_iso",
            [rtlsim.RTL / "shell/otpu_ctrl.sv", rtlsim.TB / "tb_axil_iso.sv"],
            {"BYPASS": bypass},
        )
        for seed in (1, 2):
            result = subprocess.run(
                [str(exe), f"+seed={seed}", "+mrst=300", "+slvrst=60", "+cycles=400000"],
                capture_output=True,
                text=True,
                timeout=120,
            )
            if bypass:
                assert "FAIL" in result.stdout and "did not ask for" in result.stdout, result.stdout[-2000:]
            else:
                assert "PASS" in result.stdout, result.stdout[-2000:]
