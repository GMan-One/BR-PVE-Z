//VERSAO
BRPVP_versaoCliente = "V0.2B2";

//ExtDB3: DEFINE NOME PROTOCOLOS
BRPVP_Protocolo = "P" + str round random 10000000;
BRPVP_ProtocoloRaw = "PR" + str round random 10000000;
BRPVP_ProtocoloRawText = "PR" + str round random 10000000;

//ExtDB3: CONNECTA AO MYSQL
_db = BRPVP_mapaRodando select 12;
"extDB3" callExtension ("9:ADD_DATABASE:" + _db);

//ExtDB3: CRIA PROTOCOLO
"extDB3" callExtension ("9:ADD_DATABASE_PROTOCOL:" + _db + ":SQL_CUSTOM:" + BRPVP_Protocolo + ":brpvp.ini");
"extDB3" callExtension ("9:ADD_DATABASE_PROTOCOL:" + _db + ":SQL:" + BRPVP_ProtocoloRaw);
"extDB3" callExtension ("9:ADD_DATABASE_PROTOCOL:" + _db + ":SQL:" + BRPVP_ProtocoloRawText + ":TEXT");

//ExtDB3: LOGA NOME DOS PROTOCOLOS
diag_log ("[BRPVP PROTOCOLO] " + BRPVP_Protocolo);
diag_log ("[BRPVP PROTOCOLO_RAW] " + BRPVP_ProtocoloRaw);
diag_log ("[BRPVP PROTOCOLO_RAW_TEXT] " + BRPVP_ProtocoloRawText);

//ESPERA SERVERTIME DO CLIENTE
_init = time;
waitUntil {!isNil "BRPVP_serverTimeSend" || time - _init >= 30};
if (isNil "BRPVP_serverTimeSend") then {BRPVP_serverTimeSend = 30;};
_STCli = BRPVP_serverTimeSend;
BRPVP_serverTime = BRPVP_serverTimeSend;
_start = time;
_timeLim = _start + ((310 - _STCli) max 0);
_nulo = [_STCli,_timeLim,_start] spawn {
	params ["_STCli","_timeLim","_start"];
	while {true} do {
		_time = time;
		if (_time < _timeLim) then {
			BRPVP_serverTime = _STCli + (_time - _start);
		} else {
			BRPVP_serverTime = serverTime;
		};
		sleep 1;
	};
};

//VARIAVEIS PUBLICAS
BRPVP_corruptMissIcon = [];
publicVariable "BRPVP_corruptMissIcon";
BRPVP_konvoyCompositions = [];
publicVariable "BRPVP_konvoyCompositions";
BRPVP_interferencia = 1;
publicVariable "BRPVP_interferencia";
BRPVP_terminaMissao = false;
publicVariable "BRPVP_terminaMissao";
BRPVP_noAntiAmarelou = [];
publicVariable "BRPVP_noAntiAmarelou";
BRPVP_missPrediosEm = [];
publicVariable "BRPVP_missPrediosEm";
BRPVP_missBotsEm = [];
publicVariable "BRPVP_missBotsEm";
BRPVP_naPista = [];
publicVariable "BRPVP_naPista";
BRPVP_buildingHaveDoorList = [
	//ORIGINAL BUILDINGS
	"Land_Net_Fence_Gate_F",
	"Land_City_Gate_F",
	"Land_Stone_Gate_F",
	"Land_Slum_House01_F",
	"Land_Slum_House02_F",
	"Land_Slum_House03_F",
	"Land_cmp_Shed_F",
	"Land_FuelStation_Build_F",
	"Land_Cargo_Tower_V1_F",
	"Land_Cargo_Patrol_V1_F",
	"Land_Dome_Small_F",
	"Land_Church_01_V1_F",
	"Land_Offices_01_V1_F",
	"Land_WIP_F",
	"Land_dp_mainFactory_F",
	"Land_i_Barracks_V1_F",
	//STORAGE AND FUEL OBJECTS
	"Box_NATO_AmmoVeh_F",
	"Box_East_AmmoVeh_F",
	"Box_IND_AmmoVeh_F",
	"Land_fs_feed_F",
	"Land_FuelStation_Feed_F",
	//SMALL VANILLA HOUSES
	"Land_i_Addon_02_V1_F",
	"Land_i_House_Small_02_V1_F",
	"Land_i_House_Small_02_V2_F",
	"Land_i_House_Small_02_V3_F",
	"Land_GH_House_1_F",
	"Land_GH_House_2_F",
	"Land_i_House_Small_01_V1_F",
	"Land_i_House_Small_01_V2_F",
	"Land_i_Windmill01_F",
	//BIG VANILLA HOUSES
	"Land_i_House_Big_01_V1_F",
	"Land_i_House_Big_01_V2_F",
	"Land_i_House_Big_01_V3_F",
	"Land_i_House_Big_02_V1_F",
	"Land_i_House_Big_02_V2_F",
	"Land_i_House_Big_02_V3_F",
	"Land_i_Shop_01_V1_F",
	"Land_i_Shop_01_V2_F",
	"Land_i_Shop_02_V1_F",
	"Land_i_Shop_02_V2_F",
	"Land_i_Shop_02_V3_F",
	//KIT MOVEMENT
	"Land_PierLadder_F",
	//KIT LAMP
	"Land_LampStreet_small_F",
	"Land_LampStreet_F",
	"Land_LampSolar_F",
	"Land_LampDecor_F",
	"Land_LampHalogen_F",
	"Land_LampHarbour_F",
	"Land_LampStadium_F",
	"Land_LampAirport_F",
	//RELIGIOUS KIT - ANTI ZOMBIE
	"Land_BellTower_01_V1_F",
	"Land_BellTower_02_V1_F",
	"Land_BellTower_02_V2_F",
	"Land_Calvary_01_V1_F",
	"Land_Calvary_02_V1_F",
	"Land_Calvary_02_V2_F",
	"Land_Grave_obelisk_F",
	"Land_Grave_memorial_F",
	"Land_Grave_monument_F"
] + BRPVP_buildingHaveDoorListExtra;
publicVariable "BRPVP_buildingHaveDoorList";
BRPVP_buildingHaveDoorListReverseDoor = [] + BRPVP_buildingHaveDoorListReverseDoorExtra;
publicVariable "BRPVP_buildingHaveDoorListReverseDoor";

