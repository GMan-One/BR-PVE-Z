//ARMA 3 + CUP ASSETS
_veicSpawnCivCars = [];
_veicSpawnCivHelis = [];
_veicSpawnMilCarsArm = [];
_veicSpawnMilCarsDes = [];
_veicSpawnMilHelisArm = [];
_veicSpawnMilHelisDes = [];
_veicSpawnMilApcsArm = [];
_veicSpawnMilApcsDes = [];
_veicSpawnMilTanksArm = [];
_veicSpawnMilTanksDes = [];
_CUPVeicSpawnCivCars = [];
_CUPVeicSpawnCivHelis = [];
_CUPVeicSpawnMilCarsArm = [];
_CUPVeicSpawnMilCarsDes = [];
_CUPVeicSpawnMilHelisArm = [];
_CUPVeicSpawnMilHelisDes = [];
_CUPVeicSpawnMilApcsArm = [];
_CUPVeicSpawnMilApcsDes = [];
_CUPVeicSpawnMilTanksArm = [];
_CUPVeicSpawnMilTanksDes = [];

BRPVP_tudoA3 = [];
_allDescr = [];
_facExcluida = BRPVP_mapaRodando select 17;
{
	_lado = "";
	_fac = "";
	_cat = "";
	if (isNumber (_x >> "side")) then {
		_ladoN = getNumber (_x >> "side");
		switch _ladoN do {
			case 0 : {_lado = "COMUNISM";};
			case 1 : {_lado = "CAPTALISM";};
			case 2 : {_lado = "GUERRILLA";};
			case 3 : {_lado = "CIVIL";};
		};
	};
	if (isText (_x >> "faction")) then {
		_facC = getText (_x >> "faction");
		_fac = getText (configFile >> "CfgFactionClasses" >> _facC >> "displayName");
	};
	if (isText (_x >> "editorSubcategory")) then {
		_catC = getText (_x >> "editorSubcategory");
		_cat = getText (configFile >> "CfgEditorSubcategories" >> _catC >> "displayName");
	};
	if (_lado == "CIVIL") then {
		if !(_fac in ["Civilians","Civilians (Chenarus)","Civilians (Takistan)","Civilians (Russian)"]) then {_fac = "";};
	} else {
		if (_fac in ["Others","Other","Civilians"]) then {_fac = "";};
	};
	if (_cat in ["Turrets","Targets","Storage","Drones","Submersibles","Boats"]) then {_cat = "";};
	if (_lado != "" && (_fac != "" && !(_fac in _facExcluida)) && _cat != "") then {
		_classe = configName _x;
		_passa = ({_classe find _x >= 0} count ["_base","_Base","_BASE"]) == 0;
		if (_passa) then {
			if !(_classe isKindOf "Man") then {
				if (isText (_x >> "displayName")) then {
					_descr = getText (_x >> "displayName");
					if ({_descr find _x >= 0} count ["parachute","PARACHUTE","Parachute","&"] == 0 && _descr != "") then {
						if !(_descr in _allDescr) then {
							_allDescr append [_descr];
							_valor = -1;
							if (isNumber (_x >> "cost")) then {_valor = getNumber (_x >> "cost");};
							BRPVP_tudoA3 append [[_lado,_fac,_cat,_classe,_descr,_valor]];
							if (_lado == "CIVIL") then {
								if (_cat == "Cars") exitWith {_veicSpawnCivCars append [_classe];};
								if (_cat == "Helicopters") exitWith {_veicSpawnCivHelis append [_classe];};
							} else {
								_armado = {_classe find _x >= 0 || _descr find _x >= 0} count ["unarmed","Unarmed","UNARMED"] == 0;
								if (_classe find "CUP_" != 0) then {
									if (_cat == "Cars") exitWith {
										if (_armado) then {
											_veicSpawnMilCarsArm append [_classe];
										} else {
											_veicSpawnMilCarsDes append [_classe];
										};
									};
									if (_cat == "Helicopters") exitWith {
										if (_armado) then {
											_veicSpawnMilHelisArm append [_classe];
										} else {
											_veicSpawnMilHelisDes append [_classe];
										};
									};
									if (_cat == "APCs") exitWith {
										if (_armado) then {
											_veicSpawnMilApcsArm append [_classe];
										} else {
											_veicSpawnMilApcsDes append [_classe];
										};
									};
									if (_cat == "Tanks") exitWith {
										if ({_descr find _x >= 0} count ["unarmed","Unarmed","UNARMED"] == 0) then {
											_veicSpawnMilTanksArm append [_classe];
										} else {
											_veicSpawnMilTanksDes append [_classe];
										};
									};
								} else {
									if (_cat == "Cars") exitWith {
										if (_armado) then {
											_CUPVeicSpawnMilCarsArm append [_classe];
										} else {
											_CUPVeicSpawnMilCarsDes append [_classe];
										};
									};
									if (_cat == "Helicopters") exitWith {
										if (_armado) then {
											_CUPVeicSpawnMilHelisArm append [_classe];
										} else {
											_CUPVeicSpawnMilHelisDes append [_classe];
										};
									};
									if (_cat == "APCs") exitWith {
										if (_armado) then {
											_CUPVeicSpawnMilApcsArm append [_classe];
										} else {
											_CUPVeicSpawnMilApcsDes append [_classe];
										};
									};
									if (_cat == "Tanks") exitWith {
										if ({_descr find _x >= 0} count ["unarmed","Unarmed","UNARMED"] == 0) then {
											_CUPVeicSpawnMilTanksArm append [_classe];
										} else {
											_CUPVeicSpawnMilTanksDes append [_classe];
										};
									};								
								};
							};
						};
					};
				};
			};
		};
	};
} forEach ("true" configClasses (configFile >> "CfgVehicles"));
publicVariable "BRPVP_tudoA3";

//VEICULOS PERMITIDOS
BRPVP_veiculosC = [
	_CUPVeicSpawnCivCars + _CUPVeicSpawnCivCars + _veicSpawnCivCars,
	(_CUPVeicSpawnMilCarsDes + _CUPVeicSpawnMilApcsDes) + (_CUPVeicSpawnMilCarsDes + _CUPVeicSpawnMilApcsDes) + (_veicSpawnMilCarsDes + _veicSpawnMilApcsDes),
	(_CUPVeicSpawnMilCarsArm + _CUPVeicSpawnMilApcsArm) + (_CUPVeicSpawnMilCarsArm + _CUPVeicSpawnMilApcsArm) + (_veicSpawnMilCarsArm + _veicSpawnMilApcsArm),
	(_CUPVeicSpawnMilTanksDes + _CUPVeicSpawnMilTanksArm) + (_CUPVeicSpawnMilTanksDes + _CUPVeicSpawnMilTanksArm) + (_veicSpawnMilTanksDes + _veicSpawnMilTanksArm)
];
BRPVP_veiculosH = [
	_CUPVeicSpawnCivHelis + _CUPVeicSpawnCivHelis + _veicSpawnCivHelis,
	_CUPVeicSpawnMilHelisDes + _CUPVeicSpawnMilHelisDes + _veicSpawnMilHelisDes,
	_CUPVeicSpawnMilHelisArm + _CUPVeicSpawnMilHelisArm + _veicSpawnMilHelisArm
];