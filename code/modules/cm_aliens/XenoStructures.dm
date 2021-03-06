
/*
 * effect/alien
 */
/obj/effect/alien
	name = "alien thing"
	desc = "� ���� ���� ���-�� �����."
	icon = 'icons/Xeno/Effects.dmi'
	unacidable = 1
	var/health = 1

/obj/effect/alien/flamer_fire_act()
	health -= 50
	if(health < 0) cdel(src)

/*
 * Resin
 */
/obj/effect/alien/resin
	name = "resin"
	desc = "������ �� �����-�� ��������� ������."
	icon_state = "Resin1"
	anchored = 1
	health = 200
	unacidable = 1


/obj/effect/alien/resin/proc/healthcheck()
	if(health <= 0)
		density = 0
		cdel(src)

/obj/effect/alien/resin/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage/2
	..()
	healthcheck()
	return 1

/obj/effect/alien/resin/ex_act(severity)
	switch(severity)
		if(1.0)
			health -= 500
		if(2.0)
			health -= (rand(140, 300))
		if(3.0)
			health -= (rand(50, 100))
	healthcheck()
	return

/obj/effect/alien/resin/hitby(AM as mob|obj)
	..()
	if(istype(AM,/mob/living/carbon/Xenomorph))
		return
	visible_message("<span class='danger'>\The [src] ��� ���� \the [AM].</span>", \
	"<span class='danger'>�� ����� \the [src].</span>")
	var/tforce = 0
	if(ismob(AM))
		tforce = 10
	else
		tforce = AM:throwforce
	if(istype(src, /obj/effect/alien/resin/sticky))
		playsound(loc, "alien_resin_move", 25)
	else
		playsound(loc, "alien_resin_break", 25)
	health = max(0, health - tforce)
	healthcheck()

/obj/effect/alien/resin/attack_alien(mob/living/carbon/Xenomorph/M)
	if(isXenoLarva(M)) //Larvae can't do shit
		return 0
	M.visible_message("<span class='xenonotice'>\The [M] ����� \the [src]!</span>", \
	"<span class='xenonotice'>�� ������� \the [src].</span>")
	if(istype(src, /obj/effect/alien/resin/sticky))
		playsound(loc, "alien_resin_move", 25)
	else
		playsound(loc, "alien_resin_break", 25)
	health -= (M.melee_damage_upper + 50) //Beef up the damage a bit
	healthcheck()

/obj/effect/alien/resin/attack_animal(mob/living/M as mob)
	M.visible_message("<span class='danger'>[M] ����� \the [src]!</span>", \
	"<span class='danger'>�� ���������� \the [name].</span>")
	if(istype(src, /obj/effect/alien/resin/sticky))
		playsound(loc, "alien_resin_move", 25)
	else
		playsound(loc, "alien_resin_break", 25)
	health -= 40
	healthcheck()

/obj/effect/alien/resin/attack_hand()
	to_chat(usr, "<span class='warning'>�� ������������ ��������� \the [src].</span>")

/obj/effect/alien/resin/attack_paw()
	return attack_hand()

/obj/effect/alien/resin/attackby(obj/item/W, mob/user)
	if(!(W.flags_item & NOBLUDGEON))
		var/damage = W.force
		if(W.w_class < 4 || !W.sharp || W.force < 20) //only big strong sharp weapon are adequate
			damage /= 4
		health -= damage
		if(istype(src, /obj/effect/alien/resin/sticky))
			playsound(loc, "alien_resin_move", 25)
		else
			playsound(loc, "alien_resin_break", 25)
		healthcheck()
	return ..()



