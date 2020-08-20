#define CONTAINMENT_LARVA 0

#define CONTAINMENT_SENTINEL 10
#define CONTAINMENT_SPITTER 11

#define CONTAINMENT_RUNNER 20
#define CONTAINMENT_LURKER 21
#define CONTAINMENT_RAVAGER 22

#define CONTAINMENT_DEFENDER 30
#define CONTAINMENT_WARRIOR 31
#define CONTAINMENT_CRUSHER 32
#define CONTAINMENT_PRAETORIAN 33

#define CONTAINMENT_DRONE 40
#define CONTAINMENT_CARRIER 41
#define CONTAINMENT_HIVELORD 42
#define CONTAINMENT_BURROWER 43

#define CONTAINMENT_QUEEN 50


///// Holder for species /////
/datum/species_collection
	var/list/known_species = list()
	var/list/possible_species = list()

/datum/species_collection/New()
	for(var/specie in subtypesof(/datum/alienspecies))
		possible_species += new specie(src)

/datum/species_collection/proc/AddToKnown(id)
	for(var/datum/alienspecies/specie in possible_species)
		if(specie.id == id)
			known_species += specie
			possible_species -= specie
			return
	return

/datum/species_collection/proc/CheckXeno(id)
	for(var/datum/alienspecies/specie in known_species)
		if(specie.id == id)
			return 1
	return 0

///// List of species /////
/datum/alienspecies
	var/name = "name"					// Name of species
	var/desc = "desc"					// What will show after research
	var/id = -1							// Species needed

/datum/alienspecies/larva
	name = "Xenomorph Larva"
	desc = "An intresting worm-like creature recently found by our troops. Completely harmless, this thing can evolve in numerous sub-species of Xenomorph race. Our forces can kill it with bare hands."
	id = CONTAINMENT_LARVA

/datum/alienspecies/sentinel
	name = "Xenomorph Sentinel"
	desc = "Relatively weak on close-combat, but highly dangerous on distance - Sentinels forms fire-support squadrons (or packs, to be exact) of Xenomorph Forces. They actively use covers and sniping or troops with dangerous toxins. But they can be negated by using suppresion fire and grenades."
	id = CONTAINMENT_SENTINEL

/datum/alienspecies/spitter
	name = "Xenomorph Spitter"
	desc = "Main medium-range fire troopers, Spitters dangerous for any lone marine and forms main obstacle of soldiers' advance. They neurotoxins and acids make very hard to push Xenomorph lines, but due their fragility, they can be very fast outgunned."
	id = CONTAINMENT_SPITTER

/datum/alienspecies/runner
	name = "Xenomorph Runner"
	desc = "Fast and agile - Runners' role in the Hive are scout and hit&run missions. Lone marine, if not prepered for assault, can be easily taken down by Runner, but pair of marines can defend themselves without injures."
	id = CONTAINMENT_RUNNER

/datum/alienspecies/lurker
	name = "Xenomorph Lurker"
	desc = "Dwellers in the dark, stealh and menancing - Lurkers are assasins, that dwells through alien ranks, capable tear apart any human being with ease. Chameleons, that devastating our supply lines on operative zone, slaughtering every lone marine on sight - Lurkers are foes, whom we fear the most."
	id = CONTAINMENT_LURKER

/datum/alienspecies/ravager
	name = "Xenomorph Ravager"
	desc = "Ravagers are shock troopers with enough strengh to mow down any marine in their vicinity. They can be even called AT infantry, because they are capable tear down or Longsteeds. We recommend use of high-caliber weapons and AP rounds to deal with those horrific creatures, and don't waste napalm on them."
	id = CONTAINMENT_RAVAGER

/datum/alienspecies/defender
	name = "Xenomorph Defender"
	desc = "Forming main defense lines of the Hive - Defenders are tough and powerful foes. Their only purpose is protection of the Hive. This creature is too ordinary, and small team equipped with AP weapons will make short work out of Defenders."
	id = CONTAINMENT_DEFENDER

/datum/alienspecies/warrior
	name = "Xenomorph Warrior"
	desc = "Warriors are standart troopers in every engagement. Strong and durable, those creatures never hunt lone marines. Instead entire squad will engage with small pack of Warriors. They are unintresting on academic research, but marines should be aware to never engage Warriors in close combat or alone."
	id = CONTAINMENT_WARRIOR

