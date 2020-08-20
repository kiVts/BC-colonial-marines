/mob/living/carbon/Xenomorph/Warrior
	caste = "Warrior"
	name = "Warrior"
	desc = "Мускулистый алиен с бронированным панцирем."
	icon = 'icons/Xeno/xenomorph_64x64.dmi'
	icon_state = "Warrior Walking"
	melee_damage_lower = 30
	melee_damage_upper = 35
	health = 200
	maxHealth = 200
	plasma_stored = 50
	plasma_gain = 8
	plasma_max = 100
	evolution_threshold = 500
	upgrade_threshold = 250
	caste_desc = "Мощная передняя линия атаки."
	speed = -0.8
	pixel_x = -16
	old_x = -16
	evolves_to = list("Praetorian", "Crusher")
	armor_deflection = 30
	tier = 2
	upgrade = 0
	var/mob/living/carbon/Xenomorph/observed_xeno //the Xenomorph is currently overwatching

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/watch_xeno,
//		/datum/action/xeno_action/deevolve,
		/datum/action/xeno_action/activable/toggle_agility,
		/datum/action/xeno_action/activable/fling,
		/datum/action/xeno_action/activable/lunge,
		/datum/action/xeno_action/activable/punch
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)

/mob/living/carbon/Xenomorph/Warrior/update_icons()
	if (stat == DEAD)
		icon_state = "Warrior Dead"
	else if (lying)
		if ((resting || sleeping) && (!knocked_down && !knocked_out && health > 0))
			icon_state = "Warrior Sleeping"
		else
			icon_state = "Warrior Knocked Down"
	else if (agility)
		icon_state = "Warrior Agility"
	else
		if (m_intent == MOVE_INTENT_RUN)
			icon_state = "Warrior Running"
		else
			icon_state = "Warrior Walking"

	update_fire() //the fire overlay depends on the xeno's stance, so we must update it.
	update_wounds() //the damage overlay

/mob/living/carbon/Xenomorph/Warrior/throw_item(atom/target)
	throw_mode_off()


/mob/living/carbon/Xenomorph/Warrior/stop_pulling()
	if(isliving(pulling))
		var/mob/living/L = pulling
		L.SetStunned(0)
	..()


/mob/living/carbon/Xenomorph/Warrior/start_pulling(atom/movable/AM, lunge, no_msg)
	if (!check_state() || agility)
		return FALSE

	if(!isliving(AM))
		return FALSE
	var/mob/living/L = AM

	if(!isXeno(AM))
		if (used_lunge && !lunge)
			src << "<span class='xenowarning'>Ты должен собраться с силами, прежде чем снова хвататься за шею.</span>"
			return FALSE

		if (!check_plasma(10))
			return FALSE

		if(!lunge)
			used_lunge = 1

	. = ..(AM, lunge, TRUE) //no_msg = true because we don't want to show the defaul pull message

	if(.) //successful pull
		if(!isXeno(AM))
			use_plasma(10)

		if(!isXeno(L) && !isYautja(L))
			round_statistics.warrior_grabs++
			grab_level = GRAB_NECK
			L.drop_held_items()
			L.Stun(5)
			visible_message("<span class='xenowarning'>\The [src] захватывает [L] за горло!</span>", \
			"<span class='xenowarning'>Ты хватаешь [L] за горло!</span>")

	if(!lunge && !isXeno(AM))
		spawn(lunge_cooldown)
			used_lunge = 0
			src << "<span class='notice'>Ты снова готовишься к броску.</span>"
			for(var/X in actions)
				var/datum/action/act = X
				act.update_button_icon()

/mob/living/carbon/Xenomorph/Warrior/hitby(atom/movable/AM as mob|obj,var/speed = 5)
	if(ishuman(AM))
		return
	..()

/mob/living/carbon/Xenomorph/Warrior/Topic(href, href_list)

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
/mob/living/carbon/Xenomorph/Warrior/proc/set_xeno_overwatch(mob/living/carbon/Xenomorph/target, stop_overwatch)
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
