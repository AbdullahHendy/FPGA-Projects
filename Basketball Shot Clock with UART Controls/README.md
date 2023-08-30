# Project Title

NBA Style Basketball Shot Clock with UART Control 

## Description

NBA-style (24 Seconds) shot clock with a speaker. The shot clock can be reset and paused using commands received from a host through a UART communication channel.


## Dependencies

### Software

##### Vivado

* ***Clocking Wizard*** IP from Xilinx must be added to the project before generating the bit stream.
* To avoid having to modify the source files, the ***Clocking Wizard*** component must be configured as follows:
	* Component Name: clk_wiz_0
	* Input Clock: 125 MHz
	* Output Clock: 50 MHz
	* Everything else can be left to the default values since the project doesn't require complex timing requirements.


##### Terminal

* Use a terminal/terminal-emulator software like [Tera Term](https://ttssh2.osdn.jp/index.html.en) or [PuTTY](https://www.putty.org/) or any other for serial communication between the host PC and the Zybo.
* Connect to the correct COM Port, which will show up in the *Device Manager* once the USB-UART PMOD is plugged in.
* Use the following settings for the serial communication:
	1. Baud Rate: 115200
	2. Data: 8 bits
	3. Parity: none
	4. Stop bits: 1 bit
	5. Flow Control: None


### Hardware

* [Seven-segment Display PMOD](https://digilent.com/shop/pmod-ssd-seven-segment-display/)
* [USB to UART Interface PMOD](https://digilent.com/shop/pmod-usbuart-usb-to-uart-interface/)
* Simple Buzzer.
	* A [custom made speaker](https://github.com/AbdullahHendy/Speaker-PCB) was used for this project instead of a buzzer.
* To avoid having to modify the constraint ***.xdc*** file:
	* Plug the *USB-UART interface* in the **JE** PMOD port on the Zybo
	* Plug the *Seven-segment Display* in the first row of the **JD** and **JC** PMOD ports on the Zybo
	* Plug the positive of the buzzer (speaker) to ***pin 4*** of the **JA** PMOD and the ground of the buzzer (speaker) to ***pin 5*** of the same PMOD header.

## How To Use

1. Open the terminal
2. Send the following characters to control the clock:
	1. Play: (P)
	2. Stop: (S)
	3. Reset (R)
3. Wait for the sound to go off when the clock reaches 0.


## Documentation

### Setup 

![Setup](https://github.com/AbdullahHendy/FPGA-Projects/blob/main/Basketball%20Shot%20Clock%20with%20UART%20Controls/media/setup.jpg?raw=true)


### Video Demo

[![Video Demo](https://github.com/AbdullahHendy/FPGA-Projects/blob/main/Basketball%20Shot%20Clock%20with%20UART%20Controls/media/setup.jpg)](https://www.youtube.com/watch?v=Xvc3fC9iti8)


## Version History

* 0
    * Initial version
