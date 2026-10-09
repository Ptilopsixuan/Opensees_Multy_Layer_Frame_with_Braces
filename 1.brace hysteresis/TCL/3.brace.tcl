# Parameters
if {![info exists braceType]} {
    set braceType "brb"
}
if {![info exists targetYieldForce]} {
    set targetYieldForce 1000000.0
}
source [file join [file dirname [file normalize [info script]]] "2.${braceType}.tcl"]

set scriptDir [file dirname [file normalize [info script]]]
set workDir [file dirname $scriptDir]
set outputDir [file join $workDir output $braceType]
# puts "outputDir: $outputDir"
file mkdir $outputDir

addElasticBeamColumn 3001 101 301 $rigidBraceArea $frameElasticModulus $rigidBraceInertia 3 $rigidSegmentStiffnessFactor
element Truss 3002 301 302 $area 30010
addElasticBeamColumn 3003 302 108 $rigidBraceArea $frameElasticModulus $rigidBraceInertia 3 $rigidSegmentStiffnessFactor

recorder Node -file [file join $outputDir control_node_disp.out] -time -node $controlNode -dof $controlDof disp
recorder Node -file [file join $outputDir support_reactions.out] -time -node 101 105 -dof 1 reaction
recorder Element -file [file join $outputDir brace_axial_force.out] -time -ele 3002 axialForce
recorder Element -file [file join $outputDir brace_local_force.out] -time -ele 3002 localForce

if { $braceType eq "bflp" } {
    node 303 [expr {$p * cos($braceAngle)}] [expr {$h - $p * sin($braceAngle)}]
    node 304 [expr {$w - $p * cos($braceAngle)}] [expr {$p * sin($braceAngle)}]
    addElasticBeamColumn 3004 105 304 $rigidBraceArea $frameElasticModulus $rigidBraceInertia 3 $rigidSegmentStiffnessFactor
    element Truss 3005 304 303 $area 30010
    addElasticBeamColumn 3006 303 104 $rigidBraceArea $frameElasticModulus $rigidBraceInertia 3 $rigidSegmentStiffnessFactor
    recorder Element -file [file join $outputDir brace_axial_force.out] -time -ele 3005 axialForce
    recorder Element -file [file join $outputDir brace_local_force.out] -time -ele 3005 localForce
}

puts "brace.tcl loaded"