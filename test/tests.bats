#!/home/steam/csgo/bin/bats

@test "steam script filename is patched to fix autoupdates" {
  result="steamcmd.sh"
  [ "$result" == "steamcmd.sh" ]
}

@test "Metamod is installed" {
  run test -f csgo/addons/metamod.vdf
  [ "$status" -eq 0 ]
}

@test "Sourcemod is installed" {
  run test -f csgo/addons/metamod/sourcemod.vdf
  [ "$status" -eq 0 ]
}

@test "SteamWorks is installed" {
  run test -f csgo/addons/sourcemod/extensions/SteamWorks.ext.so
  [ "$status" -eq 0 ]
}

@test "Updater is installed" {
  run test -f csgo/addons/sourcemod/plugins/updater.smx
  [ "$status" -eq 0 ]
}

@test "PugSetup is installed" {
  run test -f csgo/addons/sourcemod/plugins/pugsetup.smx
  [ "$status" -eq 0 ]
}

@test "PracticeMode is installed" {
  run test -f csgo/addons/sourcemod/plugins/practicemode.smx
  [ "$status" -eq 0 ]
}

@test "Retakes is installed and disabled" {
  run test -f csgo/addons/sourcemod/plugins/disabled/retakes.smx
  [ "$status" -eq 0 ]
}

@test "Retakes Instadefuse is installed and disabled" {
  run test -f csgo/addons/sourcemod/plugins/disabled/retakes-instadefuse.smx
  [ "$status" -eq 0 ]
}

@test "Retakes Autoplant is installed and disabled" {
  run test -f csgo/addons/sourcemod/plugins/disabled/retakes_autoplant.smx
  [ "$status" -eq 0 ]
}

@test "Retakes HUD is installed and disabled" {
  run test -f csgo/addons/sourcemod/plugins/disabled/retakes-hud.smx
  [ "$status" -eq 0 ]
}

@test "Steam IDs were added to admins list" {
  run grep -q 'STEAM_1:0:654321' 'csgo/addons/sourcemod/configs/admins_simple.ini' 
  [ "$status" -eq 0 ]
}

@test "PugSetup config modified correctly" {
  run grep -q 'sm_pugsetup_snake_captain_picks \"2\"' 'csgo/cfg/sourcemod/pugsetup/pugsetup.cfg' 
  [ "$status" -eq 0 ]
}

@test "Markers created for caching plugins" {
  num_marker_files=( csgo/*.marker )
  result="${#num_marker_files[@]}"
  [ "$result" -eq 10 ]
}
