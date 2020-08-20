

/obj/item/storage/box/m56_system
	name = "M56 smartgun system"
	desc = "A large case containing the full M56 Smartgun System. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "smartgun_case"
	w_class = 5
	storage_slots = 4
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	open(var/mob/user as mob)
		if(!opened)
			new /obj/item/clothing/glasses/night/m56_goggles(src)
			new /obj/item/weapon/gun/smartgun(src)
//			new /obj/item/smartgun_powerpack(src)   (already for belt/gun/smartgun)
			new /obj/item/clothing/suit/storage/marine/smartgunner(src)
			new /obj/item/storage/belt/gun/smartgun/full(src)
		..()

/obj/item/smartgun_powerpack
	name = "M56 powerpack"
	desc = "Тяжелый армированный рюкзак с вспомогательным оборудованием, силовыми элементами и запасными патронами для системы Smartgun M56.\nClick по значку в левом верхнем углу, чтобы перезарядить M56."
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "powerpack"
	flags_atom = CONDUCT
	flags_equip_slot = SLOT_BACK
	w_class = 5.0
	var/obj/item/cell/pcell = null
	var/rounds_remaining = 500
	var/rounds_max = 500
	actions_types = list(/datum/action/item_action/toggle)
	var/reloading = FALSE

	New()
		select_gamemode_skin(/obj/item/smartgun_powerpack)
		..()
		pcell = new /obj/item/cell(src)

	attack_self(mob/user, automatic = FALSE)
		if(!ishuman(user) || user.stat) return 0

		var/obj/item/weapon/gun/smartgun/mygun = user.get_active_hand()

		if(isnull(mygun) || !mygun || !istype(mygun))
			to_chat(user, "Вы должны держать M56 Smartgun чтобы начать процесс перезарядки.")
			return
		if(rounds_remaining < 1)
			to_chat(user, "Ваш powerpack полностью опустошен! Похоже ты в дерьме чувак!")
			return
		if(!pcell)
			to_chat(user, "У вашего powerpack нет аккумулятора! Засунь один туда!")
			return

		mygun.shells_fired_now = 0 //If you attempt a reload, the shells reset. Also prevents double reload if you fire off another 20 bullets while it's loading.

		if(reloading)
			return
		if(pcell.charge <= 50)
			to_chat(user, "Аккумулятор сел! Вставте новый аккумулятор и установите его!")
			return

		reloading = TRUE
		if(!automatic)
			user.visible_message("[user.name] начинает подавать пояс с боеприпасами в M56 Smartgun.", "Вы начинаете подавать новый пояс боеприпасов в M56 Smartgun. Не двигайся, если хочешь зарядить ленту партон.")
		else
			user.visible_message("[user.name]'s блок питания сервоприводов начнет автоматически подавать боеприпасный ремень в M56 Smartgun.","Блок питания сервоприводов начнет автоматически подавать свежий ремень патронов в M56 Smartgun.")
		var/reload_duration = 50
		if(!automatic)
			if(user.mind && user.mind.cm_skills && user.mind.cm_skills.smartgun>0)
				reload_duration = max(reload_duration - 10*user.mind.cm_skills.smartgun,30)
			if(do_after(user,reload_duration, TRUE, 5, BUSY_ICON_FRIENDLY))
				reload(user, mygun)
			else
				to_chat(user, "Ваша перезарядка была прервана!")
				playsound(src,'sound/machines/buzz-two.ogg', 25, 1)
				reloading = FALSE
				return
		else
			if(autoload_check(user, reload_duration, mygun, src))
				reload(user, mygun, TRUE)
			else
				to_chat(user, "Процесс автоматической зарядки был прерван!")
				playsound(src,'sound/machines/buzz-two.ogg', 25, 1)
				reloading = FALSE
				return
		return 1

	attackby(var/obj/item/A as obj, mob/user as mob)
		if(istype(A,/obj/item/cell))
			var/obj/item/cell/C = A
			visible_message("[user.name] swaps out the power cell in the [src.name].","You swap out the power cell in the [src] and drop the old one.")
			to_chat(user, "The new cell contains: [C.charge] power.")
			pcell.loc = get_turf(user)
			pcell = C
			C.loc = src
			playsound(src,'sound/machines/click.ogg', 25, 1)
		else
			..()

	examine(mob/user)
		..()
		if (get_dist(user, src) <= 1)
			if(pcell)
				to_chat(user, "A small gauge in the corner reads: Ammo: [rounds_remaining] / [rounds_max].")

