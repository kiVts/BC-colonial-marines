
/mob/living/carbon/Xenomorph/proc/upgrade_xeno(newlevel)
	upgrade = newlevel
	upgrade_stored = 0
	visible_message("<span class='xenonotice'>\The [src] чинает извиваться и корчиться.</span>", \
	"<span class='xenonotice'>Вы начинаете извиваться и корчиться.</span>")
	xeno_jitter(25)
	sleep(25)

/*
*1 is indicative of the base speed/armor
ARMOR
UPGRADE		*1 	 2	 3	 4	 5
------------------------------
Runner		0	5	10	10	20
Hunter		15	20	25	25	30
Ravager		40	45	50	50	55
Defender	50	55	60	70	75
Warrior		30	35	40	45	50
Crusher		60	65	70	75	80
Sentinel	15	15	20	20	25
Spitter		15	20	25	30	35
Boiler		20	30	35	35	40
Praetorian	35	40	45	50	55
Drone		0	5	10	15	20
Burrower	0	10	15	20	25
Hivelord	0	10	15	20	25
Carrier		0	10	10	15	20
Queen		45	50	55	55	80

SPEED
UPGRADE		5 		4		 3		 2		 *1
------------------------------------------------
Runner		-2.3	-2.1	-2.0	-1.9	-1.8
Hunter		-1.9	-1.8	-1.7	-1.6	-1.5
Ravager		-1.2	-1.0	-0.9	-0.8	-0.7
Defender	-1.0	-0.5	-0.4	-0.3	-0.2
Warrior		-1.0	-0.5	-0.6	-0.7	-0.8
Crusher		 0.1	 0.1	 0.1	 0.1	 0.1	*-2.0 when charging
Sentinel	-1.2	-1.1	-1.0	-0.9	-0.8
Spitter		-0.9	-0.8	-0.7	-0.6	-0.5
Boiler		 0.3	 0.4	 0.5	 0.6	 0.7
Praetorian	-0.9	-0.8	-0.7	-0.6	-0.5
Drone		-1.2	-1.1	-1.0	-0.9	-0.8
Burrower	 0.0	 0.1	 0.2	 0.3	 0.4
Hivelord	 0.0	 0.1	 0.2	 0.3	 0.4
Carrier		-0.4	-0.3	-0.2	-0.1	 0.0
Queen		-0.1	 0.0	 0.1	 0.2	 0.3
*/

	switch(upgrade)
		//FIRST UPGRADE
		if(1)
			upgrade_name = "Mature"
			to_chat(src, "<span class='xenodanger'>Ты чувствуешь себя немного сильнее.</span>")
			switch(caste)
				if("Runner")
					melee_damage_lower = 15
					melee_damage_upper = 25
					health = 120
					maxHealth = 120
					plasma_gain = 2
					plasma_max = 150
					upgrade_threshold = 200
					caste_desc = "Быстрый, четвероногий ужас, но слабый в длительном бою. Это выглядит немного более опасным."
					speed = -1.9
					armor_deflection = 5
					attack_delay = -4
					tacklemin = 2
					tacklemax = 4
					tackle_chance = 50
					pounce_delay = 35
				if("Lurker")
					melee_damage_lower = 25
					melee_damage_upper = 35
					health = 170
					maxHealth = 170
					plasma_gain = 10
					plasma_max = 150
					upgrade_threshold = 800
					caste_desc = "Быстрый, мощный фронтовой боец. Это выглядит немного более опасным."
					speed = -1.6
					armor_deflection = 20
					attack_delay = -2
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 60
					pounce_delay = 50
				if("Ravager")
					melee_damage_lower = 50
					melee_damage_upper = 70
					health = 220
					maxHealth = 220
					plasma_gain = 10
					plasma_max = 150
					upgrade_threshold = 800
					caste_desc = "Жестокий, разрушительный нападающий на передовой. Это выглядит немного более опасным."
					speed = -0.8
					armor_deflection = 45
					tacklemin = 4
					tacklemax = 5
					tackle_chance = 75
				if ("Defender")
					melee_damage_lower = 20
					melee_damage_upper = 30
					health = 275
					maxHealth = 275
					plasma_gain = 8
					plasma_max = 100
					upgrade_threshold = 200
					caste_desc = "Инопланетянин с бронированным гребнем на голове. Это выглядит немного более опасным."
					speed = -0.3
					armor_deflection = 45
				if ("Warrior")
					melee_damage_lower = 35
					melee_damage_upper = 40
					health = 225
					maxHealth = 225
					plasma_gain = 8
					plasma_max = 100
					upgrade_threshold = 400
					caste_desc = "Инопланетянин в бронированном панцире. Это выглядит немного более опасным."
					speed = -0.9
					armor_deflection = 35
				if("Crusher")
					melee_damage_lower = 20
					melee_damage_upper = 35
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 65
					health = 325
					maxHealth = 325
					plasma_gain = 15
					plasma_max = 300
					upgrade_threshold = 800
					caste_desc = "Огромный танковый ксеноморф. Это выглядит немного более опасным."
					armor_deflection = 80
				if("Sentinel")
					melee_damage_lower = 15
					melee_damage_upper = 25
					health = 150
					maxHealth = 150
					plasma_gain = 12
					plasma_max = 400
					upgrade_threshold = 200
					spit_delay = 35
					caste_desc = "Боевой инопланетянин дальнего боя. Это выглядит немного более опасным."
					armor_deflection = 15
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 60
					speed = -0.9
				if("Spitter")
					melee_damage_lower = 20
					melee_damage_upper = 30
					health = 180
					maxHealth = 180
					plasma_gain = 25
					plasma_max = 700
					upgrade_threshold = 400
					spit_delay = 20
					caste_desc = "Лидер дальнобойных повреждений. Это выглядит немного более опасным."
					armor_deflection = 20
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 60
					speed = -0.6
				if("Boiler")
					melee_damage_lower = 20
					melee_damage_upper = 25
					health = 200
					maxHealth = 200
					plasma_gain = 35
					plasma_max = 900
					upgrade_threshold = 800
					spit_delay = 30
					bomb_strength = 1.5
					caste_desc = "Какая-то мерзость. Это выглядит немного более опасным."
					armor_deflection = 30
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 65
					speed = 0.6
				if("Praetorian")
					melee_damage_lower = 20
					melee_damage_upper = 30
					health = 220
					maxHealth = 220
					plasma_gain = 30
					plasma_max = 900
					upgrade_threshold = 800
					spit_delay = 15
					caste_desc = "Гигантский монстр заколебался. Это выглядит немного более опасным."
					armor_deflection = 40
					tacklemin = 5
					tacklemax = 8
					tackle_chance = 75
					speed = 0.0
					aura_strength = 2.5
				if("Drone")
					melee_damage_lower = 12
					melee_damage_upper = 16
					health = 120
					maxHealth = 120
					plasma_max = 800
					plasma_gain = 20
					upgrade_threshold = 500
					caste_desc = "Рабочая лошадка улья. Это выглядит немного более опасным."
					armor_deflection = 5
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 60
					speed = -0.9
					aura_strength = 1
				if("Burrower")
					melee_damage_lower = 25
					melee_damage_upper = 35
					health = 220
					maxHealth = 220
					plasma_max = 900
					plasma_gain = 40
					upgrade_threshold = 800
					caste_desc = "Строитель больших ульев. Это выглядит немного более опасным."
					armor_deflection = 10
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 60
					speed = 0.3
					aura_strength = 1.5
				if("Hivelord")
					melee_damage_lower = 15
					melee_damage_upper = 20
					health = 220
					maxHealth = 220
					plasma_max = 900
					plasma_gain = 40
					upgrade_threshold = 800
					caste_desc = "Строитель действительно больших ульев. Это выглядит немного более опасным."
					armor_deflection = 10
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 60
					speed = 0.3
					aura_strength = 1.5
				if("Carrier")
					melee_damage_lower = 25
					melee_damage_upper = 35
					health = 200
					maxHealth = 200
					plasma_max = 300
					plasma_gain = 10
					upgrade_threshold = 800
					caste_desc = "Портативный транспорт любви. Это выглядит немного более опасным."
					armor_deflection = 10
					tacklemin = 3
					tacklemax = 4
					tackle_chance = 60
					speed = -0.1
					aura_strength = 1.5
					var/mob/living/carbon/Xenomorph/Carrier/CA = src
					CA.huggers_max = 9
					CA.hugger_delay = 30
					CA.eggs_max = 4
				if("Queen")
					melee_damage_lower = 40
					melee_damage_upper = 50
					health = 400
					maxHealth = 400
					plasma_max = 1000
					plasma_gain = 50
					upgrade_threshold = 1600
					spit_delay = 20
					caste_desc = "Самый большой и самый плохой ксенон. Королева контролирует улей и создаёт яица."
					armor_deflection = 50
					tacklemin = 5
					tacklemax = 7
					tackle_chance = 85
					speed = 2
					aura_strength = 5
					queen_leader_limit = 2

		//SECOND UPGRADE
		if(2)
			upgrade_name = "Elder"
			to_chat(src, "<span class='xenodanger'>Ты чувствуешь себя намного сильнее.</span>")
			switch(caste)
				if("Runner")
					melee_damage_lower = 20
					melee_damage_upper = 30
					health = 150
					maxHealth = 150
					plasma_gain = 2
					plasma_max = 200
					upgrade_threshold = 400
					caste_desc = "Быстрый, четвероногий ужас, но слабый в длительном бою. Выглядит довольно крепко."
					speed = -2.0
					armor_deflection = 10
					attack_delay = -4
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 60
					pounce_delay = 30
				if("Lurker")
					melee_damage_lower = 35
					melee_damage_upper = 50
					health = 200
					maxHealth = 200
					plasma_gain = 10
					plasma_max = 200
					upgrade_threshold = 1600
					caste_desc = "Быстрый, мощный фронтовой боец. Выглядит довольно крепко."
					speed = -1.7
					armor_deflection = 25
					attack_delay = -3
					tacklemin = 4
					tacklemax = 6
					tackle_chance = 65
					pounce_delay = 45
				if("Ravager")
					melee_damage_lower = 60
					melee_damage_upper = 80
					health = 250
					maxHealth = 250
					plasma_gain = 15
					plasma_max = 200
					upgrade_threshold = 1600
					caste_desc = "Жестокий, разрушительный нападающий на передовой. Выглядит довольно крепко."
					speed = -0.9
					armor_deflection = 50
					tacklemin = 5
					tacklemax = 7
					tackle_chance = 80
				if ("Defender")
					melee_damage_lower = 25
					melee_damage_upper = 35
					health = 300
					maxHealth = 300
					plasma_gain = 8
					plasma_max = 100
					upgrade_threshold = 400
					caste_desc = "Инопланетянин с бронированным гребнем на голове. Выглядит довольно крепко."
					speed = -0.4
					armor_deflection = 50
				if ("Warrior")
					melee_damage_lower = 40
					melee_damage_upper = 45
					health = 250
					maxHealth = 250
					plasma_gain = 8
					plasma_max = 100
					upgrade_threshold = 800
					caste_desc = "Инопланетянин в бронированном панцире. Выглядит довольно крепко."
					speed = -1.0
					armor_deflection = 40
				if("Crusher")
					melee_damage_lower = 35
					melee_damage_upper = 45
					tacklemin = 4
					tacklemax = 6
					tackle_chance = 75
					health = 375
					maxHealth = 375
					plasma_gain = 30
					plasma_max = 400
					upgrade_threshold = 1600
					caste_desc = "Огромный танковый ксеноморф. Выглядит довольно крепко."
					armor_deflection = 85
				if("Sentinel")
					melee_damage_lower = 20
					melee_damage_upper = 30
					health = 175
					maxHealth = 175
					plasma_gain = 15
					plasma_max = 500
					upgrade_threshold = 400
					spit_delay = 25
					caste_desc = "Боевой инопланетянин дальнего боя. Выглядит довольно крепко."
					armor_deflection = 20
					tacklemin = 4
					tacklemax = 6
					tackle_chance = 60
					speed = -1.0
				if("Spitter")
					melee_damage_lower = 25
					melee_damage_upper = 35
					health = 200
					maxHealth = 200
					plasma_gain = 30
					plasma_max = 800
					upgrade_threshold = 800
					spit_delay = 15
					caste_desc = "Дилер дальнобойных повреждений. Выглядит довольно крепко."
					armor_deflection = 25
					tacklemin = 4
					tacklemax = 6
					tackle_chance = 70
					speed = -0.7
				if("Boiler")
					melee_damage_lower = 30
					melee_damage_upper = 35
					health = 220
					maxHealth = 220
					plasma_gain = 40
					plasma_max = 1000
					upgrade_threshold = 1600
					spit_delay = 20
					bomb_strength = 2
					caste_desc = "Какая-то мерзость. Выглядит довольно крепко."
					armor_deflection = 35
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 70
					speed = 0.5
				if("Praetorian")
					melee_damage_lower = 30
					melee_damage_upper = 35
					health = 250
					maxHealth = 250
					plasma_gain = 40
					plasma_max = 1000
					upgrade_threshold = 1600
					spit_delay = 10
					caste_desc = "Гигантский монстр заколебался. Выглядит довольно крепко."
					armor_deflection = 45
					tacklemin = 6
					tacklemax = 9
					tackle_chance = 80
					speed = -0.1
					aura_strength = 3.5
				if("Drone")
					melee_damage_lower = 12
					melee_damage_upper = 16
					health = 150
					maxHealth = 150
					plasma_max = 900
					plasma_gain = 30
					upgrade_threshold = 600
					caste_desc = "Рабочая лошадка улья. Это выглядит немного более опасным."
					armor_deflection = 10
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 60
					speed = -1.0
					aura_strength = 1.5
				if("Burrower")
					melee_damage_lower = 25
					melee_damage_upper = 35
					health = 250
					maxHealth = 250
					plasma_max = 1000
					plasma_gain = 50
					upgrade_threshold = 1600
					caste_desc = "Строитель действительно больших ульев. Выглядит довольно крепко."
					armor_deflection = 15
					tacklemin = 4
					tacklemax = 6
					tackle_chance = 70
					speed = 0.2
					aura_strength = 2
				if("Hivelord")
					melee_damage_lower = 15
					melee_damage_upper = 20
					health = 250
					maxHealth = 250
					plasma_max = 1000
					plasma_gain = 50
					upgrade_threshold = 1600
					caste_desc = "Строитель действительно больших ульев. Выглядит довольно крепко."
					armor_deflection = 15
					tacklemin = 4
					tacklemax = 6
					tackle_chance = 70
					speed = 0.2
					aura_strength = 2
				if("Carrier")
					melee_damage_lower = 30
					melee_damage_upper = 40
					health = 220
					maxHealth = 220
					plasma_max = 350
					plasma_gain = 12
					upgrade_threshold = 1600
					caste_desc = "Портативный транспорт любви. Выглядит довольно крепко."
					armor_deflection = 10
					tacklemin = 4
					tacklemax = 5
					tackle_chance = 70
					speed = -0.2
					aura_strength = 2
					var/mob/living/carbon/Xenomorph/Carrier/CA = src
					CA.huggers_max = 10
					CA.hugger_delay = 20
					CA.eggs_max = 5
				if("Queen")
					melee_damage_lower = 50
					melee_damage_upper = 60
					health = 500
					maxHealth = 500
					plasma_max = 1000
					plasma_gain = 75
					upgrade_threshold = 3200
					spit_delay = 15
					caste_desc = "Самый большой и самый плохой ксенон. Императрица контролирует множество ульев и планет."
					armor_deflection = 65
					tacklemin = 6
					tacklemax = 9
					tackle_chance = 90
					speed = 1.5
					aura_strength = 5
					queen_leader_limit = 6

		//Free UPGRADE
		if(3)
			upgrade_name = "Ancient"
			switch(caste)
				if("Runner")
					to_chat(src, "<span class='xenoannounce'>Ты самый быстрый убийца всех времен. Ваша скорость не имеет себе равных.</span>")
					melee_damage_lower = 25
					melee_damage_upper = 35
					health = 200
					maxHealth = 200
					plasma_gain = 2
					plasma_max = 200
					upgrade_threshold = 3200
					caste_desc = "Не то, с чем хочется столкнуться в темном переулке. Это выглядит очень здорово."
					speed = -2.1
					armor_deflection = 10
					attack_delay = -4
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 70
					pounce_delay = 25
				if("Lurker")
					to_chat(src, "<span class='xenoannounce'>Ты-воплощение охотника. Немногие могут противостоять вам в открытом бою.</span>")
					melee_damage_lower = 50
					melee_damage_upper = 60
					health = 250
					maxHealth = 250
					plasma_gain = 20
					plasma_max = 300
					upgrade_threshold = 3200
					caste_desc = "Совершенно непревзойденный охотник. Нет, даже Яуты не могут сравниться с тобой."
					speed = -1.8
					armor_deflection = 25
					attack_delay = -3
					tacklemin = 4
					tacklemax = 6
					tackle_chance = 65
					pounce_delay = 40
				if("Ravager")
					to_chat(src, "<span class='xenoannounce'>Ты-воплощение смерти. Все будут дрожать перед тобой.</span>")
					melee_damage_lower = 80
					melee_damage_upper = 100
					health = 350
					maxHealth = 350
					plasma_gain = 15
					plasma_max = 200
					upgrade_threshold = 3200
					caste_desc = "Когда я иду по долине тени смерти."
					speed = -1.0
					armor_deflection = 50
					tacklemin = 5
					tacklemax = 10
					tackle_chance = 90
				if ("Defender")
					to_chat(src, "<span class='xenoannounce'>Вы невероятно устойчивы, вы можете контролировать битву с помощью чистой силы.</span>")
					health = 325
					maxHealth = 325
					plasma_gain = 8
					plasma_max = 100
					upgrade_threshold = 3200
					caste_desc = "Непреодолимая сила, которая остается, когда другие падают."
					speed = -0.4
					armor_deflection = 55
				if ("Warrior")
					to_chat(src, "<span class='xenoannounce'>Никто не может устоять перед тобой. Ты уничтожишь всех слабаков, кто попытается.</span>")
					melee_damage_lower = 45
					melee_damage_upper = 50
					health = 275
					maxHealth = 275
					plasma_gain = 8
					plasma_max = 100
					upgrade_threshold = 3200
					caste_desc = "Неуклюжий зверь, способный без усилий прорваться сквозь своих врагов."
					speed = -1.1
					armor_deflection = 45
				if("Crusher")
					to_chat(src, "<span class='xenoannounce'>Вы-физическое проявление танка. Почти ничто не может причинить вам вред.</span>")
					melee_damage_lower = 35
					melee_damage_upper = 45
					tacklemin = 4
					tacklemax = 7
					tackle_chance = 75
					health = 450
					maxHealth = 450
					plasma_gain = 30
					plasma_max = 400
					upgrade_threshold = 3200
					caste_desc = "Он всегда имеет право."
					armor_deflection = 90
				if("Sentinel")
					to_chat(src, "<span class='xenoannounce'>Ты мастер оглушения. Ваш потрясающий легендарный и вызывает огромное количество неприязни.</span>")
					melee_damage_lower = 25
					melee_damage_upper = 35
					health = 200
					maxHealth = 200
					plasma_gain = 20
					plasma_max = 600
					upgrade_threshold = 3200
					spit_delay = 25
					caste_desc = "Фабрика нейротоксинов, не позволяй ей достать тебя."
					armor_deflection = 20
					tacklemin = 4
					tacklemax = 6
					tackle_chance = 60
					speed = -1.1
				if("Spitter")
					to_chat(src, "<span class='xenoannounce'>Вы мастер дальнобойных оглушений и повреждений. Идите и делайте соль.</span>")
					melee_damage_lower = 35
					melee_damage_upper = 45
					health = 250
					maxHealth = 250
					plasma_gain = 50
					plasma_max = 900
					upgrade_threshold = 3200
					spit_delay = 10
					caste_desc = "Дальнобойная машина уничтожения."
					armor_deflection = 30
					tacklemin = 5
					tacklemax = 7
					tackle_chance = 75
					speed = -0.8
				if("Boiler")
					to_chat(src, "<span class='xenoannounce'>Вы мастер дальнобойной артиллерии. Принесите смерть свыше..Вы мастер дальнобойной артиллерии. Принесите смерть свыше.</span>")
					melee_damage_lower = 35
					melee_damage_upper = 45
					health = 250
					maxHealth = 250
					plasma_gain = 50
					plasma_max = 1000
					upgrade_threshold = 3200
					spit_delay = 10
					bomb_strength = 2.5
					caste_desc = "Разрушительная часть инопланетной артиллерии."
					armor_deflection = 35
					tacklemin = 4
					tacklemax = 6
					tackle_chance = 80
					speed = 0.4
				if("Praetorian")
					to_chat(src, "<span class='xenoannounce'>Вы самый сильный истребитель всего вокруг. Ваша слюна разрушительна, и вы можете стрелять почти постоянным потоком.</span>")
					melee_damage_lower = 40
					melee_damage_upper = 50
					health = 270
					maxHealth = 270
					plasma_gain = 50
					plasma_max = 1000
					upgrade_threshold = 3200
					spit_delay = 0
					caste_desc = "Его рот похож на миниган."
					armor_deflection = 45
					tacklemin = 7
					tacklemax = 10
					tackle_chance = 85
					speed = -0.2
					aura_strength = 4.5
				if("Drone")
					to_chat(src, "<span class='xenoannounce'>Вы-высший работник улья. Время войти и выйти из дома.</span>")
					melee_damage_lower = 20
					melee_damage_upper = 30
					health = 200
					maxHealth = 200
					plasma_max = 1000
					plasma_gain = 50
					upgrade_threshold = 3200
					caste_desc = "Очень плохой архитектор."
					armor_deflection = 15
					tacklemin = 4
					tacklemax = 6
				if("Burrower")
					to_chat(src, "<span class='xenoannounce'>Ты строитель стен. Убедитесь, что за них платят морские пехотинцы.</span>")
					melee_damage_lower = 35
					melee_damage_upper = 45
					health = 300
					maxHealth = 300
					plasma_max = 1200
					plasma_gain = 70
					upgrade_threshold = 3200
					caste_desc = "Экстремальная строительная машина. Кажется, он возводит стены..."
					armor_deflection = 20
					tacklemin = 5
					tacklemax = 7
					tackle_chance = 80
					speed = 0.1
					aura_strength = 2.5
				if("Hivelord")
					to_chat(src, "<span class='xenoannounce'>Ты строитель стен. Убедитесь, что за них платят морские пехотинцы.</span>")
					melee_damage_lower = 20
					melee_damage_upper = 30
					health = 300
					maxHealth = 300
					plasma_max = 1200
					plasma_gain = 70
					upgrade_threshold = 3200
					caste_desc = "Экстремальная строительная машина. Кажется, он возводит стены..."
					armor_deflection = 20
					tacklemin = 5
					tacklemax = 7
					tackle_chance = 80
					speed = 0.1
					aura_strength = 2.5
				if("Carrier")
					to_chat(src, "<span class='xenoannounce'>Ты мастер объятий. Бросайте их, как бейсбольные мячи в морпехов!</span>")
					melee_damage_lower = 35
					melee_damage_upper = 45
					health = 250
					maxHealth = 250
					plasma_max = 400
					plasma_gain = 15
					upgrade_threshold = 3200
					caste_desc = "Это буквально кишит 10 лицехватов."
					armor_deflection = 15
					tacklemin = 5
					tacklemax = 6
					tackle_chance = 75
					speed = -0.3
					aura_strength = 2.5
					var/mob/living/carbon/Xenomorph/Carrier/CA = src
					CA.huggers_max = 11
					CA.hugger_delay = 10
					CA.eggs_max = 6
				if("Queen")
					to_chat(src, "<span class='xenoannounce'>Ты альфа и Омега. Начало и конец. Теперь ты Королева-Мать</span>")
					melee_damage_lower = 80
					melee_damage_upper = 120
					health = 1500
					maxHealth = 1500
					plasma_max = 2000
					plasma_gain = 100
					upgrade_threshold = 3200
					spit_delay = 5
					caste_desc = "Самая совершенная форма ксеносов, какую только можно себе представить в виде титана."
					armor_deflection = 80
					tacklemin = 15
					tacklemax = 20
					tackle_chance = 200
					speed = 1
					aura_strength = 20
					queen_leader_limit = 10

		if(4) //FINAL GRADE
			upgrade_name = "TITAN"
			switch(caste)
				if("Runner")
					to_chat(src, "<span class='xenoannounce'>Ты самый быстрый убийца всех времен. Ваша скорость не имеет себе равных. ТИТАН</span>")
					melee_damage_lower = 30
					melee_damage_upper = 40
					health = 250
					maxHealth = 250
					plasma_gain = 3
					plasma_max = 250
					caste_desc = "Не то, с чем хочется столкнуться в темном переулке. Это выглядит очень здорово."
					speed = -2.2
					armor_deflection = 15
					attack_delay = -4
					tacklemin = 3
					tacklemax = 5
					tackle_chance = 70
					pounce_delay = 25
				if("Lurker")
					to_chat(src, "<span class='xenoannounce'>Ты-воплощение охотника. Немногие могут противостоять вам в открытом бою. ТИТАН</span>")
					melee_damage_lower = 55
					melee_damage_upper = 65
					health = 300
					maxHealth = 300
					plasma_gain = 25
					plasma_max = 400
					caste_desc = "Совершенно непревзойденный охотник. Нет, даже Яуты не могут сравниться с тобой."
					speed = -1.9
					armor_deflection = 30
					attack_delay = -3
					tacklemin = 4
					tacklemax = 6
					tackle_chance = 65
					pounce_delay = 40
				if("Ravager")
					to_chat(src, "<span class='xenoannounce'>Ты-воплощение смерти. Все будут дрожать перед тобой. ТИТАН</span>")
					melee_damage_lower = 90
					melee_damage_upper = 110
					health = 400
					maxHealth = 400
					plasma_gain = 20
					plasma_max = 300
					caste_desc = "Когда я иду по долине тени смерти."
					speed = -1.1
					armor_deflection = 55
					tacklemin = 5
					tacklemax = 10
					tackle_chance = 90
				if ("Defender")
					to_chat(src, "<span class='xenoannounce'>Вы невероятно устойчивы, вы можете контролировать битву с помощью чистой силы. ТИТАН</span>")
					health = 325
					maxHealth = 325
					plasma_gain = 8
					plasma_max = 100
					caste_desc = "Непреодолимая сила, которая остается, когда другие падают."
					speed = -0.4
					armor_deflection = 55
				if ("Warrior")
					to_chat(src, "<span class='xenoannounce'>Никто не может устоять перед тобой. Ты уничтожишь всех слабаков, кто попытается. ТИТАН</span>")
					melee_damage_lower = 45
					melee_damage_upper = 50
					health = 275
					maxHealth = 275
					plasma_gain = 8
					plasma_max = 100
					caste_desc = "Неуклюжий зверь, способный без усилий прорваться сквозь своих врагов."
					speed = -1.1
					armor_deflection = 45
				if("Crusher")
					to_chat(src, "<span class='xenoannounce'>Вы-физическое проявление танка. Почти ничто не может причинить вам вред. ТИТАН</span>")
					melee_damage_lower = 35
					melee_damage_upper = 45
					tacklemin = 4
					tacklemax = 7
					tackle_chance = 75
					health = 450
					maxHealth = 450
					plasma_gain = 30
					plasma_max = 400
					caste_desc = "Он всегда имеет право."
					armor_deflection = 90
				if("Sentinel")
					to_chat(src, "<span class='xenoannounce'>Ты мастер оглушения. Ваш потрясающий легендарный и вызывает огромное количество неприязни. ТИТАН</span>")
					melee_damage_lower = 25
					melee_damage_upper = 35
					health = 200
					maxHealth = 200
					plasma_gain = 20
					plasma_max = 600
					spit_delay = 25
					caste_desc = "Фабрика нейротоксинов, не позволяй ей достать тебя."
					armor_deflection = 20
					tacklemin = 4
					tacklemax = 6
					tackle_chance = 60
					speed = -1.1
				if("Spitter")
					to_chat(src, "<span class='xenoannounce'>Вы мастер дальнобойных оглушений и повреждений. Идите и делайте соль. ТИТАН</span>")
					melee_damage_lower = 40
					melee_damage_upper = 50
					health = 300
					maxHealth = 300
					plasma_gain = 50
					plasma_max = 900
					spit_delay = 10
					caste_desc = "Дальнобойная машина уничтожения."
					armor_deflection = 30
					tacklemin = 5
					tacklemax = 7
					tackle_chance = 75
					speed = -0.8
				if("Boiler")
					to_chat(src, "<span class='xenoannounce'>Вы мастер дальнобойной артиллерии. Принесите смерть свыше..Вы мастер дальнобойной артиллерии. Принесите смерть свыше. ТИТАН</span>")
					melee_damage_lower = 40
					melee_damage_upper = 50
					health = 300
					maxHealth = 300
					plasma_gain = 75
					plasma_max = 1400
					spit_delay = 5
					bomb_strength = 5
					caste_desc = "Разрушительная часть инопланетной артиллерии."
					armor_deflection = 40
					tacklemin = 4
					tacklemax = 6
					tackle_chance = 80
					speed = 0.4
				if("Praetorian")
					to_chat(src, "<span class='xenoannounce'>Вы самый сильный истребитель всего вокруг. Ваша слюна разрушительна, и вы можете стрелять почти постоянным потоком. ТИТАН</span>")
					melee_damage_lower = 45
					melee_damage_upper = 55
					health = 320
					maxHealth = 320
					plasma_gain = 55
					plasma_max = 1400
					spit_delay = 0
					caste_desc = "Его рот похож на миниган."
					armor_deflection = 50
					tacklemin = 7
					tacklemax = 10
					tackle_chance = 85
					speed = -0.2
					aura_strength = 4.5
				if("Drone")
					to_chat(src, "<span class='xenoannounce'>Вы-высший работник улья. Время войти и выйти из дома. ТИТАН</span>")
					melee_damage_lower = 25
					melee_damage_upper = 35
					health = 250
					maxHealth = 250
					plasma_max = 1200
					plasma_gain = 55
					caste_desc = "Очень плохой архитектор."
					armor_deflection = 20
					tacklemin = 4
					tacklemax = 6
				if("Burrower")
					to_chat(src, "<span class='xenoannounce'>Ты строитель стен. Убедитесь, что за них платят морские пехотинцы. ТИТАН</span>")
					melee_damage_lower = 40
					melee_damage_upper = 55
					health = 400
					maxHealth = 400
					plasma_max = 1400
					plasma_gain = 90
					caste_desc = "Экстремальная строительная машина. Кажется, он возводит стены..."
					armor_deflection = 25
					tacklemin = 5
					tacklemax = 7
					tackle_chance = 80
					speed = 0.1
					aura_strength = 2.5
				if("Hivelord")
					to_chat(src, "<span class='xenoannounce'>Ты строитель стен. Убедитесь, что за них платят морские пехотинцы. ТИТАН</span>")
					melee_damage_lower = 25
					melee_damage_upper = 35
					health = 400
					maxHealth = 400
					plasma_max = 1400
					plasma_gain = 90
					caste_desc = "Экстремальная строительная машина. Кажется, он возводит стены..."
					armor_deflection = 25
					tacklemin = 5
					tacklemax = 7
					tackle_chance = 80
					speed = 0.1
					aura_strength = 2.5
				if("Carrier")
					to_chat(src, "<span class='xenoannounce'>Ты мастер объятий. Бросайте их, как бейсбольные мячи в морпехов! ТИТАН</span>")
					melee_damage_lower = 40
					melee_damage_upper = 50
					health = 300
					maxHealth = 300
					plasma_max = 500
					plasma_gain = 20
					caste_desc = "Это буквально кишит лицехватами."
					armor_deflection = 20
					tacklemin = 5
					tacklemax = 6
					tackle_chance = 75
					speed = -0.3
					aura_strength = 2.5
					var/mob/living/carbon/Xenomorph/Carrier/CA = src
					CA.huggers_max = 11
					CA.hugger_delay = 10
					CA.eggs_max = 6
				if("Queen")
					to_chat(src, "<span class='xenoannounce'>Ты альфа и Омега. Начало и конец. Теперь ты Королева-Мать ТИТАН</span>")
					melee_damage_lower = 100
					melee_damage_upper = 150
					health = 2000
					maxHealth = 2000
					plasma_max = 2500
					plasma_gain = 100
					spit_delay = 2.5
					caste_desc = "Самая совершенная форма ксеносов, какую только можно себе представить в виде титана."
					armor_deflection = 90
					tacklemin = 15
					tacklemax = 20
					tackle_chance = 200
					speed = 0.8
					crit_health = -400
					aura_strength = 25
					queen_leader_limit = 15

	generate_name() //Give them a new name now

	hud_set_queen_overwatch() //update the upgrade level insignia on our xeno hud.

	//One last shake for the sake of it
	xeno_jitter(25)


