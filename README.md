# README

- This project uses Opensees to analyze the hysteresis behavior of different kinds of braces (including brb, csc, tsc, lpsc, and bflp) in a frame structural system.

- parameters reference: [周颖, 肖意, 顾安琪. 自复位支撑-摇摆框架结构体系及其基于位移抗震设计方法](https://doi.org/10.14006/j.jzjgxb.2019.0070)
- csc & tsc reference: [Xiao, Eberhard, Zhou. Proportioning of self-centering energy dissipative braces](https://doi.org/10.1002/eqe.3463)
- lpsc reference: [Xiao, Eberhard, Zhou. Low-prestressing, self-centering energy dissipative brace](https://doi.org/10.1002/eqe.3704)

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
