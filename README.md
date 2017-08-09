# GearboxAddOn for Farming Simulator 2017

## Current Status
Coexistance of moreRealistic and gearboxAddon was much easier than I thought. It is possible to turn off the MR CVT transmission, and this is was the gearboxAddon automatically does if it is turned on. I looked into moreRealistic and drag, air resistance and rolling resistance are not part of MR CVT transmission. So it works together with the gearboxAddon. But Dural wrote again and again this gearboxAddon is not realistic enough. This is why I stopped the support for moreRealistic. It is working right now. That's it.

Now I try to finalize version 2.1 to update it on ModHub.

There is a new way to specify the gear and ranges the tractor should use during launch. If you change the gear while the tractor is in neutral or auto hold the gearbox will remember this gear and use it again after the next stop or after changing direction. I hope that this change does not cause too much trouble.

It is not possible to lock differentials in the gearboxAddon. You can use the key combinations left shift plus 4, 5 or 6. It might look very simillar like differentaion locking in driveControl. But the underlying implementation is different. This feature only works if driveControl is not used. The gearboxAddon completely unlocks the differential. Based on the differential settings the torque is sent to the slowest of fastet wheel.

## Description
This is the continuation of the mod MoreRealistic GearboxAddon for FS13. In FS15 it works even without MoreRealistic. 
Not every tractor has a continuously variable transmission. And even the continuously variable transmissions are not as simple in construction as the standard one in FS15. This mod adds on the basis of the file zzzMrGearboxAddonConfig.xml a gearbox to all configured tractors. Many various transmission kinds can be simulated. There are classic gearboxes with gears, one or two groups and reverse gears or groups. Shorting the response time to zero will result into a power shift transmission. In modern tractors power shift transmissions are often combined with automatic gear shifting.
New in version 1.1 is now also the support of continuously variable transmissions. There are models with one or two gears like the Fendt Vario. Other models combine four automatically switched mechanical gears with a continuously variable hydrostatic drive. All of these continuously variable transmission have one thing in common. The efficiency varies quite strongly depending on the gear ratio. 

## Keyboard Layout 
If you look at the arm rest of a modern tractor you can find many buttons. Not every buttons operates a function of the transmission of cruise control. But it quickly becomes clear that you will not get along with one or two buttons.

I myself usually drive only with keyboard and without numeric keypad. The left hand operates the keys A, D, W and S. The transmission therefore so must be controllable in essential with the right hand.
Anyone can easily change the key assignments in the options menu within farming simulator 2015. Here are the default settings. Most functions are preset for the keyboard. If you want to play with a steering wheel or a joystick you might have to adjust it. 

### Simple Keys 
These are the settings without pressing any control or shift key. 
*	You change gears with the keys [ and ‘ 
*	You change the levels in group one with ] and \. 
*	Use the spacebar to switch between forward and reverse. 
*	You can override the automatic clutch for about 5. This can be useful when starting on a hill. This is defined as axis with keyboard mapping / and . 
*	Button ; switches the transmission between automatic and manual mode. A purely manual gearbox is switched to neutral here. 
*	The normal cruise control is controlled via the keys 1, 2 and 3. 
*	In addition, you can change the button 4 to a second cruise control speed. The default speed is 10 km / h. 
*	This gearbox also has hand throttle. This in turn is also an axis, which you can assign the joystick or steering wheel itself. On the keyboard to adjust hand throttle with the keys = and - 

### With the right Shift key 
Other features are offered in holding down the right shift key. 
*	Switching within the second group is done with ] and \. Not every tractor has two groups. 
*	If you press the shift key together with the spacebar, then you switch between automatic and manual clutch. This is really only useful if you have a separate clutch pedal as an input device. When you save the game with this setting is saved. 
*	The 3 key together with the shift key (de-) activated the speed limiter. You must continue press the throttle, but you cannot drive faster than a certain speed. The speed changes with the keys 1 and 2 without Shift. 
*	The key 4 in combination with the right shift key sets the current speed as cruise control speed. If cruise control is not on the limiter is activated automatically. 
*	You can also turn off the transmission. Then you have again the simple transmission of Giants along with the regular motor data. When you save the game with this setting is saved.
 
### More unassigned keys 
There are other keys not yet assigned. 
*	1st gear: BUTTON_9 (mrGearboxMogliGEAR1) 
*	2nd gear: BUTTON_10 (mrGearboxMogliGEAR2) 
*	3rd gear: BUTTON_11 (mrGearboxMogliGEAR3) 
*	4th gear: BUTTON_12 (mrGearboxMogliGEAR4) 
*	5th gear: BUTTON_13 (mrGearboxMogliGEAR5) 
*	6th gear: BUTTON_14 (mrGearboxMogliGEAR6) 
*	1st reverse gear: BUTTON_15 (mrGearboxMogliGEARR) 
*	Forward (mrGearboxMogliGEARFWD) 
*	Reverse (mrGearboxMogliGEARBACK) 

## Cruise Control
If you look at videos on the operation of modern tractors, then the speed is often controlled by a cruise control. The setting of the respective velocity in Farming Simulator 2015 have certainly become easier than in the previous version. Unfortunately the switching between different speeds disappeared.
As a solution, the GearboxAddon introduces the key 4 to switch to a second cruise control speed. So you can set the cruise control at the right speed to work. In most cases the maximum speed fits because the farming simulator automatically adjusts the speed with the work unit. But when turning at the end of the field this does not fit anymore. When you lift the implement the tractor will immediately accelerate to maximum speed. The expectation is that when turning it should go slower and not faster! Therefore, the second cruise control speed is set by default to 10 km/h. You can set the current cruise control speed as before with the 1 and 2 keys.
In addition, it bothered me that the tractor when turning on the cruise control or when changing the speed accelerates always at full power. Therefore, you can limit the positive and negative acceleration. The acceleration is limited in cruise control mode only. The tractor still has the full power.
The GearboxAddon stores the second cruise speed of the vehicle during save.

## Hired Worker and Courseplay
If the tractor has a fully automatic or continuously variable transmission, it usually works in conjunction with the hired worker and Play Course. All other gear boxes are switched off automatically as soon as the hired worker or Courseplay is activated. When disabling the helper or Course Play the gearbox automatically switch on again. For a small number of vehicles, such as MAN, it is recommended on hilly maps to deactivate the transmission manually before the starting Courseplay. The long switching times do not work on steep mountains.

## Own configurations 
You can create other configurations yourself. Just create the file zzzMrGearboxAddonConfig.xml directly in the mods folder where you find zzzMrGearboxAddon.zip. There is already such file inside the mod that can used as a template. However, it is not necessary to change anything at zzzMrGearboxAddon.zip or other mods. The zzzMrGearboxAddonConfig.xml file also works in multiplayer . 

## Developer version
Please be aware you're using a developer version, which may and will contain errors, bugs, mistakes and unfinished code. 

You have been warned.

If you're still ok with this, please remember to post possible issues that you find in the developer version. 
That's the only way we can find sources of error and fix them. 
Be as specific as possible:

* tell us the version number
* only use the vehicles necessary, not 10 other ones at a time
* which vehicles are involved, what is the intended action?
* Post! The! Log! to [Gist](https://gist.github.com/) or [PasteBin](http://pastebin.com/)

## Credits
* Stefan Biedenstein
