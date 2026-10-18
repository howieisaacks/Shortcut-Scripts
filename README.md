## Add to or Remove from static group in Jamf Pro using Jamf Pro API

This script uses the Jamf Pro API to add a computer to a static group or remove it from a static group. The script was written to be used as a shortcut in macOS. A great use case for this script is quick uninstall and reinstalls of configuration profiles. It has also been used successfully with installing or removing blueprints. If you have a policy scoped to a static group and you want to add a Mac to the group to run the policy, this script will make that very easy.  <br><br>

To use, enter the Jamf Pro static group ID in the first field marked "Group ID". Enter the computer serial number in the field marked "Serial". Use the Add or Remove drop-down menu to select Add or Remove. Click Run.  <br><br>

You need to create a Jamf Pro API client with permission to read and change group membership. A log file will be maintained in your user home folder in a folder called "Dialog-Logs".  <br><br>

![PSSO Status](https://raw.github.com/howieisaacks/Images/main/Add-Remove-Group.png)


## Generate 24-character password

This script generates a 24-character password and displays it using Swift Dialog. It's ready for you to copy and paste into whatever you are working on that needs a strong password.

![Generate Password](https://raw.github.com/howieisaacks/Images/main/Gnerate-24-Chracter-Password.png)
