# Common Functions

This page is just to enumerate all common functionalities, signals and inputs that are used within the project.

The motivation for this page is to have a single source of truth when it comes to integrating scenes between each other.

## Key Board Action Events

In order to use the key board input, use the following action events in your scripts.

- arrow_right: Right Key Press
- arrow_left: Left Key Press
- arrow_down: Down Key Press
- arrow_up: Up Key Press
- space_press: Space Key Press

```python
# Example of how you can go about using action events
if Input.is_action_pressed("arrow_right"):
	# right key functionality here
if Input.is_action_pressed("arrow_left"):
	# left key functionality here
if Input.is_action_pressed("arrow_down"):
	# down key functionality here
if Input.is_action_pressed("arrow_up"):
	# up key functionality here
if Input.is_action_pressed("space_press"):
	# space key functionality here
```
