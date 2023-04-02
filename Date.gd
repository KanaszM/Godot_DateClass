extends RefCounted
class_name Date

#    MIT License
#
#    Copyright (c) 2023 Kanasz Mihai
#
#    Permission is hereby granted, free of charge, to any person obtaining a copy
#    of this software and associated documentation files (the "Software"), to deal
#    in the Software without restriction, including without limitation the rights
#    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#    copies of the Software, and to permit persons to whom the Software is
#    furnished to do so, subject to the following conditions:
#
#    The above copyright notice and this permission notice shall be included in all
#    copies or substantial portions of the Software.
#
#    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#    SOFTWARE.

## The [Date] class is a powerful tool for precise manipulation of [member day], [member month], [member year] values.
## It can set, clamp, increment, and format these values, and also generate calendars and calculate
## [code]ISO 8601[/code] day and week numbers.
##
## [b]Overriding Parameters[/b][br]
## Methods that include the parameters [code]d[/code], [code]m[/code], and [code]y[/code] allow for the overriding of
## the [member day], [member month], and [member year] values within the class. If any of these arguments are set to an
## integer value, the corresponding member will be replaced with the provided value. If any of these arguments are left
## null, the method will use the respective member value. This provides a flexible way to modify specific date
## components within the method while keeping other components intact.
## [br][br][b]Builder Pattern[/b][br]
## Any method that returns a [Date] value will in fact return the same class reference. This enables the use of the
## builder pattern, allowing for chained method calls to set different components at once.
##     [codeblock]
##     func _ready():
##         # Calling the Date constructor without any arguments, will return the current date.
##         date: Date = Date.new()
##         # Combine the set_day() and set_year() methods to set both the day and year of the date object.
##         date.set_day(4).set_year(1991)
##     [/codeblock]
## [br][br][b]Formatting Dates[/b][br]
## When using the [method format_day], [method format_month] or [method format_year] methods, the [code]format[/code]
## parameter can be either a string or an integer, indicating the number of characters in the desired format. For any
## other format length, the function returns the full name of the day or month.
##     [codeblock]
##     func _ready() -> void:
##         var date: Date = Date.new(1, 1, 2000)
##         # All will print: "Jan"
##         print(date.format_month(3))
##         print(date.format_month("mmm"))
##         print(date.format_month("XyZ"))
##     [/codeblock]
## [br]The [method join_formats] can then be used to join multiple [method format_day], [method format_month]
## or [method format_year] methods regardless of order or quantity.
##     [codeblock]
##     func _ready() -> void:
##         var date: Date = Date.new(10, 11, 2002)
##         # Will print: "2002-10-November-Sun"
##         print(date.join_formats([
##             date.format_year(4),
##             date.format_day(2),
##             date.format_month(4),
##             date.format_day(4),
##         ]))
##     [/codeblock]

#*************************************************************************
# Constants
#*************************************************************************
const MAX_CALENDAR_DAYS: int = 42
const ZELLER_CONGRUENCE: Array = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
const DAYS: Array = [
	"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
	]
const MONTHS: Array = [
	"January", "February", "March", "April", "May", "June", "July", "August",
	"September", "October", "November", "December"
	]

#*************************************************************************
# Public Variables
#*************************************************************************
## The current day of the month. Can be set either directly or by calling [method set_day].
var day: int = 0: set = set_day

## The current month of the year. Can be set either directly or by calling [method set_month].
var month: int = 0: set = set_month

## The current year. Can be set either directly or by calling [method set_year].
var year: int = 0: set = set_year

## The minimum allowed value for the "year" variable. Can be set either directly or by calling [method set_min_year].
var min_year: int = 1000: set = set_min_year

## The maximum allowed value for the "year" variable. Can be set either directly or by calling [method set_max_year].
var max_year: int = 9999: set = set_max_year

#*************************************************************************
# Virtual Methods
#*************************************************************************
## This constructor initializes a date object, with the option to provide values for the
## [member day], [member month], and [member year].
## If any of these values are omitted, they will be replaced with the current day, month, or year,
## respectively, using the [method get_today] function.
func _init(d: int = get_today().day, m: int = get_today().month, y:int = get_today().year) -> void:
	set_day(d).set_month(m).set_year(y)

