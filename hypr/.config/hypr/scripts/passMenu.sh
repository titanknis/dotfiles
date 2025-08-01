#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) Ayush Agarwal <ayush at ayushnix dot com>
#
# vim: set expandtab ts=2 sw=2 sts=2:
#
# tessen - a data selection interface for pass and gopass on Wayland
# ------------------------------------------------------------------------------

# don't leak password data if debug mode is enabled
#set +x

# GLOBAL VARIABLES
declare _PASS_BACKEND _DMENU_BACKEND _TSN_ACTION _TSN_CONFIG
declare -a _DMENU_BACKEND_OPTS _TMP_TOFI_OPTS _TMP_ROFI_OPTS _TMP_WOFI_OPTS
declare -a _TMP_FUZZEL_OPTS _TMP_YOFI_OPTS
declare _TSN_USERKEY _TSN_URLKEY _TSN_AUTOKEY _TSN_WEB_BROWSER _TSN_OTP _TSN_NOTIFY
declare -i _TSN_DELAY
# show both actions, 'autotype' and 'copy', to choose from by default
_TSN_ACTION="default"
_TSN_OTP=false
_TSN_USERKEY="user"
_TSN_URLKEY="url"
_TSN_AUTOKEY="autotype"
_TSN_DELAY=100
_TSN_NOTIFY=true
if [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/tessen/config ]]; then
    _TSN_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"/tessen/config
elif [[ -f "${XDG_CONFIG_DIRS:-/etc/xdg}"/tessen/config ]]; then
    _TSN_CONFIG="${XDG_CONFIG_DIRS:-/etc/xdg}"/tessen/config
fi
# variables with sensitive data which will be manually unset using _clear
declare _TSN_PASSFILE _TSN_USERNAME _TSN_PASSWORD _TSN_URL _TSN_AUTOTYPE _CHOSEN_KEY
declare -i _EXIT_STATUS
declare -A _TSN_PASSDATA

# FIRST MENU: generate a list of pass files, let the user select one
get_pass_files() {
    local tmp_prefix="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
    if ! [[ -d $tmp_prefix ]]; then
        _die "password store directory not found"
    fi

    local -a tmp_pass_files
    # temporarily enable globbing, get the list of all gpg files recursively,
    # remove PASSWORD_STORE_DIR from the file names, and remove the '.gpg' suffix
    shopt -s nullglob globstar
    tmp_pass_files=("$tmp_prefix"/**/*.gpg)
    tmp_pass_files=("${tmp_pass_files[@]#"$tmp_prefix"/}")
    tmp_pass_files=("${tmp_pass_files[@]%.gpg}")
    shopt -u nullglob globstar

    _TSN_PASSFILE="$(printf "%s\n" "${tmp_pass_files[@]}" |
        "$_DMENU_BACKEND" "${_DMENU_BACKEND_OPTS[@]}")"
    _EXIT_STATUS="$?"

    # instead of searching through the tmp_pass_files array for valid selection,
    # we check if the corresponding file is present
    if ! [[ -f "$tmp_prefix/$_TSN_PASSFILE".gpg ]]; then
        _die
    fi

    unset -v tmp_pass_files tmp_prefix
}

# FIRST MENU: generate a list of gopass files, let the user select one
get_gopass_files() {
    local file
    local -i ctr=0
    local -a tmp_gopass_files
    mapfile -t tmp_gopass_files < <(gopass ls -f)

    _TSN_PASSFILE="$(printf "%s\n" "${tmp_gopass_files[@]}" |
        "$_DMENU_BACKEND" "${_DMENU_BACKEND_OPTS[@]}")"
    _EXIT_STATUS="$?"

    if [[ -z $_TSN_PASSFILE ]]; then
        _die
    fi

    for file in "${tmp_gopass_files[@]}"; do
        if [[ $_TSN_PASSFILE == "$file" ]]; then
            ctr=1
            break
        fi
    done
    if [[ $ctr -ne 1 ]]; then
        _die "the selected file was not found"
    fi

    unset -v file ctr tmp_gopass_files
}

