
//var/mob/living/carbon/Xenomorph/Queen/living_xeno_queen //global reference to the Xeno Queen if there's one alive.

/proc/update_living_queens() // needed to update when you change a queen to a different hive
	outer_loop:
		for(var/datum/hive_status/hive in hive_datum)
			if(hive.living_xeno_queen)
				if(hive.living_xeno_queen.hivenumber == hive.hivenumber)
					continue
			for(var/mob/living/carbon/Xenomorph/Queen/Q in living_mob_list)
				if(Q.hivenumber == hive.hivenumber)
					hive.living_xeno_queen = Q
					xeno_message("<span class='xenoannounce'>НоваЯ королева поднЯлась, чтобы возглавить улей! Радуйтесь!</span>",3,hive.hivenumber)
					continue outer_loop
			hive.living_xeno_queen = null

/mob/living/carbon/Xenomorph/Queen
	caste = "Queen"
	name = "Queen"
	desc = "Огромное, угрожающее инопланетное существо. Самый большой и самый плохой."
	icon = 'icons/Xeno/xenomorph_64x64.dmi'
	icon_state = "Queen Walking"
	melee_damage_lower = 20
	melee_damage_upper = 30
	tacklemin = 4
	tacklemax = 6
	tackle_chance = 80
	attacktext = "bites"
	attack_sound = null
	friendly = "nuzzles"
	wall_smash = 0
	health = 300
	maxHealth = 300
	amount_grown = 0
	max_grown = 10
	plasma_stored = 500
	plasma_max = 800
	plasma_gain = 30
	is_intelligent = 1
	speed = 0.6
	upgrade_threshold = 800
	evolution_allowed = FALSE
	pixel_x = -16
	old_x = -16
	fire_immune = 1
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	armor_deflection = 50
	tier = 0 //Queen doesn't count towards population limit.
	upgrade = 0
	aura_strength = 5 //The Queen's aura is strong and stays so, and gets devastating late game. Climbs by 1 to 5
	caste_desc = "Самый большой и самый плохой алиен. Королева контролирует улей и сажает Яйца"
	xeno_explosion_resistance = 3 //some resistance against explosion stuns.
	spit_delay = 25
	spit_types = list(/datum/ammo/xeno/toxin/medium, /datum/ammo/xeno/acid/medium)

	var/breathing_counter = 0
	var/ovipositor = FALSE //whether the Queen is attached to an ovipositor
	var/ovipositor_cooldown = 0
	var/queen_ability_cooldown = 0
	var/mob/living/carbon/Xenomorph/observed_xeno //the Xenomorph the queen is currently overwatching
	var/egg_amount = 0 //amount of eggs inside the queen
	var/last_larva_time = 0
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/watch_xeno,
//		/datum/action/xeno_action/deevolve,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/choose_resin,
		/datum/action/xeno_action/activable/secrete_resin,
		/datum/action/xeno_action/grow_ovipositor,
		/datum/action/xeno_action/activable/screech,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/emit_pheromones,
		/datum/action/xeno_action/activable/gut,
		/datum/action/xeno_action/psychic_whisper,
		/datum/action/xeno_action/shift_spits,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/ready_charge,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/claw_toggle,
		/mob/living/carbon/Xenomorph/Queen/proc/set_orders,
		/mob/living/carbon/Xenomorph/Queen/proc/hive_Message
		)

/mob/living/carbon/Xenomorph/Queen/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/Xenomorph/Queen/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/Xenomorph/Queen/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/Xenomorph/Queen/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/Xenomorph/Queen/New()
	..()
	if(z != ADMIN_Z_LEVEL)//so admins can safely spawn Queens in Thunderdome for tests.
		if(hivenumber && hivenumber <= hive_datum.len)
			var/datum/hive_status/hive = hive_datum[hivenumber]
			if(!hive.living_xeno_queen)
				hive.living_xeno_queen = src
			xeno_message("<span class='xenoannounce'>НоваЯ королева поднЯлась, чтобы возглавить улей! Радуйтесь!</span>",3,hivenumber)
	playsound(loc, 'sound/voice/alien_queen_command.ogg', 75, 0)

/mob/living/carbon/Xenomorph/Queen/Dispose()
	. = ..()
	if(observed_xeno)
		set_queen_overwatch(observed_xeno, TRUE)
	if(hivenumber && hivenumber <= hive_datum.len)
		var/datum/hive_status/hive = hive_datum[hivenumber]
		if(hive.living_xeno_queen == src)
			hive.living_xeno_queen = null

