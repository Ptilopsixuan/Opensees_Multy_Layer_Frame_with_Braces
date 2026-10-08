# ==================================================
# ================== 1.frame.tcl ===================
# ==================================================
proc hShapeProps {depth width tf tw} {
    set area [expr {2.0 * $width * $tf + $tw * ($depth - 2.0 * $tf)}]
    set inertia [expr {
        2.0 * $width * $tf * pow($depth / 2.0 - $tf / 2.0, 2)
        + $tw * pow($depth - 2.0 * $tf, 3) / 12.0
    }]
    return [list $area $inertia]
}
proc tubeProps {width thickness} {
    set innerWidth [expr {$width - 2.0 * $thickness}]
    set area [expr {$width * $width - $innerWidth * $innerWidth}]
    set inertia [expr {pow($width, 4) / 12.0 - pow($innerWidth, 4) / 12.0}]
    return [list $area $inertia]
}
proc addElasticBeamColumn {tag nodeI nodeJ area elasticModulus inertia transfTag stiffnessFactor} {
    element elasticBeamColumn $tag $nodeI $nodeJ $area [expr {$elasticModulus * $stiffnessFactor}] $inertia $transfTag
}

# ==================================================
# ================= 4.analysis.tcl =================
# ==================================================
proc cyclicTargets {height driftLevels cyclesPerLevel} {
    set targets {}
    foreach drift $driftLevels {
        set amplitude [expr {$drift * $height}]
        for {set i 0} {$i < $cyclesPerLevel} {incr i} {
            lappend targets $amplitude [expr {-$amplitude}] 0.0
        }
    }
    return $targets
}
# get Brace response
# proc trussInitialLength {nodeI nodeJ} {
#     set ci [nodeCoord $nodeI]
#     set cj [nodeCoord $nodeJ]
#     set dx [expr {[lindex $cj 0] - [lindex $ci 0]}]
#     set dy [expr {[lindex $cj 1] - [lindex $ci 1]}]
#     return [expr {sqrt($dx * $dx + $dy * $dy)}]
# }
# this func get delta_netDiagonal = delta_brace = delta_brace_core
proc trussDeformation {nodeI nodeJ initialLength} {
    set ci [nodeCoord $nodeI]
    set cj [nodeCoord $nodeJ]
    set ui [nodeDisp $nodeI]
    set uj [nodeDisp $nodeJ]
    set xi [expr {[lindex $ci 0] + [lindex $ui 0]}]
    set yi [expr {[lindex $ci 1] + [lindex $ui 1]}]
    set xj [expr {[lindex $cj 0] + [lindex $uj 0]}]
    set yj [expr {[lindex $cj 1] + [lindex $uj 1]}]
    set currentLength [expr {sqrt(pow($xj - $xi, 2) + pow($yj - $yi, 2))}]
    return [expr {$currentLength - $initialLength}]
}
proc braceAxialForce {eleTag} {
    foreach query {axialForce basicForce localForce} {
        if {[catch {set response [eleResponse $eleTag $query]}] == 0 && [llength $response] > 0} {
            return [lindex $response 0]
        }
    }
    return 0.0
}
# get Global response
proc supportReactionForce {} {
    reactions
    set leftFx [nodeReaction 101 1]
    set rightFx [nodeReaction 105 1]
    return [expr {-($leftFx + $rightFx)}]
}
# Write Brace & Global response to CSV files
proc writeResponseRows {globalFile braceFile step controlNode controlDof braceTag braceNodeI braceNodeJ netDiagonalLength} {
    set controlDisp [nodeDisp $controlNode $controlDof]
    set appliedForce [supportReactionForce]

    set braceDeformation [trussDeformation $braceNodeI $braceNodeJ $netDiagonalLength]
    set braceForce [braceAxialForce $braceTag]
    set braceStrain [expr {$braceDeformation / $netDiagonalLength}]
    # set braceStress [expr {$braceForce / $area}]

    puts $globalFile "$step,$controlDisp,$appliedForce"
    puts $braceFile "$step,$braceTag,$braceDeformation,$braceForce,$braceStrain"
    flush $globalFile
    flush $braceFile
}
# Write BFLP
proc writeAnalysisResponseRows {globalFile braceFile step controlNode controlDof braceType netDiagonalLength} {
    if {$braceType eq "bflp"} {
        set controlDisp [nodeDisp $controlNode $controlDof]
        set appliedForce [supportReactionForce]

        set braceDeformation [trussDeformation 301 302 $netDiagonalLength]
        set braceForceI [braceAxialForce 3002]
        set braceForceJ [braceAxialForce 3005]
        # Algebraic sum of the two BFLP brace element axialForce responses.
        set braceForce [expr {$braceForceI - $braceForceJ}]
        set braceStrain [expr {$braceDeformation / $netDiagonalLength}]

        puts $globalFile "$step,$controlDisp,$appliedForce"
        puts $braceFile "$step,3002+3005,$braceDeformation,$braceForce,$braceStrain"
        flush $globalFile
        flush $braceFile
        return
    }

    writeResponseRows $globalFile $braceFile $step $controlNode $controlDof 3002 301 302 $netDiagonalLength
}

# try Analysis
proc analyzeOneStep {controlNode controlDof increment testTolerance maxIterations} {
    integrator DisplacementControl $controlNode $controlDof $increment

    set strategies [list \
        [list Newton $testTolerance $maxIterations] \
        [list NewtonLineSearch [expr {$testTolerance * 10.0}] [expr {$maxIterations * 2}]] \
        [list ModifiedNewton [expr {$testTolerance * 10.0}] [expr {$maxIterations * 3}]] \
        [list KrylovNewton [expr {$testTolerance * 10.0}] [expr {$maxIterations * 3}]] \
    ]

    set ok -1
    foreach strategy $strategies {
        lassign $strategy algorithmName tolerance iterations
        test NormDispIncr $tolerance $iterations
        algorithm $algorithmName
        set ok [analyze 1]
        if {$ok == 0} {
            break
        }
    }

    test NormDispIncr $testTolerance $maxIterations
    algorithm Newton
    return $ok
}