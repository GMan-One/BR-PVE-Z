//====================================================================
//BASEADO NO CASCA CONVOYS PARA ARMA 2, SCRIPT DO MESMO AUTOR DO BRPVP
//====================================================================
//ALGUNS CODIGOS PODEM ESTAR NO ORIGINAL EM INGLES
//====================================================================
//WORK IN PROGRESS
//====================================================================

//RODA?
if !(BRPVP_mapaRodando select 8 select 0) exitWith {
	BRPVP_unidBlindados = [];
	BRPVP_unidBlindadosCor = [];
	publicVariable "BRPVP_unidBlindados";
	publicVariable "BRPVP_unidBlindadosCor";
};

//AVISA PLAYERS LOGANDO SOBRE EVOLUCAO DO LOAD NO SERVIDOR
BRPVP_serverTrabalhando = ["SPAWNING MOTORIZED AI ON MAP!",BRPVP_ant + "<t size='2'>MOTORIZED:</tr><br/><t size='3'>0</t>"];
PublicVariable "BRPVP_serverTrabalhando";

//DADOS DE CADA LADO (BOTS)
_TODOS_caras_side = [WEST,INDEPENDENT];
_TODOS_caras_side_prefixo = ["B_","I_"];
_TODOS_caras_cor = ["ColorBlue","ColorRed"];

//CONFIGURACAO DE VEICULOS
BRPVP_comboBlindados = [
	[
		["B_Quadbike_01_F",0,[],[]],
		["B_Quadbike_01_F",1,[],[]],
		["B_MRAP_01_F",0,[1,2,3],[]],
		["B_MRAP_01_F",0,[1,2,3],[]],
		["B_MRAP_01_hmg_F",0,[1,2],[3]],
		["B_MRAP_01_gmg_F",0,[1,3],[2]],
		["B_MBT_01_cannon_F",0,[1],[2]],
		["B_APC_Wheeled_01_cannon_F",0,[1],[3]]
	],
	[
		["I_Quadbike_01_F",0,[],[]],
		["I_Quadbike_01_F",1,[],[]],
		["I_MRAP_03_F",0,[1,2,3],[]],
		["I_MRAP_03_F",0,[1,2,3],[]],
		["I_MRAP_03_hmg_F",0,[1,2],[]],
		["I_MRAP_03_gmg_F",0,[1,3],[2]],
		["I_APC_tracked_03_cannon_F",0,[1],[2]],
		["I_APC_Wheeled_03_cannon_F",0,[1],[3]]
	]
];

//PEGA DO ARQUIVO DE MISSAO OS CARROS DE CADA LADO
_convoyFormation = BRPVP_mapaRodando select 8 select 1 select 0;
_insiste = BRPVP_mapaRodando select 8 select 1 select 1;

//FUNCAO PARA ACHAR ROTA DO CARRO
BRPVP_fazRotaTerra = {
	_origin = _this select 0;
	_mzGroup = _this select 1;
	_posBefore = _origin;
	_posNow = _origin;
	_wp = _mzGroup addWaypoint [_posNow,0,0];
	_wp setWaypointCompletionRadius 15;
	_wp setWaypointType "MOVE";
	_wp setWaypointSpeed "NORMAL";
	_posNext = [0,0,0];
	for "_c" from 1 to 10 do {
		_distToBefore = 0;
		_distToNext = 0;
		_found = false;
		for "_x" from 1 to 200 do {
			_posNext = BRPVP_isecs call BIS_fnc_selectRandom;
			_distToNext = _posNow distance _posNext;
			_distToBefore = _posNext distance _posBefore;
			_otherIsland = false;
			if (_distToNext > 600 && _distToNext < 1500 && _distToBefore > 1000) then {
				_found = true;
				_distUnits = _distToNext/20;
				_dltX = ((_posNext select 0) - (_posNow select 0))/_distUnits;
				_dltY = ((_posNext select 1) - (_posNow select 1))/_distUnits;
				for "_i" from 1 to _distUnits do {
					_travelPos = [(_posNow select 0)+_i*_dltX,(_posNow select 1)+_i*_dltX]; 
					if (surfaceIsWater _travelPos) exitWith {_found = false;};
				};
			};
			if (_found) exitWith {};
		};
		if (!_found) then {_posNext = BRPVP_isecs call BIS_fnc_selectRandom;};
		_wp = _mzGroup addWaypoint [_posNext,0,_c];
		_wp setWaypointCompletionRadius 15;
		_wp setWaypointType "MOVE";
		_wp setWaypointSpeed "NORMAL";
		_posNow = _posNext;
	};
	_wp = _mzGroup addWaypoint [_origin,0,6];
	_wp setWaypointCompletionRadius 15;
	_wp setWaypointType "CYCLE";
	_wp setWaypointSpeed "NORMAL";
};