/mob/living/carbon/Xenomorph/Queen/Life()
	..()

	if(stat != DEAD)
		if(++breathing_counter >= rand(12, 17)) //Increase the breathing variable each tick. Play it at random intervals.
			playsound(loc, pick('sound/voice/alien_queen_breath1.ogg', 'sound/voice/alien_queen_breath2.ogg'), 15, 1, 4)
			breathing_counter = 0 //Reset the counter

		if(observed_xeno)
			if(observed_xeno.stat == DEAD || observed_xeno.disposed)
				set_queen_overwatch(observed_xeno, TRUE)

		if(ovipositor && !is_mob_incapacitated(TRUE))
			egg_amount += 0.07 //one egg approximately every 30 seconds
			if(egg_amount >= 1)
				if(isturf(loc))
					var/turf/T = loc
					if(T.contents.len <= 25) //so we don't end up with a million object on that turf.
						egg_amount--
						var/obj/item/xeno_egg/newegg = new /obj/item/xeno_egg(loc)
						newegg.hivenumber = hivenumber

			if(hivenumber == XENO_HIVE_NORMAL && loc.z == 1)
				if(ticker.mode.stored_larva)
					if((last_larva_time + 600) < world.time) // every minute
						last_larva_time = world.time
						var/list/players_with_xeno_pref = get_alien_candidates()
						if(players_with_xeno_pref.len)
							var/mob/living/carbon/Xenomorph/Larva/new_xeno = new /mob/living/carbon/Xenomorph/Larva(loc)
							new_xeno.visible_message("<span class='xenodanger'>Вдруг из земли вылезает личинка!</span>",
							"<span class='xenodanger'>Вы выкапываетесь из земли и просыпаетесь. За улей!</span>")
							new_xeno << sound('sound/effects/xeno_newlarva.ogg')
							new_xeno.key = pick(players_with_xeno_pref)

							if(new_xeno.client)
								new_xeno.client.change_view(world.view)

							to_chat(new_xeno, "<span class='xenoannounce'>Ты-личинка ксеноморфа, пробудившаЯсЯ ото сна!</span>")
							new_xeno << sound('sound/effects/xeno_newlarva.ogg')

							ticker.mode.stored_larva--

				var/searchx
				var/searchy
				var/turf/searchspot
				for(searchx=-1, searchx<1, searchx++)
					for(searchy=-1, searchy<1, searchy++)
						searchspot = locate(loc.x+searchx, loc.y+searchy, loc.z)
						for(var/mob/living/carbon/Xenomorph/Larva/L in searchspot)
							if(!L.ckey || !L.client) // no one home
								visible_message("<span class='xenodanger'>[L] быстро зарываетсЯ в землю.</span>")
								ticker.mode.stored_larva++
								round_statistics.total_xenos_created-- // keep stats sane
								cdel(L)

/mob/living/carbon/Xenomorph/proc/handlee_collision(atom/target)
	if(!target)
		return FALSE

	//Barricade collision
	if(istype(target, /obj/structure/barricade))
		var/obj/structure/barricade/B = target
		if(charge_speed > charge_speed_buildup * charge_turfs_to_charge)
			visible_message("<span class='danger'>[src] таранит [B] и останавливаетсЯ!</span>",
			"<span class='xenowarning'>Ты таранишь [B] и останавливаешсЯ!</span>")
			flags_pass = 0
			update_icons()
			B.Bumped(src)
			stop_momentum(charge_dir)
			return TRUE
		else
			stop_momentum(charge_dir)
			return FALSE

	if(istype(target, /obj/vehicle/multitile/hitbox))
		var/obj/vehicle/multitile/hitbox/H = target
		if(charge_speed > charge_speed_buildup * charge_turfs_to_charge)
			visible_message("<span class='danger'>[src] таранит [H.root] и останавливаетсЯ!</span>",
			"<span class='xenowarning'>Ты таранишь [H.root] и останавливаешсЯ!</span>")
			flags_pass = 0
			update_icons()
			H.root.Bumped(src)
			stop_momentum(charge_dir)
			return TRUE
		else
			stop_momentum(charge_dir)
			return FALSE

