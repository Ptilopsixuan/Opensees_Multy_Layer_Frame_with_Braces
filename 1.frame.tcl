wipe
model BasicBuilder -ndm 2 -ndf 3
source function.tcl

# ==================================================
# ================== Parameters ====================
# ==================================================
# farme
set frameHeight 5490.0
set frameWidth 9140.0
set rigidLength 400.0
set frameElasticModulus 200000.0
# column
set columnDepth 386.0
set columnWidth 399.0
set columnTf 33.3
set columnTw 21.1
# beam
set beamDepth 406.0
set beamWidth 178.0
set beamTf 12.8
set beamTw 7.7
# square brace
set rigidTubeWidth 228.6
set rigidTubeThickness 14.8
set rigidSegmentStiffnessFactor 10.0
set braceRatio 0.85
# Cyclic loading parameters.
set controlNode 104
set controlDof 1
set referenceForce 1.0

# ==================================================
# ===================== Nodes ======================
# ==================================================
# geometry parameters
set p $rigidLength
set h $frameHeight
set w $frameWidth
set diagonalLength [expr {sqrt($h * $h + $w * $w)}]
set netDiagonalLength [expr {$diagonalLength - 2.0 * $p}]
set braceAngle [expr {atan2($h, $w)}]
# Column nodes. 101/105 are fixed bases; 104/108 are top column joints.
node 101 0.0 0.0
node 102 0.0 $p
node 103 0.0 [expr {$h - $p}]
node 104 0.0 $h
node 105 $w 0.0
node 106 $w $p
node 107 $w [expr {$h - $p}]
node 108 $w $h
# Beam nodes. 204 is the beam center used by the inverted-V BRB.
node 201 $p $h
node 202 [expr {$w - $p}] $h
# brace nodes
node 301 [expr {$p * cos($braceAngle)}] [expr {$p * sin($braceAngle)}]
node 302 [expr {$w / 2.0 - $p * cos($braceAngle)}] [expr {$h - $p * sin($braceAngle)}]
node 303 [expr {$w / 2.0 + $p * cos($braceAngle)}] [expr {$h - $p * sin($braceAngle)}]
node 304 [expr {$w - $p * cos($braceAngle)}] [expr {$p * sin($braceAngle)}]
# fix
fix 101 1 1 0
fix 105 1 1 0
# transformations
geomTransf PDelta 1
geomTransf Linear 2
geomTransf Linear 3

# ==================================================
# ==================== Sections ====================
# ==================================================
# hShapeProps & tubeProps see function.tcl
lassign [hShapeProps $columnDepth $columnWidth $columnTf $columnTw] columnArea columnInertia
lassign [hShapeProps $beamDepth $beamWidth $beamTf $beamTw] beamArea beamInertia
lassign [tubeProps $rigidTubeWidth $rigidTubeThickness] rigidBraceArea rigidBraceInertia
set columnSegments {
    {1001 101 102 column-rigid 10.0}
    {1002 102 103 column 1.0}
    {1003 103 104 column-rigid 10.0}
    {1004 105 106 column-rigid 10.0}
    {1005 106 107 column 1.0}
    {1006 107 108 column-rigid 10.0}
}
# addElasticBeamColumn see function.tcl
foreach segment $columnSegments {
    lassign $segment tag nodeI nodeJ kind stiffnessFactor
    addElasticBeamColumn $tag $nodeI $nodeJ $columnArea $frameElasticModulus $columnInertia 1 $stiffnessFactor
}
set beamSegments {
    {2001 104 201 beam-rigid 10.0}
    {2002 201 202 beam 1.0}
    {2003 202 108 beam-rigid 10.0}
}
foreach segment $beamSegments {
    lassign $segment tag nodeI nodeJ kind stiffnessFactor
    addElasticBeamColumn $tag $nodeI $nodeJ $beamArea $frameElasticModulus $beamInertia 2 $stiffnessFactor
}

puts "frame.tcl loaded"