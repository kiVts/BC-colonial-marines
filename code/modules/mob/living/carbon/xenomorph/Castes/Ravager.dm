/mob/living/carbon/Xenomorph/Ravager
	caste = "Ravager"
	name = "Ravager"
	desc = "Огромный, отвратительный красный алиен с огромными когтями."
	icon = 'icons/Xeno/xenomorph_64x64.dmi'
	icon_state = "Ravager Walking"
	melee_damage_lower = 25
	melee_damage_upper = 35
	tacklemin = 3
	tacklemax = 6
	tackle_chance = 80
	health = 200
	maxHealth = 200
	plasma_stored = 50
	plasma_gain = 8
	plasma_max = 100
	upgrade_threshold = 800
	evolution_allowed = FALSE
	caste_desc = "Жестокий, разрушительный нападающий на передовой."
	speed = -0.7 //Not as fast as runners, but faster than other xenos.
	var/usedcharge = 0 //What's the deal with the all caps?? They're not constants :|
	var/CHARGESPEED = 2
	var/CHARGESTRENGTH = 2
	var/CHARGEDISTANCE = 4
	var/CHARGECOOLDOWN = 120
	var/mob/living/carbon/Xenomorph/observed_xeno //the Xenomorph is currently overwatching
	charge_type = 3 //Claw at end of charge
	fire_immune = 1
	armor_deflection = 40
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	xeno_explosion_resistance = 2 //no stuns from explosions
	attack_delay = -2
	tier = 3
	upgrade = 0
	pixel_x = -16
	old_x = -16

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/watch_xeno,
//		/datum/action/xeno_action/deevolve,
		/datum/action/xeno_action/activable/charge,
		)


/mob/living/carbon/Xenomorph/Ravager/proc/charge(atom/T)
	if(!T) return

	if(!check_state())
		return

	if(usedPounce)
		return

	if(!check_plasma(20))
		return

	if(legcuffed)
		src << "<span class='xenodanger'>Ты не можешь атаковать с этой штукой на ноге!</span>"
		return

	visible_message("<span class='danger'>[src] обвинения в адрес \the [T]!</span>", \
	"<span class='danger'>Вы несетесь навстречу \the [T]!</span>" )
	emote("roar") //heheh
	usedPounce = 1 //This has to come before throw_at, which checks impact. So we don't do end-charge specials when thrown
	use_plasma(20)
	throw_at(T, CHARGEDISTANCE, CHARGESPEED, src)
	spawn(CHARGECOOLDOWN)
		usedPounce = 0
		src << "<span class='notice'>Ваш экзоскелет дрожит, когда вы готовитесь снова зарядить.</span>"
		for(var/X in actions)
			var/datum/action/A = X
			A.update_button_icon()


//Chance of insta limb amputation after a melee attack.
/mob/living/carbon/Xenomorph/Ravager/proc/delimb(var/mob/living/carbon/human/H, var/datum/limb/O)
	if (prob(isYautja(H)?10:20)) // lets halve this for preds
		O = H.get_limb(check_zone(zone_selected))
		if (O.body_part != UPPER_TORSO && O.body_part != LOWER_TORSO && O.body_part != HEAD) //Only limbs.
			visible_message("<span class='danger'>Конечность отрезана начисто!</span>","<span class='danger'>Ты отрубаешь конечность!</span>")
			O.droplimb()
			return 1

	return 0

//Super hacky firebreathing Halloween rav.
/mob/living/carbon/Xenomorph/Ravager/ravenger
	name = "Ravenger"
	desc = "Это чертов дракон! Беги! РААААН!"
	is_intelligent = 1
	hardcore = 1
	melee_damage_lower = 70
	melee_damage_upper = 90
	tacklemin = 3
	tacklemax = 6
	tackle_chance = 85
	health = 600
	maxHealth = 600
	plasma_stored = 200
	plasma_gain = 15
	plasma_max = 200
	upgrade = 3
	var/used_fire_breath = 0
	actions = list(
		/datum/action/xeno_action/activable/breathe_fire,
		)

	New()
		..()
		verbs -= /mob/living/carbon/Xenomorph/verb/hive_status
		spawn(15) name = "Ravenger"


/mob/living/carbon/Xenomorph/Ravager/ravenger/proc/breathe_fire(atom/A)
	set waitfor = 0
	if(world.time <= used_fire_breath + 75)
		return
	var/list/turf/turfs = getline2(src, A)
	var/distance = 0
	var/obj/structure/window/W
	var/turf/T
	playsound(src, 'sound/weapons/gun_flamethrower2.ogg', 50, 1)
	visible_message("<span class='xenowarning'>\The [src] из его пасти вылетает струя пламени!</span>", "<span class='xenowarning'>Вы выпускаете струю огня на ваших врагов!</span>")
	used_fire_breath = world.time
	for(T in turfs)
		if(T == loc)
			continue
		if(distance >= 5)
			break
		if(DirBlocked(T, dir))
			break
		else if(DirBlocked(T, turn(dir, 180)))
			break
		if(locate(/turf/closed/wall/resin, T) || locate(/obj/structure/mineral_door/resin, T))
			break
		W = locate() in T
		if(W)
			if(W.is_full_window())
				break
			if(W.dir == dir)
				break
		flame_turf(T)
		distance++
		sleep(1)

/mob/living/carbon/Xenomorph/Ravager/ravenger/proc/flame_turf(turf/T)
	if(!istype(T))
		return
	if(!locate(/obj/flamer_fire) in T) // No stacking flames!
		new/obj/flamer_fire(T)
	else
		return

	for(var/mob/living/carbon/M in T) //Deal bonus damage if someone's caught directly in initial stream
		if(M.stat == DEAD)
			continue
		if(isXeno(M))
			var/mob/living/carbon/Xenomorph/X = M
			if(X.fire_immune)
				continue
		else if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(istype(H.wear_suit, /obj/item/clothing/suit/fire) || istype(H.wear_suit, /obj/item/clothing/suit/space/rig/atmos))
				continue

		M.adjustFireLoss(rand(20, 50)) //Fwoom!
		M << "[isXeno(M) ? "<span class='xenodanger'>":"<span class='highdanger'>"]Ох! Ты изжарился в огне!</Sspan>"

/mob/living/carbon/Xenomorph/Ravager/Topic(href, href_list)

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
/mob/living/carbon/Xenomorph/Ravager/proc/set_xeno_overwatch(mob/living/carbon/Xenomorph/target, stop_overwatch)
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
