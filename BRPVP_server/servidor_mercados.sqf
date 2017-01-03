//QUANTIA DE MERCADOS
BRPVP_mQt = BRPVP_mapaRodando select 2;

//QUANTIA DE ITEM ESPALHADOS PELO CHAO NOS MERCADOS
_pQt = 5;

//OBJETOS GRANDES DO MERCADO (APARECE APENAS 1)
_cargos = [
	"Land_Cargo20_blue_F",
	"Land_Cargo20_brick_red_F",
	"Land_Cargo20_cyan_F",
	"Land_Cargo20_grey_F",
	"Land_Cargo20_light_blue_F",
	"Land_Cargo20_light_green_F",
	"Land_Cargo20_military_green_F",
	"Land_Cargo20_orange_F",
	"Land_Cargo20_red_F",
	"Land_Cargo20_sand_F",
	"Land_Cargo20_white_F",
	"Land_Cargo20_yellow_F"
];

//ITENS QUE SERAO ESPALHADOS NO CHAO DO MERCADO (NAO TODOS)
_pilhas = [
	["Land_WoodenTable_small_F",1,0],
	["Land_WoodenTable_large_F",1,0],
	["Land_Pallets_stack_F",1,0],
	["Land_BakedBeans_F",10,0.65],
	["Land_Canteen_F",6,0.65],
	["Land_BottlePlastic_V2_F",10,0.5],
	["Land_RiceBox_F",10,0.8],
	["Land_Bandage_F",6,0.5],
	["Land_Defibrillator_F",6,1.5],
	["Land_DisinfectantSpray_F",10,0.65],
	["Land_ButaneCanister_F",10,0.8],
	["Land_FireExtinguisher_F",5,1.5],
	["Land_GasCanister_F",6,0.65],
	["Land_GasCooker_F",8,0.65],
	["Land_ShelvesWooden_F",1,0],
	["Land_GarbageBarrel_01_F",5,3],
	["Land_FishingGear_01_F",1,0],
	["Land_Magazine_rifle_F",10,0.8],
	["Land_Money_F",20,0.65],
	["Land_Hammer_F",8,0.65]
];

//TRADER MAN CREATION
_createTraderMan = {
	private _m = createAgent ["C_man_p_beggar_F",_this,[],12,"NONE"];
	_m allowDamage false;
	_m setCaptive true;
	_m disableAI "TARGET";
	_m disableAI "AUTOTARGET";
	_m disableAI "MOVE";
	_m disableAI "ANIM";
	_m disableAI "TEAMSWITCH";
	_m disableAI "FSM";
	_m disableAI "AIMINGERROR";
	_m disableAI "SUPPRESSION";
	_m disableAI "CHECKVISIBLE";
	_m disableAI "COVER";
	_m disableAI "AUTOCOMBAT";
	_m disableAI "PATH";
	//_wep = ["MMG_01_hex_F","MMG_01_tan_F","MMG_02_camo_F","MMG_02_black_F","MMG_02_sand_F"] call BIS_fnc_selectRandom;
	//_m addWeapon _wep;
	_m
};

