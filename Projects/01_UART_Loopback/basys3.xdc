# 1. The Clock (100 MHz)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

# 2. The Reset Button (Center Button)
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

# 3. The Data Input (RX - USB Channel)
set_property PACKAGE_PIN B18 [get_ports rx_serial]
set_property IOSTANDARD LVCMOS33 [get_ports rx_serial]

# 4. The Output (LEDs)
# LED 0-7 will show the binary ASCII code of the letter you type
set_property PACKAGE_PIN U16 [get_ports {rx_byte[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rx_byte[0]}]
set_property PACKAGE_PIN E19 [get_ports {rx_byte[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rx_byte[1]}]
set_property PACKAGE_PIN U19 [get_ports {rx_byte[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rx_byte[2]}]
set_property PACKAGE_PIN V19 [get_ports {rx_byte[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rx_byte[3]}]
set_property PACKAGE_PIN W18 [get_ports {rx_byte[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rx_byte[4]}]
set_property PACKAGE_PIN U15 [get_ports {rx_byte[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rx_byte[5]}]
set_property PACKAGE_PIN U14 [get_ports {rx_byte[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rx_byte[6]}]
set_property PACKAGE_PIN V14 [get_ports {rx_byte[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rx_byte[7]}]

# 5. The "Done" Flag (Last LED - LED 15)
# This will flash briefly whenever a new character arrives
set_property PACKAGE_PIN L1 [get_ports rx_done]
set_property IOSTANDARD LVCMOS33 [get_ports rx_done]

# The Spy Pin (Mapped to Header JA, Pin 1 - The top left pin on the side header)
set_property PACKAGE_PIN J1 [get_ports spy_pin]
set_property IOSTANDARD LVCMOS33 [get_ports spy_pin]
