# Main FPGA board clock (50 MHz)
create_clock -name clk -period 20.000 [get_ports clk]

# Properly constrain the fabric-generated SPI clock divider register output
create_generated_clock -name sclk -source [get_clocks clk] -divide_by 16 [get_pins {*|sclk~reg0}]

# Ignore CDC timing between main clk and SPI clock
set_false_path -from [get_clocks clk] -to   [get_clocks sclk]
set_false_path -from [get_clocks sclk] -to   [get_clocks clk]
set_false_path -through [get_nets sclk~reg0]
