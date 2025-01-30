extends Control


@export var title_label : Label
@export var description_label : RichTextLabel
@export var item_popup : Popup


func show_item_popup(item_rect : Rect2i, item_def : ItemDefinition):
	if item_def != null:
		update_from_item_definition(item_def)
		item_popup.size = Vector2i.ZERO

	var mouse_pos := get_viewport().get_mouse_position()
	var correction : Vector2i
	var padding := 4

	if mouse_pos.x <= get_viewport_rect().size.x/2:
		correction = Vector2i(item_rect.size.x + padding, 0)
	else:
		correction = -Vector2i(item_popup.size.x + padding, 0)

	item_popup.popup(Rect2i(item_rect.position + correction, item_popup.size))


func hide_item_popup():
	item_popup.hide()


func update_from_item_definition(item_def : ItemDefinition):
	title_label.text = item_def.display_name
	description_label.text = item_def.description_text
