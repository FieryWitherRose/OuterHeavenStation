////////////////////////////////////////////////////////////////////////////////////////////////////
//										BREAST ENLARGE
///////////////////////////////////////////////////////////////////////////////////////////////////
//Other files that are relivant:
//modular_citadel/code/datums/status_effects/chems.dm
//modular_citadel/code/modules/arousal/organs/breasts.dm

//breast englargement
//Honestly the most requested chems
//I'm not a very kinky person, sorry if it's not great
//I tried to make it interesting..!!

//Normal function increases your breast size by 0.05, 10units = 1 cup.
//If you get stupid big, it presses against your clothes, causing brute and oxydamage. Then rips them off.
//If you keep going, it makes you slower, in speed and action.
//decreasing your size will return you to normal.
//(see the status effect in chem.dm)
//Overdosing on (what is essentially space estrogen) makes you female, removes balls and shrinks your dick.
//OD is low for a reason. I'd like fermichems to have low ODs, and dangerous ODs, and since this is a meme chem that everyone will rush to make, it'll be a lesson learnt early.

/datum/reagent/fermi/breast_enlarger
	name = "Succubus milk"
	id = "breast_enlarger"
	description = "A volatile collodial mixture derived from milk that encourages mammary production via a potent estrogen mix."
	color = "#E60584" // rgb: 96, 0, 255
	taste_description = "a milky ice cream like flavour."
	overdose_threshold = 17
	metabolization_rate = 0.25
	impure_chem 			= "BEsmaller" //If you make an inpure chem, it stalls growth
	inverse_chem_val 		= 0.35
	inverse_chem		= "BEsmaller" //At really impure vols, it just becomes 100% inverse
	can_synth = FALSE
	var/message_spam = FALSE

/datum/reagent/fermi/breast_enlarger/on_mob_metabolize(mob/living/M)
	. = ..()
	if(!ishuman(M)) //The monkey clause
		if(volume >= 15) //To prevent monkey breast farms
			var/turf/T = get_turf(M)
			var/obj/item/organ/genital/breasts/B = new /obj/item/organ/genital/breasts(T)
			M.visible_message("<span class='warning'>A pair of breasts suddenly fly out of the [M]!</b></span>")
			var/T2 = get_random_station_turf()
			M.adjustBruteLoss(25)
			M.Knockdown(50)
			M.Stun(50)
			B.throw_at(T2, 8, 1)
		M.reagents.remove_reagent(id, volume)
		return
	var/mob/living/carbon/human/H = M
	if(!H.getorganslot(ORGAN_SLOT_BREASTS) && H.emergent_genital_call())
		H.genital_override = TRUE

/datum/reagent/fermi/breast_enlarger/on_mob_life(mob/living/carbon/M) //Increases breast size
	if(!ishuman(M))//Just in case
		return..()

	var/mob/living/carbon/human/H = M
	var/obj/item/organ/genital/breasts/B = M.getorganslot(ORGAN_SLOT_BREASTS)
	//If they have Acute hepatic pharmacokinesis, then route processing though liver.
	if(HAS_TRAIT(H, TRAIT_PHARMA) || !H.canbearoused)
		var/obj/item/organ/liver/L = H.getorganslot(ORGAN_SLOT_LIVER)
		if(L)
			L.swelling += 0.05
		else
			H.adjustToxLoss(1)
		return..()
	//otherwise proceed as normal
	if(!B) //If they don't have breasts, give them breasts.

		B = new
		if(H.dna.species.use_skintones && H.dna.features["genitals_use_skintone"])
			B.color = skintone2hex(H.skin_tone)
		else if(M.dna.features["breasts_color"])
			B.color = "#[M.dna.features["breasts_color"]]"
		else
			B.color = skintone2hex(H.skin_tone)
		B.size = "flat"
		B.cached_size = 0
		B.prev_size = 0
		to_chat(H, "<span class='warning'>Your chest feels warm, tingling with newfound sensitivity.</b></span>")
		H.reagents.remove_reagent(id, 5)
		B.Insert(H)

	//If they have them, increase size. If size is comically big, limit movement and rip clothes.
	B.modify_size(0.05)

	if (ISINRANGE_EX(B.cached_size, 8.5, 9) && (H.w_uniform || H.wear_suit))
		var/target = H.get_bodypart(BODY_ZONE_CHEST)
		if(!message_spam)
			to_chat(H, "<span class='danger'>Your breasts begin to strain against your clothes tightly!</b></span>")
			message_spam = TRUE
		H.adjustOxyLoss(5, 0)
		H.apply_damage(1, BRUTE, target)
	return ..()

