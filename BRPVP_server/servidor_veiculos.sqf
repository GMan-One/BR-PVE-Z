//AVISA SOBRE EVOLUCAO DA COLOCACAO DE VEICULOS E CONSTRUCOES NO MAPA (PUXADO DO BD)
BRPVP_serverTrabalhando = ["SPAWNING OBJECTS!",BRPVP_ant + "<t size='2'>OBJECTS:</tr><br /><t size='3'>0</t>"];
PublicVariable "BRPVP_serverTrabalhando";

//VARIAVEIS INICIAIS
_ultimoId = -1;
_resultado = "";
_contaVeiculos = 0;
BRPVP_carrosObjetos = [];
BRPVP_helisObjetos = [];

//VEICULOS DO BANCO DA DADOS PARA O JOGO
while {_resultado != "[1,[]]"} do {
	private ["_veiculo","_isSO"];
	//CONSULTA PARA PEGAR VEICULO
	_key = format ["0:%1:getObjects:%2",BRPVP_protocolo,_ultimoId];
	_resultado = "extDB3" callExtension _key;
	
	//BOTA VEICULO NO JOGO
	if (_resultado != "[1,[]]") then {
		//COMPILA RESULTADO
		_resultadoCompilado = call compile _resultado;
		_resultadoCompilado = _resultadoCompilado select 1;
		_idcMax = count _resultadoCompilado - 1;

		for "_i" from 0 to _idcMax do {
			//DADOS VEICULO
			_veiculoId = _resultadoCompilado select _i select 0;
			_carga = _resultadoCompilado select _i select 2;
			_posicao = _resultadoCompilado select _i select 3;
			_modelo = _resultadoCompilado select _i select 4;
			_owner = _resultadoCompilado select _i select 5;
			_comp = _resultadoCompilado select _i select 6;
			_amigos = _resultadoCompilado select _i select 7;
			_mapa = _resultadoCompilado select _i select 8;
			_exec = _resultadoCompilado select _i select 9;
			
			//ADICIONA ENTRADA DE LOG
			diag_log "-----------------------------------------------------------------------";
			diag_log ("---- Model: " + _modelo);
			diag_log ("---- Id: " + str _veiculoId);
			diag_log ("---- Position: " + str _posicao);
			diag_log ("---- Cargo: " + str _carga);
			diag_log ("---- Owner: " + str _owner);
			diag_log ("---- Comp: " + str _comp);
			diag_log ("---- Friends: " + str _amigos);
			diag_log ("---- Map House: " + str _mapa);
			diag_log ("---- Exec: " + str _exec);
			diag_log "-----------------------------------------------------------------------";
			
			//ID_BD DO VEICULO
			_ultimoId = _veiculoId;
			
			//POSICAO
			_vPWD = _posicao select 0;
			_vVDU = _posicao select 1;

			_isMotorized = _modelo call BRPVP_isMotorized;
			if (_mapa) then {
				//ACHA VEICULO NO MAPA
				_veiculo = nearestObject [ASLToATL _vPWD,_modelo];
				if (!isNull _veiculo) then {
					_veiculo setVariable ["mapa",true,true];
				} else {
					diag_log ("[BRPVP: CAN'T FIND MAP OBJECT] id = " + str _veiculoId + ".");
				};
			} else {
				//CRIA E POSICIONA VEICULO
				if (_isMotorized) then {
					_veiculo = createVehicle [_modelo,_vPWD,[],0,"CAN_COLLIDE"];
				} else {
					if (_modelo in BRPVP_buildingHaveDoorList) then {
						_veiculo = createVehicle [_modelo,[0,0,0],[],0,"CAN_COLLIDE"];
						_state = if (_modelo in BRPVP_buildingHaveDoorListReverseDoor) then {1} else {0};
						if (_veiculo call BRPVP_isBuilding) then {
							{
								if (_veiculo animationPhase _x != _state) then {
									_veiculo animate [_x,_state];
								};
							} forEach animationNames _veiculo;
						};
					} else {
						_model = getText (configFile >> "CfgVehicles" >> _modelo >> "model") splitString "";
						if (_model select 0 == "\") then {_model deleteAt 0;};
						_qc = (count _model) - 1;
						_finalChars = (_model select (_qc -3)) + (_model select (_qc -2)) + (_model select (_qc -1)) + (_model select _qc);
						if !(_finalChars in [".p3d",".P3D"]) then {
							_model append [".","p","3","d"];
						};
						_model = _model joinString "";
						_veiculo = createSimpleObject [_model,AGLToASL [0,0,0]];
						[_veiculo,"cnm",_modelo] call BRPVP_setVariable;
					};
				};
				_veiculo setPosWorld _vPWD;
				_veiculo setVectorDirAndUp _vVDU;
			};
			if (!isNull _veiculo) then {
				_contaVeiculos = _contaVeiculos + 1;
				_isSO = _veiculo call BRPVP_isSimpleObject;
				if (_isSO) then {
					[_veiculo,"id_bd",_veiculoId] call BRPVP_setVariable;
					[_veiculo,"own",_owner] call BRPVP_setVariable;
				} else {
					_veiculo setVariable ["id_bd",_veiculoId,true];
					_veiculo setVariable ["own",_owner,true];
				};
				if (_owner != -1) then {
					if (!_isSO) then {
						_veiculo setVariable ["stp",_comp,true];
						_veiculo setVariable ["amg",_amigos,true];
					};
				};

				//ADICIONA VEICULO NO ARRAY DE CARROS CASO SEJA CARRO
				if (_veiculo isKindOf "LandVehicle") then {
					BRPVP_carrosObjetos pushBack _veiculo;
				};
				
				//ADICIONA VEICULO NO ARRAY DE HELIS CASO SEJA HELI
				if (_veiculo isKindOf "Air") then {
					BRPVP_helisObjetos pushBack _veiculo;
				};
				
				//ADICIONA AS CASAS
				if (!_isMotorized) then {
					BRPVP_ownedHouses pushBack _veiculo;
				};
				
				//ADICIONA CARGA DO CARRO
				clearWeaponCargoGlobal _veiculo;
				clearMagazineCargoGlobal _veiculo;
				clearItemCargoGlobal _veiculo;
				clearBackpackCargoGlobal _veiculo;
				{_veiculo addWeaponCargoGlobal [_x,(_carga select 0 select 1 select _forEachIndex)];} forEach (_carga select 0 select 0);
				
				//TEMPORARIO
				_c = _carga select 1;
				_antigo = false;
				if (count _c == 2) then {
					if (count (_c select 1) == 0) then {
						_antigo = true;
					} else {
						if (typeName (_c select 1 select 0) == "SCALAR") then {
							_antigo = true;
						};
					};
				};
				if (!_antigo) then {
					{_veiculo addMagazineAmmoCargo [_x select 0,1,_x select 1];} forEach (_carga select 1);
				} else {
					{_veiculo addMagazineCargoGlobal [_x,(_carga select 1 select 1 select _forEachIndex)];} forEach (_carga select 1 select 0);
				};
				
				{_veiculo addItemCargoGlobal [_x,(_carga select 2 select 1 select _forEachIndex)];} forEach (_carga select 2 select 0);
				{_veiculo addBackpackCargoGlobal [_x,(_carga select 3 select 1 select _forEachIndex)];} forEach (_carga select 3 select 0);

				if (!_isSO) then {
					_veiculo call BRPVP_veiculoEhReset;
				};

				//AVISA SOBRE EVOLUCAO DA COLOCACAO DE VEICULOS E CONSTRUCOES NO MAPA (PUXADO DO BD)
				if (_contaVeiculos mod 15 == 0) then {
					BRPVP_serverTrabalhando = ["",BRPVP_ant + "<t size='2'>OBJECTS:</tr><br/><t size='3'>" + str _contaVeiculos + "</t>"];
					PublicVariable "BRPVP_serverTrabalhando";
				};
				
				//EXEC OBJECT CODE
				if (_exec != "") then {
					_veiculo call compile _exec;
					diag_log ("EXEC: " + _exec);
				};
			};
		};
	};
};
publicVariable "BRPVP_ownedHouses";

//AVISA SOBRE EVOLUCAO DA COLOCACAO DE VEICULOS E CONSTRUCOES NO MAPA (PUXADO DO BD)
BRPVP_serverTrabalhando = ["",BRPVP_ant + "<t size='2'>OBJECTS:</tr><br/><t size='3'>" + str _contaVeiculos + "</t>"];
PublicVariable "BRPVP_serverTrabalhando";
BRPVP_ant = (BRPVP_serverTrabalhando select 1) + "<br/>";