/obj/item/smartgun_powerpack/proc/reload(mob/user, obj/item/weapon/gun/smartgun/mygun, automatic = FALSE)

		pcell.charge -= 50
		if(!mygun.current_mag)
				var/obj/item/ammo_magazine/internal/smartgun/A = new(mygun)
				mygun.current_mag = A

		var/rounds_to_reload = min(rounds_remaining, (mygun.current_mag.max_rounds - mygun.current_mag.current_rounds)) //Get the smaller value.

		mygun.current_mag.current_rounds += rounds_to_reload
		rounds_remaining -= rounds_to_reload

		if(!automatic)	to_chat(user, "You finish loading [rounds_to_reload] shells into the M56 Smartgun. Ready to rumble!")
		else	to_chat(user, "The powerpack servos finish loading [rounds_to_reload] shells into the M56 Smartgun. Ready to rumble!")
		playsound(user, 'sound/weapons/unload.ogg', 25, 1)

		reloading = FALSE
		return TRUE

/obj/item/smartgun_powerpack/proc/autoload_check(mob/user, delay, obj/item/weapon/gun/smartgun/mygun, obj/item/smartgun_powerpack/powerpack, numticks = 5)
	if(!istype(user) || delay <= 0) return FALSE

	var/mob/living/carbon/human/L
	if(istype(user, /mob/living/carbon/human)) L = user

	var/delayfraction = round(delay/numticks)
	. = TRUE
	for(var/i = 0 to numticks)
		sleep(delayfraction)
		if(!user)
			. = FALSE
			break
		if(!(L.s_store == mygun) && !(user.get_active_hand() == mygun) && !(user.get_inactive_hand() == mygun) || !(L.back == powerpack)) //power pack and gun aren't where they should be.
			. = FALSE
			break

/obj/item/smartgun_powerpack/snow
	icon_state = "s_powerpack"

/obj/item/smartgun_powerpack/fancy
	icon_state = "powerpackw"

/obj/item/smartgun_powerpack/merc
	icon_state = "powerpackp"

/obj/item/storage/box/heavy_armor
	name = "B-Series defensive armor crate"
	desc = "A large case containing an experiemental suit of B18 armor for the discerning specialist."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "armor_case"
	w_class = 5
	storage_slots = 3
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	open(var/mob/user as mob)
		if(!opened)
			new /obj/item/clothing/gloves/marine/specialist(src)
			new /obj/item/clothing/suit/storage/marine/specialist(src)
			new /obj/item/clothing/head/helmet/marine/specialist(src)
		..()

/obj/item/storage/box/m42c_system
	name = "M42A scoped rifle system (recon set)"
	desc = "A large case containing your very own long-range sniper rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = 5
	storage_slots = 12
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/clothing/suit/storage/marine/sniper(src)
			new /obj/item/clothing/glasses/m42_goggles(src)
			new /obj/item/ammo_magazine/sniper(src)
			new /obj/item/ammo_magazine/sniper/incendiary(src)
			new /obj/item/ammo_magazine/sniper/flak(src)
			new /obj/item/device/binoculars(src)
			new /obj/item/storage/backpack/marine/smock(src)
			new /obj/item/weapon/gun/pistol/vp70(src)
			new /obj/item/ammo_magazine/pistol/vp70(src)
			new /obj/item/ammo_magazine/pistol/vp70(src)
			new /obj/item/weapon/gun/rifle/sniper/M42A(src)


	open(var/mob/user as mob) //A ton of runtimes were caused by ticker being null, so now we do the special items when its first opened
		if(!opened) //First time opening it, so add the round-specific items
			if(map_tag)
				switch(map_tag)
					if(MAP_ICE_COLONY)
						new /obj/item/clothing/head/helmet/marine(src)
					else
						new /obj/item/clothing/head/helmet/durag(src)
						new /obj/item/facepaint/sniper(src)
		..()


