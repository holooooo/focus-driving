extends Node2D

enum City {
	CITY_A,
	CITY_B,
	CITY_C,
	CITY_D,
	CITY_E
}
enum Stage {
	CityRoad,
	Highway,
	CountryRoad,
}
@export var city: City
@export var stage: Stage
@export var TotalDistance: float = 0.0
@export var car: CarResource

@export var speed_scale: float = 1:
	set(value):
		speed_scale = value
		setup_speed()

@onready var background: Node2D = $Background

var current_distance: float = 0.0

func _ready() -> void:
	setup_speed()

func setup_speed()->void:
	if !background:
		return
	var children: Array[Node] = background.get_children()
	for child in children:
		if child is Parallax2D:
			child.autoscroll *= speed_scale
		
