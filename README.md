# ECE 3710 Project 1 - SUMO
**Erik Sargent and Westen Jensen**  
October 13, 2015


##Introduction
This game is fashioned after the ancient art of Sumo wrestling. Two LED lights light up across from each other on a bar LED, by pressing your button you move towards your opponents light. Each round starts with the LEDs moving apart, then the players race to press their buttons. The player who presses their button first will move forward and the other player has a short amount of time to also press their button to tie the round before they lose and the first player wins and advances. Following this procedure players are to compete against each other to push the other one to the end of the bar LED. When both LEDs are at one end of the bar LED, the game is over and the lights flash until the game is restarted.

##Scope
This document contain a complete description of the hardware and software design for SUMO. The full source code is located at the end of this document.

##Design Overview

###Requirements
1. The system shall run on `3.3V` DC supply.
2. The system shall use a 10 LED bar graph to display output of the game, on each end a button shall be in close proximity.
3. The system shall have 3 buttons, two player buttons and a reset button
4. The system shall have a DIP switch that will be used to calculate the speed of delay between turns.
5. After the system is reset, the two center LEDs of the bar graph shall flash at a rate of `2Hz`, which is controlled by a timer. The LED on the left represents player 1 and the LED on the right represents player 2.
6. Each player will indicate they are ready to play by pressing the button on their side of the LED bar graph.
7. The buttons shall be sampled at least every `5ms`.
8. Once a player presses their button to indicate they are ready to play their LED shall be lit solidly.
9. At some random time at least 1 second but no more than 2 seconds after (a) both players indicate their readiness to play or (b) a move concludes that does not end the game, the leftmost lit LED shall move one spot to the left and the rightmost lit LED shall move one spot to the right. This event starts the move.
10. After the move starts, each player races to press their button. As soon as a button is pressed, the corresponding players lit LED moves back to its prior position and a timer is started.
11.  If the timer in (9) expires before the opponent presses their button (and moves their lit LED), the quicker players lit LED shall move again and be adjacent to their opponent's lit LED. Otherwise, the move is a draw.
12. If the result of this move is that the two lit LEDs are on the leftmost or rightmost side of the bar graph, the game is over and the 2 lit LEDs shall ash at a rate of `2Hz` until the system is reset.
13. The delay time in (9) shall be based on the players speed, Sn, and the number of contiguous drawn moves, d. If player n is the first to press their button, the delay in milliseconds shall be $$2^{-min(d,4)} (320 – 80Sn)$$.

###Materials
* DC power Supply (3.3 Volt)
* Breadboard
* Momentary push button (2)
* 10 LED Bar graph
* 220Ω resistors for the LEDs
* Tiva C micro controller
* Assorted connection wires

###Theory of Operation
Upon power-up or reset the game shall start with the two middle LED’s flashing. Each player will then indicate their readiness to play by pressing the button on their end of the bar LED. After a player indicates they are ready, the LED on their side will be lit solid, once both players indicate they are ready to play at least 1 second but no longer than 2 seconds later the LEDs will move one LED away towards their respective sides indicating the game has begun. The players will now race to press their buttons to move in the direction of their opponent. If player 1 presses their button faster than player 2 then both LED will move in the direction of player 2’s side of the board. If both players were to press their buttons at the same time it would result in a draw and neither player would win the round. This continues until one player pushes the other to the other end of the board, when this occurs the game has been won, the LEDs then will flash until the reset button is pressed and the game is allowed to start over.

##Design Details
###Hardware Design
SUMO is implemented on a Tiva C Series TM4C123G microcontroller board. The output is displayed on a 10 LED bar graph display. A total of 3 buttons are used, there are 2 external buttons for player one and player two to play the game, and the reset button which is located on the board to reset the game once completed. A 4 position DIP switch is used for the players to enter in the difficulty level they would like to use, each player can use the switches to input a 2 bit number which is used in the formula to calculate how long of a delay should be used each round. See Figure 1. for an illustration of how the hardware should be laid out.

######Figure 1 - Hardware Design
![](hardware.png)

###Software Design
The software was broken up into 5 different sections: Setup, Pregame, Game, Move, and End Game. 

####Setup
In setup section all timers, clocks, and GPIO ports are configured and enabled for the game.
Moving into pregame state the middle LEDs are lit up and begin flashing, using two timers we flash the lights at 2Hz and check for user input at least every 5ms. Once the players both indicate they are ready to play we move into the game state. In the game state, a random delay is calculated between 1 and 2 seconds and is placed into a timer. When the timer expires the LEDs move apart and we move into the move state. The move state is the state where the players race against each other to press their button and push the opponent to the other side of the board. If a player is successful in pressing their button before their opponent the LED lights are shifted in the correct direction, a new timer is started and players are allowed to race against each other. The program then checks to see if a player has won the game, if not the game loops back to game state to begin the process again, otherwise we move into the end game state. In the end game state the LEDs flash at 2Hz at their current position at one end of the board. If at any time the reset is pressed the program starts over and begins at the beginning in the setup state. Below in Figure 2 is a flow chart of how the game proceeds through the code.

######Figure 2 - Program Flow Chart
![](flow.png)

##Testing
![](tek0001.png)
![](tek0002.png)

##Conclusion
In conclusion we have been able to create a working prototype for the SUMO game as shown in our design document. Testing our project with a logic analyzer we were able to meet the qualifications of the 2Hz flashing LED, 5ms button sampling, and enable a random timer for each turn. The hardware is compact enough that a casing could be easily made. When designing the casing for this game factors such as heat displacement should be taken into consideration as we did not test for this and could be a factor that could affect the game performance. 
