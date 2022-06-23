
#! /bin/sh

# This uninstalls the privileged helper.

sudo launchctl unload /Library/LaunchDaemons/com.notlus.YnFileBrowser.Helper.plist
sudo rm /Library/LaunchDaemons/com.notlus.YnFileBrowser.Helper.plist
sudo rm /Library/PrivilegedHelperTools/com.notlus.YnFileBrowser.Helper

