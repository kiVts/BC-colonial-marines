/obj/machinery/computer/overwatch
	name = "Overwatch Console"
	desc = "—овременное оборудование для отдачи приказов отряду."
	icon_state = "dummy"
	req_access = list(ACCESS_MARINE_BRIDGE)

	var/datum/squad/current_squad = null
	var/state = 0
	var/obj/machinery/camera/cam = null
	var/list/network = list("LEADER")
	var/x_offset_s = 0
	var/y_offset_s = 0
	var/x_input_bomb = 0
	var/y_input_bomb = 0
	var/living_marines_sorting = FALSE
	var/busy = 0 //The overwatch computer is busy launching an OB/SB, lock controls
	var/dead_hidden = FALSE //whether or not we show the dead marines in the squad.
	var/z_hidden = 0 //which z level is ignored when showing marines.
//	var/console_locked = 0


/obj/machinery/computer/overwatch/attackby(var/obj/I as obj, var/mob/user as mob)  //Can't break or disassemble.
	return

/obj/machinery/computer/overwatch/bullet_act(var/obj/item/projectile/Proj) //Can't shoot it
	return 0

/obj/machinery/computer/overwatch/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/computer/overwatch/attack_paw(var/mob/user as mob) //why monkey why
	return src.attack_hand(user)

/obj/machinery/computer/overwatch/attack_hand(mob/user)
	if(..())  //Checks for power outages
		return

	user.set_interaction(src)
	var/dat = "<head><title>Overwatch Console</title></head><body>"
	if(!allowed(user))
		to_chat(user, "<span style='color:#FF0000'>” тебя нет доступа.</span>")
		return
	else if(!operator)
		dat += "<BR><B>Operator:</b> <A href='?src=\ref[src];operation=change_operator'>----------</A><BR>"
	else
		dat += "<BR><B>Operator:</b> <A href='?src=\ref[src];operation=change_operator'>[operator.name]</A><BR>"
		dat += "   <A href='?src=\ref[src];operation=logout'>{Stop Overwatch}</A><BR>"
		dat += "----------------------<br>"

		switch(src.state)
			if(0)
				if(!current_squad) //No squad has been set yet. Pick one.
					dat += "Current Squad: <A href='?src=\ref[src];operation=pick_squad'>----------</A><BR>"
				else
					dat += "Current Squad: [current_squad.name] Squad</A>   "
					dat += "<A href='?src=\ref[src];operation=message'>\[Message Squad\]</a><br><br>"
					dat += "----------------------<BR><BR>"
					if(current_squad.squad_leader)
						dat += "<B>Squad Leader:</B> <A href='?src=\ref[src];operation=use_cam;cam_target=\ref[current_squad.squad_leader]'>[current_squad.squad_leader.name]</a> "
						dat += "<A href='?src=\ref[src];operation=sl_message'>\[MSG\]</a> "
						dat += "<A href='?src=\ref[src];operation=change_lead'>\[CHANGE SQUAD LEADER\]</a><BR><BR>"
					else
						dat += "<B>Squad Leader:</B> <font color=red>NONE</font> <A href='?src=\ref[src];operation=change_lead'>\[ASSIGN SQUAD LEADER\]</a><BR><BR>"

					dat += "<B>Primary Objective:</B> "
					if(current_squad.primary_objective)
						dat += "<A href='?src=\ref[src];operation=check_primary'>\[Check\]</A> <A href='?src=\ref[src];operation=set_primary'>\[Set\]</A><BR>"
					else
						dat += "<B><font color=red>NONE!</font></B> <A href='?src=\ref[src];operation=set_primary'>\[Set\]</A><BR>"
					dat += "<B>Secondary Objective:</B> "
					if(current_squad.secondary_objective)
						dat += "<A href='?src=\ref[src];operation=check_secondary'>\[Check\]</A> <A href='?src=\ref[src];operation=set_secondary'>\[Set\]</A><BR>"
					else
						dat += "<B><font color=red>NONE!</font></B> <A href='?src=\ref[src];operation=set_secondary'>\[Set\]</A><BR>"
					dat += "<BR>"
					dat += "<A href='?src=\ref[src];operation=insubordination'>Report a marine for insubordination</a><BR>"
					dat += "<A href='?src=\ref[src];operation=squad_transfer'>Transfer a marine to another squad</a><BR><BR>"

					dat += "<A href='?src=\ref[src];operation=supplies'>Supply Drop Control</a><BR>"
					dat += "<A href='?src=\ref[src];operation=bombs'>Orbital Bombardment Control</a><BR>"
					dat += "<A href='?src=\ref[src];operation=monitor'>Squad Monitor</a><BR>"
					dat += "<BR><BR>----------------------<BR></Body>"
					dat += "<BR><BR><A href='?src=\ref[src];operation=refresh'>{Refresh}</a></Body>"

			if(1)//Info screen.
				if(!current_squad)
					dat += "No Squad selected!<BR>"
				else

					var/leader_text = ""
					var/leader_count = 0
					var/spec_text = ""
					var/spec_count = 0
					var/medic_text = ""
					var/medic_count = 0
					var/engi_text = ""
					var/engi_count = 0
					var/smart_text = ""
					var/smart_count = 0
					var/marine_text = ""
					var/marine_count = 0
					var/misc_text = ""
					var/living_count = 0

					var/conscious_text = ""
					var/unconscious_text = ""
					var/dead_text = ""

					var/SL_z //z level of the Squad Leader
					if(current_squad.squad_leader)
						var/turf/SL_turf = get_turf(current_squad.squad_leader)
						SL_z = SL_turf.z


					for(var/X in current_squad.marines_list)
						if(!X) continue //just to be safe
						var/mob_name = "unknown"
						var/mob_state = ""
						var/role = "unknown"
						var/act_sl = ""
						var/fteam = ""
						var/dist = "<b>???</b>"
						var/area_name = "<b>???</b>"
						var/mob/living/carbon/human/H
						if(ishuman(X))
							H = X
							mob_name = H.real_name
							var/area/A = get_area(H)
							var/turf/M_turf = get_turf(H)
							if(A)
								area_name = sanitize(A.name)

							if(z_hidden && z_hidden == M_turf.z)
								continue

							if(H.mind && H.mind.assigned_role)
								role = H.mind.assigned_role
							else if(istype(H.wear_id, /obj/item/card/id)) //decapitated marine is mindless,
								var/obj/item/card/id/ID = H.wear_id		//we use their ID to get their role.
								if(ID.rank) role = ID.rank

							if(current_squad.squad_leader)
								if(H == current_squad.squad_leader)
									dist = "<b>N/A</b>"
									if(H.mind && H.mind.assigned_role != "Squad Leader")
										act_sl = " (acting SL)"
								else if(M_turf.z == SL_z)
									dist = "[get_dist(H, current_squad.squad_leader)] ([dir2text_short(get_dir(current_squad.squad_leader, H))])"

							switch(H.stat)
								if(CONSCIOUS)
									mob_state = "Conscious"
									living_count++
									conscious_text += "<tr><td><A href='?src=\ref[src];operation=use_cam;cam_target=\ref[H]'>[mob_name]</a></td><td>[role][act_sl]</td><td>[mob_state]</td><td>[area_name]</td><td>[dist]</td></tr>"

								if(UNCONSCIOUS)
									mob_state = "<b>Unconscious</b>"
									living_count++
									unconscious_text += "<tr><td><A href='?src=\ref[src];operation=use_cam;cam_target=\ref[H]'>[mob_name]</a></td><td>[role][act_sl]</td><td>[mob_state]</td><td>[area_name]</td><td>[dist]</td></tr>"

								if(DEAD)
									if(dead_hidden)
										continue
									mob_state = "<font color='red'>DEAD</font>"
									dead_text += "<tr><td><A href='?src=\ref[src];operation=use_cam;cam_target=\ref[H]'>[mob_name]</a></td><td>[role][act_sl]</td><td>[mob_state]</td><td>[area_name]</td><td>[dist]</td></tr>"


							if(!H.key || !H.client)
								if(H.stat != DEAD)
									mob_state += " (SSD)"


							if(istype(H.wear_id, /obj/item/card/id))
								var/obj/item/card/id/ID = H.wear_id
								if(ID.assigned_fireteam)
									fteam = " \[[ID.assigned_fireteam]\]"

						else //listed marine was deleted or gibbed, all we have is their name
							if(dead_hidden)
								continue
							if(z_hidden) //gibbed marines are neither on the colony nor on the almayer
								continue
							for(var/datum/data/record/t in data_core.general)
								if(t.fields["name"] == X)
									role = t.fields["real_rank"]
									break
							mob_state = "<font color='red'>DEAD</font>"
							mob_name = X
							dead_text += "<tr><td><A href='?src=\ref[src];operation=use_cam;cam_target=\ref[H]'>[mob_name]</a></td><td>[role][act_sl]</td><td>[mob_state]</td><td>[area_name]</td><td>[dist]</td></tr>"


						var/marine_infos = "<tr><td><A href='?src=\ref[src];operation=use_cam;cam_target=\ref[H]'>[mob_name]</a></td><td>[role][act_sl][fteam]</td><td>[mob_state]</td><td>[area_name]</td><td>[dist]</td></tr>"
						switch(role)
							if("Squad Leader")
								leader_text += marine_infos
								leader_count++
							if("Squad Specialist")
								spec_text += marine_infos
								spec_count++
							if("Squad Medic")
								medic_text += marine_infos
								medic_count++
							if("Squad Engineer")
								engi_text += marine_infos
								engi_count++
							if("Squad Smartgunner")
								smart_text += marine_infos
								smart_count++
							if("Squad Marine")
								marine_text += marine_infos
								marine_count++
							else
								misc_text += marine_infos

					dat += "<b>[leader_count ? "Squad Leader Deployed":"<font color='red'>No Squad Leader Deployed!</font>"]</b><BR>"
					dat += "<b>Squad Specialists: [spec_count] Deployed</b><BR>"
					dat += "<b>Squad Smartgunners: [smart_count] Deployed</b><BR>"
					dat += "<b>Squad Medics: [medic_count] Deployed | Squad Engineers: [engi_count] Deployed</b><BR>"
					dat += "<b>Squad Marines: [marine_count] Deployed</b><BR>"
					dat += "<b>Total: [current_squad.marines_list.len] Deployed</b><BR>"
					dat += "<b>Marines alive: [living_count]</b><BR><BR>"
					dat += "<table border='1' style='width:100%' align='center'><tr>"
					dat += "<th>Name</th><th>Role</th><th>State</th><th>Location</th><th>SL Distance</th></tr>"
					if(!living_marines_sorting)
						dat += leader_text + spec_text + medic_text + engi_text + smart_text + marine_text + misc_text
					else
						dat += conscious_text + unconscious_text + dead_text
					dat += "</table>"
				dat += "<BR><BR>----------------------<br>"
				dat += "<A href='?src=\ref[src];operation=refresh'>{Refresh}</a><br>"
				dat += "<A href='?src=\ref[src];operation=change_sort'>{Change Sorting Method}</a><br>"
				dat += "<A href='?src=\ref[src];operation=hide_dead'>{[dead_hidden ? "Show Dead Marines" : "Hide Dead Marines" ]}</a><br>"
				dat += "<A href='?src=\ref[src];operation=choose_z'>{Change Locations Ignored}</a><br>"
				dat += "<br><A href='?src=\ref[src];operation=back'>{Back}</a></body>"
			if(2)
				dat += "<BR><B>Supply Drop Control</B><BR><BR>"
				if(!current_squad)
					dat += "No squad selected!"
				else
					dat += "<B>Current Supply Drop Status:</B> "
					var/cooldown_left = (current_squad.supply_cooldown + 5000) - world.time
					if(cooldown_left > 0)
						dat += "Launch tubes resetting ([round(cooldown_left/10)] seconds)<br>"
					else
						dat += "<font color='green'>Ready!</font><br>"
					dat += "<B>Launch Pad Status:</b> "
					var/obj/structure/closet/crate/C = locate() in current_squad.drop_pad.loc
					if(C)
						dat += "<font color='green'>Supply crate loaded</font><BR>"
					else
						dat += "Empty<BR>"
					dat += "<B>Supply Beacon Status:</b> "
					if(current_squad.sbeacon)
						if(istype(current_squad.sbeacon.loc,/turf))
							dat += "<font color='green'>Transmitting!</font><BR>"
						else
							dat += "Not Transmitting<BR>"
					else
						dat += "Not Transmitting<BR>"
					dat += "<B>X-Coordinate Offset:</B> [x_offset_s] <A href='?src=\ref[src];operation=supply_x'>\[Change\]</a><BR>"
					dat += "<B>Y-Coordinate Offset:</B> [y_offset_s] <A href='?src=\ref[src];operation=supply_y'>\[Change\]</a><BR><BR>"
					dat += "<A href='?src=\ref[src];operation=dropsupply'>\[LAUNCH!\]</a>"
				dat += "<BR><BR>----------------------<br>"
				dat += "<A href='?src=\ref[src];operation=refresh'>{Refresh}</a><br>"
				dat += "<A href='?src=\ref[src];operation=back'>{Back}</a></body>"
			if(3)
				dat += "<BR><B>Orbital Bombardment Control</B><BR><BR>"
				dat += "<B>Current Cannon Status:</B> "
				var/cooldown_left = (almayer_orbital_cannon.last_orbital_firing + 5000) - world.time
				if(cooldown_left > 0)
					dat += "Cannon on cooldown ([round(cooldown_left/10)] seconds)<br>"
				else if(!almayer_orbital_cannon.chambered_tray)
					dat += "<font color='red'>No ammo chambered in the cannon.</font><br>"
				else
					dat += "<font color='green'>Ready!</font><br>"
				dat += "<B>Longitude:</B> [x_input_bomb] <A href='?src=\ref[src];operation=bomb_x'>\[Change\]</a><BR>"
				dat += "<B>Latitude:</B> [y_input_bomb] <A href='?src=\ref[src];operation=bomb_y'>\[Change\]</a><BR><BR>"
				dat += "<A href='?src=\ref[src];operation=dropbomb'>\[FIRE!\]</a>"
				dat += "<BR><BR>----------------------<br>"
				dat += "<A href='?src=\ref[src];operation=refresh'>{Refresh}</a><br>"
				dat += "<A href='?src=\ref[src];operation=back'>{Back}</a></body>"

	user << browse((dat), "window=overwatch;size=550x550")
	onclose(user, "overwatch")
	return