//Tiered spawns.
/mob/living/carbon/Xenomorph/Runner/mature/New()
	..()
	upgrade_xeno(1)

/mob/living/carbon/Xenomorph/Runner/elite/New()
	..()
	upgrade_xeno(2)

/mob/living/carbon/Xenomorph/Runner/ancient/New()
	..()
	upgrade_xeno(3)

/mob/living/carbon/Xenomorph/Runner/titan/New()
	..()
	upgrade_xeno(4)

/mob/living/carbon/Xenomorph/Drone/mature/New()
	..()
	upgrade_xeno(1)

/mob/living/carbon/Xenomorph/Drone/elite/New()
	..()
	upgrade_xeno(2)

/mob/living/carbon/Xenomorph/Drone/ancient/New()
	..()
	upgrade_xeno(3)

/mob/living/carbon/Xenomorph/Drone/titan/New()
	..()
	upgrade_xeno(4)

/mob/living/carbon/Xenomorph/Carrier/mature/New()
	..()
	upgrade_xeno(1)

/mob/living/carbon/Xenomorph/Carrier/elite/New()
	..()
	upgrade_xeno(2)

/mob/living/carbon/Xenomorph/Carrier/ancient/New()
	..()
	upgrade_xeno(3)

/mob/living/carbon/Xenomorph/Carrier/titan/New()
	..()
	upgrade_xeno(4)

