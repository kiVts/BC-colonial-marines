// ***************************************
// *********** Misc Xenos
// ***************************************
/datum/hive_status/alpha
	hivenumber = XENO_HIVE_ALPHA
	prefix = "Alpha "
	color = "#cccc00"

/mob/living/carbon/Xenomorph/Queen/Alpha
	hivenumber = XENO_HIVE_ALPHA

/datum/hive_status/beta
	hivenumber = XENO_HIVE_BETA
	prefix = "Beta "
	color = "#9999ff"

/mob/living/carbon/Xenomorph/Queen/Beta
	hivenumber = XENO_HIVE_BETA

/datum/hive_status/zeta
	hivenumber = XENO_HIVE_ZETA
	prefix = "Zeta "
	color = "#606060"

/mob/living/carbon/Xenomorph/Queen/Zeta
	hivenumber = XENO_HIVE_ZETA

// ***************************************
// *********** Xeno hive compare helpers
// ***************************************

// Everything below can have a hivenumber set and these ensure easy hive comparisons can be made

// atom level because of /obj/item/projectile/var/atom/firer
/atom/proc/issamexenohive(atom/A)
	if(!get_xeno_hivenumber() || !A?.get_xeno_hivenumber())
		return FALSE
	return get_xeno_hivenumber() == A.get_xeno_hivenumber()

/atom/proc/get_xeno_hivenumber()
	return FALSE

/obj/effect/alien/egg/get_xeno_hivenumber()
	return hivenumber

/obj/item/xeno_egg/get_xeno_hivenumber()
	return hivenumber

/obj/item/alien_embryo/get_xeno_hivenumber()
	return hivenumber

/obj/item/clothing/mask/facehugger/get_xeno_hivenumber()
	return hivenumber

/mob/living/carbon/Xenomorph/get_xeno_hivenumber()
	return hivenumber
