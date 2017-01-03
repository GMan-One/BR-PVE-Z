//=======
//RUN IT?
//=======
if !(BRPVP_mapaRodando select 9 select 0) exitWith {
	BRPVP_walkersObj = [];
	publicVariable "BRPVP_walkersObj";
};

//=============
//CONFIGURACOES
//=============
_qtt = BRPVP_mapaRodando select 9 select 1;
_agntCxIs = [
	[[["srifle_DMR_02_sniper_F",1]],[[getArray (configFile >> "CfgWeapons" >> "srifle_DMR_02_sniper_F" >> "magazines") select 0,4]]],
	[[["LMG_Mk200_LP_BI_F",1]],[[getArray (configFile >> "CfgWeapons" >> "LMG_Mk200_LP_BI_F" >> "magazines") select 0,3]]]
];

//=========
//VARIAVEIS
//=========
_agnts = [];
_agntsAct = [];
_agntsArg = [];
_agntsConclu = [];
_agntRelacoes = [];
BRPVP_agntsMusica = [];
_bonecos = ["C_man_polo_4_F_asia","C_man_polo_2_F_asia"];
_todosLocs = nearestLocations [
	BRPVP_centroMapa,
	["NameVillage","NameCity","NameCityCapital","Airport"],
	20000
];

//============
//CRIA AGENTES
//============
for "_i" from 1 to _qtt do {
	_loc = _todosLocs call BIS_fnc_SelectRandom;
	_locP = locationPosition _loc;
	_locP set [2,0];
	_ruas = _locP nearRoads 300;
	if (count _ruas > 0) then {
		_rua = _ruas call BIS_fnc_selectRandom;
		_locP = getPosATL _rua;
		_locP set [2,0];
	};
	_agnt = createAgent [_bonecos call BIS_fnc_selectRandom,_locP,[],15,"NONE"];
	_agnt disableAI "AUTOTARGET";
	_agnt disableAI "TARGET";
	_agnt disableAI "FSM";
	_agnt disableAI "AUTOCOMBAT";
	_agnt disableAI "COVER";
	_agnt setCombatMode "BLUE";
	_agnt setBehaviour "CARELESS";
	_agnt setCaptive true;
	_agnts = _agnts + [_agnt];
	_agntsAct = _agntsAct + [0];
	_agntsArg = _agntsArg + [-1];
	_agnt addEventHandler [
		"HandleDamage",
		{
			_dano = 0;
			_unidade = _this select 3;
			_ePlayer = isPlayer _unidade;
			_qPlayerCarro = 0;
			if (vehicle _unidade != _unidade) then {_qPlayerCarro = {isPlayer _x} count crew vehicle _unidade;};
			if (_ePlayer || _qPlayerCarro > 0) then {_dano = _this select 2;};
			_dano
		}
	];
	if (_i <= _qtt/2) then {
		_agntsConclu = _agntsConclu + ["bmb"];
		_agnt addEventhandler ["Killed",{
			params ["_agnt","_killer"];
			_pos = getPosATL _agnt;
			_pos set [2,0];
			BRPVP_giveMoney = 1500;
			(owner _killer) publicVariableClient "BRPVP_giveMoney";
			[_agnt,_pos] spawn {
				params ["_agnt","_pos"];
				sleep 3;
				_bmb = createVehicle ["Bo_GBU12_LGB_MI10",_pos,[],0,"CAN_COLLIDE"];
				_bmb setVectorDirAndUp [[0,0,1],[0,-1,0]];
				_bmb setVelocity [0,0,-1000];
				deleteVehicle _agnt;
			};
		}];
	} else {
		_agntsConclu = _agntsConclu + ["prem"];
	};
	_agntRelacoes = _agntRelacoes + [[[],[]]];
	BRPVP_agntsMusica = BRPVP_agntsMusica + [false];
	sleep 0.001;
};
BRPVP_walkersObj = _agnts;
publicVariable "BRPVP_walkersObj";

