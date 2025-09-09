onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_processor2_tb/Resetn
add wave -noupdate /top_processor2_tb/PClock
add wave -noupdate /top_processor2_tb/MClock
add wave -noupdate /top_processor2_tb/Run
add wave -noupdate /top_processor2_tb/Done
add wave -noupdate /top_processor2_tb/BusWires
add wave -noupdate /top_processor2_tb/R0_out
add wave -noupdate /top_processor2_tb/R1_out
add wave -noupdate /top_processor2_tb/RA_out
add wave -noupdate /top_processor2_tb/RG_out
add wave -noupdate /top_processor2_tb/IR_out
add wave -noupdate /top_processor2_tb/Tstep_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {828390 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 224
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {500149 ps} {712874 ps}
