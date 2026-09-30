source 3.brace.tcl
source function.tcl

# Load
timeSeries Linear 1
pattern Plain 1 1 {
    load $controlNode 1.0 0.0 0.0
}
# Deformation control
set driftLevels {0.002 0.005 0.010 0.020}
set cyclesPerLevel 1
set maxStepMm 1.0
set minStepMm 0.02
set testTolerance 1.0e-7
set maxIterations 200
# Analysis
constraints Transformation
numberer RCM
system BandGeneral
test NormDispIncr $testTolerance $maxIterations
algorithm Newton
integrator DisplacementControl $controlNode $controlDof $maxStepMm
analysis Static

# cyclicTargets see function.tcl
set targets [cyclicTargets $frameHeight $driftLevels $cyclesPerLevel]
set step 0
set ok 0

puts "analysis.tcl loaded"
puts "$braceType cyclic example finished."

set globalFile [open [file join $outputDir global_force_displacement.csv] w]
set braceFile [open [file join $outputDir brace_force_displacement.csv] w]
puts $globalFile "step,control_disp_mm,applied_force_N"
puts $braceFile "step,brace_3002_tag,brace_3002_deformation_mm,brace_3002_force_N,brace_3005_tag,brace_3005_deformation_mm,brace_3005_force_N"

set brace3002InitialLength [trussInitialLength 301 302]
set brace3005InitialLength [trussInitialLength 304 303]

# =============================================================================
# Cyclic static analysis
# =============================================================================

writeResponseRows $globalFile $braceFile $step $controlNode $controlDof $brace3002InitialLength $brace3005InitialLength

foreach target $targets {
    while {1} {
        set current [nodeDisp $controlNode $controlDof]
        set remaining [expr {$target - $current}]
        if {[expr {abs($remaining)}] <= 1.0e-8} {
            break
        }

        set direction [expr {$remaining >= 0.0 ? 1.0 : -1.0}]
        set increment [expr {$direction * min(abs($remaining), $maxStepMm)}]

        while {1} {
            set ok [analyzeOneStep $controlNode $controlDof $increment $testTolerance $maxIterations]
            if {$ok == 0} {
                incr step
                writeResponseRows $globalFile $braceFile $step $controlNode $controlDof $brace3002InitialLength $brace3005InitialLength
                break
            }

            set increment [expr {$increment * 0.5}]
            if {[expr {abs($increment)}] < $minStepMm} {
                puts "Analysis stopped: convergence failed near target displacement $target mm at step $step."
                close $globalFile
                close $braceFile
                exit
            }
        }
    }
}

close $globalFile
close $braceFile