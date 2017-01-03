BRPVP_actionRunning pushBack 5;
(_this select 3) params ["_from","_to","_fromUnit"];
if (_from call BRPVP_checaAcesso && _to call BRPVP_checaAcesso) then {
	if (isNull _from || {isNull _to}) then {
		["One of the sides\ndon't exists anymore.",5,12,128,"erro"] call BRPVP_hint;
	} else {
		_ttxt = getText (configFile >> "CfgVehicles" >> (typeOf _to) >> "displayName");
		if (_from distance _to > 50) then {
			["You is too far away from the destine.",5,12,128,"erro"] call BRPVP_hint;
		} else {
			if (_fromUnit) then {
				[_from,_to,50,player getVariable ["id_bd",-1]] call BRPVP_transferUnitCargo;
			} else {
				[_from,_to,50,player getVariable ["id_bd",-1]] call BRPVP_transferCargoCargo;
			};
			if (_from call BRPVP_isMotorized) then {
				_ftxt = getText (configFile >> "CfgVehicles" >> (typeOf _from) >> "displayName");
				["Items transfered from " + _ftxt + "\nto " + _ttxt + ".",5,12,128] call BRPVP_hint;
			} else {
				["Items transfered to " + _ttxt + ".",5,12,128] call BRPVP_hint;
			};
		};
	};
} else {
	["You can't transfer.\nNo access to one of the sides.",5,12,128,"erro"] call BRPVP_hint;
};
sleep 2;
BRPVP_actionRunning = BRPVP_actionRunning - [5];