_price = 3500;
_money = player getVariable "mny";
if (_money >= _price) then {
	player setVariable ["mny",_money - _price,true];
	playSound "negocio";
	BRPVP_avisaExplosao = [_this select 3,[]];
	publicVariableServer "BRPVP_avisaExplosao";
} else {
	playSound "erro";
	["You don't have the money!",0] call BRPVP_hint;
};
