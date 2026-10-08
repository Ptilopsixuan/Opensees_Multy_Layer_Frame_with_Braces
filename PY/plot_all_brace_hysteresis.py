from __future__ import annotations

import sys
from pathlib import Path

import matplotlib.pyplot as plt

sys.dont_write_bytecode = True

from plot_global_hysteresis_comparison import OUTPUT_ROOT, load_brace_history


DEFAULT_CASE_NAMES = ("brb", "csc", "tsc", "lpsc", "bflp")
OUTPUT_PATH = OUTPUT_ROOT / "brace_hysteresis_comparison.png"


def net_diagonal_length() -> float:
    h = 5490.0
    w = 9140.0
    diagonal_length = (h**2 + w**2) ** 0.5
    return diagonal_length - 2.0 * 400.0


def only_history(case_name: str) -> list[tuple[float, float]]:
    histories = load_brace_history(case_name)
    if len(histories) != 1:
        tags = ", ".join(sorted(histories))
        raise ValueError(f"{case_name} has multiple brace histories: {tags}")
    return next(iter(histories.values()))


def plot_all_braces(case_names: tuple[str, ...]) -> Path:
    brace_length = net_diagonal_length()

    fig, ax = plt.subplots(figsize=(7.5, 5.2), constrained_layout=True)
    colors = ("#2b6cb0", "#c23b22", "#2f855a", "#805ad5", "#d69e2e")

    for index, case_name in enumerate(case_names):
        history = only_history(case_name)
        strain_percent = [deformation_mm / brace_length * 100.0 for deformation_mm, _ in history]
        force_kn = [force_kn for _, force_kn in history]
        ax.plot(
            strain_percent[:],
            force_kn[:],
            color=colors[index % len(colors)],
            linewidth=0.5,
            label=case_name.upper(),
        )

    ax.axhline(0.0, color="#888888", linewidth=0.8)
    ax.axvline(0.0, color="#888888", linewidth=0.8)
    ax.set_xlabel("Brace axial strain (%)")
    ax.set_ylabel("Brace axial force (kN)")
    ax.set_title("Brace hysteresis comparison")
    ax.grid(True, color="#dddddd", linewidth=0.6)
    ax.legend(frameon=False)

    fig.savefig(OUTPUT_PATH, dpi=180)
    plt.close(fig)
    return OUTPUT_PATH


if __name__ == "__main__":
    case_names = tuple(sys.argv[1:]) or DEFAULT_CASE_NAMES
    saved_path = plot_all_braces(case_names)
    print(f"Saved brace hysteresis comparison figure to {saved_path}")
