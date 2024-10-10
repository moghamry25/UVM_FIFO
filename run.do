vlib work
vlog -f src_files.list +cover -covercells
vsim -voptargs=+acc work.FIFO_top -cover -sv_seed 2327370817 -classdebug -uvmcontrol=all
add wave -position insertpoint sim:/FIFO_top/DUT/*
#coverage exclude -src FIFO.v -line 54 -code c
coverage save FIFO_top.ucdb -onexit
run -all
#vcover report FIFO_top.ucdb -details -annotate -all -output cover.txt