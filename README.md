# ArchTimeSaver
A very small and fast Arch Linux (UEFI) installer.
\
\
\
\
\
I beleive the script is readable and very efficient. 
It installs the base system and Gnome DE.
\
### Warning!!
Partitioning is left to the user before running the script,
as partitioning is based on personal preference.
\
Also make sure to edit the script with the apropriate partition paths before running it. 
\
\
\
\
The scrip is oriented on dualbooting a second OS (Windows in this case).
\
\
\
\
To download this script to the Arch Installation USB the "$curl" command can be used:
<pre>$ curl https://raw.githubusercontent.com/S1lverCr0w/ArchTimeSaver/main/arch_install.sh > arch_installscript.sh</pre> 
\
To make the file executable use:
<pre>$ chmod +x arch_installscript.sh</pre>
\
To run the script:
<pre>$ ./arch_installscript.sh</pre>
\
\
\
\
Some code was borrowed from 
https://github.com/Bugswriter/arch-linux-magic
