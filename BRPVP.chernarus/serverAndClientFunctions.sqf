if (isServer) then {
	//SO VARIABLES
	BRPVP_variablesObjects = [];
	publicVariable "BRPVP_variablesObjects";
	BRPVP_variablesNames = [];
	publicVariable "BRPVP_variablesNames";
	BRPVP_variablesValues = [];
	publicVariable "BRPVP_variablesValues";
};
BRPVP_isZombie = {
	if (_this isKindOf "RyanZombieCivilian_F" || _this isKindOf "RyanZombieB_Soldier_base_F") then {true} else {false}
};
//http://killzonekid.com/arma-scripting-tutorials-get-zoom/
KK_fnc_trueZoom = {
	3*([0.5,0.5] distance2D worldToScreen positionCameraToWorld [0,3,4])*(getResolution select 5)/2
};
BRPVP_qjsAdicClassObjeto = {
	params ["_receptor","_val"];
	_receptor setVariable ["mny",(_receptor getVariable ["mny",0]) + _val,true];
	if (hasInterface) then {call BRPVP_atualizaDebug;};
};
BRPVP_qjsValorDoPlayer = {
	_this getVariable ["mny",0]
};
BRPVP_alignObjToTerrain = {
	_bb = boundingBoxReal _this;
	_bbXMax = abs ((_bb select 0 select 0) - (_bb select 1 select 0));
	_bbYMax = abs ((_bb select 0 select 1) - (_bb select 1 select 1));
	_dX = _bbXMax * 0.4;
	_dY = _bbYMax * 0.4;
	_cP = getPosWorld _this;
	_pt0 = [_cP select 0,_cP select 1,0];
	_pt1 = [(_cP select 0) + _dX,(_cP select 1) + _dY,0];
	_pt2 = [(_cP select 0) - _dX,(_cP select 1) + _dY,0];
	_pt3 = [(_cP select 0) + _dX,(_cP select 1) - _dY,0];
	_pt4 = [(_cP select 0) - _dX,(_cP select 1) - _dY,0];
	_sn0 = surfaceNormal _pt0;
	_sn1 = surfaceNormal _pt1;
	_sn2 = surfaceNormal _pt2;
	_sn3 = surfaceNormal _pt3;
	_sn4 = surfaceNormal _pt4;
	_sn = vectorNormalized ((((_sn0 vectorAdd _sn1) vectorAdd _sn2) vectorAdd _sn3) vectorAdd _sn4);
	_this setVectorUp _sn;
};
BRPVP_isSimpleObject = {
	_this setVariable ["sot",false,false];
	_this getVariable ["sot",true]
};
BRPVP_setVariable = {
	params ["_o","_n","_v",["_g",true]];
	_idxo = BRPVP_variablesObjects find _o;
	if (_idxo == -1) then {
		BRPVP_variablesObjects pushBack _o;
		BRPVP_variablesNames pushBack [_n];
		BRPVP_variablesValues pushBack [_v];
	} else {
		_idxn = (BRPVP_variablesNames select _idxo) find _n;
		if (_idxn == -1) then {
			(BRPVP_variablesNames select _idxo) pushBack _n;
			(BRPVP_variablesValues select _idxo) pushBack _v;
		} else {
			_ov = BRPVP_variablesValues select _idxo;
			_ov set [_idxn,_v];
			BRPVP_variablesValues set [_idxo,_ov];
		};
	};
	if (_g) then {
		if (isServer) then {
			BRPVP_variablesObjectsAdd = [_o,_n,_v,true];
			publicVariable "BRPVP_variablesObjectsAdd";
			diag_log ("[OBJ VARIABLE SET ON SERVER AND SENT TO CLIENTS] " + str [_o,_n,_v,true]);
		} else {
			BRPVP_setVariableSV = _this;
			publicVariableServer "BRPVP_setVariableSV";
		};
	} else {
		if (isServer) then {
			diag_log ("[OBJ VARIABLE SET ON SERVER, ONLY LOCAL] " + str [_o,_n,_v]);
		} else {
			diag_log ("[OBJ VARIABLE SET ON  THIS CLIENT, ONLY LOCAL] " + str [_o,_n,_v]);
		};
	};
};
BRPVP_getVariable = {
	params ["_o","_n","_d"];
	if (isNull _o) exitWith {_d};
	_idxo = BRPVP_variablesObjects find _o;
	if (_idxo == -1) then {
		_o getVariable [_n,_d]
	} else {
		_names = BRPVP_variablesNames select _idxo;
		_idxn = _names find _n;
		if (_idxn == -1) then {
			_o getVariable [_n,_d]
		} else {
			BRPVP_variablesValues select _idxo select _idxn
		};
	};
};
BRPVP_typeOf = {
	_typeOf = typeOf _this;
	if (_typeOf == "") then {
		_typeOf = [_this,"cnm",""] call BRPVP_getVariable;
	};
	_typeOf
};
BRPVP_transferUnitCargo = {
	params ["_from","_cargo",["_token",-1]];
	
	//GET UNIT GEAR INFO
	_bpc = backpackContainer _from;
	_vtc = vestContainer _from;
	_ufc = uniformContainer _from;
	_weaponItems = [];
	_weaponItems append (if (!isNull _bpc) then {weaponsItemsCargo _bpc} else {[]});
	_weaponItems append (if (!isNull _vtc) then {weaponsItemsCargo _vtc} else {[]});
	_weaponItems append (if (!isNull _ufc) then {weaponsItemsCargo _ufc} else {[]});
	_mags = magazinesAmmo _from;
	_items = items _from;
	_itemsAssigned = assignedItems _from;

	//GROUND HOLDER
	_wh = objNull;
	_whs = nearestObjects [_cargo,["GroundWeaponHolder"],30];
	{
		if (_x getVariable ["tuc",-1] == _token) then {
			if (_x distanceSqr _cargo < 100) then {
				_wh = _x;
			};
		};
		if (!isNull _wh) exitWith {};
	} forEach _whs;
	_createHolder = {
		_wh = createVehicle ["GroundWeaponHolder",getPosATL _cargo,[],0,"NONE"];
		_wh setVariable ["tuc",_token,true];
	};

	//GET ITEMS AND MAGS FROM THE WEAPONS
	{
		_weaponDetails = _x;
		{
			if (_forEachIndex > 0) then {
				if (typeName _x == "ARRAY") then {_mags pushBack _x;};
				if (typeName _x == "STRING") then {_items pushBack _x;};
			};
		} forEach _weaponDetails;
	} forEach _weaponItems;

	//TRANSFER UNIT MAGS
	{
		_class = _x select 0;
		_count = _x select 1;
		_from removeMagazineGlobal _class;
		if (_cargo canAdd _class) then {
			_cargo addMagazineAmmoCargo [_class,1,_count];
		} else {
			if (isNull _wh) then {call _createHolder;};
			_wh addMagazineAmmoCargo [_class,1,_count];
		};
	} forEach _mags;

	//TRANSFER UNIT ASSIGNED ITEMS
	{
		_from unlinkItem _x;
		if (_cargo canAdd _x) then {
			_cargo addItemCargoGlobal [_x,1];
		} else {
			if (isNull _wh) then {call _createHolder;};
			_wh addItemCargoGlobal [_x,1];
		};
	} forEach _itemsAssigned;
	
	//TRANSFER UNIT ITEMS
	{
		_from removeItem _x;
		if (_cargo canAdd _x) then {
			_cargo addItemCargoGlobal [_x,1];
		} else {
			if (isNull _wh) then {call _createHolder;};
			_wh addItemCargoGlobal [_x,1];
		};
	} forEach _items;

	//TRANSFER UNIT WEAPONS
	{
		_from removeWeaponGlobal (_x select 0);
		_weapon = (_x select 0) call BIS_fnc_baseWeapon;
		if (_cargo canAdd _weapon) then {
			_cargo addWeaponCargoGlobal [_weapon,1];
		} else {
			if (isNull _wh) then {call _createHolder;};
			_wh addWeaponCargoGlobal [_weapon,1];
		};
	} forEach _weaponItems;
	
	//TRANSFER CONTAINERS
	_v = vest _from;
	if (_v != "") then {
		if (_cargo canAdd _v) then {
			_cargo addItemCargoGlobal [_v,1];
		} else {
			if (isNull _wh) then {call _createHolder;};
			_wh addItemCargoGlobal [_v,1];
		};
		removeVest _from;
	};
	_b = backpack _from;
	if (_b != "") then {
		if (_cargo canAdd _b) then {
			_cargo addBackpackCargoGlobal [_b,1];
		} else {
			if (isNull _wh) then {call _createHolder;};
			_wh addBackpackCargoGlobal [_b,1];
		};
		removeBackpackGlobal _from;
	};
	{
		_c = _x select 1;
		clearWeaponCargoGlobal _c;
		clearMagazineCargoGlobal _c;
		clearItemCargoGlobal _c;
		clearBackpackCargo _c;
	} forEach everyContainer _cargo;
		
	//SET CARGO TO SAVE
	if !(_cargo getVariable ["slv",false]) then {_cargo setVariable ["slv",true,true];};
};
BRPVP_transferCargoCargo = {
	params ["_from","_cargo",["_token",-1]];
	
	//GET GEAR INFO
	_weaponItems = weaponsItemsCargo _from;
	_mags = magazinesAmmoCargo _from;
	_bags = backpackCargo _from;
	_items = getItemCargo _from;
	{
		_c = _x select 1;
		_weaponItems append weaponsItemsCargo _c;
		_mags append magazinesAmmoCargo _c;
		_is = getItemCargo _c;
		if (count (_is select 0) > 0) then {_items = [(_items select 0) + (_is select 0),(_items select 1) + (_is select 1)];};
	} forEach everyContainer _from;
	clearWeaponCargoGlobal _from;
	clearMagazineCargoGlobal _from;
	clearItemCargoGlobal _from;
	clearBackpackCargoGlobal _from;
	
	//GROUND HOLDER
	_wh = objNull;
	_whs = nearestObjects [_cargo,["GroundWeaponHolder"],30];
	{
		if (_x getVariable ["tuc",-1] == _token && {_x != _from}) then {
			if (_x distanceSqr _cargo < 144) then {
				_wh = _x;
			};
		};
		if (!isNull _wh) exitWith {};
	} forEach _whs;
	_createHolder = {
		_wh = createVehicle ["GroundWeaponHolder",getPosATL _cargo,[],0,"NONE"];
		_wh setVariable ["tuc",_token,true];
	};

	//GET ITEMS AND MAGS FROM THE WEAPONS
	{
		_weaponDetails = _x;
		{
			if (_forEachIndex > 0) then {
				if (typeName _x == "ARRAY" && {count _x > 0}) then {_mags pushBack _x;};
				if (typeName _x == "STRING") then {_items pushBack _x;};
			};
		} forEach _weaponDetails;
	} forEach _weaponItems;

	//TRANSFER MAGS
	{
		_class = _x select 0;
		_count = _x select 1;
		if (_cargo canAdd _class) then {
			_cargo addMagazineAmmoCargo [_class,1,_count];
		} else {
			if (isNull _wh) then {call _createHolder;};
			_wh addMagazineAmmoCargo [_class,1,_count];
		};
	} forEach _mags;

	//TRANSFER ITEMS
	{
		for "_q" from 1 to (_items select 1 select _forEachIndex) do {
			if (_cargo canAdd _x) then {
				_cargo addItemCargoGlobal [_x,1];
			} else {
				if (isNull _wh) then {call _createHolder;};
				_wh addItemCargoGlobal [_x,1];
			};
		};
	} forEach (_items select 0);
	
	//TRANSFER WEAPONS
	{
		_weapon = (_x select 0) call BIS_fnc_baseWeapon;
		if (_cargo canAdd _weapon) then {
			_cargo addWeaponCargoGlobal [_weapon,1];
		} else {
			if (isNull _wh) then {call _createHolder;};
			_wh addWeaponCargoGlobal [_weapon,1];
		};
	} forEach _weaponItems;
	
	//TRANSFER BAGS
	{
		if (_cargo canAdd _x) then {
			_cargo addBackpackCargoGlobal [_x,1];
		} else {
			if (isNull _wh) then {call _createHolder;};
			_wh addBackpackCargoGlobal [_x,1];
		};
	} forEach _bags;
	{
		_c = _x select 1;
		clearWeaponCargoGlobal _c;
		clearMagazineCargoGlobal _c;
		clearItemCargoGlobal _c;
		clearBackpackCargo _c;
	} forEach everyContainer _cargo;
	
	//SET CARGOS TO SAVE
	if !(typeOf _from in ["GroundWeaponHolder","WeaponHolderSimulated"]) then {
		if !(_from getVariable ["slv",false]) then {_from setVariable ["slv",true,true];};
	};
	if !(_cargo getVariable ["slv",false]) then {_cargo setVariable ["slv",true,true];};
};
BRPVP_isCfgSimilar = {
	private ["_i1","_i2","_i1c","_i2c","_i1p","_i2p","_idxi1","_return"];
	_i1 = _this;
	_return = [];
	_idxi1 = BRPVP_mercadoItensClass find _i1;
	if (_idxi1 >= 0) then {
		_return = BRPVP_mercadoItens select _idxi1;
	} else {
		if (isClass (configFile >> "CfgMagazines" >> _i1)) then {
			_i1c = 0;
			_i1p = [configfile >> "CfgMagazines" >> _i1,true] call BIS_fnc_returnParents;
		} else {
			if (isClass (configFile >> "CfgWeapons" >> _i1)) then {
				_i1c = 1;
				_i1p = [configfile >> "CfgWeapons" >> _i1,true] call BIS_fnc_returnParents;
			} else {
				if (isClass (configFile >> "CfgVehicles" >> _i1)) then {
					_i1c = 2;
					_i1p = [configfile >> "CfgVehicles" >> _i1,true] call BIS_fnc_returnParents;
				};
			};
		};
		{
			_i2 = _x;
			_i2c = BRPVP_mercadoItensParents select _forEachIndex select 1;
			_i2p = BRPVP_mercadoItensParents select _forEachIndex select 2;
			if (_i2c == _i1c && {_i1 in _i2p || {_i2 in _i1p}}) exitWith {
				_return = BRPVP_mercadoItens select _forEachIndex;
			};
		} forEach BRPVP_mercadoItensClass;
	};
	_return
};
LOL_fnc_selectRandom = {
	_this select (floor random count _this)
};
LOL_fnc_selectRandomIdx = {
	private _idx = floor random count _this;
	[_this select _idx,_idx] 
};
LOL_fnc_selectRandomFator = {
	params ["_array","_factor"];
	_array select floor ((random ((count _array)^(1/_factor)))^(_factor))
};
LOL_fnc_selectRandomFactorIdx = {
	params ["_array","_factor"];
	private _idc = floor ((random ((count _array)^(1/_factor)))^(_factor));
	[_array select _idc,_idc]
};
LOL_fnc_selectRandomN = {
	params ["_array","_n",["_unique",true]];
	private _return = [];
	_ca = count _array;
	for "_i" from 1 to (_n min _ca) do {
		_cs = _array call LOL_fnc_selectRandomIdx;
		_idx = _cs select 1;
		if (_unique) then {
			_return pushBack (_array deleteAt _idx);
		} else {
			_return pushBack (_array select _idx);
		};
	};
	_return
};
BRPVP_execFast = {
	params ["_nome","_script",["_wait",true]];
	BRPVP_fsmTerminou = false;
	BRPVP_paralelContinue = false;
	[_nome,_script] execFSM "execucaoPrioritaria.fsm";
	if (_wait) then {
		waitUntil {BRPVP_fsmTerminou};
	};
};
BRPVP_tempoPorExtenso = {
	private ["_txt","_horas","_horasFloor","_minutos","_minutosFloor","_segundosFloor"];
	_horas = _this/3600;
	_horasFloor = floor _horas;
	_minutos = (_horas - _horasFloor) * 60;
	_minutosFloor = floor _minutos;
	_segundosFloor = floor ((_minutos - _minutosFloor) * 60);
	if (_horasFloor > 0) then {
		_txt = str _horasFloor + "h " + str _minutosFloor + "m " + str _segundosFloor + "s";
	} else {
		if (_minutosFloor > 0) then {
			_txt = str _minutosFloor + "m " + str _segundosFloor + "s";
		} else {
			_txt = str _segundosFloor + "s";
		};
	};
	_txt
};
BRPVP_adicCargo = {
	params ["_cargo","_classe"];
	_nomArr = _cargo select 0;
	_qttArr = _cargo select 1;
	_idc = _nomArr find _classe;
	if (_idc >= 0) then {
		_qttArr set [_idc,(_qttArr select _idc) + 1];
		_cargo set [1,_qttArr];
	} else {
		_nomArr = _nomArr + [_classe];
		_qttArr = _qttArr + [1];
		_cargo = [_nomArr,_qttArr];
	};
	_cargo
};
BRPVP_addLoot = {
	params ["_holder","_itemsAll",["_failHolder",objNull]];
	_failedItems = [];
	if (_holder == player) then {
		{
			_idc = BRPVP_specialItems find _x;
			if (_idc >= 0) then {
				_sit = _holder getVariable ["sit",[]];
				_sit pushBack _idc;
				_holder setVariable ["sit",_sit,true];
			} else {
				if (isClass (configFile >> "CfgVehicles" >> _x)) then {
					if (isNull backPackContainer player) then {player addBackpack _x;} else {_failedItems pushBack _x;};
				} else {
					if (isClass (configFile >> "CfgWeapons" >> _x)) then {
						_isItem = _x iskindOf ["ItemCore",configFile >> "CfgWeapons"];
						_isBino = _x iskindOf ["Binocular",configFile >> "CfgWeapons"];
						if (_x find "U_" == 0 || _x find "V_" == 0 || _x find "Item" == 0 || _isItem || _isBino) then {
							if (_x find "U_" == 0) then {
								if (isNull uniformContainer player) then {
									player forceAddUniform _x;
								} else {
									if (player canAdd _x) then {player addItem _x;} else {_failedItems pushBack _x;};
								};
							} else {
								if (_x find "V_" == 0) then {
									if (isNull vestContainer player) then {
										player addVest _x;
									} else {
										if (player canAdd _x) then {player addItem _x;} else {_failedItems pushBack _x;};
									};
								} else {
									if (_isItem) then {
										if (!(_x in assignedItems player) && _x find "Item" == 0) then {
											player linkItem _x;
										} else {
											if (player canAdd _x) then {player addItem _x;} else {_failedItems pushBack _x;};
										};
									} else {
										if (_isBino) then {
											_isNVG = _x isKindOf ["NVGoggles",configFile >> "CfgWeapons"];
											_hasNVG = hmd player != "";
											_hasVEC = binocular player != "";
											if ((_isNVG && _hasNVG) || (!_isNVG && _hasVEC)) then {
												if (player canAdd _x) then {player addItem _x;} else {_failedItems pushBack _x;};
											} else {
												player addWeapon _x;
											};
										};
									};
								};
							};
						} else {
							_type = getNumber (configFile >> "CfgWeapons" >> _x >> "Type");
							if (_type == 1) then {
								if (primaryWeapon player == "") then {player addWeapon _x;} else {_failedItems pushBack _x;};
							};
							if (_type == 2) then {
								if (handGunWeapon player == "") then {player addWeapon _x;} else {_failedItems pushBack _x;};
							};
							if (_type == 4) then {
								if (secondaryWeapon player == "") then {player addWeapon _x;} else {_failedItems pushBack _x;};
							};
							if !(_type in [1,2,4]) then {_failedItems pushBack _x;};
						};
					} else {
						if (isClass (configFile >> "CfgMagazines" >> _x)) then {
							if (player canAdd _x) then {player addMagazine _x;} else {_failedItems pushBack _x;};
						};
					};
				};
			};
		} forEach _itemsAll;
		_holder = _failHolder;
		_itemsAll = _failedItems;
	};
	if (!isNull _holder) then {
		{
			_isM = isClass (configFile >> "CfgMagazines" >> _x);
			if (_isM) then {
				_holder addMagazineCargoGlobal [_x,1];
			} else {
				_isW = isClass (configFile >> "CfgWeapons" >> _x);
				if (_isW) then {
					_isItem = _x isKindOf ["ItemCore",configFile >> "CfgWeapons"];
					_isBino = _x isKindOf ["Binocular",configFile >> "CfgWeapons"];
					if (_isItem || _isBino) then {
						_holder addItemCargoGlobal [_x,1];
					} else {
						_holder addWeaponCargoGlobal [_x,1];
					};
				} else {
					_isV = isClass (configFile >> "CfgVehicles" >> _x);
					if (_isV) then {
						_holder addBackpackCargoGlobal [_x,1];
					};
				};
			};
		} forEach _itemsAll;
	};
	if (count _itemsAll == 0 && !isNull _failHolder) then {deleteVehicle _failHolder;};
	(count _failedItems > 0)
};
BRPVP_pegaSegsBBChao = {
	_bb = boundingBoxReal _this;
	_p1 = _bb select 0;
	_p2 = _bb select 1;
	_p1x = _p1 select 0;
	_p2x = _p2 select 0;
	_p1y = _p1 select 1;
	_p2y = _p2 select 1;
	_segs = [
		//FLOOR
		[[_p1x,_p1y,0],[_p2x,_p1y,0]],
		[[_p2x,_p1y,0],[_p2x,_p2y,0]],
		[[_p2x,_p2y,0],[_p1x,_p2y,0]],
		[[_p1x,_p2y,0],[_p1x,_p1y,0]]
	];
	_segs
};
BRPVP_emVoltaBB = {
	params ["_obj","_extra"];
	_segs = _obj call BRPVP_pegaSegsBBChao;
	_seg = _segs call BIS_fnc_selectRandom;
	_p1 = _seg select 0;
	_p2 = _seg select 1;
	_p3 = _p1 vectorAdd ((_p2 vectorDiff _p1) vectorMultiply random 1);
	_p3 set [2,0];
	_dist = _p3 distance [0,0,0];
	_mult = (_dist + _extra)/_dist;
	_p4 = _p3 vectorMultiply _mult;
	_retorno = _obj modelToWorld _p4;
	_retorno set [2,0];
	_retorno
};
BRPVP_emVoltaBBManual = {
	params ["_obj","_extra","_lado","_fator"];
	_segs = _obj call BRPVP_pegaSegsBBChao;
	_seg = _segs select _lado;
	_p1 = _seg select 0;
	_p2 = _seg select 1;
	_p3 = _p1 vectorAdd ((_p2 vectorDiff _p1) vectorMultiply _fator);
	_p3 set [2,0];
	_dist = _p3 distance [0,0,0];
	_mult = (_dist + _extra)/_dist;
	_p4 = _p3 vectorMultiply _mult;
	_retorno = _obj modelToWorld _p4;
	_retorno set [2,0];
	_retorno
};
BRPVP_isInsideBuilding = {
	params ["_unit","_building",["_h",50]];
	private ["_p1","_p2","_p3","_objects","_tstA""_tstB"];
	_p1 = getPosASL _unit;
	_p2 = [_p1 select 0,_p1 select 1,(_p1 select 2) - 1];
	_objects = lineIntersectsWith [_p1,_p2];
	_tstA = _building in _objects;
	if (!_tstA) then {
		_p3 = [_p1 select 0,_p1 select 1,(_p1 select 2) + _h];
		_objects = lineIntersectsWith [_p1,_p3];
		_building in _objects
	} else {
		true
	};
};
BRPVP_achaCentroPrincipal = {
	params [
		"_objetos",				//LISTA DE OBJETOS QUE PODEM SER CENTRO PRINCIPAL
		"_tipoPertoClass",		//ARRAY DE CLASSES QUE DEVEM SER VERIFICADOS NAS REDONDEZAS DO CENTRO PRINCIPAL
		"_tipoPertoModel",		//ARRAY COM SUBSTRING DO NOME DOS MODELOS A SEREM PROCURADOS NAS REDONDEZAS
		"_tipoPertoRaio",		//RAIO DA REDONDEZA
		"_polaridade",			//PARA QUANTO MAIS MELHOR USE 1, PARA QUANTO MENOS MELHOR USE -1
		"_insiste",				//NUMERO DE INSISTENCIA EM OBJETOS MELHOR POSICIONADOS
		["_ruasSeNada",true],	//CONTA RUAS NAS REDONDEZAS SE NADA DEFINIDO PARA CONTAR
		["_ladoAmigo",""],		//LADO AMIGO para dar preferencia a proximidade
		["_ladoInimigo",""]		//LADO INIMIGO para dar preferencia a nao-proximidade
	];
	private ["_ladoContar","_pos","_codContaLado","_codContaModel","_codContaClass","_objDaVez","_qtPerto","_codConta","_objDaVezTenta","_qtTop","_distTop","_qtPerto","_distSoma","_qtPertoCod","_distSomaCod"];

	//FUNCOES CONTAR
	_codContaClass = {
		{
			_qtPerto = _qtPerto + count (_objDaVezTenta nearobjects [_x,_tipoPertoRaio]);
		} forEach _tipoPertoClass;
	};
	_codContaModel = {
		{
			private ["_txt"];
			_txt = str _x;
			{
				if (_txt find _x >= 0) exitWith {
					_qtPerto = _qtPerto + 1;
				};
			} forEach _tipoPertoModel;
		} forEach (nearestobjects [_objDaVezTenta,[],_tipoPertoRaio]);
	};
	_codContaLado = {
		{
			private ["_lado","_lider","_dist"];
			_lado = side _x;
			if (_lado isEqualTo _ladoContar) then {
				_lider = leader _x;
				_dist = _pos distance2D _lider;
				_distSoma = _distSoma + (_dist/100)^2;
			};
		} forEach allGroups;
	};
	
	//CONTAGEM DE AMIGOS INIMIGOS
	if (typeName _ladoAmigo != "STRING") then {
		private ["_qa"];
		_qa = {(side _x) isEqualTo _ladoAmigo} count allGroups;
		if (_qa > 0) then {
			_distTop = 1000000;
			_ladoContar = _ladoAmigo;
			_distSomaCod = {_distSoma < _distTop};	
		} else {
			if (typeName _ladoInimigo != "STRING") then {
				private ["_qi"];
				_qi = {(side _x) isEqualTo _ladoInimigo} count allGroups;
				if (_qi > 0) then {
					_distTop = 0;
					_ladoContar = _ladoInimigo;
					_distSomaCod = {_distSoma > _distTop};
				} else {
					_codContaLado = {};
					_distSomaCod = {true};
				};
			} else {
				_codContaLado = {};
				_distSomaCod = {true};
			};
		};
	} else {
		if (typeName _ladoInimigo != "STRING") then {
			private ["_qi"];
			_qi = {(side _x) isEqualTo _ladoInimigo} count allGroups;
			if (_qi > 0) then {
				_distTop = 0;
				_ladoContar = _ladoInimigo;
				_distSomaCod = {_distSoma > _distTop};
			} else {
				_codContaLado = {};
				_distSomaCod = {true};
			};
		} else {
			_codContaLado = {};
			_distSomaCod = {true};
		};
	};
	
	//FUNCOES CONTAR COMBINADAS
	if (count _tipoPertoClass > 0 && count _tipoPertoModel > 0) then {
		_codConta = {
			call _codContaClass;
			call _codContaModel;
		};
	};
	if (count _tipoPertoClass > 0 && count _tipoPertoModel == 0) then {
		_codConta = {call _codContaClass};
	};
	if (count _tipoPertoClass == 0 && count _tipoPertoModel > 0) then {
		_codConta = {call _codContaModel;};
	};
	if (count _tipoPertoClass == 0 && count _tipoPertoModel == 0) then {
		if (_ruasSeNada) then {
			_codConta = {_qtPerto = count ((position _objDaVezTenta) nearRoads _tipoPertoRaio);};
		} else {
			_codConta = {};
		};
	};
	if (_codConta isEqualTo {}) then {
		_qtPertoCod = {true};
	} else {
		if (_polaridade == 1) then {
			_qtTop = 0;
			_qtPertoCod = {_qtPerto > _qtTop};
		};
		if (_polaridade == -1) then {
			_qtTop = 1000000;
			_qtPertoCod = {_qtPerto < _qtTop};
		};
	};
	
	//PROCURA CENTRO
	_objDaVez = objNull;
	for "_k" from 1 to _insiste do {
		_objDaVezTenta = _objetos call BIS_fnc_selectRandom;
		_qtPerto = 0;
		_distSoma = 0;
		_pos = getPosASL _objDaVezTenta;
		call _codConta;
		call _codContaLado;
		if (call _qtPertoCod) then {
			if (call _distSomaCod) then {
				_qtTop = _qtPerto;
				_distTop = _distSoma;
				_objDaVez = _objDaVezTenta;
			};
		};
	};
	_objDaVez
};
BRPVP_achaLocal = {
	params [
		"_centro",			//1.0 - CENTRO PRIMARIO
		"_resPadrao",		//1.0 - RESULTADO PADRAO CASO NAO ACHE
		"_raioMin",			//2.1 - CENTRO SECUNDARIO: RAIO MINIMO A PARTIR DO CENTRO PRIMARIO
		"_raioMinRand",		//2.1 - CENTRO SECUNDARIO: ADICIONAL RANDOMICO AO RAIO MINIMO (PODE SER 0)
		"_raioMax",			//2.2 - CENTRO SECUNDARIO: RAIO MAXIMO A PARTIR DO CENTRO PRIMARIO
		"_raioMaxRand",		//2.2 - CENTRO SECUNDARIO: ADICIONAL RANDOMICO AO RAIO MAXIMO (PODE SER 0)
		"_stepHor",			//3.0 - MOVIMENTO HORIZONTAL DO CENTRO SECUNDARIO
		"_stepVer",			//3.0 - MOVIMENTO VERTICAL DO CENTRO SECUNDARIO
		"_raioAtrCheck",	//4.0 - RAIO DE CHECK DE ATRIBUTOS (RUA E ELEVACAO) AO REDOR DO CENTRO SECUNDARIO
		"_podeRua",			//4.1 - PERMITIDO RUA NO RAIO _raioAtrCheck? TRUE/FALSE.
		"_stepAtr",			//4.1 - STEP DE CHECK DE RUAS (<= _raioAtrCheck)
		"_maxElev",			//4.2 - MAXIMA ELEVACAO MEDIA PERMITIDA
		"_objClass",		//4.3 - ARRAY DE OBJETOS A SEREM PROCURADOS
		"_objModel",		//4.3 - SUBSTRING DO NOME DO MODELO DO OBJETO A SER PROCURADO
		"_objMaxQt",		//4.3 - QUANTIA MAXIMA DE OBJETOS PERMITIDOS
		"_podeAgua"			//4.4 - PERMITIDO AGUA NO RAIO _raioAtrCheck? TRUE/FALSE.
	];
	private ["_imput","_result","_minDist","_maxDist","_blackList"];
	_origin = if (typeName _centro == "OBJECT") then {position _centro} else {_centro};
	_minDist = _raioMin + random _raioMinRand;
	_maxDist = _raioMax + random _raioMaxRand;
	_step = 15;
	_donutsQt = (_maxDist - _minDist)/_step;
	_blackList = [];
	{
		_pos = getPos _x;
		_so = sizeOf typeOf _x;
		_so = _so/1.65;
		_pTL = _pos vectorAdd [-_so,_so,0];
		_pBR = _pos vectorAdd [_so,-_so,0];
		_pTL resize 2;
		_pBR resize 2;
		_blackList pushBack [_pTL,_pBR];
	} forEach nearestObjects [_origin,["LandVehicle","Air","Man","Ship","Building","House"],_maxDist];
	_imput = [
		_origin,
		0,
		0,
		_raioAtrCheck,
		if (_podeAgua) then {1} else {0},
		tan _maxElev,
		0,
		_blackList,
		[_resPadrao,_resPadrao]
	];
	for "_i" from 1 to (ceil _donutsQt) do {
		_imput set [1,_minDist + (_i - 1) * _step];
		_imput set [2,if (_i < _donutsQt) then {_minDist + _i * _step} else {_maxDist}];
		_result = _imput call BIS_fnc_findSafePos;
		if !(_result isEqualTo _resPadrao) exitWith {};
	};
	_result
};
BRPVP_achaLocalWIP = {
	params [
		"_centro",			//1.0 - CENTRO PRIMARIO
		"_resPadrao",		//1.0 - RESULTADO PADRAO CASO NAO ACHE
		"_raioMin",			//2.1 - CENTRO SECUNDARIO: RAIO MINIMO A PARTIR DO CENTRO PRIMARIO
		"_raioMinRand",		//2.1 - CENTRO SECUNDARIO: ADICIONAL RANDOMICO AO RAIO MINIMO (PODE SER 0)
		"_raioMax",			//2.2 - CENTRO SECUNDARIO: RAIO MAXIMO A PARTIR DO CENTRO PRIMARIO
		"_raioMaxRand",		//2.2 - CENTRO SECUNDARIO: ADICIONAL RANDOMICO AO RAIO MAXIMO (PODE SER 0)
		"_stepHor",			//3.0 - MOVIMENTO HORIZONTAL DO CENTRO SECUNDARIO
		"_stepVer",			//3.0 - MOVIMENTO VERTICAL DO CENTRO SECUNDARIO
		"_raioAtrCheck",	//4.0 - RAIO DE CHECK DE ATRIBUTOS (RUA E ELEVACAO) AO REDOR DO CENTRO SECUNDARIO
		"_podeRua",			//4.1 - PERMITIDO RUA NO RAIO _raioAtrCheck? TRUE/FALSE.
		"_stepAtr",			//4.1 - STEP DE CHECK DE RUAS (<= _raioAtrCheck)
		"_maxElev",			//4.2 - MAXIMA ELEVACAO MEDIA PERMITIDA
		"_objClass",		//4.3 - ARRAY DE OBJETOS A SEREM PROCURADOS
		"_objModel",		//4.3 - SUBSTRING DO NOME DO MODELO DO OBJETO A SER PROCURADO
		"_objMaxQt",		//4.3 - QUANTIA MAXIMA DE OBJETOS PERMITIDOS
		"_podeAgua"			//4.4 - PERMITIDO AGUA NO RAIO _raioAtrCheck? TRUE/FALSE.
	];
	private ["_checaAtr","_tiraPorAtr","_raio","_angInic","_ang","_pos","_posCheck","_qt","_angAdic","_posCheckAtr","_elevSoma","_elevSomaQt"];
	if (typeName _centro == "OBJECT") then {_centro = position _centro;};
	_raio = _raioMin + random _raioMinRand;
	_raioMax = _raio + _raioMax + random _raioMaxRand;
	_angInic = random 360;
	_ang = _angInic;
	_pos = _resPadrao;
	if (!_podeRua && !_podeAgua) then {
		_checaAtr = {surfaceIsWater _posCheckAtr || isOnRoad _posCheckAtr};
	} else {
		if (_podeRua && !_podeAgua) then {
			_checaAtr = {surfaceIsWater _posCheckAtr};
		} else {
			if (!_podeRua && _podeAgua) then {
				_checaAtr = {isOnRoad _posCheckAtr};
			} else {
				if (_podeRua && _podeAgua) then {
					_checaAtr = {false};
				};
			};
		};
	};
	_procuraModels = {};
	if (count _objModel > 0) then {
		_procuraModels = {
			{
				_txt = str _x;
				{if (_txt find _x >= 0) exitWith {_qt = _qt + 1;};} forEach _objModel;
			} forEach (nearestObjects [_posCheck,[],_raioAtrCheck]);
		};
	};
	diag_log "======= [PROCURA LOCAL DETALHE] ======================================";
	while {_raio < _raioMax} do {
		_posCheck = [(_centro select 0) + _raio * sin _ang,(_centro select 1) + _raio * cos _ang,0];
		_qt = 0;
		{_qt = _qt + count (_posCheck nearobjects [_x,_raioAtrCheck]);} forEach _objClass;
		call _procuraModels;
		_tiraPorAtr = false;
		_elevSoma = 0;
		_elevSomaQt = 0;
		for "_a" from 0 to (floor ((_raioAtrCheck/_stepAtr)+0.001)) do {
			{
				_posCheckAtr = [
					(_posCheck select 0)+(_x select 0)*_a*_stepAtr,
					(_posCheck select 1)+(_x select 1)*_a*_stepAtr,
					_posCheck select 2
				];
				_elevSoma = _elevSoma + acos ((surfaceNormal _posCheckAtr) vectorCos [0,0,1]);
				_elevSomaQt = _elevSomaQt + 1;
				if (call _checaAtr) exitWith {_tiraPorAtr = true;};
			} forEach [[1,0],[-1,0],[0,1],[0,-1],[0.7,0.7],[-0.7,-0.7],[0.7,-0.7],[-0.7,0.7]];
			if (_tiraPorAtr) exitWith {};
		};
		diag_log ("REFINAMENTO: qt_classes = " + str _qt + "/" + str _objMaxQt + " | elevacao = " + str _elevSoma + "/" + str _maxElev + " | off_por_atrib = " + str _tiraPorAtr + ".");
		if (_qt <= _objMaxQt && _elevSoma/_elevSomaQt <= _maxElev && !_tiraPorAtr) exitWith {
			_pos = _posCheck;
		};
		_angAdic = (360 * _stepHor)/(2 * pi * _raio);
		if (_ang + _angAdic - _angInic > 360) then {
			_ang = _angInic;
			_raio = _raio + _stepVer;
		} else {
			_ang = _ang + _angAdic;
		};
	};
	diag_log "======= [PROCURA LOCAL DETALHE FIM] ==================================";
	_pos
};
BRPVP_pelaUnidade = {
	{_this removeMagazine _x;} forEach  magazines _this;
	{_this removeWeapon _x;} forEach weapons _this;
	{_this removeItem _x;} forEach items _this;
	removeAllAssignedItems _this;
	removeBackpackGlobal _this;
	removeUniform _this;
	removeVest _this;
	removeHeadGear _this;
	removeGoggles _this;
};
//Author: pedeathtrian
//Original: https://forums.bistudio.com/topic/191898-distance-to-bounding-box/#entry3050642
PDTH_pointIsInBox = {
	params ["_unit","_obj"];
	_posUnit = if (typeName _unit == "OBJECT") then {getPos _unit} else {_unit};
	_uPos = _obj worldToModel _posUnit;
	_ovb = _obj getVariable ["bbx",[]];
	_oBox = if (count _ovb == 0) then {boundingBoxReal _obj} else {_ovb};
	_inHelper = {
		params ["_pt0","_pt1"];
		(_pt0 select 0 <= _pt1 select 0) && (_pt0 select 1 <= _pt1 select 1) && (_pt0 select 2 <= _pt1 select 2)
	};
	([_oBox select 0,_uPos] call _inHelper) && ([_uPos, _oBox select 1] call _inHelper)
};
//Author: pedeathtrian
//https://forums.bistudio.com/topic/191898-distance-to-bounding-box/#entry3050642
PDTH_distance2Box = {
	params ["_unit","_obj"];
	_uPos = _obj worldToModel (getPos _unit);
	_oBox = boundingBoxReal _obj;
	_pt = [0,0,0];
	{
		if (_x < (_oBox select 0 select _forEachIndex)) then {
			_pt set [_forEachIndex,(_oBox select 0 select _forEachIndex) - _x];
		} else {
			if ((_oBox select 1 select _forEachIndex) < _x) then {
				_pt set [_forEachIndex,_x - (_oBox select 1 select _forEachIndex)];
			};
		};
	} forEach _uPos;
	_pt distance [0,0,0]
};
PDTH_distance2BoxQuad = {
	params ["_unit","_obj"];
	_uPos = _obj worldToModel (getPos _unit);
	_oBox = boundingBoxReal _obj;
	_pt = [0,0,0];
	{
		if (_x < (_oBox select 0 select _forEachIndex)) then {
			_pt set [_forEachIndex,(_oBox select 0 select _forEachIndex) - _x];
		} else {
			if ((_oBox select 1 select _forEachIndex) < _x) then {
				_pt set [_forEachIndex,_x - (_oBox select 1 select _forEachIndex)];
			};
		};
	} forEach _uPos;
	_pt distanceSqr [0,0,0]
};
BRPVP_IsMotorized = {
	private ["_typeOf"];
	if (typeName _this == "STRING") then {
		_typeOf = _this;
		_cfgV = configFile >> "CfgVehicles";
		_typeOf isKindOf ["LandVehicle",_cfgV] || {_typeOf isKindOf ["Air",_cfgV] || {_typeOf isKindOf ["Ship",_cfgV]}}
	} else {
		_this isKindOf "LandVehicle" || {_this isKindOf "Air" || {_this isKindOf "Ship"}}
	}	
};
BRPVP_isBuilding = {
	private ["_typeOf"];
	if (typeName _this == "STRING") then {
		_typeOf = _this;
		_cfgV = configFile >> "CfgVehicles";
		_typeOf isKindOf ["Wall",_cfgV] || {_typeOf isKindOf ["Building",_cfgV] || {_typeOf isKindOf ["House",_cfgV]}}
	} else {
		_this isKindOf "Wall" || {_this isKindOf "Building" || {_this isKindOf "House"}}
	};
};
BRPVP_fillUnitWeapons = {
	params ["_unidade",["_qttWeps",[4,4,4]]];
	_mags = magazines _unidade;
	{
		_wep = _x;
		_qtt = _qttWeps select _forEachIndex;
		if (_wep != "") then {
			_magsWep = 0;
			_magsCfg = getArray (configFile >> "CfgWeapons" >> _wep >> "magazines");
			{
				if (_x in _magsCfg) then {_magsWep = _magsWep + 1;};
			} forEach _mags;
			if (_magsWep < _qtt) then {
				_mag = _magsCfg call BIS_fnc_selectRandom;
				for "_m" from 1 to (_qtt - _magsWep) do {
					if (_unidade canAdd _mag) then {
						_unidade addMagazine _mag;
					};
				};
			};
		};
	} forEach [primaryWeapon _unidade,secondaryWeapon _unidade,handGunWeapon _unidade];
};