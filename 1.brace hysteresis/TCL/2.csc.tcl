source [file join [file dirname [file normalize [info script]]] "1.frame.tcl"]

# brace material; assume area = 1
# 10.14006/j.jzjgxb.2024.0207 Table 3
set fy 288.0
set ES 208000.0
set k1Factor 3
set fuPT 1945.0
set EPT 99000.0
# 10.1002/eqe.3463 Section 4.3
set driftAtFuse 0.02
set lambdaF 0.03
set lambdaD 1.15
set PTRatio 0.75

set ptLength [expr {$PTRatio * $braceLength}]
set euPT [expr {$fuPT / $EPT}]
set Fpre [expr {(1 + $lambdaF) / 2.0 * $targetYieldForce}]

set k1 [expr {$k1Factor * $ES * $targetYieldForce / $fy}]

# set dFuse [expr {$driftAtFuse * $h * cos($braceAngle)} * ($braceLength / $diagonalLength)]
set dFuse [expr {$driftAtFuse * $h * cos($braceAngle)}]
set eSlip [expr {$dFuse / $braceLength}]
set Dk2 [expr {$euPT * $PTRatio - $lambdaD * $dFuse / $braceLength}]
set k2 [expr {$Fpre / $Dk2}]

# set ptArea [expr {$k2 * $PTRatio / $EPT}]
# set ptInitialStress [expr {$Fpre / $ptArea / $EPT}]

set area 1.0

uniaxialMaterial SelfCentering 30010 $k1 $k2 $targetYieldForce [expr {1-$lambdaF}] $eSlip

puts "csc.tcl loaded"