//SPAWNA VEICULOS E TRIPULACAO
BRPVP_unidBlindados = [];
BRPVP_unidBlindadosCor = [];
BRPVP_blindaGroups = [];
_contaMZ = 0;
for "_cs" from 1 to (count _convoyFormation) do {
	_convoy = _convoyFormation select (_cs-1) select 0;
	_tipoCaras = [];
	_prefixo = _TODOS_caras_side_prefixo select (_convoyFormation select (_cs-1) select 1);
	while {count _tipoCaras == 0} do {
		_tenta = BRPVP_gruposDeInfantaria call BIS_fnc_selectRandom;
		_unid = _tenta select 0 select 0;
		if (_unid find _prefixo == 0) then {_tipoCaras = _tenta;};
	};
	_qtd = count _convoy;
	
	//PROCURA POSICAO PARA POR CARRO
	_idc = _convoyFormation select (_cs-1) select 1;
	_lado = _TODOS_caras_side select _idc;
	_inimigo = _TODOS_caras_side select (1 - _idc);
	_rua = [BRPVP_ruas,[],[],0,1,_insiste,false,_lado,_inimigo] call BRPVP_achaCentroPrincipal;
	
	//ACHA SEGMENTOS DE RUA PROXIMOS, UM PARA CADA CARRO
	_rPos = [[getPosATL _rua,getDir _rua]];
	while {count _rPos < _qtd} do {
		_ruasConec = roadsConnectedTo _rua;
		{_ruasConec set [_forEachIndex,[getPosATL _x,getDir _x]];} forEach _ruasConec;
		_rPos = _rPos + _ruasConec;
	};
	
	//CRIA GRUPO DO COMBOIO E ARMAZENA GRUPO NO ARRAY
	_mzGroup = createGroup _lado;
	BRPVP_blindaGroups pushBack _mzGroup;
	
	//INICIA CRIACAO DOS CARROS E DA TRIPULACAO	
	_cars = [];
	{_cars pushBack (BRPVP_comboBlindados select _idc select _x);} forEach _convoy;
	for "_n" from 1 to _qtd do {
		private ["_firstDriver"];
		
		//PEGA E CRIA CARRO
		_car = _cars select (_n - 1);
		_motor = createVehicle [_car select 0,_rPos select (_n - 1) select 0,[],4,"NONE"];
		//_motor setVehicleAmmoDef 1;
		
		//ESVAZIA GEAR DO CARRO
		clearWeaponCargoGlobal _motor;
		clearMagazineCargoGlobal _motor;
		clearItemCargoGlobal _motor;
		clearBackpackCargoGlobal _motor;
		
		//SETA DIRECAO E COMBUSTIVEL DO CARRO
		_motor setDir (_rPos select (_n - 1) select 1);
		//_motor setFuel 1;
		
		//ADICIONA TRATAMENTO DE ENTRADAS NO CARRO E DANO
		_motor call BRPVP_veiculoEhReset;
		_motor addEventHandler ["GetIn",{_this call BRPVP_carroBotGetIn;}];
		_motor addEventHandler ["HandleDamage",{_this call BRPVP_hdEhVeiculo}];
		_motor addEventHandler ["Killed",{
			(_this select 0) removeAllEventHandlers "HandleDamage";
			(_this select 0) removeAllEventHandlers "GetIn";
		}];
		
		//CONTA TRIPULACAO
		_cargorsCount = count (_car select 2);
		_turreterCount = count (_car select 3);
		_crewCount = 1 + _cargorsCount + _turreterCount;
		_crewSkin = [_car select 1] + (_car select 2) + (_car select 3);

		//INICIA COLOCACAO DA TRIPULACAO
		_gPos = 0;
		for "_y" from 1 to _crewCount do {
			//CRIA BOT E SETA SEU SKILL
			_idc = (_crewSkin select (_y - 1)) mod (count _tipoCaras);
			_unit = _mzGroup createUnit [_tipoCaras select _idc select 0,[0,0,0],[],20,"NONE"];
			_unit setSkill 0.45;
			_unit setRank (_tipoCaras select _idc select 1);

			//ADD MAGAZINES TO DEFAULT UNIT WEAPONS, IF NEEDED
			[_unit] call BRPVP_fillUnitWeapons;
			
			//ADICIONA EVENT HANDLERS DO BOT
			_unit addEventHandler ["killed",{_this call BRPVP_botDaExp;_this call BRPVP_rolaMotorista;}];
			_unit addEventHandler ["handleDamage",{_this call BRPVP_hdeh}];
			
			//ADICIONA BOT NO ARRAY DE BOTS E COR NO ARRAY DE CORES
			BRPVP_unidBlindados pushBack _unit;
			BRPVP_unidBlindadosCor pushBack (_TODOS_caras_cor select (_convoyFormation select (_cs-1) select 1));
			
			//DEFINE FUNCOES DE CADA BOT
			if (_y == 1) then {
				_unit moveInDriver _motor;
				_unit assignAsDriver _motor;
			};
			if (_y > 1 && _y <= 1 + _cargorsCount) then {
				_unit moveInCargo _motor;
				_unit assignAsCargo _motor;
			};
			if (_y > 1 + _cargorsCount) then {
				_unit moveInTurret [_motor,[_gPos]];
				_gPos = _gPos + 1;
				_unit assignAsGunner _motor;
			};
		};
		_contaMZ = _contaMZ + 1;
	};
	[_rPos select 0 select 0,_mzGroup] call BRPVP_fazRotaTerra;
	
	//MOSTRA EVOLUCAO DO LOADING DO SERVIDOR PARA PLAYERS LOGANDO APOS RESTART
	BRPVP_serverTrabalhando = ["",BRPVP_ant + "<t size='2'>MOTORIZED:</tr><br/><t size='3'>" + str _contaMZ + "</t>"];
	PublicVariable "BRPVP_serverTrabalhando";
};
if (count _convoyFormation == 0) then {
	BRPVP_serverTrabalhando = ["",BRPVP_ant + "<t size='2'>MOTORIZED:</tr><br/><t size='3'>" + str _contaMZ + "</t>"];
	PublicVariable "BRPVP_serverTrabalhando";
};

//ENVIA VARIAVEIS DOS BOTS DOS CARROS PARA OS CLIENTES
publicVariable "BRPVP_unidBlindados";
publicVariable "BRPVP_unidBlindadosCor";

//FINALIZA LOADING PARA PLAYERS LOGANDO DURANTE O RESTART
BRPVP_ant = (BRPVP_serverTrabalhando select 1) + "<br/>";