/mob/living/carbon/Xenomorph/Burrower/mature/New()
	..()
	upgrade_xeno(1)

/mob/living/carbon/Xenomorph/Burrower/elite/New()
	..()
	upgrade_xeno(2)

/mob/living/carbon/Xenomorph/Burrower/ancient/New()
	..()
	upgrade_xeno(3)

/mob/living/carbon/Xenomorph/Burrower/titan/New()
	..()
	upgrade_xeno(4)

/mob/living/carbon/Xenomorph/Hivelord/mature/New()
	..()
	upgrade_xeno(1)

/mob/living/carbon/Xenomorph/Hivelord/elite/New()
	..()
	upgrade_xeno(2)

/mob/living/carbon/Xenomorph/Hivelord/ancient/New()
	..()
	upgrade_xeno(3)

/mob/living/carbon/Xenomorph/Hivelord/titan/New()
	..()
	upgrade_xeno(4)

/mob/living/carbon/Xenomorph/Praetorian/mature/New()
	..()
	upgrade_xeno(1)

/mob/living/carbon/Xenomorph/Praetorian/elite/New()
	..()
	upgrade_xeno(2)

/mob/living/carbon/Xenomorph/Praetorian/ancient/New()
	..()
	upgrade_xeno(3)

/mob/living/carbon/Xenomorph/Praetorian/titan/New()
	..()
	upgrade_xeno(4)

