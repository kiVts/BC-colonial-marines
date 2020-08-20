/mob/living/carbon/Xenomorph/Predalien
	caste = "Predalien"
	name = "Abomination"
	desc = "Странное существо с мясистыми прядями на голове. Он выглядит как смесь брони и плоти, гладкий, но хорошо защищенный панцирем."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Predalien Walking"
	melee_damage_lower = 65
	melee_damage_upper = 80
	health = 800 //A lot of health, but it doesn't regenerate.
	maxHealth = 800
	plasma_stored = 300
	plasma_max = 300
	amount_grown = 0
	max_grown = 200
	plasma_gain = 25
	evolution_allowed = FALSE
	tacklemin = 6
	tacklemax = 10
	tackle_chance = 80

	wall_smash = TRUE
	is_intelligent = TRUE
	hardcore = TRUE

	charge_type = 4
	armor_deflection = 50
	tunnel_delay = 0

	pslash_delay = 0
	bite_chance = 25
	tail_chance = 25
	evo_points = 0

	pixel_x = -16
	old_x = -16

	mob_size = MOB_SIZE_BIG
	attack_delay = -2
	speed = -2.1
	tier = 1
	upgrade = -1 //Predaliens are already in their ultimate form, they don't get even better

	var/butchered_last //world.time to prevent spam.
	var/butchered_sum = 0 //The number of people butchered. Lowers the health gained.
	var/mob/living/carbon/Xenomorph/observed_xeno //the Xenomorph is currently overwatching

	#define PREDALIEN_BUTCHER_COOLDOWN 140 //14 seconds.
	#define PREDALIEN_BUTCHER_WAIT_TIME 120 //12 seconds.
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/watch_xeno,
//		/datum/action/xeno_action/deevolve,
		/datum/action/xeno_action/activable/pounce,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/Predalien/proc/claim_trophy
		)

	New()
		..()
		announce_spawn()

/mob/living/carbon/Xenomorph/Predalien/proc/announce_spawn()
	set waitfor = 0
	sleep(30)
	if(!loc) return FALSE
	if(ticker && ticker.mode && ticker.mode.predators.len)
		var/datum/mind/M
		for(var/i in ticker.mode.predators)
			M = i
			if(M.current && M.current.stat != DEAD)
				M.current << "<span class='event_announcement'>Мерзость для вашего народа была принесена в этот мир в [get_area(src)]! Выследить и уничтожить его!</span>"
				M.current.emote("roar")

	src << {"
<span class='role_body'>|______________________|</span>
<span class='role_header'>Вы-гибрид хищника и пришельца!
</span>
<span class='role_body'>Вы очень мощное ксеноморфное существо, которое родилось из тела воина Яуты.

Ты сильнее, быстрее и умнее обычного ксеноморфа, но ты все равно должна слушать королеву.
У вас есть степень свободы, где вы можете охотиться и требовать головы врагов улья, поэтому проверьте свои глаголы.

Ваш счетчик здоровья не будет нормально регенерировать, поэтому убейте и умрите за улей!</span>
<span class='role_body'>|______________________|</span>
"}

	emote("roar")


/mob/living/carbon/Xenomorph/Predalien/proc/claim_trophy()
	set category = "Alien"
	set name = "Claim Trophy"
	set desc = "Мясник труп, чтобы получить трофей от вашего убийства."

	if(is_mob_incapacitated()|| lying || buckled)
		src << "<span class='xenowarning'>Ты не можешь сделать это прямо сейчас.</span>"
		return FALSE

	var/choices[] = new
	for(var/mob/M in view(1, src)) //We are only interested in humans and predators.
		if(Adjacent(M) && ishuman(M) && M.stat) choices += M

	var/mob/living/carbon/human/H = input(src, "От какого трупа ты потребуешь свой трофей?") as null|anything in choices

	if(!H || !H.loc) return FALSE

	if(is_mob_incapacitated() || lying || buckled)
		src << "<span class='xenowarning'>Ты не можешь сделать это прямо сейчас.<span>"
		return FALSE

	if(!H.stat)
		src << "<span class='xenowarning'>Твоя добыча должна быть мертва.</span>"
		return FALSE

	if(!Adjacent(H))
		src << "<span class='xenowarning'>Ты должен быть рядом со своей целью.</span>"
		return FALSE

	if(world.time <= butchered_last + PREDALIEN_BUTCHER_COOLDOWN)
		src << "<span class='xenowarning'>Вы недавно пытались разделать тушу. Нужно ждать.</span>"
		return FALSE

	butchered_last = world.time

	visible_message("<span class='danger'>[src] тянется вниз, наклоняя свое тело к [H], когти вытянуты.</span>",
	"<span class='xenonotice'>Ты наклоняешься к телу носителя, наслаждаясь моментом перед тем, как потребовать трофей за свою добычу. Вы должны стоять спокойно...</span>")
	if(do_after(src, PREDALIEN_BUTCHER_WAIT_TIME, FALSE, 5, BUSY_ICON_HOSTILE) && Adjacent(H))
		var/datum/limb/head/O = H.get_limb("head")
		if(!(O.status & LIMB_DESTROYED))
			H.apply_damage(150, BRUTE, "head", FALSE, TRUE, TRUE)
			if(!(O.status & LIMB_DESTROYED)) O.droplimb() //Still not actually detached?
			visible_message("<span class='danger'>[src] протягивает руку и срывает [H]'s спинной мозг и череп!</span>",
			"<span class='xenodanger'>Ты режешь и тянешь [H]'s голова, пока не оторвется по кровавой дуге!</span>")
			playsound(loc, 'sound/weapons/slice.ogg', 25)
			emote("growl")
			var/to_heal = max(1, 5 - (0.2 * (health < maxHealth ? butchered_sum++ : butchered_sum)))//So we do not heal multiple times due to the inline proc below.
			XENO_HEAL_WOUNDS(isYautja(H)? 15 : to_heal) //Predators give far better healing.
		else
			visible_message("<span class='danger'>[src] ломтики и кубики [H]'s тело как тряпичная кукла!</span>",
			"<span class='xenodanger'>Ты впадаешь в безумие и становишься мясником [H]'s тело!</span>")
			playsound(loc, 'sound/weapons/bladeslice.ogg', 25)
			emote("growl")
			var/i = 4
			while(i--)
				H.apply_damage(100, BRUTE, pick("r_leg","l_leg","r_arm","l_arm"), FALSE, TRUE, TRUE)


/mob/living/carbon/Xenomorph/Predalien/Topic(href, href_list)

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
/mob/living/carbon/Xenomorph/Predalien/proc/set_xeno_overwatch(mob/living/carbon/Xenomorph/target, stop_overwatch)
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


	#undef PREDALIEN_BUTCHER_COOLDOWN
	#undef PREDALIEN_BUTCHER_WAIT_TIME