//VARIAVEIS SO SERVIDOR
BRPVP_criaMissaoDePredioIdc = 1;
BRPVP_cycloDeSalvamentoBd = 300;
BRPVP_serverTrabalhando = ["",""];
BRPVP_ant = "";
BRPVP_distPlayerParaDanBot = 300;
BRPVP_distPlayerParaDanBotTimer = 5;
BRPVP_ownedHouses = [];
BRPVP_botKillRemove = ["ItemRadio"];
BRPVP_corpsesToDel = [];

//MISSION ROOT: http://killzonekid.com/arma-scripting-tutorials-mission-root/
BRPVP_missionRoot = str missionConfigFile select [0, count str missionConfigFile - 15];


//CALCULOS PESADOS
_calcTerr = isNil "BRPVP_terrenos";
_calcMerc = isNil "BRPVP_terrPosArray";

//FORMA QUADRATICA
BRPVP_distPlayerParaDanBot = BRPVP_distPlayerParaDanBot^2;

//EXECUCOES SERVIDOR
["CONSTRUCOES_EXTRA","\BRPVP_server\servidor_construcoes_" + (BRPVP_mapaRodando select 0) + ".sqf"] call BRPVP_execFast;
["CRIA_ARRAY_RUAS",{BRPVP_ruas = BRPVP_centroMapa nearRoads 20000;}] call BRPVP_execFast;
["VARIAVEIS_CALCULADAS","\BRPVP_server\servidor_variaveisCalculadas.sqf"] call BRPVP_execFast;
["FUNCOES","\BRPVP_server\servidor_funcoes.sqf"] call BRPVP_execFast;
["PVEH_SERVIDOR","\BRPVP_server\servidor_PVEH.sqf"] call BRPVP_execFast;
["ARSENAL_VEICULOS","\BRPVP_server\servidor_assets_a3_cup.sqf"] call BRPVP_execFast;

if (_calcTerr) then {["ACHA TERRENOS",BRPVP_achaTerreno] call BRPVP_execFast;};

call compile preprocessFileLineNumbers "principais\itemMarketVariables.sqf";
call compile preprocessFileLineNumbers "\BRPVP_server\servidor_mercados.sqf";

["VEICULOS","\BRPVP_server\servidor_veiculos.sqf"] call BRPVP_execFast;
["COMPLETA_VEICULOS","\BRPVP_server\servidor_completa_veiculos.sqf"] call BRPVP_execFast;
["LOOT_SERVIDOR","principais\sistema_loot.sqf"] call BRPVP_execFast;
["BOTS_ON_FOOT","\BRPVP_server\servidor_bots_ape.sqf"] call BRPVP_execFast;
["BOTS_CARROS","\BRPVP_server\servidor_motorizado.sqf"] call BRPVP_execFast;
["BOTS_REVOLTOSOS","\BRPVP_server\servidor_revoltosos.sqf"] call BRPVP_execFast;

