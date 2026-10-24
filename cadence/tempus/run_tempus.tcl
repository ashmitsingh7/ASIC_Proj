if {![info exists ::env(STD_CELL_LIB)]} { error "STD_CELL_LIB is required" }
set project_root [file normalize [file join [file dirname [info script]] ../..]]
read_lib $::env(STD_CELL_LIB)
read_verilog $project_root/build/genus/harris_top_mapped.v
read_sdc $project_root/constraints/constraints_template.sdc
report_timing -late > $project_root/build/tempus_setup.rpt
report_timing -early > $project_root/build/tempus_hold.rpt