/obj/machinery/marine_turret/charge_act(mob/living/carbon/Xenomorph/X)
	if(unacidable)
		X.stop_momentum(X.charge_dir, TRUE)
		return FALSE
	if(X.charge_speed < X.charge_speed_buildup * X.charge_turfs_to_charge)
		X.stop_momentum(X.charge_dir)
		return FALSE
	X.visible_message("<span class='danger'>[X] таранит [src]!</span>",
	"<span class='xenodanger'>Ты таранишь [src]!</span>")
	playsound(loc, "punch", 25, 1)
	stat = 1
	on = 0
	update_icon()
	update_health(X.charge_speed * 20)
	X.charge_speed -= X.charge_speed_buildup * 3 //Lose three turfs worth of speed
	return TRUE

/obj/structure/table/charge_act(mob/living/carbon/Xenomorph/X)
	Crossed(X)
	return TRUE

//Custom bump for crushers. This overwrites normal bumpcode from carbon.dm
/mob/living/carbon/Xenomorph/Queen/Bump(atom/A, yes)
	set waitfor = 0

	if(charge_speed < charge_speed_buildup * charge_turfs_to_charge || !is_charging) return ..()

	if(stat || !A || !istype(A) || A == src || !yes) return FALSE

	if(now_pushing) return FALSE//Just a plain ol turf, let's return.

	if(dir != charge_dir) //We aren't facing the way we're charging.
		stop_momentum()
		return ..()

	if(!handle_collision(A))
		if(!A.charge_act(src)) //charge_act is depricated and only here to handle cases that have not been refactored as of yet.
			return ..()

	var/turf/T = get_step(src, dir)
	if(!T || !get_step_to(src, T)) //If it still exists, try to push it.
		return ..()

	lastturf = null //Reset this so we can properly continue with momentum.
	return TRUE

//Chance of insta limb amputation after a melee attack.
/mob/living/carbon/Xenomorph/Queen/proc/delimb(var/mob/living/carbon/human/H, var/datum/limb/O)
	if (prob(20))
		O = H.get_limb(check_zone(zone_selected))
		if (O.body_part != UPPER_TORSO && O.body_part != LOWER_TORSO && O.body_part != HEAD) //Only limbs.
			visible_message("<span class='danger'>Конечность отрезана начисто!</span>", \
			"<span class='danger'>Ты отрубаешь конечность!</span>")
			O.droplimb()
			return 1

	return 0

/mob/living/carbon/Xenomorph/Queen/proc/set_orders()
	set category = "Alien"
	set name = "Set Hive Orders (50)"
	set desc = "Отдайте улью несколько конкретных приказов. Они могут видеть это на панели состоЯниЯ."

	if(hivenumber == XENO_HIVE_CORRUPTED)
		to_chat(src, "<span class='warning'>Только ваши хозЯева могут решить это!</span>")
		return

	if(!check_state())
		return
	if(!check_plasma(50))
		return
	if(last_special > world.time)
		return
	plasma_stored -= 50
	var/txt = copytext(sanitize(input("Установить приказы ульЯ на что? Оставьте пустым, чтобы очистить его.", "Hive Orders", null) as text), 1, MAX_MESSAGE_LEN)


	var/datum/hive_status/hive
	if(hivenumber && hivenumber <= hive_datum.len)
		hive = hive_datum[hivenumber]
	else return

	if(txt)
		xeno_message("<B>Королева отдала новый приказ. Проверьте панель состоЯниЯ длЯ деталей.</B>",3,hivenumber)
		hive.hive_orders = fix_rus_stats(txt)
	else
		hive.hive_orders = ""

	last_special = world.time + 150

/mob/living/carbon/Xenomorph/Queen/proc/hive_Message()
	set category = "Alien"
	set name = "Word of the Queen (50)"
	set desc = "Отправьте сообщение всем инопланетЯнам в улье, которые большие и видимые"
	if(!check_plasma(50))
		return
	plasma_stored -= 50
	if(health <= 0)
		to_chat(src, "<span class='warning'>Вы не можете сделать это, не осознаваЯ.</span>")
		return 0
	var/input = stripped_multiline_input(src, "Это сообщение будет передано по всему улью.", "Word of the Queen", "")
	if(!input)
		return

	var/queensWord = "<br><h2 class='alert'>Слова королевы звучат в твоей голове...</h2>"
	queensWord += "<br><span class='alert'>[sanitize(input)]</span><br>"

	if(ticker && ticker.mode)
		for(var/datum/mind/L in ticker.mode.xenomorphs)
			var/mob/living/carbon/Xenomorph/X = L.current
			if(X && X.client && istype(X) && !X.stat && hivenumber == X.hivenumber)
				X << sound(get_sfx("queen"),wait = 0,volume = 50)
				to_chat(X, "[queensWord]")

	spawn(0)
		for(var/mob/dead/observer/G in player_list)
			G << sound(get_sfx("queen"),wait = 0,volume = 50)
			to_chat(G, "[queensWord]")

	log_admin("[key_name(src)] создал отчет Word of the Королевы:")
	log_admin("[queensWord]")
	message_admins("[key_name_admin(src)] создал доклад Королевы.", 1)


