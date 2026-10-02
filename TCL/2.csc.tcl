source [file join [file dirname [file normalize [info script]]] "1.frame.tcl"]

# brace material; assume area = 1
# 10.14006/j.jzjgxb.2024.0207 Table 3
set cscfy 288.0
set cscElasticModulus 208000.0
set csck1Factor 3
set cscPTfu 1945.0
set cscPTElasticModulus 99000.0
# 10.1002/eqe.3463 Section 4.3
set cscDriftAtFuse 0.02
set csclambdaF 0.03
set csclambdaD 1.15
set cscPTRatio 0.75

set ptLength [expr {$cscPTRatio * $braceLength}]
set ptLimitStrain [expr {$cscPTfu / $cscPTElasticModulus}]
set Fpre [expr {(1 + $csclambdaF) / 2.0 * $targetYieldForce}]

set k1 [expr {$csck1Factor * $cscElasticModulus * $targetYieldForce / $cscfy}]

# set dFuse [expr {$cscDriftAtFuse * $h * cos($braceAngle)} * ($braceLength / $diagonalLength)]
set dFuse [expr {$cscDriftAtFuse * $h * cos($braceAngle)}]
set epsSlip [expr {$dFuse / $braceLength}]
set Dk2 [expr {$ptLimitStrain * $cscPTRatio - $csclambdaD * $dFuse / $braceLength}]
set k2 [expr {$Fpre / $Dk2}]

# set ptArea [expr {$k2 * $cscPTRatio / $cscPTElasticModulus}]
# set ptInitialStress [expr {$Fpre / $ptArea / $cscPTElasticModulus}]

set area 1.0

uniaxialMaterial SelfCentering 30010 $k1 $k2 $targetYieldForce [expr {1-$csclambdaF}] $epsSlip

puts "csc.tcl loaded"
