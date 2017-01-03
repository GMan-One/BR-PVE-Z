_position = position player;
if (_position select 2 > 1) exitWith {
	playSound "erro";
	["You must be on ground to access the trader.",0] call BRPVP_hint;
};
if (vehicle player != player) exitWith {
	playSound "erro";
	["You must be on foot to access the trader.",0] call BRPVP_hint;
};
_trader = _this select 3 select 0;
BRPVP_vendaveAtivos = [
	_this select 3 select 1,
	_this select 3 select 2,
	_this select 3 select 3
];
_menuOpenOk = 13 call BRPVP_iniciaMenuExtra;
if (_menuOpenOk) then {
	BRPVP_actionRunning pushBack 1;
	waitUntil {!alive player || player distanceSqr _trader > 400 || !BRPVP_menuExtraLigado};
	if (BRPVP_menuExtraLigado) then {
		BRPVP_menuExtraLigado = false;
		call BRPVP_atualizaDebug;
	};
	BRPVP_actionRunning deleteAt (BRPVP_actionRunning find 1);
} else {
	playSound "erro";
};