/mob/living/carbon/Xenomorph/Ravager/mature/New()
	..()
	upgrade_xeno(1)

/mob/living/carbon/Xenomorph/Ravager/elite/New()
	..()
	upgrade_xeno(2)

/mob/living/carbon/Xenomorph/Ravager/ancient/New()
	..()
	upgrade_xeno(3)

/mob/living/carbon/Xenomorph/Ravager/titan/New()
	..()
	upgrade_xeno(4)

/mob/living/carbon/Xenomorph/Sentinel/mature/New()
	..()
	upgrade_xeno(1)

/mob/living/carbon/Xenomorph/Sentinel/elite/New()
	..()
	upgrade_xeno(2)

/mob/living/carbon/Xenomorph/Sentinel/ancient/New()
	..()
	upgrade_xeno(3)

/mob/living/carbon/Xenomorph/Sentinel/titan/New()
	..()
	upgrade_xeno(4)

/mob/living/carbon/Xenomorph/Spitter/mature/New()
	..()
	upgrade_xeno(1)

/mob/living/carbon/Xenomorph/Spitter/elite/New()
	..()
	upgrade_xeno(2)

/mob/living/carbon/Xenomorph/Spitter/ancient/New()
	..()
	upgrade_xeno(3)

/mob/living/carbon/Xenomorph/Spitter/titan/New()
	..()
	upgrade_xeno(4)

