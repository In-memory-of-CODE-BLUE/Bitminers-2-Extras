include("shared.lua")

surface.CreateFont( "BM2GeneratorFont", {
	font = "Roboto Lt", 
	extended = false,
	size = 40,
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

local solarMaterial = Material("materials/bitminers2/ui/solar-panel.png", "noclamp smooth")
local outputMaterial = Material("materials/bitminers2/ui/output.png", "noclamp smooth")
local warningMaterial = Material("materials/bitminers2/ui/warning.png", "noclamp smooth")

local white = Color(255,255,255,255)
local black = Color(0,0,0,255)

function ENT:DrawPowerWarning()
	--Draw the warning
	surface.SetMaterial(warningMaterial)
	surface.SetDrawColor(white)
	surface.DrawTexturedRect(-80, -300, 160, 160)

	draw.SimpleText("Can't Outout enough power!", "BM2GeneratorFont", 0, -110, black, 1, 1)
	draw.SimpleText("Can't Outout enough power!", "BM2GeneratorFont", -1, -111, white, 1, 1)

	draw.SimpleText("Connect more solar panels or disconnect some bitminers!", "BM2GeneratorFont", 0, -75, black, 1, 1)
	draw.SimpleText("Connect more solar panels or disconnect some bitminers!", "BM2GeneratorFont", -1, -76, white, 1, 1)
end

function ENT:DrawSolarWarning()
	surface.SetMaterial(warningMaterial)
	surface.SetDrawColor(white)
	surface.DrawTexturedRect(-80, -60, 160, 160)

	draw.SimpleText("No connected solar panels!", "BM2GeneratorFont", 0, 170, black, 1, 1)
	draw.SimpleText("No connected solar panels!", "BM2GeneratorFont", -1, 171, white, 1, 1)

	draw.SimpleText("Please connect some solar panels.", "BM2GeneratorFont", 0, 170 - 35, black, 1, 1)
	draw.SimpleText("Please connect some solar panels.", "BM2GeneratorFont", -1, 170 - 34, white, 1, 1)
end

function ENT:DrawPowerUsed(amountUsed, maximum, color, alpha)
	surface.SetMaterial(outputMaterial)
	surface.SetDrawColor(Color(255,165,0, 255 * alpha))
	surface.DrawTexturedRect(-196,74, 56, 56)

	draw.RoundedBox(4, -130, 74, 330, 52, Color(36,36,36,  255 * alpha))
	draw.RoundedBox(2, -128, 76, 326, 52 - 4, Color(15,15,15, 255 * alpha))
	draw.RoundedBox(2, -128, 76, 326 * math.Clamp(maximum > 0 and amountUsed/maximum or 0, 0.0, 1.0), 52 - 4, color)
	draw.SimpleText(amountUsed.."/"..maximum.."W", "BM2GeneratorFont", 45, 24 + 76, Color(0,0,0, 255 * alpha), 1, 1)
	draw.SimpleText(amountUsed.."/"..maximum.."W", "BM2GeneratorFont", 44, 24 + 75, Color(255,255,255, 255 * alpha), 1, 1)
end

function ENT:DrawConnectedSolarPanels(alpha)
	surface.SetMaterial(solarMaterial)
	surface.SetDrawColor(Color(255,165,0, 255 * alpha))
	surface.DrawTexturedRect(-200 + 4,4, 56, 56)

	draw.RoundedBox(4, -130, 4 , 330, 52, Color(36,36,36,  255 * alpha))
	draw.RoundedBox(2, -128, 6 , 326, 52 - 4, Color(15,15,15, 255 * alpha))
	draw.RoundedBox(2, -128, 6 , 326 * (self:GetConnectedPanels()/10), 52 - 4, Color(255,165,0,  255 * alpha))
	draw.SimpleText(self:GetConnectedPanels().."/10", "BM2GeneratorFont", 45, 24 + 6, Color(0,0,0, 255 * alpha), 1, 1)
	draw.SimpleText(self:GetConnectedPanels().."/10", "BM2GeneratorFont", 44, 24 + 5, Color(255,255,255, 255 * alpha), 1, 1)
end

function ENT:DrawTranslucent()
	self:DrawModel()

	if LocalPlayer():GetPos():DistToSqr(self:GetPos()) < 350 * 350 then
		self.cam2d3dAng = LerpAngle(7 * FrameTime(), self.cam2d3dAng ~= nil and self.cam2d3dAng or Angle(0,0,0), Angle(0,LocalPlayer():GetAngles().y - 90,90))

		--Cam 2D3D for drawing infomation
		local ang = self:GetAngles()
		local pos = self:GetPos() + Vector(0,0,35)

		local alpha = 1 - math.Clamp((LocalPlayer():GetPos():DistToSqr(self:GetPos()) / (350 * 350)) * 1.21, 0, 1)

		cam.Start3D2D(pos, self.cam2d3dAng, 0.05)
			if not self:GetShowNoConnectedSolarWarning() then
				draw.RoundedBox(8,-200, -10 , 410, 75 * 2 ,Color(0,0,0,100 * alpha))

				self:DrawConnectedSolarPanels(alpha)

				local powerUsed = self:GetPowerConsumpsion()
				local powerAvailable = self:GetMaxPowerConsumpsion()

				local color = powerUsed > powerAvailable and Color(255,40,20,255 * alpha) or Color(255,165,0,255*alpha)

				self:DrawPowerUsed(powerUsed, powerAvailable, color, alpha)

				if powerUsed > powerAvailable then
					self:DrawPowerWarning()
				end
			else
				self:DrawSolarWarning()
			end
		cam.End3D2D()
	end
end