#*************************************************************************
# Increment Methods
#*************************************************************************
## Increment the [member day] value positively if the [code]mode[/code] parameter is [code]True[/code] else negatively
## by the value of [code]max_iteration[/code].
##     [codeblock]
##     If the day value is less than 1, the month value will also be decremented by 1.
##     If the day value is greater than the last day of the current month, the month value will also be incremented by 1.
##     [/codeblock]
## [br]The [day] value will be clamped between 1 and the last day of the [month].
func increment_day(mode: bool, max_iteration: int = 1) -> Date:
	var current_iteration: int = 0
	while current_iteration < max_iteration:
		match mode:
			true: day += 1
			false: day -= 1
		if day > get_days_in_month():
			increment_month(true)
			day = 1
		elif day < 1:
			increment_month(false)
			day = get_days_in_month()
		current_iteration += 1
	return self


## Increment the [member month] value positively if the [code]mode[/code] parameter is [code]True[/code] else negatively
## by the value of [code]max_iteration[/code].
##     [codeblock]
##     If the month value is less than 1, the year value will also be decremented by 1.
##     If the month value is greater than 12, the year value will also be incremented by 1.
##     [/codeblock]
## [br]Lastly, the [member month] value will be clamped between 1 and 12.
func increment_month(mode: bool, max_iteration: int = 1) -> Date:
	var current_iteration: int = 0
	while current_iteration < max_iteration:
		match mode:
			true: month += 1
			false: month -= 1
		if month > 12:
			month = 1
			year += 1
		elif month < 1:
			month = 12
			year -= 1
		current_iteration += 1
	return self


## Increment the [member year] value positively if the [code]mode[/code] parameter is [code]True[/code] else negatively
## by the value of [code]max_iteration[/code].
func increment_year(mode: bool, max_iteration: int = 1) -> Date:
	return set_year((year + max_iteration) if mode else (year - max_iteration)).set_day(day)

#*************************************************************************
# Format Methods
#*************************************************************************
## Formats the day of the month according to the specified [code]format[/code] length.
##     [codeblock]
## * Length 1: returns the day with no leading zeros.
## * Length 2: returns the day with a leading zero if necessary to make it two digits.
## * Length 3: returns a string containing the abbreviated name of the day of
## the week corresponding to the day of the month. The abbreviation is two characters long.
## * Length 4: returns a string containing the abbreviated name of the day of
## the week corresponding to the day of the month. The abbreviation is three characters long.
##     [/codeblock]
func format_day(format, d: int = day, m: int = month, y: int = year) -> String:
	match format.length() if format is String else int(format):
		1: return str(d)
		2: return str(d).pad_zeros(2)
		3: return DAYS[get_weekday(d, m, y)].left(2)
		4: return DAYS[get_weekday(d, m, y)].left(3)
		_: return DAYS[get_weekday(d, m, y)]


## Formats the month of the year according to the specified [code]format[/code] length.
##     [codeblock]
## * Length 1: returns the month with no leading zeros.
## * Length 2: returns the month with a leading zero if necessary (padded with zeros on the left to a width of 2).
## * Length 3: returns the abbreviation of the month (e.g. "Jan" for January).
## * Length 4: returns the full name of the month (e.g. "January" for January).
##     [/codeblock]
func format_month(format, m: int = month) -> String:
	match format.length() if format is String else int(format):
		1: return str(m)
		2: return str(m).pad_zeros(2)
		3: return MONTHS[m - 1].left(3)
		_: return MONTHS[m - 1]


## If the length of the [code]format[/code] is greater than or equal to 4, the function returns the year as a string
## with all digits. If the length of the [code]format[/code] is less than 4, the function returns the last two digits
## of the year as a string (padded with zeros on the left to a width of 2 if necessary).
func format_year(format, y: int = year) -> String:
	return str(y) if (format.length() if format is String else int(format)) >= 4 else str(y).right(2)


## Returns a single string that concatenates all the formatted strings together, separated by the specified delimiter.
## If no delimiter is specified, the function defaults to using a hyphen.
func join_formats(formatted_strings: PackedStringArray, delimiter: String = "-") -> String:
	return delimiter.join(formatted_strings)

#*************************************************************************
# Getter Methods
#*************************************************************************
## Returns the number of days in a [member month] from the [member year].
func get_days_in_month(m: int = month, y: int = year) -> int:
	var _m: int = clamp_month(m)
	var _y: int = clamp_year(y)
	if _m in PackedInt32Array([4, 6, 9, 11]):
		return 30
	elif _m == 2:
		match (_y % 4 == 0 and _y % 100 != 0) or (_y % 400 == 0):
			true: return 29
			false: return 28
	return 31


## Returns the [member day], [member month] and [member year] values in a dictionary.
func get_dict() -> Dictionary:
	return {"day": day, "month": month, "year": year}


## Returns the current date in a dictionary.
func get_today(utc: bool = false) -> Dictionary:
	var system_date: Dictionary = Time.get_date_dict_from_system(utc)
	return {"day": system_date.day, "month": system_date.month, "year": system_date.year}


