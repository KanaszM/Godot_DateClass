# Godot 4.x Date Class
[![Made with Godot](https://img.shields.io/badge/Godot%204.0-478CBF?style=flat&logo=godot%20engine&logoColor=white)](https://godotengine.org)

The `Date` class is a powerful tool for precise manipulation of `day`, `month`, `year` values. It can set, clamp, increment, and format these values, and also generate calendars and calculate `ISO 8601` day and week numbers.

## How to Use
1. Place the `Date.gd` file anywhere in your project directory.
2. Call the `Date(day: int, month: int, year: int)` constructor to create a new `Date` object. If any of these arguments are omitted, they will default to the current day, month, or year.
```javascript
var date_today: Date = Date() // Will create a date with the current date values
var date_first_of_april_2023: Date = Date(1, 4, 2023) // Will create a date representing the first of April 2023
```
* The `day`, `month` or `year` values can be changed by assigning values directly or by calling the `set_day`, `set_month`, `set_year` methods.
The set values will be automatically clamped, meaning that setting `date.day = 50` will be clamped to the last day of the current `date.month`
* The `increment_day`, `increment_month`, `increment_year` methods can be used to increment positively if the `mode` parameter is `True` else negatively by the value of `max_iteration` parameter.
```javascript
var date: Date = Date(30, 4, 2023) // A date representing the last of April 2023
date.increment_day(True, 1) // Will increment the day value by one. The date will now change to represent the first of May 2023
```
> **Consider the in-engine documentation for more information on the class members and methods.**

## Calendar Generators
* The method `get_calendar_array2d` generates an array of 6 rows, each row representing a week in the calendar month:
```javascript
var date: Date = Date.new(1, 4, 2023) // A date representing April 1, 2023
var calendar: Array = date.get_calendar_array2d()
for row in calendar:
    print(row)
```
```
["  ", "  ", "  ", "  ", "  ", "01", "02"]
["03", "04", "05", "06", "07", "08", "09"]
["10", "11", "12", "13", "14", "15", "16"]
["17", "18", "19", "20", "21", "22", "23"]
["24", "25", "26", "27", "28", "29", "30"]
["  ", "  ", "  ", "  ", "  ", "  ", "  "]
```

---

* The method `get_calendar_dict` generates a dictionary representing a calendar month with 42 integer keys, one for each day slot. If a day slot does not correspond to a day in the month, the value of that specific key will be empty, else, the value of that specific key will be a sub-dictionary containing the day number, the row number, the week number, and the weekday number. The weekday number follows the convention where Sunday is represented as 6, Monday as 0, and so on.
```javascript
var date: Date = Date.new(1, 4, 2023) // A date representing April 1, 2023
var calendar: Dictionary = date.get_calendar_dict()
for day_idx in calendar:
    print("%d = %s" % [day_idx, calendar[day_idx]])
```
```
0 = {  }
1 = {  }
2 = {  }
3 = {  }
4 = {  }
5 = { "day": 1, "row": 0, "week": 13, "weekday": 5 }
6 = { "day": 2, "row": 0, "week": 13, "weekday": 6 }
7 = { "day": 3, "row": 1, "week": 14, "weekday": 0 }
8 = { "day": 4, "row": 1, "week": 14, "weekday": 1 }
9 = { "day": 5, "row": 1, "week": 14, "weekday": 2 }
10 = { "day": 6, "row": 1, "week": 14, "weekday": 3 }
11 = { "day": 7, "row": 1, "week": 14, "weekday": 4 }
12 = { "day": 8, "row": 1, "week": 14, "weekday": 5 }
... and so on until 41
```

## Features
### Overriding Parameters
Methods that include the parameters `d`, `m`, and `y` allow for the overriding of the `day`, `month`, and `year` values within the class. If any of these arguments are set to an integer value, the corresponding member will be replaced with the provided value. If any of these arguments are left null, the method will use the respective member value. This provides a flexible way to modify specific date components within the method while keeping other components intact.

---

### Builder Pattern
Any method that returns a `Date` value will in fact return the same class reference. This enables the use of the builder pattern, allowing for chained method calls to set different components at once.

```javascript
func _ready():
    // Calling the Date constructor without any arguments, will return the current date.
    date: Date = Date.new()
    // Combine the set_day() and set_year() methods to set both the day and year of the date object.
    date.set_day(4).set_year(1991)
```

---

### Formatting Dates
When using the `format_day()`, `format_month()` or `format_year(`) methods, the `format` parameter can be either a string or an integer, indicating the number of characters in the desired format. For any other format length, the function returns the full name of the day or month.

```javascript
func _ready() -> void:
    var date: Date = Date.new(1, 1, 2000)
    // All will print: "Jan"
    print(date.format_month(3))
    print(date.format_month("mmm"))
    print(date.format_month("XyZ"))
```

The `join_formats()` can then be used to join multiple `format_day()`, `format_month()` or `format_year()` methods regardless of order or quantity.

```javascript
func _ready() -> void:
    var date: Date = Date.new(10, 11, 2002)
    // Will print: "2002-10-November-Sun"
    print(date.join_formats([
        date.format_year(4),
        date.format_day(2),
        date.format_month(4),
        date.format_day(4),
    ]))
```

## Links and Resources
Other noteworthy date, time, calendar repositories on GitHub:
* [Calendar Button Plugin for Godot Engine 3.2.3 by Ivan Skodje](https://github.com/ivanskodje-godotengine/godot-plugin-calendar-button)
* [Godot Date Time by William Christian - verillious](https://github.com/verillious/godot-datetime)
* [godot-date by Calinou](https://github.com/Calinou/godot-date)

[And much more...](https://github.com/search?q=godot+date)
