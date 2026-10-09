# ===================================
# ========= steel material ==========
# ===================================

if {[llength $argv] >= 1} {
    set steelType [lindex $argv 0]
} else {
    set steelType "Q235"
}

# ===================================
# ============ ED steel =============
# ===================================
# 10.1002/eqe.3463 Table 3
# used in BRB, CSC, TSC and LPSC
if {$steelType eq "Q235"}{
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
}

# used in BFLP
if {$steelType eq "316L"}{
    set fyS 212.0
    set fuS 438.0
    set ES 197000.0
    set eyS [expr {$fyS / $ES}]
    set eshS [expr {(1 + 1) * $eyS}]
    set hS 0.011; # ESh / ES
    set euS 0.4
}

# ===================================
# ============ SC steel =============
# ===================================
# 10.1002/eqe.3463 Table 3
# used in CSC and TSC
if {$steelType eq "PT1"}{
    set fuPT 1945.0
    set EPT 99000.0
    set euPT [expr {$fuPT / $EPT}]
}

# used in LPSC
if {$steelType eq "PT2"}{
    set fyPT 785.0
    set fuPT 980.0
    set EPT 206000.0
    set euPT 0.09
    set eyPT [expr {$fyPT / $EPT}]
}