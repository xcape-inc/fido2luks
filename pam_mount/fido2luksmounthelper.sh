#!/bin/bash
#
# This is a rather minimal example Argbash potential
# Example taken from http://argbash.readthedocs.io/en/stable/example.html
#
# ARG_POSITIONAL_SINGLE([operation],[Operation to perform (mount|umount)],[])
# ARG_OPTIONAL_SINGLE([credentials-type],[c],[Type of the credentials to use (external|embedded)])
# ARG_OPTIONAL_SINGLE([device],[d],[Name of the device to create])
# ARG_OPTIONAL_SINGLE([mount-point],[m],[Path of the mount point to use])
# ARG_OPTIONAL_BOOLEAN([ask-pin],[a],[Ask for a pin],[off])
# ARG_OPTIONAL_SINGLE([salt],[s],[Salt to use],[""])
# ARG_HELP([Unlocks/Locks a LUKS volume and mount/unmount it in the given mount point.])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.9.0 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info
# Generated online by https://argbash.io/generate


die()
{
	local _ret="${2:-1}"
	test "${_PRINT_HELP:-no}" = yes && print_help >&2
	echo "$1" >&2
	exit "${_ret}"
}


begins_with_short_option()
{
	local first_option all_short_options='cdmash'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
_positionals=()
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_credentials_type=
_arg_device=
_arg_mount_point=
_arg_ask_pin="off"
_arg_salt=""


print_help()
{
	printf '%s\n' "Unlocks/Locks a LUKS volume and mount/unmount it in the given mount point."
	printf 'Usage: %s [-c|--credentials-type <arg>] [-d|--device <arg>] [-m|--mount-point <arg>] [-a|--(no-)ask-pin] [-s|--salt <arg>] [-h|--help] <operation>\n' "$0"
	printf '\t%s\n' "<operation>: Operation to perform (mount|umount)"
	printf '\t%s\n' "-c, --credentials-type: Type of the credentials to use (external|embedded) (no default)"
	printf '\t%s\n' "-d, --device: Name of the device to create (no default)"
	printf '\t%s\n' "-m, --mount-point: Path of the mount point to use (no default)"
	printf '\t%s\n' "-a, --ask-pin, --no-ask-pin: Ask for a pin (off by default)"
	printf '\t%s\n' "-s, --salt: Salt to use (default: '""')"
	printf '\t%s\n' "-h, --help: Prints help"
}


parse_commandline()
{
	_positionals_count=0
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			-c|--credentials-type)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_credentials_type="$2"
				shift
				;;
			--credentials-type=*)
				_arg_credentials_type="${_key##--credentials-type=}"
				;;
			-c*)
				_arg_credentials_type="${_key##-c}"
				;;
			-d|--device)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_device="$2"
				shift
				;;
			--device=*)
				_arg_device="${_key##--device=}"
				;;
			-d*)
				_arg_device="${_key##-d}"
				;;
			-m|--mount-point)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_mount_point="$2"
				shift
				;;
			--mount-point=*)
				_arg_mount_point="${_key##--mount-point=}"
				;;
			-m*)
				_arg_mount_point="${_key##-m}"
				;;
			-a|--no-ask-pin|--ask-pin)
				_arg_ask_pin="on"
				test "${1:0:5}" = "--no-" && _arg_ask_pin="off"
				;;
			-a*)
				_arg_ask_pin="on"
				_next="${_key##-a}"
				if test -n "$_next" -a "$_next" != "$_key"
				then
					{ begins_with_short_option "$_next" && shift && set -- "-a" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
				fi
				;;
			-s|--salt)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_salt="$2"
				shift
				;;
			--salt=*)
				_arg_salt="${_key##--salt=}"
				;;
			-s*)
				_arg_salt="${_key##-s}"
				;;
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			*)
				_last_positional="$1"
				_positionals+=("$_last_positional")
				_positionals_count=$((_positionals_count + 1))
				;;
		esac
		shift
	done
}


handle_passed_args_count()
{
	local _required_args_string="'operation'"
	test "${_positionals_count}" -ge 1 || _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require exactly 1 (namely: $_required_args_string), but got only ${_positionals_count}." 1
	test "${_positionals_count}" -le 1 || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect exactly 1 (namely: $_required_args_string), but got ${_positionals_count} (the last one was: '${_last_positional}')." 1
}


assign_positional_args()
{
	local _positional_name _shift_for=$1
	_positional_names="_arg_operation "

	shift "$_shift_for"
	for _positional_name in ${_positional_names}
	do
		test $# -gt 0 || break
		eval "$_positional_name=\${1}" || die "Error during argument parsing, possibly an Argbash bug." 1
		shift
	done
}

parse_commandline "$@"
handle_passed_args_count
assign_positional_args 1 "${_positionals[@]}"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash

if [ -z ${_arg_mount_point} ]; then
  die "Missing '--mount-point' argument"
fi

if [ -z ${_arg_device} ]; then
  die "Missing '--device' argument"
fi

ASK_PIN=${_arg_ask_pin}
OPERATION=${_arg_operation}
DEVICE=${_arg_device}
DEVICE_NAME=$(sed "s|/|_|g" <<< ${DEVICE})
MOUNT_POINT=${_arg_mount_point}
CREDENTIALS_TYPE=${_arg_credentials_type}
SALT=${_arg_salt}
CONF_FILE_PATH="/etc/fido2luksmounthelper.conf"

if [ "${OPERATION}" == "mount" ]; then
	if [ "${CREDENTIALS_TYPE}" == "external" ]; then
    if  [ -f ${CONF_FILE_PATH} ]; then
			if [ "${ASK_PIN}" == "on" ]; then
				read PASSWORD
			fi
			CREDENTIALS=$(<${CONF_FILE_PATH})
		else
			die "The configuration file '${CONF_FILE_PATH}' is missing. Please create it or use embedded credentials."
		fi
		printf ${PASSWORD} | fido2luks open --salt string:${SALT} --pin --pin-source /dev/stdin ${DEVICE} ${DEVICE_NAME} ${CREDENTIALS}
	elif [ "${CREDENTIALS_TYPE}" == "embedded" ]; then
		if [ "${ASK_PIN}" == "on" ]; then
			read PASSWORD
		fi
		printf ${PASSWORD} | fido2luks open-token --salt string:${SALT} --pin --pin-source /dev/stdin ${DEVICE} ${DEVICE_NAME}
	else
		die "Given credential-type '${CREDENTIALS_TYPE}' is invalid. It must be 'external' or 'embedded'"
	fi 
	mount /dev/mapper/${DEVICE_NAME} ${MOUNT_POINT}
elif [ "${OPERATION}" == "umount" ]; then
  umount ${MOUNT_POINT}
  cryptsetup luksClose ${DEVICE_NAME}
else
  die "Given operation '${OPERATION}' is invalid. It must be 'mount' or 'unmount'"
fi

exit 0

# ] <-- needed because of Argbash