/mob/living/carbon/Xenomorph/Lurker/mature/New()
	..()
	upgrade_xeno(1)

/mob/living/carbon/Xenomorph/Lurker/elite/New()
	..()
	upgrade_xeno(2)

/mob/living/carbon/Xenomorph/Lurker/ancient/New()
	..()
	upgrade_xeno(3)

/mob/living/carbon/Xenomorph/Lurker/titan/New()
	..()
	upgrade_xeno(4)

/mob/living/carbon/Xenomorph/Queen/mature/New()
	..()
	upgrade_xeno(1)

/mob/living/carbon/Xenomorph/Queen/elite/New()
	..()
	upgrade_xeno(2)

/mob/living/carbon/Xenomorph/Queen/ancient/New()
	..()
	upgrade_xeno(3)

/mob/living/carbon/Xenomorph/Queen/titan/New()
	..()
	upgrade_xeno(4)

/mob/living/carbon/Xenomorph/Crusher/mature/New()
	..()
	upgrade_xeno(1)

/mob/living/carbon/Xenomorph/Crusher/elite/New()
	..()
	upgrade_xeno(2)

/mob/living/carbon/Xenomorph/Crusher/ancient/New()
	..()
	upgrade_xeno(3)

/mob/living/carbon/Xenomorph/Crusher/titan/New()
	..()
	upgrade_xeno(4)

