extends Node

var signals: Dictionary = {}

func connect_signal(signal_name: String, callback: Callable) -> void:
	if not signals.has(signal_name):
		signals[signal_name] = []
	signals[signal_name].append(callback)

func emit(signal_name: String, data: Variant = null) -> void:
	if signals.has(signal_name):
		for callback in signals[signal_name]:
			callback.call(data)
