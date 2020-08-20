// Sell costs are just ballpark numbers right now, can be changed later.

/datum/supply_export
	var/cost = null
	var/export_obj = null

/datum/supply_export/xemomorph
	cost = 0
	export_obj = /mob/living/carbon/Xenomorph


/datum/supply_export/xemomorph/larva
	cost = 10
	export_obj = /mob/living/carbon/Xenomorph/Larva


/datum/supply_export/xemomorph/drone
	cost = 20
	export_obj = /mob/living/carbon/Xenomorph/Drone

/datum/supply_export/xemomorph/runner
	cost = 15
	export_obj = /mob/living/carbon/Xenomorph/Runner

/datum/supply_export/xemomorph/defender
	cost = 25
	export_obj = /mob/living/carbon/Xenomorph/Defender

/datum/supply_export/xemomorph/sentinel
	cost = 30
	export_obj = /mob/living/carbon/Xenomorph/Sentinel


/datum/supply_export/xemomorph/carrier
	cost = 35
	export_obj = /mob/living/carbon/Xenomorph/Carrier

/datum/supply_export/xemomorph/hivelord
	cost = 35
	export_obj = /mob/living/carbon/Xenomorph/Hivelord

/datum/supply_export/xemomorph/lurker
	cost = 30
	export_obj = /mob/living/carbon/Xenomorph/Lurker

/datum/supply_export/xemomorph/warrior
	cost = 45
	export_obj = /mob/living/carbon/Xenomorph/Warrior

/datum/supply_export/xemomorph/spitter
	cost = 45
	export_obj = /mob/living/carbon/Xenomorph/Spitter


/datum/supply_export/xemomorph/praetorian
	cost = 50
	export_obj = /mob/living/carbon/Xenomorph/Praetorian

/datum/supply_export/xemomorph/crusher
	cost = 75
	export_obj = /mob/living/carbon/Xenomorph/Crusher

/datum/supply_export/xemomorph/ravager
	cost = 80
	export_obj = /mob/living/carbon/Xenomorph/Ravager

/datum/supply_export/xemomorph/boiler
	cost = 95
	export_obj = /mob/living/carbon/Xenomorph/Boiler


/datum/supply_export/xemomorph/queen
	cost = 300
	export_obj = /mob/living/carbon/Xenomorph/Queen