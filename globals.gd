extends Node


const HOURS_PER_DAY: int = 24
const MINUTES_PER_HOUR: int = 60
const WORLD_TIME_START: int = 12

# Scale measured in hours / second.
const WORLD_TIME_UPDATE_SCALE: float = 24 / (60.0 * 60.0)

const HOUR_SUNRISE = 6
const HOUR_SUNSET = 19
const LENGTH_SUNRISE = 1
const LENGTH_SUNSET = 1

# Deep blue
const COLOR_NIGHT = Color(10 / 255.0, 31 / 255.0, 68 / 255.0)

# Orange/pink
const COLOR_SUNRISE = Color(255 / 255.0, 155 / 255.0, 113 / 255.0)

# Bright sky blue
# const COLOR_DAY = Color(135 / 255.0, 206 / 255.0, 235 / 255.0)

# White
const COLOR_DAY = Color(255 / 255.0, 255 / 255.0, 235 / 255.0)

# Orange/red
const COLOR_SUNSET = Color(255 / 255.0, 69 / 255.0, 0 / 255.0)


class WorldTime:
	var total_hours: float
	
	var days: int:
		get:
			return int(self.total_hours / HOURS_PER_DAY)
	
	var hours: int:
		get:
			return (int(self.total_hours) + WORLD_TIME_START) % HOURS_PER_DAY
	
	var minutes: int:
		get:
			var frac_hours = self.total_hours - floor(self.total_hours)
			return int(frac_hours * MINUTES_PER_HOUR)
			
	var fract_day: float:
		get:
			var frac_hours = self.total_hours - floor(self.total_hours)
			var hours = self.hours + frac_hours
			return hours / HOURS_PER_DAY
	
	func _init():
		self.reset()
		
	func reset():
		self.total_hours = 0
		
	func update(delta: float):
		self.total_hours += delta * WORLD_TIME_UPDATE_SCALE
		
	func _to_string():
		var is_morning = hours < 12
		var visible_hours = self.hours if is_morning else self.hours - 12
		if visible_hours == 0:
			visible_hours = 12
			
		return "Day {days}, {hours}:{minutes} {ampm}".format({
			"days": self.days,
			"hours": visible_hours,
			"minutes": "%02d" % self.minutes,
			"ampm": "am" if is_morning else "pm",
		})


var world_time: WorldTime


func daylight_brightness():
	var t = world_time.hours + world_time.minutes / 60.0
	if HOUR_SUNRISE <= t and t < HOUR_SUNRISE + LENGTH_SUNRISE:  # Sunrise transition (6-7 AM)
		return lerpf(0, LENGTH_SUNRISE, t - HOUR_SUNRISE)
	elif HOUR_SUNRISE + LENGTH_SUNRISE <= t and t < HOUR_SUNSET:  # Daylight period (7 AM - 7 PM)
		return 1.0
	elif HOUR_SUNSET <= t and t < HOUR_SUNSET + LENGTH_SUNSET:  # Sunset transition (7-8 PM)
		return lerpf(1, 0, t - HOUR_SUNSET)
	else:  # Nighttime (8 PM - 6 AM)
		return 0.0


func ambient_light_color():
	var hour = world_time.hours + world_time.minutes / 60.0
	
	if HOUR_SUNRISE <= hour and hour < HOUR_SUNRISE + 1:  # Sunrise transition (6-7 AM)
		return COLOR_NIGHT.lerp(COLOR_SUNRISE, hour - HOUR_SUNRISE)
	elif HOUR_SUNRISE + 1 <= hour and hour < HOUR_SUNRISE + 2:
		return COLOR_SUNRISE.lerp(COLOR_DAY, hour - HOUR_SUNRISE + 1)
	elif HOUR_SUNRISE + 2 <= hour and hour < HOUR_SUNSET - 1:  # Daytime (7 AM - 7 PM)
		return COLOR_DAY
	elif HOUR_SUNSET - 1 <= hour and hour < HOUR_SUNSET:
		return COLOR_DAY.lerp(COLOR_SUNSET, hour - 18)
	elif HOUR_SUNSET <= hour and hour < HOUR_SUNSET + 1:  # Sunset transition (7-8 PM)
		return COLOR_SUNSET.lerp(COLOR_NIGHT, hour - HOUR_SUNSET)
	else:  # Nighttime (8 PM - 6 AM)
		return COLOR_NIGHT
