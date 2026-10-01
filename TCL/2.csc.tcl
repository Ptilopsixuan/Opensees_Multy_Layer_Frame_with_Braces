set targetYieldForce 1000000.0
# =================================================
source [file join [file dirname [file normalize [info script]]] "1.frame.tcl"]

# brace material; assume area = 1
set cscfy 288.0
set cscElasticModulus 208000.0
set csck1Factor 3
set cscPTfu 1945.0
set cscPTElasticModulus 99000.0
set cscDriftAtFuse 0.02
set lambdaF 0.03
set lambdaD 1.15
set ptRatio 0.75

set ptLength [expr {$ptRatio * $braceLength}]
set ptLimitStrain [expr {$cscPTfu / $cscPTElasticModulus}]
set Fpre [expr {(1 + $lambdaF) / 2.0 * $targetYieldForce}]

set k1 [expr {$csck1Factor * $cscElasticModulus * $targetYieldForce / $cscfy}]

set dFuse [expr {$cscDriftAtFuse * $h * cos($braceAngle)} * ($braceLength / $diagonalLength)]
set epsSlip [expr {$dFuse / $braceLength}]
set Dk2 [expr {$ptLimitStrain * $ptRatio - $lambdaD * $dFuse / $braceLength}]
set k2 [expr {$Fpre / $Dk2}]

# set ptArea [expr {$k2 * $ptRatio / $cscPTElasticModulus}]
# set ptInitialStress [expr {$Fpre / $ptArea / $cscPTElasticModulus}]

set area 1.0

uniaxialMaterial SelfCentering 30010 $k1 $k2 $targetYieldForce [expr {1-$lambdaF}] $epsSlip

puts "csc.tcl loaded"