//ACHA MELHOR DISTRIBUICAO DOS TRADERS
BRPVP_calcTerminou = false;
_BRPVP_achaPosTraders = {
	_maxScore = 0;
	BRPVP_terrPosArray = [];
	for "_i1" from 1 to 2000 do {
		_terrPosArrayTry = [];	
		for "_j" from 1 to BRPVP_mQt do {
			_terrPosArrayTry pushBack ((BRPVP_terrenos call BIS_fnc_selectRandom) select 0);
		};
		_scoreA = 0;
		{
			_p1 = _x;
			_idc = _forEachIndex;
			{
				if (_forEachIndex != _idc) then {
					_p2 = _x;
					_scoreA = _scoreA + (_p1 distance2D _p2);
				};			
			} forEach _terrPosArrayTry;
		} forEach _terrPosArrayTry;
		_scoreB = 0;
		_mins = [];
		{
			_p1 = _x;
			_idc = _forEachIndex;
			_min = 1000000;
			{
				if (_forEachIndex != _idc) then {
					_p2 = _x;
					_try = _p1 distance _p2;
					if (_try < _min) then {
						_min = _try;
					};
				};
			} forEach _terrPosArrayTry;
			_mins pushBack _min;
		} forEach _terrPosArrayTry;
		{_scoreB = _scoreB + abs(_x - 2000);} forEach _mins;
		_score = _scoreA/_scoreB;
		if (_score > _maxScore) then {
			BRPVP_terrPosArray = _terrPosArrayTry;
			_maxScore = _score;
		};
	};
	BRPVP_calcTerminou = true;
};
if (_calcMerc) then {
	["FIND TRADERS POSITIONS",_BRPVP_achaPosTraders] execFSM "execucaoPrioritaria.fsm";
	waitUntil {BRPVP_calcTerminou};
	diag_log ("[BRPVP TRADERS POS] " + str BRPVP_terrPosArray);
	publicVariable "BRPVP_terrPosArray";
};

//ARRAY COM OS MERCADORES
BRPVP_mercadorObjs = [];

//INICIA COLOCACAO DOS MERCADOS E MERCADORES
_objIgnora = [];
{
	private ["_trrDaVez"];
	_pos = _x;	
	
	//COLOCA OBJETO PRINCIPAL NO MERCADO
	_mMainObj = createVehicle [(_cargos call BIS_fnc_selectRandom),_pos,[],0,"CAN_COLLIDE"];
	_mMainObj setDir random 360;
	_mMainObj setVectorUp surfaceNormal position _mMainObj;
	
	//COLOCA ITENS NO CHAO DO MERCADO
	for "_i" from 0 to (_pQt-1) do {
		private ["_pPos"];
		_pilha = _pilhas call BIS_fnc_selectRandom;
		_pilhaQt = (ceil random (_pilha select 1)) max (ceil (0.3 * (_pilha select 1)));
		
		for "_k" from 1 to _pilhaQt do {
			if (_k == 1) then {
				_item = (_pilha select 0) createVehicle _pos;
				_pPos = position _item;
			} else {
				_item = createVehicle [(_pilha select 0),_pPos,[],(_pilha select 2),"CAN_COLLIDE"];
				_item setDir random 360;
				_item setVectorUp surfaceNormal position _item;
			};			
		};
		sleep 0.001;
	};
	
	//CRIAR O MERCADOR
	_mercador = _pos call _createTraderMan;
	_mercador setVariable ["mcdr",_forEachIndex,true];
	_mercador setDir ([_mMainObj,_mercador] call BIS_fnc_dirTo);
	
	//ADICIONA MERCADOR NO ARRAY DE MERCADORES
	BRPVP_mercadorObjs pushBack _mercador;
} forEach BRPVP_terrPosArray;
publicVariable "BRPVP_mercadorObjs";

//LOCAIS MERCADORES
BRPVP_mercadoresPos = [];
{
	BRPVP_mercadoresPos pushBack [position _x,60,BRPVP_mercadoresEstoque select ((_x getVariable ["mcdr",-1]) mod (count BRPVP_mercadoresEstoque)) select 1,2];
} forEach BRPVP_mercadorObjs;
publicVariable "BRPVP_mercadoresPos";

//MERCADOS VEICULOS
BRPVP_vendaveObjs = [];
{
	_local = BRPVP_terrenos select (_x select 0) select 0;
	_local set [2,0.15];
	_bunker = createVehicle ["Land_Bunker_F",_local,[],0,"CAN_COLLIDE"];
	_local set [1,(_local select 1) + 2];
	_local set [0,(_local select 0) + -6];
	_poste =  createVehicle ["Land_LampDecor_off_F",_local,[],0,"CAN_COLLIDE"];
	_local set [0,(_local select 0) + 12];
	_contato =  createVehicle ["Land_PhoneBooth_01_F",_local,[],0,"CAN_COLLIDE"];
	_bunker allowDamage false;
	_poste allowDamage false;
	_contato allowDamage false;
	_contato setVariable ["vndv",_x select 1,true];
	BRPVP_vendaveObjs pushBack _contato;
} forEach (BRPVP_mapaRodando select 16);
publicVariable "BRPVP_vendaveObjs";

