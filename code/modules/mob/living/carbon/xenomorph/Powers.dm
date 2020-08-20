

/mob/living/carbon/Xenomorph/proc/Pounce(atom/T)

	if(!T) return

	if(T.layer >= FLY_LAYER)//anything above that shouldn't be pounceable (hud stuff)
		return

	if(!isturf(loc))
		to_chat(src, "<span class='xenowarning'>Ты не можешь прыгнуть отсюда!</span>")
		return

	if(!check_state())
		return

	if(usedPounce)
		to_chat(src, "<span class='xenowarning'>Вы должны подождать, прежде чем нападать.</span>")
		return

	if(!check_plasma(10))
		return

	if(legcuffed)
		to_chat(src, "<span class='xenodanger'>Ты не можешь прыгнуть с этой штукой на ноге!</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Ваши конечности не реагируют, когда вы пытаетесь встрЯхнуть их, шок!</span>")
		return

	if(layer == XENO_HIDING_LAYER) //Xeno is currently hiding, unhide him
		layer = MOB_LAYER

	if(m_intent == "walk" && isXenoHunter(src)) //Hunter that is currently using its stealth ability, need to unstealth him
		m_intent = "run"
		if(hud_used && hud_used.move_intent)
			hud_used.move_intent.icon_state = "running"
		update_icons()

	visible_message("<span class='xenowarning'>\The [src] набрасываетсЯ на [T]!</span>", \
	"<span class='xenowarning'>Ты набрасываешьсЯ на [T]!</span>")
	usedPounce = 1
	flags_pass = PASSTABLE
	use_plasma(10)
	throw_at(T, 6, 2, src) //Victim, distance, speed
	spawn(6)
		if(!hardcore)
			flags_pass = initial(flags_pass) //Reset the passtable.
		else
			flags_pass = 0 //Reset the passtable.

	spawn(pounce_delay)
		usedPounce = 0
		to_chat(src, "<span class='notice'>Ты снова готов к прыжку.</span>")
		for(var/X in actions)
			var/datum/action/A = X
			A.update_button_icon()

	return 1


// Praetorian acid spray
/mob/living/carbon/Xenomorph/proc/acid_spray_cone(atom/A)

	if (!A || !check_state())
		return

	if (used_acid_spray)
		to_chat(src, "<span class='xenowarning'>Вы должны ждать, чтобы произвести достаточно кислоты длЯ распылениЯ.</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Ваши мышцы не реагируют, когда вы пытаетесь встрЯхнуть их, шок!</span>")
		return

	if (!check_plasma(200))
		to_chat(src, "<span class='xenowarning'>Вы должны производить больше плазмы, прежде чем делать это.</span>")
		return

	var/turf/target

	if (isturf(A))
		target = A
	else
		target = get_turf(A)

	if (target == loc)
		return

	if(!target)
		return

	if(action_busy)
		return

	if(!do_after(src, 12, TRUE, 5, BUSY_ICON_HOSTILE))
		return

	if (used_acid_spray)
		return

	if (!check_plasma(200))
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Шок разрушает вас!</span>")
		return

	round_statistics.praetorian_acid_sprays++

	used_acid_spray = 1
	use_plasma(200)
	playsound(loc, 'sound/effects/refill.ogg', 25, 1)
	visible_message("<span class='xenowarning'>\The [src] извергает широкую струю кислоты!</span>", \
	"<span class='xenowarning'>Ты извергаешь струю кислоты!</span>", null, 5)

	speed += 2
	do_acid_spray_cone(target)
	spawn(rand(20,30))
		speed -= 2

	spawn(acid_spray_cooldown)
		used_acid_spray = 0
		to_chat(src, "<span class='notice'>Вы произвели достаточно кислоты, чтобы распылить её снова.</span>")

/mob/living/carbon/Xenomorph/proc/do_acid_spray_cone(var/turf/T)
	set waitfor = 0

	var/facing = get_cardinal_dir(src, T)
	dir = facing

	T = loc
	for (var/i = 0, i < acid_spray_range, i++)

		var/turf/next_T = get_step(T, facing)

		for (var/obj/O in T)
			if(!O.CheckExit(src, next_T))
				if(istype(O, /obj/structure/barricade))
					var/obj/structure/barricade/B = O
					B.health -= rand(20, 30)
					B.update_health(1)
				return

		T = next_T

		if (T.density)
			return

		for (var/obj/O in T)
			if(!O.CanPass(src, loc))
				if(istype(O, /obj/structure/barricade))
					var/obj/structure/barricade/B = O
					B.health -= rand(20, 30)
					B.update_health(1)
				return

		var/obj/effect/xenomorph/spray/S = acid_splat_turf(T)
		do_acid_spray_cone_normal(T, i, facing, S)
		sleep(3)

// Normal refers to the mathematical normal
/mob/living/carbon/Xenomorph/proc/do_acid_spray_cone_normal(turf/T, distance, facing, obj/effect/xenomorph/spray/source_spray)
	if (!distance)
		return

	var/obj/effect/xenomorph/spray/left_S = source_spray
	var/obj/effect/xenomorph/spray/right_S = source_spray

	var/normal_dir = turn(facing, 90)
	var/inverse_normal_dir = turn(facing, -90)

	var/turf/normal_turf = T
	var/turf/inverse_normal_turf = T

	var/normal_density_flag = 0
	var/inverse_normal_density_flag = 0

	for (var/i = 0, i < distance, i++)
		if (normal_density_flag && inverse_normal_density_flag)
			return

		if (!normal_density_flag)
			var/next_normal_turf = get_step(normal_turf, normal_dir)

			for (var/obj/O in normal_turf)
				if(!O.CheckExit(left_S, next_normal_turf))
					if(istype(O, /obj/structure/barricade))
						var/obj/structure/barricade/B = O
						B.health -= rand(20, 30)
						B.update_health(1)
					normal_density_flag = 1
					break

			normal_turf = next_normal_turf

			if(!normal_density_flag)
				normal_density_flag = normal_turf.density

			if(!normal_density_flag)
				for (var/obj/O in normal_turf)
					if(!O.CanPass(left_S, left_S.loc))
						if(istype(O, /obj/structure/barricade))
							var/obj/structure/barricade/B = O
							B.health -= rand(20, 30)
							B.update_health(1)
						normal_density_flag = 1
						break

			if (!normal_density_flag)
				left_S = acid_splat_turf(normal_turf)


		if (!inverse_normal_density_flag)

			var/next_inverse_normal_turf = get_step(inverse_normal_turf, inverse_normal_dir)

			for (var/obj/O in inverse_normal_turf)
				if(!O.CheckExit(right_S, next_inverse_normal_turf))
					if(istype(O, /obj/structure/barricade))
						var/obj/structure/barricade/B = O
						B.health -= rand(20, 30)
						B.update_health(1)
					inverse_normal_density_flag = 1
					break

			inverse_normal_turf = next_inverse_normal_turf

			if(!inverse_normal_density_flag)
				inverse_normal_density_flag = inverse_normal_turf.density

			if(!inverse_normal_density_flag)
				for (var/obj/O in inverse_normal_turf)
					if(!O.CanPass(right_S, right_S.loc))
						if(istype(O, /obj/structure/barricade))
							var/obj/structure/barricade/B = O
							B.health -= rand(20, 30)
							B.update_health(1)
						inverse_normal_density_flag = 1
						break

			if (!inverse_normal_density_flag)
				right_S = acid_splat_turf(inverse_normal_turf)



