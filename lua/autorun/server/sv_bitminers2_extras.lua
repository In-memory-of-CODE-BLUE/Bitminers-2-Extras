AddCSLuaFile("bitminers2_extra_config.lua")
include("bitminers2_extra_config.lua")

local P = FindMetaTable("Player")

util.AddNetworkString("BM2.Command.RemoteInstall")
util.AddNetworkString("BM2.Command.ChangeRemoteName")
util.AddNetworkString("BM2.OpenPhone")
util.AddNetworkString("BM2.TerminalPrintEnum")

function P:OpenRemoteBitminers()
	local bitDataTable = {}
	for k, v in pairs(BITMINER_ENTS) do
		if v.isBitminer then
			if v.remoteUser == self then
				table.insert(bitDataTable, v)
			end
		end
	end

	net.Start("BM2.OpenPhone")
	net.WriteTable(bitDataTable)
	net.Send(self)
end

hook.Add("PlayerSay", "BM2.OpenPhoneCheck", function(ply, text)
	if string.lower(text) == string.lower(BM2EXTRACONFIG.RemoteAccessCommand) then
		ply:OpenRemoteBitminers() 
	end
end)

net.Receive("BM2.Command.RemoteInstall", function(len, ply)
	local e = net.ReadEntity() or nil
	local installOrUninstall = net.ReadBool() or false

	if not IsValid(e) then return end

	if e:GetPos():Distance(e:GetPos()) > 300 then return end
	if e.isBitminer then
		e:CleanAuthorisedPlayers()
	end
	
	if e ~= nil and table.HasValue(e.authorisedPlayers or {}, ply) then
		if installOrUninstall then
			--Check its not already installed
			if e.remoteInstalled == true then
				if e.remoteUser == ply then 
					net.Start("BM2.TerminalPrintEnum")
					net.WriteUInt(1, 4)
					net.Send(ply)
					return 
				end --This user already has it installed for themself
			end

			--Check they have the funds
			if ply:canAfford(BM2EXTRACONFIG.RemoteAccessPrice) then
				ply:addMoney(-BM2EXTRACONFIG.RemoteAccessPrice) 
				e.remoteInstalled = true
				e.remoteUser = ply

				net.Start("BM2.TerminalPrintEnum")
				net.WriteUInt(2, 4)
				net.Send(ply)
			else
				net.Start("BM2.TerminalPrintEnum")
				net.WriteUInt(3, 4)
				net.Send(ply)
			end
		else
			e.remoteInstalled = false
			e.remoteUser = nil
			net.Start("BM2.TerminalPrintEnum")
			net.WriteUInt(4, 4)
			net.Send(ply)
		end
	end
end)