/datum/alienspecies/crusher
	name = "Xenomorph Crusher"
	desc = "Ponderous and staggering, Crushers are the most durable of all sub-species. They are very strong too, but can use them on fullpower only to crush enemy with all weight. Their chitin is flammable and AP bullets still can pierce their thick chitin."
	id = CONTAINMENT_CRUSHER

/datum/alienspecies/praetorian
	name = "Xenomorph Praetorian"
	desc = "We not exactly sure of what Praetorians suppose to do. They are strong, can spill acid, spit neurotoxins and spread pheromones. But they can be hardly found without some other xenomorph with. We suggest, that marines should report about any activity of Praetorians on operative area and fight them with cautious."
	id = CONTAINMENT_PRAETORIAN

/datum/alienspecies/drone
	name = "Xenomorph Drone"
	desc = "Common builders of the Hive - Drones are very weak and pathetic foes. But their work is vital for the Hive. They build, they reinforce and they creating obstacles on marines advance. Lone marine can shot down any Drone with ease, but they can tackle our troopers pretty strong."
	id = CONTAINMENT_DRONE

/datum/alienspecies/carrier
	name = "Xenomorph Carrier"
	desc = "Carriers are very weak without their 'armament', but once they aquare facehuggers, marines should use long-range weapon to deal with them. Otherwise, they are unintresting, but we recieve unverified reports, that Carriers place some kind of traps."
	id = CONTAINMENT_CARRIER

/datum/alienspecies/hivelord
	name = "Xenomorph Hivelord"
	desc = "Fasinating creature of efficent metabolism and building capabilities - Hivelords are rare xenomorph. Dwelling deep in the Hive, they are doing vital work. They resin are more thicker ar fast-deployable, but they combat abilities is somewhat underwhelming. We suggest to hunt down any of these creatures to prevent Hive spread."
	id = CONTAINMENT_HIVELORD

/datum/alienspecies/burrower
	name = "Xenomorph Hivelord"
	desc = "Fasinating creature of efficent metabolism and building capabilities - Hivelords are rare xenomorph. Dwelling deep in the Hive, they are doing vital work. They resin are more thicker ar fast-deployable, but they combat abilities is somewhat underwhelming. We suggest to hunt down any of these creatures to prevent Hive spread."
	id = CONTAINMENT_BURROWER

/datum/alienspecies/queen
	name = "Xenomorph Queen"
	desc = "If lone marine took down this insidious and powerful creature - he is some kind of superhuman no less. If Queen arrives on the battlefield, marines are doomed, if they haven't any heavy armament and earplugs. Strong, durable, smart and highly dangerous - Queen are the main component of the Hive. if we got one in our laboratory - the victory almost in our hands."
	id = CONTAINMENT_QUEEN

//// Research Stuff ////
/obj/machinery/container
	name = "Speciemen Analyze Chamber"
	desc = "Standart pressure chamber for all your biology needs"
	icon = 'code/WorkInProgress/polion1232/rnd.dmi'
	icon_state = "analyzer_chamber"
	var/mob/living/carbon/Xenomorph/occupant = null
	var/obj/machinery/computer/analyze_console/linked_console = null

	use_power = 1
	idle_power_usage = 20
	active_power_usage = 200

/obj/machinery/container/update_icon()
	if(occupant)
		icon_state = "analyzer_chamber_full"
		return
	icon_state = "analyzer_chamber"