/mob/living/carbon/Xenomorph/proc/claw_toggle()
	set name = "Permit/Disallow Slashing"
	set desc = "ПозволЯет позволить улью причинить вред."
	set category = "Alien"

	if(hivenumber == XENO_HIVE_CORRUPTED)
		to_chat(src, "<span class='warning'>Только ваши хозЯева могут решить это!</span>")
		return

	if(stat)
		to_chat(src, "<span class='warning'>Ты не можешь сделать это сейчас.</span>")
		return

	if(pslash_delay)
		to_chat(src, "<span class='warning'>Вы должны подождать немного, прежде чем вы можете переключить это снова.</span>")
		return

	spawn(300)
		pslash_delay = 0

	pslash_delay = 1

	var/datum/hive_status/hive
	if(hivenumber && hivenumber <= hive_datum.len)
		hive = hive_datum[hivenumber]
	else return

	var/choice = input("Выберите, какой уровень атаки хостов, чтобы разрешить вашему улью.","Атака") as null|anything in list("Допустимый", "Ограниченный-Меньше ПовреждениЯ", "Запрещенный")

	if(choice == "Allowed")
		to_chat(src, "<span class='xenonotice'>Вы позволЯете убивать.</span>")
		xeno_message("The Queen has <b>permitted</b> Атака хоста! Сходи с ума!")
		hive.slashing_allowed = 1
	else if(choice == "Restricted - Less Damage")
		to_chat(src, "<span class='xenonotice'>Вы ограничиваете убийства.</span>")
		xeno_message("The Queen has <b>restricted</b> Атака хоста. Ты будешь атаковать, только когда будет больно.")
		hive.slashing_allowed = 2
	else if(choice == "Forbidden")
		to_chat(src, "<span class='xenonotice'>Ты полностью запрещаешь атаковать.</span>")
		xeno_message("The Queen has <b>forbidden</b> Атака хоста. Ты больше не можешь атаковать врагов.")
		hive.slashing_allowed = 0

/mob/living/carbon/Xenomorph/Queen/proc/queen_screech()
	if(!check_state())
		return

	if(has_screeched)
		to_chat(src, "<span class='warning'>Вы не готовы снова кричать.</span>")
		return

	if(!check_plasma(500))
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
	use_plasma(500)
	spawn(500)
		has_screeched = 0
		to_chat(src, "<span class='warning'>Вы чувствуете, как вибрируют мышцы горла. Вы готовы снова закричать.</span>")
		for(var/Z in actions)
			var/datum/action/A = Z
			A.update_button_icon()
	playsound(loc, 'sound/voice/alien_queen_screech.ogg', 75, 0)
	visible_message("<span class='xenohighdanger'>\this [src] издает оглушительный гортанный рев!</span>")
	round_statistics.queen_screech++
	create_shriekwave() //Adds the visual effect. Wom wom wom
	stop_momentum(charge_dir) //Screech kills a charge

	for(var/mob/M in view())
		if(M && M.client)
			if(isXeno(M))
				shake_camera(M, 10, 1)
			else
				shake_camera(M, 30, 1) //50 deciseconds, SORRY 5 seconds was way too long. 3 seconds now

	for(var/mob/living/carbon/human/M in oview(7, src))
		if(istype(M.wear_ear, /obj/item/clothing/ears/earmuffs))
			continue
		var/dist = get_dist(src,M)
		if(dist <= 4)
			to_chat(M, "<span class='danger'>Оглушительный рев сотрясает землю под ногами!</span>")
			M.stunned += 8 //Seems the effect lasts between 3-8 seconds.
			M.KnockDown(4)
			if(!M.ear_deaf)
				M.ear_deaf += 8 //Deafens them temporarily
		else if(dist >= 5 && dist < 7)
			M.stunned += 3
			to_chat(M, "<span class='danger'>Рев сотрясает твое тело до основания, замораживая тебя на месте!</span>")

