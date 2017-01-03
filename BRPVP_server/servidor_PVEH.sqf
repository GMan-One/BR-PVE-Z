BRPVP_zombieGroups = [];
"BRPVP_spawnZombiesServer" addPublicVariableEventHandler {
	(_this select 1) params ["_player","_posSpawn","_amount"];
	_countZombiesGroups = count BRPVP_zombieGroups;
	{
		diag_log (str _x + " | " + str units _x);
	} forEach BRPVP_zombieGroups;
	if (_countZombiesGroups >= BRPVP_zombiesMaxGroups) then {
		_excess = _countZombiesGroups + 1 - 20;
		_index = 0;
		_BRPVP_zombieGroups = BRPVP_zombieGroups apply {
			_groupUnits = _x;
			_countPlayersNear = 0;
			{
				_unit = _x;
				{
					_distanceSqr = _unit distanceSqr _x;
					if (_distanceSqr < 90000) then {
						if (_distanceSqr < 2500) then {
							_countPlayersNear = _countPlayersNear + 3;
						} else {
							if (_distanceSqr < 22500) then {
								_countPlayersNear = _countPlayersNear + 2;
							} else {
								_countPlayersNear = _countPlayersNear + 1;
							};
						};
					};
				} forEach allPlayers;
			} forEach _groupUnits;
			_index = _index + 1;
			[_countPlayersNear,_index - 1]
		};
		_BRPVP_zombieGroups sort true;
		for "_i" from 0 to (_excess - 1) do {
			_index = _BRPVP_zombieGroups select _i select 1;
			_units = BRPVP_zombieGroups select _index;
			{deleteVehicle _x;} forEach _units;
			BRPVP_zombieGroups deleteAt _index;
		};
	};
	_zombieGroup = createGroup INDEPENDENT;
	BRPVP_zombieGroups pushBack _zombieGroup;
	for "_i" from 1 to _amount do {
		_zombieClass = BRPVP_ryanZombiesClasses call BIS_fnc_selectRandom;
		_zombie = _zombieGroup createUnit [_zombieClass,_posSpawn,[],5,"NONE"];
		BRPVP_switchMoveRem = [_zombie,"AmovPercMstpSnonWnonDnon_SaluteOut"];
		publicVariable "BRPVP_switchMoveRem";
		_zombie addEventHandler ["killed",{_this call BRPVP_botDaExp;}];
	};
	//_zombieGroup reveal [_player,4];
};
"BRPVP_saveLightStateDb" addPublicVariableEventHandler {
	(_this select 1) params ["_lamp","_state"];
	_exec = if (_state) then {"_this setDamage 0;"} else {"_this setDamage 0.95;"};
	_lamp call compile _exec;
	_key = format ["1:%1:saveVehicleExec:%2:%3",BRPVP_protocolo,_exec,_lamp getVariable "id_bd"];
	_resultado = "extDB3" callExtension _key;
	diag_log "---------------------------------------------------------";
	diag_log ("-- LIGHT CHANGED STATE TO: " + _exec );
	diag_log ("-- _resultado: " + str _resultado);
	diag_log "---------------------------------------------------------";
};
"BRPVP_iAskForAllInitialVars" addPublicVariableEventHandler {
	_player = _this select 1;
	(owner _player) publicVariableClient "BRPVP_carrosObjetos";
	(owner _player) publicVariableClient "BRPVP_helisObjetos";
};
"BRPVP_setVariableSV" addPublicVariableEventHandler {
	(_this select 1) params ["_o","_n","_v"];
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
	BRPVP_variablesObjectsAdd = [_o,_n,_v];
	publicVariable "BRPVP_variablesObjectsAdd";
	diag_log ("[OBJ VARIABLE RECEIVED FROM 1 CLIENT, SETED ON SERVER AND RESENT TO ALL CLIENTS] " + str [_o,_n,_v]);
};
"BRPVP_setWeatherServer" addPublicVariableEventHandler {
	BRPVP_hintemMassa = ["Weather changed by admin.\nSyncing...",0];
	publicVariable "BRPVP_hintemMassa";

	0 setOvercast 0;
	0 setRain 0;
	setWind [0,0,true];
	0 setGusts 0;
	forceWeatherChange;

	0 setOvercast (_this select 1 select 0 select 0);
	0 setRain (_this select 1 select 1 select 0);
	_wVel = _this select 1 select 1 select 1 select 0;
	_wDir = _this select 1 select 1 select 1 select 1;
	setWind [_wVel * sin _wDir,_wVel * cos _wDir,true];
	0 setGusts (_this select 1 select 0 select 1);
	forceWeatherChange;
};
"BRPVP_setTimeMultiplierSV" addPublicVariableEventHandler {
	setTimeMultiplier (_this select 1);
	BRPVP_hintEmMassa = ["Time multiplier set to " + str (_this select 1) + ".",3.5,12,768];
	publicVariable "BRPVP_hintEmMassa";
};
"BRPVP_setDateSV" addPublicVariableEventHandler {
	setDate (_this select 1);
	BRPVP_hintEmMassa = ["Day time set to " + str (_this select 1 select 3) + ":00 by an admin.",0];
	publicVariable "BRPVP_hintEmMassa";
};
"BRPVP_runCorruptMissSpawn" addPublicVariableEventHandler {
	_pcrashQt = _pcrashQt - 1;
	(getPosATL (_this select 1)) spawn BRPVP_corruptMissSpawn;
	BRPVP_hintEmMassa = ["A civil plane crash started.\nIt take some time for it appears on the map."];
	(owner (_this select 1)) publicVariableClient "BRPVP_hintEmMassa";
};
"BRPVP_mudouConfiancaEmVoceSV" addPublicVariableEventHandler {
	(_this select 1) params ["_pToNotify","_pAction","_action","_amg"];
	_pAction setVariable ["amg",_amg,true];
	if (!isNull _pToNotify) then {
		if !(local _pToNotify) then {
			BRPVP_mudouConfiancaEmVoce = [_pAction,_action];
			(owner _pToNotify) publicVariableClient "BRPVP_mudouConfiancaEmVoce";
		};
	};
	_id_bd = _pAction getVariable ["id_bd",-1];
	if (_id_bd != -1) then {
		_key = format ["1:%1:savePlayerAmg:%2:%3",BRPVP_protocolo,_pAction getVariable ["amg",[]],_id_bd];
		_resultado = "extDB3" callExtension _key;
		diag_log "----------------------------------------------------------------------------------";
		diag_log ("[BRPVP] UPDATED PLAYER FRIENDS: _key = " + str _key + ".");
		diag_log ("[BRPVP] UPDATED PLAYER FRIENDS: _resultado = " + str _resultado + ".");
		diag_log "----------------------------------------------------------------------------------";
	};
};
"BRPVP_convoyRun" addPublicVariableEventHandler {
	call BRPVP_convoyMission;
	BRPVP_hintEmMassa = ["Convoy Mission Started!",4,15,167];
	(owner (_this select 1)) publicVariableClient "BRPVP_hintEmMassa";
};
"BRPVP_giveMoneySV" addPublicVariableEventHandler {
	(_this select 1) params ["_unit","_money"];
	BRPVP_giveMoney = _money;
	(owner _unit) publicVariableClient "BRPVP_giveMoney";
};
"BRPVP_hideObjectSv" addPublicVariableEventHandler {
	(_this select 1) params ["_unit","_state"];
	_unit hideObjectGlobal _state;
};
"BRPVP_switchMoveSv" addPublicVariableEventhandler {
	BRPVP_switchMoveCli = _this select 1;
	publicVariable "BRPVP_switchMoveCli";
	
};
"BRPVP_corpseToDelAdd" addPublicVariableEventHandler {
	_corpse = _this select 1;
	_corpse setVariable ["hrv",time,false];
	BRPVP_corpsesToDel pushBack _corpse;
	_corpse setPos [-10000,-10000,0];
};
"BRPVP_bravoRun" addPublicVariableEventHandler {
	_ply = _this select 1;
	if (BRPVP_criaMissaoDePredioEspera == BRPVP_criaMissaoDePredioIdc) then {
		[] spawn BRPVP_criaMissaoDePredio;
		BRPVP_hintEmMassa = ["If there is a free Bravo Building, a new mission will start in 30 seconds.",6.5,15,167];
	} else {
		BRPVP_hintEmMassa = ["A Bravo Mission is already stanting. Please wait.",6,15,167];
	};
	(owner _ply) publicVariableClient "BRPVP_hintEmMassa";
};
"BRPVP_siegeRun" addPublicVariableEventHandler {
	_canStart = ({_x == 1} count BRPVP_closedCityRunning) == 0;
	if (_canStart) then {
		BRPVP_hintEmMassa = ["If there is a elegible city\na Siege Mission wil start in some seconds.",6,15,167];
		(owner (_this select 1)) publicVariableClient "BRPVP_hintEmMassa";
		[] spawn BRPVP_besiegedMission;
	} else {
		BRPVP_hintEmMassa = ["A Siege Mission is already starting, you need to wait.",5,15,167];
		(owner (_this select 1)) publicVariableClient "BRPVP_hintEmMassa";
	};
};
"BRPVP_moveInServer" addPublicVariableEventHandler {
	BRPVP_moveInClient = _this select 1;
	(owner (_this select 1 select 0)) publicVariableClient "BRPVP_moveInClient";
};
"BRPVP_mapHouseRemoveDb" addPublicVariableEventHandler {
	(_this select 1) call BRPVP_veiculoMorreu;
	BRPVP_ownedHouses = BRPVP_ownedHouses - [_this select 1];
};
"BRPVP_avisaExplosao" addPublicVariableEventHandler {
	(_this select 1) spawn {
		params ["_obj","_pAvisa"];
		BRPVP_remoteRemoveMyStuff = _obj;
		(owner _obj) publicVariableClient "BRPVP_remoteRemoveMyStuff";
		if (_obj call BRPVP_IsMotorized) then {
			BRPVP_tocaSom = [_obj,"destroy",0.5];
			publicVariable "BRPVP_tocaSom";
			BRPVP_hintEmMassa = ["Run!",0];
			{
				(owner _x) publicVariableClient "BRPVP_hintEmMassa";
			} forEach _pAvisa;
			for "_s" from 0 to 2 do {
				BRPVP_tocaSom = [_obj,"destroy",0.2 + 0.3*_s/2];
				publicVariable "BRPVP_tocaSom";
				sleep 2;
			};
			sleep 1;
			_obj setDamage 1;
			_obj setVariable ["bdc",true,true];
		} else {
			if (typeOf _obj in BRPVP_buildingHaveDoorList) then {
				BRPVP_hintEmMassa = ["Run!",0];
				{
					(owner _x) publicVariableClient "BRPVP_hintEmMassa";
				} forEach _pAvisa;
				for "_s" from 0 to 2 do {
					BRPVP_tocaSom = [_obj,"destroy",0.2 + 0.3*_s/2];
					publicVariable "BRPVP_tocaSom";
					sleep 2;
				};
				sleep 1;
				_pw = getPosWorld _obj;
				_obj setDamage 1;
				sleep 2;
				_ruins = nearestObject ASLToAGL _pw;
				_ruins setVariable ["bdc",true,true];
			} else {
				_obj call BRPVP_veiculoMorreu;
				deleteVehicle _obj;
			};
		};
	};
};
"BRPVP_desviraVeiculo" addPublicVariableEventHandler {
	(_this select 1) params ["_car","_alt","_gSize"];
	_hP = (getPosATL _car) vectorAdd [0,0,_alt];
	BRPVP_ganchoDesviraAdd = [_hP,_gSize];
	publicVariable "BRPVP_ganchoDesviraAdd";
	_gancho = createVehicle ["B_static_AA_F",_hP,[],0,"CAN_COLLIDE"];
	_gancho enableSimulation false;
	hideObjectGlobal _gancho;
	_car setOwner 0;
	_offSets = [
		[0.3,0,0.5],
		[-0.3,0,0.5],
		[0,0.3,0.5],
		[0,-0.3,0.5]
	];
	_offSet = _offSets call BIS_fnc_selectRandom;
	_cP = (getCenterOfMass _car) vectorAdd _offset;
	_ropus = ropeCreate [_gancho,[0,0,0],_car,_cP,((_gancho modelToWorld [0,0,0]) distance (_car modelToWorld _cP)) + 0.5];
	_ropus allowDamage false;
	[_car,_ropus,_gancho,_hP,_gSize,_alt] spawn {
		params ["_car","_ropus","_gancho","_hP","_gSize","_alt"];
		sleep 1;

		BRPVP_rapelRopeUnwindPV = [_ropus,1,-(_alt * 0.8 + 0.5),true];
		publicVariable "BRPVP_rapelRopeUnwindPV";
		ropeUnwind BRPVP_rapelRopeUnwindPV;
		waitUntil {ropeUnwound _ropus};

		_ini = time;
		waitUntil {
			_vu = vectorUp _car;
			_ang = acos (_vu vectorCos [0,0,1]);
			_ang < 30 || time - _ini > 5
		};
		
		BRPVP_rapelRopeUnwindPV = [_ropus,1,_alt * 0.8 + 0.5,true];
		publicVariable "BRPVP_rapelRopeUnwindPV";
		ropeUnwind BRPVP_rapelRopeUnwindPV;
		waitUntil {ropeUnwound _ropus};

		_car ropeDetach _ropus;
		sleep 1;
		ropeDestroy _ropus;
		deleteVehicle _gancho;
		BRPVP_ganchoDesviraRemove = [_hP,_gSize];
		publicVariable "BRPVP_ganchoDesviraRemove";
	};
};
"BRPVP_naPistaAdd" addPublicVariableEventHandler {
	_pos = _this select 1 select 1;
	_seta = createVehicle ["Sign_Arrow_Large_Blue_F",_pos,[],0,"CAN_COLLIDE"];
	BRPVP_naPista pushBack ((_this select 1) + [_seta,time]);
};
"BRPVP_rapelRopeUnwindPV" addPublicVariableEventHandler {
	if (!isNull (_this select 1 select 0)) then {
		ropeUnwind (_this select 1);
	};
};
"BRPVP_mudaDonoPropriedadeSV" addPublicVariableEventHandler {
	(_this select 1) params ["_props","_novoDono"];
	BRPVP_mudaDonoPropriedadeRecebeu = _props;
	(owner _novoDono) publicVariableClient "BRPVP_mudaDonoPropriedadeRecebeu";
};
"BRPVP_ownedHousesSolicita" addPublicVariableEventHandler {
	_p = _this select 1;
	(owner _p) publicVariableClient "BRPVP_variablesObjects";
	(owner _p) publicVariableClient "BRPVP_variablesNames";
	(owner _p) publicVariableClient "BRPVP_variablesValues";
	(owner _p) publicVariableClient "BRPVP_ownedHouses";
};
"BRPVP_ownedHousesAdd" addPublicVariableEventHandler {
	/*
	if (objNull in BRPVP_ownedHouses) then {
		BRPVP_ownedHouses = BRPVP_ownedHouses - [objNull];
	};
	*/
	BRPVP_ownedHouses pushBack (_this select 1);
};
"BRPVP_svCriaVehEnvio" addPublicVariableEventHandler {
	(_this select 1) params ["_p","_param"];
	_veh = createVehicle _param;
	_veh enableSimulation false;
	hideObjectGlobal _veh;
	BRPVP_svCriaVehRetorno = _veh;
	(owner _p) publicVariableClient "BRPVP_svCriaVehRetorno";
};
"BRPVP_amigosAtualizaServidor" addPublicVariableEventHandler {
	_id_bd = _this select 1 select 0;
	_amigos = _this select 1 select 1;
	_sql = format ["UPDATE players SET amigos = '%1' WHERE id = %2",_amigos,_id_bd];
	_key = format ["1:%1:%2",BRPVP_protocoloRaw,_sql];
	_resultado = "extDB3" callExtension _key;
	diag_log ("[BRPVP UPDATE PLAYER FRIENDS] _resultado = " + _resultado + ".");
};
"BRPVP_pegaTop10Estatistica" addPublicVariableEventHandler {
	_estatistica = _this select 1 select 0;
	_solicitante = _this select 1 select 1;
	_max = _estatistica + 1;
	_minChar = ",";
	if (_estatistica == 0) then {_minChar = "[";};
	_sql = format ["SELECT exp,nome FROM players ORDER BY (SUBSTRING_INDEX(SUBSTRING_INDEX(exp,',',%1),'%2',-1)*1) DESC LIMIT 10",_max,_minChar];
	diag_log ("[BRPVP TOP10] _sql = " + _sql);
	_key = format ["0:%1:%2",BRPVP_protocoloRawText,_sql];
	diag_log ("[BRPVP TOP10] _key = " + _sql);
	_resultado = "extDB3" callExtension _key;
	diag_log ("[BRPVP TOP10] _resultado = " + _resultado);
	_resultadoCompilado = call compile _resultado;
	_tabela = [];
	{_tabela = _tabela + [(str ((call compile (_x select 0)) select _estatistica)) + " - " + (_x select 1)];} forEach (_resultadoCompilado select 1);
	diag_log ("[BRPVP TOP10] _tabela = " + str _tabela);
	BRPVP_pegaTop10EstatisticaRetorno = _tabela;
	(owner _solicitante) publicVariableClient "BRPVP_pegaTop10EstatisticaRetorno";
};
"BRPVP_mudaExpOutroPlayer" addPublicVariableEventHandler {
	_player = _this select 1 select 0;
	BRPVP_mudaExpPedidoServidor = _this select 1 select 1;
	(owner _player) publicVariableClient "BRPVP_mudaExpPedidoServidor";
};
"BRPVP_salvaNomePeloIdBd" addPublicVariableEventHandler {
	_id_db = _this select 1 select 0;
	_nome = _this select 1 select 1;
	_key = format ["1:%1:savePlayerName:%2:%3",BRPVP_protocolo,_nome,_id_db];
	_resultado = "extDB3" callExtension _key;
};
"BRPVP_pegaNomePeloIdBd1" addPublicVariableEventHandler {
	(_this select 1) params ["_id_bd_array","_solicitante","_retorno"];
	_id_bd_txt = "";
	_final = (count _id_bd_array) - 1;
	{
		_id_bd_txt = _id_bd_txt + str _x;
		if (_forEachIndex < _final) then {_id_bd_txt = _id_bd_txt + ",";};
	} forEach _id_bd_array;
	_id_bd_txt = "(" + _id_bd_txt + ")";
	_tabNome = [];
	_tabIdBd = [];
	if (_id_bd_txt != "()") then {
		_sql = format ["SELECT nome,id FROM players WHERE id IN %1 ORDER BY nome ASC",_id_bd_txt];
		_key = format ["0:%1:%2",BRPVP_ProtocoloRawText,_sql];
		//_key = format ["0:%1:getPlayerNames1:%2",BRPVP_protocolo,_id_bd_txt];
		_resultado = "extDB3" callExtension _key;
		diag_log ("[BRPVP NAMES1] _resultado = " + _resultado);
		_resultadoCompilado = call compile _resultado;
		diag_log ("[BRPVP NAMES1] _resultadoCompilado = " + str _resultadoCompilado);
		_tabNome = [];
		_tabIdBd = [];
		{_tabNome = _tabNome + [_x select 0];} forEach (_resultadoCompilado select 1);
		{_tabIdBd = _tabIdBd + [_x select 1];} forEach (_resultadoCompilado select 1);
	};
	if (_retorno) then {
		BRPVP_pegaNomePeloIdBd1Retorno = [_tabNome,_tabIdBd];
	} else {
		BRPVP_pegaNomePeloIdBd1Retorno = _tabNome;
	};
	(owner _solicitante) publicVariableClient "BRPVP_pegaNomePeloIdBd1Retorno";
};
"BRPVP_pegaNomePeloIdBd2" addPublicVariableEventHandler {
	_id_bd = _this select 1 select 0;
	_solicitante = _this select 1 select 1;
	//_key = format ["0:%1:getPlayerNames2:%2:%3:%4:%5",BRPVP_protocolo,_id_bd,_id_bd,_id_bd,_id_bd];
	_sql = format ["SELECT nome FROM players WHERE amigos LIKE '[%1,%2' OR amigos LIKE '%2,%1,%2' OR amigos LIKE '%2,%1]' OR amigos LIKE '[%1]' ORDER BY nome ASC",_id_bd,"%"];
	_key = format ["0:%1:%2",BRPVP_protocoloRawText,_sql];
	_resultado = "extDB3" callExtension _key;
	_resultadoCompilado = call compile _resultado;
	_tabela = [];
	{_tabela = _tabela + [_x select 0];} forEach (_resultadoCompilado select 1);
	BRPVP_pegaNomePeloIdBd2Retorno = _tabela;
	(owner _solicitante) publicVariableClient "BRPVP_pegaNomePeloIdBd2Retorno";
};
"BRPVP_pegaNomePeloIdBd3" addPublicVariableEventHandler {
	(_this select 1) params ["_id_bd_array","_id_bd","_solicitante"];
	_id_bd_txt = "";
	_final = (count _id_bd_array) - 1;
	{
		_id_bd_txt = _id_bd_txt + str _x;
		if (_forEachIndex < _final) then {_id_bd_txt = _id_bd_txt + ",";};
	} forEach _id_bd_array;
	_id_bd_txt = "(" + _id_bd_txt + ")";
	_tabNome = [];
	if (_id_bd_txt != "()") then {
		_sql = format ["SELECT nome FROM players WHERE (amigos LIKE '[%1,%3' OR amigos LIKE '%3,%1,%3' OR amigos LIKE '%3,%1]' OR amigos LIKE '[%1]') AND id IN %2 ORDER BY nome ASC",_id_bd,_id_bd_txt,"%"];
		_key = format ["0:%1:%2",BRPVP_protocoloRawText,_sql];
		_resultado = "extDB3" callExtension _key;
		_resultadoCompilado = call compile _resultado;
		{_tabNome = _tabNome + [_x select 0];} forEach (_resultadoCompilado select 1);
	};
	BRPVP_pegaNomePeloIdBd3Retorno = _tabNome;
	(owner _solicitante) publicVariableClient "BRPVP_pegaNomePeloIdBd3Retorno";
};
"BRPVP_adicionaConstrucaoBd" addPublicVariableEventHandler {
	(_this select 1) params ["_mapa","_cons","_estadoCons",["_simpleObj",false]];
	_key = format ["0:%1:createVehicle:%2:%3:%4:%5:%6:%7:%8:%9",BRPVP_protocolo,_estadoCons select 0,_estadoCons select 1,_estadoCons select 2,_estadoCons select 3,_estadoCons select 4,_estadoCons select 5,_mapa,_estadoCons select 6];
	_resultado = "extDB3" callExtension _key;
	diag_log "----------------------------------------------------------------------------------";		
	diag_log "---- [INSERT: ADD CONSTRUCTION ON DB]";
	diag_log ("---- _key = " + str _key + ".");
	diag_log ("---- _resultado = " + str _resultado + ".");
	
	//PEGA ID DO OBJETO 
	_key = format ["0:%1:getConstructionIdByModelPos:%2:%3",BRPVP_protocolo,_estadoCons select 2,_estadoCons select 1];
	_resultado = "extDB3" callExtension _key;
	_resultadoCompilado = call compile _resultado;
	_cId = _resultadoCompilado select 1 select 0 select 0;
	if (_simpleObj) then {
		[_cons,"id_bd",_cId] call BRPVP_setVariable;
	} else {
		_cons setVariable ["id_bd",_cId,true];
		_cons call BRPVP_veiculoEhReset;
		if (_mapa) then {
			_cons setVariable ["mapa",true,true];
		};
		if (_cons isKindOf "LandVehicle") then {
			BRPVP_carrosObjetos pushBack _cons;
			BRPVP_newCarAddClients = _cons;
			publicVariable "BRPVP_newCarAddClients";
		};
		if (_cons isKindOf "Air") then {
			BRPVP_helisObjetos pushBack _cons;
			BRPVP_newHeliAddClients = _cons;
			publicVariable "BRPVP_newHeliAddClients";
		};
	};
	diag_log ("---- id_bd got back from db = " + str _cId + ".");
	diag_log "----------------------------------------------------------------------------------";	
};
"BRPVP_setaVidaPlayer" addPublicVariableEventHandler {
	[_this select 1 select 0,_this select 1 select 1] call BRPVP_daComoMorto;
};
BRPVP_versaoErrada = {
	for "_i" from 1 to 10 do {
		BRPVP_hintEmMassa = ["You is using a wrong version! More info in www.brpvp.com.br! Last version: " + BRPVP_versaoCliente + ".",0];
		(owner _this) publicVariableClient "BRPVP_hintEmMassa";
		sleep 3;
	};
	BRPVP_hintEmMassa = ["Closing mission for you!",0];
	(owner _this) publicVariableClient "BRPVP_hintEmMassa";
	sleep 3;
	BRPVP_terminaMissao = true;
	(owner _this) publicVariableClient "BRPVP_terminaMissao";
};
"BRPVP_checaExistenciaPlayerBd" addPublicVariableEventHandler {
	_versaoErrada = true;
	if (typeName (_this select 1) == "OBJECT") exitWith {(_this select 1) spawn BRPVP_versaoErrada;};
	_player = _this select 1 select 0;
	_versao = _this select 1 select 1;
	if (_versao != BRPVP_versaoCliente) exitWith {_player spawn BRPVP_versaoErrada;};
	_playerId = getPlayerUID _player;
	_key = format ["0:%1:checkIfPlayerOnDb:%2",BRPVP_protocolo,_playerId];
	_resultado = "extDB3" callExtension _key;
	diag_log "----------------------------------------------------------------------------------";		
	diag_log "---- " + _playerId;
	diag_log "---- [SELECT: CHECK IF PLAYER IS ON DB AND IS ALIVE]";
	diag_log ("---- _key = " + str _key + ".");
	diag_log ("---- _resultado = " + str _resultado + ".");
	diag_log "----------------------------------------------------------------------------------";	
	if (_resultado == "[1,[[2]]]") then {BRPVP_checaExistenciaPlayerBdRetorno = "no_bd_e_clcmode";};
	if (_resultado == "[1,[[1]]]") then {BRPVP_checaExistenciaPlayerBdRetorno = "no_bd_e_vivo";};
	if (_resultado == "[1,[[0]]]") then {BRPVP_checaExistenciaPlayerBdRetorno = "no_bd_e_morto";};
	if (_resultado == "[1,[]]") then {BRPVP_checaExistenciaPlayerBdRetorno = "nao_ta_no_bd";};
	(owner _player) publicVariableClient "BRPVP_checaExistenciaPlayerBdRetorno";
};
"BRPVP_incluiPlayerNoBd" addPublicVariableEventHandler {
	_player = _this select 1 select 0;
	_estadoPLayer = _this select 1 select 1;
	_steamKey = _estadoPLayer select 0;
	_key = format["0:%1:createPlayer:%2:%3:%4:%5:%6:%7:%8:%9:%10:%11:%12:%13:%14",BRPVP_Protocolo,_steamKey,_estadoPLayer select 1,_estadoPLayer select 2,_estadoPLayer select 3,_estadoPLayer select 4,_estadoPLayer select 5,_estadoPLayer select 6,[],_estadoPLayer select 7,_estadoPLayer select 8,1,_estadoPLayer select 9,_estadoPLayer select 10];
	_resultado = "extDB3" callExtension _key;
	diag_log "----------------------------------------------------------------------------------";	
	diag_log "---- " + (_estadoPLayer select 0);
	diag_log "---- [INSERT A NEW PLAYER ON DB]";
	diag_log "---- PLAYER...";
	diag_log ("---- _key = " + _key + ".");
	diag_log ("---- _resultado = " + str _resultado + ".");

	_key = format ["0:%1:getIdBdBySteamKey:%2",BRPVP_Protocolo,_steamKey];
	_resultado = "extDB3" callExtension _key;
	diag_log "---- ID BD...";
	diag_log ("---- _key = " + _key + ".");
	diag_log ("---- _resultado = " + str _resultado + ".");
	diag_log "----------------------------------------------------------------------------------";
	
	_resultadoCompilado = call compile _resultado;
	BRPVP_incluiPlayerNoBdRetorno = _resultadoCompilado select 1 select 0 select 0;
	(owner _player) publicVariableClient "BRPVP_incluiPlayerNoBdRetorno";
};
"BRPVP_salvaPlayer" addPublicVariableEventHandler {
	(_this select 1) call BRPVP_salvarPlayerServidor;
};
"BRPVP_salvaPlayerVault" addPublicVariableEventHandler {
	_estadoPlayer = _this select 1 select 0;
	_estadoVault = _this select 1 select 1;
	if (count _estadoPlayer > 0) then {_estadoPlayer call BRPVP_salvarPlayerServidor;};
	_estadoVault call BRPVP_salvarPlayerVaultServidor;
};
"BRPVP_pegaValoresContinua" addPublicVariableEventHandler {
	_player = _this select 1;
	_key = format ["0:%1:getPlayerNextLifeVals:%2",BRPVP_protocolo,getPlayerUID _player];
	_resultado = "extDB3" callExtension _key;
	diag_log "----------------------------------------------------------------------------------";
	diag_log "---- PLAYER ON DB AND DEAD: GET VALUES TO MANTAIN";
	diag_log ("---- _key = " + _key + ".");
	diag_log ("---- _resultado = " + str _resultado + ".");
	diag_log "----------------------------------------------------------------------------------";
	BRPVP_pegaValoresContinuaRetorno = _resultado;
	(owner _player) publicVariableClient "BRPVP_pegaValoresContinuaRetorno";
};
"BRPVP_pegaPlayerBd" addPublicVariableEventHandler {
	_player = _this select 1;
	_pId = getPlayerUID _player;
	_key = format ["0:%1:getPlayer:%2",BRPVP_protocolo,_pId];
	_resultado = "extDB3" callExtension _key;
	diag_log "----------------------------------------------------------------------------------";
	diag_log "---- " + _pId;
	diag_log "---- [GET PLAYER ON DB]";
	diag_log ("---- _key = " + str _key + ".");
	diag_log ("---- _resultado = " + str _resultado + ".");
	diag_log "----------------------------------------------------------------------------------";	
	BRPVP_pegaPlayerBdRetorno = _resultado;
	(owner _player) publicVariableClient "BRPVP_pegaPlayerBdRetorno";
};
"BRPVP_pegaVaultPlayerBd" addPublicVariableEventHandler {
	_player = _this select 1 select 0;
	_vaultIdx = _this select 1 select 1;
	_pId = getPlayerUID _player;
	
	_key = format ["0:%1:getPlayerVault:%2:%3",BRPVP_protocolo,_pId,_vaultIdx];
	_resultado = "extDB3" callExtension _key;
	if (_resultado == "[1,[]]") then {
		diag_log ("[BRPVP GET VAULT] Vault with IDX = " + str _vaultIdx + " not found! _resultado = " + str _resultado + ".");
		diag_log "[BRPVP GET VAULT] Creating Vault.";

		_key = format ["0:%1:createVault:%2:%3:%4:%5:%6",BRPVP_Protocolo,_pId,[[[],[]],[],[[],[]],[[],[]]],1,[],_vaultIdx];
		_resultado = "extDB3" callExtension _key;
		diag_log ("---- CREATED VAULT OF IDX = " + str _vaultIdx + " FOR PLAYER " + name _player + ".");
		diag_log ("---- _key = " + _key + ".");
		diag_log ("---- _resultado = " + str _resultado + ".");
		
		_key = format ["0:%1:getPlayerVault:%2:%3",BRPVP_protocolo,_pId,_vaultIdx];
		_resultado = "extDB3" callExtension _key;
	};
	diag_log "----------------------------------------------------------------------------------";
	diag_log "---- " + _pId;
	diag_log ("---- [GET VAULT GEAR IDX = " + str _vaultIdx + "]");
	diag_log ("---- _key = " + str _key + ".");
	diag_log ("---- _resultado = " + str _resultado + ".");
	diag_log "----------------------------------------------------------------------------------";
	
	BRPVP_pegaVaultPlayerBdRetorno = _resultado;
	(owner _player) publicVariableClient "BRPVP_pegaVaultPlayerBdRetorno";
};
"BRPVP_salvaVeiculoBd" addPublicVariableEventHandler {
	_carros = _this select 1;
	{
		_x call BRPVP_salvaVeiculo;
	} forEach _carros;
};