//========================================
//FUNCOES DE MOVIMENTO E ACAO - AUXILIARES
//========================================
_BRPVP_moveTo = {
	params ["_agnt","_nDest","_vel"];
	_dest = (expectedDestination _agnt) select 0;
	if !(moveToCompleted _agnt) then {
		_pAgo = getPosATL _agnt;
		_agnt setPosATL _dest;
		_agnt setPosATL _pAgo;
	};
	_agnt moveTo _nDest;
	_agnt forceSpeed _vel;
};
_BRPVP_playerMaisPertoVe = {
	params ["_idc","_visExt"];
	private ["_agnt","_hPerto","_pPerto","_minDist","_dist","_podeVer"];
	_agnt = _agnts select _idc;
	_hPerto = (_agnt nearEntities ["CaManBase",100]);
	_conhece = _agntRelacoes select _idc select 0;
	_ignora = _agntRelacoes select _idc select 1;
	_pPerto = objNull;
	_minDist = 1000000;
	{
		if (isPlayer _x) then {
			if (alive _x && _x getVariable ["umok",false]) then {
				if !(_x in _ignora) then {
					_dist = _agnt distanceSqr _x;
					if (_dist < _minDist) then {
						_range = if (_x in _conhece) then {240} else {120};
						_range = _range + ((_visExt * 60) min 60);
						_noSetor = [position _agnt,getDir _agnt,_range,position _x] call BIS_fnc_inAngleSector;
						if (_noSetor) then {
							_podeVer = [_x,"VIEW"] checkVisibility [eyepos _agnt,eyepos _x];
							if (_podeVer > 0.6) then {
								_minDist = _dist;
								_pPerto = _x;
							};
						};
					};
				};
			};
		};
	} forEach _hPerto;
	if (!isNull _pPerto) then {
		_ps1 = _agntRelacoes select _idc;
		_ps2 = _ps1 select 0;
		if !(_pPerto in _ps2) then {
			_ps2 append [_pPerto];
			_ps1 set [0,_ps2];
			_agntRelacoes set [_idc,_ps1];
		};
	};
	_pPerto
};

//========================================
//FUNCOES DE MOVIMENTO E ACAO - PRINCIPAIS
//========================================

//PROCURA UMA CIDADE PARA SE MOVER
_BRPVP_walkerAcao00 = {
	_agnt = _agnts select _this;
	_loc = _todosLocs call BIS_fnc_selectRandom;
	_locP = locationPosition _loc;
	_locP set [2,0];
	_ruas = [];
	_rRaio = 100;
	_rLoop = 0;
	while {count _ruas == 0} do {
		_rLoop = _rLoop + 1;				
		_ruas = _locP nearRoads (_rRaio*_rLoop);
	};
	_rua = _ruas call BIS_fnc_selectRandom;
	_locP = getPosATL _rua;
	_locP set [2,0];
	_agnt moveTo _locP;
	_agnt forceSpeed 2;
	_agntsAct set [_this,1];
	_agntsArg set [_this,[_locP,time,time]];
};

//AO ESTAR SE MOVENDO, PROCURA PLAYER POR PERTO
_BRPVP_walkerAcao01 = {
	_agnt = _agnts select _this;
	_locP = _agntsArg select _this select 0;
	_iniH = _agntsArg select _this select 1;
	_iniPP = _agntsArg select _this select 2;
	if (time - _iniPP > 0.5) then {
		if (time - _iniH > 240) then {
			_ps1 = _agntRelacoes select _this;
			_ps2 = _ps1 select 0;
			_agntRelacoes set [_this,[_ps2,[]]];
		};
		_pPerto = [_this,0] call _BRPVP_playerMaisPertoVe;
		if (!isNull _pPerto) then {
			_pPos = getPosATL _pPerto;
			_vel = 2;
			[_agnt,_pPos,_vel] call _BRPVP_moveTo;
			_agntsAct set [_this,2];
			_agntsArg set [_this,[_pPos,time,time,_vel,-1]];
		} else {
			_fim = moveToCompleted _agnt;
			if (_fim) then {
				_agntsAct set [_this,0];
				_agntsArg set [_this,-1];
			} else {
				_agntsAct set [_this,1];
				_agntsArg set [_this,[_locP,_iniH,time]];
			};
		};
	};
};

