BRPVP_actionRunning pushBack 8;
_price = _this select 3 select 0;
_money= player getVariable "mny";
if (_money >= _price) then {
	player setVariable ["mny",_money - _price,true];
	playSound "negocio";
	_ruins = _this select 3 select 1;
	playSound3D [BRPVP_missionRoot + "BRP_sons\bulldozer.ogg",_ruins,false,getPosASL _ruins,2,1,0];
	sleep 2.6;
	deleteVehicle _ruins;
} else {
	playSound "erro";
	["You don't have the money!",0] call BRPVP_hint;
};
BRPVP_actionRunning = BRPVP_actionRunning - [8];
