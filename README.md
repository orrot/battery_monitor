# Description

This is an small script that I use every day to make a different calculation of the battery in my Linux laptops.  It is focused on the battery consumption while the script is started, so there is nothing learning the use or a complex algorithm.

# Purpose

The current Ubuntu battery calculation just takes the rate consumed by the laptop and the remaining battery, to predict how much time could be the machine working. However, even when that calculation sounds well, in the practice, all the time the CPU is increasing/decreasing the consumption depending on the use of the computer. That means that just by clicking one option or opening an application, the consumption could change a lot for a very small amount of seconds. The idea is to consider the consumption when the script starts, and according to the consumed battery, the script could estimate a value, that usually uses to be smaller than the one calculated by the OS.

# Use

The script is just a bash script. I am using along with KDE widgets like: https://store.kde.org/p/1166510/ and https://store.kde.org/p/1297839, to show the information.

<Configured Widgets>

Configuration of the widgets:

## Command output
## Configurable button
