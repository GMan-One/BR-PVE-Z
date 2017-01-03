//RESETA COMANDO NO BANCO DE DADOS
_resultado = "extDB3" callExtension format ["0:%1:setDbCommand:%2",BRPVP_protocolo,"nada"];

//LOOP DO SERVIDOR
[] spawn {
	private ["_agora"];
	
	//DEFINE VARIAVEIS
	_contaA = 0;
	_contaB = 300;
	_contaC = 0;
	_contaD = 0;
	_contaE = 0;
	_contaF = 0;
	_contaG = 0;

	_loopsA = 30;
	_loopsB = 300;
	_loopsC = BRPVP_cycloDeSalvamentoBd;
	_loopsD = 10;
	_loopsE = 30;
	_loopsF = 15;
	_loopsG = (ceil (16.5/sqrt((BRPVP_mapaDimensoes select 0) * (BRPVP_mapaDimensoes select 1)/67230000))) * 60;

	_inicio = time;
	_bravoPointOn = BRPVP_mapaRodando select 11 select 0;
	_bravoPointQt = BRPVP_mapaRodando select 11 select 3;
	_siegeOn =  BRPVP_mapaRodando select 19 select 0;
	_siegeQt =  BRPVP_mapaRodando select 19 select 1;
	_convoyOn = BRPVP_mapaRodando select 20 select 0;
	_convoyQt = BRPVP_mapaRodando select 20 select 1;
	_pcrashIni = BRPVP_serverTime;
	_pcrashQt = BRPVP_mapaRodando select 21 select 2;
	_pcrashTm = BRPVP_mapaRodando select 21 select 3;
	_end = false;
	
	_BRPVP_doRestartMsg = {
		_minLeft = 60 - _this;
		if (_minLeft in BRPVP_restartWarnings) then {
			BRPVP_restartWarnings = BRPVP_restartWarnings - [_minLeft];
			BRPVP_hintEmMassa = [format["The server will restart in %1 minutes!",_minLeft],3.5,20];
			publicVariable "BRPVP_hintEmMassa";
		};
	};
	
	waitUntil {
		_agora = time;
		if (_agora - _inicio >= 1) then {
			_inicio = _agora;

			//START KONVOY MISSION
			if (_contaG == _loopsG) then {
				_contaG = 0;
				if (_convoyOn) then {
					_kvyDelIdc = [];
					{
						_compositionsOk = {alive _x && {canMove _x}} count (_x select 0);
						if (_compositionsOk == 0) then {
							_kvyDelIdc pushBack _forEachIndex;
						};
					} forEach BRPVP_konvoyCompositions;
					_kvyDelIdc sort false;
					{BRPVP_konvoyCompositions deleteAt _x;} forEach _kvyDelIdc;
					if (count BRPVP_konvoyCompositions < _convoyQt) then {
						call BRPVP_convoyMission;
					};
				};
			};
			
			//DELETA QUADRICICLOS EXPIRADOS
			if (_contaA == _loopsA) then {
				_contaA = 0;
				
				//DELETA QUADRICICLOS ESPIRADOS
				_bikes = BRPVP_centroMapa nearEntities [BRPVP_veiculoTemporarioNascimento,20000];
				{
					_bike = _x;
					_tmp = _bike getVariable ["tmp",-1];
					if (_tmp != -1) then {
						if (BRPVP_serverTime - _tmp > BRPVP_tempoDeVeiculoTemporarioNascimento && {count crew _bike == 0}) then {
							_own = _bike getVariable "own";
							{
								if (_x getVariable ["sok",false] && {_x getVariable "id_bd" == _own}) exitWith {
									BRPVP_hintEmMassa = ["Your quadricicle expired it's life time (deleted!).",0];
									(owner _x) publicVariableClient "BRPVP_hintEmMassa";
								};
							} forEach allPlayers;
							deleteVehicle _bike;
						};
					};
				} forEach _bikes;

				//END BRAVO POINT MISSION
				_buFim = [];
				{
					_bu = _x;
					_vivoQt = {alive _x} count (_bu getVariable ["msbs",[]]);
					if (_vivoQt <= 2) then {
						_buFim pushBack _bu;
						_bu allowDamage true;
					};
				} forEach BRPVP_missPrediosEm;
				if (count _buFim > 0) then {
					BRPVP_missPrediosEm = BRPVP_missPrediosEm - _buFim;
					publicVariable "BRPVP_missPrediosEm";
				};
				
				//SIEGE MISSION END
				_terminatedSiege = false;
				{
					if (_x == 2) then {
						_idc = _forEachIndex;
						_ais = BRPVP_closedCityAI select _idc;
						_aisOk = {alive _x} count _ais;
						if (_aisOk <= 3) then {
							BRPVP_closedCityRunning set [_forEachIndex,3];
							_lName = BRPVP_locaisImportantes select _idc select 2;
							_terminatedSiege = true;
							BRPVP_hintEmMassa = ["The " + _lName + " siege has ended!",5,15,0,"batida"];
							publicVariable "BRPVP_hintEmMassa";
							{
								deleteVehicle _x;
								sleep 0.001;
							} forEach (BRPVP_closedCityWalls select _idc);
							{
								if !(typeOf _x in BRPVP_towas) then {
									deleteVehicle _x;
									sleep 0.001;
								};
							} forEach (BRPVP_closedCityObjs select _idc);
						};
					};
				} forEach BRPVP_closedCityRunning;
				if (_terminatedSiege) then {
					publicVariable "BRPVP_closedCityRunning";
					publicVariable "BRPVP_closedCityObjs";
					publicVariable "BRPVP_closedCityWalls";
				};
				
				//END CIVIL PLANE CRASH MISSION
				_changed = false;
				{
					if (!isNull _x) then {
						_bm = _x getVariable "bm";
						_sc = _bm getVariable "sc";
						if (_sc isEqualTo objNull) then {
							BRPVP_corruptMissIcon set [_forEachIndex,objNull];
							{deleteVehicle _x;} forEach (BRPVP_corruptMissObjs select _forEachIndex);
							_changed = true;
						};
					};
				} forEach BRPVP_corruptMissIcon;
				if (_changed) then {
					publicVariable "BRPVP_corruptMissIcon";
				};
			};
					
			//CRIA MISSAO
			if (_contaB == _loopsB) then {
				_contaB = 0;
				_hasMissInit = false;
				
				//BRAVO POINT
				if (_bravoPointOn) then {
					_qtMiss = count BRPVP_missPrediosEm;
					if (_qtMiss == 0) then {
						[] spawn BRPVP_criaMissaoDePredio;
						_hasMissInit = true;
					} else {
						if (_qtMiss < _bravoPointQt) then {
							if (random 1 < 0.5) then {
								[] spawn BRPVP_criaMissaoDePredio;
								_hasMissInit = true;
							};
						};
					};
				};

				//SIEGE MISSION START
				if (!_hasMissInit && _siegeOn) then {
					if (count allPlayers > 0) then {
						_newestA = + BRPVP_closedCityTime;
						_newestA sort false;
						_lastTime = _newestA select 0;
						_siegeQtNow = {_x == 1 || _x == 2} count BRPVP_closedCityRunning;
						if (time - _lastTime > 600 && _siegeQtNow < _siegeQt) then {
							[] spawn BRPVP_besiegedMission;
						};
					};
				};
			};
			
			//CIVIL PLANE CRASH MISSION START
			if (_pcrashQt > 0) then {
				_tm = BRPVP_serverTime - _pcrashIni;
				if (_tm >= _pcrashTm * 60) then {
					_pcrashIni = BRPVP_serverTime;
					_pcrashQt = _pcrashQt - 1;
					[] spawn BRPVP_corruptMissSpawn;
				};
			};
			
			//MASS SAVE
			if (_contaC == _loopsC) then {
				_contaC = 0;
				call BRPVP_salvaEmMassa;
			};

			//TERMINATE SERVER WITH BAT FILE
			if (_contaD == _loopsD) then {
				_contaD = 0;
				_salvar = (call compile ("extDB3" callExtension format ["0:%1:getDbCommand",BRPVP_protocolo])) select 1 select 0 select 0;
				if (_salvar == "desligar") then {
					BRPVP_terminaMissao = true;
					publicVariable "BRPVP_terminaMissao";
					sleep 1;
					call BRPVP_salvaEmMassaVeiculos;
					sleep 4;
					"buttas555" serverCommand "#shutdown";
					_end = true;
				};
				
				//ATUALIZA FPS DO SERVIDOR NO CLIENTE
				BRPVP_servidorQPS = round diag_fps;
				diag_log ("[BRPVP] FPS = " + str BRPVP_servidorQPS + ".");
				publicVariable "BRPVP_servidorQPS";
			};

			//SERVER RESTART ON RESTART TIME
			if (_contaE == _loopsE) then {
				_contaE = 0;
				_localTime = (call compile ("extDB3" callExtension "9:LOCAL_TIME")) select 1;
				_hour = _localTime select 3;
				_lastHour = false;
				{
					if (_x - _hour == 1 || (_x == 0 && _hour == 23)) exitWith {
						_lastHour = true;
					};
				} forEach BRPVP_restartTimes;
				if (_lastHour) then {
					_min = _localTime select 4;
					if (_min >= 59) then {
						_loopsE = 1;
						_secs = _localTime select 5;
						if (_secs >= 50) then {
							if (!BRPVP_terminaMissao) then {
								BRPVP_terminaMissao = true;
								publicVariable "BRPVP_terminaMissao";
								sleep 1;
								call BRPVP_salvaEmMassaVeiculos;
								sleep 4;
								"buttas555" serverCommand "#shutdown";
								_end = true;
							};
						} else {
							_min call _BRPVP_doRestartMsg;
						};
					} else {
						if (_min >= 35) then {
							_loopsE = 10;
							_min call _BRPVP_doRestartMsg;
						};
					};
				};
			};

			//DEL REVIVE CORPSES
			if (_contaF == _loopsF) then {
				_contaF = 0;
				_iDel = [];
				{
					if (time - (_x getVariable ["hrv",0]) >= 180) then {
						_iDel pushBack _forEachIndex;
					};
				} forEach BRPVP_corpsesToDel;
				_iDel sort false;
				{
					_body = BRPVP_corpsesToDel deleteAt _x;
					deleteVehicle _body;
				} forEach _iDel;
			};
			
			_napistaDel = [];
			{
				_naPista = _x;
				_iniNP = _naPista select 4;
				_naPistaIdc = _forEachIndex;
				_pos = _naPista select 1;
				_mans = _pos nearObjects ["CaManBase",2];
				_fim = false;
				{
					if (isPlayer _x && alive _x) exitWith {
						_naPista pushBack _x;
						_naPista call BRPVP_iniciaSetOwner;
						_napistaDel pushBack _naPistaIdc;
						_fim = true;
					};
				} forEach _mans;
				if (!_fim) then {
					if (time - _iniNP > 90) then {
						_napistaDel pushBack _naPistaIdc;
						deleteVehicle (_naPista select 3);
					};
				};
			} forEach BRPVP_naPista;
			_napistaDel sort false;
			{BRPVP_naPista deleteAt _x;} forEach _napistaDel;
			
			//ATUALIZA CONTAGEM
			_contaA = _contaA + 1;
			_contaB = _contaB + 1;
			_contaC = _contaC + 1;
			_contaD = _contaD + 1;
			_contaE = _contaE + 1;
			_contaF = _contaF + 1;
			_contaG = _contaG + 1;
		};
		_end
	};
};