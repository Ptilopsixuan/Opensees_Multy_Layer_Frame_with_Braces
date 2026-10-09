# README

- This project uses Opensees to analyze the hysteresis behavior of different kinds of braces (including brb, csc, tsc, lpsc, and bflp) in a frame structural system.

## 1.brace hysteresis

- This folder is for making sure that the hysteresis behavior of different kinds of braces is typical. Just need to run the run.py in the PY folder.

- The cmd file contains the command for running the TCL script one time, just ignore this file.

### TCL

- The TCL folder contains the TCL scripts for building the frame model, making the different braces and running the analysis.

### PY

- Only run.py need to be run. It will run the TCL script and then run the Python scripts for plotting the hysteresis curves of different braces and comparing them.

- The PY folder contains the Python scripts for plotting the hysteresis curves of different braces and comparing them.

- Specially, plot_frame_geometry.py is for plotting the frame geometry, because of bflp brace is a little different from the other braces, which have to be set crossed.

## OpenSeesChuckv2

- This .exe is specialized for running the lpsc brace for its 'LPSCED' material. If don't use this version, lpsc brace won't work. (This is also the reason why I don't continue to use the OpenSeesPy, because it doesn't support this material.)
