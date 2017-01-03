_house = _this select 3;
_owner = _house getVariable ["own",-1];
if (_owner != -1 && _owner == player getVariable ["id_bd",-1]) then {
	BRPVP_actionRunning pushBack 4;
	_posPlayer = getPosASL player;
	_moved = false;
	for "_c" from 0 to 4 do {
		[format["Don't move for %1 seconds to revoke your house!",5-_c],0] call BRPVP_hint;
		sleep 1;
		if (_posPlayer distance (getposASL player) > 1) exitWith {_moved = true;};
	};
	if (!_moved) then {
		if (_owner != -1 && _owner == player getVariable ["id_bd",-1]) then {
			[[_house],""] call BRPVP_mudaDonoPropriedade;
			["You revoked this house, now it is public!",0] call BRPVP_hint;
		};
	} else {
		["You moved... process canceled!",0] call BRPVP_hint;
	};
	BRPVP_actionRunning deleteAt (BRPVP_actionRunning find 4);
};