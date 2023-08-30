# Project Title

Display Patterns With VGA 

## Description

Display different patterns using the VGA interface with a 1920x1080@60Hz display.


## Dependencies

### Software

##### Vivado

* ***Clocking Wizard*** IP from Xilinx must be added to the project before generating the bit stream.
* To avoid having to modify the source files, the ***Clocking Wizard*** component must be configured as follows:
	* Component Name: clk_wiz_0
	* Input Clock: 125 MHz
	* Output Clock: 148.5 MHz


### Hardware

* [VGA PMOD](https://digilent.com/shop/pmod-vga-video-graphics-array/)
* 1920x1080@60Hz Monitor for best results
* To avoid having to modify the constraint ***.xdc*** file:
	* Plug the VGA PMOD* in the **JC** and **JD** PMOD ports on the Zybo

## How To Use

1. Use the switch to show one pattern out of **twelve** total patterns:
	* Switch positions 0 to 11 
	* For switch positions 7, 8, 9, and 10:
		* Use the push-buttons to display different sizes of the same pattern
	* Switch position 11 is a moving ball display.


## Documentation



## Version History

* 0
    * Initial version