/obj/item/storage/box/m42c_system_Jungle
	name = "M42A scoped rifle system (marksman set)"
	desc = "A large case containing your very own long-range sniper rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = 5
	storage_slots = 9
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/clothing/suit/storage/marine/sniper/jungle(src)
			new /obj/item/clothing/glasses/m42_goggles(src)
			new /obj/item/clothing/head/helmet/durag/jungle(src)
			new /obj/item/ammo_magazine/sniper(src)
			new /obj/item/ammo_magazine/sniper(src)
			new /obj/item/ammo_magazine/sniper/incendiary(src)
			new /obj/item/weapon/gun/rifle/sniper/M42A/jungle(src)

	open(var/mob/user as mob)
		if(!opened)
			if(map_tag)
				switch(map_tag)
					if(MAP_ICE_COLONY)
						new /obj/item/clothing/under/marine/sniper(src)
						new /obj/item/storage/backpack/marine/satchel(src)
						new /obj/item/bodybag/tarp/snow(src)
					else
						new /obj/item/facepaint/sniper(src)
						new /obj/item/storage/backpack/marine/smock(src)
						new /obj/item/bodybag/tarp(src)
		..()

/obj/item/storage/box/grenade_system
	name = "M92 grenade launcher case"
	desc = "A large case containing a heavy-duty multi-shot grenade launcher, the Armat Systems M92. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "grenade_case"
	w_class = 5
	storage_slots = 3
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/weapon/gun/launcher/m92(src)
			new /obj/item/storage/belt/grenade(src)
			new /obj/item/storage/belt/grenade(src)


/obj/item/storage/box/rocket_system
	name = "M5 RPG crate"
	desc = "A large case containing a heavy-caliber antitank missile launcher and missiles. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "rocket_case"
	w_class = 5
	storage_slots = 6
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/storage/pouch/rpg(src)
			new /obj/item/weapon/gun/launcher/rocket(src)
			new /obj/item/ammo_magazine/rocket(src)
			new /obj/item/ammo_magazine/rocket(src)
			new /obj/item/ammo_magazine/rocket/ap(src)
			new /obj/item/ammo_magazine/rocket/ap(src)
			new /obj/item/ammo_magazine/rocket/wp(src)





////////////////// new specialist systems ///////////////////////////:


/obj/item/storage/box/spec
	var/spec_set

/obj/item/storage/box/spec/st
	name = "Stormtrooper equipment crate"
	desc = "M40 helmet, M40 armor, Montage, 88 mod vp70 and ammo. "
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "rocket_case"
	spec_set = "stormtrooper"
	w_class = 5
	storage_slots = 13
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/clothing/suit/storage/marine/M40(src)
			new /obj/item/clothing/head/helmet/marine/M40(src)
			new /obj/item/weapon/shield/montage(src)
			new /obj/item/weapon/gun/pistol/vp70(src)
			new /obj/item/ammo_magazine/pistol/vp70(src)
			new /obj/item/ammo_magazine/pistol/vp70(src)
			new /obj/item/ammo_magazine/pistol/vp70(src)
			new /obj/item/ammo_magazine/pistol/vp70(src)
			new /obj/item/ammo_magazine/pistol/vp70(src)

/obj/item/storage/box/spec/demolitionist
	name = "Demolitionist equipment crate"
	desc = "A large case containing light armor, a heavy-caliber antitank missile launcher, missiles, C4, claymore mines and one brand new rockets pouch. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "rocket_case"
	spec_set = "demolitionist"
	w_class = 5
	storage_slots = 13
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/clothing/suit/storage/marine/M3T(src)
			new /obj/item/clothing/head/helmet/marine(src)
			new /obj/item/weapon/gun/launcher/rocket(src)
			new /obj/item/ammo_magazine/rocket/ap(src)
			new /obj/item/ammo_magazine/rocket/ap(src)
			new /obj/item/ammo_magazine/rocket/ap(src)
			new /obj/item/ammo_magazine/rocket/wp(src)
			new /obj/item/ammo_magazine/rocket/wp(src)
			new /obj/item/explosive/mine(src)
			new /obj/item/explosive/mine(src)
			new /obj/item/explosive/plastique(src)
			new /obj/item/explosive/plastique(src)
			new /obj/item/storage/pouch/rpg/full(src)



