diag_log "[BRPVP FILE] loops.sqf INITIATED";

//DEFINE ARRAY DE POSICOES OTIMIZADO
_posicoesA = BRPVP_locaisDeCura + BRPVP_locaisImportantes + BRPVP_mercadoresPos + BRPVP_buyersPos;
BRPVP_checksDePos = [];
{
	_maisPerto = [_x select 0,_posicoesA] call BRPVP_funcaoMinDist;
	_posMaisPerto = _posicoesA select _maisPerto select 0;
	_raioMaisPerto = _posicoesA select _maisPerto select 1;
	_dist = ((_x select 0) distance _posMaisPerto) - _raioMaisPerto;
	_overlap = _dist < (_x select 1);
	BRPVP_checksDePos = BRPVP_checksDePos + [_x + [_posMaisPerto,_raioMaisPerto,_dist,_overlap]];
} forEach _posicoesA;
_posicoesA = nil;

//DEFINE CODIGOS QUE RODAM AO ENTRAR E SAIR DE LOCAIS
BRPVP_inBuyersPlace = 0;
BRPVP_codigoLocais = [
	[
		{
			BRPVP_safeZone = true;
			true call BRPVP_ligaModoSeguro;
			[] spawn BRPVP_curaPlayer;
		},
		{
			true call BRPVP_desligaModoSeguro;
			BRPVP_safeZone = false;
		}
	],
	[
		{},
		{}
	],
	[
		{
			BRPVP_safeZone = true;
			true call BRPVP_ligaModoSeguro;
			_antenna = + _this;
			_antenna set [2,35];
			[800,0.025,2.5,_antenna] call BRPVP_radarAdd;
			["This local have Radar Signal!\n(open your map).",3.5,12] call BRPVP_hint;
		},
		{
			true call BRPVP_desligaModoSeguro;
			BRPVP_safeZone = false;
			_antenna = + _this;
			_antenna set [2,35];
			[800,0.025,2.5,_antenna] call BRPVP_radarRemove;
		}
	],
	[
		{
			BRPVP_safeZone = true;
			true call BRPVP_ligaModoSeguro;
			BRPVP_inBuyersPlace = BRPVP_inBuyersPlace + 1;
			BRPVP_inBuyersPlace spawn BRPVP_buyersPlace;
			_antenna = + _this;
			_antenna set [2,50];
			[1000,0.025,2.5,_antenna] call BRPVP_radarAdd;
			["This local have Radar Signal!\n(open your map).",3.5,12] call BRPVP_hint;
		},
		{
			true call BRPVP_desligaModoSeguro;
			BRPVP_safeZone = false;
			BRPVP_inBuyersPlace = BRPVP_inBuyersPlace + 1;
			_antenna = + _this;
			_antenna set [2,50];
			[1000,0.025,2.5,_antenna] call BRPVP_radarRemove;
		}
	]
];

//COLOCA ICONES DOS LOCAIS NO MAPA
{
	_pos = _x select 0;
	_raio = _x select 1;
	_nome = _x select 2;
	_tipo = _x select 3;
	_marca = createMarkerLocal ["LOCAIS_" + str _forEachIndex,_pos];
	_marca setMarkerShapeLocal "ELLIPSE";
	_marca setMarkerSizeLocal [_raio,_raio];
	_marca setMarkerColorLocal (["ColorGreen","ColorOrange","ColorYellow"] select _tipo);
	_marca setMarkerAlphaLocal 0.5;
} forEach BRPVP_checksDePos;

