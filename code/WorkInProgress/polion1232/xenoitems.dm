/*
///// List of ids for teches/////

//First letter determinates path, second - tech
Starting (Xenomorphs) - 0

Xeno Biology - 10
Bio Plating - 11
Crusher Plating - 12
Xeno Muscles - 13
Hivelord thingy - 14

Xeno Chemistry - 20
Spitter thingy - 21

Xeno Flora - 30
Xenoweed - 31
Xenosack - 32
Drone thingy - 33

Queen thingy - 40
*/



//Holsters
/obj/item/marineResearch
	name = "An unidentified Alien Thingy"
	desc = "Researchy thingy!"
	icon = 'code/WorkInProgress/polion1232/polionresearch.dmi'
	icon_state = "biomass"
	var/list/id = list()

/obj/item/marineResearch/xenomorp
	name = "An unidentified Alien Thingy"
	desc = "Researchy thingy!"
	icon = 'code/WorkInProgress/polion1232/polionresearch.dmi'
	icon_state = "biomass"




//Xenofauna, you will not find those thing during normal gameplay, see sampler
/obj/item/marineResearch/xenomorp/weed
    name = "Xenoweed sample"
    desc = "Sample of strange plant"
    id = list(RESEARCH_XENOSTART, RESEARCH_XENO_FLORA, RESEARCH_XENO_WEED)

/obj/item/marineResearch/xenomorp/weed/sack
    name = "Sack sample"
    desc = "Sample of strange organic tissue, what partially acid"
    id = list(RESEARCH_XENOSTART, RESEARCH_XENO_FLORA, 32)

//Xenomorph pieces
/obj/item/marineResearch/xenomorp/chitin
	name = "Xenomorph chitin"
	desc = "A sturdy chunk of xenomorph chitin"
	icon_state = "chitin-chunk"
	id = list(RESEARCH_XENOSTART, RESEARCH_XENO_BIOLOGY, RESEARCH_BIO_PLATING)

/obj/item/marineResearch/xenomorp/muscle
	name = "Xenomorph muscle tissue"
	desc = "A common xenomorph muscle tissue"
	icon_state = "muscle"
	id = list(RESEARCH_XENOSTART, RESEARCH_XENO_BIOLOGY, RESEARCH_XENO_MUSCLES)

/obj/item/marineResearch/xenomorp/chitin/crusher
	name = "Crusher's chitin"
	desc = "A chunk of extremely sturdy and durable Crusher's chitin"
	icon_state = "chitin-crusher"
	id = list(RESEARCH_XENOSTART, RESEARCH_XENO_BIOLOGY, RESEARCH_BIO_PLATING, RESEARCH_CRUSHER_PLATING)

/obj/item/marineResearch/xenomorp/acid_gland
	name = "Xenomorph acid gland"
	desc = "Strange internal organ of some alien species"
	icon_state = "sentinel"
	id = list(RESEARCH_XENOSTART, RESEARCH_XENO_CHEMISTRY)

/obj/item/marineResearch/xenomorp/acid_gland/spitter
	name = "Spitter's gland"
	desc = "A more advanced acid gland, that produces strange toxins"
	icon_state = "spitter"
	id = list(RESEARCH_XENOSTART, RESEARCH_XENO_CHEMISTRY, RESEARCH_XENO_SPITTER)

/obj/item/marineResearch/xenomorp/secretor
	name = "Secretory gland"
	desc = "Strange gland, that secrete high variety of alien fauna"
	icon_state = "drone"
	id = list(RESEARCH_XENOSTART, RESEARCH_XENO_BIOLOGY, RESEARCH_XENO_MUSCLES, RESEARCH_XENO_FLORA, RESEARCH_XENO_DRONE)

/obj/item/marineResearch/xenomorp/secretor/hivelord
	name = "Hivelord's bioplasma syntesate"
	desc = "Bizzare tissue, that can be abudantly found in Hivelord body"
	icon_state = "hivelord"
	id = list(RESEARCH_XENOSTART, RESEARCH_XENO_BIOLOGY, RESEARCH_XENO_MUSCLES, RESEARCH_XENO_CHEMISTRY, RESEARCH_XENO_FLORA, RESEARCH_XENO_HIVELORD)

/obj/item/marineResearch/xenomorp/secretor/burrower
	name = "Burrower's bioplasma syntesate"
	desc = "Bizzare tissue, that can be abudantly found in Burrower body"
	icon_state = "hivelord"
	id = list(RESEARCH_XENOSTART, RESEARCH_XENO_BIOLOGY, RESEARCH_XENO_MUSCLES, RESEARCH_XENO_CHEMISTRY, RESEARCH_XENO_FLORA, RESEARCH_XENO_HIVELORD)



//Fun stuff from Queens
/obj/item/marineResearch/xenomorp/core
	name = "Queen's core"
	desc = "Highly complex and advanced organ, that can be found inside Queen's head"
	icon_state = "core"
	id = list(RESEARCH_XENOSTART, RESEARCH_XENO_BIOLOGY, RESEARCH_XENO_QUEEN)



///// Useful researcher items /////

/obj/item/marineResearch/sampler
	name = "Sampler"
	desc = "Syringe for taking samples"
	icon_state = "1"
	var/filled = 0
	var/obj/item/marineResearch/xenomorp/weed/sample = null

/obj/item/marineResearch/sampler/update_icon()
	switch(filled)
		if(1)
			if(istype(sample, /obj/item/marineResearch/xenomorp/weed/sack))
				icon_state = "3"
				return
			icon_state = "2_trava"
		if(0)
			icon_state = "1"
	return

/obj/item/marineResearch/sampler/attack_self(mob/user as mob)
	if(!filled)
		return
	if(icon_state != "3")
		return

	var/turf/T = user.loc

	if(!istype(T))
		to_chat(user, "<span class='warning'>You can't do that here.</span>")
		return

	if(!T.is_weedable())
		to_chat(user, "<span class='warning'>Bad place to start a garden!</span>")
		return

	if(locate(/obj/effect/alien/weeds/node) in T)
		to_chat(user, "<span class='warning'>There's a sac here already!</span>")
		return

	user.visible_message("[user] planted weed sac on the ground.", "You planted weed sac on the ground.")
	filled = 0
	sample = null
	update_icon()
	new /obj/effect/alien/weeds/node(user.loc, null, null)

/obj/item/bodybag/research
	name = "Hazard-resistant body bag"
	desc = "Special body bag with enormous capacity and highly resistant against hazardous environments"
	unfolded_path = /obj/structure/closet/bodybag/research

/obj/structure/closet/bodybag/research
	name = "Hazard-resistant body bag"
	bag_name = "Hazard-resistant body bag"
	desc = "Special body bag with enormous capacity and highly resistant against hazardous environments"
	storage_capacity = mob_size * MOB_SIZE_BIG
	item_path = /obj/item/bodybag/research

/obj/structure/closet/bodybag/research/can_close()
	for(var/obj/structure/closet/closet in get_turf(src))
		if(closet != src && !closet.wall_mounted)
			return FALSE
	return TRUE

// To be placed in Almayer research
/obj/item/paper/res_note
	name = "Note about equipment"
	info = "Well, I actually managed to add to Requsition our old surplus equipment, such as scanning modules, matter bins, ect. Let's hope those monkeys from Req. will not be greedy enough to NOT give us needed equipment."