/obj/item/storage/box/spec/sniper
	name = "Sniper equipment"
	desc = "A large case containing your very own long-range sniper rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = 5
	storage_slots = 15
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null
	spec_set = "sniper"

	New()
		..()
		spawn(1)
			new /obj/item/clothing/suit/storage/marine/sniper(src)
			new /obj/item/clothing/glasses/night/m42_night_goggles(src)
			new /obj/item/ammo_magazine/sniper(src)
			new /obj/item/ammo_magazine/sniper(src)
			new /obj/item/ammo_magazine/sniper(src)
			new /obj/item/ammo_magazine/sniper/incendiary(src)
			new /obj/item/ammo_magazine/sniper/incendiary(src)
			new /obj/item/ammo_magazine/sniper/flak(src)
			new /obj/item/ammo_magazine/sniper/flak(src)
			new /obj/item/storage/backpack/marine/smock(src)
			new /obj/item/weapon/gun/pistol/vp70(src)
			new /obj/item/ammo_magazine/pistol/vp70(src)
			new /obj/item/ammo_magazine/pistol/vp70(src)
			new /obj/item/device/binoculars/tactical/scout(src)
			new /obj/item/weapon/gun/rifle/sniper/M42A(src)

	open(mob/user) //A ton of runtimes were caused by ticker being null, so now we do the special items when its first opened
		if(!opened) //First time opening it, so add the round-specific items
			if(map_tag)
				switch(map_tag)
					if(MAP_ICE_COLONY)
						new /obj/item/clothing/head/helmet/marine(src)
					else
						new /obj/item/clothing/head/helmet/durag(src)
						new /obj/item/facepaint/sniper(src)
		..()

/obj/item/storage/box/spec/scout
	name = "Scout equipment"
	desc = "A large case containing Scout equipment. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = 5
	storage_slots = 15
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null
	spec_set = "scout"

	New()
		..()
		spawn(1)
			new /obj/item/clothing/suit/storage/marine/M3S(src)
			new /obj/item/clothing/head/helmet/marine/scout(src)
			new /obj/item/clothing/glasses/night/M4RA(src)
			new /obj/item/ammo_magazine/rifle/m4ra(src)
			new /obj/item/ammo_magazine/rifle/m4ra(src)
			new /obj/item/ammo_magazine/rifle/m4ra(src)
			new /obj/item/ammo_magazine/rifle/m4ra(src)
			new /obj/item/ammo_magazine/rifle/m4ra/incendiary(src)
			new /obj/item/ammo_magazine/rifle/m4ra/incendiary(src)
			new /obj/item/ammo_magazine/rifle/m4ra/impact(src)
			new /obj/item/ammo_magazine/rifle/m4ra/impact(src)
			new /obj/item/device/binoculars/tactical/scout(src)
			new /obj/item/weapon/gun/pistol/vp70(src)
			new /obj/item/ammo_magazine/pistol/vp70(src)
			new /obj/item/ammo_magazine/pistol/vp70(src)
			new /obj/item/weapon/gun/rifle/m4ra(src)
			new /obj/item/storage/backpack/marine/satchel/scout_cloak(src)
			new /obj/item/explosive/plastique(src)
			new /obj/item/explosive/plastique(src)



/obj/item/storage/box/spec/pyro
	name = "Pyrotechnician equipment"
	desc = "A large case containing Pyrotechnician equipment. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "armor_case"
	w_class = 5
	storage_slots = 10
	slowdown = 1
	can_hold = list()
	foldable = null
	spec_set = "pyro"


	New()
		..()
		spawn(1)
			new /obj/item/clothing/suit/storage/marine/M35(src)
			new /obj/item/clothing/head/helmet/marine/pyro(src)
			new /obj/item/storage/backpack/marine/engineerpack/flamethrower(src)
			new /obj/item/weapon/gun/flamer/M240T(src)
			new /obj/item/storage/pouch/pyro/full_bx(src)
			new /obj/item/ammo_magazine/flamer_tank/large(src)
			new /obj/item/ammo_magazine/flamer_tank/large(src)
			new /obj/item/ammo_magazine/flamer_tank/large/B(src)
			new /obj/item/ammo_magazine/flamer_tank/large/X(src)
			new /obj/item/tool/extinguisher/pyro(src)
			new /obj/item/tool/extinguisher/pyro(src)