//MONITORA ENTRADA E SAIDA DOS LOCAIS
BRPVP_dentroDeMudou = 0;
[] spawn {
	_contarGeral = 0;
	waitUntil {
		_pos = getPosATL vehicle player;
		_maisPerto = [_pos,BRPVP_checksDePos] call BRPVP_funcaoMinDist;
		_centro = BRPVP_checksDePos select _maisPerto select 0;
		_raio = BRPVP_checksDePos select _maisPerto select 1;
		_nome = BRPVP_checksDePos select _maisPerto select 2;
		_overlap = BRPVP_checksDePos select _maisPerto select 7;
		if (_pos distance _centro <= _raio) then {
			_centro call (BRPVP_codigoLocais select (BRPVP_checksDePos select _maisPerto select 3) select 0);
			if (!_overlap) then {
				_check1 = _raio^2;
				waitUntil {vehicle player distanceSqr _centro > _check1};
				_centro call (BRPVP_codigoLocais select (BRPVP_checksDePos select _maisPerto select 3) select 1);
			} else {
				BRPVP_dentroDe set [count BRPVP_dentroDe,_maisPerto];
			};
		} else {
			_centroMaisPerto = BRPVP_checksDePos select _maisPerto select 4;
			_raioMaisPerto = BRPVP_checksDePos select _maisPerto select 5;
			_distMax = BRPVP_checksDePos select _maisPerto select 6;
			_dist = _pos distance _centro;
			if (_dist > _raio && _dist < _distMax) then {
				_check1 = _raio^2;
				_check2 = _distMax^2;
				waitUntil {_dist = vehicle player distanceSqr _centro;_dist <= _check1 || _dist >= _check2};
			} else {
				_distMax = _dist - _raio;
				_check1 = _distMax^2;
				waitUntil {vehicle player distanceSqr _pos >= _check1 || BRPVP_dentroDeMudou > 0};
				BRPVP_dentroDeMudou = (BRPVP_dentroDeMudou - 1) max 0;
			};
		};
		_contarGeral = _contarGeral + 1;
		false
	};
};

