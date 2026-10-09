source [file join [file dirname [file normalize [info script]]] "1.frame.tcl"]

# brace material
set fy 288.0
set ES 208000.0
set Bsh 0.005
set R0 20
set CR1 0.925
# set R0 24
# set CR1 0.9
set CR2 0.15
set a1 0.05
set a2 1.0
set a3 0.03
set a4 1.0

set area [expr {$targetYieldForce / $fy}]
set energyDissipatingCoreLengthRatio 0.70; # assume ED steel length is 0.7 of brace length 
set effectiveES [expr {$ES / $energyDissipatingCoreLengthRatio}]

set effectiveE0 [expr {0.191 * $energyDissipatingCoreLengthRatio}]
set m -0.458

uniaxialMaterial Steel02 30011 $fy $effectiveES $Bsh $R0 $CR1 $CR2 $a1 $a2 $a3 $a4
uniaxialMaterial Fatigue 30010 30011 "-E0" $effectiveE0 "-m" $m

puts "brb.tcl loaded"