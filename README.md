# Nicocoko's Speed Reading
This is a mod for Project Zomboid, aiming to simulate an increase in game speed during book reading time.
While the focus of the mod is multiplayer (in which game speed can't be increased), it works also for single player use cases.

Reading speed can be greatly increased by a given factor (default 20).
At the same time during reading, calorie consumption, hunger, thirst and boredom rates per second become increased by the same factor.

Defaults for the mod can be changed in the sanbdox menu. 
The user may configure the reading speed increase factor, as well as which properties are subjected to the increased consumption rates.

## Technicalities

Heart of the logic is the single Lua file `NSRReadABook`. Here, the mod enhances many of the standard functionalities for the reading book timed action.
Key implementation strategies:

- Shorter reading time: Divide the vanilla time to finish by the given read speed factor
- Additional consumption: Compare the amount of consumption during vanilla time to finish to the speed up time to finish. Apply the difference during the course of the reading.

Consumption rates for hunger, thirst and boredom are based on measurements. 
They are used as magic numbers, expressing how much the property increases per time unit during the game.

Sandbox options are included through the `sandbox-options.txt` file which gets picked up by the game and is implemented. 
Translations for these options are included in the shared lua folder.

## Contributing

If you have any issues with this mod or you want to contribute, please have a look at this [document](https://github.com/nicoprow/zomboid-speed-reading/blob/main/CONTRIBUTING.md) first.
