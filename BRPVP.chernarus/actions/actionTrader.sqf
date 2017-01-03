_position = position player;
if (_position select 2 > 1) exitWith {
	playSound "erro";
	["You must be on ground to access the trader.",0] call BRPVP_hint;
};
if (vehicle player != player) exitWith {
	playSound "erro";
	["You must be on foot to access the trader.",0] call BRPVP_hint;
};
_merchant = _this select 3 select 0;
_merchantIndex = _this select 3 select 1;
_merchantTypesAmount = count BRPVP_mercadoresEstoque;
_merchantIndex = _merchantIndex mod _merchantTypesAmount;
BRPVP_mercadorIdc1 = _merchantIndex;
BRPVP_precoMult = _this select 3 select 2;
BRPVP_compraPrecoTotal = 0;
BRPVP_compraItensTotal = [];
BRPVP_compraItensPrecos = [];
_menuOpenOk = 9 call BRPVP_iniciaMenuExtra;
if (_menuOpenOk) then {
	BRPVP_actionRunning pushBack 0;
	waitUntil {!alive player || player distanceSqr _merchant > 400 || !BRPVP_menuExtraLigado};
	if (BRPVP_menuExtraLigado) then {
		BRPVP_menuExtraLigado = false;
		call BRPVP_atualizaDebug;
	};
	BRPVP_actionRunning deleteAt (BRPVP_actionRunning find 0);
} else {
	playSound "erro";
};