/mob/living/carbon/Xenomorph/proc/acid_splat_turf(var/turf/T)
	. = locate(/obj/effect/xenomorph/spray) in T
	if(!.)
		. = new /obj/effect/xenomorph/spray(T)

		// This should probably be moved into obj/effect/xenomorph/spray or something
		for (var/obj/structure/barricade/B in T)
			B.health -= rand(20, 30)
			B.update_health(1)

		for (var/mob/living/carbon/C in T)
			if (!ishuman(C) && !ismonkey(C))
				continue

			if ((C.status_flags & XENO_HOST) && istype(C.buckled, /obj/structure/bed/nest))
				continue

			round_statistics.praetorian_spray_direct_hits++
			C.adjustFireLoss(rand(20,30) + 5 * upgrade)
			to_chat(C, "<span class='xenodanger'>\The [src] в едких кислотах!</span>")

			if (!isYautja(C))
				C.emote("scream")
				C.KnockDown(rand(3, 4))


// Warrior Fling
/mob/living/carbon/Xenomorph/proc/fling(atom/A)

	if (!A || !istype(A, /mob/living/carbon/human))
		return

	if (!check_state() || agility)
		return

	if (used_fling)
		to_chat(src, "<span class='xenowarning'>Ты должен собратьсЯ с силами, прежде чем что-то бросать.</span>")
		return

	if (!check_plasma(10))
		return

	if (!Adjacent(A))
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Ваши конечности не реагируют, когда вы пытаетесь встрЯхнуть их, шок!</span>")
		return

	var/mob/living/carbon/human/H = A
	if(H.stat == DEAD) return
	round_statistics.warrior_flings++

	visible_message("<span class='xenowarning'>\The [src] легко бросает [H] в сторону!</span>", \
	"<span class='xenowarning'>Ты без усилий бросаешь [H] в сторону!</span>")
	playsound(H,'sound/weapons/alien_claw_block.ogg', 75, 1)
	used_fling = 1
	use_plasma(10)
	H.apply_effects(1,2) 	// Stun
	shake_camera(H, 2, 1)

	var/facing = get_dir(src, H)
	var/fling_distance = 4
	var/turf/T = loc
	var/turf/temp = loc

	for (var/x = 0, x < fling_distance, x++)
		temp = get_step(T, facing)
		if (!temp)
			break
		T = temp

	H.throw_at(T, fling_distance, 1, src, 1)

	spawn(fling_cooldown)
		used_fling = 0
		to_chat(src, "<span class='notice'>Ты набираешьсЯ сил, чтобы снова что-то бросить.</span>")
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()

/mob/living/carbon/Xenomorph/proc/punch(atom/A)

	if (!A || !ishuman(A))
		return

	if (!check_state() || agility)
		return

	if (used_punch)
		to_chat(src, "<span class='xenowarning'>Ты должен собратьсЯ с силами перед ударом.</span>")
		return

	if (!check_plasma(10))
		return

	if (!Adjacent(A))
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Ваши конечности не реагируют, когда вы пытаетесь встрЯхнуть их, шок!</span>")
		return

	var/mob/living/carbon/human/H = A
	if(H.stat == DEAD) return
	round_statistics.warrior_punches++
	var/datum/limb/L = H.get_limb(check_zone(zone_selected))

	if (!L || (L.status & LIMB_DESTROYED))
		return

	visible_message("<span class='xenowarning'>\The [src] попал [H] в [L.display_name] с дьЯвольски мощным ударом!</span>", \
	"<span class='xenowarning'>Вы попали [H] в [L.display_name] с дъЯвольски мощным ударом!</span>")
	var/S = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
	playsound(H,S, 50, 1)
	used_punch = 1
	use_plasma(10)

	if(L.status & LIMB_SPLINTED) //If they have it splinted, the splint won't hold.
		L.status &= ~LIMB_SPLINTED
		to_chat(H, "<span class='danger'>Шина на вашем [L.display_name] разваливаетсЯ!</span>")

	if(isYautja(H))
		L.take_damage(rand(8,12))
	else if(L.status & LIMB_ROBOT)
		L.take_damage(rand(30,40), 0, 0) // just do more damage
	else
		var/fracture_chance = 100
		switch(L.body_part)
			if(HEAD)
				fracture_chance = 20
			if(UPPER_TORSO)
				fracture_chance = 30
			if(LOWER_TORSO)
				fracture_chance = 40

		L.take_damage(rand(15,25), 0, 0)
		if(prob(fracture_chance))
			L.fracture()
	shake_camera(H, 2, 1)
	step_away(H, src, 2)

	spawn(punch_cooldown)
		used_punch = 0
		to_chat(src, "<span class='notice'>Ты набираешьсЯ сил, чтобы ударить снова.</span>")
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()

/mob/living/carbon/Xenomorph/proc/lunge(atom/A)

	if (!A || !istype(A, /mob/living/carbon/human))
		return

	if (!isturf(loc))
		to_chat(src, "<span class='xenowarning'>Ты не можешь броситьсЯ отсюда!</span>")
		return

	if (!check_state() || agility)
		return

	if (used_lunge)
		to_chat(src, "<span class='xenowarning'>Ты должен собратьсЯ с силами перед броском.</span>")
		return

	if (!check_plasma(10))
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Ваши конечности не реагируют, когда вы пытаетесь встрЯхнуть их, шок!</span>")
		return

	var/mob/living/carbon/human/H = A
	if(H.stat == DEAD) return
	round_statistics.warrior_lunges++
	visible_message("<span class='xenowarning'>\The [src] набрасываетсЯ в сторону [H]!</span>", \
	"<span class='xenowarning'>Вы тут же набрасываетесь [H]!</span>")

	used_lunge = 1 // triggered by start_pulling
	use_plasma(10)
	throw_at(get_step_towards(A, src), 6, 2, src)

	if (Adjacent(H))
		start_pulling(H,1)

	spawn(lunge_cooldown)
		used_lunge = 0
		to_chat(src, "<span class='notice'>Ты снова готовишьсЯ к броску.</span>")
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()

	return 1

