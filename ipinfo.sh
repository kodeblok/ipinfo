#!/bin/sh
# -----------------------------------------------------------------------------
# ipinfo.sh - 
# A shell script to obtain and extract JSON IP address information from 
# ipinfo.io
#
# Copyright (C) 2018, KodeBloK
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License at
# <http://www.gnu.org/licenses/> for more details.
#
# Requirements: sed, awk and curl
#
# -----------------------------------------------------------------------------

clear
readonly PROGNAME=$(basename $0)
readonly ARGS="$@"
readonly ARGSCOUNT="$#"

version() 
{
echo ""
echo "-- $PROGNAME Version 1.0a --" 
echo ""
}

usage() {
	cat <<- EOF
	------------------------------------------------------------

	usage: $PROGNAME options

	This program obtained IP address details from ipinfo.io

	OPTIONS:
		-i --ipaddress       fetch IP Address
		-n --hostname        fetch Hostname
		-c --country         fetch IP country origin
		-v --version         show version
		-h --help            show this usage page
		
	Examples:
		
		Fetch IP Address:
		$PROGNAME -i or $PROGNAME --ipaddress

		Fetch IP Hostname:
		$PROGNAME -n or $PROGNAME --hostname

		Fetch IP Country:
		$PROGNAME -c or $PROGNAME --country

	------------------------------------------------------------

	EOF
}

display_error()
{
echo ""
echo "*** $1 ***"
echo ""
}

get_json_value()
{
  local json_key=$1
  local json_data=$2
  result=$(echo "$json_data" \
           | awk -F=":" -v RS="," '$1~/"'$json_key'"/ {print}' \
           | sed 's/\"//g; s/'$json_key'://; s/[\{\}]//' \
           | awk '{$1=$1};1' \
           | awk NF) 

  if [ "$result" = "" ]; then
  	echo "No value found for key: \"$json_key\""
    exit 1
  else
  	echo "$result"
  fi
}

parse_arguments() {
		# Argument parsing
		if [ $ARGSCOUNT -eq 0 ]; then
			display_error "No options selected"
			usage
		fi
		for arg in $ARGS
	do
		case $arg in
			'-i'|'--ipaddress')
				valid_request=true
				ip_address=true
				;;
			'-n'|'--hostname')
				valid_request=true
				ip_hostname=true
				;;
			'-c'|'--country')
				valid_request=true
				ip_country=true
				;;
			'-v'|'--version')
				version
				;;
			'-h'|'--help')
				usage
				;;
			*)
				display_error "$arg is not a valid option"
				usage
				exit 1
				;;
			-*)
				display_error "No options selected"
				usage
				exit 1
				;;
		esac
		shift
	done

	if [ "$valid_request" = true ]; then
		json_data=$(curl -s ipinfo.io)
		
		if [ "$ip_address" = true ]; then
			echo $(get_json_value ip "$json_data")
		fi

		if [ "$ip_hostname" = true ]; then
			echo $(get_json_value hostname "$json_data")
		fi

		if [ "$ip_country" = true ]; then
			echo $(get_json_value country "$json_data")
		fi

	fi

}

main() 
{
		parse_arguments
}

main 