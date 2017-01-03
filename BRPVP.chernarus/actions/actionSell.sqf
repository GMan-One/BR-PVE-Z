_index = _this select 3;
if (vehicle player == player) then {
	_posPlayer = getposATL player;
	_dirPlayer = getDir player;
	_posBox = [(_posPlayer select 0) + 1.25 * sin _dirPlayer,(_posPlayer select 1) + 1.25 * cos _dirPlayer,_posPlayer select 2];
	_box = createVehicle ["Box_NATO_Wps_F",_posBox,[],0,"NONE"];
	_box setVectorUp surfaceNormal _posBox;
	_box setDir getDir player;
	_box allowDamage false;
	clearWeaponCargoGlobal _box;
	clearMagazineCargoGlobal _box;
	clearBackPackCargoGlobal _box;
	clearItemCargoGlobal _box;
	_box setVariable ["own",player getVariable "id_bd",true];
	_box setVariable ["amg",player getVariable "amg",true];
	_box setVariable ["stp",0,true];
	_box setVariable ["bidx",_index,true];
	_arrow = "Sign_Arrow_F" createVehicleLocal [0,0,0];
	_arrow attachTo [_box,[0,0,1]];
	BRPVP_sellReceptacle = _box;
	BRPVP_sellStage = 2;
	BRPVP_pegaVaultPlayerBdRetorno = nil;
	BRPVP_pegaVaultPlayerBd = [player,_index];
	publicVariableServer "BRPVP_pegaVaultPlayerBd";
} else {
	["You must leave the vehicle to access\nthe sell receptacle. ",0] call BRPVP_hint;
};