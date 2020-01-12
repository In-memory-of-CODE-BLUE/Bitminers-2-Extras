include("bitminers2_extra_config.lua")

local screenOverlay = Material("bitminers2/ui/screen_overlay.png", "smooth")
local screenBackground = Material("bitminers2/ui/screen_background.png", "smooth")
local screenTitlebar = Material("bitminers2/ui/screen_titlebar.png", "smooth")
local screenPanel = Material("bitminers2/ui/bitminer_panel.png", "noclamp smooth")
local UI_OPEN = false

surface.CreateFont( "Bitminers2ExtrasPhone", {
	font = "Roboto Lt",
	extended = false,
	size = 23,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

local BITMINERS2_TERMINAL_STRINGS = {
	[1] = "Failed to install! : 0x6753c2890 Already installed for this user!",
	[2] = "Remote module has been installed! Type !remotebitminer to access it remotely!",
	[4] = "Remote module has been uninstalled. No one can access this bitminer remotely anymore."
}

net.Receive("BM2.TerminalPrintEnum", function()
	--Have to get it here, otherwise darkrp isnt initialized
	BITMINERS2_TERMINAL_STRINGS[3] = "Failed to install! : 0x676f62b020 Cannot Afford. You need '$"..DarkRP.formatMoney(BM2EXTRACONFIG.RemoteAccessPrice).."'!"
	BM2TerminalPrint(BITMINERS2_TERMINAL_STRINGS[net.ReadUInt(4)])
end)

local white = Color(255,255,255,255)
 
local function OpenRemoteBitminers(bitminers)

	if UI_OPEN then return end

	UI_OPEN = true

	local phone = vgui.Create("DFrame")
	phone:SetSize(315, 605)
	phone:Center()
	phone:SetTitle("")
	phone:ShowCloseButton(false)
	phone:MakePopup()
	phone.Paint = function(s, w, h)
		surface.SetDrawColor(white)
		surface.SetMaterial(screenBackground)
		surface.DrawTexturedRectRotated(157, 303, w, h, 0)

		surface.SetMaterial(screenOverlay)
		surface.DrawTexturedRectRotated(157, 303, w, h, 0)
	end
	phone.Close = function(s)
		UI_OPEN = false
		s:Remove()
	end 

	--Contet for the panels
	local scrollPanel = vgui.Create("DScrollPanel", phone)
	scrollPanel:SetPos(19, 130) 
	scrollPanel:SetSize(279, 400)
	scrollPanel:GetVBar():SetWide(0)

	--Show all the bitminers
	for k, v in pairs(bitminers) do
		local panel = vgui.Create("DButton", scrollPanel)
		panel:SetSize(268, 53)
		panel:SetText("")
		panel:SetPos(5, 5 + ((k-1) * (45)))
		panel.lerp = 0.8
		panel.Paint = function(s, w, h)
			s.lerp = Lerp(10 * FrameTime(), s.lerp, s:IsHovered() and 1 or 0.8)

			surface.SetDrawColor(Color(255,255,255, 255 * s.lerp))
			surface.SetMaterial(screenPanel)
			surface.DrawTexturedRectRotated(134, 26, w, h, 0)	

			draw.SimpleText(v.remoteName or "Unknown", "Bitminers2ExtrasPhone", 20, 10, Color(0,0,0,255 * s.lerp), 0, 0)
		end
		panel.DoClick = function(s)
			BM2OpenTerminal(v)
		end
	end

	local titleBar = vgui.Create("DPanel", phone)
	titleBar:SetSize(283, 10)
	titleBar:SetPos(17, 98)
	titleBar.Paint = function(s, w, h)
		surface.SetDrawColor(white)
		surface.SetMaterial(screenTitlebar)
		surface.DrawTexturedRectRotated(141, 5, 280, 79, 0)			
	end
	titleBar:NoClipping(true)

	local closeButton = vgui.Create("DButton", phone)
	closeButton:SetSize(315, 75)
	closeButton:SetText("")
	closeButton.DoClick = function(s) phone:Close() end
	closeButton.Paint = function() end

	local closeButton2 = vgui.Create("DButton", phone)
	closeButton2:SetSize(315, 75)
	closeButton2:SetPos(0, 540)
	closeButton2:SetText("")
	closeButton2.DoClick = function(s) phone:Close() end
	closeButton2.Paint = function() end
end

net.Receive("BM2.OpenPhone", function()
	local bitData = net.ReadTable()
	OpenRemoteBitminers(bitData)
end) 