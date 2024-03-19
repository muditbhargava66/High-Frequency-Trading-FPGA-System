# Clock definition
create_clock -period 4.000 -name clk_100MHz [get_ports clk]

# Clock dedicated route constraint
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_IBUF]

# Input delay constraints
set_input_delay -clock clk_100MHz -max 1.000 [get_ports rst_n]
set_input_delay -clock clk_100MHz -max 1.000 [get_ports eth_rx_data[*]]
set_input_delay -clock clk_100MHz -max 1.000 [get_ports eth_rx_valid]
set_input_delay -clock clk_100MHz -max 1.000 [get_ports eth_tx_ready]
set_input_delay -clock clk_100MHz -max 1.000 [get_ports custom_ip_control[*]]

# Output delay constraints
set_output_delay -clock clk_100MHz -max 1.000 [get_ports eth_rx_ready]
set_output_delay -clock clk_100MHz -max 1.000 [get_ports eth_tx_data[*]]
set_output_delay -clock clk_100MHz -max 1.000 [get_ports eth_tx_valid]
set_output_delay -clock clk_100MHz -max 1.000 [get_ports custom_ip_status[*]]

# False path constraints
# set_false_path -from [get_ports rst_n] -to [all_registers]

# Multicycle path constraints
set_multicycle_path -setup -from [get_clocks clk_100MHz] -to [get_clocks clk_100MHz] 2
set_multicycle_path -hold -from [get_clocks clk_100MHz] -to [get_clocks clk_100MHz] 1

# Clock groups
set_clock_groups -asynchronous -group [get_clocks clk_100MHz] -group [get_clocks -include_generated_clocks]

# Timing ignore constraints
set_false_path -through [get_nets -hierarchical *cdc_sync_fifo_din_reg*]
set_false_path -through [get_nets -hierarchical *cdc_sync_fifo_dout_reg*]

# Timing exceptions
set_case_analysis 1 [get_pins -hier *cdc_sync_fifo_wr_en_reg/C]
set_case_analysis 1 [get_pins -hier *cdc_sync_fifo_rd_en_reg/C]

# Timing logics
# set_logic_one [get_ports -hier *cdc_sync_fifo_wr_rst_busy*]
# set_logic_zero [get_ports -hier *cdc_sync_fifo_rd_rst_busy*]

# Area constraints
create_pblock pblock_top_level
add_cells_to_pblock [get_pblocks pblock_top_level] [get_cells -hier -filter {NAME =~ *top_level*}]
resize_pblock [get_pblocks pblock_top_level] -add {SLICE_X0Y0:SLICE_X150Y150}

# Placement constraints
set_property PACKAGE_PIN R4 [get_ports clk]
set_property PACKAGE_PIN G4 [get_ports rst_n]
set_property PACKAGE_PIN H1 [get_ports {eth_rx_data[0]}]
set_property PACKAGE_PIN J1 [get_ports {eth_rx_data[1]}]
set_property PACKAGE_PIN H2 [get_ports {eth_rx_data[2]}]
set_property PACKAGE_PIN J2 [get_ports {eth_rx_data[3]}]
set_property PACKAGE_PIN G1 [get_ports {eth_rx_data[4]}]
set_property PACKAGE_PIN F1 [get_ports {eth_rx_data[5]}]
set_property PACKAGE_PIN E1 [get_ports {eth_rx_data[6]}]
set_property PACKAGE_PIN E2 [get_ports {eth_rx_data[7]}]
set_property PACKAGE_PIN F2 [get_ports {eth_rx_data[8]}]
set_property PACKAGE_PIN G2 [get_ports {eth_rx_data[9]}]
set_property PACKAGE_PIN K1 [get_ports eth_rx_valid]
set_property PACKAGE_PIN K2 [get_ports eth_tx_ready]
set_property PACKAGE_PIN L1 [get_ports {custom_ip_control[0]}]
set_property PACKAGE_PIN L2 [get_ports {custom_ip_control[1]}]
set_property PACKAGE_PIN M1 [get_ports {custom_ip_control[2]}]
set_property PACKAGE_PIN M2 [get_ports {custom_ip_control[3]}]
set_property PACKAGE_PIN N1 [get_ports eth_rx_ready]
set_property PACKAGE_PIN P1 [get_ports {eth_tx_data[0]}]
set_property PACKAGE_PIN R1 [get_ports {eth_tx_data[1]}]
set_property PACKAGE_PIN P2 [get_ports {eth_tx_data[2]}]
set_property PACKAGE_PIN R2 [get_ports {eth_tx_data[3]}]
set_property PACKAGE_PIN N2 [get_ports {eth_tx_data[4]}]
set_property PACKAGE_PIN M3 [get_ports {eth_tx_data[5]}]
set_property PACKAGE_PIN L3 [get_ports {eth_tx_data[6]}]
set_property PACKAGE_PIN K3 [get_ports {eth_tx_data[7]}]
set_property PACKAGE_PIN J3 [get_ports {eth_tx_data[8]}]
set_property PACKAGE_PIN H3 [get_ports {eth_tx_data[9]}]
set_property PACKAGE_PIN G3 [get_ports eth_tx_valid]

# I/O standards
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports eth_rx_data[*]]
set_property IOSTANDARD LVCMOS33 [get_ports eth_rx_valid]
set_property IOSTANDARD LVCMOS33 [get_ports eth_tx_ready]
set_property IOSTANDARD LVCMOS33 [get_ports custom_ip_control[*]]
set_property IOSTANDARD LVCMOS33 [get_ports eth_rx_ready]
set_property IOSTANDARD LVCMOS33 [get_ports eth_tx_data[*]]
set_property IOSTANDARD LVCMOS33 [get_ports eth_tx_valid]
set_property IOSTANDARD LVCMOS33 [get_ports custom_ip_status[*]]