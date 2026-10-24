set TOP harris_top
set ROOT [file normalize [file join [file dirname [info script]] ../..]]
read library -liberty $env(STD_CELL_LIB) -both
read design $ROOT/rtl/*.sv -sv -golden
read design $ROOT/build/genus/harris_top_mapped.v -revised
set system mode lec
add compared points -all
compare
report verification
