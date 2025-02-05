extends Node


const HOURS_PER_DAY: int = 24
const MINUTES_PER_HOUR: int = 60
const WORLD_TIME_START: int = 12
const WORLD_TIME_UPDATE_SCALE: float = 0.5


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
		var visible_hours = self.hours if is_morning else self.hours - 11
			
		return "Day {days}, {hours}:{minutes} {ampm}".format({
			"days": self.days,
			"hours": visible_hours,
			"minutes": "%02d" % self.minutes,
			"ampm": "am" if is_morning else "pm",
		})


var world_time: WorldTime
