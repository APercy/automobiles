--
-- constants
--
coupe={}
coupe.LONGIT_DRAG_FACTOR = 0.12*0.12
coupe.LATER_DRAG_FACTOR = 18.0
coupe.gravity = automobiles_lib.gravity
coupe.max_speed = 22
coupe.max_acc_factor = 8

dofile(minetest.get_modpath("automobiles_lib") .. DIR_DELIM .. "custom_physics.lua")
dofile(minetest.get_modpath("automobiles_lib") .. DIR_DELIM .. "control.lua")
dofile(minetest.get_modpath("automobiles_lib") .. DIR_DELIM .. "fuel_management.lua")
dofile(minetest.get_modpath("automobiles_lib") .. DIR_DELIM .. "ground_detection.lua")
dofile(minetest.get_modpath("automobiles_coupe") .. DIR_DELIM .. "coupe_entities.lua")
dofile(minetest.get_modpath("automobiles_coupe") .. DIR_DELIM .. "coupe_crafts.lua")


