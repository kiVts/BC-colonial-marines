//Xenomorph Evolution Code - Colonial Marines - Apophis775 - Last Edit: 11JUN16

//Recoded and consolidated by Abby -- ALL evolutions come from here now. It should work with any caste, anywhere
//All castes need an evolves_to() list in their defines
//Such as evolves_to = list("Warrior", "Sentinel", "Runner", "Badass") etc

/mob/living/carbon/Xenomorph/verb/Evolve()
	set name = "Evolve"
	set desc = "Evolve into a higher form."
	set category = "Alien"
	var totalXenos = 0 //total number of Xenos
	// var tierA = 0.0 //Tier 1 - Not used in calculation of Tier maximums
	var/tierB = 0 //Tier 2
	var/tierC = 0 //Tier 3
	var/potential_queens = 0

	if(is_ventcrawling)
		to_chat(src, "<span class='warning'>��� ����� ������� ����������, ����� �����������.</span>")
		return

	if(!isturf(loc))
		to_chat(src, "<span class='warning'>����� ������ �����������.</span>")
		return

	if(hardcore)
		to_chat(src, "<span class='warning'>���.</span>")
		return

	if(jobban_isbanned(src, "Alien"))
		to_chat(src, "<span class='warning'>�� ���������� �� ����������� � �� ������ �����������. ��� �� ������ ���� ���������������?</span>")
		return

	if(is_mob_incapacitated(TRUE))
		to_chat(src, "<span class='warning'>�� �� ������ ����������� � ����� �������� ���������.</span>")
		return

	if(handcuffed || legcuffed)
		to_chat(src, "<span class='warning'>����������� ������� ������, ����� ��������� ��� �����������.</span>")
		return

	if(isXenoLarva(src)) //Special case for dealing with larvae
		if(amount_grown < max_grown)
			to_chat(src, "<span class='warning'>�� ��� �� ������ ��������. � ��������� ����� ��: [amount_grown] / [max_grown].</span>")
			return

	if(isnull(evolves_to))
		to_chat(src, "<span class='warning'>�� ��� ������� ����� � �������. ��� � �������� ����!</span>")
		return

	if(health < maxHealth)
		to_chat(src, "<span class='warning'>�� ������ ���� � ������ �������, ����� �����������.</span>")
		return

	if(plasma_stored < plasma_max)
		to_chat(src, "<span class='warning'>�� ������ ���� � ������ �������, ����� �����������.</span>")
		return

	if (agility || fortify || crest_defense)
		to_chat(src, "<span class='warning'>�� �� ������ �����������, � ���� �������.</span>")
		return

	//Debugging that should've been done
	// to_chat(world, "[tierA] Tier 1")
	// to_chat(world, "[tierB] Tier 2")
	// to_chat(world, "[tierC] Tier 3")
	// to_chat(world, "[totalXenos] Total")

	var/castepick = input("You are growing into a beautiful alien! It is time to choose a caste.") as null|anything in evolves_to
	if(!castepick) //Changed my mind
		return

	if(!isturf(loc)) //cdel'd or inside something
		return

	if(is_mob_incapacitated(TRUE))
		to_chat(src, "<span class='warning'>�� �� ������ ����������� � ����� �������� ���������.</span>")
		return

	var/datum/hive_status/hive
	if(hivenumber && hivenumber <= hive_datum.len)
		hive = hive_datum[hivenumber]
	else
		hivenumber = XENO_HIVE_NORMAL
		hive = hive_datum[hivenumber]

	if((!hive.living_xeno_queen) && castepick != "Queen" && !isXenoLarva(src))
		to_chat(src, "<span class='warning'>���� �������� ������� ��������� ��������. �� �� ������ ����� � ���� ���� �����������.</span>")
		return

	if(handcuffed || legcuffed)
		to_chat(src, "<span class='warning'>����������� ������� �������, ����� ��������� ��� �����������.</span>")
		return

	if(castepick == "Queen") //Special case for dealing with queenae
		if(!hardcore)
			if(plasma_stored >= 500)
				if(hive.living_xeno_queen)
					to_chat(src, "<span class='warning'>��� ���� ����� ��������.</span>")
					return
			else
				to_chat(src, "<span class='warning'>��� ����� ������ ������! � ��������� �����: [plasma_stored] / 500.</span>")
				return

			if(hivenumber == 1 && ticker && ticker.mode && hive.xeno_queen_timer)
				to_chat(src, "<span class='warning'>�� ������ ����� ��� ���� , ����� ���������� �� ������ ���������� �������� ����� [round(hive.xeno_queen_timer / 60)] .<span>")
				return
		else
			to_chat(src, "<span class='warning'>��-�.</span>")
			return

	//This will build a list of ALL the current Xenos and their Tiers, then use that to calculate if they can evolve or not.
	//Should count mindless as well so people don't cheat
	for(var/mob/living/carbon/Xenomorph/M in living_mob_list)
		if(hivenumber == M.hivenumber)
			switch(M.tier)
				if(0)
					if(caste == "Bloody Larva")
						if(M.client && M.ckey)
							potential_queens++
					continue
				if(1)
					if(caste == "Drone")
						if(M.client && M.ckey)
							potential_queens++
				if(2)
					tierB++
				if(3)
					tierC++
				else
					to_chat(src, "<span class='warning'>�� �� ������ ����� ������. ���� �� ��� ��������, ������ repot ���! (Error XE01).</span>")

					continue
			if(M.client && M.ckey)
				totalXenos++

	if(tier == 1 && ((tierB + tierC) / max(totalXenos, 1))> 0.5 && castepick != "Queen")
		to_chat(src, "<span class='warning'>���� �� ����� ������������ ������� Tier 2, ����� ���� ������� ��� ������ ����������� ��� ���-�� �����.</span>")
		return
	else if(tier == 2 && (tierC / max(totalXenos, 1))> 0.25 && castepick != "Queen")
		to_chat(src, "<span class='warning'>���� �� ����� ������������ ������� 3, ����� ���� ������� ��� ������ ����������� ��� ���-�� �����.</span>")

		return
	else if(!hive.living_xeno_queen && potential_queens == 1 && isXenoLarva(src) && castepick != "Drone")
		to_chat(src, "<span class='xenonotice'>� ��������� ����� � ���� ��� ������, ��������� ����� ���������! ��������� ���� �������, ����� �� ���� ������!</span>")
		return
	else
		to_chat(src, "<span class='xenonotice'>������, ��� ���� ����� ���������� ���� �������� <span style='font-weight: bold'>[castepick]!</span></span>")

	var/mob/living/carbon/Xenomorph/M = null

	//Better to use a get_caste_by_text proc but ehhhhhhhh. Lazy.
	switch(castepick) //ADD NEW CASTES HERE!
		if("Larva" || "Bloody Larva") //Not actually possible, but put here for insanity's sake
			M = /mob/living/carbon/Xenomorph/Larva
		if("Runner")
			M = /mob/living/carbon/Xenomorph/Runner
		if("Drone")
			M = /mob/living/carbon/Xenomorph/Drone
		if("Carrier")
			M = /mob/living/carbon/Xenomorph/Carrier
		if("Burrower")
			M = /mob/living/carbon/Xenomorph/Burrower
		if("Hivelord")
			M = /mob/living/carbon/Xenomorph/Hivelord
		if("Praetorian")
			M = /mob/living/carbon/Xenomorph/Praetorian
		if("Ravager")
			M = /mob/living/carbon/Xenomorph/Ravager
		if("Sentinel")
			M = /mob/living/carbon/Xenomorph/Sentinel
		if("Spitter")
			M = /mob/living/carbon/Xenomorph/Spitter
		if("Lurker")
			M = /mob/living/carbon/Xenomorph/Lurker
		if ("Warrior")
			M = /mob/living/carbon/Xenomorph/Warrior
		if ("Defender")
			M = /mob/living/carbon/Xenomorph/Defender
		if("Queen")
			switch(hivenumber) // because it causes issues otherwise
				if(XENO_HIVE_NORMAL)
					M = /mob/living/carbon/Xenomorph/Queen
				if(XENO_HIVE_CORRUPTED)
					M = /mob/living/carbon/Xenomorph/Queen/Corrupted
				if(XENO_HIVE_ALPHA)
					M = /mob/living/carbon/Xenomorph/Queen/Alpha
				if(XENO_HIVE_BETA)
					M = /mob/living/carbon/Xenomorph/Queen/Beta
				if(XENO_HIVE_ZETA)
					M = /mob/living/carbon/Xenomorph/Queen/Zeta
		if("Crusher")
			M = /mob/living/carbon/Xenomorph/Crusher
		if("Boiler")
			M = /mob/living/carbon/Xenomorph/Boiler
		if("Predalien")
			M = /mob/living/carbon/Xenomorph/Predalien

	if(isnull(M))
		to_chat(usr, "<span class='warning'>[castepick] �� �������� �������������� ������! ���� �� ������ ��� ���������, ������� ������!</span>")
		return

	if(evolution_threshold && castepick != "Queen") //Does the caste have an evolution timer? Then check it
		if(evolution_stored < evolution_threshold)
			to_chat(src, "<span class='warning'>�� ������ ���������, ������ ��� ����������������. � ��������� ����� ��: [evolution_stored] / [evolution_threshold].</span>")
			return

	visible_message("<span class='xenonotice'>\The [src] �������� ���������� � ���������.</span>", \
	"<span class='xenonotice'>�� ��������� ���������� � ���������.</span>")
	xeno_jitter(25)
	if(do_after(src, 25, FALSE, 5, BUSY_ICON_HOSTILE))
		if(!isturf(loc)) //cdel'd or moved into something
			return
		if(castepick == "Queen") //Do another check after the tick.
			if(jobban_isbanned(src, "Queen"))
				to_chat(src, "<span class='warning'>�� �������� �� ���� ��������.</span>")
				return
			if(hive.living_xeno_queen)
				to_chat(src, "<span class='warning'>��� ���� ��������.</span>")
				return

		//From there, the new xeno exists, hopefully
		var/mob/living/carbon/Xenomorph/new_xeno = new M(get_turf(src))

		if(!istype(new_xeno))
			//Something went horribly wrong!
			to_chat(usr, "<span class='warning'>���-�� ����� ����� �� ���. ���� ����� ������-����! ���������� �������� ������!</span>")
			if(new_xeno)
				cdel(new_xeno)
			return

		if(mind)
			mind.transfer_to(new_xeno)
		else
			new_xeno.key = src.key
			if(new_xeno.client) new_xeno.client.change_view(world.view)

		//Pass on the unique nicknumber, then regenerate the new mob's name now that our player is inside
		new_xeno.nicknumber = nicknumber
		new_xeno.hivenumber = hivenumber
		generate_name()

		if(new_xeno.health - getBruteLoss(src) - getFireLoss(src) > 0) //Cmon, don't kill the new one! Shouldnt be possible though
			new_xeno.bruteloss = src.bruteloss //Transfers the damage over.
			new_xeno.fireloss = src.fireloss //Transfers the damage over.
			new_xeno.updatehealth()

		if(xeno_mobhud)
			var/datum/mob_hud/H = huds[MOB_HUD_XENO_STATUS]
			H.add_hud_to(new_xeno) //keep our mobhud choice
			new_xeno.xeno_mobhud = TRUE

		new_xeno.middle_mouse_toggle = middle_mouse_toggle //Keep our toggle state

		for(var/obj/item/W in contents) //Drop stuff
			drop_inv_item_on_ground(W)

		empty_gut()
		new_xeno.visible_message("<span class='xenodanger'>[new_xeno.caste] ���������� �� ������ \the [src].</span>", \
		"<span class='xenodanger'>�� ����������� � ������� ����� �� �������� ������ ������� ����. �� ����!</span>")

		round_statistics.total_xenos_created-- //so an evolved xeno doesn't count as two.

		if(queen_chosen_lead && castepick != "Queen") // xeno leader is removed by Dispose()
			new_xeno.queen_chosen_lead = TRUE
			hive.xeno_leader_list += new_xeno
			new_xeno.hud_set_queen_overwatch()
			if(hive.living_xeno_queen)
				new_xeno.handle_xeno_leader_pheromones(hive.living_xeno_queen)

		if(hive.living_xeno_queen && hive.living_xeno_queen.observed_xeno == src)
			hive.living_xeno_queen.set_queen_overwatch(new_xeno)
		cdel(src)
		new_xeno.xeno_jitter(25)
	else
		to_chat(src, "<span class='warning'>�� �������, �� ������ �� ����������. ����������� �� ����� �� ����� ��������.</span>")
