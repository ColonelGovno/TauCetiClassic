/obj/structure/scrap_beacon
	name = "Scrap Beacon"
	desc = "This machine generates directional gravity rays which catch trash orbiting around."
	icon = 'icons/obj/structures/scrap/scrap_beacon.dmi'
	icon_state = "beacon0"
	anchored = 1
	density = 1
	layer = MOB_LAYER+1
	var/summon_cooldown = 1200
	var/impact_speed = 3
	var/impact_prob = 100
	var/impact_range = 2
	var/last_summon = -300
	var/active = 0

/obj/structure/scrap_beacon/attack_hand(mob/user as mob)
	if((last_summon + summon_cooldown) >= world.time)
		user << "<span class='notice'>[src.name] not charged yet.</span>"
		return
	last_summon = world.time
	if(!active)
		start_scrap_summon()

/obj/structure/scrap_beacon/update_icon()
	icon_state = "beacon[active]"

/obj/structure/scrap_beacon/proc/start_scrap_summon()
	active = 1
	update_icon()
	sleep(30)
	var/list/flooring_near_beacon = list()
	for(var/turf/T in RANGE_TURFS(impact_range, src))
		if(!istype(T,/turf/simulated/floor))
			continue
		if((locate(/obj/structure/scrap) in T))
			continue
		if(!prob(impact_prob))
			continue
		flooring_near_beacon += T
	flooring_near_beacon -= src.loc
	while(flooring_near_beacon.len > 0)
		sleep(impact_speed)
		var/turf/newloc = pick(flooring_near_beacon)
		flooring_near_beacon -= newloc
		spawn()
			summon_scrap_pile(newloc)
	active = 0
	update_icon()
	return

/obj/structure/scrap_beacon/proc/summon_scrap_pile(newloc)
	new /obj/random/scrap/moderate_weighted(newloc)
	var/datum/effect/effect/system/spark_spread/s = PoolOrNew(/datum/effect/effect/system/spark_spread)
	s.set_up(3, 1, newloc)
	s.start()
