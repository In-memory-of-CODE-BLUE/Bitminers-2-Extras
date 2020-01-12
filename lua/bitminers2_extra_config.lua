BM2EXTRACONFIG = {}

--The capacity of the extra fuel tanks
BM2EXTRACONFIG.ExtraFuelTankSize = 5000 

--Then someone destroyed a fuel tank that still has fuel in it it will explopde.
--This will disable it if set to true
BM2EXTRACONFIG.DisableFuelTankExplosion = false

--If set to true this will disable the requirment of solar panels having power
--Setting this to false will require that solar panels have direct line of sight with the skybox
BM2EXTRACONFIG.DisableLightRequirment = false

--This is how much it costs to purchase the remote access upgrade on a bitminer
BM2EXTRACONFIG.RemoteAccessPrice = 2500

--This is the command used to access the phone in game
BM2EXTRACONFIG.RemoteAccessCommand = "!remotebitminers"

--Edit the entities here
hook.Add("BM2_DLC_loadCustomDarkRPItems", "BM2.RegisterEntities", function()
	DarkRP.createEntity("Fuel Line", {
		ent = "bm2_extra_fuel_line",
		model = "models/bitminers2/bm2_extra_fuel_plug.mdl",
		price = 1500,
		max = 2,
		cmd = "buyfuelline",
		category = "Bitminers 2"
	}) 

	DarkRP.createEntity("Large Fuel", {
		ent = "bm2_large_fuel",
		model = "models/props/de_train/barrel.mdl",
		price = 4000,
		max = 4,
		cmd = "buylargefuel",
		category = "Bitminers 2"
	})

	DarkRP.createEntity("Fuel Tank", {
		ent = "bm2_extra_fuel_tank",
		model = "models/bitminers2/bm2_extra_fueltank.mdl",
		price = 10000,
		max = 2,
		cmd = "buyfueltank",
		category = "Bitminers 2"
	})

	DarkRP.createEntity("Solar Cable", {
		ent = "bm2_solar_cable",
		model = "models/bitminers2/bm2_solar_plug.mdl",
		price = 500,
		max = 10,
		cmd = "buysolarcable",
		category = "Bitminers 2"
	})

	DarkRP.createEntity("Solar Converter", {
		ent = "bm2_solarconverter",
		model = "models/bitminers2/bm2_solar_converter.mdl",
		price = 20000,
		max = 1,
		cmd = "buysolarconverter",
		category = "Bitminers 2"
	})

	DarkRP.createEntity("Solar Panel", {
		ent = "bm2_solar_panel",
		model = "models/bitminers2/bm2_solar_panel.mdl",
		price = 15000,
		max = 10,
		cmd = "buysolarpanel",
		category = "Bitminers 2"
	})
end)