// Sticky Resin And Speedy
/obj/effect/alien/resin/sticky
	name = "sticky resin"
	desc = "���� �������������� ������ �����."
	icon_state = "sticky"
	density = 0
	opacity = 0
	health = 36
	layer = RESIN_STRUCTURE_LAYER
	var/slow_amt = 8

	Crossed(atom/movable/AM)
		. = ..()
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			H.next_move_slowdown += slow_amt
/*
/obj/effect/alien/resin/speedy
	name = "speedy resin"
	desc =  "���� ��������� ����."
	icon_state = "speedy"
	density = 0
	opacity = 0
	health = 18
	layer = RESIN_STRUCTURE_LAYER
	var/speed_amt = 8

	Crossed(atom/movable/AM)
		. = ..()
		if(isxeno(AM))
			var/mob/living/carbon/xenomorph/X = AM
			X.next_move_slowdown -= slow_amt
*/
// Praetorian Sticky Resin spit uses this.
/obj/effect/alien/resin/sticky/thin
	name = "thin sticky resin"
	desc = "������ ���� �������������� ������ �����."
	health = 7
	slow_amt = 4

// Praetorian Speedy Resin spit uses this.
/*/obj/effect/alien/resin/speedy/thin
	name = "thin speedy resin"
	desc = "������ ���� ��������� ����."
	health = 7
	speed_amt = 4 */

//Carrier trap
/obj/effect/alien/resin/trap
	desc = "������ ���-��, �������� � ���������."
	name = "resin hole"
	icon_state = "trap0"
	density = 0
	opacity = 0
	anchored = 1
	health = 5
	layer = RESIN_STRUCTURE_LAYER
	var/hugger = FALSE
	var/carrier_number //the nicknumber of the carrier that placed us.

/obj/effect/alien/resin/trap/New(loc, mob/living/carbon/Xenomorph/Carrier/C)
	if(C)
		carrier_number = C.nicknumber
	..()

/obj/effect/alien/resin/trap/examine(mob/user)
	if(isXeno(user))
		to_chat(user, "���� ��� ���������� ����-��, ����� ���������� � ������.")
		if(hugger)
			to_chat(user, "��� ������ ���-�� ���������.")
		else
			to_chat(user, "��� �����.")
	else
		..()


/obj/effect/alien/resin/trap/flamer_fire_act()
	if(hugger)
		var/obj/item/clothing/mask/facehugger/FH = new (loc)
		FH.Die()
		hugger = FALSE
		icon_state = "trap0"
	..()

/obj/effect/alien/resin/trap/fire_act()
	if(hugger)
		var/obj/item/clothing/mask/facehugger/FH = new (loc)
		FH.Die()
		hugger = FALSE
		icon_state = "trap0"
	..()

/obj/effect/alien/resin/trap/bullet_act(obj/item/projectile/P)
	if(P.ammo.flags_ammo_behavior & (AMMO_XENO_ACID|AMMO_XENO_TOX))
		return
	. = ..()

/obj/effect/alien/resin/trap/HasProximity(atom/movable/AM)
	if(hugger)
		if(CanHug(AM) && !isYautja(AM) && !isSynth(AM))
			var/mob/living/L = AM
			L.visible_message("<span class='warning'>[L] ������� �� [src]!</span>",\
							"<span class='danger'>�� ������������ �� [src]!</span>")
			L.KnockDown(1)
			if(carrier_number)
				for(var/mob/living/carbon/Xenomorph/X in living_mob_list)
					if(X.nicknumber == carrier_number)
						if(!X.stat)
							var/area/A = get_area(src)
							if(A)
								to_chat(X, "<span class='xenoannounce'>�� ����������, ��� ���� �� ����� ������� � [A.name] ���� ��������!</span>")
						break
			drop_hugger()

/obj/effect/alien/resin/trap/proc/drop_hugger()
	set waitfor = 0
	var/obj/item/clothing/mask/facehugger/FH = new (loc)
	hugger = FALSE
	icon_state = "trap0"
	visible_message("<span class='warning'>[FH] ������� �� [src]!</span>")
	sleep(15)
	if(FH.stat == CONSCIOUS && FH.loc) //Make sure we're conscious and not idle or dead.
		FH.leap_at_nearest_target()