// Called when pulling something and attacking yourself with the pull
/mob/living/carbon/Xenomorph/proc/pull_power(var/mob/M)
	if (isXenoWarrior(src) && !ripping_limb && M.stat != DEAD)
		ripping_limb = 1
		if(rip_limb(M))
			stop_pulling()
		ripping_limb = 0


// Warrior Rip Limb - called by pull_power()
/mob/living/carbon/Xenomorph/proc/rip_limb(var/mob/M)
	if (!istype(M, /mob/living/carbon/human))
		return 0

	if(action_busy) //can't stack the attempts
		return 0

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Ваши конечности не реагируют, когда вы пытаетесь встрЯхнуть их, шок!</span>")
		return

	var/mob/living/carbon/human/H = M
	var/datum/limb/L = H.get_limb(check_zone(zone_selected))

	if (!L || L.body_part == UPPER_TORSO || L.body_part == LOWER_TORSO || (L.status & LIMB_DESTROYED)) //Only limbs and head.
		to_chat(src, "<span class='xenowarning'>Ты не можешь оторвать эту конечность.</span>")
		return 0
	round_statistics.warrior_limb_rips++
	var/limb_time = rand(40,60)

	if (L.body_part == HEAD)
		limb_time = rand(90,110)

	visible_message("<span class='xenowarning'>\The [src] начинает тЯнуть на [M]'s [L.display_name] с невероЯтной силой!</span>", \
	"<span class='xenowarning'>Вы начинаете тЯнуть на [M]'s [L.display_name] с невероЯтной силой!</span>")

	if(!do_after(src, limb_time, TRUE, 5, BUSY_ICON_HOSTILE, 1) || M.stat == DEAD)
		to_chat(src, "<span class='notice'>Хватит отрывать конечности.</span>")
		return 0

	if(L.status & LIMB_DESTROYED)
		return 0

	if(L.status & LIMB_ROBOT)
		L.take_damage(rand(30,40), 0, 0) // just do more damage
		visible_message("<span class='xenowarning'>Вы слышите [M]'s [L.display_name] быть вытЯгиванным за свои пределы нагрузки!</span>", \
		"<span class='xenowarning'>\The [M]'s [L.display_name] начинает рватьсЯ на части!</span>")
	else
		visible_message("<span class='xenowarning'>Вы слышите как кости в [M]'s [L.display_name] хрустЯт с прекрасным хрустом!</span>", \
		"<span class='xenowarning'>\The [M]'s [L.display_name] кости хрустЯт с прекрасным хрустом!</span>")
		L.take_damage(rand(15,25), 0, 0)
		L.fracture()
	log_message(src, M, "сорвал [L.display_name] off", addition="1/2 прогресс")

	if(!do_after(src, limb_time, TRUE, 5, BUSY_ICON_HOSTILE)  || M.stat == DEAD)
		to_chat(src, "<span class='notice'>Хватит отрывать конечности.</span>")
		return 0

	if(L.status & LIMB_DESTROYED)
		return 0

	visible_message("<span class='xenowarning'>\The [src] отрывает [M]'s [L.display_name] от \his тела!</span>", \
	"<span class='xenowarning'>\The [M]'s [L.display_name] rips away from \his body!</span>")
	log_message(src, M, "сорвал [L.display_name] off", addition="2/2 прогресс")

	L.droplimb()

	return 1


// Warrior Agility
/mob/living/carbon/Xenomorph/proc/toggle_agility()
	if (!check_state())
		return

	if (used_toggle_agility)
		return

	agility = !agility

	round_statistics.warrior_agility_toggles++
	if (agility)
		to_chat(src, "<span class='xenowarning'>Ты опускаешьсЯ на четвереньки.</span>")
		speed -= 0.7
		update_icons()
		do_agility_cooldown()
		return

	to_chat(src, "<span class='xenowarning'>Вы поднимаетесь на две ноги.</span>")
	speed += 0.7
	update_icons()
	do_agility_cooldown()

/mob/living/carbon/Xenomorph/proc/do_agility_cooldown()
	spawn(toggle_agility_cooldown)
		used_toggle_agility = 0
		to_chat(src, "<span class='notice'>Вы можете [agility ? "raise yourself back up" : "lower yourself back down"] опЯть.</span>")
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()


// Defender Headbutt
/mob/living/carbon/Xenomorph/proc/headbutt(var/mob/M)
	if (!M || !istype(M, /mob/living/carbon/human))
		return

	if (fortify)
		to_chat(src, "<span class='xenowarning'>Вы не можете использовать способности, пока укреплены.</span>")
		return

	if (crest_defense)
		to_chat(src, "<span class='xenowarning'>НельзЯ использовать способности с опущенным гребнем.</span>")
		return

	if (!check_state())
		return

	if (used_headbutt)
		to_chat(src, "<span class='xenowarning'>Ты должен собратьсЯ с силами перед ударом головой.</span>")
		return

	if (!check_plasma(10))
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Ваши конечности не реагируют, когда вы пытаетесь встрЯхнуть их, шок!</span>")
		return

	var/mob/living/carbon/human/H = M

	var/distance = get_dist(src, H)

	if (distance > 2)
		return

	if (distance > 1)
		step_towards(src, H, 1)

	if (!Adjacent(H))
		return

	round_statistics.defender_headbutts++

	visible_message("<span class='xenowarning'>\The [src] таран [H]  бронированным гребнем!</span>", \
	"<span class='xenowarning'>Вы таран [H] с бронированным гребнем!</span>")

	used_headbutt = 1
	use_plasma(10)

	if(H.stat != DEAD && (!(H.status_flags & XENO_HOST) || !istype(H.buckled, /obj/structure/bed/nest)) )
		H.apply_damage(20)
		shake_camera(H, 2, 1)

	var/facing = get_dir(src, H)
	var/headbutt_distance = 3
	var/turf/T = loc
	var/turf/temp = loc

	for (var/x = 0, x < headbutt_distance, x++)
		temp = get_step(T, facing)
		if (!temp)
			break
		T = temp

	H.throw_at(T, headbutt_distance, 1, src)
	playsound(H,'sound/weapons/alien_claw_block.ogg', 50, 1)
	spawn(headbutt_cooldown)
		used_headbutt = 0
		to_chat(src, "<span class='notice'>Ты набираешьсЯ сил, чтобы снова ударить головой.</span>")
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()


