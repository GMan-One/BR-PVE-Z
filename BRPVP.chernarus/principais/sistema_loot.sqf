diag_log "[BRPVP FILE] sistema_loot.sqf INITIATED";

private ["_mtdr_loot_items","_renewTime"];

//DEFINICAO DE PREDIOS COM LOOT BOM, LOOT RUIM E SEM LOOT (O RESTO E LOOT NORMAL)
_lootBom = BRPVP_mapaRodando select 13;
_lootRuim = BRPVP_mapaRodando select 14;
_lootNormal = BRPVP_mapaRodando select 15;

//DEFINE UNIDADES DE LOOT
_mtdr_loot_items_unidade = [
	//PISTOLA
	["hgun_P07_F",5,3],
	["hgun_Rook40_F",5,3],
	//SMG
	["hgun_PDW2000_F",4,3],
	["SMG_02_F",4,3],
	//RIFLES
	["arifle_Katiba_F",4,3],
	["arifle_MX_F",4,3],
	["arifle_TRG20_F",4,3],
	["arifle_Mk20_GL_F",4,3],
	["arifle_TRG21_GL_F",4,3],
	["arifle_MX_SW_F",3,3],
	//SUPRESSOR DE SOM
	"muzzle_snds_L",
	"muzzle_snds_H",
	//OTICA
	"optic_Holosight_smg",
	"optic_Holosight",
	"optic_Aco",
	"optic_ACO_grn",
	//LANTERNA ARMA
	"acc_flashlight",
	//BOLSAS DE SANGUE
	"FirstAidKit",
	"FirstAidKit",
	"FirstAidKit",
	"FirstAidKit",
	"FirstAidKit",
	//COMIDAS
	"BRP_cerveja",
	"BRP_ades",
	"BRP_cocacola",
	"BRP_bigmac",
	"BRP_lollo",
	"BRP_fanta",
	"BRP_torcida",
	"BRP_guarana",
	//CONSTRUCAO COMUM
	"BRP_kitCamuflagem",
	"BRP_kitLight",
	"BRP_kitAreia",
	//UNIFORMES
	"U_BG_Guerilla3_1",
	"U_BG_Guerilla3_2",
	"U_IG_Guerilla3_1",
	"U_IG_Guerilla3_2",
	"U_OG_Guerilla3_1",
	"U_OG_Guerilla3_2",
	//VESTS
	"V_BandollierB_blk",
	"V_BandollierB_cbr",
	"V_BandollierB_khk",
	"V_TacVest_brn",
	"V_TacVest_khk",
	"V_TacVest_blk",
	//BACKPACKS
	"B_OutdoorPack_blk",
	"B_OutdoorPack_tan",
	"B_OutdoorPack_blu",
	//SCANNERS
	"BRP_scanner_500",
	"BRP_scanner_1000",
	"BRP_scanner_1500",
	//VALVULAS
	"BRP_valvula_50",
	"BRP_valvula_75",
	"BRP_valvula_100",
	//PREMIUM BLOODBAGS
	"FirstAidKit",
	"FirstAidKit",
	"FirstAidKit",
	"FirstAidKit",
	//GOOD FOOD
	"BRP_mineirinho",
	"BRP_bife",
	"BRP_paofrances",
	"BRP_maggi",
	"BRP_goiabada",
	//ALZIRA ULTRA FOOD
	"BRP_alzira_1",
	"BRP_alzira_2",
	"BRP_alzira_3"
];

//ACHA MUNICAO DAS ARMAS
{
	if (typeName _x == "array") then {
		_class = _x select 0;
		_qt1 = _x select 1;
		_qt2 = _x select 2;
		_combinacao = [_class];
		_mags = getArray (configFile >> "CfgWeapons" >> _class >> "magazines");
		_mag = floor random (count _mags);
		for "_i" from 1 to _qt1 do {_combinacao pushBack (_mags select _mag);};
		_muzzles = getArray(configfile >> "CfgWeapons" >> _class >> "muzzles");
		{
			if (_x != "this") exitWith {
				_mags = getArray(configfile >> "CfgWeapons" >> _class >> _x >> "magazines");
				_mag = floor random (count _mags);
				for "_i" from 1 to _qt2 do {_combinacao pushBack (_mags select _mag);};
			};
		} forEach _muzzles;
		_mtdr_loot_items_unidade set [_forEachIndex,_combinacao];
		diag_log ("[BRPVP LOOT WEAPON AMMO GRENADE] " + str _combinacao);
	};
} forEach _mtdr_loot_items_unidade;	