/obj/effect/alien/resin/trap/attack_alien(mob/living/carbon/Xenomorph/M)
	if(M.a_intent != "hurt")
		var/list/allowed_castes = list("Queen","Drone","Hivelord","Carrier")
		if(allowed_castes.Find(M.caste))
			if(!hugger)
				to_chat(M, "<span class='warning'>[src] �����.</span>")
			else
				hugger = FALSE
				icon_state = "trap0"
				var/obj/item/clothing/mask/facehugger/F = new ()
				M.put_in_active_hand(F)
				to_chat(M, "<span class='xenonotice'>������� facehugger �� [src].</span>")
		return
	..()

/obj/effect/alien/resin/trap/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/clothing/mask/facehugger) && isXeno(user))
		var/obj/item/clothing/mask/facehugger/FH = W
		if(FH.stat == DEAD)
			to_chat(user, "<span class='warning'>�� �� ������ ��������� �������� �������� � [src].</span>")
		else
			hugger = TRUE
			icon_state = "trap1"
			to_chat(user, "<span class='xenonotice'>�� ��������� �������� � [src].</span>")
			cdel(FH)
	else
		. = ..()

/obj/effect/alien/resin/trap/Crossed(atom/A)
	if(ismob(A))
		HasProximity(A)

/obj/effect/alien/resin/trap/Dispose()
	if(hugger && loc)
		drop_hugger()
	. = ..()



//Resin Doors
/obj/structure/mineral_door/resin
	name = "resin door"
	mineralType = "resin"
	icon = 'icons/Xeno/Effects.dmi'
	hardness = 1.5
	var/health = 80
	var/close_delay = 100

	tiles_with = list(/turf/closed, /obj/structure/mineral_door/resin)

/obj/structure/mineral_door/resin/New()
	spawn(0)
		relativewall()
		relativewall_neighbours()
		if(!locate(/obj/effect/alien/weeds) in loc)
			new /obj/effect/alien/weeds(loc)
	..()

/obj/structure/mineral_door/resin/attack_paw(mob/user as mob)
	if(user.a_intent == "hurt")
		user.visible_message("<span class='xenowarning'>\The [user] ����� �� \the [src].</span>", \
		"<span class='xenowarning'>�� ���������� �� \the [src].</span>")
		playsound(loc, "alien_resin_break", 25)
		health -= rand(40, 60)
		if(health <= 0)
			user.visible_message("<span class='xenodanger'>\The [user] ��������� \the [src] �� �����.</span>", \
			"<span class='xenodanger'>�� ���������� \the [src] �� �����.</span>")
		healthcheck()
		return
	else
		return TryToSwitchState(user)

/obj/structure/mineral_door/resin/attack_larva(mob/living/carbon/Xenomorph/Larva/M)
	var/turf/cur_loc = M.loc
	if(!istype(cur_loc))
		return FALSE
	TryToSwitchState(M)
	return TRUE

//clicking on resin doors attacks them, or opens them without harm intent
/obj/structure/mineral_door/resin/attack_alien(mob/living/carbon/Xenomorph/M)
	var/turf/cur_loc = M.loc
	if(!istype(cur_loc))
		return FALSE //Some basic logic here
	if(M.a_intent != "hurt")
		TryToSwitchState(M)
		return TRUE

	M.visible_message("<span class='warning'>\The [M] �������� � \the [src] � �������� ��������� ���.</span>", \
	"<span class='warning'>�� ��������� � \the [src] � ��������� ��������� ���.</span>", null, 5)
	playsound(src, "alien_resin_break", 25)
	if(do_after(M, 80, FALSE, 5, BUSY_ICON_HOSTILE))
		if(!loc)
			return FALSE //Someone already destroyed it, do_after should check this but best to be safe
		if(M.loc != cur_loc)
			return FALSE //Make sure we're still there
		M.visible_message("<span class='danger'>[M] ���� ���� \the [src]!</span>", \
		 "<span class='danger'>�� ���������� ���� \the [src]!</span>", null, 5)
		cdel(src)

