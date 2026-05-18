###############################################################################
# Created by write_sdc
###############################################################################
current_design mm_top
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 10.0000 [get_ports {clk}]
set_clock_transition 0.1500 [get_clocks {clk}]
set_clock_uncertainty 0.2500 clk
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {input_data[0]}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {input_data[1]}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {input_data[2]}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {input_data[3]}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {input_data[4]}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {input_data[5]}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {input_data[6]}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {input_data[7]}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {read_ram}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {rst}]
set_input_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {start}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {finish}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {read_data_out[0]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {read_data_out[1]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {read_data_out[2]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {read_data_out[3]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {read_data_out[4]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {read_data_out[5]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {read_data_out[6]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {read_data_out[7]}]
set_output_delay 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {read_data_out[8]}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0060 [get_ports {finish}]
set_load -pin_load 0.0060 [get_ports {read_data_out[8]}]
set_load -pin_load 0.0060 [get_ports {read_data_out[7]}]
set_load -pin_load 0.0060 [get_ports {read_data_out[6]}]
set_load -pin_load 0.0060 [get_ports {read_data_out[5]}]
set_load -pin_load 0.0060 [get_ports {read_data_out[4]}]
set_load -pin_load 0.0060 [get_ports {read_data_out[3]}]
set_load -pin_load 0.0060 [get_ports {read_data_out[2]}]
set_load -pin_load 0.0060 [get_ports {read_data_out[1]}]
set_load -pin_load 0.0060 [get_ports {read_data_out[0]}]
set_driving_cell -lib_cell sg13g2_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {clk}]
set_driving_cell -lib_cell sg13g2_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {read_ram}]
set_driving_cell -lib_cell sg13g2_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {rst}]
set_driving_cell -lib_cell sg13g2_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {start}]
set_driving_cell -lib_cell sg13g2_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {input_data[7]}]
set_driving_cell -lib_cell sg13g2_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {input_data[6]}]
set_driving_cell -lib_cell sg13g2_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {input_data[5]}]
set_driving_cell -lib_cell sg13g2_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {input_data[4]}]
set_driving_cell -lib_cell sg13g2_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {input_data[3]}]
set_driving_cell -lib_cell sg13g2_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {input_data[2]}]
set_driving_cell -lib_cell sg13g2_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {input_data[1]}]
set_driving_cell -lib_cell sg13g2_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {input_data[0]}]
###############################################################################
# Design Rules
###############################################################################
set_max_fanout 10.0000 [current_design]