/datum/reagent/fermi/breast_enlarger/overdose_process(mob/living/carbon/M) //Turns you into a female if male and ODing, doesn't touch nonbinary and object genders.

	//Acute hepatic pharmacokinesis.
	if(HAS_TRAIT(M, TRAIT_PHARMA) || !M.canbearoused)
		var/obj/item/organ/liver/L = M.getorganslot(ORGAN_SLOT_LIVER)
		L.swelling+= 0.05
		return ..()

	var/obj/item/organ/genital/penis/P = M.getorganslot(ORGAN_SLOT_PENIS)
	var/obj/item/organ/genital/testicles/T = M.getorganslot(ORGAN_SLOT_TESTICLES)
	var/obj/item/organ/genital/vagina/V = M.getorganslot(ORGAN_SLOT_VAGINA)
	var/obj/item/organ/genital/womb/W = M.getorganslot(ORGAN_SLOT_WOMB)

	if(M.gender == MALE)
		M.gender = FEMALE
		M.visible_message("<span class='boldnotice'>[M] suddenly looks more feminine!</span>", "<span class='boldwarning'>You suddenly feel more feminine!</span>")

	if(P)
		P.modify_size(-0.05)
	if(T)
		qdel(T)
	if(!V)
		V = new
		V.Insert(M)
	if(!W)
		W = new
		W.Insert(M)
	return ..()

/datum/reagent/fermi/BEsmaller
	name = "Modesty milk"
	id = "BEsmaller"
	description = "A volatile collodial mixture derived from milk that encourages mammary reduction via a potent estrogen mix. Produced by reacting impure Succubus milk."
	color = "#E60584" // rgb: 96, 0, 255
	taste_description = "a milky ice cream like flavour."
	metabolization_rate = 0.25
	can_synth = FALSE

/datum/reagent/fermi/BEsmaller/on_mob_life(mob/living/carbon/M)
	var/obj/item/organ/genital/breasts/B = M.getorganslot(ORGAN_SLOT_BREASTS)
	if(!B)
		//Acute hepatic pharmacokinesis.
		if(HAS_TRAIT(M, TRAIT_PHARMA) || !M.canbearoused)
			var/obj/item/organ/liver/L = M.getorganslot(ORGAN_SLOT_LIVER)
			L.swelling-= 0.05
			return ..()

		//otherwise proceed as normal
		return..()
	B.modify_size(-0.05)
	return ..()

/datum/reagent/fermi/BEsmaller_hypo
	name = "Rectify milk" //Rectify
	id = "BEsmaller_hypo"
	color = "#E60584"
	taste_description = "a milky ice cream like flavour."
	metabolization_rate = 0.25
	description = "A medicine used to treat organomegaly in a patient's breasts."
	var/sizeConv =  list("a" =  1, "b" = 2, "c" = 3, "d" = 4, "e" = 5)
	can_synth = TRUE

/datum/reagent/fermi/BEsmaller_hypo/on_mob_metabolize(mob/living/M)
	. = ..()
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	if(!H.getorganslot(ORGAN_SLOT_VAGINA) && H.dna.features["has_vag"])
		H.give_genital(/obj/item/organ/genital/vagina)
	if(!H.getorganslot(ORGAN_SLOT_WOMB) && H.dna.features["has_womb"])
		H.give_genital(/obj/item/organ/genital/womb)

