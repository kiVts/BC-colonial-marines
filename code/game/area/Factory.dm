//DeadWood AREAS--------------------------------------//
/area/Factiry
	icon_state = "lv-626"

/area/Factiry/ground
	name = "Ground"
	icon_state = "green"
	always_unpowered = 1 //Will this mess things up? God only knows

//Jungle
/area/Factiry/ground/jungle1
	name ="Southeast Jungle"
	icon_state = "southeast"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/Factiry/ground/jungle2
	name ="Southern Jungle"
	icon_state = "south"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/Factiry/ground/jungle3
	name ="Southwest Jungle"
	icon_state = "southwest"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/Factiry/ground/jungle4
	name ="Western Jungle"
	icon_state = "west"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/Factiry/ground/jungle5
	name ="Eastern Jungle"
	icon_state = "east"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/Factiry/ground/jungle6
	name ="Northwest Jungle"
	icon_state = "northwest"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/Factiry/ground/jungle7
	name ="Northern Jungle"
	icon_state = "north"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/Factiry/ground/jungle8
	name ="Northeast Jungle"
	icon_state = "northeast"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/Factiry/ground/jungle9
	name ="Central Jungle"
	icon_state = "central"
	ambience = list('sound/ambience/jungle_amb1.ogg')

//Sand
/area/Factiry/ground/sand1
	name = "Western Barrens"
	icon_state = "west"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/Factiry/ground/sand2
	name = "Central Barrens"
	icon_state = "red"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/Factiry/ground/sand3
	name = "Eastern Barrens"
	icon_state = "east"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/Factiry/ground/sand4
	name = "North Western Barrens"
	icon_state = "northwest"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/Factiry/ground/sand5
	name = "North Central Barrens"
	icon_state = "blue-red"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/Factiry/ground/sand6
	name = "North Eastern Barrens"
	icon_state = "northeast"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/Factiry/ground/sand7
	name = "South Western Barrens"
	icon_state = "southwest"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/Factiry/ground/sand8
	name = "South Central Barrens"
	icon_state = "away1"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/Factiry/ground/sand9
	name = "South Eastern Barrens"
	icon_state = "southeast"
//	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/Factiry/ground/river1
	name = "Western River"
	icon_state = "blueold"
//	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/Factiry/ground/river2
	name = "Central River"
	icon_state = "purple"
//	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/Factiry/ground/river3
	name = "Eastern River"
	icon_state = "bluenew"
//	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/Factiry/ground/compound
	name = "Weyland Yutani Compound"
	icon_state = "green"

/area/Factiry/ground/compound/ne
	name = "Northeast W-Y Compound"
	icon_state = "northeast"

/area/Factiry/ground/compound/n
	name = "Northern W-Y Compound"
	icon_state = "north"

/area/Factiry/ground/compound/c
	name = "Central W-Y Compound"
	icon_state = "purple"

/area/Factiry/ground/compound/se
	name = "Southeast W-Y Compound"
	icon_state = "southeast"

/area/Factiry/ground/compound/sw
	name = "Southwest W-Y Compound"
	icon_state = "southwest"

//	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/Factiry/ground/caves //Does not actually exist
	name ="Caves"
	icon_state = "cave"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambisin4.ogg')
	ceiling = CEILING_DEEP_UNDERGROUND

//Caves
/area/Factiry/ground/caves/west1
	name ="Western Caves"
	icon_state = "away1"

/area/Factiry/ground/caves/east1
	name ="Eastern Caves"
	icon_state = "away"

/area/Factiry/ground/caves/central1
	name ="Central Caves"
	icon_state = "away4" //meh

/area/Factiry/ground/caves/west2
	name ="North Western Caves"
	icon_state = "cave"

/area/Factiry/ground/caves/east2
	name ="North Eastern Caves"
	icon_state = "cave"

/area/Factiry/ground/caves/central2
	name ="North Central Caves"
	icon_state = "away3" //meh

/area/Factiry/ground/caves/central3
	name ="South Central Caves"
	icon_state = "away2" //meh

//DeadWood landing
/area/Factiry/lazarus
	name = "Lazarus"
	icon_state = "green"
	ceiling = CEILING_METAL

