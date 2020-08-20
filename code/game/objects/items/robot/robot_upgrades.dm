// robot_upgrades.dm
// Contains various borg upgrades.

/obj/item/robot/upgrade
	name = "borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/items/circuitboards.dmi'
	icon_state = "cyborg_upgrade"
	var/construction_time = 120
	var/construction_cost = list("metal"=10000)
	var/locked = 0
	var/require_module = 0
	var/installed = 0

/obj/item/robot/upgrade/proc/action(var/mob/living/silicon/robot/R)
	if(R.stat == DEAD)
		to_chat(usr, "<span style='color:#FF0000'>The [src] will not function on a deceased robot.</span>")
		return 1
	return 0


/obj/item/robot/upgrade/reset
	name = "robotic module reset board"
	desc = "Used to reset a cyborg's module. Destroys any other upgrades applied to the robot."
	icon_state = "cyborg_upgrade1"
	require_module = 1

/obj/item/robot/upgrade/reset/action(var/mob/living/silicon/robot/R)
	if(..()) return 0
	R.uneq_all()
	R.hands.icon_state = "nomod"
	R.icon_state = "robot"
	cdel(R.module)
	R.module = null
	R.camera.network.Remove(list("Engineering","Medical","MINE"))
	R.updatename("Default")
	R.status_flags |= CANPUSH
	R.update_icons()

	return 1

/obj/item/robot/upgrade/rename
	name = "robot reclassification board"
	desc = "Used to rename a cyborg."
	icon_state = "cyborg_upgrade1"
	construction_cost = list("metal"=35000)
	var/heldname = "default name"

/obj/item/robot/upgrade/rename/attack_self(mob/user as mob)
	heldname = stripped_input(user, "Enter new robot name", "Robot Reclassification", heldname, MAX_NAME_LEN)

/obj/item/robot/upgrade/rename/action(var/mob/living/silicon/robot/R)
	if(..()) return 0
	R.name = heldname
	R.custom_name = heldname
	R.real_name = heldname

	return 1

/obj/item/robot/upgrade/restart
	name = "robot emergency restart module"
	desc = "Used to force a restart of a disabled-but-repaired robot, bringing it back online."
	construction_cost = list("metal"=60000 , "glass"=5000)
	icon_state = "cyborg_upgrade1"


/obj/item/robot/upgrade/restart/action(var/mob/living/silicon/robot/R)
	if(R.health < 0)
		to_chat(usr, "You have to repair the robot before using this module!")
		return 0

	if(!R.key)
		for(var/mob/dead/observer/ghost in player_list)
			if(ghost.mind && ghost.mind.current == R)
				R.key = ghost.key
				if(R.client) R.client.change_view(world.view)
				break

	R.stat = CONSCIOUS
	return 1


/obj/item/robot/upgrade/vtec
	name = "robotic VTEC Module"
	desc = "Used to kick in a robot's VTEC systems, increasing their speed."
	construction_cost = list("metal"=80000 , "glass"=6000 , "gold"= 5000)
	icon_state = "cyborg_upgrade2"
	require_module = 1

/obj/item/robot/upgrade/vtec/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(R.speed == -1)
		return 0

	R.speed--
	return 1


/obj/item/robot/upgrade/tasercooler
	name = "robotic Rapid Taser Cooling Module"
	desc = "Used to cool a mounted taser, increasing the potential current in it and thus its recharge rate."
	construction_cost = list("metal"=80000 , "glass"=6000 , "gold"= 2000, "diamond" = 500)
	icon_state = "cyborg_upgrade3"
	require_module = 1


/obj/item/robot/upgrade/tasercooler/action(var/mob/living/silicon/robot/R)
	if(..()) return 0
/*

	if(!istype(R.module, /obj/item/circuitboard/robot_module/security))
		to_chat(R, "Upgrade mounting error!  No suitable hardpoint detected!")
		to_chat(usr, "There's no mounting point for the module!")
		return 0

	var/obj/item/weapon/gun/energy/taser/cyborg/T = locate() in R.module
	if(!T)
		T = locate() in R.module.contents
	if(!T)
		T = locate() in R.module.modules
	if(!T)
		to_chat(usr, "This robot has had its taser removed!")
		return 0

	if(T.recharge_time <= 2)
		to_chat(R, "Maximum cooling achieved for this hardpoint!")
		to_chat(usr, "There's no room for another cooling unit!")
		return 0

	else
		T.recharge_time = max(2 , T.recharge_time - 4)
*/
	return 1

/obj/item/robot/upgrade/jetpack
	name = "mining robot jetpack"
	desc = "A carbon dioxide jetpack suitable for low-gravity mining operations."
	construction_cost = list("metal"=10000,"phoron"=15000,"uranium" = 20000)
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/robot/upgrade/jetpack/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	R.module.modules += new/obj/item/tank/jetpack/carbondioxide
	for(var/obj/item/tank/jetpack/carbondioxide in R.module.modules)
		R.internal = src
	//R.icon_state="Miner+j"
	return 1


/obj/item/robot/upgrade/syndicate/
	name = "illegal equipment module"
	desc = "Unlocks the hidden, deadlier functions of a robot"
	construction_cost = list("metal"=10000,"glass"=15000,"diamond" = 10000)
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/robot/upgrade/syndicate/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(R.emagged == 1)
		return 0

	R.emagged = 1
	return 1
