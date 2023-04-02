# Godot 4.x Date Class
The `Date` class is a powerful tool for precise manipulation of `day`, `month`, `year` values. It can set, clamp, increment, and format these values, and also generate calendars and calculate `ISO 8601` day and week numbers.

## Features
### Overriding Parameters
Methods that include the parameters `d`, `m`, and `y` allow for the overriding of the `day`, `month`, and `year` values within the class. If any of these arguments are set to an integer value, the corresponding member will be replaced with the provided value. If any of these arguments are left null, the method will use the respective member value. This provides a flexible way to modify specific date components within the method while keeping other components intact.

### Builder Pattern
Any method that returns a `Date` value will in fact return the same class reference. This enables the use of the builder pattern, allowing for chained method calls to set different components at once.

```godot
func _ready():
    # Calling the Date constructor without any arguments, will return the current date.
    date: Date = Date.new()
    # Combine the set_day() and set_year() methods to set both the day and year of the date object.
    date.set_day(4).set_year(1991)
```

### Formatting Dates
When using the `format_day()`, `format_month()` or `format_year(`) methods, the `format` parameter can be either a string or an integer, indicating the number of characters in the desired format. For any other format length, the function returns the full name of the day or month.

```godot
func _ready() -> void:
    var date: Date = Date.new(1, 1, 2000)
    # All will print: "Jan"
    print(date.format_month(3))
    print(date.format_month("mmm"))
    print(date.format_month("XyZ"))
```

The `join_formats()` can then be used to join multiple `format_day()`, `format_month()` or `format_year()` methods regardless of order or quantity.

```godot
func _ready() -> void:
    var date: Date = Date.new(10, 11, 2002)
    # Will print: "2002-10-November-Sun"
    print(date.join_formats([
        date.format_year(4),
        date.format_day(2),
        date.format_month(4),
        date.format_day(4),
    ]))
```
