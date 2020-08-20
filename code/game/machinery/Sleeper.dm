/////////////////////////////////////////
// SLEEPER CONSOLE
/////////////////////////////////////////

/obj/machinery/sleep_console
	name = "Sleeper Console"
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "sleeperconsole"
	var/obj/machinery/sleeper/connected = null
	anchored = 1 //About time someone fixed this.
	density = 0
	var/orient = "LEFT" // "RIGHT" changes the dir suffix to "-r"

	use_power = 1
	idle_power_usage = 40

/obj/machinery/sleep_console/process()
	if(stat & (NOPOWER|BROKEN))
		return
	updateUsrDialog()
	return

/obj/machinery/sleep_console/ex_act(severity)
	switch(severity)
		if(1.0)
			//SN src = null
			cdel(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				cdel(src)
				return
		else
	return

/obj/machinery/sleep_console/New()
	..()
	spawn( 5 )
		if(orient == "RIGHT")
			icon_state = "sleeperconsole-r"
			connected = locate(/obj/machinery/sleeper, get_step(src, EAST))
			connected.connected = src
		else
			connected = locate(/obj/machinery/sleeper, get_step(src, WEST))
			connected.connected = src
		return
	return

/obj/machinery/sleep_console/attack_ai(mob/living/user)
	return attack_hand(user)

/obj/machinery/sleep_console/attack_paw(mob/living/user)
	return attack_hand(user)

/obj/machinery/sleep_console/attack_hand(mob/living/user)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	var/dat = ""
	if (!connected || (connected.stat & (NOPOWER|BROKEN)))
		dat += "This console is not connected to a sleeper or the sleeper is non-functional."
	else
		var/mob/living/occupant = connected.occupant
		dat += "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>"
		if (occupant)
			var/t1
			switch(occupant.stat)
				if(0)
					t1 = "Conscious"
				if(1)
					t1 = "<font color='blue'>Unconscious</font>"
				if(2)
					t1 = "<font color='red'>*dead*</font>"
				else
			dat += text("[]\tHealth %: [] ([])</FONT><BR>", (occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), occupant.health, t1)
			if(iscarbon(occupant))
				var/mob/living/carbon/C = occupant
				dat += text("[]\t-Pulse, bpm: []</FONT><BR>", (C.pulse == PULSE_NONE || C.pulse == PULSE_THREADY ? "<font color='red'>" : "<font color='blue'>"), C.get_pulse(GETPULSE_TOOL))
			dat += text("[]\t-Brute Damage %: []</FONT><BR>", (occupant.getBruteLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getBruteLoss())
			dat += text("[]\t-Respiratory Damage %: []</FONT><BR>", (occupant.getOxyLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getOxyLoss())
			dat += text("[]\t-Toxin Content %: []</FONT><BR>", (occupant.getToxLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getToxLoss())
			dat += text("[]\t-Burn Severity %: []</FONT><BR>", (occupant.getFireLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getFireLoss())
			dat += text("<HR>Knocked Out Summary %: [] ([] seconds left!)<BR>", occupant.knocked_out, round(occupant.knocked_out / 4))
			if(occupant.reagents)
				for(var/chemical in connected.available_chemicals)
					dat += "[connected.available_chemicals[chemical]]: [occupant.reagents.get_reagent_amount(chemical)] units<br>"
			dat += "<A href='?src=\ref[src];refresh=1'>Refresh Meter Readings</A><BR>"
			if(connected.beaker)
				dat += "<HR><A href='?src=\ref[src];removebeaker=1'>Remove Beaker</A><BR>"
				if(ishuman(occupant))
					if(connected.filtering)
						dat += "<A href='?src=\ref[src];togglefilter=1'>Stop Dialysis</A><BR>"
						dat += "Output Beaker has [connected.beaker.reagents.maximum_volume - connected.beaker.reagents.total_volume] units of free space remaining<BR><HR>"
					else
						dat += "<HR><A href='?src=\ref[src];togglefilter=1'>Start Dialysis</A><BR>"
						dat += "Output Beaker has [connected.beaker.reagents.maximum_volume - connected.beaker.reagents.total_volume] units of free space remaining<BR><HR>"
				else
					dat += "<HR>Dialysis Disabled - Non-human present.<BR><HR>"

			else
				dat += "<HR>No Dialysis Output Beaker is present.<BR><HR>"

			for(var/chemical in connected.available_chemicals)
				dat += "Inject [connected.available_chemicals[chemical]]: "
				for(var/amount in connected.amounts)
					dat += "<a href ='?src=\ref[src];chemical=[chemical];amount=[amount]'>[amount] units</a><br> "


			dat += "<HR><A href='?src=\ref[src];ejectify=1'>Eject Patient</A>"
		else
			dat += "The sleeper is empty."
	dat += text("<BR><BR><A href='?src=\ref[];mach_close=sleeper'>Close</A>", user)
	user << browse(dat, "window=sleeper;size=400x500")
	onclose(user, "sleeper")
	return

/obj/machinery/sleep_console/Topic(href, href_list)
	if(..())
		return FALSE
	var/mob/living/carbon/human/user = usr
	if(!user.contents.Find(src) || get_dist(src, user) > 1)
		return FALSE
	user.set_interaction(src)
	if(href_list["chemical"] && connected && connected.occupant)
		if (connected.occupant.stat == DEAD)
			to_chat(usr, "<span class='warning'>This person has no life for to preserve anymore.</span>")
		else if(!(href_list["chemical"] in connected.available_chemicals))
			message_admins("[usr.ckey] has tried to inject an invalid chem with the sleeper. Looks like an exploit attempt. Or a bug.", 1)
		else if(connected.occupant.health <= 0 && href_list["chemical"] != "inaprovaline")
			to_chat(usr, "<span class='warning'>This person is not in good enough condition for sleepers to be effective! Use another means of treatment, such as cryogenics!</span>")
		else
			var/amount = text2num(href_list["amount"])
			if(amount == 5 || amount == 10)
				connected.inject_chemical(user,href_list["chemical"],amount)
		updateUsrDialog()
	if (href_list["refresh"])
		updateUsrDialog()
	if (href_list["removebeaker"])
		connected.remove_beaker()
		updateUsrDialog()
	if (href_list["togglefilter"])
		connected.toggle_filter()
		updateUsrDialog()
	if (href_list["ejectify"])
		connected.eject()
		updateUsrDialog()
	add_fingerprint(usr)
	return









/////////////////////////////////////////
// THE SLEEPER ITSELF
/////////////////////////////////////////

/obj/machinery/sleeper
	name = "Sleeper"
	desc = "A fancy bed with built-in injectors, a dialysis machine, and a limited health scanner."
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "sleeper_0"
	density = 1
	anchored = 1
	var/orient = "LEFT" // "RIGHT" changes the dir suffix to "-r"
	var/mob/living/carbon/human/occupant = null
	var/available_chemicals = list("inaprovaline" = "Inaprovaline", "stoxin" = "Soporific", "paracetamol" = "Paracetamol", "anti_toxin" = "Dylovene", "dexalin" = "Dexalin", "tricordrazine" = "Tricordrazine")
	var/amounts = list(5, 10)
	var/obj/item/reagent_container/glass/beaker = null
	var/filtering = 0
	var/obj/machinery/sleep_console/connected

	use_power = 1
	idle_power_usage = 15
	active_power_usage = 200 //builtin health analyzer, dialysis machine, injectors.


/obj/machinery/sleeper/New()
	..()
	beaker = new /obj/item/reagent_container/glass/beaker/large()
	spawn( 5 )
		if(orient == "RIGHT")
			icon_state = "sleeper_0-r"
		return
	return


/obj/machinery/sleeper/allow_drop()
	return 0


/obj/machinery/sleeper/on_stored_atom_del(atom/movable/AM)
	if(AM == beaker)
		beaker = null

/obj/machinery/sleeper/process()
	if (stat & (NOPOWER|BROKEN))
		return

	if(filtering > 0)
		if(beaker)
			if(beaker.reagents.total_volume < beaker.reagents.maximum_volume)
				for(var/datum/reagent/x in occupant.reagents.reagent_list)
					occupant.reagents.trans_to(beaker, 3)


	updateUsrDialog()


/obj/machinery/sleeper/attackby(var/obj/item/W, var/mob/living/user)
	if(istype(W, /obj/item/reagent_container/glass))
		if(!beaker)
			if(user.drop_inv_item_to_loc(W, src))
				beaker = W
				user.visible_message("[user] adds \a [W] to \the [src]!", "You add \a [W] to \the [src]!")
				updateUsrDialog()
			return
		else
			to_chat(user, "<span class='warning'>The sleeper has a beaker already.</span>")
			return

	else if(istype(W, /obj/item/grab))
		if(isXeno(user))
			return
		var/obj/item/grab/G = W
		if(!ismob(G.grabbed_thing))
			return

		if(occupant)
			to_chat(user, "<span class='notice'>The sleeper is already occupied!</span>")
			return

		visible_message("[user] starts putting [G.grabbed_thing] into the sleeper.", 3)

		if(do_after(user, 20, TRUE, 5, BUSY_ICON_GENERIC))
			if(occupant)
				to_chat(user, "<span class='notice'>The sleeper is already occupied!</span>")
				return
			if(!G || !G.grabbed_thing)
				return
			var/mob/M = G.grabbed_thing
			M.forceMove(src)
			update_use_power(2)
			occupant = M
			start_processing()
			connected.start_processing()
			icon_state = "sleeper_1"
			if(orient == "RIGHT")
				icon_state = "sleeper_1-r"

			add_fingerprint(user)



/obj/machinery/sleeper/ex_act(severity)
	if(filtering)
		toggle_filter()
	switch(severity)
		if(1)
			cdel(src)
		if(2)
			if(prob(50))
				cdel(src)
		if(3)
			if(prob(25))
				cdel(src)


/obj/machinery/sleeper/emp_act(severity)
	if(filtering)
		toggle_filter()
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		go_out()
	..()

/obj/machinery/sleeper/proc/toggle_filter()
	if(!occupant)
		filtering = 0
		return
	if(filtering)
		filtering = 0
	else
		filtering = 1

/obj/machinery/sleeper/proc/go_out()
	if(filtering)
		toggle_filter()
	if(!occupant)
		return
	occupant.forceMove(loc)
	occupant = null
	stop_processing()
	connected.stop_processing()
	update_use_power(1)
	if(orient == "RIGHT")
		icon_state = "sleeper_0-r"
	return


/obj/machinery/sleeper/proc/inject_chemical(mob/living/user as mob, chemical, amount)
	if(occupant && occupant.reagents)
		if(occupant.reagents.get_reagent_amount(chemical) + amount <= 20)
			occupant.reagents.add_reagent(chemical, amount)
			to_chat(user, "<span class='notice'>Occupant now has [occupant.reagents.get_reagent_amount(chemical)] units of [available_chemicals[chemical]] in his/her bloodstream.</span>")
			return
	to_chat(user, "<span class='warning'>There's no occupant in the sleeper or the subject has too many chemicals!</span>")
	return


/obj/machinery/sleeper/proc/check(mob/living/user)
	if(occupant)
		to_chat(user, text("<span style='color:#0000FF'><B>Occupant ([]) Statistics:</B></span>", occupant))
		var/t1
		switch(occupant.stat)
			if(0)
				t1 = "Conscious"
			if(1)
				t1 = "Unconscious"
			if(2)
				t1 = "*dead*"
			else
		to_chat(user, text("[]\t Health %: [] ([])", (occupant.health > 50 ? "<span style='color:#0000FF'>" : "<span style='color:#FF0000'></span></span>"), occupant.health, t1))
		to_chat(user, text("[]\t -Core Temperature: []&deg;C ([]&deg;F)</FONT><BR>", (occupant.bodytemperature > 50 ? "<font color='blue'>" : "<font color='red'>"), occupant.bodytemperature-T0C, occupant.bodytemperature*1.8-459.67))
		to_chat(user, text("[]\t -Brute Damage %: []", (occupant.getBruteLoss() < 60 ? "<span style='color:#0000FF'>" : "<span style='color:#FF0000'></span></span>"), occupant.getBruteLoss()))
		to_chat(user, text("[]\t -Respiratory Damage %: []", (occupant.getOxyLoss() < 60 ? "<span style='color:#0000FF'>" : "<span style='color:#FF0000'></span></span>"), occupant.getOxyLoss()))
		to_chat(user, text("[]\t -Toxin Content %: []", (occupant.getToxLoss() < 60 ? "<span style='color:#0000FF'>" : "<span style='color:#FF0000'></span></span>"), occupant.getToxLoss()))
		to_chat(user, text("[]\t -Burn Severity %: []", (occupant.getFireLoss() < 60 ? "<span style='color:#0000FF'>" : "<span style='color:#FF0000'></span></span>"), occupant.getFireLoss()))
		to_chat(user, "<span style='color:#0000FF'>Expected time till occupant can safely awake: (note: If health is below 20% these times are inaccurate)</span>")
		to_chat(user, "<span style='color:#0000FF'>\t [occupant.knocked_out / 5] second\s (if around 1 or 2 the sleeper is keeping them asleep.)</span>")
		if(beaker)
			to_chat(user, "<span style='color:#0000FF'>\t Dialysis Output Beaker has [beaker.reagents.maximum_volume - beaker.reagents.total_volume] of free space remaining.</span>")
		else
			to_chat(user, "<span style='color:#0000FF'>No Dialysis Output Beaker loaded.</span>")
	else
		to_chat(user, "<span style='color:#0000FF'>There is no one inside!</span>")
	return


/obj/machinery/sleeper/verb/eject()
	set name = "Eject Sleeper"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0)
		return
	if(orient == "RIGHT")
		icon_state = "sleeper_0-r"
	icon_state = "sleeper_0"
	go_out()
	add_fingerprint(usr)


/obj/machinery/sleeper/verb/remove_beaker()
	set name = "Remove Beaker"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0)
		return
	if(beaker)
		filtering = 0
		beaker.loc = usr.loc
		beaker = null
	add_fingerprint(usr)


/obj/machinery/sleeper/verb/move_inside()
	set name = "Enter Sleeper"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || !ishuman(usr))
		return

	var/mob/living/carbon/human/user = usr

	if(occupant)
		to_chat(usr, "<span class='notice'>The sleeper is already occupied!</span>")
		return

	visible_message("[user] starts climbing into the sleeper.", 3)
	if(user.pulledby)
		if(ismob(user.pulledby))
			var/mob/grabmob = user.pulledby
			grabmob.stop_pulling()
	if(do_after(user, 20, FALSE, 5, BUSY_ICON_GENERIC))
		if(occupant)
			to_chat(usr, "<span class='notice'>The sleeper is already occupied!</span>")
			return
		user.stop_pulling()
		if(user.pulledby)
			if(ismob(user.pulledby))
				var/mob/grabmob = user.pulledby
				grabmob.stop_pulling()
		user.forceMove(src)
		update_use_power(2)
		occupant = usr
		start_processing()
		connected.start_processing()
		icon_state = "sleeper_1"
		if(orient == "RIGHT")
			icon_state = "sleeper_1-r"

		for(var/obj/O in src)
			cdel(O)
		add_fingerprint(usr)