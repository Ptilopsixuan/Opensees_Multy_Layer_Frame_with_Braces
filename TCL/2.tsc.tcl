source [file join [file dirname [file normalize [info script]]] "1.frame.tcl"]

# brace material; assume area = 1
# 10.14006/j.jzjgxb.2024.0207 Table 3
set tscfy 288.0
set tscElasticModulus 208000.0
set tsck1Factor 3.0
set tscPTfu 1945.0
set tscPTElasticModulus 99000.0
# 10.1002/eqe.3463 Section 4.4
set tscDriftAtFrac 0.045
set tscLambdaF 0.03
set tscPTRatio 0.75

set ptLength [expr {$tscPTRatio * $braceLength}]
set ptLimitStrain [expr {$tscPTfu / $tscPTElasticModulus}]
set Fpre [expr {(1 + $tscLambdaF) / 2.0 * $targetYieldForce}]
set Ffri [expr {(1 - $tscLambdaF) / 2.0 * $targetYieldForce}]

set k1 [expr {$tsck1Factor * $tscElasticModulus * $targetYieldForce / $tscfy}]

set dFrac [expr {$tscDriftAtFrac * $h * cos($braceAngle)}]
set Dk2 [expr {2.0 * $ptLimitStrain * $tscPTRatio - $dFrac / $braceLength}]
set k2 [expr {$Fpre / $Dk2}]

set ptArea [expr {$k2 * $tscPTRatio / $tscPTElasticModulus}]
set ePTInit [expr {$Fpre / $ptArea / $tscPTElasticModulus / 2.0}]
set eY [expr {$targetYieldForce / $k1}]
set eFracture [expr {($ptLimitStrain - $ePTInit) * 2.0 * $ptLength / $braceLength}]
set fPTMax [expr {$Fpre + (0.1 - $eY) * $k2}]

set ptStrains [list [expr {-0.1}] [expr {-$eY}] 0.0 [expr {$eY}] 0.1]
set ptStresses [list [expr {-$fPTMax}] [expr {-$Fpre}] 0.0 $Fpre $fPTMax]

uniaxialMaterial ElasticMultiLinear 30011 -strain {*}$ptStrains -stress {*}$ptStresses
uniaxialMaterial MinMax 30012 30011 -min [expr {-$eFracture}] -max $eFracture
uniaxialMaterial ElasticPP 30013 [expr {$Ffri / $eY}] $eY
uniaxialMaterial Parallel 30010 30012 30013

set area 1.0

puts "tsc.tcl loaded"