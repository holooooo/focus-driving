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
@export var stage:Stage
@export var TotalDistance: float = 0.0
@export var car: CarResource

var current_distance: float = 0.0