# parse the password store file for username, password, otp, custom autotype,
# and other key value pairs
get_pass_data() {
    local -a passdata
    local keyval_regex otp_regex idx key val

    if [[ $_PASS_BACKEND == "pass" ]]; then
        mapfile -t passdata < <(pass show "$_TSN_PASSFILE" 2>/dev/null)
        if [[ ${#passdata[@]} -eq 0 ]]; then
            _die "the selected file is empty"
        fi
    elif [[ $_PASS_BACKEND == "gopass" ]]; then
        # the output from gopass show -n -f that prints the first line and the
        # newline before EOF doesn't use file descriptors but is printed only when
        # the output is detected to be a terminal ... weird
        mapfile -t passdata < <(gopass show -n -f "$_TSN_PASSFILE" 2>/dev/null)
        if [[ ${#passdata[@]} -eq 0 ]]; then
            _die "the selected file is empty"
        fi
    fi

    keyval_regex='^[[:alnum:][:blank:]+#@_-]+:[[:blank:]].+$'
    # for parsing the 'otpauth://' URI
    # this regex is borrowed from pass-otp at commit 3ba564c
    otp_regex='^otpauth:\/\/(totp|hotp)(\/(([^:?]+)?(:([^:?]*))?)(:([0-9]+))?)?\?(.+)$'
    _TSN_PASSWORD="${passdata[0]}"

    for idx in "${passdata[@]:1}"; do
        key="${idx%%:*}"
        val="${idx#*: }"
        if [[ ${key,,} == "password" ]]; then
            continue
        elif [[ ${key,,} =~ ^$_TSN_USERKEY$ ]] && [[ -z ${_TSN_USERNAME} ]]; then
            _TSN_USERKEY="${key,,}"
            _TSN_USERNAME="$val"
        elif [[ ${key,,} =~ ^$_TSN_AUTOKEY$ ]] && [[ -z ${_TSN_AUTOTYPE} ]]; then
            _TSN_AUTOKEY="${key,,}"
            _TSN_AUTOTYPE="$val"
        elif [[ ${key,,} =~ ^$_TSN_URLKEY$ ]] && [[ -z ${_TSN_URL} ]]; then
            _TSN_URLKEY="${key,,}"
            _TSN_URL="$val"
        elif [[ $idx =~ $otp_regex ]] && [[ $_TSN_OTP == "false" ]]; then
            _TSN_OTP=true
        elif [[ $idx =~ $keyval_regex ]] && [[ -z ${_TSN_PASSDATA["$key"]} ]]; then
            _TSN_PASSDATA["$key"]="$val"
        fi
    done

    # set the value of the _TSN_USERKEY to the default value
    # this prevents the userkey from showing up as a regex in case a user has set
    # it in the config file
    # the same goes for other custom key variables
    if [[ -z $_TSN_USERNAME ]]; then
        _TSN_USERNAME="${_TSN_PASSFILE##*/}"
        _TSN_USERKEY="user"
    fi
    if [[ -z $_TSN_AUTOTYPE ]]; then
        _TSN_AUTOKEY="autotype"
    fi
    if [[ -z $_TSN_URL ]]; then
        _TSN_URLKEY="url"
    fi

    unset -v passdata keyval_regex otp_regex idx key val
}

# map custom actions to specific dmenu exit codes
custom_keyb_action() {
    case "$_EXIT_STATUS" in
    10) auto_type_def ;;
    11) auto_type "$_TSN_USERNAME" ;;
    12) auto_type "$_TSN_PASSWORD" ;;
    13) key_open_url ;;
    14) wld_copy "$_TSN_USERNAME" ;;
    15) wld_copy "$_TSN_PASSWORD" ;;
    16) wld_copy "$_TSN_URL" ;;
    17) key_otp autotype ;;
    18) key_otp copy ;;
    *) _die "unmapped exit code detected" ;;
    esac
}

