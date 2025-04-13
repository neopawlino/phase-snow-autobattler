extends Node

var main_slots : SlotContainer
var bench_slots : SlotContainer
var items : Items
var stream_manager : StreamManager
var shop_manager : ShopManager
var ability_slots : AbilitySlots

var is_dragging : bool = false:
	set(val):
		is_dragging = val
		is_dragging_changed.emit(val)
signal is_dragging_changed(value : bool)
# we can swap when we're dragging a character already in our team, but not from the shop
var drag_can_swap : bool = false
var drag_object : Node:
	set(drag_obj):
		drag_object = drag_obj
		drag_object_changed.emit(drag_obj)
signal drag_object_changed(drag_obj : Node)
var drag_original_slot : Slot
var drag_end_slot : Slot
var drag_parent : Node
var drag_sell_button : bool
var drag_initial_mouse_pos : Vector2

var player_money : float:
	set(val):
		if val > player_money:
			total_earnings += val - player_money
		player_money = val
		player_money_changed.emit(val)
signal player_money_changed(value: float)

var starting_money : float = 15.0

var inflation_coeff : float = 1.0:
	set(val):
		inflation_coeff = val
		inflation_changed.emit(val)
signal inflation_changed(val : float)
var inflation_mult_per_round : float = 1.2

var player_hp : int:
	set(val):
		player_hp = val
		player_hp_changed.emit(val)
signal player_hp_changed(value: int)

var max_interest : int = 5

var round_number : int:
	set(val):
		round_number = val
		round_number_changed.emit(val)
signal round_number_changed(value: int)

var wins : int:
	set(val):
		wins = val
		wins_changed.emit(val)
signal wins_changed(value: int)

var wins_needed : int:
	set(val):
		wins_needed = val
		wins_needed_changed.emit(val)
signal wins_needed_changed(value: int)


var hard_mode : bool


var cheats_enabled : bool:
	set(val):
		cheats_enabled = val
		cheats_enabled_changed.emit(val)
signal cheats_enabled_changed(value : bool)


var viewer_goal : float = 10:
	set(val):
		viewer_goal = val
		viewer_goal_changed.emit(val)
signal viewer_goal_changed(value: int)

var base_viewer_goal : float = 10.0

var subscribers : float = 1:
	set(val):
		subscribers = val
		subscribers_changed.emit(val)
signal subscribers_changed(value: int)

var initial_subscribers : float = 1.0

var members : float = 0:
	set(val):
		members = val
		members_changed.emit(val)
signal members_changed(value: int)

var initial_members : float = 0

var base_views_per_sec : float = 10.0
var base_viewer_retention : float = 0.1
var base_subscriber_rate : float = 0.1
var base_member_rate : float = 0.1

var highest_views : float
var highest_viewers : float

var total_earnings : float:
	set(val):
		total_earnings = val
		total_earnings_changed.emit(val)
signal total_earnings_changed(val: float)

var viewer_goal_exp_base : float = 1.2
var starting_viewer_goal_exp_base : float = 1.2
var max_viewer_goal_exp_base : float = 1.4
var viewer_goal_exp_base_increase_per_round : float = 0.01

var victory_screen_shown : bool = false
var victory_sub_count : float = 1000000


func get_interest() -> int:
	var interest_cap := get_interest_cap()
	return min(int(player_money / 5), interest_cap)


func get_interest_cap() -> int:
	var interest_cap := max_interest
	if items:
		for item in items.get_items(&"interest_cap_up"):
			interest_cap += 5
	return interest_cap


var paused : bool = false:
	set(val):
		paused = val
		paused_changed.emit(val)
		get_tree().paused = val
signal paused_changed(is_paused : bool)


func _ready() -> void:
	GlobalSignals.stream_results_confirmed.connect(func():
		round_number += 1
		viewer_goal_exp_base += viewer_goal_exp_base_increase_per_round
		viewer_goal_exp_base = minf(viewer_goal_exp_base, max_viewer_goal_exp_base)
		viewer_goal = get_viewer_goal(round_number)
	)
	GlobalSignals.stream_end_anim_finished.connect(func():
		self.player_money += self.stream_manager.total_revenue
		if self.subscribers >= victory_sub_count and not victory_screen_shown:
			GlobalSignals.victory.emit()
	)
	GlobalSignals.stream_results_confirmed.connect(increase_inflation)
	self.reset()


func reset() -> void:
	self.viewer_goal = self.base_viewer_goal
	self.subscribers = self.initial_subscribers
	self.members = self.initial_members
	self.round_number = 1
	self.player_money = self.starting_money
	self.wins = 0
	self.highest_views = 0
	self.highest_viewers = 0
	self.total_earnings = 0
	self.victory_screen_shown = false
	self.inflation_coeff = 1.0


func get_viewer_goal(round_num : int) -> float:
	return base_viewer_goal * pow(viewer_goal_exp_base, round_num-1)


func increase_inflation():
	self.inflation_coeff *= self.inflation_mult_per_round


func restart_game() -> void:
	self.reset()
	get_tree().reload_current_scene()