// Defender Tail Sweep
/mob/living/carbon/Xenomorph/proc/tail_sweep()
	if (fortify)
		to_chat(src, "<span class='xenowarning'>Вы не можете использовать способности, пока укреплены.</span>")
		return

	if (crest_defense)
		to_chat(src, "<span class='xenowarning'>НельзЯ использовать способности с опущенным гребнем.</span>")
		return

	if (!check_state())
		return

	if (used_tail_sweep)
		to_chat(src, "<span class='xenowarning'>Ты должен собратьсЯ с силами, прежде чем махать хвостом.</span>")
		return

	if (!check_plasma(10))
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Ваши конечности не реагируют, когда вы пытаетесь встрЯхнуть их, шок!</span>")
		return

	round_statistics.defender_tail_sweeps++
	visible_message("<span class='xenowarning'>\The [src] размахивает хвостом по широкому кругу!</span>", \
	"<span class='xenowarning'>Ты описываешь хвостом широкий круг!</span>")

	spin_circle()

	var/sweep_range = 1
	var/list/L = orange(sweep_range)		// Not actually the fruit

	for (var/mob/living/carbon/human/H in L)
		step_away(H, src, sweep_range, 2)
		H.apply_damage(10)
		round_statistics.defender_tail_sweep_hits++
		shake_camera(H, 2, 1)

		if (prob(50))
			H.KnockDown(2, 1)

		to_chat(H, "<span class='xenowarning'>Вы поражены \the [src]'s хвостовой разверткой!</span>")
		playsound(H,'sound/weapons/alien_claw_block.ogg', 50, 1)
	used_tail_sweep = 1
	use_plasma(10)

	spawn(tail_sweep_cooldown)
		used_tail_sweep = 0
		to_chat(src, "<span class='notice'>Ты набираешь достаточно сил, чтобы снова взмахнуть хвостом.</span>")
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()


// Defender Crest Defense
/mob/living/carbon/Xenomorph/proc/toggle_crest_defense()

	if (fortify)
		to_chat(src, "<span class='xenowarning'>Вы не можете использовать способности, пока укреплены.</span>")
		return

	if (!check_state())
		return

	if (used_crest_defense)
		return

	crest_defense = !crest_defense
	used_crest_defense = 1

	if (crest_defense)
		round_statistics.defender_crest_lowerings++
		to_chat(src, "<span class='xenowarning'>Ты опускаешь свой гребень.</span>")
		armor_deflection += 15
		speed += 0.8	// This is actually a slowdown but speed is dumb
		update_icons()
		do_crest_defense_cooldown()
		return

	round_statistics.defender_crest_raises++
	to_chat(src, "<span class='xenowarning'>Ты поднимаешь свой гребень.</span>")
	armor_deflection -= 15
	speed -= 0.8
	update_icons()
	do_crest_defense_cooldown()

/mob/living/carbon/Xenomorph/proc/do_crest_defense_cooldown()
	spawn(crest_defense_cooldown)
		used_crest_defense = 0
		to_chat(src, "<span class='notice'>Вы можете [crest_defense ? "raise" : "lower"] ваш гребень.</span>")
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()


// Defender Fortify
/mob/living/carbon/Xenomorph/proc/fortify()
	if (crest_defense)
		to_chat(src, "<span class='xenowarning'>НельзЯ использовать способности с опущенным гребнем.</span>")
		return

	if (!check_state())
		return

	if (used_fortify)
		return

	round_statistics.defender_fortifiy_toggles++

	fortify = !fortify
	used_fortify = 1

	if (fortify)
		to_chat(src, "<span class='xenowarning'>Ты принимаешь оборонительную стойку.</span>")
		armor_deflection += 30
		xeno_explosion_resistance++
		frozen = 1
		anchored = 1
		update_canmove()
		update_icons()
		do_fortify_cooldown()
		fortify_timer = world.timeofday + 90		// How long we can be fortified
		process_fortify()
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 30, 1)
		return

	fortify_off()
	do_fortify_cooldown()

/mob/living/carbon/Xenomorph/proc/process_fortify()
	set background = 1

	spawn while (fortify)
		if (world.timeofday > fortify_timer)
			fortify = 0
			fortify_off()
		sleep(10)	// Process every second.

/mob/living/carbon/Xenomorph/proc/fortify_off()
	to_chat(src, "<span class='xenowarning'>Ты принимаешь свою обычную позу.</span>")
	armor_deflection -= 30
	xeno_explosion_resistance--
	frozen = 0
	anchored = 0
	playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 30, 1)
	update_canmove()
	update_icons()

/mob/living/carbon/Xenomorph/proc/do_fortify_cooldown()
	spawn(fortify_cooldown)
		used_fortify = 0
		to_chat(src, "<span class='notice'>Вы сможете [fortify ? "stand up" : "fortify"] еще раз.</span>")
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()


/* WIP Burrower stuff
/mob/living/carbon/Xenomorph/proc/burrow()
	if (!check_state())
		return

	if (used_burrow)
		return

	burrow = !burrow
	used_burrow = 1

	if (burrow)
		// TODO Make immune to all damage here.
		to_chat(src, "<span class='xenowarning'>You burrow yourself into the ground.</span>")
		frozen = 1
		invisibility = 101
		anchored = 1
		density = 0
		update_canmove()
		update_icons()
		do_burrow_cooldown()
		burrow_timer = world.timeofday + 90		// How long we can be burrowed
		process_burrow()
		return

	burrow_off()
	do_burrow_cooldown()

/mob/living/carbon/Xenomorph/proc/process_burrow()
	set background = 1

	spawn while (burrow)
		if (world.timeofday > burrow_timer && !tunnel)
			burrow = 0
			burrow_off()
		sleep(10)	// Process every second.

/mob/living/carbon/Xenomorph/proc/burrow_off()

	to_chat(src, "<span class='notice'>You resurface.</span>")
	frozen = 0
	invisibility = 0
	anchored = 0
	density = 1
	update_canmove()
	update_icons()

/mob/living/carbon/Xenomorph/proc/do_burrow_cooldown()
	spawn(burrow_cooldown)
		used_burrow = 0
		to_chat(src, "<span class='notice'>You can now surface or tunnel.</span>")
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()


/mob/living/carbon/Xenomorph/proc/tunnel(var/turf/T)
	if (!burrow)
		to_chat(src, "<span class='notice'>You must be burrowed to do this.</span>")
		return

	if (used_burrow || used_tunnel)
		to_chat(src, "<span class='notice'>You must wait some time to do this.</span>")
		return

	if (tunnel)
		tunnel = 0
		to_chat(src, "<span class='notice'>You stop tunneling.</span>")
		used_tunnel = 1
		do_tunnel_cooldown()
		return

	if (!T || T.density)
		to_chat(src, "<span class='notice'>You cannot tunnel to there!</span>")

	tunnel = 1
	process_tunnel(T)


/mob/living/carbon/Xenomorph/proc/process_tunnel(var/turf/T)
	set background = 1

	spawn while (tunnel && T)
		if (world.timeofday > tunnel_timer)
			tunnel = 0
			do_tunnel()
		sleep(10)	// Process every second.

/mob/living/carbon/Xenomorph/proc/do_tunnel(var/turf/T)
	to_chat(src, "<span class='notice'>You tunnel to your destination.</span>")
	M.forceMove(T)
	burrow = 0
	burrow_off()

/mob/living/carbon/Xenomorph/proc/do_tunnel_cooldown()
	spawn(tunnel_cooldown)
		used_tunnel = 0
		to_chat(src, "<span class='notice'>You can now tunnel while burrowed.</span>")
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()
*/

