source [file join [file dirname [file normalize [info script]]] "1.frame.tcl"]

# Parameters 10.14006/j.jzjgxb.2024.0207 Table 3|P6
set lambdaF [expr {30000.0 / $targetYieldForce}]
# This should be 0.03 but considering the Spring is sellected which is coresponding to Fpre.
# If change this lambdaF, the parameters should be changed theoretically.
# puts "lambdaF: $lambdaF"
set deltaSC 0.025
set CkRS 4.5
set dFT 3

# ED
set fyS 212.0
set fuS 438.0
set Es 197000.0
set eyS [expr {$fyS / $Es}]
set eshS [expr {(1 + 13) * $eyS}]
set hS 0.011; # Esh / Es
set euS 0.45
set SRatio [expr 0.7 / (1 + 0.45)] 
set lS [expr {$braceLength * $SRatio}]
# This yieldArea won't be used. This theoretical area is a little larger than the used AS.
set yieldArea [expr {$targetYieldForce / $fyS}]
# PT
set fyPT 785.0
set fuPT 980.0
set EPT 206000.0
set euPT 0.09
set eyPT [expr {$fyPT / $EPT}]
set PTRatio 0.75
set lPT [expr {$braceLength * $PTRatio}]
# Spr
set Fpre [expr $lambdaF * $targetYieldForce]
set FuSpr 64000.0
set dSprPreOne 1.44
set dSprAllOne 3.6
set hSprOne 9.6
set dSprEffOne [expr {$dSprAllOne - $dSprPreOne}]
set kSprOne [expr {($FuSpr - $Fpre) / $dSprEffOne}]
set N [expr {ceil(($deltaSC * $h * cos($braceAngle) - $eyPT * $lPT) / $dSprEffOne)}]
set dSprEff [expr {$dSprEffOne * $N}]
set dSprPre [expr {$dSprPreOne * $N}]
set kSpr [expr {$kSprOne / $N}]
# PT
set dPTPre [expr {$dSprEff + $eyPT * $lPT - $deltaSC * $h * cos($braceAngle)}]
set kPT [expr {$Fpre / $dPTPre}]
set APT [expr {$kPT * $lPT / $EPT}]
# Total
set k1 [expr {($targetYieldForce - $Fpre) / $eyS / $lS * $CkRS / ($CkRS + 1.0)}]
set k3 [expr {$kPT * $kSpr / ($kPT + $kSpr)}]
set kS [expr {($k1 - $k3) * ($CkRS + 1.0) / $CkRS}]
set AS [expr {$kS * $lS / $Es}]
set FyPT [expr {$APT * $fyPT}]
set fpre [expr {$Fpre / $APT}]
set fuSpr [expr {$FuSpr / $APT}]

# SC
## PT
uniaxialMaterial Steel01 30011 [expr {$fyPT - $fpre}] $EPT 0.001
## Spr
set sprStrains [list [expr {-1.0}] [expr {-$dSprPre / $lPT}] 0.0 [expr {$dSprEff / $lPT}] [expr {($dSprEff + 0.01) / $lPT}]]
set sprStresses [list [expr {-2 * $fpre}] [expr {-$fpre}] 0.0 [expr {$fuSpr - $fpre}] $fuSpr]
uniaxialMaterial ElasticMultiLinear 30012 -strain {*}$sprStrains -stress {*}$sprStresses

uniaxialMaterial Series 30013 30011 30012

# ED
## Ratchet
uniaxialMaterial Ratchet 30016 [expr {$CkRS * $Es}] [expr {$dFT / $lS}]
uniaxialMaterial Elastic 30017 [expr {$Es / 10000.0}]
uniaxialMaterial Parallel 30018 30016 30017
## ED steel
uniaxialMaterial ReinforcingSteel 30019 $fyS $fuS $Es [expr {$hS * $Es}] $eshS $euS
uniaxialMaterial MinMax 30020 30019 -max $euS
uniaxialMaterial Elastic 30021 [expr {$Es / 10000.0}]
uniaxialMaterial Parallel 30022 30020 30021

uniaxialMaterial Series 30023 30018 30022

uniaxialMaterial LPSCED 30010 $PTRatio $SRatio [expr {$APT / $AS}] 30013 30023
# =====================================================================
# set Dopen [expr {$lambdaF * $lS * $fyS / $Es / 3}]
# set eopen [expr {$Dopen / $lPT}]
# set fadj [expr {$fpre - $k3 * $Dopen / $APT}]
# uniaxialMaterial ElasticBilin 30014 [expr {$fadj / $eopen}] [expr {$EPT/10000.0}] $eopen
# uniaxialMaterial Parallel 30015 30013 30014
# uniaxialMaterial LPSCED 30010 $PTRatio $SRatio [expr {$APT / $AS}] 30015 30023
# =====================================================================

# puts "not used yieldArea: $yieldArea"
# puts "used AS: $AS"
set area $AS

puts "lpsc.tcl loaded"