/obj/structure/mineral_door/resin/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage/2
	..()
	healthcheck()
	return 1

/obj/structure/mineral_door/resin/TryToSwitchState(atom/user)
	if(isXeno(user))
		return ..()

/obj/structure/mineral_door/resin/Open()
	if(state || !loc) return //already open
	isSwitchingStates = 1
	playsound(loc, "alien_resin_move", 25)
	flick("[mineralType]opening",src)
	sleep(10)
	density = 0
	opacity = 0
	state = 1
	update_icon()
	isSwitchingStates = 0

	spawn(close_delay)
		if(!isSwitchingStates && state == 1)
			Close()

/obj/structure/mineral_door/resin/Close()
	if(!state || !loc) return //already closed
	//Can't close if someone is blocking it
	for(var/turf/turf in locs)
		if(locate(/mob/living) in turf)
			spawn (close_delay)
				Close()
			return
	isSwitchingStates = 1
	playsound(loc, "alien_resin_move", 25)
	flick("[mineralType]closing",src)
	sleep(10)
	density = 1
	opacity = 1
	state = 0
	update_icon()
	isSwitchingStates = 0
	for(var/turf/turf in locs)
		if(locate(/mob/living) in turf)
			Open()
			return

/obj/structure/mineral_door/resin/Dismantle(devastated = 0)
	cdel(src)

/obj/structure/mineral_door/resin/CheckHardness()
	playsound(loc, "alien_resin_move", 25)
	..()

/obj/structure/mineral_door/resin/Dispose()
	relativewall_neighbours()
	var/turf/U = loc
	spawn(0)
		var/turf/T
		for(var/i in cardinal)
			T = get_step(U, i)
			if(!istype(T)) continue
			for(var/obj/structure/mineral_door/resin/R in T)
				R.check_resin_support()
	. = ..()

/obj/structure/mineral_door/resin/proc/healthcheck()
	if(src.health <= 0)
		src.Dismantle(1)


//do we still have something next to us to support us?
/obj/structure/mineral_door/resin/proc/check_resin_support()
	var/turf/T
	for(var/i in cardinal)
		T = get_step(src, i)
		if(T.density)
			. = 1
			break
		if(locate(/obj/structure/mineral_door/resin) in T)
			. = 1
			break
	if(!.)
		visible_message("<span class = 'notice'>[src] ������� ��-�� ���������� ���������.</span>")
		cdel(src)



/obj/structure/mineral_door/resin/thick
	name = "thick resin door"
	health = 160
	hardness = 2.0


/*
 * Egg
 */
/var/const //for the status var
	BURST = 0
	BURSTING = 1
	GROWING = 2
	GROWN = 3
	DESTROYED = 4

	MIN_GROWTH_TIME = 100 //time it takes for the egg to mature once planted
	MAX_GROWTH_TIME = 150

/obj/effect/alien/egg
	desc = "��� �������� ��� �������� ����"
	name = "egg"
	icon_state = "Egg Growing"
	density = 0
	anchored = 1

	health = 80
	var/list/egg_triggers = list()
	var/status = GROWING //can be GROWING, GROWN or BURST; all mutually exclusive
	var/on_fire = 0
	var/hivenumber = XENO_HIVE_NORMAL

/obj/effect/alien/egg/New()
	..()
	create_egg_triggers()
	Grow()

/obj/effect/alien/egg/Dispose()
	. = ..()
	delete_egg_triggers()

/obj/effect/alien/egg/ex_act(severity)
	Burst(1)//any explosion destroys the egg.

