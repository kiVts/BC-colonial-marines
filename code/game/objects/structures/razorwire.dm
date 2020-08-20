/* (/obj/structure/barricade/razor)
/obj/structure/razorwire
	name = "razorwire obstacle"
	desc = "A bundle of barbed wire supported by metal rods. Used to deny access to areas under (literal) pain of entanglement and injury. A classic fortification since the 1900s."
	icon = 'icons/obj/structures/barbedwire.dmi'
	icon_state = "barbedwire_x"
	var/base_icon_state = "barbedwire_x"
	density = TRUE
	anchored = TRUE
	layer = ABOVE_OBJ_LAYER
	throwpass = TRUE	//You can throw objects over this
	climbable = FALSE
	var/list/entangled_list = list()
	var/sheet_type = /obj/item/stack/barbed_wire
	var/sheet_type2 = /obj/item/stack/rods
	var/table_prefix = "" //used in update_icon()
	var/barricade_resistance = 5
	barricade_type = "razor"
	health = 200
	maxhealth = 200
	var/is_wired = TRUE
	var/soak = 5

/obj/structure/razorwire/destroy(deconstruct,disassembled = TRUE)
	if(disassembled)
		if(health > maxhealth * 0.5)
			new sheet_type(loc)
		var/obj/item/stack/rods/salvage = new sheet_type2(loc)
		salvage.amount = min(1, round(4 * (health / maxhealth) ) )
	else
		if(prob(50))
			new sheet_type(loc)
		if(prob(50))
			var/obj/item/stack/rods/salvage = new sheet_type2(loc)
			salvage.amount = rand(1,4)
	return ..()

/obj/structure/razorwire/Crossed(atom/movable/O)
	. = ..()
	if(!isliving(O))
		return
	var/mob/living/M = O
	if(W.force > barricade_resistance)
		return
	playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
	var/armor_block = null
	var/def_zone = ran_zone()
	armor_block = M.run_armor_check(def_zone, "melee")
	M.apply_damage(rand(40 * 0.8, 40 * 1.2), BRUTE, def_zone, armor_block, TRUE)
	UPDATEHEALTH(M)
	razorwire_tangle(M)

/obj/structure/razorwire/hitby(atom/movable/AM)
	if(AM.throwing && is_wired)
		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			C.visible_message("<span class='danger'>The barbed wire slices into [C]!</span>",
			"<span class='danger'>The barbed wire slices into you!</span>")
			C.apply_damage(40)
			C.KnockDown(2) //Leaping into barbed wire is VERY bad
	..()


/obj/structure/razorwire/CheckExit(atom/movable/O, turf/target)
	if(closed)
		return TRUE

	if(O.throwing)
		if(is_wired && iscarbon(O)) //Leaping mob against barbed wire fails
			if(get_dir(loc, target) & dir)
				return FALSE
		return TRUE

	if(get_dir(loc, target) & dir)
		return FALSE
	else
		return TRUE

/obj/structure/razorwire/attackby(obj/item/I, mob/user, params)
	. = ..()

		if(iswirecutter(I))
		user.visible_message("<span class='notice'>[user] starts disassembling [src].</span>",
		"<span class='notice'>You start disassembling [src].</span>")
		var/delay_disassembly = 25

		if(!do_after(user, delay_disassembly, TRUE, src, BUSY_ICON_BUILD))
			return

		user.visible_message("<span class='notice'>[user] disassembles [src].</span>",
		"<span class='notice'>You disassemble [src].</span>")
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		deconstruct(TRUE)

	else if(iswelder(I))
		var/obj/item/tool/weldingtool/WT = I
		if(!WT.remove_fuel(0, user))
			return

		var/delay = SKILL_TASK_TOUGH - (1 SECONDS + user.skills.getRating("engineer") * 5)
		user.visible_message("<span class='notice'>[user] begins repairing damage to [src].</span>",
		"<span class='notice'>You begin repairing the damage to [src].</span>")
		playsound(loc, 'sound/items/welder2.ogg', 25, 1)
		var/old_loc = loc
		if(!do_after(user, delay, TRUE, src, BUSY_ICON_FRIENDLY) || old_loc != loc)
			return

		user.visible_message("<span class='notice'>[user] repairs some damage on [src].</span>",
		"<span class='notice'>You repair [src].</span>")
		repair_damage(100)
		update_icon()
		playsound(loc, 'sound/items/welder2.ogg', 25, 1)

/obj/structure/razorwire/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	health -= rand(M.melee_damage_lower, M.melee_damage_upper)
	if(razorwire_hitsound)
		playsound(src, razorwire_hitsound, 25, 1)
	if(health <= 0)
		M.visible_message("<span class='danger'>[M] slices [src] apart!</span>", \
		"<span class='danger'>You slice [src] apart!</span>", null, 5)
	else
		M.visible_message("<span class='danger'>[M] slashes [src]!</span>", \
		"<span class='danger'>You slash [src]!</span>", null, 5)
	if(is_wired)
		M.visible_message("<span class='danger'>The barbed wire slices into [M]!</span>",
		"<span class='danger'>The barbed wire slices into you!</span>", null, 5)
		M.apply_damage(100)
	update_health(TRUE)

/obj/structure/razorwire/ex_act(severity)
	switch(severity)
		if(1.0)
			visible_message("<span class='danger'>[src] is blown apart!</span>")
			cdel(src)
			return
		if(2.0)
			health -= rand(33, 66)
		if(3.0)
			health -= rand(10, 33)
	update_health()

/obj/structure/razorwire/proc/update_health(nomessage)
	health = CLAMP(health, 0, maxhealth)

	if(!health)
		if(!nomessage)
			visible_message("<span class='danger'>[src] falls apart!</span>")
		destroy()
		return

	update_damage_state()
	update_icon()

/obj/structure/razorwire/proc/acid_smoke_damage(var/obj/effect/particle_effect/smoke/S)
	health -= 15
	update_health()
*/