//TENTA CHEGAR A MENOS DE 10 M DO PLAYER
//DESFECHOS: DESISTE (04), CHEGA A MENOS DE 10 M (03)
_BRPVP_walkerAcao02 = {
	_agnt = _agnts select _this;
	_pPosA = _agntsArg select _this select 0;
	_iniT = _agntsArg select _this select 1;
	_dirT = _agntsArg select _this select 2;
	_vel = _agntsArg select _this select 3;
	_tFree = _agntsArg select _this select 4;
	_pPerto = [_this,(time - _iniT)/180] call _BRPVP_playerMaisPertoVe;
	if (!isNull _pPerto) then {
		_tFree = -1;
		_pPosA = getPosATL _pPerto;
	} else {
		if (_tFree == -1) then {_tFree = time;};
		_pPosA = [_pPosA,1 + random 0.5,random 360] call BIS_fnc_relPos;
	};
	if (!isNull _pPerto && _agnt distanceSqr _pPerto < 100) then {
			_aPos = getPosATL _agnt;
			[_agnt,_aPos,_vel] call _BRPVP_moveTo;
			_agntsAct set [_this,3];
			_agntsArg set [_this,[time,false,_pPerto]];
	} else {
		if (time - _iniT > 60) then {_vel = 8;};
		if !(BRPVP_agntsMusica select _this) then {
			BRPVP_agntsMusica set [_this,true];
			_nil = [_agnt,_this] spawn {
				BRPVP_tocaSom = [_this select 0,"walker",1];
				{
					if (_x distanceSqr (_this select 0) < 14400) then {
						(owner _x) publicVariableClient "BRPVP_tocaSom";
					};
				} forEach  allPlayers;
				sleep 15.9;
				BRPVP_agntsMusica set [_this select 1,false];
			};
		};
		if (time - _iniT > 180 || (_tFree != -1 && time - _tFree > 35)) then {
			_aPos = getPosATL _agnt;
			[_agnt,_aPos,_vel] call _BRPVP_moveTo;
			_agntsAct set [_this,4];
			_agntsArg set [_this,[time,10]];
		} else {
			if (time - _dirT > 2.5 || moveToCompleted _agnt) then {
				[_agnt,_pPosA,_vel] call _BRPVP_moveTo;
				_agntsAct set [_this,2];
				_agntsArg set [_this,[_pPosA,_iniT,time,_vel,_tFree]];
			};
		};
	};
};

//EXPLODE OU PREMIA
_BRPVP_walkerAcao03 = {
	_agnt = _agnts select _this;
	_tFim = _agntsConclu select _this;
	_iniT = _agntsArg select _this select 0;
	_aniR = _agntsArg select _this select 1;
	_pPerto = _agntsArg select _this select 2;
	if (_aniR) then {
		_tmp = 7;
		if (_tFim == "prem") then {_tmp = 5;};
		if (time - _iniT > _tmp) then {
			if (_tFim == "bmb") then {
				_agnt setDamage 1;
				BRPVP_giveMoney = 3000 + round random 1000;
				(owner _pPerto) publicVariableClient "BRPVP_giveMoney";
			};
			if (_tFim == "prem") then {
				_pos = getPosATL _agnt;
				_cx = createVehicle ["Box_NATO_WpsSpecial_F",_pos,[],3,"CAN_COLLIDE"];
				waitUntil {!isNull _cx};
				clearWeaponCargoGlobal _cx;
				clearMagazineCargoGlobal _cx;
				clearItemCargoGlobal _cx;
				clearBackpackCargoGlobal _cx;
				_cxIs = _agntCxIs call BIS_fnc_selectRandom;
				{_cx addWeaponCargoGlobal _x;} forEach (_cxIs select 0);
				{_cx addMagazineCargoGlobal _x;} forEach (_cxIs select 1);
				_agntsAct set [_this,4];
				_agntsArg set [_this,[time,10]];
				_cx spawn {sleep (5*60);deletevehicle _this;};
				_agnt setUnitPos "UP";
				_agnt switchMove "";
				BRPVP_giveMoney = 6000 + round random 2000;
				(owner _pPerto) publicVariableClient "BRPVP_giveMoney";
			};
		};
	} else {
		_aniR = true;
		_agnt setUnitPos "MIDDLE";
		_agntsArg set [_this,[_iniT,true,_pPerto]];
	};
};

//AGENTE DESISTE DO OBJETIVO ATUAL
_BRPVP_walkerAcao04 = {
	_agnt = _agnts select _this;
	_iniT = _agntsArg select _this select 0;
	_espT = _agntsArg select _this select 1;
	if (time - _iniT > _espT) then {
		_ps1 = _agntRelacoes select _this;
		_ps2 = _ps1 select 0;
		_agntRelacoes set [_this,[[],_ps2]];
		_agntsAct set [_this,0];
		_agntsArg set [_this,-1];
	};
};

//==========
//LOOP GERAL
//==========
_umVivo = true;
waitUntil {
	_umVivo = false;
	{
		_agnt = _x;
		_idc = _forEachIndex;
		_acao = _agntsAct select _idc;
		if (!isNull _agnt) then {
			if (alive _agnt) then {
				if (_acao == 0) then {_idc call _BRPVP_walkerAcao00;};
				if (_acao == 1) then {_idc call _BRPVP_walkerAcao01;};
				if (_acao == 2) then {_idc call _BRPVP_walkerAcao02;};
				if (_acao == 3) then {_idc call _BRPVP_walkerAcao03;};
				if (_acao == 4) then {_idc call _BRPVP_walkerAcao04;};
				_umVivo = true;
			};
		};
	} forEach _agnts;
	!_umVivo
};