/obj/machinery/container/attackby(obj/item/W, mob/living/user)
	if(istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		if(!ismob(G.grabbed_thing))
			return
		var/mob/M = G.grabbed_thing
		if(isXeno(M))
			put_mob(M)
	return

/obj/machinery/container/proc/put_mob(mob/living/carbon/M as mob)
	if (stat & (NOPOWER|BROKEN))
		to_chat(usr, "<span style='color:#FF0000'>The chamber is not functioning.</span>")
		return
	if (!istype(M))
		to_chat(usr, "<span style='color:#FF0000'><B>The chamber cannot handle such a lifeform!</B></span>")
		return
	if (!isXeno(M))
		to_chat(usr, "<span style='color:#FF0000'><B>You feel stupid of this idea</B></span>")
		return
	if (occupant)
		to_chat(usr, "<span style='color:#FF0000'><B>The chamber is already occupied!</B></span>")
		return
	if (M.abiotic())
		to_chat(usr, "<span style='color:#FF0000'>Subject may not have abiotic items on.</span>")
		return
	M.forceMove(src)
	occupant = M
	update_use_power(2)
//	M.metabslow = 1
	add_fingerprint(usr)
	update_icon()
	return 1

/obj/machinery/container/verb/move_eject()
	set name = "Eject occupant"
	set category = "Object"
	set src in oview(1)
	if(usr == occupant)//If the user is inside the tube...
		if (usr.stat == 2)//and he's not dead....
			return
		to_chat(usr, "<span style='color:#0000FF'>Release sequence activated. This will take two minutes.</span>")
		sleep(1200)
		if(!src || !usr || !occupant || (occupant != usr)) //Check if someone's released/replaced/bombed him already
			return
		go_out()//and release him from the eternal prison.
	else
		go_out()
	add_fingerprint(usr)
	update_icon()
	return

/obj/machinery/container/proc/go_out()
	occupant.forceMove(loc)
	occupant = null



/*
///// Speciemen Analyze Console /////

If chamber connected to the console, you can start research aliens. Just don't butcher them before.
*/

/obj/machinery/computer/analyze_console
	name = "Speciemen Analyze Console"
	icon = 'code/WorkInProgress/polion1232/polionresearch.dmi'
	icon_state = "r_on"
	circuit = /obj/item/circuitboard/machine/analyze_console

	var/datum/species_collection/files = null
	var/obj/machinery/container/linked_chamber = null
	var/screen = 1.0
	var/errored = 0
	req_access = list(ACCESS_MARINE_RESEARCH)

/obj/machinery/computer/analyze_console/update_icon()
	if(stat & NOPOWER || stat & BROKEN)
		icon_state = "r_off"
		return
	icon_state = "r_on"

/obj/machinery/computer/analyze_console/New()
	..()
	files = new /datum/species_collection(src)

/obj/machinery/computer/analyze_console/proc/SyncRDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any). Derived from rdconsole.dm
	for(var/obj/machinery/container/D in oview(3,src))
		if(D.linked_console != null)
			continue
		if(istype(D, /obj/machinery/container))
			if(linked_chamber == null)
				linked_chamber = D
				D.linked_console = src
				return
	return

/obj/machinery/computer/analyze_console/Topic(href, href_list)				//Brutally teared from rdconsole.dm
	if(..())
		return

	add_fingerprint(usr)

	usr.set_interaction(src)
	if(href_list["menu"]) //Switches menu screens. Converts a sent text string into a number. Saves a LOT of code.
		var/temp_screen = text2num(href_list["menu"])
		if(temp_screen <= 1.0 || (3 <= temp_screen && 4.9 >= temp_screen) || src.allowed(usr) || emagged) //Unless you are making something, you need access.
			screen = temp_screen
		else
			to_chat(usr, "Unauthorized Access.")

	else if(href_list["find_device"]) //The R&D console looks for devices nearby to link up with.
		screen = 0.0
		spawn(20)
			SyncRDevices()
			screen = 1.3
			updateUsrDialog()

	else if(href_list["scan"])
		if(linked_chamber)
			if(linked_chamber.occupant)
				if(linked_chamber.occupant.xeno_forbid_retract)
					screen = 2.3
					updateUsrDialog()
					spawn(50)
						screen = 2.2
						updateUsrDialog()
						return
				if(isXenoLarva(linked_chamber.occupant))
					files.AddToKnown(CONTAINMENT_LARVA)
				else if(isXenoSentinel(linked_chamber.occupant))
					files.AddToKnown(CONTAINMENT_SENTINEL)
				else if(isXenoSpitter(linked_chamber.occupant))
					files.AddToKnown(CONTAINMENT_SPITTER)
				else if(isXenoRunner(linked_chamber.occupant))
					files.AddToKnown(CONTAINMENT_RUNNER)
				else if(isXenoHunter(linked_chamber.occupant))
					files.AddToKnown(CONTAINMENT_LURKER)
				else if(isXenoRavager(linked_chamber.occupant))
					files.AddToKnown(CONTAINMENT_RAVAGER)
				else if(isXenoDefender(linked_chamber.occupant))
					files.AddToKnown(CONTAINMENT_DEFENDER)
				else if(isXenoWarrior(linked_chamber.occupant))
					files.AddToKnown(CONTAINMENT_WARRIOR)
				else if(isXenoCrusher(linked_chamber.occupant))
					files.AddToKnown(CONTAINMENT_CRUSHER)
				else if(isXenoPraetorian(linked_chamber.occupant))
					files.AddToKnown(CONTAINMENT_PRAETORIAN)
				else if(isXenoDrone(linked_chamber.occupant))
					files.AddToKnown(CONTAINMENT_DRONE)
				else if(isXenoCarrier(linked_chamber.occupant))
					files.AddToKnown(CONTAINMENT_CARRIER)
				else if(isXenoHivelord(linked_chamber.occupant))
					files.AddToKnown(CONTAINMENT_HIVELORD)
