//CHECK FOR ACTUAL MAP HOUSE
_mapHouses = [];
{
	if (_x getVariable ["mapa",false]) then {
		_mapHouses pushBack _x;
	};
} forEach BRPVP_myStuff;
if (count _mapHouses > 0) then {
	["You must first revoke your actual map house.",0] call BRPVP_hint;
} else {
	_house = _this select 3;
	_owner = _house getVariable ["own",-1];
	if (_owner == -1) then {
		//GARANTEE THIS MAP HOUSE
		_house setVariable ["own",player getVariable ["id_bd",-1],true];
		_house setVariable ["amg",player getVariable ["amg",[]],true];
		_house setVariable ["stp",player getVariable ["dstp",1],true];
		_house setVariable ["mapa",true,true];

		//ADD NEW MAP HOUSE
		BRPVP_myStuff pushBack _house;
		["mastuff"] call BRPVP_atualizaIcones;
		["This is now your map house!",0] call BRPVP_hint;
		
		//ADD MAP HOUSE TO DB IF NEEDED
		if (_house getVariable ["id_bd",-1] == -1) then {
			BRPVP_ownedHousesAdd = _house;
			publicVariableServer "BRPVP_ownedHousesAdd";
			_objectInfoArray = [
				[[[],[]],[[],[]],[[],[]],[[],[]]],
				[getPosWorld _house,[vectorDir _house,vectorUp _house]],
				_house call BRPVP_typeOf,
				_house getVariable ["own",-1],
				_house getVariable ["stp",1],
				_house getVariable ["amg",[]],
				""
			];
			BRPVP_adicionaConstrucaoBd = [true,_house,_objectInfoArray];
			publicVariableServer "BRPVP_adicionaConstrucaoBd";
		};
	} else {
		if (_owner == player getVariable ["id_bd",-1]) then {
			["This is already your map house!",0] call BRPVP_hint;
		} else {
			playSound "erro";
			["You can't. This map house is already taken by someone...",0] call BRPVP_hint;
		};
	};
};