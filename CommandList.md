## List of commands
+ QST  
+ QRep  
+ CPGoto *number of area*  
+ CPRGoto *number of room*   
+ CPAT *number of target*  

## Aliases needed
+ This plugin assumes that you have an alias called TARGET. If you do not please add one, the "Replace:" text should be **TARGET** and "With:" text can be **ANYTHING**.  

## How to use the commands
### Commands for use during a quest
+ QST - once you take a quest you just press this and it will send the room name to be for by the mapper, while it runs to the area for you. It also sets a variable - Blowtorch calls these aliases -, called TARGET, with the name of the quest target.  
+ QRep - this function reports the status of your current quest. If you are not on a quest, or have already killed your quest target it reports that you are not on a quest.  
### Commands for use during a campaign
+ CPGoto - once you run cp check, it will generate a list, with a number, then area name and then a sublist of each of the mobs in that area. Use **.CPGoto 1**, to go to the first area listed.  
+ CPAT - use this once you are in the area that your campaign target is in. then use the number in the sublist, for example **.CPAT 1**  
+ CPRGoto - use this during room campaigns. it will generate a list of rooms that you can navigate using **.MapperGotoListNext** and **.MapperGotoListPrevious**  