//CODIGO EXCLUSIVO SERVIDOR
if (isServer) then {
	private ["_mtdr_loot_buildings_objs","_mtdr_lootTable_bobj","_mtdr_lootTable_item","_mtdr_lootActive","_MTDR_fnc_selectRandom"];
	if (isNil "BRPVP_loot_buildings_class") then {
		BRPVP_loot_buildings_class = [];
		BRPVP_loot_buildings_spawnPos = [];
		
		//ACHA CONSTRUCOES COM POSICOES INTERNAS
		{
			_object = _x;
			_class = typeOf _x;
			if !(_class in BRPVP_loot_buildings_class) then {
				_qt = count (_object buildingPos -1) - 1;
				BRPVP_loot_buildings_class pushBack _class;
				if (_qt >= 0) then {
					BRPVP_loot_buildings_spawnPos pushBack (floor random (_qt + 1));
				} else {
					BRPVP_loot_buildings_spawnPos pushBack -1;
				};
			};
		} forEach (BRPVP_centroMapa nearObjects ["Building",20000]);
		{if (_x == -1) then {BRPVP_loot_buildings_class set [_forEachIndex,-1];};} forEach BRPVP_loot_buildings_spawnPos;
		BRPVP_loot_buildings_class = BRPVP_loot_buildings_class - [-1];
		BRPVP_loot_buildings_spawnPos = BRPVP_loot_buildings_spawnPos - [-1];
		diag_log "======================================================";
		{diag_log _x;} forEach BRPVP_loot_buildings_class;
		diag_log "======================================================";
		{diag_log _x;} forEach BRPVP_loot_buildings_spawnPos;
		diag_log "======================================================";

		//ENVIA CONSTRUCOES E POSICOES NAS CONSTRUCOES PARA OS CLIENTES
		publicVariable "BRPVP_loot_buildings_class";
		publicVariable "BRPVP_loot_buildings_spawnPos";
	};
	diag_log ("[BRPVP] CHECK ARRAYS SIZE: BRPVP_loot_buildings_class - " + str count BRPVP_loot_buildings_class + " / BRPVP_loot_buildings_spawnPos - " + str count BRPVP_loot_buildings_spawnPos + ".");
	
	//DEFINE CONSTRUCOES PARA LOOT BOM, NORMAL E RUIM
	_lootBomN = [];
	_lootRuimN = [];
	_lootNormalN = [];
	{_lootBomN pushBack (BRPVP_loot_buildings_class find _x);} forEach _lootBom;
	{_lootRuimN pushBack (BRPVP_loot_buildings_class find _x);} forEach _lootRuim;
	{_lootNormalN pushBack (BRPVP_loot_buildings_class find _x);} forEach _lootNormal;
	_lootBomN = _lootBomN - [-1];
	_lootRuimN = _lootRuimN - [-1];
	_lootNormalN = _lootNormalN - [-1];

	//ARMAS: TIPOS
	_lstPist = [0,1];
	_lstSMG = [2,3];
	_lstRif = [4,5,6,7,8,9];
	
	//ARMAS: RUIM, NORMAL, BOM
	_slstArmasRuim = [[0.6,0.3,0.1],_lstPist,_lstSMG,_lstRif];
	_slstArmasNormal = [[0.5,0.3,0.2],_lstPist,_lstSMG,_lstRif];
	_slstArmasBom = [[0.1,0.2,0.7],_lstPist,_lstSMG,_lstRif];
	
	//ATTACH & VESTIMENTA
	_lstLant = [16];
	_lstSupr = [10,11];
	_lstOtic = [12,13,14,15];
	_lstUnif = [33,34,35,36,37,38];
	_lstVest = [39,40,41,42,43,44];
	_lstBPack = [45,46,47];
	
	//ATTACH & VESTIMENTA: RUIM, NORMAL, BOM
	_slstExtra1Ruim = [[0.3,0.2,0.2,0.15,0.15],_lstLant,_lstSupr,_lstOtic,_lstVest,_lstBPack];
	_slstExtra1Normal = [[0.25,0.2,0.2,0.2,0.15],_lstLant,_lstSupr,_lstOtic,_lstVest,_lstBPack];
	_slstExtra1Bom = [[0.05,0.1,0.25,0.2,0.4],_lstLant,_lstSupr,_lstOtic,_lstVest,_lstBPack];
	
	//HEAL & FADIGA
	_lstComid1 = [22,23,24,25,26,27,28,29];
	_lstComid2 = [58,59,60,61,62];
	_lstComid3 = [63,64,65];
	_lstSang1 = [17,18,19,20,21];
	_lstSang2 = [54,55,56,57];
	
	//HEAL & FADIGA: RUIM, NORMAL, BOM
	_slstHealRuim = [[0.8,0.2],_lstSang1,_lstSang2];
	_slstHealNormal = [[0.5,0.5],_lstSang1,_lstSang2];
	_slstHealBom = [[0.2,0.8],_lstSang1,_lstSang2];
	
	//FADIGA: RUIM, NORMAL, BOM
	_slstFadRuim = [[0.5,0.3,0.2],_lstComid1,_lstComid2,_lstComid3];
	_slstFadNormal = [[0.3,0.4,0.3],_lstComid1,_lstComid2,_lstComid3];
	_slstFadBom = [[0.2,0.3,0.5],_lstComid1,_lstComid2,_lstComid3];

	//CONSTRUCAO
	_lstConsRuim = [30,31];
	_lstConsNormal = [32];
	
	//CONSTRUCAO: RUIM, NORMAL, BOM
	_slstConsRuim = [[0.8,0.2],_lstConsRuim,_lstConsNormal];
	_slstConsNormal = [[0.6,0.4],_lstConsRuim,_lstConsNormal];
	_slstConsBom = [[0.2,0.8],_lstConsRuim,_lstConsNormal];
	
	//EQUIPAMENTOS
	_slstEquipRuim = [48,51];
	_slstEquipNormal = [49,52];
	_slstEquipBom = [50,53];
	
	//EQUIPAMENTOS: RUIM, NOMRAL, BOM
	_slstEquipRuim = [[0.8,0.1,0.1],_slstEquipRuim,_slstEquipNormal,_slstEquipBom];
	_slstEquipRuim = [[0.6,0.3,0.1],_slstEquipRuim,_slstEquipNormal,_slstEquipBom];
	_slstEquipRuim = [[0.2,0.4,0.4],_slstEquipRuim,_slstEquipNormal,_slstEquipBom];
	
	//DEFINE FATOR DE CORRECAO DO LOOT (1.0 = SEM CORRECAO)
	_xfator = BRPVP_lootMult;
	
	//DEFINE DISTRIBUICAO DO LOOT
	_pRuim = BRPVP_mapaRodando select 18 select 0;
	_pMedio = BRPVP_mapaRodando select 18 select 1;
	_pBom = BRPVP_mapaRodando select 18 select 2;
	_pUsado =  BRPVP_mapaRodando select 18 select 3;
	_mtdr_loot_items = [
		//LOOT RUIM
		[_slstArmasRuim,1*_pRuim,_lootRuimN,[],false,1],
		[_slstExtra1Ruim,1*_pRuim,_lootRuimN,[],false,1],
		[_slstEquipRuim,1*_pRuim,_lootRuimN,[],false,1],
		[_slstConsRuim,0.75*_pRuim,_lootRuimN,[],false,1],
		[_slstHealRuim,0.7*_pRuim,_lootRuimN,[],false,1],
		
		//LOOT NORMAL
		[_slstArmasNormal,1*_pMedio,_lootNormalN,[],false,1],
		[_slstExtra1Normal,1*_pMedio,_lootNormalN,[],false,1],
		[_slstHealNormal,0.7*_pMedio,_lootNormalN,[],false,1],
		[_slstEquipNormal,0.65*_pMedio,_lootNormalN,[],false,1],
		[_slstConsNormal,0.5*_pMedio,_lootNormalN,[],false,1],
		
		//LOOT BOM
		[_slstArmasBom,1*_pBom,_lootBomN,[],false,1],
		[_slstExtra1Bom,1*_pBom,_lootBomN,[],false,1],
		[_slstHealBom,0.7*_pBom,_lootBomN,[],false,1],
		[_slstEquipRuim,0.65*_pBom,_lootBomN,[],false,1],
		[_slstConsBom,0.55*_pBom,_lootBomN,[],false,1]
	];

	_qtLoot = 0;
	if (isNil "BRPVP_mtdr_lootTable_bobj") then {
		//MAPEIA TODAS AS CASAS DE LOOT
		_mtdr_loot_buildings_objs = [];
		_mtdr_loot_buildings_objs_count = [];
		_mtdr_loot_buildings_objs_useds = [];
		_numCas = 0;
		{
			_class = _x;
			_objs = BRPVP_centroMapa nearObjects [_class,20000];
			{if (typeOf _x != _class) then {_objs set [_forEachIndex,-1];};} forEach _objs;
			_objs = _objs - [-1];
			_mtdr_loot_buildings_objs pushBack _objs;
			_mtdr_loot_buildings_objs_useds pushBack [];
			_qtt = count _objs;
			diag_log (_class + " - " + str _qtt);
			_mtdr_loot_buildings_objs_count pushBack _qtt;
			_numCas = _numCas + 1;
			if (_numCas mod 5 == 0) then {
				BRPVP_serverTrabalhando = ["",BRPVP_ant + "<t size='2'>HOUSES:</tr><br/><t size='3'>" + str _numCas + "</t>"];
				PublicVariable "BRPVP_serverTrabalhando";
			};
		} forEach BRPVP_loot_buildings_class;
		BRPVP_serverTrabalhando = ["",BRPVP_ant + "<t size='2'>HOUSES:</tr><br/><t size='3'>" + str _numCas + "</t>"];
		PublicVariable "BRPVP_serverTrabalhando";

		//DISTRIBUI LOOT PELAS CASAS E GERA VARIAVEIS
		BRPVP_mtdr_lootTable_bobj = [];
		BRPVP_mtdr_lootTable_item = [];
		_mtdr_lootTable_qtt = [];
		_MTDR_fnc_selectRandom = {_index = round (random count _this - 0.5);_index};
		BRPVP_serverTrabalhando = ["",BRPVP_ant + "<t size='2'>LOOT:</tr><br/><t size='3'>0</t>"];
		PublicVariable "BRPVP_serverTrabalhando";
		{
			private ["_total","_totalB","_item"];
			for "_k" from 0 to ((count _mtdr_lootTable_qtt) - 1) do {_mtdr_lootTable_qtt set [_k,0];};
			_bExclude = [];
			for "_k" from 0 to ((count BRPVP_loot_buildings_class) - 1) do {_bExclude pushBack [];};
			_buildRepeat = _x select 5;
			_prefArray = _x select 3;
			if (count _prefArray == 0) then {{_prefArray pushBack 1;} forEach (_x select 2);};
			_total = 0;
			_totalB = 0;
			{
				_total = _total + (_mtdr_loot_buildings_objs_count select _x) * (_prefArray select _forEachIndex);
				_totalB = _totalB + (_mtdr_loot_buildings_objs_count select _x);
			} forEach (_x select 2);
			{
				_qttB = (_mtdr_loot_buildings_objs_count select _x) * (_prefArray select _forEachIndex);
				_prefArray set [_forEachIndex,(_qttB/_total) * 100];
			} forEach (_x select 2);
			_qtt = (_x select 1) * _xfator;
			if !(_x select 4) then {_qtt = _qtt * _totalB;};
			_lastChance = _qtt - floor _qtt;
			if (random 1 < _lastChance) then {_qtt = floor _qtt + 1;} else {_qtt = floor _qtt;};
			for "_i" from 1 to _qtt do {
				_bTypeIndex = 0;
				while {true} do {
					_idx = (_x select 2) call _MTDR_fnc_selectRandom;
					if (random 100 < _prefArray select _idx) exitWith {
						_bTypeIndex = (_x select 2) select _idx;
					};
				};
				if (typeName (_x select 0 select 0) == "SCALAR") then {
					_item = (_x select 0) call BIS_fnc_selectRandom;
				} else {
					_percs = _x select 0 select 0;
					_piaoDoBau = random 1;
					_acum = 0;
					_idc = 1;
					{
						if (_piaoDoBau >= _acum && _piaoDoBau < _acum + _x) exitWith {
							_idc = _forEachIndex + 1;
						};
						_acum = _acum + _x;
					} forEach _percs;
					_item = (_x select 0 select _idc) call BIS_fnc_selectRandom;
				};
				_bOptions = (_mtdr_loot_buildings_objs select _bTypeIndex) - (_bExclude select _bTypeIndex);
				_bOptionsUsed = (_mtdr_loot_buildings_objs_useds select _bTypeIndex) - (_bExclude select _bTypeIndex);
				_bOptionsCount = count _bOptions;
				for "_y" from 1 to _bOptionsCount do {
					private ["_buildObj"];
					_ok = false;
					if (random 1 > _pUsado || count _bOptionsUsed == 0) then {
						_buildObj = _bOptions call BIS_fnc_selectRandom;
					} else {
						_buildObj = _bOptionsUsed call BIS_fnc_selectRandom;
					};
					_bIndex = BRPVP_mtdr_lootTable_bobj find _buildObj;
					if (_bIndex == -1) then {
						BRPVP_mtdr_lootTable_bobj pushBack _buildObj;
						BRPVP_mtdr_lootTable_item pushBack _item;
						_mtdr_lootTable_qtt pushBack 1;
						(_mtdr_loot_buildings_objs_useds select _bTypeIndex) pushBack _buildObj;
						_ok = true;
						_qtLoot = _qtLoot + 1;
						if (_qtLoot mod 50 == 0) then {
							BRPVP_serverTrabalhando = ["",BRPVP_ant + "<t size='2'>POSITIONS:</tr><br/><t size='3'>" + str _qtLoot + "</t>"];
							PublicVariable "BRPVP_serverTrabalhando";
						};
					} else {
						_items = BRPVP_mtdr_lootTable_item select _bIndex;
						if (typeName _items != "Array") then {_items = [_items];};
						if (_buildRepeat == 0 || (_mtdr_lootTable_qtt select _bIndex < _buildRepeat)) then {
							_newPile = _items + [_item];
							BRPVP_mtdr_lootTable_item set [_bIndex,_newPile];
							_mtdr_lootTable_qtt set [_bIndex,(_mtdr_lootTable_qtt select _bIndex) + 1];
							_ok = true;
						};
					};
					if (_ok) exitWith {};
					_bExcludeNow = _bExclude select _bTypeIndex;
					_bExclude set [_bTypeIndex,_bExcludeNow + [_buildObj]];
					_bOptions = _bOptions - [_buildObj];
					_bOptionsUsed = _bOptionsUsed - [_buildObj];
				};
			};
		} forEach _mtdr_loot_items;
		
		//MAKE LOG FOR PRECALCULATED SQF
		diag_log "======================================================";
		{diag_log (ASLToAGL getPosWorld _x);} forEach BRPVP_mtdr_lootTable_bobj;
		diag_log "======================================================";
		{diag_log _x;} forEach BRPVP_mtdr_lootTable_item;
		diag_log "======================================================";

		//ENVIA LOOT TABLE PARA CLIENTES
		mtdr_lootSystemMain = [BRPVP_mtdr_lootTable_bobj,BRPVP_mtdr_lootTable_item];
		publicVariable "mtdr_lootSystemMain";
	} else {
		_qtLoot = 50 * round ((count BRPVP_mtdr_lootTable_bobj)/50);
	};
	BRPVP_serverTrabalhando = ["",BRPVP_ant + "<t size='2'>POSITIONS:</tr><br/><t size='3'>" + str _qtLoot + "</t>"];
	PublicVariable "BRPVP_serverTrabalhando";
	
	diag_log ("[BRPVP LOOT] BUILDINGS WITH LOOT: " + str count BRPVP_mtdr_lootTable_bobj + ".");
	
	//RECEBE INFORMACAO DO LOOT ATIVADO PELOS CLIENTES
	mtdr_lootActive = [];
	"mtdr_lootActiveAdd" addPublicVariableEventHandler {mtdr_lootActive pushBack (_this select 1);};
	
	//SEM COMENTARIO
	BRPVP_ant = (BRPVP_serverTrabalhando select 1) + "<br/>";

	//DELETA LOOT ABANDONADO
	[] spawn {
		private ["_time"];
		_tmpX = 60;
		_ini = time;
		waitUntil {
			_time = time;
			if (_time - _ini >= _tmpX) then {
				_ini = _time;
				diag_log ("[BRPVP ACTIVE LOOT] count mtdr_lootActive = " + str count mtdr_lootActive + ".");
				_mtdr_lootActive_remove = [];
				{
					_build = _x;
					_time = _build getVariable ["ml_used",0];
					if (BRPVP_serverTime > _time) then {
						_bPos = getPosATL _build;
						_nearP = false;
						{if (_bPos distanceSqr _x < 14400) exitWith {_nearP = true;};} forEach allPlayers;
						_waited = _build getVariable ["ml_wtd",false];
						if (!_nearP || _waited) then {
							_holder = objNull;
							_takes = 0;
							{
								_takes = _x getVariable ["ml_takes",-1];
								if (_takes >= 0) exitWith {_holder = _x;};
							} forEach ((_build buildingPos (BRPVP_loot_buildings_spawnPos select (BRPVP_loot_buildings_class find typeOf _build))) nearObjects ["groundWeaponHolder",1]);
							if ((_takes > 0 || isNull _holder) && !_waited) then {
								if (!isNull _holder) then {deleteVehicle _holder;};
								_build setVariable ["ml_used",BRPVP_serverTime + 300 - _tmpX/2,true];
								_build setVariable ["ml_wtd",true,false];
							} else {
								if (!isNull _holder) then {deleteVehicle _holder;};
								_mtdr_lootActive_remove pushBack _forEachIndex;
								_build setVariable ["ml_used",-1,true];
								_build setVariable ["ml_wtd",false,false];
							};
						};
					};
				} forEach mtdr_lootActive;
				{mtdr_lootActive deleteAt _x;} forEach _mtdr_lootActive_remove;
			};
			false
		};
	};
};
	