## Returns an integer representing the day of the week, where Sunday is 6, Monday is 0, and so on.
func get_weekday(d: int = day, m: int = month, y: int = year) -> int:
	var _d: int = clamp_day(d, m ,y)
	var _m: int = clamp_month(m)
	var _y: int = clamp_year(y)
	var dd: int = ZELLER_CONGRUENCE[_m - 1] + _d - 1
	var yy: int = _y - 1 if _m < 3 else _y
	return ((yy + int(yy / 4.0) - int(yy / 100.0) + int(yy / 400.0) + dd) % 7)


## Returns an integer representing the day of the week for the last day of the year.
func get_last_week_day_of_year(y: int = year) -> int:
	var _y: int = clamp_year(y)
	return (_y + int(_y / 4.0) - int(_y / 100.0) + int(_y / 400.0)) % 7


## Returns an integer representing the number of weeks in the specified year.
func get_number_of_weeks_of_year(y: int = year) -> int:
	return 52 + (1 if get_last_week_day_of_year(y) == 4 or get_last_week_day_of_year(clamp_year(y) - 1) == 3 else 0)


## Returns an integer representing the day of the year in ISO format.
func get_iso_day_of_year(d: int = day, m: int = month, y: int = year) -> int:
	return int((_get_unix(d, m, y) - _get_unix_first_day_of_year(y)) / 86400.0) + 1


## Returns the ISO week number.
func get_iso_week_number(d: int = day, m: int = month, y: int = year) -> int:
	var iso_day_of_year: int = get_iso_day_of_year(d, m, y) - 1
	var iso_weekday: int = (get_last_week_day_of_year(y - 1) + iso_day_of_year) % 7 + 1
	var iso_week_number: int = int(float(iso_day_of_year + 1 - iso_weekday + 10) / 7.0)
	if iso_week_number < 1:
		return get_number_of_weeks_of_year(y - 1)
	elif iso_week_number > get_number_of_weeks_of_year(y):
		return 1
	return iso_week_number

#*************************************************************************
# Calendar Methods
#*************************************************************************
## Generates a dictionary representing a calendar month with 42 integer keys, one for each day slot. If a day slot does
## not correspond to a day in the month, the value of that specific key will be empty, else, the value of that specific
## key will be a sub-dictionary containing the day number, the row number, the week number, and the weekday number.[br]
## The weekday number follows the convention where Sunday is represented as 6, Monday as 0, and so on.
##     [codeblock]
##     var date: Date = Date.new(1, 4, 2023) # A date representing April 1, 2023
##     var calendar: Dictionary = date.get_calendar_dict()
##     for day_idx in calendar:
##         print("%d = %s" % [day_idx, calendar[day_idx]])
##     [/codeblock]
##[br]Will print:
##     [codeblock]
##     0 = {  }
##     1 = {  }
##     2 = {  }
##     3 = {  }
##     4 = {  }
##     5 = { "day": 1, "row": 0, "week": 13, "weekday": 5 }
##     6 = { "day": 2, "row": 0, "week": 13, "weekday": 6 }
##     7 = { "day": 3, "row": 1, "week": 14, "weekday": 0 }
##     8 = { "day": 4, "row": 1, "week": 14, "weekday": 1 }
##     9 = { "day": 5, "row": 1, "week": 14, "weekday": 2 }
##     10 = { "day": 6, "row": 1, "week": 14, "weekday": 3 }
##     11 = { "day": 7, "row": 1, "week": 14, "weekday": 4 }
##     12 = { "day": 8, "row": 1, "week": 14, "weekday": 5 }
##     ... and so on until 41
##     [/codeblock]
func get_calendar_dict(m: int = month, y: int = year) -> Dictionary:
	var _m: int = clamp_month(m)
	var _y: int = clamp_year(y)
	var calendar_dict: Dictionary = {}
	var day_first: int = get_weekday(1, _m, _y)
	var day_count: int = 1
	for day_idx in MAX_CALENDAR_DAYS:
		calendar_dict[day_idx] = {}
		if day_idx in range(day_first, get_days_in_month(_m, _y) + day_first):
			calendar_dict[day_idx] = {
				"day": day_count,
				"row": int(day_idx / 7.0),
				"week": get_iso_week_number(day_count, _m, _y),
				"weekday": get_weekday(day_count, _m, _y)
				}
			day_count += 1
	return calendar_dict


