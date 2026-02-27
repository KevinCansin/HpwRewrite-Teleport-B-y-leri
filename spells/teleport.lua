local Spell = { }
Spell.LearnTime = 25
Spell.ApplyFireDelay = 0.4
Spell.Level = 1
Spell.Ders = "Büyücülük"
Spell.Description = [[
    Belirli bir konuma ışınlar.
]]

Spell.AccuracyDecreaseVal = 0
Spell.ShouldSay = false
Spell.NodeOffset = Vector(-1270, 60, 0)

game.AddParticles( 'particles/alien_crash_fx.pcf' )
PrecacheParticleSystem( 'alien_teleportin' )
PrecacheParticleSystem( 'alien_teleport' )
Spell.IconMat = Material( 'phxspellicons/teleport.png' )

if SERVER then
	util.AddNetworkString("isinlanmenusend")
	util.AddNetworkString("isinlanmaserver")
	local min = 5
	net.Receive("isinlanmaserver", function()
		local konum = net.ReadVector()
		local oyuncu = net.ReadEntity()
		ParticleEffectAttach( 'alien_teleport', 1, oyuncu, 1)
		local oldCollision = oyuncu:GetCollisionGroup() or COLLISION_GROUP_PLAYER
		timer.Simple(1.5, function()
			oyuncu:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR) 
			oyuncu:SetPos(konum)
		end)
		timer.Simple(20, function()
			oyuncu:SetCollisionGroup(oldCollision) 
		end)
	end)
else
	local mekanlar = {
		{
			mekan = "Ön Sur",
			konum = Vector( 813.195435, -696.984314, -9600.897461)
		},
		{
			mekan = "Botanik",
			konum = Vector( 13.669552, -9213.409180, -9611.666992)
		},
		{
			mekan = "Taş Avlu",
			konum = Vector( -12518.220703, -6645.712402, -9882.915039)
		},
		{
			mekan = "Hogsmeade",
			konum = Vector( 6035.051758, -1394.534668, 12937.778320)
		},
		{
			mekan = "Sihir Bakanlığı",
			konum = Vector( -11713.032227, -10917.336914, -15154.878906)
		},
		{
			mekan = "S.Y.B. Alanı",
			konum = Vector( 12514.899414, -7050.852539, -11619.955078)
		},
		{
			mekan = "Baykuş Kulesi",
			konum = Vector( 6409.388672, 6476.623047, -8357.775391)
		},
	}
	local function isinlanmamenusuac()
		local scrw, scrh = ScrW(), ScrH()
		local isinlanmemenu = vgui.Create( "DFrame" )
		isinlanmemenu:SetSize( scrw* .2, scrh*.5 ) 
		isinlanmemenu:SetTitle( "" ) 
		isinlanmemenu:SetVisible( true ) 
		isinlanmemenu:SetPos(scrw* .1, scrh*.3)
		isinlanmemenu:ShowCloseButton( true ) 
		isinlanmemenu:MakePopup()
		isinlanmemenu.Paint = function(me, w, h)
			surface.SetDrawColor(30,30,30,255)
			surface.DrawRect( 0, 0, w, h )
		end
	
		local DScrollPanel = vgui.Create( "DScrollPanel", isinlanmemenu )
		DScrollPanel:Dock( FILL )
	
		for k, v in pairs(mekanlar) do
			local DButton = DScrollPanel:Add( "DButton" )
			DButton:SetText( v.mekan)
			DButton:SetSize(scrw*.05, scrh*.05)
			DButton:Dock( TOP )
			DButton:DockMargin( 0, 0, 0, 5 )
			DButton.DoClick = function()
				local ply = LocalPlayer()
				for k,oyuncu in pairs(ents.FindInSphere( ply:GetPos(), 160 )) do
					if oyuncu:IsPlayer() then 
						net.Start("isinlanmaserver")
							net.WriteVector(v.konum)
							net.WriteEntity(oyuncu)
						net.SendToServer()
					end
				end
			end
		end
	end
	
	net.Receive("isinlanmenusend", isinlanmamenusuac)
end
function Spell:OnFire(wand)
	ParticleEffectAttach( 'alien_teleportin', 1, self.Owner, 1)
	local ply = self.Owner;
	net.Start("isinlanmenusend")
	net.Send(ply)
end

HpwRewrite:AddSpell("Teleport", Spell)
