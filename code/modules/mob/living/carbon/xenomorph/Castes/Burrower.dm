/mob/living/carbon/Xenomorph/Burrower
	caste = "Burrower"
	name = "Burrower"
	desc = "Огромное существо с булькающей кожей! Вот дерьмо!"
	icon = 'icons/Xeno/xenomorph_64x64.dmi'
	icon_state = "Burrower Walking"
	melee_damage_lower = 15
	melee_damage_upper = 20
	health = 220
	maxHealth = 220
	plasma_stored = 200
	plasma_max = 800
	upgrade_threshold = 800
	evolution_allowed = FALSE
	plasma_gain = 35
	caste_desc = "Строитель действительно больших ульев."
	pixel_x = -16
	old_x = -16
	speed = 0.4
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	var/speed_activated = 0
	tier = 2
	upgrade = 0
	aura_strength = 2 //Hivelord's aura is not extremely strong, but better than Drones. At the top, it's just a bit above a young Queen. Climbs by 0.5 to 2.5
	var/mob/living/carbon/Xenomorph/observed_xeno //the Xenomorph is currently overwatching

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/watch_xeno,
//		/datum/action/xeno_action/deevolve,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/choose_resin,
		/datum/action/xeno_action/activable/secrete_resin/hivelord,
		/datum/action/xeno_action/activable/transfer_plasma/hivelord,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/emit_pheromones,
		/datum/action/xeno_action/build_tunnel,
		/datum/action/xeno_action/toggle_speed,
		/datum/action/xeno_action/activable/spray_acid2,
		/datum/action/xeno_action/activable/aoe,
		/datum/action/xeno_action/place_trap
		)



/mob/living/carbon/Xenomorph/Burrower/movement_delay()
	. = ..()

	if(speed_activated)
		if(locate(/obj/effect/alien/weeds) in loc)
			. -= 1.5

/mob/living/carbon/Xenomorph/Burrower/proc/screech()
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
			M.stunned += 4 //Seems the effect lasts between 3-8 seconds.
			M.KnockDown(4)
			if(!M.ear_deaf)
				M.ear_deaf += 4 //Deafens them temporarily
		else if(dist >= 5 && dist < 7)
			M.stunned += 3
			to_chat(M, "<span class='danger'>Рев сотрясает твое тело до основания, замораживая тебя на месте!</span>")


/mob/living/carbon/Xenomorph/Burrower/Topic(href, href_list)

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
/mob/living/carbon/Xenomorph/Burrower/proc/set_xeno_overwatch(mob/living/carbon/Xenomorph/target, stop_overwatch)
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
