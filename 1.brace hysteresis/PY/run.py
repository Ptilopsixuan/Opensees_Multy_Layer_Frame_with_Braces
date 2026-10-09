from __future__ import annotations

import subprocess
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
TCL_EXE = PROJECT_ROOT / "openseeschuckv2"
BRACE_HYSTERESIS_DIR = PROJECT_ROOT / "1.brace hysteresis"
TCL_SCRIPT = BRACE_HYSTERESIS_DIR / "TCL" / "4.analysis.tcl"
PYTHON_EXE = Path(r"C:\Users\Ptilopsis\miniconda3\python.exe")
PLOT_SCRIPT = BRACE_HYSTERESIS_DIR / "PY" / "plot_global_hysteresis_comparison.py"
PLOT_ALL_SCRIPT = BRACE_HYSTERESIS_DIR / "PY" / "plot_all_brace_hysteresis.py"

def run_command(command: list[str], *, cwd: Path) -> None:
	print("Running:", " ".join(command))
	subprocess.run(command, cwd=cwd, check=True)


def main(case_name: str, targetYieldForce: float) -> None:
	run_command([str(TCL_EXE), str(TCL_SCRIPT), case_name, str(targetYieldForce)], cwd=PROJECT_ROOT)
	run_command([str(PYTHON_EXE), str(PLOT_SCRIPT), case_name], cwd=PROJECT_ROOT)
	

if __name__ == "__main__":
	CASE_NAMES = ['brb', 'csc', 'tsc','lpsc' ,'bflp']
	targetYieldForce = 700e3
	for case_name in CASE_NAMES:
		main(case_name, targetYieldForce)
	run_command([str(PYTHON_EXE), str(PLOT_ALL_SCRIPT)], cwd=PROJECT_ROOT)