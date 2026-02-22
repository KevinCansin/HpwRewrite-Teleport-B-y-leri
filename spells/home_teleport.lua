local Spell = {}
Spell.LearnTime = 25
Spell.ApplyFireDelay = 0.5
Spell.Level = 3
Spell.Ders = "Büyücülük"
Spell.Description = [[
    Hane Işınlanma Büyüsü]]

Spell.AccuaryDecreaseVal = 0
Spell.ShouldSay = false 
Spell.NodeOffsey = Vector(-1270, 60, 0)

game.AddParticles('particles/alien_crash_fx.pcf') -- Bu partikülü değiştirebilirsin
PrecacheParticleSystem('alien_teleport') -- Bunuda değiştirlebilirsin
PrecacheParticleSystem('alien_teleportin') -- Bunuda değiştirebilirsin
Spell.IconMat = Material('materials/teleport.png') -- Büyü ikon resmini kendin eklicen bende yok

if SERVER then
    util.AddNetworkString("haneteleportsend")
    util.AddNetworkString("haneteleportserver")
    local min = 1
    net.Receive("haneteleportserver", function()
        local alan = net.ReadVector()
        local oyuncu = net.ReadEntity()
        ParticleEffectAttach('alien_teleport', 1, kisi, 1)
        local oldCollision = kisi:GetCollisionGroup() or COLLISION_GROUP_PLAYER
        timer.Simple(1.5, function()
            kisi:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
            kisi:SetPos(alan)
        end)
        timer.Simple(10, function()
            kisi:SetCollisionGroup(oldCollision)
        end)
    end)
else
    local haneler = { -- HABE KONUMLARINI KENDİ HARİTANIZA GÖRE XYZ KOORDİNATLARINI BURADAKİ VECTOR DEĞERLERİNE YAZIN
        {
            hane = "Gryffindor"
            konum = Vector(0, 0, 0) 
        },
        {
            hane = "Hufflepuff"
            konum = Vector(0, 0, 0)
        },
        {
            hane = "Ravenclaw"
            konum = Vector(0, 0, 0)
        }, 
        {
            hane = "Slytherin"
            konum = Vector(0, 0, 0)
        },
    }
    local function oyuncununHanesi()
        local ply = LocalPlayer()
        local team = ply:Team()

        for _, v in ipairs(haneler) do
            if v.faction and team == v.faction then
                return v
            end
        end

        return nil
    end

    local function hanemenuac()
        local scrw, scrh = ScrW(), ScrH()

        local hanemenu = vgui.Create("DFrame")
        hanemenu:SetSize(scrw * 0.3, scrh * 0.5)
        hanemenu:SetTitle("Hane Teleport")
        hanemenu:SetVisible(true)
        hanemenu:SetPos(scrw * 0.1, scrh * 0.3)
        hanemenu:MakePopup()

        hanemenu.Paint = function(me, w, h)
            local ply = LocalPlayer()
            local team = ply:Team()

            if team == FACTION_SLYTHERIN then
                surface.SetDrawColor(18, 209, 24, 200)
            elseif team == FACTION_RAVENCLAW then
                surface.SetDrawColor(19, 16, 204, 200)
            elseif team == FACTION_HUFFLEPUFF then
                surface.SetDrawColor(223, 226, 26, 200)
            elseif team == FACTION_GRYFFINDOR then
                surface.SetDrawColor(234, 23, 23, 200)
            else
                surface.SetDrawColor(50, 50, 50, 200)
            end

            surface.DrawRect(0, 0, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(0, 0, 0, 100))
        end

        local DScrollPanel = vgui.Create("DScrollPanel", hanemenu)
        DScrollPanel:Dock(FILL)

        local oyununHane = oyuncununHanesi()

        if not oyununHane then
            local label = vgui.Create("DLabel", DScrollPanel)
            label:SetText("Bir haneye ait değilsin.")
            label:SetTextColor(Color(255, 255, 255))
            label:Dock(TOP)
            label:SetTall(40)
            label:SetContentAlignment(5)
            return
        end

        local btn = vgui.Create("DButton", DScrollPanel)
        btn:SetText(oyununHane.hane .. " Hanesine Işınlan")
        btn:Dock(TOP)
        btn:SetTall(50)
        btn:DockMargin(5, 5, 5, 5)

        btn.Paint = function(me, w, h)
            local col = me:IsHovered() and Color(80, 80, 80, 220) or Color(40, 40, 40, 200)
            draw.RoundedBox(6, 0, 0, w, h, col)
        end

        btn.DoClick = function()
            net.Start("haneteleportserver")
                net.WriteVector(oyununHane.konum)
                net.WriteEntity(LocalPlayer())
            net.SendToServer()
            hanemenu:Close()
        end
    end

    Spell.ClientFunction = function(kisi)
        hanemenuac()
    end

    net.Receive("hanemenusend", hamemenuac)
end
function Spell:OnFire(wand)
    ParticleEffectAttach('ailen_teleportin', 1, self.Owner, 1)
    local ply = self.Owner;
    net.Start("hanemenusned")
    net.Send(ply)
end

HpwRewrite:AddSpell("Hane Teleport", Spell)