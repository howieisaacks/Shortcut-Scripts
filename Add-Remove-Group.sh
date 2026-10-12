#!/bin/zsh --no-rcs

export PATH=/usr/bin:/bin:/usr/sbin:/sbin
set -euo pipefail

:<<'INFO'
----------------------------------------
TITLE: Add-Remove from computer group
VERSION: 1.0
PURPOSE: Display Dialog to allow entering a group ID and selecting Add or Remove to mange static group membership in Jamf Pro

5/20/2026 | Howie Canterbury
----------------------------------------
INFO

# Global variables
dialog_bin="/usr/local/bin/dialog"
dialog_output="/tmp/dialog-output.json"
currentUser=$(/usr/bin/stat -f "%Su" /dev/console)
log_file="/Users/$currentUser/Dialog-Logs/Add-Remove-Group.log"
log_folder="/Users/$currentUser/Dialog-Logs"

# Jamf Pro API login
url="https://yourserver"
client_id="ENTER_CLIENT_ID"
client_secret="ENTER_CLIENT_SECRET"

# Log function
updateLog() {
	if [[ ! -d "$log_folder" ]]; then
		mkdir -p "$log_folder"
	fi
	
	local message="$1"
	local timestamp
	timestamp=$(/bin/date "+%Y-%m-%d %H:%M:%S")
	echo "${timestamp} | ${message}" | /usr/bin/tee -a "$log_file"
}

# Jamf API client authentication function
jamfAPI_auth() {
	response=$(curl --silent --location --request POST "${url}/api/oauth/token" \
		--header "Content-Type: application/x-www-form-urlencoded" \
		--data-urlencode "client_id=${client_id}" \
		--data-urlencode "grant_type=client_credentials" \
		--data-urlencode "client_secret=${client_secret}")
	token=$(echo "$response" | plutil -extract access_token raw -)
	token_expires_in=$(echo "$response" | plutil -extract expires_in raw -)
}

# Add computer to group
add_to_group() {
	local group_ID="$1"
	local jss_ID="$2"
	updateLog "Adding to group ${group_ID}"
	curl -X PUT "${url}/JSSResource/computergroups/id/$group_ID" -H "Authorization: Bearer ${token}" -H "Content-Type: application/xml" -d "<computer_group><computer_additions><computer><id>$jss_ID</id></computer></computer_additions></computer_group>"
}

# Remove computer from group
remove_from_group() {
	local group_ID="$1"
	local jss_ID="$2"
	updateLog "Removing from group ${group_ID}"
	curl -X PUT "${url}/JSSResource/computergroups/id/$group_ID" -H "Authorization: Bearer ${token}" -H "Content-Type: application/xml" -d "<computer_group><computer_deletions><computer><id>$jss_ID</id></computer></computer_deletions></computer_group>"
}

# Process input from Dialog. Exit if any input field was not used.
process_input() {
	if [[ -z "$group_id" ]] || [[ -z "$serial" ]] || [[ -z "$group_action" ]]; then
		updateLog "No input received"
		exit 0
	fi
	
	updateLog "Working with computer: ${serial}"
	
	# Start authenticated API session
	jamfAPI_auth
	
	case "$group_action" in
		"Add")
		jss_ID=$(curl -G "${url}/api/v1/computers-inventory" --data-urlencode "filter=hardware.serialNumber=="${serial}"" --data-urlencode "section=GENERAL" --header "Authorization: Bearer ${token}" --header "Accept: application/json" | jq -r '.results[0].id')
		add_to_group "$group_id" "$jss_ID"
		;;
		"Remove")
			jss_ID=$(curl -G "${url}/api/v1/computers-inventory" --data-urlencode "filter=hardware.serialNumber=="${serial}"" --data-urlencode "section=GENERAL" --header "Authorization: Bearer ${token}" --header "Accept: application/json" | jq -r '.results[0].id')
			remove_from_group "$group_id" "$jss_ID"
		;;
	esac
}

# Function for displaying Dialog for input
display_dialog() {
	
	if [[ -f "$dialog_output" ]]; then
		rm "$dialog_output"
	fi
	
	"$dialog_bin" \
	--ontop \
	--moveable \
	--appearance "dark" \
	--overlayicon "SF=laptopcomputer,colour=#1d79d0,bgcolor=none,weight=bold" \
	--icon "SF=contextualmenu.and.pointer.arrow,colour=#33ab90,weight=bold" \
	--iconsize "200" \
	--bannerimage "colour=blue,nogradient" \
	--bannerheight "50" \
	--bannertitle "Add to or remove computer from group" \
	--titlefont "colour=white,size=24,weight=thin,shadow=1" \
	--message "1 - Enter group ID<br><br>2 - Enter serial number<br><br>3 - Select Add or Remove" \
	--button1text "Go" \
	--textfield "Group ID" \
	--textfield "Serial" \
	--selecttitle "Add or Remove" \
	--selectvalues "Add,Remove" \
	--buttonsize "large" \
	--json > "$dialog_output"
}


# Main function
main() {
	# Display Dialog for input
	display_dialog
	
	# Data input into Dialog
	group_id=$(/usr/bin/plutil -extract "Group ID" raw "$dialog_output")
	group_action=$(/usr/bin/plutil -extract "Add or Remove.selectedValue" raw "$dialog_output")
	serial=$(/usr/bin/plutil -extract "Serial" raw "$dialog_output")
	
	# Process input data and run add or remove function
	process_input
}

# Run the code!
main "$@"