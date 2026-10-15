#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\gametypes_zm\spawnlogic;
#include maps\mp\gametypes_zm\_hostmigration;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\gametypes_zm\_hud_message;

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
        player thread drawVelocity();
    }
}

drawVelocity()
{
    flag_wait("initial_blackscreen_passed");
    self endon("disconnect");
    level endon("end_game");

    // Resolution-relative bottom-center anchor, lifted slightly from the edge.
    self.velocityHud = createFontString("Objective", 1.7);
    self.velocityHud.alignX = "center";
    self.velocityHud.alignY = "bottom";
    self.velocityHud.horzAlign = "user_center";
    self.velocityHud.vertAlign = "user_bottom";
    self.velocityHud.x = 0;
    self.velocityHud.y = -90;
    self.velocityHud.color = (1, 0, 0);
    self.velocityHud.alpha = 1;
    self.velocityHud.archived = 1;

    for(;;)
    {
        velocity = self getVelocity();
        speed = int(sqrt((velocity[0] * velocity[0]) + (velocity[1] * velocity[1])));

        if(speed < 100)
        {
            self.velocityHud.color = (1, 0.5, 0);      // Orange: 0-99
        }
        else if(speed < 200)
        {
            self.velocityHud.color = (0, 0, 1);      // Blue: 100-199
        }
        else if(speed < 285)
        {
            self.velocityHud.color = (0.5, 0, 1);    // Purple: 200-299
        }
        else
        {
            self.velocityHud.color = (0, 1, 0);      // Green: 300+
        }

        self.velocityHud setValue(speed);
        wait 0.05;
    }
}
