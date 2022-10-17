extends AnimatedSprite

func _on_AnimatedSprite_animation_finished():
	get_parent().queue_free()