/*				else if(isXenoBurrower(linked_chamber.occupant))
					files.AddToKnown(CONTAINMENT_BURROWER)*/
				else if(isXenoQueen(linked_chamber.occupant))
					files.AddToKnown(CONTAINMENT_QUEEN)
				screen = 0.1
				spawn(300)
					screen = 1.1
					updateUsrDialog()
	else if(href_list["harvest"])
		if(!linked_chamber)
			updateUsrDialog()
		else
			if(!linked_chamber.occupant)
				return
			if(linked_chamber.occupant.xeno_forbid_retract == 1)
				return
			linked_chamber.occupant.xeno_forbid_retract = 1
			screen = 0.3
			spawn(300)
				screen = 1.1
				if(isXenoCrusher(linked_chamber.occupant))
					new /obj/item/marineResearch/xenomorp/chitin/crusher(linked_chamber.loc)
					if(files.CheckXeno(CONTAINMENT_CRUSHER))
						new /obj/item/marineResearch/xenomorp/chitin/crusher(linked_chamber.loc)
				else
					new /obj/item/marineResearch/xenomorp/chitin(linked_chamber.loc)
					if(files.CheckXeno(CONTAINMENT_RUNNER) && files.CheckXeno(CONTAINMENT_LURKER) && files.CheckXeno(CONTAINMENT_RAVAGER))
						new /obj/item/marineResearch/xenomorp/chitin(linked_chamber.loc)

				new /obj/item/marineResearch/xenomorp/muscle(linked_chamber.loc)
				if(files.CheckXeno(CONTAINMENT_RUNNER) || files.CheckXeno(CONTAINMENT_LURKER) || files.CheckXeno(CONTAINMENT_RAVAGER))
					new /obj/item/marineResearch/xenomorp/chitin(linked_chamber.loc)

				if(isXenoSentinel(linked_chamber.occupant))
					new /obj/item/marineResearch/xenomorp/acid_gland(linked_chamber.loc)

				if(isXenoSpitter(linked_chamber.occupant) || isXenoQueen(linked_chamber.occupant))
					new /obj/item/marineResearch/xenomorp/acid_gland/spitter(linked_chamber.loc)
					if(isXenoQueen(linked_chamber.occupant) && files.CheckXeno(CONTAINMENT_SPITTER))
						new /obj/item/marineResearch/xenomorp/acid_gland/spitter(linked_chamber.loc)

				if(isXenoDrone(linked_chamber.occupant) || isXenoQueen(linked_chamber.occupant))
					new /obj/item/marineResearch/xenomorp/secretor(linked_chamber.loc)
					if(isXenoQueen(linked_chamber.occupant) && files.CheckXeno(CONTAINMENT_DRONE))
						new /obj/item/marineResearch/xenomorp/secretor(linked_chamber.loc)

				if(isXenoHivelord(linked_chamber.occupant) || isXenoQueen(linked_chamber.occupant))
					new /obj/item/marineResearch/xenomorp/secretor(linked_chamber.loc)
					new /obj/item/marineResearch/xenomorp/secretor/hivelord(linked_chamber.loc)
					if(isXenoHivelord(linked_chamber.occupant) && files.CheckXeno(CONTAINMENT_DRONE))
						new /obj/item/marineResearch/xenomorp/secretor(linked_chamber.loc)
					if((isXenoQueen(linked_chamber.occupant) || isXenoHivelord(linked_chamber.occupant)) && files.CheckXeno(CONTAINMENT_HIVELORD))
						new /obj/item/marineResearch/xenomorp/secretor/hivelord(linked_chamber.loc)
