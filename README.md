# CPE487 Final Project: Dueling Pianos

### Manavi Panjnani & George Mularadelis

## Introduction

The goal of this project is to create 2 keyboards that each play on one audio channel, allowing users to battle it out on these piano keyboards. In addition to the keyboards, users can also change their octaves as well, allowing them to have more freedom over the songs played.

![SetupFinalProject](https://github.com/user-attachments/assets/7bc1ff99-7367-4e54-8621-03f1fa38ada4)

**Components:**
* Nexys A7-100T Board
* 2 16-button keypad modules
  * Connected to ports JB & JC
* 24-bit digital-to-analog converter (DAC): Pmod I2S
  * Connected to port JA (top 6 pins)
  * 3.5-mm connector for a headphone/speaker needed

Within this project, the keypads and switches act as inputs, and the DAC with the speaker are the outputs of our program. To successfully use these components, we modified the constraints, which are explained in the modifications section.

![DAC](https://github.com/user-attachments/assets/40b7c4a6-6775-4444-b22a-5bbd9f70b56c)
![Keypad](https://github.com/user-attachments/assets/9c268b46-4acd-4965-a26a-4d5097c4a7d4)


## Summary

This lab largely builds off files used in labs 4 & 5, which were the calculator & wailing audio signal labs. Below are the different modules that were pulled from these labs and their functions within our project.

The keypad module is the setup used from lab 4, which reads the inputs with the clock process from the keypad. 

The dad_if module is from lab 5, and takes 16-bit parallel stereo data and converts it to the serial format required by the digital to analog converter.
* When L_start is high, a 16-bit left channel data word is loaded into the 16-bit serial shift register SREG on the falling edge of SCLK.
* When L_start goes low, SCLK shifts the data out of SREG, MSBit first to the serial output SDATA at a rate of 1.56 Mb/s.
* Similarly, when R_start goes high, right channel data is loaded into SREG and then shifted out to SDATA.
* Output data changes on the falling edge of SCLK, so that it is stable when the DAC is reading the data on the rising edge of SCLK.

The wail module is from lab 5, and serves as the file in which the audio signal is produced at the correct pitch given the keypad entry. It also takes the input from the switches and changes the octave depending on which switches are active. 

The tone module from lab 5 generates a signed triangular wave (a tone) at a sampling rate of 48.8 KHz.
* The process cnt_pr generates an unsigned sawtooth waveform count by incrementing a 16-bit counter pitch value every clock cycle.
* The frequency with which it traverses the whole 16-bit count range is thus proportional to pitch.
* The lowest possible tone frequency is obtained when pitch=1.
* It then takes 216 or 65,536 cycles to traverse the range of the counter.
* The frequency is then 48.8 kHz / 216 or 0.745 Hz.
 * This was used to calculate the correct keypad outputs within wail.
* A select signal assignment statement is then used to convert the unsigned sawtooth count into a signed triangle wave.
* The sawtooth count is split up into 4 quadrants quad and an index value within the quadrant.
* The signals quad and index are used to generate a triangle wave.

The siren module is from lab 5, and in this project, it acts as our testbench. Within this code, it initializes all of our entities and runs the main clock process to ensure all components are synchronized and can pass information to one another. 

## Description of inputs from and outputs to the Nexys board from the Vivado project (10 points of the Submission category)

## Images and/or videos of the project in action interspersed throughout to provide context (10 points of the Submission category)

## “Modifications” (15 points of the Submission category)

## Conclude with a summary of the process itself – who was responsible for what components (preferably also shown by each person contributing to the github repository!), the timeline of work completed, any difficulties encountered and how they were solved, etc. (10 points of the Submission category)

