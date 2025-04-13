extends Control

@export var stream_manager : StreamManager

@export var viewer_goal : Label
@export var views : Label
@export var views_per_sec : Label
@export var viewer_retention : Label
@export var viewers : Label
@export var subscriber_rate : Label
@export var subscribers : Label
@export var member_rate : Label
@export var members : Label
@export var money : Label

@export var goal_progress_bar : ProgressBar
@export var goal_mult_label : Label

@export var goal_hit_sound : AudioStream
@export var goal_hit_particles : CPUParticles2D

var goal_hit_tween : Tween


func _ready() -> void:
	stream_manager.viewer_goal_changed.connect(update_viewer_goal)
	stream_manager.views_changed.connect(update_views)
	stream_manager.views_per_sec_changed.connect(update_views_per_sec)
	stream_manager.viewer_retention_changed.connect(update_viewer_retention)
	stream_manager.viewers_changed.connect(update_viewers)
	stream_manager.subscriber_rate_changed.connect(update_subscriber_rate)
	GameState.subscribers_changed.connect(update_subscribers)
	stream_manager.member_rate_changed.connect(update_member_rate)
	GameState.members_changed.connect(update_members)
	GameState.player_money_changed.connect(update_money)

	stream_manager.goal_hit.connect(func():
		update_viewer_goal(stream_manager.viewer_goal)
		play_goal_hit_effect()
	)

	GlobalSignals.stream_started.connect(show_anim)
	GlobalSignals.stream_started.connect(update_all)
	GlobalSignals.stream_ended.connect(func(_goal_met : bool): hide_anim())


func show_anim():
	self.modulate = Color(Color.WHITE, 0)
	self.show()
	var tween := self.create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.5).set_trans(Tween.TRANS_SINE)


func hide_anim():
	var tween := self.create_tween()
	tween.tween_property(self, "modulate", Color(Color.WHITE, 0), 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(self.hide)


func update_all():
	update_viewer_goal(stream_manager.viewer_goal)
	update_views(stream_manager.views)
	update_views_per_sec(stream_manager.views_per_sec)
	update_viewer_retention(stream_manager.viewer_retention)
	update_viewers(stream_manager.viewers)
	update_subscriber_rate(stream_manager.subscriber_rate)
	update_subscribers(GameState.subscribers)
	update_member_rate(stream_manager.member_rate)
	update_members(GameState.members)
	update_money(GameState.player_money)


func update_viewer_goal(amt : float):
	viewer_goal.text = StringUtil.format_number(amt)
	goal_progress_bar.min_value = 0
	goal_progress_bar.max_value = amt
	goal_progress_bar.value = fmod(stream_manager.peak_viewers, stream_manager.viewer_goal)
	var times_hit_goal := minf(9999.0, stream_manager.times_hit_goal)
	if times_hit_goal > 0:
		goal_mult_label.text = "%dx" % times_hit_goal
	else:
		goal_mult_label.text = ""


func play_goal_hit_effect():
	var pitch_add := clampf(lerpf(0.0, 1.0, stream_manager.times_hit_goal / 10.0), 0.0, 1.0)
	SoundManager.play_sound(goal_hit_sound, 0.0, pitch_add)
	goal_hit_particles.emitting = true

	if goal_hit_tween:
		goal_hit_tween.kill()
	goal_hit_tween = self.create_tween()
	goal_hit_tween.tween_property(
		goal_mult_label, "scale", Vector2.ONE * 1.5, 0.02
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	goal_hit_tween.tween_property(
		goal_mult_label, "scale", Vector2.ONE, 0.4
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_delay(0.1)


func update_views(amt : float):
	views.text = StringUtil.format_number(amt)


func update_views_per_sec(amt : float):
	views_per_sec.text = "(%s/sec)" % StringUtil.format_number(amt)


func update_viewer_retention(amt : float):
	viewer_retention.text = "(%d%%)" % (amt * 100.0)


func update_viewers(amt : float):
	viewers.text = StringUtil.format_number(amt)
	update_viewer_goal(stream_manager.viewer_goal)


func update_subscriber_rate(amt : float):
	subscriber_rate.text = "(%d%%)" % (amt * 100.0)


func update_subscribers(amt : float):
	subscribers.text = StringUtil.format_number(amt)


func update_member_rate(amt : float):
	member_rate.text = "(%d%%)" % (amt * 100.0)


func update_members(amt : float):
	members.text = StringUtil.format_number(amt)


func update_money(amt : float):
	money.text = StringUtil.format_money(amt)
