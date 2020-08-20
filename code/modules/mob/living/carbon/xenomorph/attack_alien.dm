//This file deals with xenos clicking on stuff in general. Including mobs, objects, general atoms, etc.
//Abby

/*
 * Important note about attack_alien : In our code, attack_ procs are received by src, not dealt by src
 * For example, attack_alien defined for humans means what will happen to THEM when attacked by an alien
 * In that case, the first argument is always the attacker. For attack_alien, it should always be Xenomorph sub-types
 */


/mob/living/carbon/human/attack_alien(mob/living/carbon/Xenomorph/M, dam_bonus)
	if (M.fortify)
		return FALSE

	//Reviewing the four primary intents
	switch(M.a_intent)

		if("help")
			M.visible_message("<span class='notice'>\The [M] ласкает [src] косой рукой.</span>", \
			"<span class='notice'>Вы ласкаете [src] своей косой рукой.</span>", null, 5)

		if("grab")
			if(M == src || anchored || buckled)
				return FALSE

			if(check_shields(0, M.name) && prob(90)) //Bit of a bonus
				M.visible_message("<span class='danger'>\The [M]'s захват заблокирован щитом [src]'s!</span>", \
				"<span class='danger'>Ваш захват был заблокирован щитом [src]'s!</span>", null, 5)
				playsound(loc, 'sound/weapons/alien_claw_block.ogg', 25, 1) //Feedback
				return FALSE

			if(Adjacent(M)) //Logic!
				M.start_pulling(src)

		if("hurt")
			var/datum/hive_status/hive
			if(M.hivenumber && M.hivenumber <= hive_datum.len)
				hive = hive_datum[M.hivenumber]
			else return

			if(!hive.slashing_allowed && !M.is_intelligent)
				to_chat(M, "<span class='warning'>Сеча в настоЯщее времЯ <b>запрещено</b> Королевой. Вы отказываетесь резать [src].</span>")
				return FALSE

			if(stat == DEAD)
				if(luminosity > 0)
					playsound(loc, "alien_claw_metal", 25, 1)
					M.flick_attack_overlay(src, "slash")
					var/datum/effect_system/spark_spread/spark_system2
					spark_system2 = new /datum/effect_system/spark_spread()
					spark_system2.set_up(5, 0, src)
					spark_system2.attach(src)
					spark_system2.start(src)
					disable_lights()
					to_chat(M, "<span class='warning'>Вы ломаете все раздражающие огни, которыми обладает мертвое существо.</span>")
				else
					to_chat(M, "<span class='warning'>[src] мертв, почему вы хотите прикоснутьсЯ к нему?</span>")
				return FALSE

			if(!M.is_intelligent)
				if(hive.slashing_allowed == 2)
					if(status_flags & XENO_HOST)
						for(var/obj/item/alien_embryo/embryo in src)
							if(embryo.hivenumber == M.hivenumber)
								to_chat(M, "<span class='warning'>Ты пытаетесь атаковать [src], но <B>запрещено</B>. Там внутри хозЯина твоЯ сестра!</span>")
								return FALSE

					if(M.health > round(M.maxHealth * 0.66)) //Note : Under 66 % health
						to_chat(M, "<span class='warning'>Вы пытаетесь атаковать [src], но <B>запрещено</B>. Ты еще недостаточно ранен, чтобы нарушить приказ Королевы.</span>")
						return FALSE

				else if(istype(buckled, /obj/structure/bed/nest) && (status_flags & XENO_HOST))
					for(var/obj/item/alien_embryo/embryo in src)
						if(embryo.hivenumber == M.hivenumber)
							to_chat(M, "<span class='warning'>Вы не должны вредить этому хосту! У него есть ваша сестра внутри.</span>")
							return FALSE

			if(check_shields(0, M.name) && prob(90)) //Bit of a bonus
				M.visible_message("<span class='danger'>\The [M]'s удар заблокирован щитом [src]!</span>", \
				"<span class='danger'>Ваш удар заблокирован щитом [src]!</span>", null, 5)
				return FALSE

			//From this point, we are certain a full attack will go out. Calculate damage and modifiers
			var/damage = rand(M.melee_damage_lower, M.melee_damage_upper) + dam_bonus

			//Frenzy auras stack in a way, then the raw value is multipled by two to get the additive modifier
			if(M.frenzy_aura > 0)
				damage += (M.frenzy_aura * 2)

			M.animation_attack_on(src)

			//Check for a special bite attack
			if(prob(M.bite_chance))
				M.bite_attack(src, damage)
				return TRUE

			//Check for a special bite attack
			if(prob(M.tail_chance))
				M.tail_attack(src, damage)
				return TRUE

			//Somehow we will deal no damage on this attack
			if(!damage)
				playsound(M.loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
				M.animation_attack_on(src)
				M.visible_message("<span class='danger'>\The [M] бросаетсЯ на [src]!</span>", \
				"<span class='danger'>Вы бросаетесь на [src]!</span>", null, 5)
				return FALSE

			M.flick_attack_overlay(src, "slash")
			var/datum/limb/affecting
			affecting = get_limb(ran_zone(M.zone_selected, 70))
			if(!affecting) //No organ, just get a random one
				affecting = get_limb(ran_zone(null, 0))
			if(!affecting) //Still nothing??
				affecting = get_limb("chest") //Gotta have a torso?!

			var/armor_block = run_armor_check(affecting, "melee")

			if(isYautja(src) && check_zone(M.zone_selected) == "head")
				if(istype(wear_mask, /obj/item/clothing/mask/gas/yautja))
					var/knock_chance = 1
					if(M.frenzy_aura > 0)
						knock_chance += 2 * M.frenzy_aura
					if(M.is_intelligent)
						knock_chance += 2
					knock_chance += min(round(damage * 0.25), 10) //Maximum of 15% chance.
					if(prob(knock_chance))
						playsound(loc, "alien_claw_metal", 25, 1)
						M.visible_message("<span class='danger'>The [M] разбивает [src]'s [wear_mask.name]!</span>", \
						"<span class='danger'>Вы разбиваете [src]'s [wear_mask.name]!</span>", null, 5)
						drop_inv_item_on_ground(wear_mask)
						emote("roar")
						return TRUE

			//The normal attack proceeds
			playsound(loc, "alien_claw_flesh", 25, 1)
			M.visible_message("<span class='danger'>\The [M] режет [src]!</span>", \
			"<span class='danger'>Ты режешь [src]!</span>")

			//Logging, including anti-rulebreak logging
			if(src.status_flags & XENO_HOST && src.stat != DEAD)
				if(istype(src.buckled, /obj/structure/bed/nest)) //Host was buckled to nest while infected, this is a rule break
					log_combat(M, src, "slashed", addition="while they were infected and nested")
					msg_admin_ff("[key_name(M)] slashed [key_name(src)] while they were infected and nested.") //This is a blatant rulebreak, so warn the admins
				else //Host might be rogue, needs further investigation
					log_combat(M, src, "slashed", addition="while they were infected")
			else //Normal xenomorph friendship with benefits
				log_combat(M, src, "slashed")

			if (M.caste == "Ravager")
				var/mob/living/carbon/Xenomorph/Ravager/R = M
				if (R.delimb(src, affecting))
					return TRUE

			apply_damage(damage, BRUTE, affecting, armor_block, sharp = 1, edge = 1) //This should slicey dicey
			updatehealth()

		if("disarm")
			if(M.legcuffed && isYautja(src))
				to_chat(M, "<span class='xenodanger'>У тебЯ не хватит ловкости справитьсЯ с охотником за головами с этой штукой на ноге!</span>")
				return FALSE
			M.animation_attack_on(src)
			if(check_shields(0, M.name) && prob(66)) //Bit of a bonus
				M.visible_message("<span class='danger'>\The [M]'s способность заблокирована щитом [src]!</span>", \
				"<span class='danger'>Ваша способность заблокирована щитом [src]!</span>", null, 5)
				return FALSE
			M.flick_attack_overlay(src, "disarm")
			if(knocked_down)
				if(isYautja(src))
					if(prob(95))
						M.visible_message("<span class='danger'>[src] избегает \the [M]'s снасти!</span>", \
						"<span class='danger'>src] избегает вашей попытки сбить с ног его!</span>", null, 5)
						playsound(loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
						return TRUE
				else if(prob(80))
					playsound(loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
					M.visible_message("<span class='danger'>\The [M] пытаетсЯ сбить с ног [src], но он уже повален!</span>", \
					"<span class='danger'>Вы пытаетесь сбить с ног [src], но он уже повален!</span>", null, 5)
					return TRUE
				playsound(loc, 'sound/weapons/pierce.ogg', 25, 1)
				KnockDown(rand(M.tacklemin, M.tacklemax)) //Min and max tackle strenght. They are located in individual caste files.
				M.visible_message("<span class='danger'>\The [M] сбил с ног [src]!</span>", \
				"<span class='danger'>Вы сбили с ног [src]!</span>", null, 5)

			else
				var/tackle_bonus = 0
				if(M.frenzy_aura > 0)
					tackle_bonus = M.frenzy_aura * 3
				if(isYautja(src))
					if(prob((M.tackle_chance + tackle_bonus)*0.2))
						playsound(loc, 'sound/weapons/alien_knockdown.ogg', 25, 1)
						KnockDown(rand(M.tacklemin, M.tacklemax))
						M.visible_message("<span class='danger'>\The [M] сбил с ног [src]!</span>", \
						"<span class='danger'>Вы сбили с ног [src]!</span>", null, 5)
						return TRUE
					else
						playsound(loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
						M.visible_message("<span class='danger'>\The [M] пытаетсЯ сбить с ног [src]</span>", \
						"<span class='danger'>Вы пытаетесь сбить с ног [src]</span>", null, 5)
						return TRUE
				else if(prob(M.tackle_chance + tackle_bonus)) //Tackle_chance is now a special var for each caste.
					playsound(loc, 'sound/weapons/alien_knockdown.ogg', 25, 1)
					KnockDown(rand(M.tacklemin, M.tacklemax))
					M.visible_message("<span class='danger'>\The [M] сбил с ног [src]!</span>", \
					"<span class='danger'>Вы сбили с ног [src]!</span>", null, 5)
					return TRUE

				playsound(loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
				M.visible_message("<span class='danger'>\The [M] пытаетсЯ сбить с ног [src]</span>", \
				"<span class='danger'>Вы пытаетесь сбить с ног [src]</span>", null, 5)
	return TRUE


//Every other type of nonhuman mob
/mob/living/attack_alien(mob/living/carbon/Xenomorph/M)
	if (M.fortify)
		return FALSE

	switch(M.a_intent)
		if("help")
			M.visible_message("<span class='notice'>\The [M] ласкает [src] своей косой рукой.</span>", \
			"<span class='notice'>Вы ласкаете [src] своей косой рукой.</span>", null, 5)
			return FALSE

		if("grab")
			if(M == src || anchored || buckled)
				return FALSE

			if(Adjacent(M)) //Logic!
				M.start_pulling(src)

		if("hurt")
			if(isXeno(src) && xeno_hivenumber(src) == M.hivenumber)
				M.visible_message("<span class='warning'>\The [M] кусает [src].</span>", \
				"<span class='warning'>Вы кусаете [src].</span>", null, 5)
				return TRUE

			var/datum/hive_status/hive
			if(M.hivenumber && M.hivenumber <= hive_datum.len)
				hive = hive_datum[M.hivenumber]
			else return

			if(!M.is_intelligent)
				if(hive.slashing_allowed == 2)
					if(status_flags & XENO_HOST)
						for(var/obj/item/alien_embryo/embryo in src)
							if(embryo.hivenumber == M.hivenumber)
								to_chat(M, "<span class='warning'>Вы пытаетесь ударить [src], но разрешить вам <B>не может</B>. Там внутри хоста!</span>")
								return FALSE

					if(M.health > round(2 * M.maxHealth / 3)) //Note : Under 66 % health
						to_chat(M, "<span class='warning'>Вы пытаетесь ударить [src], но разрешить вам <B>не может</B>. Ты еще недостаточно ранен, чтобы нарушить приказ королевы.</span>")
						return FALSE

				else if(istype(buckled, /obj/structure/bed/nest) && (status_flags & XENO_HOST))
					for(var/obj/item/alien_embryo/embryo in src)
						if(embryo.hivenumber == M.hivenumber)
							to_chat(M, "<span class='warning'>Вы не должны вредить этому хозЯину! У него есть сестра внутри.</span>")
							return FALSE

			if(issilicon(src) && stat != DEAD) //A bit of visual flavor for attacking Cyborgs. Sparks!
				var/datum/effect_system/spark_spread/spark_system
				spark_system = new /datum/effect_system/spark_spread()
				spark_system.set_up(5, 0, src)
				spark_system.attach(src)
				spark_system.start(src)
				playsound(loc, "alien_claw_metal", 25, 1)

			// copypasted from attack_alien.dm
			//From this point, we are certain a full attack will go out. Calculate damage and modifiers
			var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)

			//Frenzy auras stack in a way, then the raw value is multipled by two to get the additive modifier
			if(M.frenzy_aura > 0)
				damage += (M.frenzy_aura * 2)

			//Somehow we will deal no damage on this attack
			if(!damage)
				playsound(M.loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
				M.animation_attack_on(src)
				M.visible_message("<span class='danger'>\The [M] бросаетсЯ на [src]!</span>", \
				"<span class='danger'>Вы бросаетесь на [src]!</span>", null, 5)
				return FALSE

			M.visible_message("<span class='danger'>\The [M] режет [src]!</span>", \
			"<span class='danger'>Ты режешь [src]!</span>", null, 5)
			log_combat(M, src, "slashed")

			playsound(loc, "alien_claw_flesh", 25, 1)
			apply_damage(damage, BRUTE)

		if("disarm")
			playsound(loc, 'sound/weapons/alien_knockdown.ogg', 25, 1)
			M.visible_message("<span class='warning'>\The [M] пихает [src]!</span>", \
			"<span class='warning'>Ты пихаешь [src]!</span>", null, 5)
			if(ismonkey(src))
				KnockDown(8)
	return FALSE

/mob/living/attack_larva(mob/living/carbon/Xenomorph/Larva/M)
	M.visible_message("<span class='danger'>[M] тычетсЯ головой в [src].</span>", \
	"<span class='danger'>Ты прижимаешьсЯ головой к [src].</span>", null, 5)

/obj/attack_larva(mob/living/carbon/Xenomorph/Larva/M)
	return //larva can't do anything by default