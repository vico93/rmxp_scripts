# Custom Resolution
Authors: ForeverZer0, KK20, LiTTleDRAgo
Version: 0.97
Type: Game Utility
Key Term: Game Utility


## Introduction

My goal in creating this script was to create a system that allowed the user to set the screen size to something other than 640 x 480, but not have make huge sacrifices in compatibility and performance. Although the script is not simply Plug-and-Play, it is about as close as one can achieve with a script of this nature.

## Features
**Note these were written at the time of v0.93. The following may not be entirely true for the later versions.**

* Totally re-written Tilemap and Plane class. Both classes were written to display the map across any screen size automatically. The Tilemap class is probably even more efficient than the original, which will help offset any increased lag due to using a larger screen size with more sprites being displayed.
* Every possible autotile graphic (48 per autotile) will be cached for the next time that tile is used.
* Autotile animation has been made as efficient as possible, with a system that stores their coodinates, but only if they change. This greatly reduces the number of iterations at each update.
* Option to have the system create an external file to save pre-cached data for autotiles. This will decrease any loading times even more, and only takes a second, depending on the number of maps you have.
* User defined autotile animation speed. Can change with script calls.
* Automatic re-sizing of Bitmaps and Viewports that are 640 x 480 to the defined resolution, unless explicitely over-ridden in the method call. The graphics themselves will not be resized, but any existing scripts that use the normal screen size will already be configured to display different sizes of graphics for battlebacks, pictures, fogs, etc.
* Option to have a log file ouput each time the game is ran, which can alert you to possible errors with map sizes, etc.

## Instructions

1. Place script below default scripts, and above "Main".
2. Any further instructions are in the script.

## Compatibility

This script is not going to be for everyone obviously. A bigger screen means bigger chance of lag.

Custom scripts will need to be made to have windows for your CMS, CBS, and other scenes fill the screen properly.

## Credits and Thanks

* ForeverZer0, for the script.
* Creators of Transition Pack and screenshot.dll
* Selwyn, for base resolution script.
* KK20, for v0.94 (and above) and the Tilemap rewrite (many hours and pages of notes went into this to make it one of the most realistic rewrites out there)
* LiTTleDRAgo, for using some methods from his Core Engine script to make a DLL-less version and continued support/contributions by editing the existing script and creating compatible add-ons

## Author's Notes

Please report any bugs/issues/suggestions. KK20 will be happy to fix them.

**EDIT**: KK20 will no longer be providing support. He has moved on to XP Ace Tilemap.
Enjoy!