// Vent Crawl
/mob/living/carbon/Xenomorph/proc/vent_crawl()
	set name = "Crawl through Vent"
	set desc = "Влезтть в вентилЯционное отверстие и проползти через систему труб."
	set category = "Alien"
	if(!check_state())
		return
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)


/mob/living/carbon/Xenomorph/proc/xeno_transfer_plasma(atom/A, amount = 50, transfer_delay = 20, max_range = 2)
	if(!istype(A, /mob/living/carbon/Xenomorph))
		return
	var/mob/living/carbon/Xenomorph/target = A

	if(!check_state())
		return

	if(!isturf(loc))
		to_chat(src, "<span class='warning'>Вы не можете перенести плазму отсюда!</span>")
		return

	if(get_dist(src, target) > max_range)
		to_chat(src, "<span class='warning'>Тебе нужно быть ближе к [target].</span>")
		return

	to_chat(src, "<span class='notice'>Вы начинаете фокусировать плазму в сторону [target].</span>")
	if(!do_after(src, transfer_delay, TRUE, 5, BUSY_ICON_FRIENDLY))
		return

	if(!check_state())
		return

	if(!isturf(loc))
		to_chat(src, "<span class='warning'>Вы не можете перенести плазму отсюда!</span>")
		return

	if(get_dist(src, target) > max_range)
		to_chat(src, "<span class='warning'>Тебе нужно быть ближе к [target].</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Ваши конечности не реагируют, когда вы пытаетесь встрЯхнуть их, шок!</span>")
		return

	if(plasma_stored < amount)
		amount = plasma_stored //Just use all of it
	use_plasma(amount)
	target.gain_plasma(amount)
	to_chat(target, "<span class='xenowarning'>\The [src] передал вам [amount] плазмы. Теперь у вас есть [target.plasma_stored].</span>")
	to_chat(src, "<span class='xenowarning'>Вы перенесли плазму [amount] в \the [target]. Теперь у вас есть [plasma_stored].</span>")
	playsound(src, "alien_drool", 25)

//Note: All the neurotoxin projectile items are stored in XenoProcs.dm
/mob/living/carbon/Xenomorph/proc/xeno_spit(atom/T)

	if(!check_state())
		return

	if(!isturf(loc))
		to_chat(src, "<span class='warning'>Ты не можешь плевать отсюда!</span>")
		return

	if(has_spat > world.time)
		to_chat(src, "<span class='warning'>Вы должны ждать, пока ваши плевательные железы наполнЯтсЯ.</span>")
		return

	if(!check_plasma(ammo.spit_cost))
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Ваши конечности не реагируют, когда вы пытаетесь встрЯхнуть их, шок!</span>")
		return

	var/turf/current_turf = get_turf(src)

	if(!current_turf)
		return

	visible_message("<span class='xenowarning'>\The [src] плюет в \the [T]!</span>", \
	"<span class='xenowarning'>You spit at \the [T]!</span>" )
	var/sound_to_play = pick(1, 2) == 1 ? 'sound/voice/alien_spitacid.ogg' : 'sound/voice/alien_spitacid2.ogg'
	playsound(src.loc, sound_to_play, 25, 1)

	var/obj/item/projectile/A = rnew(/obj/item/projectile, current_turf)
	A.generate_bullet(ammo)
	A.permutated += src
	A.def_zone = get_limbzone_target()
	A.fire_at(T, src, null, ammo.max_range, ammo.shell_speed)
	has_spat = world.time + spit_delay + ammo.added_spit_delay
	use_plasma(ammo.spit_cost)
	cooldown_notification(spit_delay + ammo.added_spit_delay, "spit")

	return TRUE

/mob/living/carbon/Xenomorph/proc/cooldown_notification(cooldown, message)
	set waitfor = 0
	sleep(cooldown)
	switch(message)
		if("spit")
			to_chat(src, "<span class='notice'>Вы чувствуете, что ваш нейротоксин железы набухают. Можешь снова плюнуть.</span>")
	for(var/X in actions)
		var/datum/action/A = X
		A.update_button_icon()



