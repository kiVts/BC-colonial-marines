#define MEMOFILE "data/memo.sav"	//where the memos are saved
#define ENABLE_MEMOS 1				//using a define because screw making a config variable for it. This is more efficient and purty.
#define FANFACTFILE "data/fanfact.sav"	//where the memos are saved
#define ENABLE_FANFACTS 1				//using a define because screw making a config variable for it. This is more efficient and purty.


//switch verb so we don't spam up the verb lists with like, 3 verbs for this feature.
/client/proc/admin_memo(task in list("write","show","delete"))
	set name = "Memo"
	set category = "Server"
	if(!ENABLE_MEMOS)		return
	if(!check_rights(0))	return
	switch(task)
		if("write")		admin_memo_write()
		if("show")		admin_memo_show()
		if("delete")	admin_memo_delete()

//write a message
/client/proc/admin_memo_write()
	var/savefile/F = new(MEMOFILE)
	if(F)
		var/memo = input(src,"Type your memo\n(Leaving it blank will delete your current memo):","Write Memo",null) as null|message
		switch(memo)
			if(null)
				return
			if("")
				F.dir.Remove(ckey)
				to_chat(src, "<b>Memo removed</b>")
				return
		if( findtext(memo,"<script",1,0) )
			return
		F[ckey] << "[key] on [time2text(world.realtime,"(DDD) DD MMM hh:mm")]<br>[memo]"
		message_admins("[key] set an admin memo:<br>[memo]")

//show all memos
/client/proc/admin_memo_show()
	if(ENABLE_MEMOS)
		var/savefile/F = new(MEMOFILE)
		if(F)
			for(var/ckey in F.dir)
				to_chat(src, "<center><span class='motd'><b>Admin Memo</b><i> by [F[ckey]]</i></span></center>")

//delete your own or somebody else's memo
/client/proc/admin_memo_delete()
	var/savefile/F = new(MEMOFILE)
	if(F)
		var/ckey
		if(check_rights(R_SERVER,0))	//high ranking admins can delete other admin's memos
			ckey = input(src,"Whose memo shall we remove?","Remove Memo",null) as null|anything in F.dir
		else
			ckey = src.ckey
		if(ckey)
			F.dir.Remove(ckey)
			to_chat(src, "<b>Removed Memo created by [ckey].</b>")



//switch verb so we don't spam up the verb lists with like, 3 verbs for this feature.
/client/proc/create_admin_fan_fact(task in list("write","show","delete"))
	set category = "Fun"
	set name = "Set Fun Fact"
	set desc = "Set message for end round (one please)."
	if(!ENABLE_FANFACTS)		return
	if(!check_rights(0))	return
	switch(task)
		if("write")		admin_fan_fact_write()
		if("show")		admin_fan_fact_show()
		if("delete")	admin_fan_fact_delete()

//write a message
/client/proc/admin_fan_fact_write()
	var/savefile/F = new(FANFACTFILE)
	if(F)
		var/fanfact = input(src,"Type your Fan Fact\n(Leaving it blank will delete your current Fan Fact):","Write Fan Fact",null) as null|message
		switch(fanfact)
			if(null)
				return
			if("")
				F.dir.Remove(ckey)
				to_chat(src, "<b>Fan Fact removed</b>")
				return
		if( findtext(fanfact,"<script",1,0) )
			return
		F[ckey] << "[key] on [time2text(world.realtime,"(DDD) DD MMM hh:mm")]<br>[fanfact]"
		message_admins("[key] set an admin Fan fact:<br>[fanfact]")

//show all memos
/client/proc/admin_fan_fact_show()
	if(ENABLE_FANFACTS)
		var/savefile/F = new(FANFACTFILE)
		if(F)
			for(var/ckey in F.dir)
				to_chat(src, "<center><span class='motd'><i>[F]</i></span></center>")

//delete your own or somebody else's memo
/client/proc/admin_fan_fact_delete()
	var/savefile/F = new(FANFACTFILE)
	if(F)
		var/ckey
		if(check_rights(R_SERVER,0))	//high ranking admins can delete other admin's memos
			ckey = input(src,"Whose Fan Fact shall we remove?","Remove Fan Fact",null) as null|anything in F.dir
		else
			ckey = src.ckey
		if(ckey)
			F.dir.Remove(ckey)
			to_chat(src, "<b>Removed Fan Fact created by [ckey].</b>")


#undef FANFACTFILE
#undef ENABLE_FANFACTS
#undef MEMOFILE
#undef ENABLE_MEMOS