# SECOND MENU: show a list of possible keys to choose from for autotyping or
# copying, depending on the value of _TSN_ACTION
# THIRD MENU: optional, this will show up if _TSN_ACTION is blank
get_key() {
    local -a key_arr
    local ch flag=false

    # the 2nd menu for autotype, both, and the default actions will be the same
    # and the autotype key will be present in these cases
    # when _TSN_ACTION is set to copy, the autotype key shouldn't be shown in the 2nd menu
    case "$_TSN_ACTION" in
    autotype | both | default)
        if [[ $1 == "key_list" ]]; then
            if [[ $_TSN_OTP == "false" ]] && [[ -z $_TSN_URL ]]; then
                key_arr=("$_TSN_AUTOKEY" "$_TSN_USERKEY" "password" "${!_TSN_PASSDATA[@]}")
            elif [[ $_TSN_OTP == "false" ]] && [[ -n $_TSN_URL ]]; then
                key_arr=("$_TSN_AUTOKEY" "$_TSN_USERKEY" "password" "$_TSN_URLKEY" "${!_TSN_PASSDATA[@]}")
            elif [[ $_TSN_OTP == "true" ]] && [[ -z $_TSN_URL ]]; then
                key_arr=("$_TSN_AUTOKEY" "$_TSN_USERKEY" "password" "otp" "${!_TSN_PASSDATA[@]}")
            elif [[ $_TSN_OTP == "true" ]] && [[ -n $_TSN_URL ]]; then
                key_arr=("$_TSN_AUTOKEY" "$_TSN_USERKEY" "password" "otp" "$_TSN_URLKEY" "${!_TSN_PASSDATA[@]}")
            fi
        fi
        # the (optional) third menu, its appearance depends on _TSN_ACTION being default
        if [[ $_TSN_ACTION == "default" ]] && [[ $1 == "option" ]]; then
            key_arr=("$_TSN_AUTOKEY" "copy")
            # the (optional) third menu if _TSN_URLKEY is chosen, it depends on
            # _TSN_ACTION being default
        elif [[ $_TSN_ACTION == "default" ]] && [[ $1 == "$_TSN_URLKEY" ]]; then
            key_arr=("open" "copy")
        fi
        ;;
    copy)
        if [[ $1 == "key_list" ]]; then
            if [[ $_TSN_OTP == "false" ]] && [[ -z $_TSN_URL ]]; then
                key_arr=("$_TSN_USERKEY" "password" "${!_TSN_PASSDATA[@]}")
            elif [[ $_TSN_OTP == "false" ]] && [[ -n $_TSN_URL ]]; then
                key_arr=("$_TSN_USERKEY" "password" "$_TSN_URLKEY" "${!_TSN_PASSDATA[@]}")
            elif [[ $_TSN_OTP == "true" ]] && [[ -z $_TSN_URL ]]; then
                key_arr=("$_TSN_USERKEY" "password" "otp" "${!_TSN_PASSDATA[@]}")
            elif [[ $_TSN_OTP == "true" ]] && [[ -n $_TSN_URL ]]; then
                key_arr=("$_TSN_USERKEY" "password" "otp" "$_TSN_URLKEY" "${!_TSN_PASSDATA[@]}")
            fi
        fi
        ;;
    esac

    # a global variable to hold the selected key for key_menu
    _CHOSEN_KEY="$(printf "%s\n" "${key_arr[@]}" | "$_DMENU_BACKEND" "${_DMENU_BACKEND_OPTS[@]}")"

    # validate the chosen key, if it doesn't exist, exit
    for ch in "${key_arr[@]}"; do
        if [[ $_CHOSEN_KEY == "$ch" ]]; then
            flag=true
            break
        fi
    done
    if [[ $flag == "false" ]]; then
        _die
    fi

    unset -v key_arr ch flag
}

# SECOND MENU: use 'get_key()' to show a list of possible keys to choose from
key_menu() {
    get_key key_list

    case "$_CHOSEN_KEY" in
    "$_TSN_AUTOKEY") auto_type_def ;;
    "$_TSN_USERKEY") key_action "$_TSN_USERNAME" ;;
    password) key_action "$_TSN_PASSWORD" ;;
    otp) key_otp ;;
    "$_TSN_URLKEY") key_action "$_TSN_URLKEY" ;;
    *) key_action "${_TSN_PASSDATA["$_CHOSEN_KEY"]}" ;;
    esac
}

