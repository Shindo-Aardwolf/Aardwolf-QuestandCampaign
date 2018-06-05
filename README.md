# Aardwolf-QuestandCampaign

This plugin uses gmcp input to recognise that a quest has been requested and then acts on that.

At this stage the uid of all the start rooms have not been entered into AreasArray.lua which means that some of the functions will still use the runto command. Please note that if your aardwolf.db has not be populated with enough areas it will also not be able to take you to those locations, either because it does not know the path or because you haven't mapped the area yet.

parts of this plugin rely on the mapper plugin
