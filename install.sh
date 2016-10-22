#!/usr/bin/env bash
dir=$(dirname "$0")

source $dir/src/tools.sh
source $dir/src/profiles.sh

set_profile_colors() {
  local profile=$1
  local scheme_dir=$dir/colors

  local bg_color_file=$scheme_dir/bgcolor
  local fg_color_file=$scheme_dir/fgcolor
  local bd_color_file=$scheme_dir/bdcolor

  if [ "$newGnome" = "1" ]
    then local profile_path=$dconfdir/$profile

    # set color palette
    dconf write $profile_path/palette "$(to_dconf < $scheme_dir/palette)"

    # set foreground, background and highlight color
    dconf write $profile_path/bold-color "'$(cat $bd_color_file)'"
    dconf write $profile_path/background-color "'$(cat $bg_color_file)'"
    dconf write $profile_path/foreground-color "'$(cat $fg_color_file)'"

    # make sure the profile is set to not use theme colors
    dconf write $profile_path/use-theme-colors "true"

    # set highlighted color to be different from foreground color
    dconf write $profile_path/bold-color-same-as-fg "false"

  else
    local profile_path=$gconfdir/$profile

    # set color palette
    gconftool-2 -s -t string $profile_path/palette "$(to_gconf < $scheme_dir/palette)"

    # set foreground, background and highlight color
    gconftool-2 -s -t string $profile_path/bold_color $(cat $bd_color_file)
    gconftool-2 -s -t string $profile_path/background_color \
        $(cat $bg_color_file)
    gconftool-2 -s -t string $profile_path/foreground_color \
        $(cat $fg_color_file)

    # make sure the profile is set to not use theme colors
    gconftool-2 -s -t bool $profile_path/use_theme_colors false

    # set highlighted color to be different from foreground color
    gconftool-2 -s -t bool $profile_path/bold_color_same_as_fg false
  fi
}

interactive_confirm() {
  local confirmation

  echo    "You have selected:"
  echo
  echo    "  Profile: $(get_profile_name $profile) ($profile)"
  echo
  echo    "Are you sure you want to overwrite the selected profile?"
  echo -n "(YES to continue) "

  read confirmation
  if [[ $(echo $confirmation | tr '[:lower:]' '[:upper:]') != YES ]]
  then
    die "ERROR: Confirmation failed -- ABORTING!"
  fi

  echo    "Confirmation received -- applying settings"
}


if [[ -n "$profile" ]]
  then if [ "$newGnome" = "1" ]
    then profile="$(get_uuid "$profile")"
  fi
  validate_profile $profile
else
  if [ "$newGnome" = "1" ]
    then check_empty_profile
  fi
  interactive_select_profile "${profiles[@]}"
  interactive_confirm
fi

set_profile_colors $profile
