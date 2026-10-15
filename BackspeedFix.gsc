#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_utility;


init()
{
    level endon("end_game");
    level thread onplayerconnect();
}

onplayerconnect()
{
    for(;;)
        {
            level waittill("connected", player);
            player thread onplayerspawn();
        }
}

onplayerspawn()
{
    level endon("game_ended");
    self endon("disconnect");

    for(;;)
        {
            self waittill("spawned_player");
            self SetClientDvars("player_backSpeedScale", "1");
        }
}