/datum/reagent/fermi/BEsmaller_hypo/on_mob_life(mob/living/carbon/M)
	var/obj/item/organ/genital/breasts/B = M.getorganslot(ORGAN_SLOT_BREASTS)
	if(!B)
		return..()
	var/optimal_size = B.breast_values[M.dna.features["breasts_size"]]
	if(!optimal_size)//Fast fix for those who don't want it.
		B.modify_size(-0.1)
	else if(B.cached_size > optimal_size)
		B.modify_size(-0.05, optimal_size)
	else if(B.cached_size < optimal_size)
		B.modify_size(0.05, 0, optimal_size)
	return ..()

////////////////////////////////////////////////////////////////////////////////////////////////////
//										PENIS ENLARGE
///////////////////////////////////////////////////////////////////////////////////////////////////
//See breast explanation, it's the same but with taliwhackers
//instead of slower movement and attacks, it slows you and increases the total blood you need in your system.
//Since someone else made this in the time it took me to PR it, I merged them.
/datum/reagent/fermi/penis_enlarger // Due to popular demand...!
	name = "Incubus draft"
	id = "penis_enlarger"
	description = "A volatile collodial mixture derived from various masculine solutions that encourages a larger gentleman's package via a potent testosterone mix, formula derived from a collaboration from Fermichem  and Doctor Ronald Hyatt, who is well known for his phallus palace." //The toxic masculinity thing is a joke because I thought it would be funny to include it in the reagents, but I don't think many would find it funny? dumb
	color = "#888888" // This is greyish..?
	taste_description = "chinese dragon powder"
	overdose_threshold = 17 //ODing makes you male and removes female genitals
	metabolization_rate = 0.5
	impure_chem 			= "PEsmaller" //If you make an inpure chem, it stalls growth
	inverse_chem_val 		= 0.35
	inverse_chem		= "PEsmaller" //At really impure vols, it just becomes 100% inverse and shrinks instead.
	can_synth = FALSE
	var/message_spam = FALSE

/datum/reagent/fermi/penis_enlarger/on_mob_metabolize(mob/living/M)
	. = ..()
	if(!ishuman(M)) //Just monkeying around.
		if(volume >= 15) //to prevent monkey penis farms
			var/turf/T = get_turf(M)
			var/obj/item/organ/genital/penis/P = new /obj/item/organ/genital/penis(T)
			M.visible_message("<span class='warning'>A penis suddenly flies out of the [M]!</b></span>")
			var/T2 = get_random_station_turf()
			M.adjustBruteLoss(25)
			M.Knockdown(50)
			M.Stun(50)
			P.throw_at(T2, 8, 1)
		M.reagents.remove_reagent(id, volume)
		return
	var/mob/living/carbon/human/H = M
	if(!H.getorganslot(ORGAN_SLOT_PENIS) && H.emergent_genital_call())
		H.genital_override = TRUE

/datum/reagent/fermi/penis_enlarger/on_mob_life(mob/living/carbon/M) //Increases penis size, 5u = +1 inch.
	if(!ishuman(M))
		return ..()
	var/mob/living/carbon/human/H = M
	var/obj/item/organ/genital/penis/P = H.getorganslot(ORGAN_SLOT_PENIS)
	//If they have Acute hepatic pharmacokinesis, then route processing though liver.
	if(HAS_TRAIT(H, TRAIT_PHARMA) || !H.canbearoused)
		var/obj/item/organ/liver/L = H.getorganslot(ORGAN_SLOT_LIVER)
		if(L)
			L.swelling += 0.05
		else
			H.adjustToxLoss(1)
		return ..()
	//otherwise proceed as normal
	if(!P)//They do have a preponderance for escapism, or so I've heard.

		P = new
		P.length = 1
		to_chat(H, "<span class='warning'>Your groin feels warm, as you feel a newly forming bulge down below.</b></span>")
		P.prev_length = 1
		H.reagents.remove_reagent(id, 5)
		P.Insert(H)

	P.modify_size(0.1)
	if (ISINRANGE_EX(P.length, 20.5, 21) && (H.w_uniform || H.wear_suit))
		var/target = H.get_bodypart(BODY_ZONE_CHEST)
		if(!message_spam)
			to_chat(H, "<span class='danger'>Your cock begin to strain against your clothes tightly!</b></span>")
			message_spam = TRUE
		H.apply_damage(2.5, BRUTE, target)

	return ..()

