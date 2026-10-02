source [file join [file dirname [file normalize [info script]]] "1.frame.tcl"]

# brace material
set brbfy 288.0
set brbElasticModulus 208000.0
set brbBsh 0.005
set brbR0 20
set brbCR1 0.925
# set brbR0 24
# set brbCR1 0.9
set brbCR2 0.15
set brba1 0.05
set brba2 1.0
set brba3 0.03
set brba4 1.0

set area [expr {$targetYieldForce / $brbfy}]
set energyDissipatingCoreLengthRatio 0.70
set effectiveElasticModulus [expr {$brbElasticModulus / $energyDissipatingCoreLengthRatio}]

set effectiveE0 [expr {0.191 * $energyDissipatingCoreLengthRatio}]
set m -0.458

uniaxialMaterial Steel02 30011 $brbfy $effectiveElasticModulus $brbBsh $brbR0 $brbCR1 $brbCR2 $brba1 $brba2 $brba3 $brba4
uniaxialMaterial Fatigue 30010 30011 "-E0" $effectiveE0 "-m" $m

puts "brb.tcl loaded"