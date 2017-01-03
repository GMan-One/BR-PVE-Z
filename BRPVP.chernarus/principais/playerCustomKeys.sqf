diag_log "[BRPVP FILE] teclas_custom.sqf INITIATED";

//CODIGO DE TRATAMENTO DO MENU EXTRA
BRPVP_menuCode = {
	if (_key == 0x11 && _XXX) then {
		if (BRPVP_menuOpcoesSel >= 0) then {
			BRPVP_menuOpcoesSel = (BRPVP_menuOpcoesSel - 1) mod count BRPVP_menuOpcoes;
			if (BRPVP_menuOpcoesSel == -1) then {BRPVP_menuOpcoesSel = ((count BRPVP_menuOpcoes) - 1);};
			call BRPVP_atualizaDebugMenu;
			playSound "hint";
		};
	};
	if (_key == 0x1F && _XXX) then {
		if (BRPVP_menuOpcoesSel >= 0) then {
			BRPVP_menuOpcoesSel = (BRPVP_menuOpcoesSel + 1) mod count BRPVP_menuOpcoes;
			call BRPVP_atualizaDebugMenu;
			playSound "hint";
		};
	};
	if (_key == 0x39 && _XXX) then {
		if !(call BRPVP_menuForceExit) then {
			private ["_destino"];
			BRPVP_menuPos set [BRPVP_menuIdc,BRPVP_menuOpcoesSel];
			if (BRPVP_menuTipo == 0) then {
				call BRPVP_menuCodigo;
				if (typeName BRPVP_menuDestino == "ARRAY") then {
					_destino = BRPVP_menuDestino select BRPVP_menuOpcoesSel;
					_destino spawn BRPVP_menuMuda;
				} else {
					if (BRPVP_menuDestino >= 0) then {
						BRPVP_menuDestino spawn BRPVP_menuMuda;
					};
				};
			} else {
				if (BRPVP_menuTipo == 2) then {
					(BRPVP_menuExecutaParam select BRPVP_menuOpcoesSel) call BRPVP_menuExecutaFuncao;
				};
			};
		} else {
			playSound "erro";
			BRPVP_menuExtraLigado = false;
			call BRPVP_atualizaDebug;
		};
	};
	if (_key == 0x1E && _XXX) then {
		if (typeName BRPVP_menuVoltar == "SCALAR") then {
			BRPVP_menuVoltar spawn BRPVP_menuMuda;
		} else {
			if (typeName BRPVP_menuVoltar == "CODE") then {
				call BRPVP_menuVoltar;
			};
		};
	};
};