/obj/item/storage/box/command_kit
	name = "Command Heavy Defens Kit"
	desc = "This is very poverfull kit of experemental commandos rifle!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "command_kit"
	w_class = 5
	storage_slots = 6
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/weapon/gun/rifle/m46c(src)
			new /obj/item/ammo_magazine/rifle/m46c(src)
			new /obj/item/ammo_magazine/rifle/m46c(src)
			new /obj/item/ammo_magazine/rifle/m46c(src)
			new /obj/item/ammo_magazine/rifle/m46c(src)
			new /obj/item/ammo_magazine/rifle/m46c(src)
			new /obj/item/attachable/compensator(src)
			new /obj/item/attachable/scope/iftsscope(src)
			new /obj/item/attachable/fverticalgrip(src)


/obj/item/storage/box/heavy_kit
	name = "Forward HPR Shield Kit"
	desc = "This specialization kit offers the powerful Heavy Pulse Rifle as well as a folding barricade for quick defensive placement and firepower. This specific kit must be handed out from Requisitions.\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "heavy_kit"
	w_class = 5
	storage_slots = 8
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/weapon/gun/rifle/lmg(src)
			new /obj/item/ammo_magazine/rifle/lmg(src)
			new /obj/item/attachable/bipod(src)
			new /obj/item/folding(src)
			new /obj/item/clothing/glasses/welding(src)
			new /obj/item/tool/weldingtool(src)


/obj/item/storage/box/field_kit
	name = "M-OU53 Field Test Kit"
	desc = "This specialization kit gives you access to the limited M-OU53 break action shotgun as well as limited ammo. This specific kit must be handed out from Requisitions.\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "field_kit"
	w_class = 5
	storage_slots = 5
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/weapon/gun/shotgun/mou53(src)
			new /obj/item/attachable/stock/mou53(src)
			new /obj/item/ammo_magazine/shotgun/incendiary(src)
			new /obj/item/ammo_magazine/shotgun/flechette(src)
			new /obj/item/storage/belt/shotgun(src)


/obj/item/storage/box/trooper_kit
	name = "Experimental Trooper Kit"
	desc = "This specialization kit gives you access to the limited SU-6 Smartpistol with extra magazines and attachments to go with it.\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "trooper_kit"
	w_class = 5
	storage_slots = 8
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/storage/belt/gun/su6h/full(src)
			new /obj/item/attachable/attached_gun/flamer(src)
			new /obj/item/attachable/attached_gun/shotgun(src)


/obj/item/storage/box/veteran_kit
	name = "Veteran Kit"
	desc = "This specialization kit give you access to the old MK1 Pulse Rifle as well as spare magazines for it and under barrel attachments. This is one of the kit options of the ColMarTech Automated Closet.\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "veteran_kit"
	w_class = 5
	storage_slots = 8
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/weapon/gun/rifle/m41aMK1(src)
			new /obj/item/ammo_magazine/rifle/m41aMK1(src)
			new /obj/item/ammo_magazine/rifle/m41aMK1(src)
			new /obj/item/ammo_magazine/rifle/m41aMK1(src)
			new /obj/item/ammo_magazine/rifle/m41aMK1(src)
			new /obj/item/ammo_magazine/rifle/m41aMK1(src)
			new /obj/item/attachable/extended_barrel(src)
			new /obj/item/attachable/quickfire(src)
			new /obj/item/attachable/lasersight(src)


/obj/item/storage/box/cts_kit
	name = "Combat Technician Support Kit"
	desc = "This specialization kit gives you the ability to construct defenses such as metal barricades, as well as a starter construction kit for immediate defense. This is one of the kit options of the ColMarTech Automated Closet.\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "cts_kit"
	w_class = 5
	storage_slots = 9
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/storage/backpack/marine/engineerpack(src)
			new /obj/item/storage/pouch/construction/full(src)
			new /obj/item/storage/pouch/tools/full(src)
			new /obj/item/folding(src)
			new /obj/item/clothing/gloves/yellow(src)
			new /obj/item/tool/shovel/etool(src)
			new /obj/item/clothing/glasses/welding(src)
			new /obj/item/stack/sheet/metal/small_stack(src)
			new /obj/item/stack/sandbags_empty/full(src)


