/mob/living/carbon/Xenomorph/Defender
	caste = "Defender"
	name = "Defender"
	desc = "Инопланетянин с бронированным гребнем на голове."
	icon = 'icons/Xeno/xenomorph_64x64.dmi'
	icon_state = "Defender Walking"
	melee_damage_lower = 15
	melee_damage_upper = 25
	health = 250
	maxHealth = 250
	plasma_stored = 50
	plasma_gain = 8
	plasma_max = 100
	evolution_threshold = 200
	upgrade_threshold = 100
	caste_desc = "Крепкая линия фронта дружинником."
	speed = -0.2
	pixel_x = -16
	old_x = -16
	evolves_to = list("Warrior")
	charge_type = 2 //Pounce - Hunter
	armor_deflection = 40
	tier = 1
	upgrade = 0
	var/mob/living/carbon/Xenomorph/observed_xeno //the Xenomorph is currently overwatching

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/watch_xeno,
//		/datum/action/xeno_action/deevolve,
		/datum/action/xeno_action/activable/toggle_crest_defense,
		/datum/action/xeno_action/activable/fortify,
		/datum/action/xeno_action/activable/headbutt,
		/datum/action/xeno_action/activable/tail_sweep
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)

/mob/living/carbon/Xenomorph/Defender/update_icons()
	if (stat == DEAD)
		icon_state = "Defender Dead"
	else if (lying)
		if ((resting || sleeping) && (!knocked_down && !knocked_out && health > 0))
			icon_state = "Defender Sleeping"
		else
			icon_state = "Defender Knocked Down"
	else if (fortify)
		icon_state = "Defender Fortify"
	else if (crest_defense)
		icon_state = "Defender Crest"
	else
		if (m_intent == MOVE_INTENT_RUN)
			icon_state = "Defender Running"
		else
			icon_state = "Defender Walking"

	update_fire() //the fire overlay depends on the xeno's stance, so we must update it.
	update_wounds() //the damage overlay

/mob/living/carbon/Xenomorph/Defender/Topic(href, href_list)

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
/mob/living/carbon/Xenomorph/Defender/proc/set_xeno_overwatch(mob/living/carbon/Xenomorph/target, stop_overwatch)
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
