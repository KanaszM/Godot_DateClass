# Godot 4.x Date Class
The `Date` class is a powerful tool for precise manipulation of `day`, `month`, `year` values. It can set, clamp, increment, and format these values, and also generate calendars and calculate `ISO 8601` day and week numbers.
___
## Description
Methods that include the parameters `d`, `m`, and `y` allow for the overriding of the day, month, and year values within the class. If any of these arguments are set to an integer value, the corresponding member will be replaced with the provided value. If any of these arguments are left null, the method will use the respective member value. This provides a flexible way to modify specific date components within the method while keeping other components intact.
