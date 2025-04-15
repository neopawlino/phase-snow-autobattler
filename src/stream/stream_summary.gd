extends Control

class_name StreamSummary

signal continue_button_pressed

enum StreamResult {
	WIN,
	LOSE,
	DRAW
}

@export var stream_finished_label : Label
@export var stream_title_label : Label

@export var thumbnail : TextureRect

@export var views_label : Label
@export var viewers_label : Label
@export var subscribers_label : Label
@export var subscribers_container : Control
@export var members_label : Label
@export var members_container : Control
@export var total_revenue_label : Label

@export var overlay : CanvasItem

@export var performance_bonus_label : Label
@export var ad_revenue_container : Control
@export var ad_revenue_label : Label
@export var rpm_label : Label
@export var member_revenue_container : Control
@export var member_revenue_label : Label
@export var item_revenue_container : Control
@export var item_revenue_label : Label
@export var abilities_revenue_container : Control
@export var abilities_revenue_label : Label

@export var stream_finished_container : Control
@export var revenue_breakdown_container : Control

@export var stream_titles : Array[String] = [
	"the bestest and greatest stream ever fort night",
	"[ENDURANCE] stream ends when I yab",
	"it's a good announcement i swear",
	"[DONOTHON DAY 228] please send help I am trapped in this nightmare",
	"That one anime song you liked 10 years ago [Cover]",
	"[Minceraft] Collab with HEROBRINE?!!?!",
	"[Zatsu] I LITERALLY ALMOST DIED???? (had breakfast)",
	"[ASMR] eating a $10,000 mic for breakfast",
	"[Art] Making thumbnails! (it's cropped h*ntai)",
	"[ASMR] Betterhelp roleplay (gone bad) (gone wrong) (homicide)",
	"Drinking 10,000 grams of pure caffeine #ad",
	"Top 5 Streamer Simulator Games TIER LIST",
	"Learning Korean so I can say SLURS",
	"Spreading VTubers to war-torn countries! <3",
	"[DONOTHON DAY 128] $1 = 10,000 GACHA PULLS",
	"EASIEST way to get FREE MONEY [gambling]",
	"One secret the IRS DOESN'T want you to know [it's tax fraud]",
	"[Handcam] Cooking without a fire exinguisher CHALLENGE",
	"[ASMR] eating a whole head of cabbage",
	"[zatsu] being funny speedrun any%",
	"[Handcam] Genetically engineering cat girls because no one else will",
	"My response. (to the allegations)",
	"Doing nothing for 12 HOURS",
	"PhaseJam Situation is Crazy",
	"[DONOTHON] $1 = 1 hour locked in a cage with bears",
]

var stream_finished_orig_pos : Vector2
var rev_breakdown_orig_pos : Vector2

func _ready() -> void:
	GlobalSignals.stream_started.connect(on_stream_started)
	GlobalSignals.stream_ended.connect(func(goal_met : bool):
		if goal_met:
			show_stream_summary()
	)
	self.stream_finished_orig_pos = self.stream_finished_container.position
	self.rev_breakdown_orig_pos = self.revenue_breakdown_container.position


func on_stream_started():
	thumbnail.texture = ImageTexture.create_from_image(self.get_viewport().get_texture().get_image())


func show_stream_summary():
	self.update_stream_finished()
	self.update_revenue_breakdown()
	self.show_anim()


func update_stream_finished():
	self.stream_finished_label.text = "Stream Finished - Day %d" % GameState.round_number
	self.stream_title_label.text = self.stream_titles.pick_random()

	self.views_label.text = "%s" % StringUtil.format_number(GameState.stream_manager.views)
	self.viewers_label.text = "%s" % StringUtil.format_number(GameState.stream_manager.peak_viewers)
	self.subscribers_container.visible = GameState.stream_manager.new_subscribers > 0
	self.subscribers_label.text = "%s" % StringUtil.format_number(GameState.stream_manager.new_subscribers)
	self.members_container.visible = GameState.stream_manager.new_members > 0
	self.members_label.text = "%s" % StringUtil.format_number(GameState.stream_manager.new_members)

	var total_revenue := GameState.stream_manager.total_revenue + GameState.stream_manager.ability_revenue
	self.total_revenue_label.text = StringUtil.format_money(total_revenue)


func update_revenue_breakdown():
	self.performance_bonus_label.text = StringUtil.format_money(GameState.stream_manager.get_performance_bonus())

	self.ad_revenue_container.visible = GameState.stream_manager.ad_revenue > 0
	self.ad_revenue_label.text = StringUtil.format_money(GameState.stream_manager.ad_revenue)
	self.rpm_label.text = "(%s per 1,000 views)" % StringUtil.format_money(GameState.stream_manager.ad_rpm)

	self.member_revenue_container.visible = GameState.members > 0
	self.member_revenue_label.text = StringUtil.format_money(GameState.stream_manager.member_revenue)

	# no item revenue yet
	self.item_revenue_container.visible = false

	var ability_revenue := GameState.stream_manager.ability_revenue
	self.abilities_revenue_container.visible = ability_revenue != 0
	self.abilities_revenue_label.text = StringUtil.format_money(ability_revenue)


func show_anim():
	self.overlay.modulate.a = 0
	var tween := self.create_tween()
	tween.tween_property(self.overlay, "modulate:a", 1.0, 0.5)

	self.stream_finished_container.position = self.stream_finished_orig_pos
	self.stream_finished_container.position.y += 1000
	tween.parallel().tween_property(self.stream_finished_container, "position:y", stream_finished_orig_pos.y, 0.5).set_trans(Tween.TRANS_QUAD)

	self.revenue_breakdown_container.position = self.rev_breakdown_orig_pos
	self.revenue_breakdown_container.position.y += 1000
	tween.tween_property(self.revenue_breakdown_container, "position:y", rev_breakdown_orig_pos.y, 0.5).set_trans(Tween.TRANS_QUAD)
	self.show()


func _on_button_pressed() -> void:
	GlobalSignals.stream_results_confirmed.emit()
	self.hide_anim()


func hide_anim():
	var tween := self.create_tween()
	tween.tween_property(self.overlay, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(
		self.stream_finished_container,
		"position:y",
		stream_finished_container.position.y + 1000,
		0.5
	).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(
		self.revenue_breakdown_container,
		"position:y",
		revenue_breakdown_container.position.y + 1000,
		0.5
	).set_trans(Tween.TRANS_QUAD)

	tween.tween_callback(self.hide)
