diag_log "[BRPVP FILE] playerEH.sqf INITIATED";

//ADICIONA EVENT HANDLERS
player addEventHandler ["Respawn",{
	params ["_unit","_corpse"];
	_unit setVariable ["dd",-1,true];
	_unit setVariable ["sok",false,true];
	setPlayerRespawnTime 500;
	cutText ["","BLACK FADED",10];
	diag_log "[BRPVP RESPAWN] PLAYER RESPAWNED!";
	BRPVP_playerLastCorpse = _corpse;
	BRPVP_disabledBodyDamage = false;
	_corpse setVariable ["stp",3,true];
	if (_corpse getVariable "dd" == 2) then {
		[] spawn {call BRPVP_nascimento_player;};
	};
	if (_corpse getVariable "dd" == 1) then {
		_corpse setVariable ["hrm",serverTime,true];
		execVM "init.sqf";
	};
}];
BRPVP_playerKilled = {
	if (BRPVP_reviveOn) then {
		//LOG DO SISTEMA
		diag_log "[BRPVP REVIVE] killed EH - player died while disabled!";
		
		//LAST BREATH
		playSound3D [BRPVP_missionRoot + "BRP_sons\nobreath.ogg",player,false,getPosASL player,0.25,1,0];
	} else {
		BRPVP_setaVidaPlayer = [getPlayerUID player,0];
		publicVariableServer "BRPVP_setaVidaPlayer";
	};

	//ATUALIZA ESTATISTICAS
	_matador = _this;
	if (_matador isKindof "LandVehicle" || _matador isKindof "Air") then {_matador = effectiveCommander _matador;};
	if (_matador isKindOf "CAManBase") then {
		if (isPlayer _matador) then {
			if (_matador != player) then {
				//FOI MORTO POR PLAYER: ATUALIZA ESTAT. MORTO
				[["player_matou",1]] call BRPVP_mudaExp;
				
				//FOI MORTO POR PLAYER: ATUALIZA ESTAT. MATADOR
				BRPVP_mudaExpOutroPlayer = [_matador,[["matou_player",1]]];
				publicVariableServer "BRPVP_mudaExpOutroPlayer";
			} else {
				if (!BRPVP_suicidou) then {
					//MOREU SOZINHO: QUEDA OU CHOQUE FISICO
					[["queda",1]] call BRPVP_mudaExp;
				} else {
					//MOREU SOZINHO: CONTROL + K (JA ESTATISTICOU)
					BRPVP_suicidou = false;
				};
			};
		} else {
			//FOI MORTO POR BOT
			[["bot_matou",1]] call BRPVP_mudaExp;
		};
	};
	
	//MENSAGEM DE KILL
	_pNome = player getVariable ["nm","sem_nome"];
	_tempoTiro = BRPVP_mensagemDeKillArray select 0;
	if (_tempoTiro > 0) then {
		_tempoSangra = time - _tempoTiro;
		if (_tempoSangra < 5) then {
			_KM_max = -1;
			_KM_tot = 0;
			_KM_maxIndex = -1;
			{
				_KM_tot = _KM_tot + _x;
				if (_x >= _KM_max) then {
					_KM_max = _x;
					_KM_maxIndex = _forEachIndex;
				};
			} forEach BRPVP_HDAtacantesDano;
			_KM_agres = BRPVP_HDAtacantes select _KM_maxIndex;
			_KM_agresPerc = str round ((_KM_max/_KM_tot) * 100) + "%";
			_aClass = BRPVP_mensagemDeKillArray select 2;
			_aNome = getText (configFile >> "CfgWeapons" >> _aClass >> "displayName");
			BRPVP_mensagemDeKillTxt = [
				"BRPVP_morreu_1",
				[
					_pNome, //ATACADO
					BRPVP_mensagemDeKillArray select 1, //OFENSOR
					_aNome, //ARMA USADA
					BRPVP_mensagemDeKillArray select 3, //DISTANCIA
					_KM_agres, //MOST AGRESSOR
					_KM_agresPerc //MOST AGRESSOR PERC
				]
			];
		} else {
			BRPVP_mensagemDeKillTxt = [
				"BRPVP_morreu_2",
				[_pNome,BRPVP_mensagemDeKillArray select 1,str round _tempoSangra]
			];
		};
	} else {
		BRPVP_mensagemDeKillTxt = ["BRPVP_morreu_3",[_pNome]];
	};
	BRPVP_mensagemDeKillTxt call LOL_fnc_showNotification;

	//ENVIA MENSAGEM DE KILL PARA OUTROS PLAYERS
	BRPVP_mensagemDeKillTxtSend = BRPVP_mensagemDeKillTxt;
	publicVariable "BRPVP_mensagemDeKillTxtSend";

	//DELETA QUADRICICLO SE ELE ESTIVER VAZIO
	_qdcl = player getVariable ["qdcl",objNull];
	if (!isNull _qdcl) then {
		if (count crew _qdcl == 0) then {
			deleteVehicle _qdcl;
		};
	};
	
	//COLOCA EM CHEQUE PROPRIEDADES PERTO
	if (_matador != player) then {
		BRPVP_naPistaAdd = [];
		{
			_qrad = if (_x call BRPVP_isMotorized) then {5} else {15};
			if ([player,_x] call PDTH_distance2Box < _qrad) then {
				BRPVP_naPistaAdd append [_x];
			};
		} forEach BRPVP_myStuff;
		if (count BRPVP_naPistaAdd > 0) then {
			BRPVP_naPistaAdd = [getPlayerUID player,getPosATL player,BRPVP_naPistaAdd];
			publicVariableServer "BRPVP_naPistaAdd";
		};
	};
	
	//FECHA VAULT SE ESTIVER ABERTA
	_pSaved = false;
	_vault = player getVariable ["wh",objNull];
	if (!isNull _vault) then {
		_pSaved = true;
		call BRPVP_vaultRecolhe;
	};

	//CLOSE SELL RECEPTACLE
	_sellR = player getVariable ["sr",objNull];
	if (!isNull _sellR) then {
		if (_pSaved) then {
			false call BRPVP_actionSellClose;
		} else {
			_pSaved = true;
			true call BRPVP_actionSellClose;
		};
	};
	
	//SALVA AMIGOS, ESTATISTICAS ETC DO PLAYER NO BANCO DE DADOS PARA A PROXIMA VIDA
	if (!_pSaved) then {
		BRPVP_salvaPlayer = player call BRPVP_pegaEstadoPlayer;
		publicVariableServer "BRPVP_salvaPlayer";
	};
};
player addEventHandler ["Killed",{
	//FECHA MENUS
	BRPVP_terrenosMapaLigado = false;
	BRPVP_menuExtraLigado = false;
	call BRPVP_atualizaDebug;
	
	//LOG DAMAGE WHEN INCAPACITATED
	diag_log ("[BRPVP REVIVE] BRPVP_fallDamage = " + str BRPVP_fallDamage);
	
	//SHOUT
	playSound3D [BRPVP_missionRoot + "BRP_sons\" + (BRPVP_disabledSounds select (BRPVP_disabledSoundsIdc mod (count BRPVP_disabledSounds))),player,false,getposASL player,0.5,1,0];
	BRPVP_disabledSoundsIdc = BRPVP_disabledSoundsIdc + 1;
	
	if (BRPVP_reviveOn) then {
		diag_log "[BRPVP REVIVE] killed EH - player was disabled in combat!";
		
		player setVariable ["dd",0,true];
		BRPVP_disabledWeapon = currentWeapon player; 
	
		//DISABLED COUNT
		[] spawn {
			BRPVP_disabledBodyDamage = true;
			_step = 0.5/125;
			_init = time;
			_dd = 0;
			["LASTING LIFE: " + str (0.1 * round (((0.5-BRPVP_disabledDamage) * 2000) max 0)) + " %\nPress Space Bar to die.",0] call BRPVP_hint;
			waitUntil {
				_time = time;
				if (_time - _init >= 1) then {
					_init = _time;
					BRPVP_disabledBleed = BRPVP_disabledBleed + _step;
					_ll = str (0.1 * round (((0.5-(BRPVP_disabledDamage + BRPVP_disabledBleed)) * 2000) max 0));
					["LASTING LIFE: " + _ll + " %\nPress Space Bar to die.",0,200,0,"ciclo"] call BRPVP_hint;
				};
				if (BRPVP_disabledDamage + BRPVP_disabledBleed >= 0.5) then {
					player setVariable ["dd",1,true];
				};
				_dd = player getVariable ["dd",0];
				_dd > 0
			};
			["",0,200,0,""] call BRPVP_hint;
			if (_dd == 1) then {
				diag_log ("[BRPVP REVIVE] BRPVP_lastOfensor = " + name BRPVP_lastOfensor);
				BRPVP_lastOfensor call BRPVP_playerKilled;
			};
			setPlayerRespawnTime 0;
		};
	} else {
		diag_log "[BRPVP REVIVE] killed EH - player KILLED (BRPVP revive off)!";
		
		player setVariable ["dd",1,true];
		diag_log ("[BRPVP REVIVE] BRPVP_lastOfensor = " + name BRPVP_lastOfensor);
		BRPVP_lastOfensor call BRPVP_playerKilled;
		setPlayerRespawnTime 0;
	};
}];
player addEventHandler ["AnimDone",{
	_animacao = _this select 1;
	if (BRPVP_todasAnimAndando find _animacao >= 0) then {
		BRPVP_experienciaDeAndar = BRPVP_experienciaDeAndar + 1;
		if (BRPVP_experienciaDeAndar == 45) then {
			[["andou",1]] call BRPVP_mudaExp;
			BRPVP_experienciaDeAndar = 0;
		};
	};
}];
BRPVP_playerHandleDamage = {
	params ["_atacado","_parte","_dano","_ofensor"];
	_dano = _dano * BRPVP_multiplicadorDanoAdmin;
	if (_ofensor isKindof "LandVehicle" || _ofensor isKindof "Air") then {_ofensor = effectiveCommander _ofensor;};
	if (_ofensor isKindOf "CAManBase") then {
		if (_ofensor != _atacado) then {
			if !(_ofensor in BRPVP_meusAmigosObj) then {call BRPVP_ligaModoCombate;};
			if (_parte == "") then {
				_dltDano = _dano - damage _atacado;
				if (player getVariable ["dd",0] <= 0) then {
					_nOfensor = if (isPlayer _ofensor) then {_ofensor getVariable "nm"} else {"Bots"};
					_atacIDC = BRPVP_HDAtacantes find _nOfensor;
					if (_atacIDC == -1) then {
						BRPVP_HDAtacantes append [_nOfensor];
						BRPVP_HDAtacantesDano append [_dltDano];
					} else {
						BRPVP_HDAtacantesDano set [_atacIDC,(BRPVP_HDAtacantesDano select _atacIDC) + _dltDano];
					};
					_dist = round (_atacado distance _ofensor);
					BRPVP_mensagemDeKillArray = [time,_nOfensor,currentWeapon _ofensor,str _dist];
				};
			};
			if (_parte == "head") then {
				_dltDano = _dano - (_atacado getHit _parte);
				if (_dltDano > 0.9) then {
					if (player getVariable ["dd",0] <= 0) then {
						if (isPlayer _ofensor) then {
							[["levou_tiro_cabeca_player",1]] call BRPVP_mudaExp;
							BRPVP_mudaExpOutroPlayer = [_ofensor,[["deu_tiro_cabeca_player",1]]];
							publicVariableServer "BRPVP_mudaExpOutroPlayer";
						} else {
							if (_ofensor isKindOf "Man") then {[["levou_tiro_cabeca_bot",1]] call BRPVP_mudaExp;};
						};
					};
				};
			};
		};
	};
	if (_parte == "") then {
		if (player getVariable ["dd",-1] <= 0) then {
			BRPVP_lastOfensor = _ofensor;
		};
		BRPVP_playerDamaged = true;
		if (BRPVP_disabledBodyDamage) then {
			BRPVP_disabledDamage = _dano - BRPVP_fallDamage;
			diag_log ("[BRPVP HD DISABLED] _dano = " + str _dano + " / BRPVP_fallDamage = " + str BRPVP_fallDamage + " / BRPVP_disabledDamage = " + str BRPVP_disabledDamage + " / BRPVP_disabledBleed = " + str BRPVP_disabledBleed );
		} else {
			//STORE FALL DAMAGE
			BRPVP_fallDamage = _dano;
		};
	};
	
	//ACE COMPATIBILITY
	if (BRPVP_hdehReturnValue) then {_dano};
};
player addEventHandler ["HandleDamage",{
	_this call BRPVP_playerHandleDamage
}];
player addEventHandler ["Fired",{
	BRPVP_shotTime = time;
	if (BRPVP_earPlugs) then {
		0.2 fadeSound (0.08 + random 0.04);
		if (!BRPVP_earPlugsAlivio) then {
			BRPVP_earPlugsAlivio = true;
			_nulo = [] spawn {
				waitUntil {time - BRPVP_shotTime > 4 || !BRPVP_earPlugs};
				if (BRPVP_earPlugs) then {2 fadeSound 0.4;};
				BRPVP_earPlugsAlivio = false;
			};
		};
	};
	call BRPVP_ligaModoCombate;
	_bala = _this select 6;
	if (BRPVP_ehNaoAtira) then {
		deleteVehicle _bala;
	} else {
		if (BRPVP_rastroBalasLigado) then {
			BRPVP_bala = _bala;
			BRPVP_rastroPosicoes = [position _bala];
		};
	};
	if (BRPVP_godMode) then {
		_wpn = currentWeapon player;
		player setAmmo [_wpn,(player ammo _wpn) + 1];
	};
}];
player addEventHandler ["GetInMan",{
	_veiculo = _this select 2;
	if (_veiculo getVariable ["id_bd",-1] >= 0) then {
		if !(_veiculo getVariable ["slv",false]) then {_veiculo setVariable ["slv",true,true];};
	};
	_unid = _this select 0;
	if (isPlayer _unid) then {
		_ocup = _this select 1;
		if (_ocup == "DRIVER") then {
			if (BRPVP_safeZone) then {_veiculo allowDamage false;};
			_nulo = [_veiculo,isEngineOn _veiculo] spawn BRPVP_protejeCarro;
		};
	};
	BRPVP_meuVeiculoNow = [];
	if (_veiculo call BRPVP_checaAcesso) then {
		BRPVP_assignedVehicle = _veiculo;
	} else {
		BRPVP_assignedVehicle = objNull;
	};
	[200,0.125,1,_veiculo,5] call BRPVP_radarAdd;
	["This car have Radar Signal!\n(open your map).",3.5,12] call BRPVP_hint;
}];
BRPVP_fastRopeTeclas = [];
_acoesOk = ["binocular","fire","headlights","holdBreath","lookAround","lookAroundToggle","nightVision","optics","reloadMagazine","zoomCont","zoomIn","zoomOut"];
{BRPVP_fastRopeTeclas append actionKeys _x;} forEach _acoesOk;
BRPVP_giroSuave = {
	params ["_obj","_ang","_tempo"];
	_teta = 0;
	_vel = _ang/_tempo;
	waitUntil {
		_tempoFrame = 1/diag_fps;
		_step = _tempoFrame * _vel;
		_obj setDir (getDir _obj + _step);
		_teta = _teta + _step;
		abs _teta >= abs _ang
	};
};
player addEventHandler ["GetOutMan",{
	_veiculo = _this select 2;
	BRPVP_meuVeiculoNow = getPosATL _veiculo;
	if (_veiculo isKindOf "Helicopter" && typeOf _veiculo != "B_Parachute") then {
		_vH = (position _veiculo) select 2;
		if (_vH > 5) then {
			cutText ["","BLACK FADED"];
			_pPos = getPosATL player;
			player setPosATL (_pPos vectorAdd [0,0,1850]);
			BRPVP_fastRopeHeli = _veiculo;
			BRPVP_fastRopeAcaba = false;
			_nulo = _pPos spawn {
				player setPosATL _this;
				cutText ["","PLAIN"];
				BRPVP_fastRopeRope = ropeCreate [BRPVP_fastRopeHeli,getCenterOfMass BRPVP_fastRopeHeli,player,[0,0,0.25],2.5];
				_frKeysDEH = (findDisplay 46) displayAddEventHandler ["KeyUp",{
					params ["_controle","_key","_keyShift","_keyCtrl","_keyAlt"];
					_casos = [_key];
					if (_keyShift) then {_casos append [905969664 + _key,704643072 + _key];};
					if (_keyCtrl) then {_casos append [486539264 + _key,-1660944384 + _key];};
					if (_keyAlt) then {_casos append [939524096 + _key,-1207959552 + _key];};
					_retorno = if ({_x in BRPVP_fastRopeTeclas} count _casos == 0) then {true} else {false};
					if (_key in [0x10,0x12]&& !_keyCtrl && !_keyAlt) then {
						_retorno = true;
						_giro = if (_key == 0x10) then {-15} else {15};
						if (_keyShift) then {_giro = 2 * _giro;};
						_nulo = [player,_giro,0.65] spawn BRPVP_giroSuave;
					};
					if (_key in [0x11,0x1F] && !_keyCtrl && !_keyAlt && ropeUnwound BRPVP_fastRopeRope) then {
						_retorno = true;
						_frTamAdic = 2;
						if (_keyShift) then {_frTamAdic = 5;};
						if (_key == 0x11) then {_frTamAdic = -_frTamAdic;};
						BRPVP_fastRopeEnrola = [BRPVP_fastRopeRope,_frTamAdic];
						publicVariable "BRPVP_fastRopeEnrola";
						ropeUnwind [BRPVP_fastRopeRope,5,(((ropeLength BRPVP_fastRopeRope) + _frTamAdic) max 2.5) min 50];
					};
					if (_key == 0x39 && !_keyShift && !_keyCtrl && !_keyAlt) then {
						_retorno = true;
						ropeDestroy BRPVP_fastRopeRope;
						BRPVP_fastRopeAcaba = true;
					};
					if (_key == 0xD3 && !_keyShift && !_keyCtrl && !_keyAlt) then {
						_retorno = true;
						if (ropeLength BRPVP_fastRopeRope < 3.5) then {
							ropeDestroy BRPVP_fastRopeRope;
							player moveInCargo BRPVP_fastRopeHeli;
							BRPVP_fastRopeAcaba = true;
						};
					};
					_retorno
				}];
				waitUntil {(getPos player) select 2 < 1 || !alive player || !alive BRPVP_fastRopeHeli || player != vehicle player || BRPVP_fastRopeAcaba};
				(findDisplay 46) displayRemoveEventHandler ["KeyUp",_frKeysDEH];
				ropeDestroy BRPVP_fastRopeRope;
				BRPVP_fastRopeAcaba = true;
			};
		};
	};
	[200,0.125,1,_veiculo,5] call BRPVP_radarRemove;
}];
player addEventHandler ["Put",{
	_cont = _this select 1;
	if (_cont getVariable ["id_bd",-1] >= 0) then {
		if !(_cont getVariable ["slv",false]) then {_cont setVariable ["slv",true,true];};
	};
}];
player addEventHandler ["Take",{
	_cont = _this select 1;
	_item = _this select 2;
	if (_item in ["FlareWhite_F","FlareYellow_F"]) then {
		_addMny = 1000;
		if (_item == "FlareYellow_F") then {_addMny = 2000;};
		player setVariable ["mny",(player getVariable "mny") + _addMny,true];
		playSound "negocio";
		_item spawn {player removeMagazines _this;};
		call BRPVP_atualizaDebug;
	};
	if (_cont getVariable ["id_bd",-1] >= 0) then {
		if !(_cont getVariable ["slv",false]) then {_cont setVariable ["slv",true,true];};
	};
	_wh_usos = _cont getVariable ["ml_takes",-1];
	if (_wh_usos >= 0) then {_cont setVariable ["ml_takes",_wh_usos + 1,true];};
}];
BRPVP_hasFlare = false;
player addEventHandler ["InventoryOpened",{
	_c = _this select 1;
	_retorno = !(_c call BRPVP_checaAcesso);
	if (_retorno) then {
		["You don't have access!",0] call BRPVP_hint;
	} else {
		_mags = (getMagazineCargo _c) select 0;
		BRPVP_hasFlare = "FlareWhite_F" in _mags || "FlareYellow_F" in _mags;
	};
	_retorno
}];
player addEventHandler ["InventoryClosed",{
	if (BRPVP_hasFlare) then {
		BRPVP_hasFlare = false;
		["Get the flares for *instant money* or\ntransfer and sell then on the Collectors!",6,15,989] call BRPVP_hint;
	};
}];
player addEventHandler ["SeatSwitchedMan",{
	_unid = _this select 0;
	if (isPlayer _unid) then {
		_ocup = (assignedVehicleRole _unid) select 0;
		if (_ocup == "DRIVER") then {
			_veiculo = _this select 2;
			if (BRPVP_safeZone) then {_veiculo allowDamage false;};
			_nulo = [_veiculo,isEngineOn _veiculo] spawn BRPVP_protejeCarro;
		};
	};
}];

diag_log "[BRPVP FILE] playerEH.sqf END REACHED";