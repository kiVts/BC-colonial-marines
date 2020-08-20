//
//Robotic Component Analyser, basically a health analyser for robots
//
/obj/item/device/robotanalyzer
	name = "cyborg analyzer"
	icon_state = "robotanalyzer"
	item_state = "analyzer"
	desc = "A hand-held scanner able to diagnose robotic injuries."
	flags_atom = CONDUCT
	flags_equip_slot = SLOT_WAIST
	throwforce = 3
	w_class = 2.0
	throw_speed = 5
	throw_range = 10
	matter = list("metal" = 200)
	origin_tech = "magnets=1;biotech=1"
	var/mode = 1;

/obj/item/device/robotanalyzer/attack(mob/living/M as mob, mob/living/user as mob)
	if(( (CLUMSY in user.mutations) || user.getBrainLoss() >= 60) && prob(50))
		to_chat(user, text("<span style='color:#FF0000'>You try to analyze the floor's vitals!</span>"))
		for(var/mob/O in viewers(M, null))
			O.show_message(text("<span style='color:#FF0000'>[user] has analyzed the floor's vitals!</span>"), 1)
		user.show_message(text("<span style='color:#0000FF'>Analyzing Results for The floor:\n\t Overall Status: Healthy</span>"), 1)
		user.show_message(text("<span style='color:#0000FF'>\t Damage Specifics: [0]-[0]-[0]-[0]</span>"), 1)
		user.show_message("<span style='color:#0000FF'>Key: Suffocation/Toxin/Burns/Brute</span>", 1)
		user.show_message("<span style='color:#0000FF'>Body Temperature: ???</span>", 1)
		return
	if(!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		to_chat(user, "<span style='color:#FF0000'>You don't have the dexterity to do this!</span>")
		return
	if(!istype(M, /mob/living/silicon/robot) && !(ishuman(M) && (M:species.flags & IS_SYNTHETIC)))
		to_chat(user, "<span style='color:#FF0000'>You can't analyze non-robotic things!</span>")
		return

	user.visible_message("<span class='notice'> [user] has analyzed [M]'s components.","<span class='notice'> You have analyzed [M]'s components.")
	var/BU = M.getFireLoss() > 50 	? 	"<b>[M.getFireLoss()]</b>" 		: M.getFireLoss()
	var/BR = M.getBruteLoss() > 50 	? 	"<b>[M.getBruteLoss()]</b>" 	: M.getBruteLoss()
	user.show_message("<span style='color:#0000FF'>Analyzing Results for [M]:\n\t Overall Status: [M.stat > 1 ? "fully disabled" : "[M.health - M.halloss]% functional"]</span>")
	user.show_message("\t Key: <font color='#FFA500'>Electronics</font>/<font color='red'>Brute</font>", 1)
	user.show_message("\t Damage Specifics: <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font>")
	if(M.tod && M.stat == DEAD)
		user.show_message("<span style='color:#0000FF'>Time of Disable: [M.tod]</span>")

	if (istype(M, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/H = M
		var/list/damaged = H.get_damaged_components(1,1,1)
		user.show_message("<span style='color:#0000FF'>Localized Damage:</span>",1)
		if(length(damaged)>0)
			for(var/datum/robot_component/org in damaged)
				user.show_message(text("<span style='color:#0000FF'>\t []: [][] - [] - [] - []</span>",	\
				capitalize(org.name),					\
				(org.installed == -1)	?	"<font color='red'><b>DESTROYED</b></font> "							:"",\
				(org.electronics_damage > 0)	?	"<font color='#FFA500'>[org.electronics_damage]</font>"	:0,	\
				(org.brute_damage > 0)	?	"<font color='red'>[org.brute_damage]</font>"							:0,		\
				(org.toggled)	?	"Toggled ON"	:	"<font color='red'>Toggled OFF</font>",\
				(org.powered)	?	"Power ON"		:	"<font color='red'>Power OFF</font>"),1)
		else
			user.show_message("<span style='color:#0000FF'>\t Components are OK.</span>",1)
		if(H.emagged && prob(5))
			user.show_message("<span style='color:#FF0000'>\t ERROR: INTERNAL SYSTEMS COMPROMISED</span>",1)

	if (ishuman(M) && (M:species.flags & IS_SYNTHETIC))
		var/mob/living/carbon/human/H = M
		var/list/damaged = H.get_damaged_limbs(1,1)
		user.show_message("<span style='color:#0000FF'>Localized Damage, Brute/Electronics:</span>",1)
		if(length(damaged)>0)
			for(var/datum/limb/org in damaged)
				user.show_message(text("<span style='color:#0000FF'>\t []: [] - []</span>",	\
				capitalize(org.display_name),					\
				(org.brute_dam > 0)	?	"<span style='color:#FF0000'>[org.brute_dam]</span>"							:0,		\
				(org.burn_dam > 0)	?	"<font color='#FFA500'>[org.burn_dam]</font>"	:0),1)
		else
			user.show_message("<span style='color:#0000FF'>\t Components are OK.</span>",1)

	user.show_message("<span style='color:#0000FF'>Operating Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)</span>", 1)

	src.add_fingerprint(user)
	return
