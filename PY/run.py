from __future__ import annotations

import subprocess
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parent.parent
TCL_EXE = PROJECT_ROOT / "openseeschuckv2"
TCL_SCRIPT = PROJECT_ROOT / "TCL" / "4.analysis.tcl"
PYTHON_EXE = Path(r"C:\Users\Ptilopsis\miniconda3\python.exe")
PLOT_SCRIPT = PROJECT_ROOT / "PY" / "plot_global_hysteresis_comparison.py"


def run_command(command: list[str], *, cwd: Path) -> None:
	print("Running:", " ".join(command))
	subprocess.run(command, cwd=cwd, check=True)




def main(case_name: str, targetYieldForce: float) -> None:
	run_command([str(TCL_EXE), str(TCL_SCRIPT), case_name, str(targetYieldForce)], cwd=PROJECT_ROOT)
	run_command([str(PYTHON_EXE), str(PLOT_SCRIPT), case_name], cwd=PROJECT_ROOT)


if __name__ == "__main__":
	CASE_NAMES = ['bflp', 'lpsc','tsc', 'brb', 'csc']
	targetYieldForce = 700e3
	for case_name in CASE_NAMES:
		main(case_name, targetYieldForce)