/mob/living/carbon/Xenomorph/Queen/proc/queen_gut(atom/A)

	if(!iscarbon(A))
		return

	var/mob/living/carbon/victim = A

	if(get_dist(src, victim) > 1)
		return

	if(!check_state())
		return

	if(last_special > world.time)
		return

	if(isSynth(victim))
		var/datum/limb/head/synthhead = victim.get_limb("head")
		if(synthhead.status & LIMB_DESTROYED)
			return

	if(locate(/obj/item/alien_embryo) in victim) //Maybe they ate it??
		var/mob/living/carbon/human/H = victim
		if(H.status_flags & XENO_HOST)
			if(victim.stat != DEAD) //Not dead yet.
				to_chat(src, "<span class='xenowarning'>Хост и ребенок еще живы!</span>")
				return
			else if(istype(H) && ( world.time <= H.timeofdeath + H.revive_grace_period )) //Dead, but the host can still hatch, possibly.
				to_chat(src, "<span class='xenowarning'>Ребенок еще может вылупитьсЯ! Еще нет!</span>")
				return

	if(isXeno(victim))
		var/mob/living/carbon/Xenomorph/xeno = victim
		if(hivenumber == xeno.hivenumber)
			to_chat(src, "<span class='warning'>Ты не можешь заставить себЯ причинить вред сестре такого масштаба.</span>")
			return

	var/turf/cur_loc = victim.loc
	if(!istype(cur_loc))
		return

	if(action_busy)
		return

	if(!check_plasma(200))
		return
	use_plasma(200)
	last_special = world.time + 50

	visible_message("<span class='xenowarning'>\this [src] начинает медленно подниматьсЯ \this [victim] в верх.</span>", \
	"<span class='xenowarning'>Ты начинаешь концентрировать свой гнев, медленно поднимаЯсь \this [victim] в верх.</span>")
	if(do_mob(src, victim, 80, BUSY_ICON_HOSTILE))
		if(!victim)
			return
		if(victim.loc != cur_loc)
			return
		visible_message("<span class='xenodanger'>\this [src] злобно разбивает на части \this [victim] врозь!</span>", \
		"<span class='xenodanger'>Ты вдруг даешь волю чистому гневу \this [victim], мгновенно выворачивает \his врозь!</span>")
		emote("roar")
		log_combat(victim, src, "gibbed")
		victim.gib() //Splut
		stop_pulling()

/mob/living/carbon/Xenomorph/Queen/proc/mount_ovipositor()
	if(ovipositor) return //sanity check
	ovipositor = TRUE

	for(var/datum/action/A in actions)
		cdel(A)

	var/list/immobile_abilities = list(\
		/datum/action/xeno_action/regurgitate,\
		/datum/action/xeno_action/remove_eggsac,\
		/datum/action/xeno_action/activable/screech,\
		/datum/action/xeno_action/emit_pheromones,\
		/datum/action/xeno_action/psychic_whisper,\
		/datum/action/xeno_action/watch_xeno,\
		/datum/action/xeno_action/toggle_queen_zoom,\
		/datum/action/xeno_action/set_xeno_lead,\
		/datum/action/xeno_action/queen_heal,\
		/datum/action/xeno_action/queen_give_plasma,\
		/datum/action/xeno_action/queen_order,\
		/datum/action/xeno_action/deevolve, \
		)

	for(var/path in immobile_abilities)
		var/datum/action/xeno_action/A = new path()
		A.give_action(src)

	anchored = TRUE
	resting = FALSE
	update_canmove()
	update_icons()

	if(hivenumber && hivenumber <= hive_datum.len)
		var/datum/hive_status/hive = hive_datum[hivenumber]

		for(var/mob/living/carbon/Xenomorph/L in hive.xeno_leader_list)
			L.handle_xeno_leader_pheromones(src)

	xeno_message("<span class='xenoannounce'>Королева вырастила Яйцеклад, эволюционный прогресс возобновилсЯ.</span>", 3, hivenumber)