# this function checks the value of _TSN_ACTION and decides if the third menu
# should be presented or not
# in case it receives "url", autotype becomes equivalent to opening the url in
# a web browser
key_action() {
    local arg="$1"

    case "$_TSN_ACTION" in
    autotype)
        if [[ $arg == "$_TSN_URLKEY" ]]; then
            key_open_url || _die
            return 0
        fi
        auto_type "$arg"
        ;;
    copy)
        if [[ $arg == "$_TSN_URLKEY" ]]; then
            wld_copy "$_TSN_URL" || _die
            return 0
        fi
        wld_copy "$arg"
        ;;
    both)
        if [[ $arg == "$_TSN_URLKEY" ]]; then
            key_open_url
            wld_copy "$_TSN_URL"
        else
            auto_type "$arg"
            wld_copy "$arg"
        fi
        ;;
    default)
        if [[ $arg == "$_TSN_URLKEY" ]]; then
            get_key "$_TSN_URLKEY"
            if [[ $_CHOSEN_KEY == "open" ]]; then
                key_open_url || _die
                return 0
            else
                wld_copy "$_TSN_URL"
            fi
        else
            get_key option
            if [[ $_CHOSEN_KEY == "$_TSN_AUTOKEY" ]]; then
                auto_type "$arg"
            else
                wld_copy "$arg"
            fi
        fi
        ;;
    esac

    unset -v arg
}

# THIRD MENU: optional, this function is used if an 'otpauth://' URI is found
# OTP support in gopass is deprecated
key_otp() {
    local tmp_otp

    if [[ $_PASS_BACKEND == "pass" ]] && ! pass otp -h >/dev/null 2>&1; then
        _die "pass-otp is not installed"
    fi

    if [[ $_PASS_BACKEND == "pass" ]]; then
        tmp_otp="$(pass otp "$_TSN_PASSFILE")"
    elif [[ $_PASS_BACKEND == "gopass" ]]; then
        tmp_otp="$(gopass otp -o "$_TSN_PASSFILE")"
    fi

    if ! [[ $tmp_otp =~ ^[[:digit:]]+$ ]]; then
        _die "invalid OTP detected"
    fi

    if [[ $1 == "autotype" ]]; then
        auto_type "$tmp_otp"
    elif [[ $1 == "copy" ]]; then
        wld_copy "$tmp_otp"
    else
        key_action "$tmp_otp"
    fi

    unset -v tmp_otp
}

key_open_url() {
    if [[ -n $_TSN_WEB_BROWSER ]]; then
        "$_TSN_WEB_BROWSER" "$_TSN_URL" >/dev/null 2>&1 || {
            printf "%s\n" "$_TSN_WEB_BROWSER was unable to open '$_TSN_URL'" >&2
            return 1
        }
    elif is_installed xdg-open; then
        xdg-open "$_TSN_URL" 2>/dev/null || {
            printf "%s\n" "xdg-open was unable to open '$_TSN_URL'" >&2
            return 1
        }
    else
        _die "failed to open '$_TSN_URLKEY'"
    fi
}

# SECOND MENU: the default autotype function, either autotype the username and
# password or the custom autotype defined by the user
auto_type_def() {
    local word tmp_otp

    if [[ -z $_TSN_AUTOTYPE ]]; then
        auto_type "$_TSN_USERNAME"
        wtype -s "$_TSN_DELAY" -k Tab --
        auto_type "$_TSN_PASSWORD"
    else
        for word in $_TSN_AUTOTYPE; do
            case "$word" in
            ":delay") sleep 1 ;;
            ":tab") wtype -s "$_TSN_DELAY" -k Tab -- ;;
            ":space") wtype -s "$_TSN_DELAY" -k space -- ;;
            ":enter") wtype -s "$_TSN_DELAY" -k Return -- ;;
            ":otp") key_otp ;;
            path | basename | filename) auto_type "${_TSN_PASSFILE##*/}" ;;
            "$_TSN_USERKEY") auto_type "$_TSN_USERNAME" ;;
            pass | password) auto_type "$_TSN_PASSWORD" ;;
            *)
                if [[ -n ${_TSN_PASSDATA["$word"]} ]]; then
                    auto_type "${_TSN_PASSDATA["$word"]}"
                else
                    wtype -s "$_TSN_DELAY" -k space --
                fi
                ;;
            esac
        done
    fi
}

auto_type() {
    printf "%s" "$1" | wtype -s "$_TSN_DELAY" -
}

