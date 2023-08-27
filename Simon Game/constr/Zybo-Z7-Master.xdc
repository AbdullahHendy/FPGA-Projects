create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports {clk_top}];
set_property PACKAGE_PIN K18 [get_ports {btns[0]}]
set_property PACKAGE_PIN P16 [get_ports {btns[1]}]
set_property PACKAGE_PIN K19 [get_ports {btns[2]}]
set_property PACKAGE_PIN Y16 [get_ports {btns[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btns[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btns[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btns[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btns[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[0]}]
set_property PACKAGE_PIN D18 [get_ports {leds[3]}]
set_property PACKAGE_PIN G14 [get_ports {leds[2]}]
set_property PACKAGE_PIN M15 [get_ports {leds[1]}]
set_property PACKAGE_PIN M14 [get_ports {leds[0]}]
set_property PACKAGE_PIN K17 [get_ports clk_top]
set_property PACKAGE_PIN F17 [get_ports green]
set_property PACKAGE_PIN V16 [get_ports red]
set_property PACKAGE_PIN M17 [get_ports blue]
set_property IOSTANDARD LVCMOS33 [get_ports blue]
set_property IOSTANDARD LVCMOS33 [get_ports clk_top]
set_property IOSTANDARD LVCMOS33 [get_ports green]
set_property IOSTANDARD LVCMOS33 [get_ports red]
