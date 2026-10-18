#!/bin/zsh --no-rcs

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

:<<'INFO'
----------------------------------------
TITLE: Random Password Generator
VERSION: 1.0
PURPOSE: Generate a randomly generated 24-character password and display it to be copied.

7/8/2026 | Howie Canterbury
----------------------------------------
INFO

# Password generator
generate_password() {
	for ((n=0;n<1;n++))
	do dd if=/dev/urandom count=1 2> /dev/null | uuencode -m - | sed -ne 2p | cut -c-24
	done
}

# Display Dialog with generated password
result_output() {
	local dialog_bin="/usr/local/bin/dialog"
	local result="$1"
	
	dialog_cmd=(
	--small
	--moveable
	--appearance "dark"
	--icon "SF=lock.circle.dotted,palette=#33ab90,#009DDC,none"
	--centreicon
	--bannerimage "colour=#009DDC,nogradient"
	--bannerheight "50"
	--bannertitle "New Password"
	--titlefont "colour=white,size=24,weight=regular,shadow=1"
	--textfield "Generated 24-character password,value="$result""
	--position "center"
	--button1text "Done"
	--buttonsize "large"
	)
	
	"${dialog_bin}" "${dialog_cmd[@]}"
}

# Run
result_output "$(generate_password)"
