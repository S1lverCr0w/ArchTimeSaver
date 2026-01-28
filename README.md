# ArchTimeSaver
A very small and fast Arch Linux (UEFI) installer. (about 2min install time including user input)

\
I beleive the script is readable and very efficient. It installs the base system and Gnome DE.
> [!CAUTION]
> Partitioning is left to the user before running the script, as partitioning is based on personal preference.
>> Also make sure to edit the script with the apropriate partition paths before running it.

\
\
The script is oriented on dualbooting a second OS (Windows in this case).
\
\
\
To download this script to the Arch Installation USB the `$ curl` command can be used:
```bash
curl https://raw.githubusercontent.com/S1lverCr0w/ArchTimeSaver/main/archinstall.sh > archinstallscript.sh
```
\
To make the file executable use:
```bash
chmod +x archinstallscript.sh
```
\
To run the script:
```bash
./archinstallscript.sh
```
\
\
Some code was borrowed from
https://github.com/Bugswriter/arch-linux-magic
