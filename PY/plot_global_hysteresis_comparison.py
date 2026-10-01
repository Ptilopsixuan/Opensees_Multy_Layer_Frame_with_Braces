from __future__ import annotations

import csv
from collections import defaultdict
from pathlib import Path

import matplotlib.pyplot as plt


CURRENT_DIR = Path(__file__).resolve().parent.parent
OUTPUT_ROOT = CURRENT_DIR / "output"

CASE_NAME = "csc"
CASE_LABEL = "CSC"


def load_brace_history(case_name: str) -> dict[str, list[tuple[float, float]]]:
    csv_path = OUTPUT_ROOT / case_name / "brace_force_displacement.csv"
    if not csv_path.exists():
        raise FileNotFoundError(f"Missing result file: {csv_path}")

    histories: dict[str, list[tuple[float, float]]] = defaultdict(list)
    with csv_path.open(newline="", encoding="utf-8") as csv_file:
        reader = csv.DictReader(csv_file)
        required_columns = {"brace_tag", "brace_deformation_mm", "brace_force_N"}
        missing_columns = required_columns - set(reader.fieldnames or [])
        if missing_columns:
            missing = ", ".join(sorted(missing_columns))
            raise ValueError(f"Missing column(s) in {csv_path}: {missing}")

        for row in reader:
            brace_tag = row["brace_tag"].strip()
            deformation_mm = float(row["brace_deformation_mm"])
            force_kn = float(row["brace_force_N"]) / 1000.0
            histories[brace_tag].append((deformation_mm, force_kn))

    if not histories:
        raise ValueError(f"No brace history rows found in {csv_path}")
    return histories


def plot_brace_hysteresis(brace_length: float, transfer_factor: float) -> Path:
    histories = load_brace_history(CASE_NAME)

    fig, ax = plt.subplots(figsize=(7, 5), constrained_layout=True)
    colors = ("#2b6cb0", "#c23b22", "#2f855a", "#805ad5")

    for index, (brace_tag, history) in enumerate(sorted(histories.items())):
        deformation_mm = [point[0] * transfer_factor / brace_length * 100 for point in history]
        force_kn = [point[1] for point in history]
        label = f"{CASE_LABEL} brace {brace_tag}"
        ax.plot(
            deformation_mm,
            force_kn,
            color=colors[index % len(colors)],
            linewidth=1.15,
            label=label,
        )

    ax.axhline(0.0, color="#888888", linewidth=0.8)
    ax.axvline(0.0, color="#888888", linewidth=0.8)
    ax.set_xlabel("Brace axial strain (%)")
    ax.set_ylabel("Brace axial force (kN)")
    ax.set_title("Brace hysteresis")
    ax.grid(True, color="#dddddd", linewidth=0.6)
    ax.legend(frameon=False)

    output_path = OUTPUT_ROOT / CASE_NAME / "brace_hysteresis.png"
    fig.savefig(output_path, dpi=180)
    plt.close(fig)
    return output_path


if __name__ == "__main__":
    h = 5490
    w = 9140
    diagonal_length = (h**2 + w**2) ** 0.5
    net_diagonal_length = diagonal_length - 2.0 * 400.0
    model_ratio = net_diagonal_length / diagonal_length
    brace_ratio = 0.85
    brace_length = diagonal_length * brace_ratio
    transfer_factor = brace_ratio / model_ratio
    # transfer_factor = 1
    saved_path = plot_brace_hysteresis(brace_length, transfer_factor)
    print(f"Saved brace hysteresis figure to {saved_path}")