//LOCAL TO PLAYER SELL ITEMS
BRPVP_buyersObjs = [];
{
	_idx = BRPVP_sellTerrainPlaces select 1 select _forEachIndex;
	_wsx = 9.65;
	_wqx = 5;
	_wqy = 4;
	_ph = BRPVP_terrenos select _x select 0;
	_h = createVehicle ["Land_GH_Gazebo_F",_ph,[],0,"CAN_COLLIDE"];
	_h setDir -5 + random 10;
	_h call BRPVP_alignObjToTerrain;
	_hd = getDir _h;
	BRPVP_buyersObjs pushBack _h;
	_ct = _h modelToWorld [0,0,0];
	_fp = _ct vectorAdd [11,0,0];
	_fp set [2,0];
	_f = createVehicle ["Land_FuelStation_Feed_F",_fp,[],0,"CAN_COLLIDE"];
	_f setDir (_hd + 90);
	_t = (getPosATL _h) call _createTraderMan;
	_t setDir ([_h,_t] call BIS_fnc_dirTo);
	_xl = _wsx * _wqx;
	_yl = _wsx * _wqy;
	_wp1 = _ct vectorAdd [-_xl,-_yl,0];
	_wp2 = _ct vectorAdd [_xl,-_yl,0];
	_wp3 = _ct vectorAdd [_xl,_yl,0];
	_wp4 = _ct vectorAdd [-_xl,_yl,0];
	_wp1 set [2,0];
	_wp2 set [2,0];
	_wp3 set [2,0];
	_wp4 set [2,0];
	_hbbx = [[-_xl,-_yl,-10],[_xl,_yl,10]];
	_h setVariable ["bbx",_hbbx,true];
	_h setVariable ["bidx",_idx,true];
	{
		_x params ["_wpa","_wpb","_d","_wq","_rem"];
		for "_s" from 0 to (2 * _wq - 1 - _rem) do {
			_vd = vectorNormalized (_wpb vectorDiff _wpa);
			_wp = _wpa vectorAdd (_vd vectorMultiply (_s * _wsx));
			_wp = _wp vectorAdd (_vd vectorMultiply (_wsx/2));
			_w = createSimpleObject ["BlockConcrete_F",(AGLToASL _wp) vectorAdd [0,0,0.6]];
			_w setDir (_d - 2.5 + random 5);
			_w call BRPVP_alignObjToTerrain;
		};
	} forEach [[_wp1,_wp2,_hd + 0,_wqx,2],[_wp2,_wp3,_hd + 90,_wqy,1],[_wp3,_wp4,_hd + 180,_wqx,2],[_wp4,_wp1,_hd + 270,_wqy,1]];
	_aroundClass = ["Land_CinderBlocks_F","Land_Bricks_V1_F","Land_Bricks_V2_F","Land_Bricks_V3_F","Land_Bricks_V4_F"];
	{
		_obj = createSimpleObject [_x,AGLToASL ([_ph,25,random 360] call BIS_fnc_relPos)];
		_obj setVectorUp (vectorNormalized ((surfaceNormal getPosATL _obj) vectorAdd [0,0,1]));
	} forEach _aroundClass;
} forEach (BRPVP_sellTerrainPlaces select 0);
publicVariable "BRPVP_buyersObjs";

//BUYERS POSITIONS
BRPVP_buyersPos = [];
{BRPVP_buyersPos pushBack [position _x,120,"",3];} forEach BRPVP_buyersObjs;
publicVariable "BRPVP_buyersPos";
