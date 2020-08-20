/obj/item/ammo_magazine/smg
	name = "default SMG magazine"
	desc = "A submachinegun magazine."
	var/serial_number = 0
	default_ammo = /datum/ammo/bullet/smg
	max_rounds = 30

/obj/item/ammo_magazine/smg/New(turf/loc, var/given_serial = 0)
	if(given_serial == 0)
		serial_number = rand(1, 979225)
	else
		serial_number = given_serial
	desc += " Серийный номер [serial_number]"
	..(loc)

//-------------------------------------------------------
//M39 SMG ammo

/obj/item/ammo_magazine/smg/m39
	name = "M39 magazine (10x20mm)"
	desc = "A 10x20mm caseless submachinegun magazine."
	default_ammo = /datum/ammo/bullet/smg
	caliber = "10x20mm"
	icon_state = "m39"
	max_rounds = 48
	w_class = 3
	gun_type = /obj/item/weapon/gun/smg/m39

/obj/item/ammo_magazine/smg/m39/ap
	name = "M39 AP magazine (10x20mm)"
	icon_state = "m39_AP"
	default_ammo = /datum/ammo/bullet/smg/ap

/obj/item/ammo_magazine/smg/m39/incendiary
	name = "M39 Incendiary magazine (10x20mm)"
	icon_state = "m39_incendiary"
	default_ammo = /datum/ammo/bullet/smg/incendiary

/obj/item/ammo_magazine/smg/m39/extended
	name = "M39 extended magazine (10x20mm)"
	max_rounds = 72
	bonus_overlay = "m39_ex"

/obj/item/ammo_magazine/smg/m39/le
	name = "M39 Ligh Explosive magazine (10x20mm)"
	icon_state = "m39_le"
	max_rounds = 6
	default_ammo = /datum/ammo/bullet/smg/le

/obj/item/ammo_magazine/smg/m39/New(turf/loc, var/given_serial = 0)
	if(given_serial == 0)
		serial_number = rand(1, 979225)
	else
		serial_number = given_serial
	desc += " Серийный номер [serial_number]"
	..(loc)

//-------------------------------------------------------
//M5, a classic SMG used in a lot of action movies.

/obj/item/ammo_magazine/smg/mp5
	name = "MP5 magazine (9mm)"
	desc = "A 9mm magazine for the MP5."
	default_ammo = /datum/ammo/bullet/smg
	caliber = "9mm"
	icon_state = "mp7" //PLACEHOLDER
	gun_type = /obj/item/weapon/gun/smg/mp5
	max_rounds = 30 //Also comes in 10 and 40.

/obj/item/ammo_magazine/smg/mp5/New(turf/loc, var/given_serial = 0)
	if(given_serial == 0)
		serial_number = rand(1, 979225)
	else
		serial_number = given_serial
	desc += " Серийный номер [serial_number]"
	..(loc)

//-------------------------------------------------------
//MP27, based on the MP27, based on the M7.

/obj/item/ammo_magazine/smg/mp7
	name = "MP27 magazine (4.6x30mm)"
	desc = "A 4.6mm magazine for the MP27."
	default_ammo = /datum/ammo/bullet/smg/ap
	caliber = "4.6x30mm"
	icon_state = "mp7"
	gun_type = /obj/item/weapon/gun/smg/mp7
	max_rounds = 30 //Also comes in 20 and 40.

/obj/item/ammo_magazine/smg/mp7/New(turf/loc, var/given_serial = 0)
	if(given_serial == 0)
		serial_number = rand(1, 679225)
	else
		serial_number = given_serial
	desc += " Серийный номер [serial_number]"
	..(loc)

//-------------------------------------------------------
//SKORPION //Based on the same thing.

/obj/item/ammo_magazine/smg/skorpion
	name = "CZ-81 magazine (.32ACP)"
	desc = "A .32ACP caliber magazine for the CZ-81."
	caliber = ".32ACP"
	icon_state = "skorpion" //PLACEHOLDER
	gun_type = /obj/item/weapon/gun/smg/skorpion
	max_rounds = 20 //Can also be 10.

/obj/item/ammo_magazine/smg/skorpion/New(turf/loc, var/given_serial = 0)
	if(given_serial == 0)
		serial_number = rand(1, 579225)
	else
		serial_number = given_serial
	desc += " Серийный номер [serial_number]"
	..(loc)

//-------------------------------------------------------
//PPSH //Based on the PPSh-41.

/obj/item/ammo_magazine/smg/ppsh
	name = "PPSh-17b drum magazine (7.62x25mm)"
	desc = "A drum magazine for the PPSh submachinegun."
	default_ammo = /datum/ammo/bullet/smg/ppsh
	caliber = "7.62x25mm"
	icon_state = "ppsh17b"
	max_rounds = 35
	gun_type = /obj/item/weapon/gun/smg/ppsh

/obj/item/ammo_magazine/smg/ppsh/extended
	name = "PPSh-17b extended magazine (7.62x25mm)"
	max_rounds = 71

/obj/item/ammo_magazine/smg/ppsh/New(turf/loc, var/given_serial = 0)
	if(given_serial == 0)
		serial_number = rand(1, 379225)
	else
		serial_number = given_serial
	desc += " Серийный номер [serial_number]"
	..(loc)

//-------------------------------------------------------
//GENERIC UZI //Based on the uzi submachinegun, of course.

/obj/item/ammo_magazine/smg/uzi //Based on the Uzi.
	name = "MAC-15 magazine (9mm)"
	desc = "A magazine for the MAC-15."
	caliber = "9mm"
	icon_state = "mac15"
	max_rounds = 32 //Can also be 20, 25, 40, and 50.
	gun_type = /obj/item/weapon/gun/smg/uzi

/obj/item/ammo_magazine/smg/uzi/extended
	name = "MAC-15 extended magazine (9mm)"
	max_rounds = 50

/obj/item/ammo_magazine/smg/uzi/New(turf/loc, var/given_serial = 0)
	if(given_serial == 0)
		serial_number = rand(1, 79225)
	else
		serial_number = given_serial
	desc += " Серийный номер [serial_number]"
	..(loc)

//-------------------------------------------------------
//FP9000 //Based on the FN P90

/obj/item/ammo_magazine/smg/p90
	name = "FN FP9000 magazine (5.7x28mm)"
	desc = "A magazine for the FN FP9000 SMG."
	default_ammo = /datum/ammo/bullet/smg/ap
	caliber = "5.7x28mm"
	icon_state = "FP9000"
	max_rounds = 50
	gun_type = /obj/item/weapon/gun/smg/p90
