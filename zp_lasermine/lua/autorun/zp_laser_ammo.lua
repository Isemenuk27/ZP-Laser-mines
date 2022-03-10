game.AddAmmoType( {
	name = "ammo_zp_laser",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 10,
	maxsplash = 5
} )
if CLIENT then
	language.Add("ammo_zp_laser_ammo", "Laser Mine")
end