/area/Factiry/lazarus/atmos
	name = "Atmospherics"
	icon_state = "atmos"
	ceiling = CEILING_GLASS

/area/Factiry/lazarus/atmos/outside
	name = "Atmospherics Area"
	icon_state = "purple"
	ceiling = CEILING_NONE

/area/Factiry/lazarus/hallway_one
	name = "Hallway"
	icon_state = "green"
	can_hellhound_enter = 0

/area/Factiry/lazarus/hallway_two
	name = "Hallway"
	icon_state = "purple"
	can_hellhound_enter = 0

/area/Factiry/lazarus/medbay
	name = "Medbay"
	icon_state = "medbay"

/area/Factiry/lazarus/armory
	name = "Armory"
	icon_state = "armory"

/area/Factiry/lazarus/security
	name = "Security"
	icon_state = "security"
	can_hellhound_enter = 0

/area/Factiry/lazarus/captain
	name = "Commandant's Quarters"
	icon_state = "captain"
	can_hellhound_enter = 0

/area/Factiry/lazarus/hop
	name = "Head of Personnel's Office"
	icon_state = "head_quarters"
	can_hellhound_enter = 0

/area/Factiry/lazarus/kitchen
	name = "Kitchen"
	icon_state = "kitchen"
	can_hellhound_enter = 0

/area/Factiry/lazarus/canteen
	name = "Canteen"
	icon_state = "cafeteria"
	can_hellhound_enter = 0

/area/Factiry/lazarus/main_hall
	name = "Main Hallway"
	icon_state = "hallC1"
	can_hellhound_enter = 0

/area/Factiry/lazarus/main_hall
	name = "Main Hallway"
	icon_state = "hallC1"
	can_hellhound_enter = 0

/area/Factiry/lazarus/toilet
	name = "Dormitory Toilet"
	icon_state = "toilet"
	can_hellhound_enter = 0

/area/Factiry/lazarus/chapel
	name = "Chapel"
	icon_state = "chapel"
	ambience = list('sound/ambience/ambicha1.ogg','sound/ambience/ambicha2.ogg','sound/ambience/ambicha3.ogg','sound/ambience/ambicha4.ogg')
	can_hellhound_enter = 0

/area/Factiry/lazarus/toilet
	name = "Dormitory Toilet"
	icon_state = "toilet"
	can_hellhound_enter = 0

/area/Factiry/lazarus/sleep_male
	name = "Male Dorm"
	icon_state = "Sleep"
	can_hellhound_enter = 0

/area/Factiry/lazarus/sleep_female
	name = "Female Dorm"
	icon_state = "Sleep"
	can_hellhound_enter = 0

/area/Factiry/lazarus/quart
	name = "Quartermasters"
	icon_state = "quart"
	can_hellhound_enter = 0

/area/Factiry/lazarus/quartstorage
	name = "Cargo Bay"
	icon_state = "quartstorage"
	can_hellhound_enter = 0

/area/Factiry/lazarus/quartstorage/outdoors
	name = "Cargo Bay Area"
	icon_state = "purple"
	ceiling = CEILING_NONE

/area/Factiry/lazarus/engineering
	name = "Engineering"
	icon_state = "engine_smes"

/area/Factiry/lazarus/comms
	name = "Communications Relay"
	icon_state = "tcomsatcham"

/area/Factiry/lazarus/secure_storage
	name = "Secure Storage"
	icon_state = "storage"

/area/Factiry/lazarus/internal_affairs
	name = "Internal Affairs"
	icon_state = "law"

/area/Factiry/lazarus/robotics
	name = "Robotics"
	icon_state = "ass_line"

/area/Factiry/lazarus/research
	name = "Research Lab"
	icon_state = "toxlab"

/area/Factiry/lazarus/fitness
	name = "Fitness Room"
	icon_state = "fitness"

/area/Factiry/lazarus/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"
	ceiling = CEILING_GLASS

/area/Factiry/lazarus/relay
	name = "Secret Relay Room"
	icon_state = "tcomsatcham"

/area/Factiry/lazarus/console
	name = "Shuttle Console"
	icon_state = "tcomsatcham"