/obj/effect/alien/egg/attack_alien(mob/living/carbon/Xenomorph/M)

	if(M.hivenumber != hivenumber)
		M.animation_attack_on(src)
		M.visible_message("<span class='xenowarning'>[M] ����� \the [src]","<span class='xenowarning'>�� ������ \the [src]")
		Burst(1)
		return

	if(!istype(M))
		return attack_hand(M)

	switch(status)
		if(BURST, DESTROYED)
			switch(M.caste)
				if("Queen","Drone","Hivelord","Carrier")
					M.visible_message("<span class='xenonotice'>\The [M] ������� ������������ ����.</span>", \
					"<span class='xenonotice'>�� �������� ������������ ����.</span>")
					playsound(src.loc, "alien_resin_break", 25)
					M.plasma_stored++
					cdel(src)
		if(GROWING)
			to_chat(M, "<span class='xenowarning'>������� ��� �� ������.</span>")
		if(GROWN)
			if(isXenoLarva(M))
				to_chat(M, "<span class='xenowarning'>������� ����, �� ������ �� ����������.</span>")
				return
			to_chat(M, "<span class='xenonotice'>�� ��������� �������.</span>")
			Burst(0)

/obj/effect/alien/egg/proc/Grow()
	set waitfor = 0
	update_icon()
	sleep(rand(MIN_GROWTH_TIME,MAX_GROWTH_TIME))
	if(status == GROWING)
		icon_state = "Egg"
		status = GROWN
		update_icon()
		deploy_egg_triggers()

/obj/effect/alien/egg/proc/create_egg_triggers()
	for(var/i=1, i<=8, i++)
		egg_triggers += new /obj/effect/egg_trigger(src, src)

/obj/effect/alien/egg/proc/deploy_egg_triggers()
	var/i = 1
	var/x_coords = list(-1,-1,-1,0,0,1,1,1)
	var/y_coords = list(1,0,-1,1,-1,1,0,-1)
	var/turf/target_turf
	for(var/atom/trigger in egg_triggers)
		var/obj/effect/egg_trigger/ET = trigger
		target_turf = locate(x+x_coords[i],y+y_coords[i], z)
		if(target_turf)
			ET.loc = target_turf
			i++

/obj/effect/alien/egg/proc/delete_egg_triggers()
	for(var/atom/trigger in egg_triggers)
		egg_triggers -= trigger
		cdel(trigger)

/obj/effect/alien/egg/proc/Burst(kill = 1) //drops and kills the hugger if any is remaining
	set waitfor = 0
	if(kill)
		if(status != DESTROYED)
			delete_egg_triggers()
			status = DESTROYED
			icon_state = "Egg Exploded"
			flick("Egg Exploding", src)
			playsound(src.loc, "sound/effects/alien_egg_burst.ogg", 25)
	else
		if(status == GROWN || status == GROWING)
			status = BURSTING
			delete_egg_triggers()
			icon_state = "Egg Opened"
			flick("Egg Opening", src)
			playsound(src.loc, "sound/effects/alien_egg_move.ogg", 25)
			sleep(10)
			if(loc && status != DESTROYED)
				status = BURST
				var/obj/item/clothing/mask/facehugger/child = new(loc)
				child.hivenumber = hivenumber
				child.leap_at_nearest_target()

/obj/effect/alien/egg/bullet_act(var/obj/item/projectile/P)
	..()
	if(P.ammo.flags_ammo_behavior & (AMMO_XENO_ACID|AMMO_XENO_TOX)) return
	health -= P.ammo.damage_type == BURN ? P.damage * 1.3 : P.damage
	healthcheck()
	P.ammo.on_hit_obj(src,P)
	return 1

/obj/effect/alien/egg/update_icon()
	overlays.Cut()
	if(hivenumber && hivenumber <= hive_datum.len)
		var/datum/hive_status/hive = hive_datum[hivenumber]
		if(hive.color)
			color = hive.color
	if(on_fire)
		overlays += "alienegg_fire"

/obj/effect/alien/egg/fire_act()
	on_fire = 1
	if(on_fire)
		update_icon()
		spawn(rand(125, 200))
			cdel(src)

