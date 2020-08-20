/mob/living/carbon/Xenomorph/Runner
	caste = "Runner"
	name = "Runner"
	desc = "Маленький красный инопланетянин, который, похоже, может бегать довольно быстро..."
	icon = 'icons/xeno/xenomorph_64x64.dmi' //They are now like, 2x1 or something
	icon_state = "Runner Walking"
	melee_damage_lower = 10
	melee_damage_upper = 20
	health = 100
	maxHealth = 100
	plasma_stored = 50
	plasma_gain = 1
	plasma_max = 100
	evolution_threshold = 200
	upgrade_threshold = 100
	caste_desc = "Быстрый, четвероногий ужас, но слабый в длительном бою."
	speed = -1.8
	evolves_to = list("Lurker")
	charge_type = 1 //Pounce - Runner
	flags_pass = PASSTABLE
	attack_delay = -4
	tier = 1
	upgrade = 0
	pixel_x = -16  //Needed for 2x2
	old_x = -16
	pull_speed = -1
	var/mob/living/carbon/Xenomorph/observed_xeno //the Xenomorph is currently overwatching

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/watch_xeno,
//		/datum/action/xeno_action/deevolve,
		/datum/action/xeno_action/xenohide,
		/datum/action/xeno_action/activable/pounce,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)

/mob/living/carbon/Xenomorph/Runner/Topic(href, href_list)

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
/mob/living/carbon/Xenomorph/Runner/proc/set_xeno_overwatch(mob/living/carbon/Xenomorph/target, stop_overwatch)
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