//TRATAMENTO DE TECLAS PARA CONSTRUCAO
BRPVP_consCode = {
	//CHANGE OBJECT -1
	if (_key == 0x10 && _XXX) then {
		_retorno = true;
		_conta = count BRPVP_construindoItens;
		BRPVP_construindoItemIdc = BRPVP_construindoItemIdc - 1;
		if (BRPVP_construindoItemIdc == -1) then {BRPVP_construindoItemIdc = (_conta - 1);};
		BRPVP_construindoItem = BRPVP_construindoItens select BRPVP_construindoItemIdc;
		[] spawn BRPVP_consSpawnItem;
		playSound "hint";
	};

	//CHANGE OBJECT +1
	if (_key == 0x12 && _XXX) then {
		_retorno = true;
		_conta = count BRPVP_construindoItens;
		BRPVP_construindoItemIdc = (BRPVP_construindoItemIdc + 1) mod _conta;
		BRPVP_construindoItem = BRPVP_construindoItens select BRPVP_construindoItemIdc;
		[] spawn BRPVP_consSpawnItem;
		playSound "hint";
	};

	//MUDA ANG
	if (_key == 0x2D && _XXX) then {
		_retorno = true;
		_conta = count BRPVP_construindoAngsRotacao;
		BRPVP_construindoAngRotacaoIdc = (BRPVP_construindoAngRotacaoIdc + 1) mod _conta;
		BRPVP_construindoAngRotacao = BRPVP_construindoAngsRotacao select BRPVP_construindoAngRotacaoIdc;
		call BRPVP_atualizaDebugMenu;
	};

	//SET OBJECT ORIGIN
	if (_key == 0x15) then {
		_retorno = true;
		if (BRPVP_construindoPega select 0 >= 0) then {
			if (BRPVP_buildingLevelTerrain) then {
				_poWorld = getPosWorld BRPVP_construindoItemObj;
				_ho = _poWorld select 2;
				_ppWorld = getPosWorld player;
				_hp = _ppWorld select 2;
				_h = _ho - _hp;
				BRPVP_construindoHIntSet = _h;
			} else {
				_poWorld = getPosWorld BRPVP_construindoItemObj;
				_poGround = [_poWorld select 0,_poWorld select 1,0];
				_poGroundASL = AGLToASL _poGround;
				_ho = (_poWorld select 2) - (_poGroundASL select 2);
				BRPVP_construindoHIntSet = _ho;
			};
		};
		BRPVP_buildingLevelTerrain = !BRPVP_buildingLevelTerrain;
		call BRPVP_atualizaDebugMenu;
	};

	//RODA Z+ RODA Z-
	if ((_key == 0x2E || _key == 0x2C) && _XXX) then {
		_retorno = true;
		_dAng = BRPVP_construindoAngRotacao;
		if (_key == 0x2C) then {_dAng = -_dAng;};
		BRPVP_construindoAngRotacaoSet = (BRPVP_construindoAngRotacaoSet + _dAng) mod 360;
	};
	
	//SETA INTENSIDADE H
	if (_key == 0x2F && _XXX) then {
		_retorno = true;
		_conta = count BRPVP_construindoHInts;
		BRPVP_construindoHIntIdc = (BRPVP_construindoHIntIdc + 1) mod _conta;
		BRPVP_construindoHInt = BRPVP_construindoHInts select BRPVP_construindoHIntIdc;
		call BRPVP_atualizaDebugMenu;
	};
	
	//MOVE H + MOVE H -
	if ((_key == 0x13 || _key == 0x21) && _XXX) then {
		_retorno = true;
		_h = BRPVP_construindoHInt;
		if (_key == 0x21) then {_h = -_h;};
		BRPVP_construindoHIntSet = BRPVP_construindoHIntSet + _h;
	};
	
	//PEGA & SOLTA
	if (_key == 0x39 && _XXX) then {
		_retorno = true;
		if (BRPVP_construindoPega select 0 == -1) then {
			if (player distance BRPVP_construindoItemObj <= BRPVP_construindoFrente * 8) then {
				private ["_BRPVP_construindoHIntSet"];
				if (BRPVP_buildingLevelTerrain) then {
					_poWorld = getPosWorld BRPVP_construindoItemObj;
					_poGround = [_poWorld select 0,_poWorld select 1,0];
					_poGroundASL = AGLToASL _poGround;
					_ho = (_poWorld select 2) - (_poGroundASL select 2);
					_BRPVP_construindoHIntSet = _ho;
				} else {
					_pP = (getPosworld player) select 2;
					_oP = (getPosWorld BRPVP_construindoItemObj) select 2;
					_BRPVP_construindoHIntSet = _oP - _pP;
				};
				BRPVP_construindoPega = [
					player distance2D BRPVP_construindoItemObj,
					getDir player
				];
				BRPVP_construindoHIntSet = _BRPVP_construindoHIntSet;
				BRPVP_construindoDirPlyObj = [player,BRPVP_construindoItemObj] call BIS_fnc_dirTo;
			} else {
				playSound "erro";
			};
		} else {
			BRPVP_construindoPega = [-1];
			BRPVP_construindoHIntSet = 0;
		};
	};
	
	//VERTICAL ALIGMENT 
	if (_key == 0x14 && _XXX) then {
		_retorno = true;
		BRPVP_construindoAlinTerr = false;
		BRPVP_construindoItemObj setVectorUp [0,0,1];
	};
	
	//TERRAIN ALIGMENT 
	if (_key == 0x22 && _XXX) then {
		_retorno = true;
		BRPVP_construindoAlinTerr = true;
	};

	//CANCELA CONSTRUCAO
	if (_key == 0xD3 && _XXX) then {
		_retorno = true;
		call BRPVP_cancelaConstrucao;
	};
	
	//CONCLUI POSITIVO
	if (_key == 0x1C && _XXX) then {
		private ["_vComplete","_isSO","_estadoCons","_actualRespawnSpots"];
		_retorno = true;
		
		//CHECK IF IS RESPAWN SPOT AND IF CAN BUILD. EXIT IF CANT BUILD.
		_isRespawnSpot = BRPVP_construindoItemObjClass in BRP_kitRespawnA || BRPVP_construindoItemObjClass in BRP_kitRespawnB;
		if (_isRespawnSpot) then {
			_actualRespawnSpots = {
				_typeOf = _x call BRPVP_typeOf;
				_typeOf in BRP_kitRespawnA || _typeOf in BRP_kitRespawnB
			} count BRPVP_myStuff;
		};
		if (_isRespawnSpot && {_actualRespawnSpots > 0}) exitWith {["You already have a Spawn Spot!\nRemove it first!",4,12,6374,"erro"] call BRPVP_hint;};
		
		_hMin = (BRPVP_buildingsHeightFixValue select (BRPVP_buildingsHeightFixClass find BRPVP_construindoItemObjClass)) * 0.5;
		if ((ASLToAGL getPosWorld BRPVP_construindoItemObj) select 2 < _hMin) exitWith {["Ooops!\nThe object is too much inside the terrain...",4,12,6374,"erro"] call BRPVP_hint;};
			
		BRPVP_construindoItemObj removeAllEventHandlers "HandleDamage";
		_posW = getPosWorld BRPVP_construindoItemObj;
		_vdu = [vectorDir BRPVP_construindoItemObj,vectorUp BRPVP_construindoItemObj];
		if (BRPVP_construindoItemObjClass in BRPVP_buildingHaveDoorList) then {
			_vComplete = createVehicle [BRPVP_construindoItemObjClass,[0,0,0],[],0,"CAN_COLLIDE"];
			_state = if (BRPVP_construindoItemObjClass in BRPVP_buildingHaveDoorListReverseDoor) then {1} else {0};
			if (_vComplete call BRPVP_isBuilding) then {
				{
					if (_vComplete animationPhase _x != _state) then {
						_vComplete animate [_x,_state];
					};
				} forEach animationNames _vComplete;
			};
			_isSO = false;
		} else {
			_model = getText (configFile >> "CfgVehicles" >> BRPVP_construindoItemObjClass >> "model") splitString "";
			if (_model select 0 == "\") then {_model deleteAt 0;};
			_qc = (count _model) - 1;
			_finalChars = (_model select (_qc -3)) + (_model select (_qc -2)) + (_model select (_qc -1)) + (_model select _qc);
			if !(_finalChars in [".p3d",".P3D"]) then {
				_model append [".","p","3","d"];
			};
			_vComplete = createSimpleObject [_model joinString "",AGLToASL [0,0,0]];
			[_vComplete,"cnm",BRPVP_construindoItemObjClass] call BRPVP_setVariable;
			_isSO = true;
		};
		_vComplete setVectorDirAndUp _vdu;
		_vComplete setPosWorld _posW;
		_del = BRPVP_construindoItemObj;
		BRPVP_construindoItemObj = _vComplete;
		deleteVehicle _del;

		//SET LAMP STATE
		_exec = "";
		if (BRPVP_construindoItemObjClass in BRP_kitLamp) then {
			BRPVP_construindoItemObj switchLight "OFF";
			_exec = "_this setDamage 0.95;";
		};
		
		BRPVP_construindo = false;
		call BRPVP_atualizaDebugMenu;
		BRPVP_construindoItemIdc = 0;
		if (_isSO) then {
			[BRPVP_construindoItemObj,"own",player getVariable ["id_bd",-1]] call BRPVP_setVariable;
		} else {
			BRPVP_construindoItemObj setVariable ["own",player getVariable ["id_bd",-1],true];
			BRPVP_construindoItemObj setVariable ["stp",player getVariable ["dstp",1],true];
			BRPVP_construindoItemObj setVariable ["amg",player getVariable ["amg",[]],true];
		};
		BRPVP_myStuff pushBack BRPVP_construindoItemObj;
		["mastuff"] call BRPVP_atualizaIcones;
		BRPVP_ownedHousesAdd = BRPVP_construindoItemObj;
		publicVariableServer "BRPVP_ownedHousesAdd";
		if (_isSO) then {
			_estadoCons = [
				[[[],[]],[[],[]],[[],[]],[[],[]]],
				[getPosWorld BRPVP_construindoItemObj,[vectorDir BRPVP_construindoItemObj,vectorUp BRPVP_construindoItemObj]],
				BRPVP_construindoItemObjClass,
				player getVariable ["id_bd",-1],
				1,
				[],
				_exec
			];
		} else {
			_estadoCons = [
				[[[],[]],[[],[]],[[],[]],[[],[]]],
				[getPosWorld BRPVP_construindoItemObj,[vectorDir BRPVP_construindoItemObj,vectorUp BRPVP_construindoItemObj]],
				BRPVP_construindoItemObjClass,
				BRPVP_construindoItemObj getVariable ["own",-1],
				BRPVP_construindoItemObj getVariable ["stp",1],
				BRPVP_construindoItemObj getVariable ["amg",[]],
				_exec
			];
		};
		BRPVP_adicionaConstrucaoBd = [false,BRPVP_construindoItemObj,_estadoCons,_isSO];
		publicVariableServer "BRPVP_adicionaConstrucaoBd";
		[["itens_construidos",1]] call BRPVP_mudaExp;
		_sit = player getVariable "sit";
		_i = _sit find BRPVP_construindoItemRetira;
		if (_i >= 0) then {
			_sit deleteAt _i;
			player setVariable ["sit",_sit,true];
		};
		player setVariable ["obui",objNull,true];
		
		//SET NEW RESPAWN SPOT
		if (_isRespawnSpot) then {
			BRPVP_respawnSpot = BRPVP_construindoItemObj;
			["geral"] call BRPVP_atualizaIcones;
		};

		35 call BRPVP_iniciaMenuExtra;
	};
};

//TECLAS CUSTOMIZADAS PARA TODOS OS PLAYERS
player_keydown = {
	params ["_controle","_key","_keyShift","_keyCtrl","_keyAlt"];
	_retorno = false;
	//COMBINACOES CONTROL SHIFT ALT
	_XXX = !_keyShift && !_keyCtrl && !_keyAlt;
	_SXX = _keyShift && !_keyCtrl && !_keyAlt;
	_XCX = !_keyShift && _keyCtrl && !_keyAlt;
	_XXA = !_keyShift && !_keyCtrl && _keyAlt;
	_XCA = !_keyShift && _keyCtrl && _keyAlt;
	
	//CONSTRUCAO VARIOS COMANDOS
	if (BRPVP_construindo) then {
		call BRPVP_consCode;
	} else {
		//EXTRA MENU
		if (BRPVP_menuExtraLigado) then {
			if (!BRPVP_menuCustomKeysOff) then {call BRPVP_menuCode;};
			_retorno = !(_key in BRPVP_notBlockedKeys);
		} else {
			if (player getVariable ["sok",false]) then {
				if (alive player) then {
					//SPECIAL ITEMS
					if (_key == 0x17 && _XXA) then {
						_retorno = true;
						35 call BRPVP_iniciaMenuExtra;
					};
					
					//PLAYER MENU
					if (_key == 0x10 && _XXA) then {
						_retorno = true;
						playSound "achou_loot";
						BRPVP_suicidouTrava = 5;
						30 call BRPVP_iniciaMenuExtra;
					};

					//VAULT
					if (_key == 0x2F && _XXA) then {
						_retorno = true;
						_tempo = (BRPVP_vaultAcaoTempo - time) max 0;
						if (_tempo > 0) then {
							["Wait " + str ((round _tempo) max 1) + " seconds to close/open the vault again!",0] call BRPVP_hint;
						} else {
							if (!BRPVP_vaultLigada) then {
								BRPVP_vaultLigada = true;
								BRPVP_vaultAcaoTempo = time + 10;
								call BRPVP_vaultAbre;
							} else {
								BRPVP_vaultLigada = false;
								BRPVP_vaultAcaoTempo = time + 10;
								call BRPVP_vaultRecolhe;
							};
						};
					};

					//SETAS PARA AMIGOS
					if (_key in [0x02,0x03,0x04] && _XCX) then {
						private ["_idc"];
						_retorno = true;
						if (_key == 0x02) then {_idc = 0;};
						if (_key == 0x03) then {_idc = 1;};
						if (_key == 0x04) then {_idc = 2;};
						_setas = player getVariable ["sts",[[],[],[]]];
						if (count (_setas select _idc) == 0) then {
							_ct = cursorObject;
							if (!isNull _ct) then {
								_bb = boundingBoxReal _ct;
								_h = abs ((_bb select 0 select 2) - (_bb select 1 select 2));
								_pASL = getPosASL _ct;
								_p3D = ASLToAGL ((lineIntersectsSurfaces [_pASL vectorAdd [0,0,_h],_pASL]) select 0 select 0);
								_setas set [_idc,_p3D];
							} else {
								_p2D = screenToWorld [0.5,0.5];
								_setas set [_idc,[_p2D select 0,_p2D select 1]];
							};
							player setVariable ["sts",_setas,true];
						} else {
							_setas set [_idc,[]];
							player setVariable ["sts",_setas,true];
						};
					};

					//INFORMACOES DO OBJETO NA MIRA
					if (_key == 0x17 && _XCA) then {
						_retorno = true;
						_obj = cursorObject;
						if (!isNull _obj) then {
							BRPVP_objetoMarcado = _obj;
							_objClass = typeOf _obj;
							if (_obj distance player < ((sizeOf _objClass) * 1.5)) then {
								_objPos = getPosATL _obj;
								_objPos = [(round((_objPos select 0)*100))/100,(round((_objPos select 1)*100))/100,(round((_objPos select 2)*100))/100];
								_objVu = vectorUp _obj;
								_objVu = [round((_objVu select 0)*100)/100,round((_objVu select 1)*100)/100,round((_objVu select 2)*100)/100];
								_objDir = (round ((getDir _obj)*100))/100;
								["ctc: " + _objClass + " | " + "ctp: " + str _objPos + "\n" + "ctd: " + str _objDir + " | " + "ctv: " + str _objVu + "\n" + "cts: " + str _obj,10,2,437] call BRPVP_hint;
							};
						} else {
							BRPVP_objetoMarcado = objNull;
						};
					};
					
					//INFORMACOES DO PLAYER
					if (_key == 0x19 && _XCA) then {
						_retorno = true;
						_pos = getPosATL player;
						_pos = [(round((_pos select 0)*100))/100,(round((_pos select 1)*100))/100,(round((_pos select 2)*100))/100];
						_class = typeOf player;
						_vu = vectorUp player;
						_vu = [round((_vu select 0)*100)/100,round((_vu select 1)*100)/100,round((_vu select 2)*100)/100];
						_dir = (round ((getDir player)*100))/100;
						["plc: " + _class + " | " + "plp: " + str _pos + "\n" + "pld: " + str _dir + " | " + "plv: " + str _vu,10,2,437] call BRPVP_hint;
						diag_log ("[INFO] Position: " + str _pos + " / Direction: " + str _dir);
					};

					//DEBUG
					if (_key == 0xD2 && _XXX) then {
						_retorno = true;
						BRPVP_indiceDebug = (BRPVP_indiceDebug + 1) mod (count BRPVP_indiceDebugItens);
						if (BRPVP_indiceDebug == 0) then {
							BRPVP_indiceDebugTxt = "Main Debug!";
						};
						if (BRPVP_indiceDebug == 1) then {
							BRPVP_indiceDebugTxt = "Info Debug!";
						};
						if (BRPVP_indiceDebug == 2) then {
							BRPVP_indiceDebugTxt = "Min Debug!";
						};
						call BRPVP_atualizaDebug;
					};

					//ABRE PARAQUEDAS
					if (_key == 0x39 && (_XXX || _SXX) && !BRPVP_menuExtraLigado) then {
						if (typeOf unitBackpack player == "B_parachute" && alive player) then {
							_retorno = true;
							player action ["OpenParachute",player];
						};
					};
					
					//SKY DIVE
					if (!isNil "BRPVP_nascendoParaQuedas" && !BRPVP_aceleraParaRodando) then {
						if ((_key == 0x11 || _key == 0x1F) && _SXX) then {
							BRPVP_aceleraParaRodando = true;
							if (_key == 0x11) then {
								_retorno = BRPVP_paraParam select 2;
								_nil = "descer" spawn BRPVP_aceleraPara;
							};
							if (_key == 0x1F) then {
								_retorno = BRPVP_paraParam select 3;
								_nil = "subir" spawn BRPVP_aceleraPara;
							};
						};
					};
				} else {
					if (_key == 0x39 && _XXX) then {
						_retorno = true;
						if (player getVariable ["dd",-1] == 0) then {
							player setVariable ["dd",1,true];
						};
					};
					if (BRPVP_trataseDeAdmin && {_key == 0x39 && _XXA}) then {
						_retorno = true;
						if (player getVariable ["dd",-1] == 0) then {
							player setVariable ["dd",2,true];
						};
					};
				};
			};
		};
	};
	_retorno
};

//TECLAS CUSTOMIZADAS PARA ADMINS
admin_keydown = {
	params ["_controle","_key","_keyShift","_keyCtrl","_keyAlt"];
	_retorno = false;
	if (alive player) then {
		//COMBINACOES CONTROL SHIFT ALT
		_XXA = !_keyShift && !_keyCtrl && _keyAlt;
		_XXX = !_keyShift && !_keyCtrl && !_keyAlt;
		_XCX = !_keyShift && _keyCtrl && !_keyAlt;

		//ADMIN MENU
		if (_key == 0x12 && _XXA) then {
			_retorno = true;
			29 call BRPVP_iniciaMenuExtra;
		};
		
		if (player getVariable ["sok",false]) then {
			//PULO A FRENTE
			if (_key == 0x06 && _XXX) then {
				_retorno = true;
				_dir = getDir vehicle player;
				_pAGL = getPos vehicle player;
				_hAGL = _pAGL select 2;
				if (_hAGL < 0.5) then {
					vehicle player setVehiclePosition [[(_pAGL select 0) + 5 * (sin _dir),(_pAGL select 1) + 5 * (cos _dir),0],[],0,"NONE"];
					player setDir _dir;
				} else {
					_pASL = getPosASL vehicle player;
					_pxASL = [(_pASL select 0) + 5 * (sin _dir),(_pASL select 1) + 5 * (cos _dir),_pASL select 2];
					_pxATL = ASLToATL _pxASL;
					_hOk = (_pxATL select 2) > 0;
					if (_hOk) then {vehicle player setPosASL _pxASL;} else {vehicle player setPosATL _pxATL;};
				};
			};
			
			//SUBIR NO EIXO Z
			if (_key == 0x05 && _XXX) then {
				_retorno = true;
				_vel = velocity vehicle player;
				_add = 1;
				if (_vel select 2 < 0) then {_add = 1 - (_vel select 2);};
				_velNew = [_vel select 0,_vel select 1,((_vel select 2) + _add) min 20];
				vehicle player setVelocity _velNew;
			};
		};
	};
	_retorno
};

//TECLAS CUSTOM
_nulo = [] spawn {
	waitUntil {!isNull (findDisplay 46)};
	if (BRPVP_trataseDeAdmin) then {
		//DISPLAY EVENT HANDLER PARA ADMINS: TECLAS CUSTOM
		(findDisplay 46) displayAddEventHandler ["keyDown",{_this call admin_keydown || _this call player_keydown || (BRPVP_keyBlocked && !((_this select 1) in BRPVP_notBlockedKeys))}];
	} else {
		//DISPLAY EVENT HANDLER PARA PLAYERS: TECLAS CUSTOM
		(findDisplay 46) displayAddEventHandler ["keyDown",{_this call player_keydown || (BRPVP_keyBlocked && !((_this select 1) in BRPVP_notBlockedKeys))}];
	};
	(findDisplay 46) displayAddEventHandler ["keyUp",{BRPVP_keyBlocked}];
};

diag_log "[BRPVP FILE] teclas_custom.sqf END REACHED";