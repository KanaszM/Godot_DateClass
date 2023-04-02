# Godot 4.x Date Class
The `Date` class is a powerful tool for precise manipulation of `day`, `month`, `year` values. It can set, clamp, increment, and format these values, and also generate calendars and calculate `ISO 8601` day and week numbers.

## Description
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
