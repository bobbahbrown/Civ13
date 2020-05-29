
/////////////////////////////TELEPHONE/////////////////////////////////////
/obj/item/weapon/telephone
	name = "telephone"
	desc = "Used to communicate with other telephones. No number."
	icon = 'icons/obj/modern_structures.dmi'
	icon_state = "telephone"
	flammable = FALSE
	density = FALSE
	opacity = FALSE
	force = WEAPON_FORCE_WEAK+3
	throwforce = WEAPON_FORCE_WEAK
	w_class = 4
	var/phonenumber = 0
	var/ringing = FALSE
	var/ringingnum = FALSE
	var/obj/item/weapon/telephone/origincall = null
	var/connected = FALSE

	var/wireless = FALSE
	var/maxrange = 0
	var/list/contacts = list()

/obj/item/weapon/telephone/verb/name_telephone()
	set category = null
	set name = "Name"
	set desc = "Name this telephone."

	set src in view(1)
	if (!ishuman(usr))
		return
	var/yn = input(usr, "Name this telephone?") in list("Yes", "No")
	if (yn == "Yes")
		var/_name = input(usr, "What name?") as text
		name = sanitize(_name, 20)
	return

var/list/global/phone_numbers = list()
/obj/item/weapon/telephone/New()
	..()
	if (phonenumber == 0)
		new_phonenumber()

/obj/item/weapon/telephone/proc/new_phonenumber()
	var/tempnum = 0
	tempnum = rand(1000,9999)
	if (tempnum in phone_numbers)
		new_phonenumber()
		return
	else
		phonenumber = tempnum
		phone_numbers += tempnum
		desc = "Used to communicate with other telephones. Number: [phonenumber]."
		return

/obj/item/weapon/telephone/proc/ringproc(var/origin,var/obj/item/weapon/telephone/ocall)
	ringing = TRUE
	ringingnum = origin
	origincall = ocall
	spawn(0)
		if (ringing)
			ring(origin)
	spawn(40)
		if (ringing)
			ring(origin)
	spawn(80)
		if (ringing)
			ring(origin)
	spawn(120)
		if (ringing)
			ring(origin)
	spawn(160)
		if (ringing)
			ring(origin)
	spawn(200)
		ringing = FALSE
		ringingnum = FALSE
		if (!connected)
			origincall = null
	return
/obj/item/weapon/telephone/proc/ring(var/origin = null)
	var/orname = "Unknown"
	if (origin)
		for(var/list/L in contacts)
			if (L[2] == origin)
				orname = L[1]
	if (ringing)
		playsound(loc, 'sound/machines/telephone.ogg', 65)
		if (!origin)
			visible_message("<b><font size=2 color=#FFAE19>\icon[getFlatIcon(src)] [src]:</b> </font>Ringing!")
		else
			visible_message("<b><font size=2 color=#FFAE19>\icon[getFlatIcon(src)] [src]:</b> </font>Incoming call: <b>[orname]</b> ([origin])")
	else
		return

/obj/item/weapon/telephone/proc/broadcast(var/msg, var/mob/living/human/speaker)

	// ignore emotes.
	if (dd_hasprefix(msg, "*"))
		return

	var/list/tried_mobs = list()

	for (var/mob/living/human/hearer in human_mob_list)
		if (tried_mobs.Find(hearer))
			continue
		tried_mobs += hearer
		if (hearer.stat == CONSCIOUS)
			for (var/obj/item/weapon/telephone/phone in view(7, hearer))
				if (src == phone.origincall || src == phone)
					hearer.hear_phone(msg, speaker.default_language, speaker, src, phone)

