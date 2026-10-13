wipe
model BasicBuilder -ndm 3 -ndf 6

# # output node coordinates to file
# set outputFile [file join [pwd] "node_coordinates.txt"]
# set fp [open $outputFile w]
# puts $fp "nodeID x y z"

# ======================================================================
# ======================== Node Generation =============================
# ======================================================================
set layer 9
set storyHeights {5490.0 3960.0 3960.0 3960.0 3960.0 3960.0 3960.0 3960.0 3960.0}
set Width 9140.0
set rigidColumn {{500.0 207.0} {500.0 207.0} {500.0 207.0} {450.0 207.0} {450.0 207.0} {450.0 207.0} {400.0 207.0} {400.0 207.0} {400.0 0.0}}
set rigidBeam {450.0 450.0 400.0 400.0 400.0 350.0 350.0 350.0 181.0}
set rigidBrace {450.0 450.0 450.0 400.0 400.0 400.0 350.0 350.0 350.0}

# node start with 1, following 2-digit for layer and 2-digit for node
set cumZ 0.0
for {set i 0} {$i < $layer} {incr i} {
    set nodeID [expr {10100 + $i * 100}]
    set storyHeight [lindex $storyHeights $i]
    lassign [lindex $rigidColumn $i] z2Offset z3Offset
    set xOffset [lindex $rigidBeam $i]
    set diagonalLength [expr {sqrt($storyHeight * $storyHeight + $Width * $Width)}]
    set braceOffset [lindex $rigidBrace $i]
    set netDiagonalLength [expr {$diagonalLength - 2.0 * $braceOffset}]
    set braceAngle [expr {atan2($storyHeight, $Width)}]
    set braceLength $netDiagonalLength

    set z1 [expr {$cumZ}]
    set z2 [expr {$cumZ + $z2Offset}]
    set z3 [expr {$cumZ + $storyHeight - $z3Offset}]
    set z4 [expr {$cumZ + $storyHeight}]
    set braceNode1X [expr {$xOffset * cos($braceAngle)}]
    set braceNode1Z [expr {$z1 + $xOffset * sin($braceAngle)}]
    set braceNode2X [expr {$Width - $xOffset * cos($braceAngle)}]
    set braceNode2Z [expr {$z4 - $xOffset * sin($braceAngle)}]

    # left column   1-3
    # right column  4-6
    # beam          7-8
    # brace         9-10(12)
    # gravity base  49
    # gravity column 50
    # gravity beam  51-54
    set nodeList [list \
        [list [expr {$nodeID + 1}] 0.0 0.0 $z1] \
        [list [expr {$nodeID + 2}] 0.0 0.0 $z2] \
        [list [expr {$nodeID + 3}] 0.0 0.0 $z3] \
        [list [expr {$nodeID + 4}] $Width 0.0 $z1] \
        [list [expr {$nodeID + 5}] $Width 0.0 $z2] \
        [list [expr {$nodeID + 6}] $Width 0.0 $z3] \
        [list [expr {$nodeID + 7}] $xOffset 0.0 $z4] \
        [list [expr {$nodeID + 8}] [expr {$Width - $xOffset}] 0.0 $z4] \
        [list [expr {$nodeID + 9}] $braceNode1X 0.0 $braceNode1Z] \
        [list [expr {$nodeID + 10}] $braceNode2X 0.0 $braceNode2Z] \
        [list [expr {$nodeID + 50}] [expr {2.0 * $Width}] 0.0 $z4] \
        [list [expr {$nodeID + 51}] [expr {1.5 * $Width}] 0.0 $z4] \
        [list [expr {$nodeID + 52}] [expr {2.0 * $Width}] 0.0 $z4] \
        [list [expr {$nodeID + 53}] [expr {2.0 * $Width}] 0.0 $z4] \
        [list [expr {$nodeID + 54}] [expr {2.5 * $Width}] 0.0 $z4]]
        if {$i eq 0} {
        set nodeList [concat $nodeList [list \
            [list [expr {$nodeID + 49}] [expr {2.0 * $Width}] 0.0 $z1]]]
    }
    if {[info exists braceType] && $braceType eq "bflp"} {
        set nodeList [concat $nodeList [list \
            [list [expr {$nodeID + 11}] $braceNode1X 0.0 $braceNode2Z] \
            [list [expr {$nodeID + 12}] $braceNode2X 0.0 $braceNode1Z]]]
    }

    # foreach item $nodeList {
    #     lassign $item nodeNum x y z
    #     node $nodeNum $x $y $z
    #     puts $fp [format "%d %.6f %.6f %.6f" $nodeNum $x $y $z]
    # }

    set cumZ [expr {$cumZ + $storyHeight}]
}

# close $fp
# puts "node coordinates saved to $outputFile"

# ======================================================================
# ======================== Mass Generation =============================
# ======================================================================




# ======================================================================
# ===================== Restraint Generation ===========================
# ======================================================================