//MONITOR CENTRAL
[] spawn {
	private ["_agora","_tempo60","_tempo10","_tempo1","_saiu","_temSaiu","_safePos"];
	BRPVP_actionTrader = -1;
	BRPVP_actionVehicleTrader = -1;
	BRPVP_actionRevive = -1;
	BRPVP_actionFinalize = -1;
	BRPVP_actionFlipVehicle3 = -1;
	BRPVP_actionFlipVehicle6 = -1;
	BRPVP_actionFlipVehicle12 = -1;
	BRPVP_actionAdoptHouse = -1;
	BRPVP_actionRevokeHouse = -1;
	BRPVP_actionTranferUC = -1;
	BRPVP_actionBriefcase = -1;
	BRPVP_actionStuff = -1;
	BRPVP_actionBulldozer = -1;
	BRPVP_actionRadarSpot = -1;
	BRPVP_actionRadarCut = -1;
	BRPVP_actionDismantleRespawn = -1;
	BRPVP_actionSwitchLampOff = -1;
	BRPVP_actionSwitchLampOn = -1;
	BRPVP_actionRunning = [];
	_actionOnScreen = false;
	_inicio60 = time;
	_inicio10 = time;
	_inicio1 = time;
	_hAntes = 0;
	_bin1 = true;
	_bin2 = true;
	
	//RAPEL DE ENCOSTAS VARS E FUNCS
	_safePos = [0,0,0];
	BRPVP_rapelRapelling = false;
	BRPVP_rapelRope = objNull;
	BRPVP_rapelStopRapel = {
		ropeDestroy BRPVP_rapelRope;
		deleteVehicle BRPVP_svCriaVehRetorno;
		(findDisplay 46) displayRemoveEventHandler ["KeyUp",BRPVP_rapelKeyUpEH];
		BRPVP_rapelRapelling = false;
	};
	BRPVP_rapelRopeUnwind = {
		if (!isNull (_this select 0)) then {
			ropeUnwind _this;
			BRPVP_rapelRopeUnwindPV = _this;
			publicVariable "BRPVP_rapelRopeUnwindPV";
		};
	};
	BRPVP_svCriaVeh = {
		BRPVP_svCriaVehEnvio = _this;
		publicVariableServer "BRPVP_svCriaVehEnvio";
	};
	BRPVP_rapelOnDanger = {
		params ["_pP","_rapelHSafe"];
		_h = _pP select 2;
		if (_h > _rapelHSafe) then {[true]} else {[false,_h]};
	};

	//MINITORA EVENTOS
	_objectOnCursorLast = objNull;
	waitUntil {
		//VARIAVEIS DE EVENTOS
		_agora = time;
		_tempo60 = _agora - _inicio60 > 60;
		_tempo10 = _agora - _inicio10 > 10;
		_tempo1 = _agora - _inicio1 > 1;
		_saiu = [];
		_temSaiu = false;
		{
			if (vehicle player distance (BRPVP_checksDePos select _x select 0) > (BRPVP_checksDePos select _x select 1)) then {
				_saiu pushBack _x;
				_temSaiu = true;
			};
		} count BRPVP_dentroDe;
	
		//RENOVA TRIGGERS DE TEMPO
		if (_tempo1) then {
			_inicio1 = _agora;
			if (BRPVP_countSecs == 2520) then {
				BRPVP_countSecs = 0;
			} else {
				BRPVP_countSecs = BRPVP_countSecs + 1;
			};
		};
		if (_tempo10) then {_inicio10 = _agora;};
		if (_tempo60) then {_inicio60 = _agora;};

		//PLAYER SAIU DE ALGUMA AREA IMPORTANTE (AREAS IMPORTANTES PODEM TER INTERSECAO)
		if (_temSaiu) then {
			{(BRPVP_checksDePos select _x select 0) call (BRPVP_codigoLocais select (BRPVP_checksDePos select _x select 3) select 1);} forEach _saiu;
			BRPVP_dentroDe = BRPVP_dentroDe - _saiu;
			BRPVP_dentroDeMudou = BRPVP_dentroDeMudou + 1;
		};
		
		//PLAYER DAMAGED
		if (BRPVP_playerDamaged) then {
			call BRPVP_atualizaDebug;
			BRPVP_playerDamaged = false;
		};
		
		//UPDATE MENU TO AVOID IT DISSAPEARS
		if (_tempo10) then {
			if ((BRPVP_menuExtraLigado && !BRPVP_menuCustomKeysOff) || BRPVP_construindo) then {
				call BRPVP_atualizaDebugMenu;
			};
		};
		
		//CONHECIDO FN_SELFACTIONS
		if (!_bin1 && !_bin2) then {
			_vec = (getCameraViewDirection player) vectorMultiply 6;
			_posCam = AGLToASL (positionCameraToWorld [0,0,0]);
			_lis = lineIntersectsSurfaces [_posCam,_posCam vectorAdd _vec,player,objNull,true,3,"GEOM","FIRE"];
			_objetoNoCursor = objNull;
			_objetoNoCursorTypeOf = "";
			{
				_objetoNoCursorTypeOf = (_x select 2) call BRPVP_typeOf;
				if (_objetoNoCursorTypeOf != "") exitWith {
					_objetoNoCursor = _x select 2;
				};
			} forEach _lis;
			_changed = _objetoNoCursor != _objectOnCursorLast;
			_objectOnCursorLast = _objetoNoCursor;
			if (!isNull _objetoNoCursor && !_changed && !BRPVP_construindo) then {
				_bdc = _objetoNoCursor getVariable ["bdc",false];
				
				//0 - VENDEDORES ITENS
				_mcdrId = _objetoNoCursor getVariable ["mcdr",-1];
				if (_mcdrId >= 0 && {!(0 in BRPVP_actionRunning)}) then {
					if (BRPVP_actionTrader < 0) then {
						BRPVP_actionTrader = player addAction [("<t>Talk to the merchant</t>"),"actions\actionTrader.sqf",[_objetoNoCursor,_mcdrId,1]];
						_actionOnScreen = true;
					};
				} else {
					player removeAction BRPVP_actionTrader;
					BRPVP_actionTrader = -1;
				};
				
				//1 - VENDEDORES VEICULOS
				_vndv = _objetoNoCursor getVariable ["vndv",[]];
				if (count _vndv > 0 && {!(1 in BRPVP_actionRunning)}) then {
					if (BRPVP_actionVehicleTrader < 0) then {
						_cats = ["Tanks","Cars","APCs","Helicopters","Anti-Air","Artillery"];
						BRPVP_actionVehicleTrader = player addAction [("<t>Call underground merchant</t>"),"actions\actionVehicleTrader.sqf",[_objetoNoCursor,_vndv,_cats,1]];
						_actionOnScreen = true;
					};
				} else {
					player removeAction BRPVP_actionVehicleTrader;
					BRPVP_actionVehicleTrader = -1;
				};

				//2 - REVIVE A PLAYER
				if (_objetoNoCursor getVariable ["dd",-1] == 0 && {!(2 in BRPVP_actionRunning)}) then {
					if (BRPVP_actionRevive < 0) then {
						BRPVP_actionRevive = player addAction [("<t color='#00BB00'>Revive " + (_objetoNoCursor getVariable ["nm","this player"]) + "!</t>"),"actions\actionRevive.sqf",_objetoNoCursor];
						BRPVP_actionFinalize = player addAction [("<t color='#BB0000'>Finalize " + (_objetoNoCursor getVariable ["nm","this player"]) + "!</t>"),"actions\actionFinalize.sqf",_objetoNoCursor];
						_actionOnScreen = true;
					};
				} else {
					player removeAction BRPVP_actionRevive;
					BRPVP_actionRevive = -1;
					player removeAction BRPVP_actionFinalize;
					BRPVP_actionFinalize = -1;
				};
				
				//3 - DESVIRAR CARRO
				if (_objetoNoCursor call BRPVP_IsMotorized && {!(3 in BRPVP_actionRunning)}) then {
					_vu = vectorUp _objetoNoCursor;
					_angA = acos (_vu vectorCos [0,0,1]);
					_angB = acos (_vu vectorCos surfaceNormal (getPosATL _objetoNoCursor));
					if (_angA > 60 && _angB > 20) then {
						if (BRPVP_actionFlipVehicle3 < 0) then {
							BRPVP_actionFlipVehicle3 = player addAction [("<t>Weak Crane</t>"),"actions\actionFlipVehicle.sqf",[_objetoNoCursor,1.5,1]];
							BRPVP_actionFlipVehicle6 = player addAction [("<t>Normal Crane</t>"),"actions\actionFlipVehicle.sqf",[_objetoNoCursor,3,2]];
							BRPVP_actionFlipVehicle12 = player addAction [("<t>Strong Crane</t>"),"actions\actionFlipVehicle.sqf",[_objetoNoCursor,8,3]];
							_actionOnScreen = true;
						};
					} else {
						player removeAction BRPVP_actionFlipVehicle3;
						player removeAction BRPVP_actionFlipVehicle6;
						player removeAction BRPVP_actionFlipVehicle12;
						BRPVP_actionFlipVehicle3 = -1;
						BRPVP_actionFlipVehicle6 = -1;
						BRPVP_actionFlipVehicle12 = -1;
					};
				};
				
				//4 - ADOPT HOUSE
				_ishouse = _objetoNoCursorTypeOf in BRPVP_loot_buildings_class;
				if (_ishouse && {!(4 in BRPVP_actionRunning)}) then {
					_isMine = _objetoNoCursor in BRPVP_myStuff;
					if (!_isMine && !_bdc) then {
						if (BRPVP_actionAdoptHouse < 0) then {
							BRPVP_actionAdoptHouse = player addAction [("<t>Make this your map house!</t>"),"actions\actionMakeMyHouse.sqf",_objetoNoCursor,1.5,false];
							_actionOnScreen = true;
						};
					} else {
						player removeAction BRPVP_actionAdoptHouse;
						BRPVP_actionAdoptHouse = -1;
					};
					if (_isMine && {_objetoNoCursor getVariable ["mapa",false]}) then {
						if (BRPVP_actionRevokeHouse < 0) then {
							BRPVP_actionRevokeHouse = player addAction [("<t color='#FF0000'>[WARNING] Revoke this map house!</t>"),"actions\actionRevokeMyHouse.sqf",_objetoNoCursor,1.5,false];
							_actionOnScreen = true;
						};
					} else {
						player removeAction BRPVP_actionRevokeHouse;
						BRPVP_actionRevokeHouse = -1;
					};
				} else {
					player removeAction BRPVP_actionAdoptHouse;
					BRPVP_actionAdoptHouse = -1;
					player removeAction BRPVP_actionRevokeHouse;
					BRPVP_actionRevokeHouse = -1;
				};
				
				//5 - TRANSFER ITEMS
				_fromUnit = !alive _objetoNoCursor && {_objetoNoCursor isKindOf "Man" && {!isPlayer _objetoNoCursor}};
				_fromHolder = (_objetoNoCursor isKindOf "GroundWeaponHolder" || {_objetoNoCursor isKindOf "WeaponHolderSimulated"}) && {_objetoNoCursor call BRPVP_checaAcesso};
				_fromVehicle = (_objetoNoCursor call BRPVP_isMotorized || {_objetoNoCursorTypeOf find "Box_" == 0}) && {_objetoNoCursor call BRPVP_checaAcesso};
				if ((_fromUnit || _fromHolder || _fromVehicle) && {!(5 in BRPVP_actionRunning)}) then {
					if (BRPVP_actionTranferUC < 0) then {
						if (!isNull BRPVP_sellReceptacle && {_objetoNoCursor != BRPVP_sellReceptacle}) then {
							BRPVP_actionTranferUC = player addAction [("<t color='#FFFF00'>Tranfer Items to Receptacle</t>"),"actions\actionTransfer.sqf",[_objetoNoCursor,BRPVP_sellReceptacle,_fromUnit],100,false];
							_actionOnScreen = true;
						} else {
							if (!isNull BRPVP_holderVault && {_objetoNoCursor != BRPVP_holderVault}) then {
								BRPVP_actionTranferUC = player addAction [("<t color='#FFFF00'>Tranfer Items to Vault</t>"),"actions\actionTransfer.sqf",[_objetoNoCursor,BRPVP_holderVault,_fromUnit],100,false];
								_actionOnScreen = true;
							} else {
								if (!isNull BRPVP_assignedVehicle && {alive BRPVP_assignedVehicle && {_objetoNoCursor != BRPVP_assignedVehicle}}) then {
									_txt = getText (configFile >> "CfgVehicles" >> (typeOf BRPVP_assignedVehicle) >> "displayName");
									BRPVP_actionTranferUC = player addAction [("<t color='#FFFF00'>Tranfer Items to " + _txt + "</t>"),"actions\actionTransfer.sqf",[_objetoNoCursor,BRPVP_assignedVehicle,_fromUnit],100,false];
									_actionOnScreen = true;
								};
							};
						};
					};
				} else {
					player removeAction BRPVP_actionTranferUC;
					BRPVP_actionTranferUC = -1;
				};
				
				//6 - GET MONEY FROM BRIEF CASE
				if (_objetoNoCursorTypeOf == "Land_Suitcase_F") then {
					if (BRPVP_actionBriefcase < 0) then {
						BRPVP_actionBriefcase = player addAction [("<t color='#FFFF00'>$$$</t> <t color='#FFDD00'>Get Money</t>"),"actions\actionGetMoney.sqf",_objetoNoCursor,1.5,true];
						_actionOnScreen = true;
					};
				} else {
					player removeAction BRPVP_actionBriefcase;
					BRPVP_actionBriefcase = -1;
				};
				
				//7 - MY STUFF MENU
				if (_objetoNoCursor in BRPVP_myStuff && {!(7 in BRPVP_actionRunning)}) then {
					if (BRPVP_actionStuff < 0) then {
						BRPVP_actionStuff = player addAction ["<t color='#FFCC55'>Item menu</t>","actions\actionItemMenu.sqf",_objetoNoCursor];
						_actionOnScreen = true;
					};
				} else {
					player removeAction BRPVP_actionStuff;
					BRPVP_actionStuff = -1;
				};

				//8 - BULLDOZER
				if (_bdc && {!(8 in BRPVP_actionRunning)}) then {
					if (BRPVP_actionBulldozer < 0) then {
						_price = if (_objetoNoCursor call BRPVP_isMotorized) then {1000} else {2000};
						BRPVP_actionBulldozer = player addAction ["<t color='#666666'>Clean Ruins - $" + str _price + "</t>","actions\actionBulldozer.sqf",[_price,_objetoNoCursor]];
						_actionOnScreen = true;
					};
				} else {
					player removeAction BRPVP_actionBulldozer;
					BRPVP_actionBulldozer = -1;
				};
				
				//9 - RADAR SPOTS
				_antennaIndex = BRPVP_antennasObjs find _objetoNoCursorTypeOf;
				if (_antennaIndex != -1 && {!(9 in BRPVP_actionRunning)}) then {
					if (BRPVP_actionRadarSpot < 0) then {
						_force = BRPVP_antennasObjsForce select _antennaIndex;
						BRPVP_actionRadarSpot = player addAction ["<t color='#4040FF'>Turn on Radar</t>","actions\actionRadarSpot.sqf",[_objetoNoCursor,_force]];
						_actionOnScreen = true;
					};
				} else {
					player removeAction BRPVP_actionRadarSpot;
					BRPVP_actionRadarSpot = -1;
				};
				
				//DISMANTLE OTHERS RESPAWN
				if (_objetoNoCursorTypeOf in (BRP_kitRespawnA + BRP_kitRespawnB) && {!(_objetoNoCursor in BRPVP_myStuff)}) then {
					if (BRPVP_actionDismantleRespawn < 0) then {
						BRPVP_actionDismantleRespawn = player addAction ["<t color='#9050FF'>Dismantle Respawn ($ 3500)</t>","actions\actionDismantleRespawn.sqf",_objetoNoCursor];
						_actionOnScreen = true;
					};
				} else {
					player removeAction BRPVP_actionDismantleRespawn;
					BRPVP_actionDismantleRespawn = -1;
				};

				//TURN LIGHT OFF
				_accessLamp = _objetoNoCursorTypeOf in BRP_kitLamp && {_objetoNoCursor call BRPVP_checaAcesso};
				if (_accessLamp) then {
					if (BRPVP_actionSwitchLampOn < 0) then {
						BRPVP_actionSwitchLampOn = player addAction ["<t color='#BBFF00'>Turn On</t>","actions\actionLightOn.sqf",_objetoNoCursor];
						_actionOnScreen = true;
					};
				} else {
					player removeAction BRPVP_actionSwitchLampOn;
					BRPVP_actionSwitchLampOn = -1;
				};

				//TURN LIGHT OFF
				if (_accessLamp) then {
					if (BRPVP_actionSwitchLampOff < 0) then {
						BRPVP_actionSwitchLampOff = player addAction ["<t color='#AAEE00'>Turn Off</t>","actions\actionLightOff.sqf",_objetoNoCursor];
						_actionOnScreen = true;
					};
				} else {
					player removeAction BRPVP_actionSwitchLampOff;
					BRPVP_actionSwitchLampOff = -1;
				};
			} else {
				if (_actionOnScreen) then {
					_actionOnScreen = false;
					player removeAction BRPVP_actionTrader;
					BRPVP_actionTrader = -1;
					player removeAction BRPVP_actionVehicleTrader;
					BRPVP_actionVehicleTrader = -1;
					player removeAction BRPVP_actionRevive;
					BRPVP_actionRevive = -1;
					player removeAction BRPVP_actionFinalize;
					BRPVP_actionFinalize = -1;
					player removeAction BRPVP_actionFlipVehicle3;
					player removeAction BRPVP_actionFlipVehicle6;
					player removeAction BRPVP_actionFlipVehicle12;
					BRPVP_actionFlipVehicle3 = -1;
					BRPVP_actionFlipVehicle6 = -1;
					BRPVP_actionFlipVehicle12 = -1;
					player removeAction BRPVP_actionAdoptHouse;
					BRPVP_actionAdoptHouse = -1;
					player removeAction BRPVP_actionRevokeHouse;
					BRPVP_actionRevokeHouse = -1;
					player removeAction BRPVP_actionTranferUC;
					BRPVP_actionTranferUC = -1;
					player removeAction BRPVP_actionBriefcase;
					BRPVP_actionBriefcase = -1;
					player removeAction BRPVP_actionStuff;
					BRPVP_actionStuff = -1;
					player removeAction BRPVP_actionBulldozer;
					BRPVP_actionBulldozer = -1;
					player removeAction BRPVP_actionRadarSpot;
					BRPVP_actionRadarSpot = -1;
					player removeAction BRPVP_actionDismantleRespawn;
					BRPVP_actionDismantleRespawn = -1;
					player removeAction BRPVP_actionSwitchLampOff;
					BRPVP_actionSwitchLampOff = -1;
					player removeAction BRPVP_actionSwitchLampOn;
					BRPVP_actionSwitchLampOn = -1;
				};
			};
			//CUT CONNECTION
			if (9 in BRPVP_actionRunning) then {
				if (BRPVP_actionRadarCut < 0) then {
					BRPVP_actionRadarCut = player addAction ["<t color='#8040FF'>Cut Radar Connection</t>",{BRPVP_connectionOn = false;},[]];
				};
			} else {
				if (BRPVP_actionRadarCut != -1) then {
					player removeAction BRPVP_actionRadarCut;
					BRPVP_actionRadarCut = -1;
				};
			};
		};
		
		//ATUALIZA DEBUG DE 1 EM 1 SEGUNDO
		if (_tempo1) then {call BRPVP_atualizaDebug;};
		
		//AJUSTA VISAO DOS OBJETOS
		if (_tempo10) then {
			if (viewDistance != BRPVP_viewDist) then {setViewDistance BRPVP_viewDist;};
			if (getObjectViewDistance select 0 != BRPVP_viewObjsDist) then {setObjectViewDistance BRPVP_viewObjsDist;};
		};
		
		//ATUALIZA FOME DO PLAYER E PROCESSA DANOS
		if (_tempo60) then {
			if (player getVariable ["sok",false]) then {
				BRPVP_alimentacao = (BRPVP_alimentacao - (0 * BRPVP_multiplicadorDanoAdmin)) max 0;
				_males = [];
				if (BRPVP_alimentacao < 5) then {_males = _males + ["fomeBraba"];};
				if (BRPVP_alimentacao < 25 && BRPVP_alimentacao >= 5) then {_males = _males + ["fome"];};
				_males call BRPVP_efeitosSaude;
				player setVariable ["sud",[round BRPVP_alimentacao,100],true];
			};
		};

		//RAPEL DE ENCOSTAS
		if (_bin1 && _bin2) then {
			if (!BRPVP_rapelRapelling) then {
				_pP = getPosASL player;
				_rapelIt = [getPos player,3.5] call BRPVP_rapelOnDanger;
				if (_rapelIt select 0) then {
					if (animationState player find "ladder" == -1 && _pP distanceSqr _safePos <= 4) then {
						BRPVP_rapelRapelling = true;
						_vel = velocity player;
						_pole = (vectorNormalized _vel) vectorMultiply 0.8;
						_pR = (_pP vectorAdd _pole) vectorAdd [0,0,-0.5];
						[player,["B_static_AA_F",ASLToAGL _pR,[],0,"CAN_COLLIDE"]] call BRPVP_svCriaVeh;
						BRPVP_rapelKeyUpEH = (findDisplay 46) displayAddEventHandler ["KeyUp",{
							params ["_unused","_key","_shift","_ctrl","_alt"];
							_return = false;
							if (!isNull BRPVP_rapelRope) then {
								if (_key == 0x11 && ropeUnwound BRPVP_rapelRope) then {
									_return = true;
									[BRPVP_rapelRope,5,-0.5,true] call BRPVP_rapelRopeUnwind;
								};
								if (_key == 0x1F && ropeUnwound BRPVP_rapelRope) then {
									_return = true;
									_delta = 2 min (((getPos player) select 2) - 0.1);
									[BRPVP_rapelRope,5,_delta,true] call BRPVP_rapelRopeUnwind;
								};
								if (_key == 0x39 && !_shift) then {
									_return = true;
									call BRPVP_rapelStopRapel;
								};
								if (_key == 0x39 && _shift) then {
									_return = true;
									call BRPVP_rapelStopRapel;
									_dir = getDir player;
									player setVelocity [5*sin(_dir),5*cos(_dir),2.5];
								};
								if (_key in actionKeys "Prone") then {_return = true;};
							};
							_return
						}];
					};
				} else {
					_h = _rapelIt select 1;
					if (vehicle player == player && stance player != "PRONE" && _h < 0.25) then {
						_safePos = _pP;
					};
				};
			} else {
				if (!isNull BRPVP_rapelRope) then {
					if !(([getPos player,0.5] call BRPVP_rapelOnDanger) select 0) then {
						call BRPVP_rapelStopRapel;
					};
				};
			};
		};

		_bin1 = !_bin1;
		if (_bin1) then {_bin2 = !_bin2;};
		false
	};
};

diag_log "[BRPVP FILE] loops.sqf END REACHED";