/mob/living/carbon/Xenomorph/proc/build_resin(atom/A, resin_plasma_cost)
	if(action_busy) return
	if(!check_state())
		return
	if(!check_plasma(resin_plasma_cost))
		return
	if(stagger)
		to_chat(src, "<span class='xenowarning'>Ваши ловкие конечности не в состоЯнии должным образом реагировать, как вы пытаетесь встрЯхнуть их, шок!</span>")
		return
	var/turf/current_turf = loc
	if (caste == "Hivelord") //hivelords can thicken existing resin structures.
		if(get_dist(src,A) <= 1)
			if(istype(A, /turf/closed/wall/resin))
				var/turf/closed/wall/resin/WR = A
				if(WR.walltype == "resin")
					visible_message("<span class='xenonotice'>\The [src] отрыгивает густое вещество и сгущает [WR].</span>", \
					"<span class='xenonotice'>Ты выплёвываешь некоторые смолы и утолщаютсЯ [WR].</span>", null, 5)
					var/prev_oldturf = WR.oldTurf
					WR.ChangeTurf(/turf/closed/wall/resin/thick)
					WR.oldTurf = prev_oldturf
					use_plasma(resin_plasma_cost)
					playsound(loc, "alien_resin_build", 25)
				else if(WR.walltype == "membrane")
					var/prev_oldturf = WR.oldTurf
					WR.ChangeTurf(/turf/closed/wall/resin/membrane/thick)
					WR.oldTurf = prev_oldturf
					use_plasma(resin_plasma_cost)
					playsound(loc, "alien_resin_build", 25)
				else
					to_chat(src, "<span class='xenowarning'>[WR] не могут быть сделаны толще.</span>")
				return

			else if(istype(A, /obj/structure/mineral_door/resin))
				var/obj/structure/mineral_door/resin/DR = A
				if(DR.hardness == 1.5) //non thickened
					var/oldloc = DR.loc
					visible_message("<span class='xenonotice'>\The [src] отрыгивает густое вещество и сгущает [DR].</span>", \
						"<span class='xenonotice'>Вы отрыгиваете какую-то смолу и сгущаете [DR].</span>", null, 5)
					cdel(DR)
					new /obj/structure/mineral_door/resin/thick (oldloc)
					playsound(loc, "alien_resin_build", 25)
					use_plasma(resin_plasma_cost)
				else
					to_chat(src, "<span class='xenowarning'>[DR] нельзЯ сделать толще..</span>")
				return

			else
				current_turf = get_turf(A) //Hivelords can secrete resin on adjacent turfs.



	var/mob/living/carbon/Xenomorph/blocker = locate() in current_turf
	if(blocker && blocker != src && blocker.stat != DEAD)
		to_chat(src, "<span class='warning'>Не могу сделать это с [blocker] на пути!</span>")
		return

	if(!istype(current_turf) || !current_turf.is_weedable())
		to_chat(src, "<span class='warning'>Ты не можешь сделать это здесь.</span>")
		return

	var/area/AR = get_area(current_turf)
	if(istype(AR,/area/shuttle/drop1/lz1) || istype(AR,/area/shuttle/drop2/lz2) || istype(AR,/area/sulaco/hangar)) //Bandaid for atmospherics bug when Xenos build around the shuttles
		to_chat(src, "<span class='warning'>Вы чувствуете, что это не подходЯщее место длЯ расширениЯ ульЯ.</span>")
		return

	var/obj/effect/alien/weeds/alien_weeds = locate() in current_turf

	if(!alien_weeds)
		to_chat(src, "<span class='warning'>Вы можете формировать только на сорнЯках. Найдите смолу, прежде чем начать строить!</span>")
		return

	if(!check_alien_construction(current_turf))
		return

	if(selected_resin == "resin door")
		var/wall_support = FALSE
		for(var/D in cardinal)
			var/turf/T = get_step(current_turf,D)
			if(T)
				if(T.density)
					wall_support = TRUE
					break
				else if(locate(/obj/structure/mineral_door/resin) in T)
					wall_support = TRUE
					break
		if(!wall_support)
			to_chat(src, "<span class='warning'>ДверЯм смолы нужна дверь, стены или смолы рЯдом с ними, чтобы встать.</span>")
			return

	var/wait_time = 5
	if(caste == "Drone")
		wait_time = 10

	if(!do_after(src, wait_time, TRUE, 5, BUSY_ICON_BUILD))
		return

	blocker = locate() in current_turf
	if(blocker && blocker != src && blocker.stat != DEAD)
		return

	if(!check_state())
		return
	if(!check_plasma(resin_plasma_cost))
		return

	if(!istype(current_turf) || !current_turf.is_weedable())
		return

	AR = get_area(current_turf)
	if(istype(AR,/area/shuttle/drop1/lz1 || istype(AR,/area/shuttle/drop2/lz2)) || istype(AR,/area/sulaco/hangar)) //Bandaid for atmospherics bug when Xenos build around the shuttles
		return

	alien_weeds = locate() in current_turf
	if(!alien_weeds)
		return

	if(!check_alien_construction(current_turf))
		return

	if(selected_resin == "resin door")
		var/wall_support = FALSE
		for(var/D in cardinal)
			var/turf/T = get_step(current_turf,D)
			if(T)
				if(T.density)
					wall_support = TRUE
					break
				else if(locate(/obj/structure/mineral_door/resin) in T)
					wall_support = TRUE
					break
		if(!wall_support)
			to_chat(src, "<span class='warning'>ДверЯм смолы нужна дверь, стены или смолы рЯдом с ними, чтобы встать.</span>")
			return

	use_plasma(resin_plasma_cost)
	visible_message("<span class='xenonotice'>\The [src] отрыгивает густую субстанцию и формирует ее в \a [selected_resin]!</span>", \
	"<span class='xenonotice'>Ты отрыгиваешь смолу и придаешь ей форму \a [selected_resin].</span>", null, 5)
	playsound(loc, "alien_resin_build", 25)

	var/atom/new_resin

	switch(selected_resin)
		if("resin door")
			if (caste == "Hivelord")
				new_resin = new /obj/structure/mineral_door/resin/thick(current_turf)
			else
				new_resin = new /obj/structure/mineral_door/resin(current_turf)
		if("resin wall")
			if (caste == "Hivelord")
				current_turf.ChangeTurf(/turf/closed/wall/resin/thick)
			else
				current_turf.ChangeTurf(/turf/closed/wall/resin)
			new_resin = current_turf
		if("resin nest")
			new_resin = new /obj/structure/bed/nest(current_turf)
		if("sticky resin")
			new_resin = new /obj/effect/alien/resin/sticky(current_turf)

	new_resin.add_hiddenprint(src) //so admins know who placed it


//Corrosive acid is consolidated -- it checks for specific castes for strength now, but works identically to each other.
//The acid items are stored in XenoProcs.
/mob/living/carbon/Xenomorph/proc/corrosive_acid(atom/O, acid_type, plasma_cost)

	if(!O.Adjacent(src))
		to_chat(src, "<span class='warning'>\The [O] слишком далеко.</span>")
		return

	if(!isturf(loc))
		to_chat(src, "<span class='warning'>Вы не можете расплавить [O] отсюда!</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Ваши конечности не реагируют, когда вы пытаетесь встрЯхнуть их, шок!</span>")
		return

	face_atom(O)

	var/wait_time = 10

	//OBJ CHECK
	if(isobj(O))
		var/obj/I = O

		if(I.unacidable || istype(I, /obj/machinery/computer) || istype(I, /obj/effect)) //So the aliens don't destroy energy fields/singularies/other aliens/etc with their acid.
			to_chat(src, "<span class='warning'>Ты не можешь растворить \the [I].</span>")
			return
		if(istype(O, /obj/structure/window_frame))
			var/obj/structure/window_frame/WF = O
			if(WF.reinforced && acid_type != /obj/effect/xenomorph/acid/strong)
				to_chat(src, "<span class='warning'>Это [O.name] слишком сложно, чтобы быть расплавленным вашей слабой кислотой.</span>")
			return

		if(O.density || istype(O, /obj/structure))
			wait_time = 40 //dense objects are big, so takes longer to melt.

	//TURF CHECK
	else if(isturf(O))
		var/turf/T = O

		if(istype(O, /turf/closed/wall))
			var/turf/closed/wall/wall_target = O
			if (wall_target.acided_hole)
				to_chat(src, "<span class='warning'>[O] уже ослаблено.</span>")
				return

		var/dissolvability = T.can_be_dissolved()
		switch(dissolvability)
			if(0)
				to_chat(src, "<span class='warning'>Ты не можешь растворить \the [T].</span>")
				return
			if(1)
				wait_time = 50
			if(2)
				if(acid_type != /obj/effect/xenomorph/acid/strong)
					to_chat(src, "<span class='warning'>Это [T.name] слишком сложно, чтобы расплавить вашей слабой кислотой.</span>")
					return
				wait_time = 100
			else
				return
		to_chat(src, "<span class='xenowarning'>Ты начинаешь вырабатывать достаточно кислоты, чтобы расплавить \the [T].</span>")
	else
		to_chat(src, "<span class='warning'>Ты не можешь растворить \the [O].</span>")
		return

	if(!do_after(src, wait_time, TRUE, 5, BUSY_ICON_HOSTILE))
		return

	if(!check_state())
		return

	if(!O || !get_turf(O)) //Some logic.
		return

	if(!check_plasma(plasma_cost))
		return

	if(!O.Adjacent(src))
		return

	use_plasma(plasma_cost)

	var/obj/effect/xenomorph/acid/A = new acid_type(get_turf(O), O)

	if(istype(O, /obj/vehicle/multitile/root/cm_armored))
		var/obj/vehicle/multitile/root/cm_armored/R = O
		R.take_damage_type( (1 / A.acid_strength) * 20, "acid", src)
		visible_message("<span class='xenowarning'>\The [src] извергает шарики мерзкой дрЯни на \the [O]. Он шипит под пузырЯщейсЯ массой кислоты!</span>", \
			"<span class='xenowarning'>Ты плюёшь мерзкими шариками. \the [O]. Он шипит под пузырЯщейсЯ массой кислоты!</span>", null, 5)
		playsound(loc, "sound/bullets/acid_impact1.ogg", 25)
		sleep(20)
		cdel(A)
		return

	if(isturf(O))
		A.icon_state += "_wall"

	if(istype(O, /obj/structure) || istype(O, /obj/machinery)) //Always appears above machinery
		A.layer = O.layer + 0.1
	else //If not, appear on the floor or on an item
		A.layer = LOWER_ITEM_LAYER //below any item, above BELOW_OBJ_LAYER (smartfridge)

	A.add_hiddenprint(src)

	if(!isturf(O))
		log_combat(src, O, "spat on", addition="with corrosive acid")
		msg_admin_attack("[src.name] ([src.ckey]) spat acid on [O].")
	visible_message("<span class='xenowarning'>\The [src] извергает шарики мерзкой дрЯни повсюду \the [O]. Он начинает шипеть и плавитьсЯ под пузырЯщейсЯ массой кислоты!</span>", \
	"<span class='xenowarning'>Ты плюёшь мерзкими шариками по всему телу \the [O]. Он начинает шипеть и плавитьсЯ под пузырЯщейсЯ массой кислоты!</span>", null, 5)
	playsound(loc, "sound/bullets/acid_impact1.ogg", 25)





