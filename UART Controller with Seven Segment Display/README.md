# Project Title

UART Controller with Seven-segment Display Tester 

## Description

UART communication using using seven-segment display to show the lower 4-bits of the data received decoded into decimal numbers

**The UART Implementation is inspired by the following book:
[FPGA Prototyping by VHDL Examples: Xilinx MicroBlaze MCS SoC Edition by Pong P. Chu
](https://www.wiley.com/en-us/FPGA+Prototyping+by+VHDL+Examples%3A+Xilinx+MicroBlaze+MCS+SoC%2C+2nd+Edition-p-9781119282747)**

## Dependencies

### Software

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
* To avoid having to modify the constraint ***.xdc*** file:
	* Plug the *USB-UART interface* in the **JC** PMOD port on the Zybo
	* Plug the *Seven-segment Display* in the first row of the **JD** and **JE** PMOD ports on the Zybo

## How To Use

1. Reset → BTN0
2. The FPGA test code is programmed to send the character "2" followed by a new line, which should show up in the terminal if the setup is done correctly.
3. While in the terminal window, press any number/character on the keyboard and the last 4-bits of the ASCII number associated with that character should show on the seven-segment display. Use the keyboard numbers to test the design since the lower 4-bits of the ASCII code of the numbers (0-9) represent the same number in binary. This trick will make the number showing on the seven-segment display match the sent data. 


## Documentation



## Version History

* 0
    * Initial version
