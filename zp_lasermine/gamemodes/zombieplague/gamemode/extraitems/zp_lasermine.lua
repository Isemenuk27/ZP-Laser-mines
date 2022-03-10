ExtraItem.ID = "ZPLaserMine"
ExtraItem.Name = "ExtraItemLaserMineName"
ExtraItem.Price = 6
function ExtraItem:OnBuy(ply)
	local Weap = ply:GetWeapon("zp_laser_weapon")
	if IsValid(Weap) then
		ply:GiveAmmo(1, Weap:GetPrimaryAmmoType(), true) 
	else
		ply:Give("zp_laser_weapon")
	end
end

WeaponManager:AddWeaponMultiplier("zp_laser_weapon", 1)
WeaponManager:AddWeaponMultiplier("zp_laser", 1)

Dictionary:RegisterPhrase("en-us", "ExtraItemLaserMineName", "Laser Mine", false)
Dictionary:RegisterPhrase("pt-br", "ExtraItemLaserMineName", "Laser Mine", false)
Dictionary:RegisterPhrase("es-ar", "ExtraItemLaserMineName", "Laser Mine", false)
Dictionary:RegisterPhrase("ru", "ExtraItemLaserMineName", "Лазерная Мина", false)
Dictionary:RegisterPhrase("uk", "ExtraItemLaserMineName", "Лазерна Міна", false)
Dictionary:RegisterPhrase("tchinese", "ExtraItemLaserMineName", "Laser Mine", false)
Dictionary:RegisterPhrase("ja", "ExtraItemLaserMineName", "Laser Mine", false)
Dictionary:RegisterPhrase("ko", "ExtraItemLaserMineName", "Laser Mine", false)