/mob/living/carbon/Xenomorph/verb/hive_status()
	set name = "Hive Status"
	set desc = "Проверьте состоЯние вашего текущего ульЯ."
	set category = "Alien"

	var/datum/hive_status/hive
	if(hivenumber && hivenumber <= hive_datum.len)
		hive = hive_datum[hivenumber]
	else return
	if(!hive.living_xeno_queen)
		to_chat(src, "<span class='warning'>Нет никакой королевы. Вы одиноки.</span>")
		return

	if(caste == "Queen" && anchored)
		check_hive_status(src, anchored)
	else
		check_hive_status(src)


/proc/check_hive_status(mob/living/carbon/Xenomorph/user, var/anchored = 0)
	var/dat = "<html><head><title>Hive Status</title></head><body>"

	var/count = 0
	var/queen_list = ""
	//var/exotic_list = ""
	//var/exotic_count = 0
	var/boiler_list = ""
	var/boiler_count = 0
	var/crusher_list = ""
	var/crusher_count = 0
	var/praetorian_list = ""
	var/praetorian_count = 0
	var/ravager_list = ""
	var/ravager_count = 0
	var/carrier_list = ""
	var/carrier_count = 0
	var/hivelord_list = ""
	var/hivelord_count = 0
	var/burrower_list = ""
	var/burrower_count = 0
	var/warrior_list = ""
	var/warrior_count = 0
	var/hunter_list = ""
	var/hunter_count = 0
	var/spitter_list = ""
	var/spitter_count = 0
	var/drone_list = ""
	var/drone_count = 0
	var/runner_list = ""
	var/runner_count = 0
	var/sentinel_list = ""
	var/sentinel_count = 0
	var/defender_list = ""
	var/defender_count = 0
	var/larva_list = ""
	var/larva_count = 0
	var/stored_larva_count = ticker.mode.stored_larva
	var/leader_list = ""

	for(var/mob/living/carbon/Xenomorph/X in living_mob_list)
		if(X.z == ADMIN_Z_LEVEL) continue //don't show xenos in the thunderdome when admins test stuff.
		if(istype(user)) // cover calling it without parameters
			if(X.hivenumber != user.hivenumber)
				continue // not our hive
		var/area/A = get_area(X)

		var/datum/hive_status/hive
		if(X.hivenumber && X.hivenumber <= hive_datum.len)
			hive = hive_datum[X.hivenumber]
		else
			X.hivenumber = XENO_HIVE_NORMAL
			hive = hive_datum[X.hivenumber]

		var/leader = ""

		if(X in hive.xeno_leader_list)
			leader = "<b>(-L-)</b>"

		var/xenoinfo
		if(user && anchored && X != user)
			xenoinfo = "<tr><td>[leader]<a href=?src=\ref[user];watch_xeno_number=[X.nicknumber]>[X.name]</a> "
		else
			xenoinfo = "<tr><td>[leader][X.name] "
		if(!X.client) xenoinfo += " <i>(SSD)</i>"

		count++ //Dead players shouldn't be on this list
		xenoinfo += " <b><font color=green>([A ? A.name : null])</b></td></tr>"

		if(leader != "")
			leader_list += xenoinfo

		switch(X.caste)
			if("Queen")
				queen_list += xenoinfo
			if("Boiler")
				if(leader == "") boiler_list += xenoinfo
				boiler_count++
			if("Crusher")
				if(leader == "") crusher_list += xenoinfo
				crusher_count++
			if("Praetorian")
				if(leader == "") praetorian_list += xenoinfo
				praetorian_count++
			if("Ravager")
				if(leader == "") ravager_list += xenoinfo
				ravager_count++
			if("Carrier")
				if(leader == "") carrier_list += xenoinfo
				carrier_count++
			if("Hivelord")
				if(leader == "") hivelord_list += xenoinfo
				hivelord_count++
			if("Burrower")
				if(leader == "") burrower_list += xenoinfo
				burrower_count++
			if ("Warrior")
				if (leader == "")
					warrior_list += xenoinfo
				warrior_count++
			if("Lurker")
				if(leader == "") hunter_list += xenoinfo
				hunter_count++
			if("Spitter")
				if(leader == "") spitter_list += xenoinfo
				spitter_count++
			if("Drone")
				if(leader == "") drone_list += xenoinfo
				drone_count++
			if("Runner")
				if(leader == "") runner_list += xenoinfo
				runner_count++
			if("Sentinel")
				if(leader == "") sentinel_list += xenoinfo
				sentinel_count++
			if ("Defender")
				if (leader == "")
					defender_list += xenoinfo
				defender_count++
			if("Bloody Larva") // all larva are caste = blood larva
				if(leader == "") larva_list += xenoinfo
				larva_count++

	dat += "<b>Total Living Sisters: [count]</b><BR>"
	//if(exotic_count != 0) //Exotic Xenos in the Hive like Predalien or Xenoborg
		//dat += "<b>Ultimate Tier:</b> [exotic_count] Sisters</b><BR>"
	dat += "<b>Tier 3: [boiler_count + crusher_count + praetorian_count + ravager_count] Sisters</b> | Boilers: [boiler_count] | Crushers: [crusher_count] | Praetorians: [praetorian_count] | Ravagers: [ravager_count]<BR>"
	dat += "<b>Tier 2: [carrier_count + burrower_count + hivelord_count + hunter_count + spitter_count + warrior_count] Sisters</b> | Carriers: [carrier_count] | Burrowers: [burrower_count] | Hivelords: [hivelord_count] | Warriors: [warrior_count] | Lurkers: [hunter_count] | Spitters: [spitter_count]<BR>"
	dat += "<b>Tier 1: [drone_count + runner_count + sentinel_count + defender_count] Sisters</b> | Drones: [drone_count] | Runners: [runner_count] | Sentinels: [sentinel_count] | Defenders: [defender_count]<BR>"
	dat += "<b>Larvas: [larva_count] Sisters<BR>"
	if(istype(user)) // cover calling it without parameters
		if(user.hivenumber == XENO_HIVE_NORMAL)
			dat += "<b>Burrowed Larva: [stored_larva_count] Sisters<BR>"
	dat += "<table cellspacing=4>"
	dat += queen_list + leader_list + boiler_list + crusher_list + praetorian_list + ravager_list + carrier_list + burrower_list + hivelord_list + warrior_list + hunter_list + spitter_list + drone_list + runner_list + sentinel_list + defender_list + larva_list
	dat += "</table></body>"
	usr << browse(dat, "window=roundstatus;size=500x500")