//CODIGO EXCLUSIVO CLIENTE
if (hasInterface) then {
	//RECEBE CONSTRUCOES E POSICOENS NAS CONSTRUCOES (RECEBE DO SERVIDOR)
	waitUntil {
		diag_log "[BRPVP LOOT] WAITING FOR PVAR...";
		!isNil "BRPVP_loot_buildings_class" && !isNil "BRPVP_loot_buildings_spawnPos"
	};

	//LOOP LOOT PLAYER
	_mtdr_loot_items_unidade spawn {
		private ["_mtdr_lootTable_bobj","_mtdr_lootTable_item","_mtdr_lootTable_bobj_local_size","_mtdr_lootTable_item_local","_time"];
		_mtdr_loot_items_unidade = _this;
		
		//PEGA CASAS COM LOOT E ITENS DE CADA CASA
		if (!isNil "BRPVP_mtdr_lootTable_bobj") then {
			_mtdr_lootTable_bobj = BRPVP_mtdr_lootTable_bobj;
			_mtdr_lootTable_item = BRPVP_mtdr_lootTable_item;
		} else {
			_mtdr_lootTable_bobj = mtdr_lootSystemMain select 0;
			_mtdr_lootTable_item = mtdr_lootSystemMain select 1;
		};
		_mtdr_pPosMain = getPosATL player;
		
		//SIZE DOS BUILDINGS COM LOOT
		_mtdr_lootTable_bobj_size = [];
		{
			_tam2 = ((sizeOf typeOf _x)/2)^2;
			_mtdr_lootTable_bobj_size pushBack _tam2;
		} forEach _mtdr_lootTable_bobj;
		
		//FUNCAO: ACHA CONSTRUCOES EM VOLTA
		_mtdr_calc_newBuilds = {
			BRPVP_mtdr_lootTable_bobj_local = [];
			_mtdr_lootTable_item_local = [];
			_mtdr_lootTable_bobj_local_size = [];
			{
				_dist = _mtdr_pPosMain distanceSqr _x;
				_items = _mtdr_lootTable_item select _forEachIndex;
				if (_dist < 15625) then {
					BRPVP_mtdr_lootTable_bobj_local pushBack _x;
					_mtdr_lootTable_bobj_local_size pushBack (_mtdr_lootTable_bobj_size select _forEachIndex);
					_mtdr_lootTable_item_local pushBack _items;
				};
			} forEach _mtdr_lootTable_bobj;
		};

		//FUNCAO: SPAWNA LOOT
		_mtdr_spawnLoot = {
			_obj = _this select 0;
			_items = _this select 1;
			if (typeName _items != "Array") then {_items = [_items];};
			_idx1 = BRPVP_loot_buildings_class find typeOf _obj;
			_spawnPosIdx = 0;
			if (_idx1 >= 0) then {
				_spawnPosIdx = BRPVP_loot_buildings_spawnPos select _idx1;
			} else {
				diag_log ("[BRPVP LOOT] House not found in BRPVP_loot_buildings_class. _idx1 == -1.");
			};
			_spawnPos = _obj buildingPos _spawnPosIdx;
			//_spawnPos set [2,(_spawnPos select 2) + 0.35];
			_holder = createVehicle ["groundWeaponHolder",_spawnPos,[],0,"CAN_COLLIDE"];
			_holder setPosATL _spawnPos;
			_holder setVariable ["ml_takes",0,true];
			{
				_itemsAll = _mtdr_loot_items_unidade select _x;
				if (typeName _itemsAll == "String") then {_itemsAll = [_itemsAll];};
				[_holder,_itemsAll] call BRPVP_addLoot;
			} forEach _items;
			mtdr_lootActiveAdd = _obj;
			publicVariableServer "mtdr_lootActiveAdd";
		};

		//INICIA CALCULANDO CONSTRUCOES DE LOOT PROXIMAS
		call _mtdr_calc_newBuilds;
		
		//MONITORA MOVIMENTO DO PLAYER PARA SPAWNAR LOOT
		_ini = time;
		waitUntil {
			_time = time;
			if (_time - _ini > 1.25) then {
				_ini = _time;
				_pOnFoot = vehicle player == player;
				if (_pOnFoot) then {
					_pPos = getPosATL player;
					_walked = _mtdr_pPosMain distanceSqr _pPos;
					if (_walked > 10000) then {
						_mtdr_pPosMain = _pPos;
						call _mtdr_calc_newBuilds;
						_walked = 0;
					};
					{
						_dist = (_pPos distanceSqr _x) - (_mtdr_lootTable_bobj_local_size select _forEachIndex);
						if (_dist <= 0) then {
							if ([player,_x] call PDTH_pointIsInBox) then {
								_bUsed = _x getVariable ["ml_used",-1];
								if (_bUsed == -1) then {
									_x setVariable ["ml_used",serverTime,true];
									_items = _mtdr_lootTable_item_local select _forEachIndex;
									[_x,_items] call _mtdr_spawnLoot;
								};
							};
						};
					} forEach BRPVP_mtdr_lootTable_bobj_local;
				};
			};
			false
		};
	};
};

diag_log "[BRPVP FILE] sistema_loot.sqf END REACHED";