## List of commands
+ QST  
+ QRep  
+ CPGoto *number of area/first/last*  
+ CPRGoto *number of room*   
+ CPAT *number of target*  

## Aliases needed
+ This plugin assumes that you have an alias called TARGET. If you do not please add one, the "Replace:" text should be **TARGET** and "With:" text can be **ANYTHING**.  

## How to use the commands
### Commands for use during a quest
+ QST - once you take a quest you just run this function and it will send the room name to be for by the mapper, while it runs to the area for you. It also sets a variable - Blowtorch calls these aliases -, called TARGET, with the name of the quest target.  
+ QRep - this function reports the status of your current quest. If you are not on a quest, or have already killed your quest target it reports that you are not on a quest.  
### Commands for use during a campaign
+ CPGoto - once you run **cp check**, it will generate a list, with a number, then area name and then a sublist of each of the mobs in that area. Use **.CPGoto 1**, to go to the first area listed. Alternatively you can use **.CPGoto first** or **.CPGoto last** to run to and set the first or last area in the list as the current campaign area.  
+ CPAT - use this once you are in the area that your campaign target is in. then use the number in the sublist, for example **.CPAT 1**. This will set the value of the alias we made earlier, TARGET, to the name of your current campaign mob and then run the hunt trick function with that mobs name.  
+ CPRGoto - use this during room campaigns. **.CPRGoto first** or **.CPRGoto last** or **CPRGoto 1**  will generate a list of rooms that you can navigate using **.MapperGotoListNext** and **.MapperGotoListPrevious**  

## Suggested buttons and their content
I suggest that you have a buttons setup to handle most of these functions, as having to type everything everytime is counter productive. You may want to create a "button set" for these and include some of the mapper functions, bound to buttons, in this set.  
A useful feature that is hidden is the **.keyboard popup** function. If you need a button that loads default text that you then wish to provide extra data for, this is the way to do it. For example, with the *.CPGoto* command, you need to supply a number along with it. To do this you create a button and in the * CMD: * part you put **.keyboard popup .CPGoto** ,now when you press that button the command line will already contain .CPGoto and you then just need to type the number of the area.  
