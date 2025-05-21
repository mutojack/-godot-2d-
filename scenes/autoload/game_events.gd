extends Node

signal experience_vial_collected(number: int)
signal ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary)
signal player_damaged
signal item_collected(item: BasicDrop)
signal auto_fire_changed(open: bool)
signal player_stats_changed(player_info: Player)
signal level_up_play
signal use_consumable(item: BasicDrop)

func emit_experience_vial_collected(number: int):
	experience_vial_collected.emit(number)


func emit_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	ability_upgrade_added.emit(upgrade, current_upgrades)


func emit_player_damaged():
	player_damaged.emit()


func emit_item_collected(item: BasicDrop):
	item_collected.emit(item)


func emit_auto_fire_changed(open: bool):
	auto_fire_changed.emit()


func emit_player_stats_changed(player_info: Player):
	player_stats_changed.emit(player_info)
	

func emit_level_up_play():
	level_up_play.emit()
	

func emit_use_consumable(item: BasicDrop):
	use_consumable.emit(item)
