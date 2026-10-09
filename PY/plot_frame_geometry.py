from __future__ import annotations

import math
from pathlib import Path

import matplotlib.pyplot as plt

# KIND = "bflp"
KIND = "brb"
CURRENT_DIR = Path(__file__).resolve().parent.parent
OUTPUT_DIR = CURRENT_DIR / "output" / KIND


def build_model_geometry() -> tuple[dict[int, tuple[float, float]], list[tuple[str, int, int, str, float]]]:
    # Keep these values consistent with 1.frame.tcl.
    frame_height = 5490.0
    frame_width = 9140.0
    rigid_length = 400.0

    p = rigid_length
    h = frame_height
    w = frame_width
    brace_angle = math.atan2(h, w)

    nodes = {
        101: (0.0, 0.0),
        102: (0.0, p),
        103: (0.0, h - p),
        104: (0.0, h),
        105: (w, 0.0),
        106: (w, p),
        107: (w, h - p),
        108: (w, h),
        201: (p, h),
        202: (w - p, h),
        301: (p * math.cos(brace_angle), p * math.sin(brace_angle)),
        302: (w - p * math.cos(brace_angle), h - p * math.sin(brace_angle)),
    }

    elements = [
        ("1001", 101, 102, "#777777", 2.0),
        ("1002", 102, 103, "#777777", 2.0),
        ("1003", 103, 104, "#777777", 2.0),
        ("1004", 105, 106, "#777777", 2.0),
        ("1005", 106, 107, "#777777", 2.0),
        ("1006", 107, 108, "#777777", 2.0),
        ("2001", 104, 201, "#555555", 2.0),
        ("2002", 201, 202, "#555555", 2.0),
        ("2003", 202, 108, "#555555", 2.0),
        ("3001", 101, 301, "#2b6cb0", 3.0),
        ("3002", 301, 302, "#c23b22", 3.0),
        ("3003", 302, 108, "#2b6cb0", 3.0),
    ]

    if KIND == "bflp":
        nodes.update({
            303: (p * math.cos(brace_angle), h - p * math.sin(brace_angle)),
            304: (w - p * math.cos(brace_angle), p * math.sin(brace_angle)),
        })
        elements.extend([
            ("3004", 105, 304, "#2b6cb0", 3.0),
            ("3005", 304, 303, "#c23b22", 3.0),
            ("3006", 303, 104, "#2b6cb0", 3.0),
        ])

    return nodes, elements


def plot_frame_geometry() -> Path:
    nodes, elements = build_model_geometry()
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    fig, ax = plt.subplots(figsize=(8, 5), constrained_layout=True)

    for element_tag, node_i, node_j, color, linewidth in elements:
        xi, yi = nodes[node_i]
        xj, yj = nodes[node_j]
        ax.plot([xi, xj], [yi, yj], color=color, linewidth=linewidth)
        ax.text(
            (xi + xj) / 2.0,
            (yi + yj) / 2.0,
            element_tag,
            color=color,
            fontsize=9,
            ha="center",
            va="center",
        )

    for node_tag, (x_coord, y_coord) in nodes.items():
        ax.scatter([x_coord], [y_coord], s=30, color="black", zorder=3)
        ax.text(x_coord + 60.0, y_coord + 60.0, str(node_tag), fontsize=8)

    ax.set_aspect("equal", adjustable="box")
    ax.set_xlabel("x (mm)")
    ax.set_ylabel("y (mm)")
    ax.set_title("Frame Geometry")
    ax.grid(True, color="#dddddd", linewidth=0.6)

    output_path = OUTPUT_DIR / "frame_geometry.png"
    fig.savefig(output_path, dpi=180)
    plt.close(fig)
    return output_path


if __name__ == "__main__":
    saved_path = plot_frame_geometry()
    print(f"Saved frame geometry figure to {saved_path}")