/mob/living/carbon/Xenomorph/verb/toggle_xeno_mobhud()
	set name = "Toggle Xeno Status HUD"
	set desc = "Переключает здоровье, плазмо hud, поЯвлЯющийсЯ над ксеноморфами."
	set category = "Alien"

	xeno_mobhud = !xeno_mobhud
	var/datum/mob_hud/H = huds[MOB_HUD_XENO_STATUS]
	if(xeno_mobhud)
		H.add_hud_to(usr)
	else
		H.remove_hud_from(usr)


/mob/living/carbon/Xenomorph/verb/middle_mousetoggle()
	set name = "Toggle Middle/Shift Clicking"
	set desc = "Переключение между использованием среднего щелчка мыши и shift, нажмите длЯ выбранного использованиЯ."
	set category = "Alien"

	middle_mouse_toggle = !middle_mouse_toggle
	if(!middle_mouse_toggle)
		to_chat(src, "<span class='notice'>Некоторые способности ксено будет активирована при нажатии на кнопку shift.</span>")
	else
		to_chat(src, "<span class='notice'>ВыбраннаЯ способность ксено теперь будет активирована средним щелчком мыши.</span>")
// Crusher Horn Toss
/mob/living/carbon/Xenomorph/proc/cresttoss(var/mob/living/carbon/M)
	if(cresttoss_used)
		return

	if(!check_plasma(CRUSHER_CRESTTOSS_COST))
		return

	if(legcuffed)
		to_chat(src, "<span class='xenodanger'>С этой штукой на ноге ты не сможешь нормально маневрировать!</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Вы пытаетесь отбросить [M], но слишком дезориентированы!</span>")
		return

	if (!Adjacent(M) || !istype(M, /mob/living)) //Sanity check
		return

	if(M.stat == DEAD || (M.status_flags & XENO_HOST && istype(M.buckled, /obj/structure/bed/nest) ) ) //no bully
		return

	if(M.mob_size >= MOB_SIZE_BIG) //We can't fling big aliens/mobs
		to_chat(src, "<span class='xenowarning'>[M] слишком большой, чтобы бросить!</span>")
		return

	face_atom(M) //Face towards the target so we don't look silly

	var/facing = get_dir(src, M)
	var/toss_distance = rand(3,5)
	var/turf/T = loc
	var/turf/temp = loc
	if(a_intent == "hurt") //If we use the ability on hurt intent, we throw them in front; otherwise we throw them behind.
		for (var/x = 0, x < toss_distance, x++)
			temp = get_step(T, facing)
			if (!temp)
				break
			T = temp
	else
		facing = get_dir(M, src)
		if(!check_blocked_turf(get_step(T, facing) ) ) //Make sure we can actually go to the target turf
			M.loc = get_step(T, facing) //Move the target behind us before flinging
			for (var/x = 0, x < toss_distance, x++)
				temp = get_step(T, facing)
				if (!temp)
					break
				T = temp
		else
			to_chat(src, "<span class='xenowarning'>Вы пытаетесь бросить [M] позади вас, но нет места!</span>")
			return

	//The target location deviates up to 1 tile in any direction
	var/scatter_x = rand(-1,1)
	var/scatter_y = rand(-1,1)
	var/turf/new_target = locate(T.x + round(scatter_x),T.y + round(scatter_y),T.z) //Locate an adjacent turf.
	if(new_target)
		T = new_target//Looks like we found a turf.

	icon_state = "Crusher Charging"  //Momentarily lower the crest for visual effect

	visible_message("<span class='xenowarning'>\The [src] бросает [M] прочь его гребнем!</span>", \
	"<span class='xenowarning'>Вы отбрасываете [M] прочь вашим гребнем!</span>")

	cresttoss_used = 1
	use_plasma(CRUSHER_CRESTTOSS_COST)


	M.throw_at(T, toss_distance, 1, src)

	//Handle the damage
	if(!isXeno(M)) //Friendly xenos don't take damage.
		var/damage = toss_distance * 5
		if(frenzy_aura)
			damage *= (1 + round(frenzy_aura * 0.1,0.01)) //+10% damage per level of frenzy
		M.apply_damage(damage, HALLOSS) //...But decent armour ignoring Halloss
		shake_camera(M, 2, 2)
		playsound(M,pick('sound/weapons/alien_claw_block.ogg','sound/weapons/alien_bite2.ogg'), 50, 1)
		M.KnockDown(1, 1)

	cresttoss_cooldown()
	spawn(3) //Revert to our prior icon state.
		if(m_intent == MOVE_INTENT_RUN)
			icon_state = "Crusher Running"
		else
			icon_state = "Crusher Walking"

/mob/living/carbon/Xenomorph/proc/cresttoss_cooldown()
	if(!cresttoss_used)//sanity check/safeguard
		return
	spawn(CRUSHER_CRESTTOSS_COOLDOWN)
		cresttoss_used = FALSE
		to_chat(src, "<span class='xenowarning'><b>Теперь вы можете снова бросить гребень.</b></span>")
		playsound(src, 'sound/effects/xeno_newlarva.ogg', 50, 0, 1)
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()
