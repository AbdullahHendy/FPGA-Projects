# Project Title

Zynq-7000 SoC FPGA Projects 

## Description

A variety of projects using the PL side (FPGA) of the Zybo Z7-10



### Project List

* [Number Guessing Game (Simple)](https://github.com/AbdullahHendy/FPGA-Projects/tree/main/Number%20Guessing%20Game%20Simple)
* [Number Guessing Game (Advanced)](https://github.com/AbdullahHendy/FPGA-Projects/tree/main/Number%20guessing%20Game%20Advanced)
* [Simon Game](https://github.com/AbdullahHendy/FPGA-Projects/tree/main/Simon%20Game)
* [UART with Seven Segment Display](https://github.com/AbdullahHendy/FPGA-Projects/tree/main/UART%20Controller%20with%20Seven%20Segment%20Display)
* [Basketball Shot Clock with UART Controls](https://github.com/AbdullahHendy/FPGA-Projects/tree/main/Basketball%20Shot%20Clock%20with%20UART%20Controls)
* [VGA Display Patterns](https://github.com/AbdullahHendy/FPGA-Projects/tree/main/VGA%20Patterns)
* [Rainbow Effect (PWM)](https://github.com/AbdullahHendy/FPGA-Projects/tree/main/Rainbow%20PWM)
* [Digital Lock](https://github.com/AbdullahHendy/FPGA-Projects/tree/main/Digital%20Lock)


## Dependencies

### Software

* The project was developed on Windows 10 using Vivado 2022.1
* Vivado Part Select:
	* Display Name: Zybo Z7-10
	* Vendor: digilentinc.com
	* File Version: 1.1
	* Part: xc7z010clg400-1

### Language

* Most of the VHDL (*.vhd*) source files are developed using VHDL-2008 features. In the Vivado GUI, the language for each *.vhd* source file must be set to **VHDL2008**.
	* Some *.vhd* source files do **not** need **VHDL2008**, however, it best to set all *.vhd* files to **VHDL2008**

### Hardware

* [Zybo Z7-10](https://digilent.com/shop/zybo-z7-zynq-7000-arm-fpga-soc-development-board/) is used for all projects.
* Project-specific hardware is included in each project's **README** page.

## How To Use

1. [Download Vivado 2022.1.](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2022-1.html)
2. Clone the project.
3. Go to the specific project you want to try and create a folder named ***build***.
	* It can be any name but ***build*** is a popular naming convention.
4. Create a Vivado project and save it in the build folder.
5. Import the constraint file from the ***constr*** folder.
6. Import all source files from the ***src*** folder
	* In some projects the source files are in ***hardware\src***
7. Generate the bit-stream
	* Using the ***Generate Bitstream*** feature in Vivado is easier but will generate a ***.bit*** that will be loaded into the FPGA. This will be a volatile image.
	* Another way is to flash a non-volatile image on the Zybo's flash using ***.mcs*** file. This [tutorial](https://doc.nucleisys.com/hbirdv2/quick_start/mcs.html) shows the procedure.
8. Program the Zybo board.
9. Follow the additional project specific instructions in each project's **README** page.


    
## Authors


Contributors names and contact info

[@AbdullahHendy](https://www.linkedin.com/in/abdullah-hendy/)

## Version History

* 0
    * Initial version