/obj/machinery/computer/overwatch/Topic(href, href_list)
	if(..())
		return

	if(!href_list["operation"])
		return

	if((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_interaction(src)

	switch(href_list["operation"])
		// main interface
		if("back")
			state = 0
		if("monitor")
			state = 1
		if("supplies")
			state = 2
		if("bombs")
			state = 3
		if("change_operator")
			if(operator != usr)
				if(current_squad)
					current_squad.overwatch_officer = usr
				operator = usr
				var/mob/living/carbon/human/H = operator
				var/obj/item/card/id/ID = H.get_idcard()
				visible_message("\icon[src] <span class='boldnotice'>ќсновные системы наблюдения инициализирован. ƒобро пожаловать, [ID ? "[ID.rank] ":""][operator.name]. ѕожалуйста, выберите отряд.</span>")
				send_to_squad("¬нимание. ¬аш офицер патруля сейчас [ID ? "[ID.rank] ":""][operator.name].") //This checks for squad, so we don't need to.
		if("logout")
			if(current_squad)
				current_squad.overwatch_officer = null //Reset the squad's officer.
			var/mob/living/carbon/human/H = operator
			var/obj/item/card/id/ID = H.get_idcard()
			send_to_squad("¬нимание. [ID ? "[ID.rank] ":""][operator ? "[operator.name]":"sysadmin"] это больше не ваш сотрудник патруля. ‘ункции Ќаблюдения отключены.")
			visible_message("\icon[src] <span class='boldnotice'>—истемы наблюдения деактивированы. ѕрощайте, [ID ? "[ID.rank] ":""][operator ? "[operator.name]":"sysadmin"].</span>")
			operator = null
			current_squad = null
			if(cam)
				usr.reset_view(null)
			cam = null
			state = 0
		if("pick_squad")
			if(operator == usr)
				if(current_squad)
					to_chat(usr, "<span class='warning'>\icon[src] ¬ы уже выбираете команду.</span>")
				else
					var/list/squad_list = list()
					for(var/datum/squad/S in RoleAuthority.squads)
						if(S.usable && !S.overwatch_officer)
							squad_list += S.name

					var/name_sel = input(" акой отряд вы хотели бы получить для Ќаблюдения?") as null|anything in squad_list
					if(!name_sel) return
					if(operator != usr)
						return
					if(current_squad)
						to_chat(usr, "<span class='warning'>\icon[src] ¬ы уже выбираете команду.</span>")
						return
					var/datum/squad/selected = get_squad_by_name(name_sel)
					if(selected)
						selected.overwatch_officer = usr //Link everything together, squad, console, and officer
						current_squad = selected
						send_to_squad("¬нимание-ваш отряд был выбран для Ќаблюдения. ѕроверьте панель состояния для целей.")
						send_to_squad("¬аш офицер патрул€: [operator.name].")
						visible_message("\icon[src] <span class='boldnotice'>“актические данные для команды '[current_squad]' загружены. ¬се тактические функции инициализированы.</span>")
						attack_hand(usr)
						if(!current_squad.drop_pad) //Why the hell did this not link?
							for(var/obj/structure/supply_drop/S in item_list)
								S.force_link() //LINK THEM ALL!

					else
						to_chat(usr, "\icon[src] <span class='warning'>Ќеверный ввод. ѕрерывание.</span>")
		if("message")
			if(current_squad && operator == usr)
				var/input = stripped_input(usr, "ѕожалуйста, напишите сообщение, чтобы объявить составу:", "Squad Message")
				if(input)
					send_to_squad(input, 1) //message, adds username
					visible_message("\icon[src] <span class='boldnotice'>—ообщение, отправленное всем морским пехотинцам из отряда '[current_squad]'.</span>")
		if("sl_message")
			if(current_squad && operator == usr)
				var/input = stripped_input(usr, "ѕожалуйста, напишите сообщение, чтобы объявить командиру отряда:", "SL Message")
				if(input)
					send_to_squad(input, 1, 1) //message, adds usrname, only to leader
					visible_message("\icon[src] <span class='boldnotice'>—ообщение отправлено командиру отряда [current_squad.squad_leader] из отряда '[current_squad]'.</span>")
		if("check_primary")
			if(current_squad) //This is already checked, but ehh.
				if(current_squad.primary_objective)
					visible_message("\icon[src] <span class='boldnotice'>Ќапоминания о основных целях команды '[current_squad]'.</span>")
					to_chat(usr, "\icon[src] <b>Primary Objective:</b> [current_squad.primary_objective]")
		if("check_secondary")
			if(current_squad) //This is already checked, but ehh.
				if(current_squad.secondary_objective)
					visible_message("\icon[src] <span class='boldnotice'>Ќапоминание о второстепенных целях команды '[current_squad]'.</span>")
					to_chat(usr, "\icon[src] <b>Secondary Objective:</b> [current_squad.secondary_objective]")
		if("set_primary")
			var/input = stripped_input(usr, " акова будет основная цель отряда?", "Primary Objective")
			if(input)
				current_squad.primary_objective = fix_rus_stats(input) + " ([worldtime2text()])"
				send_to_squad("¬аша основная цель изменилась. ѕанель статуса.")
				visible_message("\icon[src] <span class='boldnotice'>ќсновная цель отряда '[current_squad]'.</span>")
		if("set_secondary")
			var/input = stripped_input(usr, " акова будет вторая цель отряда?", "Secondary Objective")
			if(input)
				current_squad.secondary_objective = fix_rus_stats(input) + " ([worldtime2text()])"
				send_to_squad("¬аша вторичная цель изменилась. ѕроверте панель статуса.")
				visible_message("\icon[src] <span class='boldnotice'>¬торичная цель отряда '[current_squad]'.</span>")
		if("supply_x")
			var/input = input(usr," акое смещение X-координаты между -5 и 5 ¬ы хотели бы? (Positive means east)","X Offset",0) as num
			if(input > 5) input = 5
			if(input < -5) input = -5
			to_chat(usr, "\icon[src] <span class='notice'>X-смещение сейчас [input].</span>")
			src.x_offset_s = input
		if("supply_y")
			var/input = input(usr," акое y-координатное смещение между -5 и 5 вы бы хотели? (ѕоложительный означает север)","Y Offset",0) as num
			if(input > 5) input = 5
			if(input < -5) input = -5
			to_chat(usr, "\icon[src] <span class='notice'>Y-смещение сейчас [input].</span>")
			y_offset_s = input
		if("bomb_x")
			var/input = input(usr," акую долготу вы хотите?","Longitude",0) as num
			if(input >= world.maxx) input = world.maxx
			if(input <= 0) input = 0
			to_chat(usr, "\icon[src] <span class='notice'>ƒолгота сейчас [input].</span>")
			x_input_bomb = input
		if("bomb_y")
			var/input = input(usr," акую широту вы хотите?","Latitude",0) as num
			if(input >= world.maxy) input = world.maxy
			if(input <= 0) input = 0
			to_chat(usr, "\icon[src] <span class='notice'>Ўирота теперь [input].</span>")
			y_input_bomb = input
		if("refresh")
			src.attack_hand(usr)
		if("change_sort")
			living_marines_sorting = !living_marines_sorting
			if(living_marines_sorting)
				to_chat(usr, "\icon[src] <span class='notice'>ћорские пехотинцы теперь сортируются по состо€нию здоровья.</span>")
			else
				to_chat(usr, "\icon[src] <span class='notice'>ћорские пехотинцы теперь сортируются по рангам.</span>")
		if("hide_dead")
			dead_hidden = !dead_hidden
			if(dead_hidden)
				to_chat(usr, "\icon[src] <span class='notice'>ѕогибших морских пехотинцев сейчас не показывают.</span>")
			else
				to_chat(usr, "\icon[src] <span class='notice'>ћертвые морские пехотинцы теперь показаны снова.</span>")
		if("choose_z")
			switch(z_hidden)
				if(0)
					z_hidden = MAIN_SHIP_Z_LEVEL
					to_chat(usr, "\icon[src] <span class='notice'>ћорские пехотинцы на Almayer скрыты.</span>")
				if(MAIN_SHIP_Z_LEVEL)
					z_hidden = 1
					to_chat(usr, "\icon[src] <span class='notice'>ћорские пехотинцы на «емле теперь скрыты.</span>")
				else
					z_hidden = 0
					to_chat(usr, "\icon[src] <span class='notice'>ћестоположение больше не игнорируется.</span>")

		if("change_lead")
			change_lead()
		if("insubordination")
			mark_insubordination()
		if("squad_transfer")
			transfer_squad()
		if("dropsupply")
			if(current_squad)
				if((current_squad.supply_cooldown + 5000) > world.time)
					to_chat(usr, "\icon[src] <span class='warning'>ƒроп поставки еще не доступно!</span>")
				else
					handle_supplydrop()
		if("dropbomb")
			if((almayer_orbital_cannon.last_orbital_firing + 5000) > world.time)
				to_chat(usr, "\icon[src] <span class='warning'>ќрбитальная бомбардировка пока недоступна!</span>")
			else
				handle_bombard()
		if("back")
			state = 0
		if("use_cam")
			if(current_squad)
				var/mob/cam_target = locate(href_list["cam_target"])
				var/obj/machinery/camera/new_cam = get_camera_from_target(cam_target)
				if(!new_cam || !new_cam.can_use())
					to_chat(usr, "\icon[src] <span class='warning'>Searching for helmet cam. No helmet cam found for this marine! Tell your squad to put their helmets on!</span>")
				else if(cam && cam == new_cam)//click the camera you're watching a second time to stop watching.
					visible_message("\icon[src] <span class='boldnotice'>Stopping helmet cam view of [cam_target].</span>")
					cam = null
					usr.reset_view(null)
				else if(usr.client.view != world.view)
					to_chat(usr, "<span class='warning'>You're too busy peering through binoculars.</span>")
				else
					visible_message("\icon[src] <span class='boldnotice'>Searching for helmet cam of [cam_target]. Helmet cam found and linked.</span>")
					cam = new_cam
					usr.reset_view(cam)
	attack_hand(usr) //The above doesn't ever seem to work.

/obj/machinery/computer/overwatch/check_eye(mob/user)
	if(user.is_mob_incapacitated(TRUE) || get_dist(user, src) > 1 || user.blinded) //user can't see - not sure why canmove is here.
		user.unset_interaction()
	else if(!cam || !cam.can_use()) //camera doesn't work, is no longer selected or is gone
		user.unset_interaction()


/obj/machinery/computer/overwatch/on_unset_interaction(mob/user)
	..()
	cam = null
	user.reset_view(null)

//returns the helmet camera the human is wearing
/obj/machinery/computer/overwatch/proc/get_camera_from_target(mob/living/carbon/human/H)
	if (current_squad)
		if (H && istype(H) && istype(H.head, /obj/item/clothing/head/helmet/marine))
			var/obj/item/clothing/head/helmet/marine/helm = H.head
			return helm.camera

//Sends a string to our currently selected squad.
/obj/machinery/computer/overwatch/proc/send_to_squad(var/txt = "", var/plus_name = 0, var/only_leader = 0)
	if(txt == "" || !current_squad || !operator) return //Logic

	var/text = copytext(sanitize(txt), 1, MAX_MESSAGE_LEN)
	var/nametext = ""
	if(plus_name)
		nametext = "[usr.name] transmits: "
		text = "<font size='3'><b>[text]<b></font>"

	for(var/mob/living/carbon/human/M in current_squad.marines_list)
		if(!M.stat && M.client) //Only living and connected people in our squad
			if(!only_leader)
				if(plus_name)
					M << sound('sound/effects/radiostatic.ogg')
				to_chat(M, "\icon[src] <font color='blue'><B>\[Overwatch\]:</b> [nametext][text]</font>")
			else
				if(current_squad.squad_leader == M)
					if(plus_name)
						M << sound('sound/effects/radiostatic.ogg')
					to_chat(M, "\icon[src] <font color='blue'><B>\[SL Overwatch\]:</b> [nametext][text]</font>")
					return

/obj/machinery/computer/overwatch/proc/handle_bombard()
	if(!usr) return

	if(busy)
		to_chat(usr, "\icon[src] <span class='warning'>The [name] is busy processing another action!</span>")
		return

	if(!almayer_orbital_cannon.chambered_tray)
		to_chat(usr, "\icon[src] <span class='warning'>The orbital cannon has no ammo chambered.</span>")
		return

	var/x_bomb = x_input_bomb
	var/y_bomb = y_input_bomb
	x_bomb = round(x_bomb)
	y_bomb = round(y_bomb)
	if(x_bomb <= 0) x_bomb = 0 //None of these should be possible, but whatever
	if(x_bomb >= world.maxy) x_bomb = world.maxx
	if(y_bomb <= 0) y_bomb = 0
	if(y_bomb >= world.maxy) y_bomb = world.maxy

	var/turf/T = locate(x_bomb,y_bomb,1)

	var/area/A = get_area(T)
	if(istype(A) && A.ceiling >= CEILING_DEEP_UNDERGROUND)
		to_chat(usr, "\icon[src] <span class='warning'>The [current_squad.bbeacon.name]'s signal is too weak. It is probably underground.</span>")
		return

	if(istype(T, /turf/open/space))
		to_chat(usr, "\icon[src] <span class='warning'>The [current_squad.bbeacon.name]'s landing zone appears to be out of bounds.</span>")
		return

	//All set, let's do this.
	busy = 1
	visible_message("\icon[src] <span class='boldnotice'>Orbital bombardment request accepted. Orbital cannons are now calibrating.</span>")
	playsound(src,'sound/effects/alert.ogg', 25, 1)  //Placeholder
	sleep(20)
	visible_message("Analyzing surface.")
	sleep(20)
	visible_message("Calibrating trajectory window.")
	sleep(20)
	for(var/mob/living/carbon/H in living_mob_list)
		if(H.z == MAIN_SHIP_Z_LEVEL && !H.stat) //USS Almayer decks.
			to_chat(H, "<span class='warning'>The deck of the USS Almayer shudders as the orbital cannons open fire on the colony.</span>")
			if(H.client)
				shake_camera(H, 10, 1)
	visible_message("\icon[src] <span class='boldnotice'>Orbital bombardment has fired! Impact imminent!</span>")
	spawn(6)
		if(A)
			message_mods("ALERT: [usr] ([usr.key]) fired an orbital bombardment in [A.name]' (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)")
			log_attack("[usr.name] ([usr.ckey]) fired an orbital bombardment in [A.name]'")
		busy = 0
		var/turf/target = locate(T.x,T.y,T.z)
		if(target && istype(target))
			target.ceiling_debris_check(5)
			spawn(2)
				almayer_orbital_cannon.fire_ob_cannon(target, usr)


/obj/machinery/computer/overwatch/proc/change_lead()
	if(!usr || usr != operator)
		return
	if(!current_squad)
		to_chat(usr, "\icon[src] <span class='warning'>No squad selected!</span>")
		return
	var/sl_candidates = list()
	for(var/mob/living/carbon/human/H in current_squad.marines_list)
		if(istype(H) && H.stat != DEAD && H.mind && !jobban_isbanned(H, "Squad Leader"))
			sl_candidates += H
	var/new_lead = input(usr, "Choose a new Squad Leader") as null|anything in sl_candidates
	if(!new_lead || new_lead == "Cancel") return
	var/mob/living/carbon/human/H = new_lead
	if(!istype(H) || !H.mind || H.stat == DEAD) //marines_list replaces mob refs of gibbed marines with just a name string
		to_chat(usr, "\icon[src] <span class='warning'>[H] is KIA!</span>")
		return
	if(H == current_squad.squad_leader)
		to_chat(usr, "\icon[src] <span class='warning'>[H] is already the Squad Leader!</span>")
		return
	if(jobban_isbanned(H, "Squad Leader"))
		to_chat(usr, "\icon[src] <span class='warning'>[H] is unfit to lead!</span>")
		return
	if(current_squad.squad_leader)
		send_to_squad("Attention: [current_squad.squad_leader] is [current_squad.squad_leader.stat == DEAD ? "stepping down" : "demoted"]. A new Squad Leader has been set: [H.real_name].")
		visible_message("\icon[src] <span class='boldnotice'>Squad Leader [current_squad.squad_leader] of squad '[current_squad]' has been [current_squad.squad_leader.stat == DEAD ? "replaced" : "demoted and replaced"] by [H.real_name]! Logging to enlistment files.</span>")
		current_squad.demote_squad_leader(current_squad.squad_leader.stat != DEAD)
	else
		send_to_squad("Attention: A new Squad Leader has been set: [H.real_name].")
		visible_message("\icon[src] <span class='boldnotice'>[H.real_name] is the new Squad Leader of squad '[current_squad]'! Logging to enlistment file.</span>")

	to_chat(H, "\icon[src] <font size='3' color='blue'><B>\[Overwatch\]: You've been promoted to \'[H.mind.assigned_role == "Squad Leader" ? "SQUAD LEADER" : "ACTING SQUAD LEADER"]\' for [current_squad.name]. Your headset has access to the command channel (:v).</B></font>")
	to_chat(usr, "\icon[src] [H.real_name] is [current_squad]'s new leader!")
	current_squad.squad_leader = H
	if(H.mind.assigned_role == "Squad Leader")//a real SL
		H.mind.role_comm_title = "SL"
	else //an acting SL
		H.mind.role_comm_title = "aSL"
	if(H.mind.cm_skills)
		H.mind.cm_skills.leadership = max(SKILL_LEAD_TRAINED, H.mind.cm_skills.leadership)
		H.update_action_buttons()

	if(istype(H.wear_ear, /obj/item/device/radio/headset/almayer/marine))
		var/obj/item/device/radio/headset/almayer/marine/R = H.wear_ear
		if(!R.keyslot1)
			R.keyslot1 = new /obj/item/device/encryptionkey/squadlead (src)
		else if(!R.keyslot2)
			R.keyslot2 = new /obj/item/device/encryptionkey/squadlead (src)
		else if(!R.keyslot3)
			R.keyslot3 = new /obj/item/device/encryptionkey/squadlead (src)
		R.recalculateChannels()
	if(istype(H.wear_id, /obj/item/card/id))
		var/obj/item/card/id/ID = H.wear_id
		ID.access += ACCESS_MARINE_LEADER
	H.hud_set_squad()
	H.update_inv_head() //updating marine helmet leader overlays
	H.update_inv_wear_suit()

/obj/machinery/computer/overwatch/proc/mark_insubordination()
	if(!usr || usr != operator)
		return
	if(!current_squad)
		to_chat(usr, "\icon[src] <span class='warning'>No squad selected!</span>")
		return
	var/mob/living/carbon/human/wanted_marine = input(usr, "Report a marine for insubordination") as null|anything in current_squad.marines_list
	if(!wanted_marine) return
	if(!istype(wanted_marine))//gibbed/deleted, all we have is a name.
		to_chat(usr, "\icon[src] <span class='warning'>[wanted_marine] is missing in action.</span>")
		return

	for (var/datum/data/record/E in data_core.general)
		if(E.fields["name"] == wanted_marine.real_name)
			for (var/datum/data/record/R in data_core.security)
				if (R.fields["id"] == E.fields["id"])
					if(!findtext(R.fields["ma_crim"],"Insubordination."))
						R.fields["criminal"] = "*Arrest*"
						if(R.fields["ma_crim"] == "None")
							R.fields["ma_crim"]	= "Insubordination."
						else
							R.fields["ma_crim"] += "Insubordination."
						visible_message("\icon[src] <span class='boldnotice'>[wanted_marine] has been reported for insubordination. Logging to enlistment file.</span>")
						to_chat(wanted_marine, "\icon[src] <font size='3' color='blue'><B>\[Overwatch\]:</b> You've been reported for insubordination by your overwatch officer.</font>")
						wanted_marine.sec_hud_set_security_status()
					return

/obj/machinery/computer/overwatch/proc/transfer_squad()
	if(!usr || usr != operator)
		return
	if(!current_squad)
		to_chat(usr, "\icon[src] <span class='warning'>No squad selected!</span>")
		return
	var/datum/squad/S = current_squad
	var/mob/living/carbon/human/transfer_marine = input(usr, "Choose marine to transfer") as null|anything in current_squad.marines_list
	if(!transfer_marine) return
	if(S != current_squad) return //don't change overwatched squad, idiot.

	if(!istype(transfer_marine) || !transfer_marine.mind || transfer_marine.stat == DEAD) //gibbed, decapitated, dead
		to_chat(usr, "\icon[src] <span class='warning'>[transfer_marine] is KIA.</span>")
		return

	if(!istype(transfer_marine.wear_id, /obj/item/card/id))
		to_chat(usr, "\icon[src] <span class='warning'>Transfer aborted. [transfer_marine] isn't wearing an ID.</span>")
		return

	var/datum/squad/new_squad = input(usr, "Choose the marine's new squad") as null|anything in RoleAuthority.squads
	if(!new_squad) return
	if(S != current_squad) return

	if(!istype(transfer_marine) || !transfer_marine.mind || transfer_marine.stat == DEAD)
		to_chat(usr, "\icon[src] <span class='warning'>[transfer_marine] is KIA.</span>")
		return

	if(!istype(transfer_marine.wear_id, /obj/item/card/id))
		to_chat(usr, "\icon[src] <span class='warning'>Transfer aborted. [transfer_marine] isn't wearing an ID.</span>")
		return

	var/datum/squad/old_squad = transfer_marine.assigned_squad
	if(new_squad == old_squad)
		to_chat(usr, "\icon[src] <span class='warning'>[transfer_marine] is already in [new_squad]!</span>")
		return


	var/no_place = FALSE
	switch(transfer_marine.mind.assigned_role)
		if("Squad Leader")
			if(new_squad.num_leaders == new_squad.max_leaders)
				no_place = TRUE
		if("Squad Specialist")
			if(new_squad.num_specialists == new_squad.max_specialists)
				no_place = TRUE
		if("Squad Engineer")
			if(new_squad.num_engineers >= new_squad.max_engineers)
				no_place = TRUE
		if("Squad Medic")
			if(new_squad.num_medics >= new_squad.max_medics)
				no_place = TRUE
		if("Squad Smartgunner")
			if(new_squad.num_smartgun == new_squad.max_smartgun)
				no_place = TRUE

	if(no_place)
		to_chat(usr, "\icon[src] <span class='warning'>Transfer aborted. [new_squad] can't have another [transfer_marine.mind.assigned_role].</span>")
		return

	old_squad.remove_marine_from_squad(transfer_marine)
	new_squad.put_marine_in_squad(transfer_marine)

	for(var/datum/data/record/t in data_core.general) //we update the crew manifest
		if(t.fields["name"] == transfer_marine.real_name)
			t.fields["squad"] = new_squad.name
			break

	var/obj/item/card/id/ID = transfer_marine.wear_id
	ID.assigned_fireteam = 0 //reset fireteam assignment

	//Changes headset frequency to match new squad
	var/obj/item/device/radio/headset/almayer/marine/H = transfer_marine.wear_ear
	if(istype(H, /obj/item/device/radio/headset/almayer/marine))
		H.set_frequency(new_squad.radio_freq)

	transfer_marine.hud_set_squad()
	visible_message("\icon[src] <span class='boldnotice'>[transfer_marine] has been transfered from squad '[old_squad]' to squad '[new_squad]'. Logging to enlistment file.</span>")
	to_chat(transfer_marine, "\icon[src] <font size='3' color='blue'><B>\[Overwatch\]:</b> You've been transfered to [new_squad]!</font>")


/obj/machinery/computer/overwatch/proc/handle_supplydrop()
	if(!usr || usr != operator)
		return

	if(busy)
		to_chat(usr, "\icon[src] <span class='warning'>The [name] is busy processing another action!</span>")
		return

	if(!current_squad.sbeacon)
		to_chat(usr, "\icon[src] <span class='warning'>No supply beacon detected!</span>")
		return

	var/obj/structure/closet/crate/C = locate() in current_squad.drop_pad.loc //This thing should ALWAYS exist.
	if(!istype(C))
		to_chat(usr, "\icon[src] <span class='warning'>No crate was detected on the drop pad. Get Requisitions on the line!</span>")
		return

	if(!isturf(current_squad.sbeacon.loc))
		to_chat(usr, "\icon[src] <span class='warning'>The [current_squad.sbeacon.name] was not detected on the ground.</span>")
		return

	var/area/A = get_area(current_squad.bbeacon)
	if(A && A.ceiling >= CEILING_DEEP_UNDERGROUND)
		to_chat(usr, "\icon[src] <span class='warning'>The [current_squad.sbeacon.name]'s signal is too weak. It is probably deep underground.</span>")
		return

	var/turf/T = get_turf(current_squad.sbeacon)

	if(istype(T, /turf/open/space) || T.density)
		to_chat(usr, "\icon[src] <span class='warning'>The [current_squad.sbeacon.name]'s landing zone appears to be obstructed or out of bounds.</span>")
		return

	var/x_offset = x_offset_s
	var/y_offset = y_offset_s
	x_offset = round(x_offset)
	y_offset = round(y_offset)
	if(x_offset < -5 || x_offset > 5) x_offset = 0
	if(y_offset < -5 || y_offset > 5) y_offset = 0
	x_offset += rand(-2,2) //Randomize the drop zone a little bit.
	y_offset += rand(-2,2)

	busy = 1

	visible_message("\icon[src] <span class='boldnotice'>'[C.name]' supply drop is now loading into the launch tube! Stand by!</span>")
	C.visible_message("<span class='warning'>\The [C] begins to load into a launch tube. Stand clear!</span>")
	C.anchored = TRUE //to avoid accidental pushes
	send_to_squad("Supply Drop Incoming!")
	current_squad.sbeacon.visible_message("\icon[src] <span class='boldnotice'>The [current_squad.sbeacon.name] begins to beep!</span>")
	var/datum/squad/S = current_squad //in case the operator changes the overwatched squad mid-drop
	spawn(100)
		if(!C || C.loc != S.drop_pad.loc) //Crate no longer on pad somehow, abort.
			if(C) C.anchored = FALSE
			to_chat(usr, "\icon[src] <span class='warning'>Launch aborted! No crate detected on the drop pad.</span>")
			return
		S.supply_cooldown = world.time

		if(S.sbeacon)
			cdel(S.sbeacon) //Wipe the beacon. It's only good for one use.
			S.sbeacon = null
		playsound(C.loc,'sound/effects/bamf.ogg', 50, 1)  //Ehh
		C.anchored = FALSE
		C.z = T.z
		C.x = T.x + x_offset
		C.y = T.y + x_offset
		var/turf/TC = get_turf(C)
		TC.ceiling_debris_check(3)
		playsound(C.loc,'sound/effects/bamf.ogg', 50, 1)  //Ehhhhhhhhh.
		C.visible_message("\icon[C] <span class='boldnotice'>The [C.name] falls from the sky!</span>")
		visible_message("\icon[src] <span class='boldnotice'>'[C.name]' supply drop launched! Another launch will be available in five minutes.</span>")
		busy = 0

/obj/machinery/computer/overwatch/almayer
	density = 0
	icon = 'icons/Marine/almayer_props.dmi'
	icon_state = "sensor_comp2"

/obj/machinery/computer/overwatch/almayer
	density = 0
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "overwatch"

/obj/structure/supply_drop
	name = "Supply Drop Pad"
	desc = "Place a crate on here to allow bridge Overwatch officers to drop them on people's heads."
	icon = 'icons/effects/warning_stripes.dmi'
	anchored = 1
	density = 0
	unacidable = 1
	layer = ABOVE_TURF_LAYER
	var/squad = "Alpha"
	var/sending_package = 0

	New() //Link a squad to a drop pad
		..()
		spawn(10)
			force_link()

	proc/force_link() //Somehow, it didn't get set properly on the new proc. Force it again,
		var/datum/squad/S = get_squad_by_name(squad)
		if(S)
			S.drop_pad = src
		else
			to_chat(world, "Alert! Supply drop pads did not initialize properly.")

/obj/structure/supply_drop/alpha
	icon_state = "alphadrop"
	squad = "Alpha"

/obj/structure/supply_drop/bravo
	icon_state = "bravodrop"
	squad = "Bravo"

/obj/structure/supply_drop/charlie
	icon_state = "charliedrop"
	squad = "Charlie"

/obj/structure/supply_drop/delta
	icon_state = "deltadrop"
	squad = "Delta"

/obj/item/device/squad_beacon
	name = "squad supply beacon"
	desc = "A rugged, glorified laser pointer capable of sending a beam into space. Activate and throw this to call for a supply drop."
	icon_state = "motion0"
	unacidable = 1
	w_class = 2
	var/serial_number = 0
	var/activated = 0
	var/activation_time = 60
	var/datum/squad/squad = null
	var/icon_activated = "motion2"

/obj/item/device/squad_beacon/New(turf/loc, var/given_serial = 0)
	if(given_serial == 0)
		serial_number = rand(1, 979225)
	else
		serial_number = given_serial
	desc += " —ерийный номер [serial_number]"
	..(loc)

/obj/item/device/squad_beacon/Dispose()
	if(squad)
		if(squad.sbeacon == src)
			squad.sbeacon = null
		if(squad.bbeacon == src)
			squad.bbeacon = null
		squad = null
	. = ..()

/obj/item/device/squad_beacon/attack_self(mob/user)
	if(activated)
		to_chat(user, "<span class='warning'>It's already been activated. Just leave it.</span>")
		return

	if(!ishuman(user)) return
	var/mob/living/carbon/human/H = user

	if(!user.mind)
		to_chat(user, "<span class='warning'>It doesn't seem to do anything for you.</span>")
		return

	squad = H.assigned_squad

	if(!squad)
		to_chat(user, "<span class='warning'>You need to be in a squad for this to do anything.</span>")
		return
	if(squad.sbeacon)
		to_chat(user, "<span class='warning'>Your squad already has a beacon activated.</span>")
		return
	var/area/A = get_area(user)
	if(A && istype(A) && A.ceiling >= CEILING_METAL)
		to_chat(user, "<span class='warning'>You have to be outside or under a glass ceiling to activate this.</span>")
		return

	var/delay = activation_time
	if(user.mind.cm_skills)
		delay = max(10, delay - 20*user.mind.cm_skills.leadership)

	user.visible_message("<span class='notice'>[user] starts setting up [src] on the ground.</span>",
	"<span class='notice'>You start setting up [src] on the ground and inputting all the data it needs.</span>")
	if(do_after(user, delay, TRUE, 5, BUSY_ICON_FRIENDLY))

		squad.sbeacon = src
		user.drop_inv_item_to_loc(src, user.loc)
		activated = 1
		anchored = 1
		w_class = 10
		icon_state = "[icon_activated]"
		playsound(src, 'sound/machines/twobeep.ogg', 15, 1)
		user.visible_message("[user] activates [src]",
		"You activate [src]")

/obj/item/device/squad_beacon/bomb
	name = "orbital beacon"
	desc = "A bulky device that fires a beam up to an orbiting vessel to send local coordinates."
	icon_state = "motion4"
	w_class = 2
	activation_time = 80
	icon_activated = "motion1"

/obj/item/device/squad_beacon/bomb/New(turf/loc, var/given_serial = 0)
	if(given_serial == 0)
		serial_number = rand(1, 979225)
	else
		serial_number = given_serial
	desc += " —ерийный номер [serial_number]"
	..(loc)

/obj/item/device/squad_beacon/bomb/attack_self(mob/user)
	if(activated)
		to_chat(user, "<span class='warning'>It's already been activated. Just leave it.</span>")
		return
	if(!ishuman(user)) return
	var/mob/living/carbon/human/H = user

	if(!user.mind)
		to_chat(user, "<span class='warning'>It doesn't seem to do anything for you.</span>")
		return

	squad = H.assigned_squad

	if(!squad)
		to_chat(user, "<span class='warning'>You need to be in a squad for this to do anything.</span>")
		return
	if(squad.bbeacon)
		to_chat(user, "<span class='warning'>Your squad already has a beacon activated.</span>")
		return

	if(user.z != 1)
		to_chat(user, "<span class='warning'>You have to be on the planet to use this or it won't transmit.</span>")
		return

	var/area/A = get_area(user)
	if(A && istype(A) && A.ceiling >= CEILING_DEEP_UNDERGROUND)
		to_chat(user, "<span class='warning'>This won't work if you're standing deep underground.</span>")
		return

	var/delay = activation_time
	if(user.mind.cm_skills)
		delay = max(15, delay - 20*user.mind.cm_skills.leadership)

	user.visible_message("<span class='notice'>[user] starts setting up [src] on the ground.</span>",
	"<span class='notice'>You start setting up [src] on the ground and inputting all the data it needs.</span>")
	if(do_after(user, delay, TRUE, 5, BUSY_ICON_HOSTILE))

		message_admins("[user] ([user.key]) set up an orbital strike beacon.")
		squad.bbeacon = src //Set us up the bomb~
		user.drop_inv_item_to_loc(src, user.loc)
		activated = 1
		anchored = 1
		w_class = 10
		layer = ABOVE_FLY_LAYER
		icon_state = "[icon_activated]"
		playsound(src, 'sound/machines/twobeep.ogg', 15, 1)
		user.visible_message("[user] activates [src]",
		"You activate [src]")

//This is perhaps one of the weirdest places imaginable to put it, but it's a leadership skill, so
/*
/mob/living/carbon/human/verb/issue_order()

	set name = "Issue Order"
	set desc = "Issue an order to nearby humans, using your authority to strengthen their resolve."
	set category = "IC"

	if(!mind.cm_skills || (mind.cm_skills && mind.cm_skills.leadership < SKILL_LEAD_TRAINED))
		to_chat(src, "<span class='warning'>You are not competent enough in leadership to issue an order.</span>")
		return

	if(stat)
		to_chat(src, "<span class='warning'>You cannot give an order in your current state.</span>")
		return

	if(command_aura_cooldown > 0)
		to_chat(src, "<span class='warning'>You have recently given an order. Calm down.</span>")
		return

	var/choice = input(src, "Choose an order") in command_aura_allowed + "help" + "cancel"
	if(choice == "help")
		to_chat(src, "<span class='notice'><br>Orders give a buff to nearby soldiers for a short period of time, followed by a cooldown, as follows:<br><B>Move</B> - Increased mobility and chance to dodge projectiles.<br><B>Hold</B> - Increased resistance to pain and combat wounds.<br><B>Focus</B> - Increased gun accuracy and effective range.<br></span>")
		return
	if(choice == "cancel") return
	command_aura = choice
	command_aura_cooldown = 60 //60 ticks
	command_aura_tick = 45 //45 ticks
	var/message = ""
	switch(command_aura)
		if("move")
			message = pick(";ѕќЎ≈¬≈Ћ»¬ј…“≈—№!", ";¬ѕ≈–≈ƒ, ¬ѕ≈–≈ƒ, ¬ѕ≈–≈ƒ!", ";ƒ¬»∆≈ћ—я!", ";Ў≈¬≈Ћ»“≈—№!", ";Ѕџ—“–≈≈!")
			say(message)
		if("hold")
			message = pick(";¬ ” –џ“»≈!", ";ƒ≈–∆ј“№ Ћ»Ќ»ё!", ";ƒ≈–∆ј“№ ѕќ«»÷»ё!", ";¬—≈ћ —“ќя“№ Ќј ћ≈—“≈!", ";—“ќя“№ » —–ј∆ј“№—я!")
			say(message)
		if("focus")
			message = pick(";—‘ќ ”—»–ќ¬ј“№ ќ√ќЌ№!", ";ѕ–»÷≈Ћ»“№—я!", ";ќ√ќЌ№ ѕќ ÷≈Ќ“–”!", ";ѕ–»÷≈Ћ№Ќџћ» ќ„≈–≈ƒяћ»!", ";ѕ–»÷≈Ћ№Ќџ… ќ√ќЌ№!")
			say(message)
	update_action_buttons()

/datum/action/skill/issue_order
	name = "Issue Order"
	skill_name = "leadership"
	skill_min = SKILL_LEAD_TRAINED

/datum/action/skill/issue_order/New()
	return ..(/obj/item/device/megaphone)

/datum/action/skill/issue_order/action_activate()
	var/mob/living/carbon/human/human = owner
	if(istype(human))
		human.issue_order()

/datum/action/skill/issue_order/update_button_icon()
	var/mob/living/carbon/human/human = owner
	if(!istype(human))
		return

	if(human.command_aura_cooldown > 0)
		button.color = rgb(255,0,0,255)
	else
		button.color = rgb(255,255,255,255)

/mob/living/carbon/human/New()
	..()
	var/datum/action/skill/issue_order/issue_order_action = new
	issue_order_action.give_action(src)*/

/mob/living/carbon/human/verb/issue_order(which as null|text)
	set name = "Issue Order"
	set desc = "Issue an order to nearby humans, using your authority to strengthen their resolve."
	set category = "IC"

	if(!mind.cm_skills || (mind.cm_skills && mind.cm_skills.leadership < SKILL_LEAD_TRAINED))
		to_chat(src, "<span class='warning'>You are not competent enough in leadership to issue an order.</span>")
		return

	if(stat)
		to_chat(src, "<span class='warning'>You cannot give an order in your current state.</span>")
		return

	if(command_aura_cooldown > 0)
		to_chat(src, "<span class='warning'>You have recently given an order. Calm down.</span>")
		return

	if(!which)
		var/choice = input(src, "Choose an order") in command_aura_allowed + "help" + "cancel"
		if(choice == "help")
			to_chat(src, "<span class='notice'><br>Orders give a buff to nearby soldiers for a short period of time, followed by a cooldown, as follows:<br><B>Move</B> - Increased mobility and chance to dodge projectiles.<br><B>Hold</B> - Increased resistance to pain and combat wounds.<br><B>Focus</B> - Increased gun accuracy and effective range.<br></span>")
			return
		if(choice == "cancel")
			return
		command_aura = choice
	else
		command_aura = which
	command_aura_cooldown = 120 //120 ticks
	command_aura_tick = 60 //60 ticks
	var/message = ""
	switch(command_aura)
		if("move")
			message = pick(";ѕќЎ≈¬≈Ћ»¬ј…“≈—№!", ";¬ѕ≈–≈ƒ, ¬ѕ≈–≈ƒ, ¬ѕ≈–≈ƒ!", ";ƒ¬»∆≈ћ—я!", ";Ў≈¬≈Ћ»“≈—№!", ";Ѕџ—“–≈≈!")
			say(message)
			var/image/move = image('icons/mob/talk.dmi', icon_state = "order_move")
			overlays += move
			spawn(5 SECONDS)
				overlays -= move
		if("hold")
			message = pick(";¬ ” –џ“»≈!", ";ƒ≈–∆ј“№ Ћ»Ќ»ё!", ";ƒ≈–∆ј“№ ѕќ«»÷»ё!", ";¬—≈ћ —“ќя“№ Ќј ћ≈—“≈!", ";—“ќя“№ » —–ј∆ј“№—я!")
			say(message)
			var/image/hold = image('icons/mob/talk.dmi', icon_state = "order_hold")
			overlays += hold
			spawn(5 SECONDS)
				overlays -= hold
		if("focus")
			message = pick(";—‘ќ ”—»–ќ¬ј“№ ќ√ќЌ№!", ";ѕ–»÷≈Ћ»“№—я!", ";ќ√ќЌ№ ѕќ ÷≈Ќ“–”!", ";ѕ–»÷≈Ћ№Ќџћ» ќ„≈–≈ƒяћ»!", ";ѕ–»÷≈Ћ№Ќџ… ќ√ќЌ№!")
			say(message)
			var/image/focus = image('icons/mob/talk.dmi', icon_state = "order_focus")
			overlays += focus
			spawn(5 SECONDS)
				overlays -= focus
	update_action_buttons()


/datum/action/skill/issue_order
	name = "Issue Order"
	skill_name = "leadership"
	skill_min = SKILL_LEAD_TRAINED

/datum/action/skill/issue_order/New()
	return ..(/obj/item/device/megaphone)

/datum/action/skill/issue_order/action_activate()
	var/mob/living/carbon/human/human = owner
	if(istype(human))
		human.issue_order()

/datum/action/skill/issue_order/update_button_icon()
	var/mob/living/carbon/human/human = owner
	if(!istype(human))
		return

	if(human.command_aura_cooldown > 0)
		button.color = rgb(255,0,0,255)
	else
		button.color = rgb(255,255,255,255)

/mob/living/carbon/human/New()
	..()
	var/datum/action/skill/issue_order/issue_order_action = new
	issue_order_action.give_action(src)




/obj/structure/fulter_pad
	name = "Fulton Recovery System"
	desc = "—юда поступают отправленные вещи через 'Fulton Recieving Device'."
	icon = 'icons/effects/warning_stripes.dmi'
	icon_state = "emergencydrop"
	anchored = 1
	density = 0
	unacidable = 1
	layer = ABOVE_TURF_LAYER
/*
	New() //Link a squad to a drop pad
		..()
		spawn(10)
			force_link()

	proc/force_link() //Somehow, it didn't get set properly on the new proc. Force it again,
		var/datum/squad/S = get_squad_by_name(squad)
		if(S)
			S.fulter_pad = src
		else
			to_chat(world, "Alert! Fulton Recovery System pads did not initialize properly.")
*/



/*
/obj/item/device/data_detector
	name = "Data detector"
	desc = "A device that detects data files, but ignores non information files. It has a mode selection button on the side."
	var/serial_number = 0
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "detecter"
	item_state = "electronic"
	flags_atom = CONDUCT
	flags_equip_slot = SLOT_WAIST
	var/list/blip_pool = list()
	var/detector_range = 14
	var/detector_mode = DATA_DETECTOR_LONG
	w_class = 3
	var/active = 0
	var/recycletime = 120
	var/long_range_cooldown = 2

/obj/item/device/data_detector/New(turf/loc, var/given_serial = 0)
	if(given_serial == 0)
		serial_number = rand(1, 79225)
	else
		serial_number = given_serial
	desc += " —ерийный номер [serial_number]"
	..(loc)

/obj/item/device/data_detector/verb/toggle_range_mode()
	set name = "Toggle Range Mode"
	set category = "Object"
	detector_mode = !detector_mode
	if(detector_mode)
		to_chat(usr, "<span class='notice'>You switch [src] to short range mode.</span>")
		detector_range = 7
	else
		to_chat(usr, "<span class='notice'>You switch [src] to long range mode.</span>")
		detector_range = 14
	if(active)
		icon_state = "detecter_on_[detector_mode]"


/obj/item/device/data_detector/attack_self(mob/user)
	if(ishuman(user))
		active = !active
		if(active)
			icon_state = "detecter_on_[detector_mode]"
			to_chat(user, "<span class='notice'>You activate [src].</span>")
			processing_objects.Add(src)

		else
			icon_state = "detecter"
			to_chat(user, "<span class='notice'>You deactivate [src].</span>")
			processing_objects.Remove(src)

/obj/item/device/data_detector/Dispose()
	processing_objects.Remove(src)
	for(var/obj/X in blip_pool)
		cdel(X)
	blip_pool = list()
	..()

/obj/item/device/data_detector/process()
	if(!active)
		processing_objects.Remove(src)
		return
	recycletime--
	if(!recycletime)
		recycletime = initial(recycletime)
		for(var/X in blip_pool) //we dump and remake the blip pool every few minutes
			if(blip_pool[X])	//to clear blips assigned to mobs that are long gone.
				cdel(blip_pool[X]) //the blips are garbage-collected and reused via rnew() below
		blip_pool = list()

	if(!detector_mode)
		long_range_cooldown--
		if(long_range_cooldown) return
		else long_range_cooldown = initial(long_range_cooldown)

	playsound(loc, 'sound/items/detector.ogg', 60, 0, 7, 2)

	var/mob/living/carbon/human/human_user
	if(ishuman(loc))
		human_user = loc

	var/detected
	for(var/mob/M in living_mob_list)
		if(loc == null || M == null) continue
		if(loc.z != M.z) continue
		if(get_dist(M, src) > detector_range) continue
		if(M == loc) continue //device user isn't detected
		if(!isturf(M.loc)) continue
		if(world.time > M.l_move_time + 20) continue //hasn't moved recently
		if(isrobot(M)) continue
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(istype(H.wear_ear, /obj/item/device/radio/headset/almayer))
				continue //device detects marine headset and ignores the wearer.
		detected = TRUE

		if(human_user)
			show_blip(human_user, M)

		if(detected)
			playsound(loc, 'sound/items/tick.ogg', 50, 0, 7, 2)

/obj/item/device/data_detector/proc/show_blip(mob/user, mob/target)
	set waitfor = 0
	if(user.client)

		if(!blip_pool[target])
			blip_pool[target] = rnew(/obj/effect/detector_blip)

		var/obj/effect/detector_blip/DB = blip_pool[target]
		var/c_view = user.client.view
		var/view_x_offset = 0
		var/view_y_offset = 0
		if(c_view > 7)
			if(user.client.pixel_x >= 0) view_x_offset = round(user.client.pixel_x/32)
			else view_x_offset = CEILING(user.client.pixel_x/32, 1)
			if(user.client.pixel_y >= 0) view_y_offset = round(user.client.pixel_y/32)
			else view_y_offset = CEILING(user.client.pixel_y/32, 1)

		var/diff_dir_x = 0
		var/diff_dir_y = 0
		if(target.x - user.x > c_view + view_x_offset) diff_dir_x = 4
		else if(target.x - user.x < -c_view + view_x_offset) diff_dir_x = 8
		if(target.y - user.y > c_view + view_y_offset) diff_dir_y = 1
		else if(target.y - user.y < -c_view + view_y_offset) diff_dir_y = 2
		if(diff_dir_x || diff_dir_y)
			DB.icon_state = "detector_blip_dir"
			DB.dir = diff_dir_x + diff_dir_y
		else
			DB.icon_state = initial(DB.icon_state)
			DB.dir = initial(DB.dir)

		DB.screen_loc = "[CLAMP(c_view + 1 - view_x_offset + (target.x - user.x), 1, 2*c_view+1)],[CLAMP(c_view + 1 - view_y_offset + (target.y - user.y), 1, 2*c_view+1)]"
		user.client.screen += DB
		sleep(12)
		if(user.client)
			user.client.screen -= DB




/obj/item/device/fulton
	name = "Fulton Recieving Device"
	desc = "."
	var/serial_number = 0
	w_class = 2
	icon_state = "flare"
	item_state = "flare"
	det_time = 200
	actions = list()	//just pull it manually, neckbeard.

/obj/item/device/fulton/New(turf/loc, var/given_serial = 0)
	if(given_serial == 0)
		serial_number = rand(1, 897826)
	else
		serial_number = given_serial
	desc += " —ерийный номер [serial_number]"
	..(loc)

/obj/structure/fulter_pad/proc/handle_supplydrop()
	if(!usr || usr != operator)
		return

	if(busy)
		to_chat(usr, "\icon[src] <span class='warning'>The [name] is busy processing another action!</span>")
		return

	if(!current_fulter_pad)
		to_chat(usr, "\icon[src] <span class='warning'>No detected!</span>")
		return

//	var/obj/
	var/mob/living/carbon/Xenomorph/X = locate() in current_squad.fulter_pad.loc //This thing should ALWAYS exist.
	if(!istype(X))
		to_chat(usr, "\icon[src] <span class='warning'></span>")
		return

	if(!isturf(current_fulter_pad.loc))
		to_chat(usr, "\icon[src] <span class='warning'></span>")
		return

	var/area/A = get_area(current_fulter_pad)
	if(A && A.ceiling >= CEILING_DEEP_UNDERGROUND)
		to_chat(usr, "\icon[src] <span class='warning'></span>")
		return

	var/turf/T = get_turf(current_fulter_pad)

	if(istype(T, /turf/open/space) || T.density)
		to_chat(usr, "\icon[src] <span class='warning'>The landing zone appears to be obstructed or out of bounds.</span>")
		return

	var/x_offset = x_offset_s
	var/y_offset = y_offset_s
	x_offset = round(x_offset)
	y_offset = round(y_offset)
	if(x_offset < -5 || x_offset > 5) x_offset = 0
	if(y_offset < -5 || y_offset > 5) y_offset = 0
	x_offset += rand(-0,0) //Randomize the drop zone a little bit.
	y_offset += rand(-0,0)

	busy = 1

	visible_message("\icon[src] <span class='boldnotice'>'[X.name]' is now launch! Stand by!</span>")
	C.visible_message("<span class='warning'>\The [X] begins launch. Stand clear!</span>")
	C.anchored = TRUE //to avoid accidental pushes
	send_to_squad("Supply Drop Incoming!")
	current_fulter_pad.visible_message("\icon[src] <span class='boldnotice'>Begins to beep!</span>")
	var/datum/squad/S = current_squad //in case the operator changes the overwatched squad mid-drop
	spawn(100)
		if(!C || C.loc != S.drop_pad.loc) //Crate no longer on pad somehow, abort.
			if(C) C.anchored = FALSE
			to_chat(usr, "\icon[src] <span class='warning'>Launch aborted! No crate detected on the drop pad.</span>")
			return
		S.fulter_cooldown = 1

		if(S.sfulter_pad)
			cdel(S.sfulter_pad) //Wipe the beacon. It's only good for one use.
			S.sbeacon = null
		playsound(C.loc,'sound/effects/bamf.ogg', 50, 1)  //Ehh
		X.anchored = FALSE
		X.z = T.z
		X.x = T.x + x_offset
		X.y = T.y + x_offset
		var/turf/TC = get_turf(C)
		TC.ceiling_debris_check(3)
		playsound(X.loc,'sound/effects/bamf.ogg', 50, 1)  //Ehhhhhhhhh.
		X.visible_message("\icon[X] <span class='boldnotice'>The [X.name] falls from the sky!</span>")
		visible_message("\icon[src] <span class='boldnotice'>'[X.name]' launched! Another launch will be available in five minutes.</span>")
		busy = 0*/