/mob/living/carbon/Xenomorph/Boiler/mature/New()
	..()
	upgrade_xeno(1)

/mob/living/carbon/Xenomorph/Boiler/elite/New()
	..()
	upgrade_xeno(2)

/mob/living/carbon/Xenomorph/Boiler/ancient/New()
	..()
	upgrade_xeno(3)

/mob/living/carbon/Xenomorph/Boiler/titan/New()
	..()
	upgrade_xeno(4)


/mob/living/carbon/Xenomorph/Defender/mature/New()
	..()
	upgrade_xeno(1)

/mob/living/carbon/Xenomorph/Defender/elite/New()
	..()
	upgrade_xeno(2)

/mob/living/carbon/Xenomorph/Defender/ancient/New()
	..()
	upgrade_xeno(3)

/mob/living/carbon/Xenomorph/Defender/titan/New()
	..()
	upgrade_xeno(4)


/mob/living/carbon/Xenomorph/Warrior/mature/New()
	..()
	upgrade_xeno(1)

/mob/living/carbon/Xenomorph/Warrior/elite/New()
	..()
	upgrade_xeno(2)

/mob/living/carbon/Xenomorph/Warrior/ancient/New()
	..()
	upgrade_xeno(3)

/mob/living/carbon/Xenomorph/Warrior/titan/New()
	..()
	upgrade_xeno(4)

