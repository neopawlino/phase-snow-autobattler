extends Node

static func binomial(tries : float, prob : float) -> float:
	if tries < 100:
		var acc : int = 0
		for i in range(0,tries):
			acc += bernoulli(prob)
		return float(acc)
	else:
		return abs(randfn(tries*prob,tries*prob*(1.0-prob)))

#1 or 0
static func bernoulli(prob : float) -> int:
	return int(randf() < prob)


var all_characters_rg : ResourceGroup = load("res://resources/all_characters.tres")
var all_character_definitions : Array[CharacterDefinition]

var all_items_rg : ResourceGroup = load("res://resources/all_items.tres")
var all_item_definitions : Array[ItemDefinition]

var all_abilities_rg : ResourceGroup = load("res://resources/all_abilities.tres")
var all_ability_definitions : Array[AbilityDefinition]


func _ready() -> void:
	all_characters_rg.load_all_into(all_character_definitions)
	all_items_rg.load_all_into(all_item_definitions)
	all_abilities_rg.load_all_into(all_ability_definitions)


func random_ability() -> AbilityDefinition:
	return all_ability_definitions.pick_random()


func random_abilities_no_dupes(count : int) -> Array[AbilityDefinition]:
	var dupe := all_ability_definitions.duplicate()
	dupe.shuffle()
	return dupe.slice(0, count)