## Generates an array of 6 rows, each row representing a week in the calendar month.
##     [codeblock]
##     var date: Date = Date.new(1, 4, 2023) # A date representing April 1, 2023
##     var calendar: Array = date.get_calendar_array2d()
##     for row in calendar:
##         print(row)
##     [/codeblock]
##[br]Will print:
##     [codeblock]
##     ["  ", "  ", "  ", "  ", "  ", "01", "02"]
##     ["03", "04", "05", "06", "07", "08", "09"]
##     ["10", "11", "12", "13", "14", "15", "16"]
##     ["17", "18", "19", "20", "21", "22", "23"]
##     ["24", "25", "26", "27", "28", "29", "30"]
##     ["  ", "  ", "  ", "  ", "  ", "  ", "  "]
##     [/codeblock]
func get_calendar_array2d(m: int = month, y: int = year) -> Array:
	var calendar_array2d: Array = []
	var calendar_dict: Dictionary = get_calendar_dict(m, y)
	var last_day_idx: int = 0
	for row_idx in sqrt(MAX_CALENDAR_DAYS) - 1:
		var row: PackedStringArray = PackedStringArray([])
		var row_range: PackedInt32Array = PackedInt32Array(range(last_day_idx, last_day_idx + 7))
		row.resize(7)
		row.fill("  ")
		for idx in row_range.size():
			var day_idx: int = row_range[idx]
			if not calendar_dict[day_idx].is_empty():
				row[idx] = str(calendar_dict[day_idx].day).pad_zeros(2)
			if idx == row_range.size() - 1:
				last_day_idx = day_idx + 1
		calendar_array2d.append(row)
	return calendar_array2d

#*************************************************************************
# Misc Methods
#*************************************************************************
## Prints out a formatted calendar based on the result generated by the [method get_calendar_array2d] function with an
## additional title on top consisting of the full name of the month and the four-digit year + the abbreviations of the
## days of the week.
func print_calendar_array2d(m: int = month, y: int = year) -> void:
	print("> %s / %d" % [format_month(4, m), year])
	print((DAYS as Array).map(func substr(text: String) -> String: return text.substr(0, 2)))
	get_calendar_array2d(m, y).any(func print_row(row: Array) -> void: print(row))

#*************************************************************************
# Setter Methods
#*************************************************************************
## Sets the [member day], [member month], [member year] values to the corresponding values of the current date (today).
func set_today() -> Date:
	set_day(get_today().day).set_month(get_today().month).set_year(get_today().year)
	return self


## Chainable setter for [member day]. It will automatically clamp the day according the set [member month] and
## [member year] values by using the [method clamp_day] function.
func set_day(d: int) -> Date:
	day = clamp_day(d, month, year)
	return self


## Chainable setter for [member month]. The value is automatically clamped by using the [method clamp_month] function.
func set_month(m: int) -> Date:
	month = clamp_month(m)
	return self


## Chainable setter for [member year]. The value is automatically clamped by using the [method clamp_year] function.
func set_year(y: int) -> Date:
	year = clamp_year(y)
	return self


## Chainable setter for [member min_year]. The value is automatically clamped by using the [method clamp_year_bounds]
## function.
func set_min_year(value: int) -> Date:
	min_year = clamp_year_bounds(value)
	return self


## Chainable setter for [member max_year]. The value is automatically clamped by using the [method clamp_year_bounds]
## function.
func set_max_year(value: int) -> Date:
	max_year = clamp_year_bounds(value)
	return self

#*************************************************************************
# Clamp Methods
#*************************************************************************
## Returns the day clamped to the valid range for the given month and year.
## It uses the [method get_days_in_month] function to determine the number of days in the given month and year,
## and clamps the day to the range 1 to that number.
func clamp_day(d: int = day, m: int = month, y: int = year) -> int:
	return clampi(d, 1, get_days_in_month(m, y))

## Returns the month clamped to the range 1 to 12.
func clamp_month(m: int = month) -> int:
	return clampi(m, 1, 12)

## Returns the year clamped to the range specified by [member min_year] and [member max_year].
func clamp_year(y: int = year) -> int:
	return clampi(y, min_year, max_year)

## Returns the year value clamped to the range 1000 to 9999.
func clamp_year_bounds(value: int) -> int:
	return clampi(value, 1000, 9999)

#*************************************************************************
# Private Methods
#*************************************************************************
func _get_unix(d: int = day, m: int = month, y: int = year) -> int:
	return Time.get_unix_time_from_datetime_dict(
		{"day": clamp_day(d, m, y), "month": clamp_month(m), "year": clamp_year(y)}
		)


func _get_unix_first_day_of_year(y: int = year) -> int:
	return Time.get_unix_time_from_datetime_dict({"year": clamp_year(y), "month": 1, "day": 1})
