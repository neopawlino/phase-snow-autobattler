extends Node

const KBS : String = "KBS"
const PREVIEW_VIEWPORT_CONTAINER : String = "PreviewViewportContainer"

var stream_camera : Camera2D


func find_kbs(node : Node):
	return node.find_parent(KBS)


func find_preview_viewport(node : Node):
	return node.find_parent(PREVIEW_VIEWPORT_CONTAINER)


func get_screenspace_position(node : Node, viewport_position : Vector2) -> Vector2:
	var result_pos := Vector2.ZERO
	var screen_size := self.get_viewport().get_visible_rect().size
	var kbs : Window = self.find_kbs(node)
	if kbs:
		# top left corner of KBS
		result_pos += Vector2(kbs.position)
		var preview_viewport : SubViewportContainer = self.find_preview_viewport(node)
		if preview_viewport:
			var camera_center := stream_camera.get_screen_center_position()
			var camera_top_left := camera_center - (preview_viewport.size / stream_camera.zoom / 2.0)
			var node_pos_from_camera := viewport_position - camera_top_left
			# top left corner of preview viewport
			result_pos += preview_viewport.position
			# preview viewport is scaled
			result_pos += node_pos_from_camera * stream_camera.zoom * preview_viewport.scale
		else:
			result_pos += viewport_position
	# TODO shop window
	return result_pos
