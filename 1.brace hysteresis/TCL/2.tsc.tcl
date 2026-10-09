source [file join [file dirname [file normalize [info script]]] "1.frame.tcl"]

# brace material; assume area = 1
# 10.14006/j.jzjgxb.2024.0207 Table 3
set fy 288.0
set ES 208000.0
set k1Factor 3.0
set fuPT 1945.0
set EPT 99000.0
# 10.1002/eqe.3463 Section 4.4
set DriftAtFrac 0.045
set lambdaF 0.03
set PTRatio 0.75

set ptLength [expr {$PTRatio * $braceLength}]
set euPT [expr {$fuPT / $EPT}]
set Fpre [expr {(1 + $lambdaF) / 2.0 * $targetYieldForce}]
set Ffri [expr {(1 - $lambdaF) / 2.0 * $targetYieldForce}]

set k1 [expr {$k1Factor * $ES * $targetYieldForce / $fy}]

set dFrac [expr {$DriftAtFrac * $h * cos($braceAngle)}]
set Dk2 [expr {2.0 * $euPT * $PTRatio - $dFrac / $braceLength}]
set k2 [expr {$Fpre / $Dk2}]

set ptArea [expr {$k2 * $PTRatio / $EPT}]
set ePTInit [expr {$Fpre / $ptArea / $EPT / 2.0}]
set eyS [expr {$targetYieldForce / $k1}]
set eFracture [expr {($euPT - $ePTInit) * 2.0 * $ptLength / $braceLength}]
set FPTMax [expr {$Fpre + (0.1 - $eyS) * $k2}]

set ptStrains [list [expr {-0.1}] [expr {-$eyS}] 0.0 [expr {$eyS}] 0.1]
set ptStresses [list [expr {-$FPTMax}] [expr {-$Fpre}] 0.0 $Fpre $FPTMax]

uniaxialMaterial ElasticMultiLinear 30011 -strain {*}$ptStrains -stress {*}$ptStresses
uniaxialMaterial MinMax 30012 30011 -min [expr {-$eFracture}] -max $eFracture
uniaxialMaterial ElasticPP 30013 [expr {$Ffri / $eyS}] $eyS
uniaxialMaterial Parallel 30010 30012 30013

set area 1.0

puts "tsc.tcl loaded"