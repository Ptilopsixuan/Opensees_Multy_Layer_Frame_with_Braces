source [file join [file dirname [file normalize [info script]]] "1.frame.tcl"]

set lambdaF [expr {30000.0 / $targetYieldForce}]
set CkRS 1.0
set dFT 3

set fyS 212.0
set fuS 438.0
set Es 197000.0
set eyS [expr {$fyS / $Es}]
set eshS [expr {(1 + 1) * $eyS}]
set hS 0.011; # Esh / Es
set euS 0.4
set yieldArea [expr {$targetYieldForce / $fyS}]

set SRatio [expr 1 / (1 + 2 * $euS)]
set EsEff [expr {$Es / $SRatio}]
set lS [expr {$braceLength * $SRatio}]
set dReserve [expr {$euS * $lS}]
set reserveRatio [expr {$dReserve / $braceLength}]

set Fpre [expr $lambdaF * $targetYieldForce]
set FSpr 500000.0

uniaxialMaterial Ratchet 30011 [expr {$CkRS * $EsEff}] [expr {$dFT / $braceLength}]
uniaxialMaterial Elastic 30012 [expr {$Es / 10000.0}]
uniaxialMaterial Parallel 30013 30011 30012
uniaxialMaterial ElasticPPGap 30014 [expr {$Es * 10000.0}] [expr {-$fuS * 10000.0}] [expr {-$dReserve / $braceLength}]
uniaxialMaterial Parallel 30015 30013 30014
uniaxialMaterial ReinforcingSteel 30016 $fyS $fuS $Es [expr {$hS * $Es}] $eshS $euS
uniaxialMaterial Series 30017 30015 30016
uniaxialMaterial ElasticPPGap 30018 [expr {$Es * 10000.0}] [expr {-$fuS * 10000.0}] 0.0
uniaxialMaterial Parallel 30019 30017 30018

uniaxialMaterial ElasticPPGap 30020 [expr {$Es * 10000.0}] [expr {$fuS * 10000.0}] 0.0
set sprStrains [list [expr {-0.1}] [expr {-0.00004}] 0.0]
set sprStresses [list [expr {-$FSpr / $yieldArea}] [expr {-$Fpre / $yieldArea}] 0.0]
uniaxialMaterial ElasticMultiLinear 30021 -strain {*}$sprStrains -stress {*}$sprStresses
uniaxialMaterial Parallel 30022 30021 30020

uniaxialMaterial Series 30010 30019 30022
set area $yieldArea
puts "bflp.tcl loaded"