//SIEGE MISSION
BRPVP_closedCityWalls = [];
BRPVP_closedCityRunning = [];
BRPVP_closedCityObjs = [];
BRPVP_closedCityAI = [];
BRPVP_closedCityTime = [];
{
	BRPVP_closedCityWalls pushBack [];
	BRPVP_closedCityRunning pushBack 0;
	BRPVP_closedCityObjs pushBack [];
	BRPVP_closedCityAI pushBack [];
	BRPVP_closedCityTime pushBack -600;
} forEach BRPVP_locaisImportantes;
BRPVP_towas = ["Land_Cargo_Patrol_V2_F","Land_Cargo_Patrol_V3_F","Land_Cargo_Tower_V2_F"];
publicVariable "BRPVP_closedCityRunning";
publicVariable "BRPVP_closedCityWalls";
publicVariable "BRPVP_closedCityObjs";

call compile preprocessFileLineNumbers "\BRPVP_server\servidor_loop.sqf";

//WALKERS
execVM "\BRPVP_server\servidor_walkers.sqf";
waitUntil {!isNil "BRPVP_walkersObj"};

//SALVA PLAYER NA SAIDA + ANTI-AMARELOU
addMissionEventHandler ["HandleDisconnect",{
	_p = _this select 0;
	if (_p getVariable ["sok",false]) then {
		//SAVE VAULT AND SELL RECEPTACLE
		[_p,true] call BRPVP_salvaVault;

		//CANCEL CONSTRUCTION IF IN CONSTRUCTION
		_obui = _p getVariable ["obui",objNull];
		if (!isNull _obui) then {deleteVehicle _obui;};
		
		if (BRPVP_terminaMissao) then {
			if (alive _p) then {
				(_p call BRPVP_pegaEstadoPlayer) call BRPVP_salvarPlayerServidor;
			} else {
				[_p getVariable ["id","0"],0] call BRPVP_daComoMorto;
			};		
		} else {
			if (alive _p) then {
				//SALVA PLAYER
				(_p call BRPVP_pegaEstadoPlayer) call BRPVP_salvarPlayerServidor;
				
				//LIGA ANTI-AMARELOU NO USUARIO E NO SLOT
				diag_log ( "[BRPVP AA] player state = " + str (_p call BRPVP_pegaEstadoPlayer));
				BRPVP_noAntiAmarelou pushBack (_p getVariable ["id","0"]);
				publicVariable "BRPVP_noAntiAmarelou";
				
				//DISABLE AI
				_p disableAI "TARGET";
				_p disableAI "AUTOTARGET";
				_p disableAI "MOVE";
				_p disableAI "ANIM";
				_p disableAI "TEAMSWITCH";
				_p disableAI "FSM";
				_p disableAI "AIMINGERROR";
				_p disableAI "SUPPRESSION";
				_p disableAI "CHECKVISIBLE";
				_p disableAI "COVER";
				_p disableAI "AUTOCOMBAT";
				_p disableAI "PATH";
				
				_p spawn {
					_p = _this;
					
					//REMOVE DO SLOT
					_grpAntigo = group _p;
					_grpNovo = createGroup OPFOR;
					[_p] joinSilent _grpNovo;
					deleteGroup _grpAntigo;
					
					//ESPERA MORTE DO PLAYER E FINALIZA
					_ini = time;
					_pass = 0;
					waitUntil {_pass = time - _ini;_pass >= 11.75 || !alive _p || BRPVP_terminaMissao};
					_id = _p getVariable ["id","0"];
					if (alive _p) then {
						if (_pass > 1) then {
							(_p call BRPVP_pegaEstadoPlayer) call BRPVP_salvarPlayerServidor;
						};
						deleteVehicle _p;
						deleteGroup _grpNovo;
					} else {
						[_p getVariable ["id","0"],0] call BRPVP_daComoMorto;
						_p setVariable ["hrm",BRPVP_serverTime,true];
						//_p setVariable ["id_bd",-1,true];
						_p setVariable ["stp",3,true];
					};
											
					//RETIRA PLAYER DO ANTI-AMARELOU
					_p setVariable ["AA",false,true];
					BRPVP_noAntiAmarelou = BRPVP_noAntiAmarelou - [_id];
					publicVariable "BRPVP_noAntiAmarelou";
					
					//FAZ ATUALIZAR LISTA AMIGOS
					BRPVP_PUSV = true;
					publicVariable "BRPVP_PUSV";
				};
			} else {
				//playSound3D [BRPVP_missionRoot + "BRP_sons\nobreath.ogg",_p,false,getPosASL _p,0.5,1,0];
				[_p getVariable ["id","0"],0] call BRPVP_daComoMorto;
				_p setVariable ["hrm",BRPVP_serverTime,true];
				_p setVariable ["dd",1,true];
				_p setVariable ["stp",3,true];
				BRPVP_PUSV = true;
				publicVariable "BRPVP_PUSV";
			};
		};
	} else {
		_p spawn {
			sleep 0.001;
			deleteVehicle _this;
		};
	};
	true
}];