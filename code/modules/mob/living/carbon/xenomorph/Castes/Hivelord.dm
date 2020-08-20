/mob/living/carbon/Xenomorph/Hivelord
	caste = "Hivelord"
	name = "Hivelord"
	desc = "Огромный ксенос с задницей покрыта странной травой! Вот дерьмо!"
	icon = 'icons/Xeno/xenomorph_64x64.dmi'
	icon_state = "Hivelord Walking"
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
	aura_strength = 1 //Hivelord's aura is not extremely strong, but better than Drones. At the top, it's just a bit above a young Queen. Climbs by 0.5 to 2.5
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
		/datum/action/xeno_action/toggle_speed,
		)



/mob/living/carbon/Xenomorph/Hivelord/movement_delay()
	. = ..()

	if(speed_activated)
		if(locate(/obj/effect/alien/weeds) in loc)
			. -= 1.5

/mob/living/carbon/Xenomorph/Hivelord/Topic(href, href_list)

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
/mob/living/carbon/Xenomorph/Hivelord/proc/set_xeno_overwatch(mob/living/carbon/Xenomorph/target, stop_overwatch)
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