/obj/effect/alien/egg/attackby(obj/item/W, mob/living/user)
	if(health <= 0)
		return

	if(istype(W,/obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/F = W
		if(F.stat != DEAD)
			switch(status)
				if(BURST)
					if(user)
						visible_message("<span class='xenowarning'>[user] ������ [F] ������� � [src].</span>","<span class='xenonotice'>�� ��������� ������� ������� � [src].</span>")
						user.temp_drop_inv_item(F)
					else
						visible_message("<span class='xenowarning'>[F] ��������� ������� � [src]!</span>") //Not sure how, but let's roll with it for now.
					status = GROWN
					icon_state = "Egg"
					cdel(F)
				if(DESTROYED) to_chat(user, "<span class='xenowarning'>��� ���� ������ ������ ������������.</span>")
				if(GROWING,GROWN) to_chat(user, "<span class='xenowarning'>��� ������ ��������.</span>")
		else
			to_chat(user, "<span class='xenowarning'>���� ������� �����.</span>")
		return

	if(W.flags_item & NOBLUDGEON)
		return

	user.animation_attack_on(src)
	if(W.attack_verb.len)
		visible_message("<span class='danger'>\The [src] ��� [pick(W.attack_verb)] � \the [W][(user ? " by [user]." : ".")]</span>")
	else
		visible_message("<span class='danger'>\The [src] ��� �������� � \the [W][(user ? " by [user]." : ".")]</span>")
	var/damage = W.force
	if(W.w_class < 4 || !W.sharp || W.force < 20) //only big strong sharp weapon are adequate
		damage /= 4
	if(istype(W, /obj/item/tool/weldingtool))
		var/obj/item/tool/weldingtool/WT = W

		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(src.loc, 'sound/items/Welder.ogg', 25, 1)
	else
		playsound(src.loc, "alien_resin_break", 25)

	health -= damage
	healthcheck()


/obj/effect/alien/egg/proc/healthcheck()
	if(health <= 0)
		Burst(1)

/obj/effect/alien/egg/HasProximity(atom/movable/AM as mob|obj)
	if(status == GROWN)
		if(!CanHug(AM) || isYautja(AM) || isSynth(AM)) //Predators are too stealthy to trigger eggs to burst. Maybe the huggers are afraid of them.
			return
		Burst(0)

/obj/effect/alien/egg/flamer_fire_act() // gotta kill the egg + hugger
	Burst(1)


//The invisible traps around the egg to tell it there's a mob right next to it.
/obj/effect/egg_trigger
	name = "egg trigger"
	icon = 'icons/effects/effects.dmi'
	anchored = 1
	mouse_opacity = 0
	invisibility = INVISIBILITY_MAXIMUM
	var/obj/effect/alien/egg/linked_egg

	New(loc, obj/effect/alien/egg/source_egg)
		..()
		linked_egg = source_egg


/obj/effect/egg_trigger/Crossed(atom/A)
	if(!linked_egg) //something went very wrong
		cdel(src)
	else if(get_dist(src, linked_egg) != 1 || !isturf(linked_egg.loc)) //something went wrong
		loc = linked_egg
	else if(iscarbon(A))
		var/mob/living/carbon/C = A
		linked_egg.HasProximity(C)




/*

TUNNEL

*/


/obj/structure/tunnel
	name = "tunnel"
	desc = "���� � �������. ������, ��� ������� �����-�� ����� � �������."
	icon = 'icons/Xeno/effects.dmi'
	icon_state = "hole"

	density = 0
	opacity = 0
	anchored = 1
	unacidable = 1
	layer = RESIN_STRUCTURE_LAYER

	var/tunnel_desc = "" //description added by the hivelord.

	var/health = 140
	var/obj/structure/tunnel/other = null
	var/id = null //For mapping

	New()
		..()
		spawn(5)
			if(id && !other)
				for(var/obj/structure/tunnel/T in structure_list)
					if(T.id == id && T != src && T.other == null) //Found a matching tunnel
						T.other = src
						other = T //Link them!
						break

/obj/structure/tunnel/Dispose()
	if(other)
		other.other = null
		other = null
	. = ..()

/obj/structure/tunnel/examine(mob/user)
	..()
	if(!isXeno(user) && !isobserver(user))
		return

	if(!other)
		to_chat(user, "<span class='warning'>�������, ��� ������ �� �����.</span>")
	else
		var/area/A = get_area(other)
		to_chat(user, "<span class='info'>������� ��� ����� � <b>[A.name]</b>.</span>")
		if(tunnel_desc)
			to_chat(user, "<span class='info'>����� Hivelord ������: \'[tunnel_desc]\'</span>")

/obj/structure/tunnel/proc/healthcheck()
	if(health <= 0)
		visible_message("<span class='danger'>[src] �������� �������!</span>")
		if(other && isturf(other.loc))
			visible_message("<span class='danger'>[other] �������� �������!</span>")
			cdel(other)
			other = null
		cdel(src)

/obj/structure/tunnel/bullet_act(var/obj/item/projectile/Proj)
	return 0

/obj/structure/tunnel/ex_act(severity)
	switch(severity)
		if(1.0)
			health -= 200
		if(2.0)
			health -= 120
		if(3.0)
			if(prob(50))
				health -= 50
			else
				health -= 25
	healthcheck()

/obj/structure/tunnel/attackby(obj/item/W as obj, mob/user as mob)
	if(!isXeno(user))
		return ..()
	attack_alien(user)

/obj/structure/tunnel/attack_alien(mob/living/carbon/Xenomorph/M)
	if(!istype(M) || M.stat || M.lying)
		return

	//Prevents using tunnels by the queen to bypass the fog.
	if(ticker && ticker.mode && ticker.mode.flags_round_type & MODE_FOG_ACTIVATED)
		var/datum/hive_status/hive = hive_datum[XENO_HIVE_NORMAL]
		if(!hive.living_xeno_queen)
			to_chat(M, "<span class='xenowarning'>��� ������� ��������. ������� �� ������ ����� ���������.</span>")
			return FALSE
		else if(isXenoQueen(M))
			to_chat(M, "<span class='xenowarning'>���� ��� ������ �������� ���������� ������.</span>")
			return FALSE

	if(M.anchored)
		to_chat(M, "<span class='xenowarning'>� ����������� ��������� �� ������� �� ���������.</span>")
		return FALSE

	var/tunnel_time = 40

	if(M.mob_size == MOB_SIZE_BIG) //Big xenos take WAY longer
		tunnel_time = 120

	if(isXenoLarva(M)) //Larva can zip through near-instantly, they are wormlike after all
		tunnel_time = 5

	if(!other || !isturf(other.loc))
		to_chat(M, "<span class='warning'>\The [src] ������ ������ �� �����.</span>")
		return

	var/area/A = get_area(other)

	if(tunnel_time <= 50)
		M.visible_message("<span class='xenonotice'>\The [M] �������� ������ ���� � \the [src].</span>", \
		"<span class='xenonotice'>�� ��������� ������ ���� � \the [src] � <b>[A.name]</b>.</span>")
	else
		M.visible_message("<span class='xenonotice'>[M]  �������� ��������� ���� �������� ����� ���� � \the [src].</span>", \
		"<span class='xenonotice'>�� ��������� ��������� ���� ���������� ����� � \the [src] � <b>[A.name]</b>.</span>")

	if(do_after(M, tunnel_time, FALSE, 5, BUSY_ICON_GENERIC))
		if(other && isturf(other.loc)) //Make sure the end tunnel is still there
			M.forceMove(other.loc)
			M.visible_message("<span class='xenonotice'>\The [M] ����������� �� \the [src].</span>", \
			"<span class='xenonotice'>�� ������������ � ������ �������!</span>")
		else
			to_chat(M, "<span class='warning'>\The [src] ���������� ����������,������� �� ������������� �������.</span>")
	else
		to_chat(M, "<span class='warning'>���� �������� ���� ��������!</span>")

