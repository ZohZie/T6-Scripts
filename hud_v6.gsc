#include common_scripts\utility;
#include maps\mp\zombies\_zm_net;
#include maps\mp\_utility;
#include mapsmp\zombies\_zm;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_score;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\animscripts\zm_death;
#include maps\mp\zombies\_zm_blockers;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\gametypes_zm\_spectating;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_timer;

/*
	COLORES
	^0 | Black
	^1 | Red
	^2 | Green
	^3 | Yellow
	^4 | Dark Blue
	^5 | Light Blue
	^6 | Pink
	^7 | White
	^8 | Gray
	^9 | Brown
*/

init()
{
	precacheshader( "specialty_chugabud_zombies" );
	precacheshader( "specialty_electric_cherry_zombie" );
	precacheshader( "specialty_vulture_zombies" );
	precacheshader( "minimap_icon_chugabud" );
	precacheshader( "minimap_icon_electric_cherry" );
	precacheshader( "damage_feedback" );
	precacheshader( "zm_riotshield_icon" );
	precacheshader( "zm_riotshield_tomb_icon" );
	precacheshader( "zm_riotshield_hellcatraz_icon" );
	precacheshader( "menu_mp_fileshare_custom" );
	//level.navcards = undefined;
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	while( 1 )
	{
		level waittill( "connected", player );
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	first_spawn = 1;
	
	while( 1 )
	{
		self waittill( "spawned_player" );
		self iprintln("^2HUD Status^7: Health Bar ^2ON^7, Zombies Counter ^2ON");

		if( is_true( first_spawn ) )
		{
			first_spawn = 0;
			self thread first_spawn();
			self thread timer();
			self thread zombiecounter();
			self thread shield_hud();
		}
	}
}

first_spawn()
{
	self._health_overlay.color = ( 0.4, 0, 0 );
	self endon( "disconnect" );
	flag_wait( "initial_blackscreen_passed" );

	// Crear el valor de la salud
	healthvalue = self createfontstring( "default", 1 );
	healthvalue setpoint( "RIGHT", "BOTTOM_LEFT", 59, 18 );
	healthvalue.hidewheninmenu = 1;
	healthvalue.sort = 1;

	// Crear el fondo de la barra de salud
	healthbar_bg = newclienthudelem( self );
	healthbar_bg.x = 0;
	healthbar_bg.y = 0;
	healthbar_bg setshader( "white", 104, 5 );  // Tamaño ligeramente mayor que la barra de salud
	healthbar_bg.alignx = "left";
	healthbar_bg.aligny = "middle";
	healthbar_bg.horzalign = "left";
	healthbar_bg.vertalign = "bottom";
	healthbar_bg.x = healthbar_bg.x + -45;  // Posición ajustada para centrarse en la barra
	healthbar_bg.y = healthbar_bg.y + 7;
	healthbar_bg.color = ( 0, 0, 0 );
	healthbar_bg.alpha = 0.5;  // Fondo semi-transparente
	healthbar_bg.hidewheninmenu = 1;
	healthbar_bg.sort = 0;  // Para asegurarse de que esté detrás de la barra de salud
	
	// Crear la barra de salud
	healthbar = newclienthudelem( self );
	healthbar.x = 0;
	healthbar.y = 0;
	healthbar setshader( "progress_bar_fill", 100, 3 );
	healthbar.alignx = "left";
	healthbar.aligny = "middle";
	healthbar.horzalign = "left";
	healthbar.vertalign = "bottom";
	healthbar.x = healthbar.x + -43;
	healthbar.y = healthbar.y + 7;
	healthbar.hidewheninmenu = 1;
	healthbar.width = 100;
	healthbar.sort = 1;
	
	// Crear el nombre del jugador debajo de la barra de salud
	playername = self createfontstring( "default", 1 );
	playername setpoint( "LEFT", "BOTTOM_LEFT", -45, 18 );  // Ajusta la posición del nombre del jugador
	playername setText( self.name );  // Muestra el nombre del jugador
	playername.hidewheninmenu = 1;
	
	healthbar_mas = self createfontstring( "default", 1.5 );
	healthbar_mas setpoint( "LEFT", "BOTTOM_LEFT", 18, 17 );
	healthbar_mas setText( "+" );
	healthbar_mas.hidewheninmenu = 1;

	while( 1 )
	{
		// Oculta la barra de salud y su fondo si está en el modo afterlife
		if ( IsDefined( self.e_afterlife_corpse ))
		{
			healthbar.alpha = 0;
			healthvalue.alpha = 0;
			playername.alpha = 0;
			healthbar_bg.alpha = 0;
			healthbar_mas.alpha = 0;

			wait 0.05;
            		continue;
        	}
		
		// Verifica si los elementos están ocultos (alpha = 0)
		if ( healthbar.alpha == 0 || healthvalue.alpha == 0 || playername.alpha == 0 || healthbar_bg.alpha == 0 || healthbar_mas.alpha == 0 )
		{
			// Muestra nuevamente la barra de salud, su fondo y el valor de salud
			healthbar.alpha = 1;
			healthvalue.alpha = 1;
			playername.alpha = 1;
			healthbar_bg.alpha = 0.5;  // Restaurar la transparencia del fondo
			healthbar_mas.alpha = 1;
		}
		
		// Actualizar la barra de salud
		if( IsDefined( self.health ) )
		{
			healthbar setshader( "progress_bar_fill", int( 100 * ( self.health / self.maxhealth ) ), 3 ); // int( longitud * () ) ), grosor )
		}

		// Actualizar el valor de la salud
		if( IsDefined( self.health ) )
		{
			healthvalue setText( self.health + "^8/" + self.maxhealth );
		}
		
		// Cambiar color de la barra y el texto de la vida según la salud actual
		if(self.health <= self.maxhealth && self.health >= 71)
		{
			healthvalue.color = (0, 1, 0.5); healthbar_mas.color = (0, 1, 0.5);
			healthbar.color = (0, 1, 0.5);
		}
		else if(self.health <= 70 && self.health >= 50)
		{
			healthvalue.color = (1, 1, 0); healthbar_mas.color = (1, 1, 0);
			healthbar.color = (1, 1, 0);
		}
		else if(self.health <= 49 && self.health >= 25)
		{
			healthvalue.color = (1, 0.5, 0); healthbar_mas.color = (1, 0.5, 0);
			healthbar.color = (1, 0.5, 0);
		}
		else if(self.health <= 24 && self.health >= 0)
		{
			healthvalue.color = (0.5, 0, 0); healthbar_mas.color = (0.5, 0, 0);
			healthbar.color = (0.5, 0, 0);
		}

		wait 0.1;
	}
}

timer()
{
	self endon( "disconnect" );
	timer = newclienthudelem( self );
	timer.alignx = "center";
	timer.aligny = "top";
	timer.horzalign = "center";
	timer.vertalign = "user_top";
	timer.x = timer.x - 1;
	timer.y = timer.y + -2;
	timer.fontscale = 1.4;
	timer.alpha = 0;
	timer.hidewheninmenu = 1;
	flag_wait( "initial_blackscreen_passed" );
	timer.alpha = 0;
	timer settimerup( 0 );
}

zombiecounter()
{
	self endon( "disconnect" );
	level endon( "end_game" );
	flag_wait( "initial_blackscreen_passed" );
	self.zombietext = createfontstring( "hudsmall", 1.2 );
	self.zombietext setpoint( "LEFT", "BOTTOM_LEFT", -45, -7 );
	self.zombietext.hidewheninmenu = 1;
	self.zombietext.sort = 1;

	while( 1 )
	{
		self.zombietext setvalue( get_round_enemy_array().size + level.zombie_total );

		if( get_round_enemy_array().size + level.zombie_total != 0 )
		{
			self.zombietext.label = &"Zombies Left: ^1";
		}
		else
		{
			self.zombietext.label = &"Zombies Left: ^1";
		}

		wait 0.25;
	}
}

shield_hud()
{
	self endon( "disconnect" );
	flag_wait( "initial_blackscreen_passed" );
	shield_text = self createprimaryprogressbartext();
	shield_text setpoint( "CENTER", "CENTER", 275, 225 );
	shield_text.hidewheninmenu = 1;
	shield_hud = newclienthudelem( self );
	shield_hud.alignx = 240;
	shield_hud.aligny = 460;
	shield_hud.horzalign = "center";
	shield_hud.vertalign = "center";
	shield_hud.x = 240;
	shield_hud.y = 460;
	shield_hud.alpha = 0;
	shield_hud.hidewheninmenu = 1;

	if( getdvar( "mapname" ) == "zm_transit" )
	{
		shield_hud setshader( "zm_riotshield_icon", 15, 15 );
	}

	if( getdvar( "mapname" ) == "zm_tomb" )
	{
		shield_hud setshader( "zm_riotshield_tomb_icon", 15, 15 );
	}

	if( getdvar( "mapname" ) == "zm_prison" )
	{
		shield_hud setshader( "zm_riotshield_hellcatraz_icon", 15, 15 );
	}

	for(;;)
	{
		if( self hasweapon( "tomb_shield_zm" ) || self hasweapon( "alcatraz_shield_zm" ) || self hasweapon( "riotshield_zm" ) )
		{
			shield_text.alpha = 1;
			shield_hud.alpha = 1;
		}
		else
		{
			shield_text.alpha = 0;
			shield_hud.alpha = 0;
		}

		shield_text setvalue( 2300 - self.shielddamagetaken );
		wait 0.05;

		if( self.shielddamagetaken >= 2300 )
		{
			shield_text.alpha = 0;
		}
	}

}