/obj/item/weapon/telephone/attack_self(var/mob/user as mob)
	if (!connected && !ringing)
		var/input = input(user, "Choose the number to call: (4 digits, no decimals)") as num
		if (!input)
			return
		var/tgtnum = 0
		if (input != 911)
			tgtnum = sanitize_integer(input, min=1000, max=9999, default=0) //0 as a first digit doesnt really work
		else
			tgtnum = 911
		if (tgtnum == 0)
			return
		if (!wireless)
			for (var/obj/structure/phoneline/PL in range(2,loc))
				PL.ring_phone(tgtnum,phonenumber, src)
				ringing = TRUE
				visible_message("<b><font size=2 color=#FFAE19>\icon[getFlatIcon(src)] [src]:</b> </font>Ringing [tgtnum]...")
				spawn(200)
					if (!connected)
						ringing = FALSE
						visible_message("<b><font size=2 color=#FFAE19>\icon[getFlatIcon(src)] [src]:</b> </font>Nobody picked up the phone at [tgtnum].")
						return
		else
			var/found_tower = FALSE
			for (var/obj/structure/cell_tower/CT in range(maxrange,loc))
				found_tower = TRUE
			if (found_tower)
				ring_phone(tgtnum,phonenumber, src, user)
				spawn(200)
					if (!connected)
						user << "<b><font size=2 color=#FFAE19>\icon[getFlatIcon(src)] [src]:</b> </font>Nobody picked up the phone at [tgtnum]."
						return
			else
				user << "<b><font size=2 color=#FFAE19>\icon[getFlatIcon(src)] [src]:</b> </font>No signal."
				return
	if (connected)
		connected = FALSE
		if (origincall)
			user << "<b><font size=2 color=#FFAE19>\icon[getFlatIcon(src)] [src]:</b> </font>You hang up the phone."
			if (ishuman(origincall.loc))
				origincall.loc << "<b><font size=2 color=#FFAE19>\icon[getFlatIcon(src)] [src]:</b> </font>Someone hangs up the phone."
			else
				origincall.visible_message("<b><font size=2 color=#FFAE19>\icon[getFlatIcon(src)] [src]:</b> </font>Someone hangs up the phone.")
			origincall.connected = FALSE
			origincall.origincall = null
			origincall = null

	if (ringing && ringingnum)
		ringing = FALSE
		connected = ringingnum
		if (origincall)
			origincall.connected = phonenumber
			origincall.ringing = FALSE
			origincall.origincall = src
			user << "<b><font size=2 color=#FFAE19>\icon[getFlatIcon(src)] [src]:</b> </font>You pick up the phone."
			if (ishuman(origincall.loc))
				origincall.loc << "<b><font size=2 color=#FFAE19>\icon[getFlatIcon(src)] [src]:</b> </font>Someone picks up the phone."
			else
				origincall.visible_message("<b><font size=2 color=#FFAE19>\icon[getFlatIcon(src)] [src]:</b> </font>Someone picks up the phone.")

/obj/item/weapon/telephone/attack_hand(var/mob/living/human/H)
	if (anchored && ishuman(H))
		attack_self(H)
		return
	else
		..()
/////////////////////////////MOBILE PHONE/////////////////////////////////////
/obj/item/weapon/telephone/mobile
	name = "cellphone"
	desc = "Used to communicate with other telephones. No number."
	icon = 'icons/obj/device.dmi'
	icon_state = "cellphone"
	force = WEAPON_FORCE_WEAK+3
	throwforce = WEAPON_FORCE_WEAK
	wireless = TRUE
	maxrange = 40
	w_class = 2