/obj/item/storage/box/defense_kit
	name = "Personal Defense Kit"
	desc = "Standard issue won't cut it out on the field when your primary weapon is lost. This specialization kit comes with an VP78 pistol which is a formidable hand gun with attachments and a holster to make it yours. A reliable pistol that also packs a punch. This is one of the kit options of the ColMarTech Automated Closet.\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "defense_kit"
	w_class = 5
	storage_slots = 9
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/weapon/gun/pistol/vp78(src)
			new /obj/item/storage/belt/gun/m4a3(src)
			new /obj/item/attachable/lasersight(src)
			new /obj/item/attachable/reddot(src)
			new /obj/item/ammo_magazine/pistol/vp78(src)
			new /obj/item/ammo_magazine/pistol/vp78(src)
			new /obj/item/ammo_magazine/pistol/vp78(src)
			new /obj/item/ammo_magazine/pistol/vp78(src)
			new /obj/item/ammo_magazine/pistol/vp78(src)


/obj/item/storage/box/sniper_kit
	name = "L42 Sniper Kit"
	desc = "This specialization kit offers long ranged capabilities against targets out of reach with normal primary weapons. It comes with a L42 Pulse Carbine MK1 along with free attachments and AP maganzines. This is one of the kit options of the ColMarTech Automated Closet.\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_kit"
	w_class = 5
	storage_slots = 7
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/weapon/gun/rifle/l42(src)
			new /obj/item/attachable/scope(src)
			new /obj/item/attachable/stock/l_stock(src)
			new /obj/item/attachable/extended_barrel(src)
			new /obj/item/attachable/suppressor(src)
			new /obj/item/ammo_magazine/carabin/ap(src)
			new /obj/item/ammo_magazine/carabin/ap(src)


/obj/item/storage/box/jtac_kit
	name = "JTAC Radio Kit"
	desc = "This specialization kits gives you access to the special JTAC channel for coordinating airstrikes as well as calling them in with tactical binoculars and signal flare packs as well as a flare gun.\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "jtac_kit"
	w_class = 5
	storage_slots = 5
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/storage/belt/gun/m82f/full(src)
			new /obj/item/storage/box/m89(src)
			new /obj/item/storage/box/m89(src)
			new /obj/item/device/binoculars/tactical(src)
			new /obj/item/device/encryptionkey/jtac(src)

/*
/obj/item/storage/box/fis_kit
	name = "Field Intelligence Support Kit"
	desc = "This marine kit gives you equipment for scavenging the Area of Operations for Intel and retrieving it.\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "fis_kit"
	w_class = 5
	storage_slots = 5
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/weapon/combat_knife(src)
			new /obj/item/storage/pouch/document(src)
			new /obj/item/device/data_detector(src)
			new /obj/item/device/encryptionkey/intel(src)
			new /obj/item/device/fulton(src)


*/
/obj/item/storage/box/point_man_kit
	name = "M39 Point Man Kit"
	desc = "This marine kit gives the M39 SMG with the SMG Arm Brace, allowing it to chase after targets with more ease."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "point_man_kit"
	w_class = 5
	storage_slots = 5
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/weapon/gun/smg/m39(src)
			new /obj/item/ammo_magazine/smg/m39/ap(src)
			new /obj/item/ammo_magazine/smg/m39/ap(src)
			new /obj/item/ammo_magazine/smg/m39/ap(src)
			new /obj/item/device/binoculars/tactical(src)
			new /obj/item/attachable/scope/iftsscope(src)
			new /obj/item/attachable/lasersight(src)





/obj/item/storage/box/mini_med_kit
	name = "First Response Medical Support Kit"
	desc = "The marine kit gives you the ability to heal other people with more effectiveness as well as common medical supplies as what a regular combat medic uses."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "medical_support_kit"
	w_class = 5
	storage_slots = 5
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/clothing/glasses/hud/health(src)
			new /obj/item/storage/pouch/respon_med/full(src)
			new /obj/item/storage/pouch/autoinjector/full(src)
			new /obj/item/roller(src)


