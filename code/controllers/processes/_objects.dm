datum/controller/process/objects

datum/controller/process/objects/setup()
	name = "Objects"
	schedule_interval = 23 //2.3 seconds

	to_chat(world, "<span style='color:#FF0000'>\b Initializing objects</span>")
	sleep(-1)
	for(var/atom/movable/object in world)
		object.initialize()

datum/controller/process/objects/doWork()

	var/i = 1
	while(i<=processing_objects.len)
		var/obj/Object = processing_objects[i]
		if(Object)
			Object.process()
			i++
			continue
		processing_objects.Cut(i,i+1)