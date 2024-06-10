extends Node3D
class_name Guide

signal done

var points_:Points
var hit_ := false
var miss_ := false
var points_service
var fall_tween_:Tween
var active := false
