onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_processor_tb/Resetn
add wave -noupdate /top_processor_tb/PClock
add wave -noupdate /top_processor_tb/MClock
add wave -noupdate /top_processor_tb/Run
add wave -noupdate /top_processor_tb/Done
add wave -noupdate /top_processor_tb/BusWires
add wave -noupdate /top_processor_tb/R0_out
add wave -noupdate /top_processor_tb/R1_out
add wave -noupdate /top_processor_tb/RA_out
add wave -noupdate /top_processor_tb/RG_out
add wave -noupdate /top_processor_tb/IR_out
add wave -noupdate /top_processor_tb/Tstep_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
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
WaveRestoreZoom {1009050 ps} {1010050 ps}
