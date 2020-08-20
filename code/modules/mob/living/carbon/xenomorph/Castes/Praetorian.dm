mob/living/carbon/Xenomorph/Praetorian
	caste = "Praetorian"
	name = "Praetorian"
	desc = "Огромный, Грозный инопланетный зверь."
	icon = 'icons/Xeno/xenomorph_64x64.dmi'
	icon_state = "Praetorian Walking"
	melee_damage_lower = 15
	melee_damage_upper = 25
	tacklemin = 3
	tacklemax = 8
	tackle_chance = 75
	health = 250
	maxHealth = 250
	plasma_stored = 200
	plasma_gain = 25
	plasma_max = 800
	upgrade_threshold = 800
	evolution_allowed = FALSE
	spit_delay = 20
	spit_types = list(/datum/ammo/xeno/toxin/heavy, /datum/ammo/xeno/acid/heavy, /datum/ammo/xeno/sticky)
	speed = -0.5
	pixel_x = -16
	old_x = -16
	caste_desc = "Тьфу!"
	armor_deflection = 35
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	tier = 3
	upgrade = 0
	aura_strength = 1.5 //Praetorian's aura starts strong. They are the Queen's right hand. Climbs by 1 to 4.5
	var/sticky_cooldown = 0
	var/mob/living/carbon/Xenomorph/observed_xeno //the Xenomorph is currently overwatching

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/watch_xeno,
//		/datum/action/xeno_action/deevolve,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/emit_pheromones,
		/datum/action/xeno_action/shift_spits,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/spray_acid,
		/datum/action/xeno_action/activable/aoe2
		)

/mob/living/carbon/Xenomorph/Praetorian/proc/screech()
	if(!check_state())
		return

	if(has_screeched)
		to_chat(src, "<span class='warning'>Вы не готовы снова кричать.</span>")
		return

	if(!check_plasma(250))
		return

	//screech is so powerful it kills huggers in our hands
	if(istype(r_hand, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/FH = r_hand
		if(FH.stat != DEAD)
			FH.Die()

	if(istype(l_hand, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/FH = l_hand
		if(FH.stat != DEAD)
			FH.Die()

	has_screeched = 1
	use_plasma(250)
	spawn(250)
		has_screeched = 0
		to_chat(src, "<span class='warning'>Вы чувствуете, как вибрируют мышцы горла. Вы готовы снова завизжать.</span>")
		for(var/Z in actions)
			var/datum/action/A = Z
			A.update_button_icon()
	playsound(loc, 'sound/voice/alien_queen_screech.ogg', 75, 0)
	visible_message("<span class='xenohighdanger'>\this [src] издает оглушительный гортанный рев!</span>")
	create_s_shriekwave_l() //Adds the visual effect. Wom wom wom
	//stop_momentum(charge_dir) //Screech kills a charge

	for(var/mob/M in view())
		if(M && M.client)
			if(isXeno(M))
				shake_camera(M, 10, 1)
			else
				shake_camera(M, 20, 1) //50 deciseconds, SORRY 5 seconds was way too long. 3 seconds now

	for(var/mob/living/carbon/human/M in oview(7, src))
		if(istype(M.wear_ear, /obj/item/clothing/ears/earmuffs))
			continue
		var/dist = get_dist(src,M)
		if(dist <= 4)
			to_chat(M, "<span class='danger'>Оглушительный гортанный рев сотрясает землю под ногами!</span>")
			M.stunned += 3 //Seems the effect lasts between 3-8 seconds.
			M.KnockDown(4)
			if(!M.ear_deaf)
				M.ear_deaf += 8 //Deafens them temporarily
		else if(dist >= 5 && dist < 7)
			M.stunned += 3
			to_chat(M, "<span class='danger'>Рев сотрясает твое тело до основания, замораживая тебя на месте!</span>")

/mob/living/carbon/Xenomorph/Praetorian/Topic(href, href_list)

	if(href_list["xenotrack"])
		if(!check_state())
			return
		var/mob/living/carbon/Xenomorph/target = locate(href_list["xenotrack"]) in living_mob_list
		if(!istype(target))
			return
		if(target.stat == DEAD || target.z == ADMIN_Z_LEVEL)
			return
		if(target == observed_xeno)
			set_xeno_overwatch(target, TRUE)
		else
			set_xeno_overwatch(target)

	if (href_list["watch_xeno_number"])
		if(!check_state())
			return
		var/xeno_num = text2num(href_list["watch_xeno_number"])
		for(var/mob/living/carbon/Xenomorph/X in living_mob_list)
			if(X.z != ADMIN_Z_LEVEL && X.nicknumber == xeno_num)
				if(observed_xeno == X)
					set_xeno_overwatch(X, TRUE)
				else
					set_xeno_overwatch(X)
				break
		return
	..()

//proc to modify which xeno, if any, the queen is observing.
/mob/living/carbon/Xenomorph/Praetorian/proc/set_xeno_overwatch(mob/living/carbon/Xenomorph/target, stop_overwatch)
	if(stop_overwatch)
		observed_xeno = null
	else
		var/mob/living/carbon/Xenomorph/old_xeno = observed_xeno
		observed_xeno = target
		if(old_xeno)
			old_xeno.hud_set_queen_overwatch()
	if(!target.disposed) //not cdel'd
		target.hud_set_queen_overwatch()
	reset_view()