/obj/item/storage/box/Pyrotechnician_kit
	name = "M240 Pyrotechnician Support Kit"
	desc = "A specialization kit that gives you access to the powerful M240 Flamethrower along with equipment to refuel it and to extinguish any friendly fiery incidents. This is one of the kit options of the ColMarTech Automated Closet.\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "pyrotechnician_kit"
	w_class = 5
	storage_slots = 5
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/storage/backpack/marine/engineerpack/flamethrower2(src)
			new /obj/item/weapon/gun/flamer(src)
			new /obj/item/storage/pouch/pyro/full(src)
			new /obj/item/ammo_magazine/flamer_tank(src)
			new /obj/item/ammo_magazine/flamer_tank(src)
			new /obj/item/tool/extinguisher/pyro(src)


/obj/item/storage/box/grenadier_kit
	name = "Frontline M40 Grenadier kit"
	desc = "A specialization kit that gives you a belt of grenades for all your explosive needs. The HEDP rig comes with free HE/INC/HEFA grenades.\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "grenader_kit"
	w_class = 5
	storage_slots = 5
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/storage/belt/grenade(src)
			new /obj/item/explosive/grenade/phosphorus(src)
			new /obj/item/explosive/grenade/phosphorus(src)
			new /obj/item/explosive/grenade/phosphorus(src)
			new /obj/item/storage/pouch/explosive/full(src)


/obj/item/storage/box/spec/heavy_grenadier
	name = "Heavy Grenadier case"
	desc = "A large case containing M50 Heavy Armor and a heavy-duty multi-shot grenade launcher, the Armat Systems M92. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "grenade_case"
	w_class = 5
	storage_slots = 5
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null
	spec_set = "heavy grenadier"

	New()
		..()
		spawn(1)
			new /obj/item/weapon/gun/launcher/m92(src)
			new /obj/item/storage/belt/grenade(src)
			new /obj/item/clothing/gloves/marine/specialist(src)
			new /obj/item/clothing/suit/storage/marine/specialist(src)
			new /obj/item/clothing/head/helmet/marine/specialist(src)


/obj/item/spec_kit //For events/WO, allowing the user to choose a specalist kit
	name = "specialist kit"
	desc = "A paper box. Open it and get a specialist kit."
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "deliverycrate"

/obj/item/spec_kit/attack_self(mob/user as mob)
	if(user.mind && user.mind.cm_skills && user.mind.cm_skills.spec_weapons < SKILL_SPEC_TRAINED)
		to_chat(user, "<span class='notice'>This box is not for you, give it to a specialist!</span>")
		return
	var/choice = input(user, "Please pick a specalist kit!","Selection") in list("Pyro","Grenadier","Sniper","Scout","Demo")
	var/obj/item/storage/box/spec/S = null
	switch(choice)
		if("Pyro")
			S = /obj/item/storage/box/spec/pyro
		if("Grenadier")
			S = /obj/item/storage/box/spec/heavy_grenadier
		if("Sniper")
			S = /obj/item/storage/box/spec/sniper
		if("Scout")
			S = /obj/item/storage/box/spec/scout
		if("Demo")
			S = /obj/item/storage/box/spec/demolitionist
	new S(loc)
	user.put_in_hands(S)
	cdel()

/obj/item/spec_kit/attack_self(mob/user)
	var/selection = input(user, "Pick your equipment", "Specialist Kit Selection") as null|anything in list("Pyro","Grenadier","Sniper","Scout","Demo")
	if(!selection)
		return
	var/turf/T = get_turf(loc)
	switch(selection)
		if("Pyro")
			new /obj/item/storage/box/spec/pyro (T)
		if("Grenadier")
			new /obj/item/storage/box/spec/heavy_grenadier (T)
		if("Sniper")
			new /obj/item/storage/box/spec/sniper (T)
		if("Scout")
			new /obj/item/storage/box/spec/scout (T)
		if("Demo")
			new /obj/item/storage/box/spec/demolitionist (T)
	cdel(src)