/datum/reagent/fermi/penis_enlarger/overdose_process(mob/living/carbon/human/M) //Turns you into a male if female and ODing, doesn't touch nonbinary and object genders.
	if(!istype(M))
		return ..()
	//Acute hepatic pharmacokinesis.
	if(HAS_TRAIT(M, TRAIT_PHARMA) || !M.canbearoused)
		var/obj/item/organ/liver/L = M.getorganslot(ORGAN_SLOT_LIVER)
		L.swelling+= 0.05
		return..()

	var/obj/item/organ/genital/breasts/B = M.getorganslot(ORGAN_SLOT_BREASTS)
	var/obj/item/organ/genital/testicles/T = M.getorganslot(ORGAN_SLOT_TESTICLES)
	var/obj/item/organ/genital/vagina/V = M.getorganslot(ORGAN_SLOT_VAGINA)
	var/obj/item/organ/genital/womb/W = M.getorganslot(ORGAN_SLOT_WOMB)

	if(M.gender == FEMALE)
		M.gender = MALE
		M.visible_message("<span class='boldnotice'>[M] suddenly looks more masculine!</span>", "<span class='boldwarning'>You suddenly feel more masculine!</span>")

	if(B)
		B.modify_size(-0.05)
	if(M.getorganslot(ORGAN_SLOT_VAGINA))
		qdel(V)
	if(W)
		qdel(W)
	if(!T)
		T = new
		T.Insert(M)
	return ..()

/datum/reagent/fermi/PEsmaller // Due to cozmo's request...!
	name = "Chastity draft"
	id = "PEsmaller"
	description = "A volatile collodial mixture derived from various masculine solutions that encourages a smaller gentleman's package via a potent testosterone mix. Produced by reacting impure Incubus draft."
	color = "#888888" // This is greyish..?
	taste_description = "chinese dragon powder"
	metabolization_rate = 0.5
	can_synth = FALSE

/datum/reagent/fermi/PEsmaller/on_mob_life(mob/living/carbon/M)
	if(!ishuman(M))
		return ..()
	var/mob/living/carbon/human/H = M
	var/obj/item/organ/genital/penis/P = H.getorganslot(ORGAN_SLOT_PENIS)
	if(!P)
		//Acute hepatic pharmacokinesis.
		if(HAS_TRAIT(M, TRAIT_PHARMA))
			var/obj/item/organ/liver/L = M.getorganslot(ORGAN_SLOT_LIVER)
			L.swelling-= 0.05
		return..()

	P.modify_size(-0.1)
	..()

/datum/reagent/fermi/PEsmaller_hypo
	name = "Rectify draft"
	id = "PEsmaller_hypo"
	color = "#888888" // This is greyish..?
	taste_description = "chinese dragon powder"
	description = "A medicine used to treat organomegaly in a patient's penis."
	metabolization_rate = 0.5
	can_synth = TRUE

/datum/reagent/fermi/PEsmaller_hypo/on_mob_metabolize(mob/living/M)
	. = ..()
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	if(!H.getorganslot(ORGAN_SLOT_PENIS) && H.dna.features["has_cock"])
		H.give_genital(/obj/item/organ/genital/penis)
	if(!H.getorganslot(ORGAN_SLOT_TESTICLES) && H.dna.features["has_balls"])
		H.give_genital(/obj/item/organ/genital/testicles)

/datum/reagent/fermi/PEsmaller_hypo/on_mob_life(mob/living/carbon/M)
	var/obj/item/organ/genital/penis/P = M.getorganslot(ORGAN_SLOT_PENIS)
	if(!P)
		return ..()
	var/optimal_size = M.dna.features["cock_length"]
	if(!optimal_size)//Fast fix for those who don't want it.
		P.modify_size(-0.2)
	else if(P.length > optimal_size)
		P.modify_size(-0.1, optimal_size)
	else if(P.length < optimal_size)
		P.modify_size(0.1, 0, optimal_size)
	return ..()
