# Project Title

Number Guessing Game (Advanced) 

## Description

Guess a number guided by the RGB LED feedback until the secret number is found


## Dependencies

### Software

* No additional software requirements besides the [main]() requirements.


### Hardware

* [Seven-segment Display PMOD](https://digilent.com/shop/pmod-ssd-seven-segment-display/)
* [16-button Keypad](https://digilent.com/shop/pmod-kypd-16-button-keypad/)
* To avoid having to modify the constraint ***.xdc*** file:
	* Plug the *16-button keypad* in the **JA** PMOD port on the Zybo
	* Plug the *Seven-segment Display* in the first row of the **JC** and **JD** PMOD ports on the Zybo

## How To Use

1. Reset → BTN0
2. Randomize the secret number → BTN1
3. Use the keypad to enter a number (0-99), the entered number will show up on the seven-segment
4. Enter → BTN2
5. If the LED is red, pick a lower number. If the LED is blue, pick a higher number until the secret number is found
6. To show the secret number on the seven-segment display → BTN3


## Documentation



## Version History

* 0
    * Initial version
