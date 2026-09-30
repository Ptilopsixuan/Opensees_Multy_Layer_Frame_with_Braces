# Parameters
set targetYieldForce 1000000.0
# =================================================
source [file join [file dirname [file normalize [info script]]] "1.frame.tcl"]

# brace material
set brbFy 288.0
set brbElasticModulus 208000.0
set brbBsh 0.005
set brbR0 20
set brbCR1 0.925
set brbCR2 0.15
set brba1 0.05
set brba2 1.0
set brba3 0.03
set brba4 1.0

set area [expr {$targetYieldForce / $brbFy}]
set energyDissipatingCoreLengthRatio 0.70
set braceLength [expr {$diagonalLength * $braceRatio}]
set energyDissipatingCoreLength [expr {$braceLength * $energyDissipatingCoreLengthRatio}]
set effectiveElasticModulus [expr {$brbElasticModulus * $netDiagonalLength / $energyDissipatingCoreLength}]

set effectiveE0 [expr {0.191 * $energyDissipatingCoreLength / $netDiagonalLength}]
set m -0.458

uniaxialMaterial Steel02 30011 $brbFy $effectiveElasticModulus $brbBsh $brbR0 $brbCR1 $brbCR2 $brba1 $brba2 $brba3 $brba4
uniaxialMaterial Fatigue 30010 30011 "-E0" $effectiveE0 "-m" $m

puts "brb.tcl loaded"