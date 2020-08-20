/obj/item/map
	name = "map"
	var/serial_number = 0
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "map"
	item_state = "map"
	throw_speed = 1
	throw_range = 5
	w_class = 1
	// color = ... (Colors can be names - "red, green, grey, cyan" or a HEX color code "#FF0000")
	var/dat        // Page content
	var/html_link = ""
	var/window_size = "1280x720"

/obj/item/map/New(turf/loc, var/given_serial = 0)
	if(given_serial == 0)
		serial_number = rand(1, 3589217554)
	else
		serial_number = given_serial
	desc += " Серийный номер [serial_number]"
	..(loc)

/obj/item/map/attack_self(var/mob/usr as mob) //Open the map
	usr.visible_message("<span class='notice'>[usr] открыл [src.name]. </span>")
	initialize_map()

// /obj/item/map/attack(mob/living/carbon/human/M as mob, mob/living/carbon/human/usr as mob) //Show someone the map by hitting them with it
//     usr.visible_message("<span class='notice'>You open up the [name] and show it to [M]. </span>", \
//         "<span class='notice'>[usr] opens up the [name] and shows it to \the [M]. </span>")
//     to_chat(M, initialize_map())
/obj/item/map/attack()
	return

/obj/item/map/proc/initialize_map()
	var/wikiurl = config.wikiurl
	if(wikiurl)
		dat = {"

			<html><head>
			<style>
				iframe {
					display: none;
				}
			</style>
			</head>
			<body>
			<script type="text/javascript">
				function pageloaded(myframe) {
					document.getElementById("loading").style.display = "none";
					myframe.style.display = "inline";
    			}
			</script>
			<p id='loading'>You start unfolding the map...</p>
			<iframe width='100%' height='97%' onload="pageloaded(this)" src="https://cm-ss13.com/wiki/[html_link]?printable=yes&remove_links=1" frameborder="0" id="main_frame"></iframe>
			</body>

			</html>

			"}
	usr << browse("[dat]", "window=map;size=[window_size]")//[wikiurl] (https://cm-ss13.com/wiki/)

/obj/item/map/lazarus_landing_map
	name = "Lazarus Landing Map"
	desc = "A satellite printout of the Lazarus Landing colony on LV-624."
	html_link = "images/6/6f/LV624.png"

/obj/item/map/ice_colony_map
	name = "Ice Colony Map"
	desc = "A satellite printout of the Ice Colony."
	html_link = "images/1/18/Map_icecolony.png"
	color = "cyan"

/obj/item/map/whiskey_outpost_map
	name = "Whiskey Outpost Map"
	desc = "A tactical printout of the Whiskey Outpost defensive positions and locations."
	html_link = "images/7/78/Whiskey_outpost.png"
	color = "grey"

/obj/item/map/big_red_map
	name = "Solaris Ridge Map"
	desc = "A censored blueprint of the Solaris Ridge facility."
	html_link = "images/9/9e/Solaris_Ridge.png"
	color = "#e88a10"

/obj/item/map/FOP_map
	name = "Fiorina Orbital Penitentiary Map"
	desc = "A labelled interior scan of Fiorina Orbital Penitentiary."
	html_link = "images/4/4c/Map_Prison.png"
	color = "#e88a10"

/obj/item/map/desert_dam_map
	name = "Desert Dam Map"
	desc = "A satellite printout of the Desert Dam."
	html_link = "images/9/92/Desert_Dam.png"
	color = "#e88a10"

/obj/item/map/decalm_slay_map
	name = "Decalm Slay Map"
	desc = "A satellite printout of the Decalm Slay."
	html_link = "images/Decalm_Slay.png"//6/6c
	color = "grey"

/obj/item/map/secret_object_map
	name = "Very Secret Object Map"
	desc = "A unltimate center."
	html_link = "images/Secret_Object.png"//8/8c
	color = "#e88a10"

/obj/item/map/dead_wood_map
	name = "Dead Wood Map"
	desc = "A satellite printout of the Dead Wood."
	html_link = "images/Dead_Wood.png"//7/7c
	color = "red"

//used by marine equipment machines to spawn the correct map.
/obj/item/map/current_map

/obj/item/map/current_map/New()
	..()
	if(!map_tag)
		cdel(src)
		return
	switch(map_tag)
		if(MAP_LV_624)
			name = "Lazarus Landing Map"
			desc = "A satellite printout of the Lazarus Landing colony on LV-624."
			html_link = "images/6/6f/LV624.png"
		if(MAP_ICE_COLONY)
			name = "Ice Colony Map"
			desc = "A satellite printout of the Ice Colony."
			html_link = "images/1/18/Map_icecolony.png"
			color = "cyan"
		if(MAP_BIG_RED)
			name = "Solaris Ridge Map"
			desc = "A censored blueprint of the Solaris Ridge facility."
			html_link = "images/9/9e/Solaris_Ridge.png"
			color = "#e88a10"
		if(MAP_PRISON_STATION)
			name = "Fiorina Orbital Penitentiary Map"
			desc = "A labelled interior scan of Fiorina Orbital Penitentiary."
			html_link = "images/4/4c/Map_Prison.png"
			color = "#e88a10"
		if(MAP_DESERT_DAM)
			name = "Desert Dam Map"
			desc = "A satellite printout of the Desert Dam."
			html_link = "images/9/92/Trijent_Dam.png"
			color = "#e88a10"
		if(MAP_DECALM_SLAY)
			name = "Decalm Slay Map"
			desc = "A satellite printout of the Decalm Slay."
			html_link = "images/Decalm_Slay.png"//6/6c
			color = "#e88a10"
		if(MAP_SECRET_OBJECT)
			name = "Very Secret Object Map"
			desc = "A unltimate center."
			html_link = "images/Secret_Object.png"//8/8c
		if(MAP_DEAD_WOOD)
			name = "Dead Wood Map"
			desc = "A satellite printout of the Dead Wood."
			html_link = "images/Dead_Wood.png"//7/7c
			color = "red"
		else
			cdel(src)


// Landmark - Used for mapping. Will spawn the appropriate map for each gamemode (LV map items will spawn when LV is the gamemode, etc)
/obj/effect/landmark/map_item
	name = "map item"