wld_copy() {
    local tsn_cliptime

    if [[ $_PASS_BACKEND == "pass" ]]; then
        tsn_cliptime="${PASSWORD_STORE_CLIP_TIME:-15}"
        if ! are_digits "$tsn_cliptime"; then
            printf "%s\n" "invalid clipboard timeout value in PASSWORD_STORE_CLIP_TIME" >&2
            return 1
        fi
    elif [[ $_PASS_BACKEND == "gopass" ]]; then
        tsn_cliptime="$(gopass config core.cliptimeout)"
        tsn_cliptime="${tsn_cliptime##*: }"
        if ! are_digits "$tsn_cliptime"; then
            printf "%s\n" "invalid clipboard timeout value in cliptimeout" >&2
            return 1
        fi
    fi
    # it would've been better to use, or at least provide an option, to paste
    # only once using `wl-copy -o` but web browsers don't work well with this
    # feature
    # https://github.com/bugaevc/wl-clipboard/issues/107
    printf "%s" "$1" | wl-copy
    if [[ $_TSN_NOTIFY == true ]] && is_installed notify-send; then
        notify-send -t $((tsn_cliptime * 1000)) \
            "data has been copied and will be cleared from the clipboard after $tsn_cliptime seconds"
    fi
    {
        sleep "$tsn_cliptime" || kill 0
        wl-copy --clear
    } >/dev/null 2>&1 &

    unset -v tsn_cliptime
    unset -v _TSN_PASSFILE _TSN_PASSDATA _TSN_USERNAME _TSN_PASSWORD _CHOSEN_KEY
}

are_digits() {
    if [[ $1 =~ ^[[:digit:]]+$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_pass_backend() {
    if ! is_installed "$1"; then
        _die "please install a valid password store backend: pass | gopass"
    fi
    if [[ $1 == "pass" ]] || [[ $1 == "gopass" ]]; then
        _PASS_BACKEND="$1"
    else
        _die "please specify a valid password store backend: pass | gopass"
    fi
}

validate_dmenu_backend() {
    if ! is_installed "$1"; then
        _die "please install a valid dmenu backend: fuzzel | tofi | bemenu | yofi | wofi | rofi | dmenu"
    fi

    local -a bemenu_opts
    case "$1" in
    fuzzel)
        _DMENU_BACKEND="fuzzel"
        _DMENU_BACKEND_OPTS=('-d' '--log-level=warning')
        ;;
    bemenu)
        _DMENU_BACKEND="bemenu"
        _DMENU_BACKEND_OPTS=()
        bemenu_opts=('-l' '10' '-n')
        if [[ -z ${BEMENU_OPTS[*]} ]]; then
            export BEMENU_OPTS="${bemenu_opts[*]}"
        fi
        ;;
    tofi)
        _DMENU_BACKEND="tofi"
        _DMENU_BACKEND_OPTS=()
        ;;
    yofi)
        _DMENU_BACKEND="yofi"
        # yofi needs the 'dialog' option after the '--config-file' argument
        _DMENU_BACKEND_OPTS=('dialog')
        ;;
    wofi)
        _DMENU_BACKEND="wofi"
        _DMENU_BACKEND_OPTS=('-d' '-k' '/dev/null')
        ;;
    rofi)
        _DMENU_BACKEND="rofi"
        _DMENU_BACKEND_OPTS=('-dmenu' '-p' '>')
        ;;
    dmenu)
        _DMENU_BACKEND="dmenu"
        _DMENU_BACKEND_OPTS=()
        ;;
    *)
        _die "please install a valid dmenu backend: fuzzel | tofi | bemenu | yofi | wofi | rofi | dmenu"
        ;;
    esac
    unset -v bemenu_opts
}