/obj/item/weapon/telephone/mobile/attack_self(var/mob/user as mob)
	if (!connected && !ringing)
		var/choice1 = WWinput(user, "What do you want to do?", "Mobile Phone", "Cancel", list("Call Number", "Call Contact", "Add Contact"))
		if (choice1 == "Cancel")
			return
		else if (choice1 == "Call Number")
			..()
		else if (choice1 == "Add Contact")
			var/input1 = input(user, "Choose the number to add: (4 digits, no decimals)") as num
			if (!input1)
				return
			if (input1 == phonenumber)
				user << "<span class='notice'>You can't add your own number!</span>"
				return
			var/addnum = 0
			addnum = sanitize_integer(input1, min=1000, max=9999, default=0) //0 as a first digit doesnt really work
			if (addnum == 0)
				return
			var/input2 = input(user, "Choose the name to assign to this number: (up to 15 characters)") as text
			if (!input2 || input2 == "")
				return
			input2 = sanitize(input2, 15)
			contacts += list(list(input2,input1))
		else if (choice1 == "Call Contact")
			var/list/clist = list("Cancel")
			for (var/list/i in contacts)
				clist += list(i[1])
			var/choice2 = WWinput(user, "Which contact do you want to call?", "Mobile Phone", "Cancel", clist)
			if (choice2 == "Cancel")
				return
			else
				var/callnum = 0
				for(var/list/j in contacts)
					if (j[1] == choice2)
						callnum = j[2]
				if (!callnum)
					return
				var/tgtnum = callnum
				var/found_tower = FALSE
				for (var/obj/structure/cell_tower/CT in range(maxrange,loc))
					found_tower = TRUE
				if (found_tower)
					ring_phone(tgtnum,phonenumber, src, user)
					spawn(200)
						if (!connected)
							user << "<b><font size=2 color=#FFAE19>\icon[getFlatIcon(src)] [src]:</b> </font>Nobody picked up the phone at [tgtnum]."
							return
				else
					user << "<b><font size=2 color=#FFAE19>\icon[getFlatIcon(src)] [src]:</b> </font>No signal."
					return
	else
		..()
/////////////////////////////CELLPHONE TOWER/////////////////////////////////////
/obj/structure/cell_tower
	name = "cell tower"
	desc = "A steel tower used to relay mobile communications."
	icon = 'icons/obj/obj32x64.dmi'
	icon_state = "radio_powered"
	flammable = TRUE
	not_movable = TRUE
	not_disassemblable = TRUE
	density = FALSE
	opacity = FALSE
	var/maxrange = 40
	var/lastproc = 0
	anchored = TRUE

/proc/ring_phone(var/target, var/origin, var/obj/item/weapon/telephone/originphone, var/mob/living/human/user = null)
	var/targetc = ""
	if (originphone.contacts.len)
		for (var/list/L in originphone.contacts)
			if (L[2] == target)
				targetc = L[1]
				break
	if (!origin || !target)
		return
	else
		for (var/obj/item/weapon/telephone/TLG in world)
			if (TLG.phonenumber == target && TLG.phonenumber != origin)
				if (!TLG.ringing)
					TLG.ringing = TRUE
					TLG.ringproc(origin, originphone)
					if (user)
						if (targetc != "")
							user << "<b><font size=2 color=#FFAE19>\icon[getFlatIcon(originphone)] [originphone]:</b> </font>Ringing <b>[targetc]</b> ([target])..."
						else
							user << "<b><font size=2 color=#FFAE19>\icon[getFlatIcon(originphone)] [originphone]:</b> </font>Ringing [target]..."

/obj/item/weapon/telephone/wireless
	name = "telephone"
	desc = "Used to communicate with other telephones. No number."
	icon_state = "telephone"
	connected = TRUE
	wireless = TRUE
	maxrange = 40

/obj/item/weapon/telephone/mobile/police
	name = "911 terminal"
	desc = "Emergency calls will be received here."
	icon = 'icons/obj/modern_structures.dmi'
	icon_state = "radio_transmitter"
	phonenumber = 911
	anchored = TRUE
	New()
		..()
		phone_numbers += phonenumber
/obj/item/weapon/telephone/mobile/faction
/obj/item/weapon/telephone/mobile/faction/red
	name = "Red phone"
/obj/item/weapon/telephone/mobile/faction/blue
	name = "Blue phone"
/obj/item/weapon/telephone/mobile/faction/green
	name = "Green phone"
/obj/item/weapon/telephone/mobile/faction/yellow
	name = "Yellow phone"

/obj/item/weapon/telephone/mobile/faction/New()
	..()
	contacts += list(list("Emergency",911))
	spawn(100)
		for (var/obj/item/weapon/telephone/mobile/faction/F in world)
			if (F != src)
				contacts += list(list(F.name,F.phonenumber))