/mob/living/carbon/Xenomorph/Queen/proc/dismount_ovipositor(instant_dismount)
	set waitfor = 0
	if(!instant_dismount)
		if(observed_xeno)
			set_queen_overwatch(observed_xeno, TRUE)
		flick("ovipositor_dismount", src)
		sleep(5)
	else
		flick("ovipositor_dismount_destroyed", src)
		sleep(5)

	if(ovipositor)
		ovipositor = FALSE
		update_icons()
		new /obj/ovipositor(loc)

		if(observed_xeno)
			set_queen_overwatch(observed_xeno, TRUE)
		zoom_out()

		for(var/datum/action/A in actions)
			cdel(A)

		var/list/mobile_abilities = list(
			/datum/action/xeno_action/xeno_resting,
			/datum/action/xeno_action/regurgitate,
			/datum/action/xeno_action/plant_weeds,
			/datum/action/xeno_action/choose_resin,
			/datum/action/xeno_action/activable/secrete_resin,
			/datum/action/xeno_action/grow_ovipositor,
			/datum/action/xeno_action/activable/screech,
			/datum/action/xeno_action/activable/corrosive_acid,
			/datum/action/xeno_action/emit_pheromones,
			/datum/action/xeno_action/activable/gut,
			/datum/action/xeno_action/psychic_whisper,
			/datum/action/xeno_action/shift_spits,
			/datum/action/xeno_action/activable/xeno_spit,
			/datum/action/xeno_action/ready_charge,
			)

		for(var/path in mobile_abilities)
			var/datum/action/xeno_action/A = new path()
			A.give_action(src)


		egg_amount = 0
		ovipositor_cooldown = world.time + 3000 //5 minutes
		anchored = FALSE
		update_canmove()

		if(hivenumber && hivenumber <= hive_datum.len)
			var/datum/hive_status/hive = hive_datum[hivenumber]

			for(var/mob/living/carbon/Xenomorph/L in hive.xeno_leader_list)
				L.handle_xeno_leader_pheromones(src)

		if(!instant_dismount)
			xeno_message("<span class='xenoannounce'>Королева потерЯла Яйцеклад, эволюциЯ остановилась.</span>", 3, hivenumber)

/mob/living/carbon/Xenomorph/Queen/update_canmove()
	. = ..()
	if(ovipositor)
		lying = FALSE
		density = TRUE
		canmove = FALSE
		return canmove

/mob/living/carbon/Xenomorph/Queen/reset_view(atom/A)
	if (client)
		if(ovipositor && observed_xeno && !stat)
			client.perspective = EYE_PERSPECTIVE
			client.eye = observed_xeno
		else
			if (istype(A, /atom/movable))
				client.perspective = EYE_PERSPECTIVE
				client.eye = A
			else
				if (isturf(loc))
					client.eye = client.mob
					client.perspective = MOB_PERSPECTIVE
				else
					client.perspective = EYE_PERSPECTIVE
					client.eye = loc

/mob/living/carbon/Xenomorph/Queen/update_icons()
	icon = initial(icon)
	if(stat == DEAD)
		icon_state = "Queen Dead"
	else if(ovipositor)
		icon = 'icons/Xeno/Ovipositor.dmi'
		icon_state = "Queen Ovipositor"
	else if(lying)
		if((resting || sleeping) && (!knocked_down && !knocked_out && health > 0))
			icon_state = "Queen Sleeping"
		else
			icon_state = "Queen Knocked Down"
	else
		if(m_intent == MOVE_INTENT_RUN)
			if(charge_speed > charge_speed_buildup * charge_turfs_to_charge)
				icon_state = "Queen Charging"
			else
				icon_state = "Queen Running"

		else
			icon_state = "Queen Walking"

	update_fire() //the fire overlay depends on the xeno's stance, so we must update it.
	update_wounds() //the damage overlay

/mob/living/carbon/Xenomorph/Queen/Topic(href, href_list)

	if(href_list["queentrack"])
		if(!check_state())
			return
		var/mob/living/carbon/Xenomorph/target = locate(href_list["queentrack"]) in living_mob_list
		if(!istype(target))
			return
		if(target.stat == DEAD || target.z == ADMIN_Z_LEVEL)
			return
		if(target == observed_xeno)
			set_queen_overwatch(target, TRUE)
		else
			set_queen_overwatch(target)

	if (href_list["watch_xeno_number"])
		if(!check_state())
			return
		var/xeno_num = text2num(href_list["watch_xeno_number"])
		for(var/mob/living/carbon/Xenomorph/X in living_mob_list)
			if(X.z != ADMIN_Z_LEVEL && X.nicknumber == xeno_num)
				if(observed_xeno == X)
					set_queen_overwatch(X, TRUE)
				else
					set_queen_overwatch(X)
				break
		return
	..()

//proc to modify which xeno, if any, the queen is observing.
/mob/living/carbon/Xenomorph/Queen/proc/set_queen_overwatch(mob/living/carbon/Xenomorph/target, stop_overwatch)
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


/mob/living/carbon/Xenomorph/Queen/gib()
	death(1) //we need the body to show the queen's name at round end.