validate_action() {
    case "$1" in
    autotype)
        if ! is_installed "wtype"; then
            _die "wtype is not installed, unable to autotype pass data"
        fi
        _TSN_ACTION="autotype"
        ;;
    copy)
        if ! is_installed "wl-copy"; then
            _die "wl-clipboard is not installed, unable to copy-paste pass data"
        fi
        _TSN_ACTION="copy"
        ;;
    both)
        if ! is_installed "wtype"; then
            _die "wtype is not installed, unable to autotype pass data"
        elif ! is_installed "wl-copy"; then
            _die "wl-clipboard is not installed, unable to copy-paste pass data"
        fi
        _TSN_ACTION="both"
        ;;
    default)
        if is_installed "wtype" && is_installed "wl-copy"; then
            _TSN_ACTION="default"
        elif is_installed "wtype" && ! is_installed "wl-copy"; then
            printf "%s\n" "wl-clipboard is not installed, unable to copy-paste pass data" >&2
            _TSN_ACTION="autotype"
        elif ! is_installed "wtype" && is_installed "wl-copy"; then
            printf "%s\n" "wtype is not installed, unable to autotype pass data" >&2
            _TSN_ACTION="copy"
        elif ! is_installed "wtype" && ! is_installed "wl-copy"; then
            _die "please install at least one the following backends to use tessen: wtype | wl-clipboard "
        fi
        ;;
    *) _die "please specify a valid action: autotype | copy | both" ;;
    esac
}

find_pass_backend() {
    local -a tmp_pass_arr=('pass' 'gopass')
    local idx

    for idx in "${tmp_pass_arr[@]}"; do
        if is_installed "$idx"; then
            _PASS_BACKEND="$idx"
            break
        fi
    done
    if [[ -z $_PASS_BACKEND ]]; then
        _die "please install a valid password store backend: pass | gopass"
    fi

    unset -v idx tmp_pass_arr
}

find_dmenu_backend() {
    local -a tmp_dmenu_arr=('fuzzel' 'tofi' 'bemenu' 'yofi' 'wofi' 'rofi' 'dmenu')
    local idx

    for idx in "${tmp_dmenu_arr[@]}"; do
        if is_installed "$idx"; then
            _DMENU_BACKEND="$idx"
            break
        fi
    done
    if [[ -z $_DMENU_BACKEND ]]; then
        _die "please install a valid dmenu backend: fuzzel | tofi | bemenu | yofi | wofi | rofi | dmenu"
    fi
    unset -v idx tmp_dmenu_arr
}

is_installed() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

_clear() {
    unset -v _TSN_PASSFILE _TSN_PASSDATA _TSN_USERNAME _TSN_PASSWORD _TSN_URL
    unset -v _TSN_AUTOTYPE _CHOSEN_KEY
}

_die() {
    if [[ -n $1 ]]; then
        printf "%s\n" "$1" >&2
    fi
    exit 1
}

print_help() {
    local prog="tessen"

    printf "%s" "\
$prog - autotype and copy data from password-store and gopass on wayland

usage: $prog [options]

  $prog                        find a dmenu and pass backend, look for a config
                                file in \$XDG_CONFIG_HOME/tessen/config, and either
                                autotype OR copy data
  $prog -p gopass              use gopass as the pass backend
  $prog -d fuzzel              use fuzzel as the dmenu backend
  $prog -d fuzzel -a autotype  use fuzzel and always autotype data
  $prog -d fuzzel -a copy      use fuzzel and always copy data
  $prog -d fuzzel -a both      use fuzzel and always autotype AND copy data
  $prog -c \$HOME/tsncfg        specify a custom location for the $prog config file

  -p, --pass, --pass=         choose either 'pass' or 'gopass'
  -d, --dmenu, --dmenu=       specify a dmenu backend - 'fuzzel', 'tofi',
                              'bemenu', 'yofi', 'wofi', 'rofi', and 'dmenu' are supported
  -a, --action, --action=     choose either 'autotype', 'copy', or 'both'
                              omit this option to use the default behavior
  -c, --config, --config=     use a config file on a custom path
  -h, --help                  print this help menu
  -v, --version               print the version of $prog

for more details and additional features, please read the man page of $prog(1)

for reporting bugs or feedback, visit one of the following git forge providers
https://sr.ht/~ayushnix/tessen
https://codeberg.org/ayushnix/tessen
https://github.com/ayushnix/tessen
"

    unset -v prog
}