/*
				if(isXenoBurrower(linked_chamber.occupant) || isXenoQueen(linked_chamber.occupant))
					new /obj/item/marineResearch/xenomorp/secretor(linked_chamber.loc)
					new /obj/item/marineResearch/xenomorp/secretor/Burrower(linked_chamber.loc)
					if(isXenoBurrower(linked_chamber.occupant) && files.CheckXeno(CONTAINMENT_DRONE))
						new /obj/item/marineResearch/xenomorp/secretor(linked_chamber.loc)
					if((isXenoQueen(linked_chamber.occupant) || isXenoBurrower(linked_chamber.occupant)) && files.CheckXeno(CONTAINMENT_BURROWER))
						new /obj/item/marineResearch/xenomorp/secretor/burrower(linked_chamber.loc)
*/
				if(isXenoQueen(linked_chamber.occupant))
					new /obj/item/marineResearch/xenomorp/acid_gland/spitter(linked_chamber.loc)
					new /obj/item/marineResearch/xenomorp/secretor(linked_chamber.loc)
					new /obj/item/marineResearch/xenomorp/secretor/hivelord(linked_chamber.loc)

				if(isXenoQueen(linked_chamber.occupant))
					new /obj/item/marineResearch/xenomorp/core(linked_chamber.loc)
				updateUsrDialog()

	updateUsrDialog()

/obj/machinery/computer/analyze_console/attack_hand(mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return

	user.set_interaction(src)
	var/dat = ""
	switch(screen) //A quick check to make sure you get the right screen when a device is disconnected.
		if(2 to 2.9)
			if(linked_chamber == null)
				screen = 2.0
			else if(linked_chamber.occupant == null)
				screen = 2.1
			else if(linked_chamber.occupant.xeno_forbid_retract == 1)
				screen = 2.3
			else
				screen = 2.2

	switch(screen)

		if(0.0)
			dat += "Establishing linkage with nearby chamber"

		if(0.1)
			dat += "Scanning in progress."

		if(0.2)
			dat += "SYSTEM LOCKED<BR><BR>"
			dat += "<A href='?src=\ref[src];lock=1.2'>Unlock</A>"

		if(0.3)
			dat += "Harvesting...<BR><BR>"

		if(1.0)
			dat += "Main Menu:<BR><BR>"
			dat += "<A href='?src=\ref[src];menu=1.1'>Known Species</A><HR>"
			if(linked_chamber != null) dat += "<A href='?src=\ref[src];menu=2.2'>Analyze Chamber Menu</A><BR>"
			else dat += "NO CHAMBER LINKED<BR>"
			dat += "<HR><A href='?src=\ref[src];menu=1.2'>Settings</A>"

		if(1.1)
			dat += "List of discovered species.<HR><HR>"
			for(var/datum/alienspecies/specie in files.known_species)
				dat +="<font size=2>[specie.name]<BR>[specie.desc]</font><HR>"
			dat += "<HR><A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

		if(1.2)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "R&D Console Setting:<BR><BR>"
			dat += "<A href='?src=\ref[src];menu=1.3'>Device Linkage Menu</A><BR>"
			dat += "<A href='?src=\ref[src];lock=0.2'>Lock Console</A><BR>"

		if(1.3)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || <A href='?src=\ref[src];menu=1.2'>Settings</A><HR>"
			dat += "<A href='?src=\ref[src];find_device=1'>Re-sync with Nearby Chamber</A><BR>"
			dat += "Chamber status: "
			if(linked_chamber)
				if(linked_chamber.occupant)
					dat += " OCCUPIED<BR>"
				else
					dat += " LINKED <A href='?src=\ref[src];disconnect=chamber'>(Disconnect)</A><BR>"
			else
				dat += " NOT FOUND<BR>"

		if(2.0)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "CHAMBER NOT LINKED<HR>"

		if(2.1)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "CHAMBER IS EMPTY"

		if(2.2)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "[linked_chamber.occupant.name]: <A href='?src=\ref[src];scan=1'>Scan</A> | <A href='?src=\ref[src];harvest=1'>Harvest Organs</A><BR>"
		if(2.3)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "ERROR! Speciemen internal injures is too severe. Suspected organ removal."

	user << browse("<TITLE>Research and Development Console</TITLE><HR>[dat]", "window=rdconsole;size=575x400")
	onclose(user, "rdconsole")

#undef CONTAINMENT_LARVA

#undef CONTAINMENT_SENTINEL
#undef CONTAINMENT_SPITTER

#undef CONTAINMENT_RUNNER
#undef CONTAINMENT_LURKER
#undef CONTAINMENT_RAVAGER

#undef CONTAINMENT_DEFENDER
#undef CONTAINMENT_WARRIOR
#undef CONTAINMENT_CRUSHER
#undef CONTAINMENT_PRAETORIAN

#undef CONTAINMENT_DRONE
#undef CONTAINMENT_CARRIER
#undef CONTAINMENT_HIVELORD
#undef CONTAINMENT_BURROWER

#undef CONTAINMENT_QUEEN