# this block of code is needed because we can't source the file and execute
# arbitrary input
parse_config() {
    local line idx key val
    local -a config_arr
    local config_regex='^[[:alpha:]_]+=[[:print:]]+'
    # in case the user hasn't provided an explicit location, we'll have to check
    # if the default file exists before we parse it
    if [[ -s $_TSN_CONFIG ]]; then
        while read -r line || [[ -n $line ]]; do
            if [[ $line == \#* ]]; then
                continue
            elif [[ $line =~ $config_regex ]]; then
                config_arr+=("$line")
            fi
        done <"$_TSN_CONFIG"
        for idx in "${config_arr[@]}"; do
            key="${idx%=*}"
            val="${idx#*\"}"
            val="${val%*\"}"
            # here comes the ladder
            # the -p, -d, and -a options will be parsed and set only if they're not
            # already set, i.e., from the argparse
            if [[ $key == "pass_backend" ]] && [[ -z $_PASS_BACKEND ]]; then
                validate_pass_backend "$val"
                readonly _PASS_BACKEND
            elif [[ $key == "dmenu_backend" ]] && [[ -z $_DMENU_BACKEND ]]; then
                validate_dmenu_backend "$val"
                readonly _DMENU_BACKEND
            elif [[ $key == "action" ]] && unset -v _TSN_ACTION 2>/dev/null; then
                validate_action "$val"
                readonly _TSN_ACTION
            elif [[ $key == "fuzzel_config_file" ]] && [[ -f ${val@P} ]]; then
                _TMP_FUZZEL_OPTS+=("--config=${val@P}")
            elif [[ $key == "tofi_config_file" ]] && [[ -f ${val@P} ]]; then
                _TMP_TOFI_OPTS+=("-c" "${val@P}")
            elif [[ $key == "rofi_config_file" ]] && [[ -f ${val@P} ]]; then
                _TMP_ROFI_OPTS+=("-config" "${val@P}")
            elif [[ $key == "wofi_config_file" ]] && [[ -f ${val@P} ]]; then
                _TMP_WOFI_OPTS+=("-c" "${val@P}")
            elif [[ $key == "wofi_style_file" ]] && [[ -f ${val@P} ]]; then
                _TMP_WOFI_OPTS+=("-s" "${val@P}")
            elif [[ $key == "wofi_color_file" ]] && [[ -f ${val@P} ]]; then
                _TMP_WOFI_OPTS+=("-C" "${val@P}")
            elif [[ $key == "yofi_config_file" ]] && [[ -f ${val@P} ]]; then
                _TMP_YOFI_OPTS+=("--config-file" "${val@P}")
            elif [[ $key == "userkey" ]]; then
                _TSN_USERKEY="$val"
            elif [[ $key == "urlkey" ]]; then
                _TSN_URLKEY="$val"
            elif [[ $key == "autotype_key" ]]; then
                _TSN_AUTOKEY="$val"
            elif [[ $key == "delay" ]]; then
                _TSN_DELAY="$val"
            elif [[ $key == "web_browser" ]] && is_installed "$val"; then
                _TSN_WEB_BROWSER="$val"
            elif [[ $key == "notify" ]]; then
                _TSN_NOTIFY="$val"
            fi
        done
    fi

    unset -v line key val idx config_arr config_regex
}

main() {
    local -r tsn_version="2.2.3"
    # parse arguments because they have the highest priority
    # make the values supplied to -p, -d, and -a as readonly
    local _opt
    while [[ $# -gt 0 ]]; do
        _opt="$1"
        case "$_opt" in
        -p | --pass)
            if [[ $# -lt 2 ]]; then
                _die "please specify a valid password store backend: pass | gopass"
            fi
            validate_pass_backend "$2"
            readonly _PASS_BACKEND
            shift
            ;;
        --pass=*)
            if [[ -z ${_opt##--pass=} ]]; then
                _die "please specify a valid password store backend: pass | gopass"
            fi
            validate_pass_backend "${_opt##--pass=}"
            readonly _PASS_BACKEND
            ;;
        -d | --dmenu)
            if [[ $# -lt 2 ]]; then
                _die "please install a valid dmenu backend: fuzzel | tofi | bemenu | yofi | wofi | rofi | dmenu"
            fi
            validate_dmenu_backend "$2"
            readonly _DMENU_BACKEND
            # since there's a possibility that a user may mention config files for
            # dmenu backends, we will make _DMENU_BACKEND_OPTS readonly only if
            # _DMENU_BACKEND is bemenu, the only dmenu program which don't support
            # configuration files
            if [[ $_DMENU_BACKEND == "bemenu" ]] || [[ $_DMENU_BACKEND == "dmenu" ]]; then
                readonly _DMENU_BACKEND_OPTS
            fi
            shift
            ;;
        --dmenu=*)
            if [[ -z ${_opt##--dmenu=} ]]; then
                _die "please install a valid dmenu backend: fuzzel | tofi | bemenu | yofi | wofi | rofi | dmenu"
            fi
            validate_dmenu_backend "${_opt##--dmenu=}"
            readonly _DMENU_BACKEND
            if [[ $_DMENU_BACKEND == "bemenu" ]] || [[ $_DMENU_BACKEND == "dmenu" ]]; then
                readonly _DMENU_BACKEND_OPTS
            fi
            ;;
        -a | --action)
            if [[ $# -lt 2 ]]; then
                _die "please specify a valid action: autotype | copy | both"
            fi
            validate_action "$2"
            readonly _TSN_ACTION
            shift
            ;;
        --action=*)
            if [[ -z ${_opt##--action=} ]]; then
                _die "please specify a valid action: autotype | copy | both"
            fi
            validate_action "${_opt##--action=}"
            readonly _TSN_ACTION
            ;;
        -c | --config)
            if [[ $# -lt 2 ]] || ! [[ -f $2 ]]; then
                _die "please specify a valid path for the configuration file of tessen"
            fi
            _TSN_CONFIG="$2"
            shift
            ;;
        --config=*)
            if ! [[ -f ${_opt##--config=} ]]; then
                _die "please specify a valid path for the configuration file of tessen"
            fi
            _TSN_CONFIG="${_opt##--config=}"
            ;;
        -h | --help)
            print_help
            exit 0
            ;;
        -v | --version)
            printf "%s\n" "$tsn_version"
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *) _die "invalid argument detected" ;;
        esac
        shift
    done
    unset -v _opt

    # parse the config file
    # the config file comes AFTER the argparse because the config file has some
    # options that argparse doesn't offer
    # the options which are mutual between the argparse and the config file will
    # be considered in the config file only if those options aren't already set
    parse_config
    if [[ $_DMENU_BACKEND == "fuzzel" ]]; then
        _DMENU_BACKEND_OPTS+=("${_TMP_FUZZEL_OPTS[@]}")
    elif [[ $_DMENU_BACKEND == "tofi" ]]; then
        _DMENU_BACKEND_OPTS+=("${_TMP_TOFI_OPTS[@]}")
        readonly _DMENU_BACKEND_OPTS
    elif [[ $_DMENU_BACKEND == "rofi" ]]; then
        _DMENU_BACKEND_OPTS+=("${_TMP_ROFI_OPTS[@]}")
        readonly _DMENU_BACKEND_OPTS
    elif [[ $_DMENU_BACKEND == "wofi" ]]; then
        _DMENU_BACKEND_OPTS+=("${_TMP_WOFI_OPTS[@]}")
        readonly _DMENU_BACKEND_OPTS
    elif [[ $_DMENU_BACKEND == "yofi" ]]; then
        _DMENU_BACKEND_OPTS=("${_TMP_YOFI_OPTS[@]}" "$_DMENU_BACKEND_OPTS")
        readonly _DMENU_BACKEND_OPTS
    fi

    # initialize basic options for users who expect sane defaults and don't use
    # either the config file or args
    if [[ -z $_PASS_BACKEND ]]; then
        find_pass_backend
        readonly _PASS_BACKEND
    fi
    if [[ -z $_DMENU_BACKEND ]]; then
        find_dmenu_backend
        validate_dmenu_backend "$_DMENU_BACKEND"
        readonly _DMENU_BACKEND
    fi
    if unset -v _TSN_ACTION 2>/dev/null; then
        validate_action "default"
        readonly _TSN_ACTION
    fi

    trap '_clear' EXIT TERM INT
    if [[ $_PASS_BACKEND == "pass" ]]; then
        get_pass_files
    elif [[ $_PASS_BACKEND == "gopass" ]]; then
        get_gopass_files
    fi
    get_pass_data
    if [[ $_EXIT_STATUS -ge 10 ]]; then
        custom_keyb_action
        exit 0
    fi
    key_menu
    trap - EXIT TERM INT
}

main "$@"
