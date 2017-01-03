diag_log "[BRPVP FILE] init.sqf INITIATED";

//CODIGO A SER RODADO APENAS UMA VEZ
if (isNil "BRPVP_primeiraRodadaOk") then {
	//GET INITIAL SERVER VARS
	BRPVP_iAskForAllInitialVars = player;
	publicVariableServer "BRPVP_iAskForAllInitialVars";
	waitUntil {!isNil "BRPVP_helisObjetos"};
	
	//ACE PREFERENCE
	if (!isNil "ACE_Medical") then {
		diag_log "[ACE BRPVP] ACE MEDICAL FOUND!";
		BRPVP_reviveOn = false;
		BRPVP_hdehReturnValue = false;
	} else {
		diag_log "[ACE BRPVP] ACE MEDICAL *NOT* FOUND! USING BRPVP REVIVE.";
		BRPVP_reviveOn = true;
		BRPVP_hdehReturnValue = true;
	};
	
	//DEFINE VARIAVEIS
	BRPVP_variavies = compileFinal preprocessFileLineNumbers "principais\perSpawnVariables.sqf";
	call BRPVP_variavies;

	//IMPEDE QUE O CODIGO RODE DE NOVO
	BRPVP_primeiraRodadaOk = 1;
	
	//VARIAVEIS ONE TIME SET
	BRPVP_connectionOn = false;
	BRPVP_respawnSpot = objNull;
	BRPVP_radarConfigPool = [[0,0,5,[0,0,0]]];
	BRPVP_radarDist = 0;
	BRPVP_radarDistErr = 0;
	BRPVP_radarBeepInterval = 5;
	BRPVP_radarCenter = [0,0,0];
	BRPVP_notBlockedKeys = (actionKeys "Chat") + (actionKeys "ShowMap") + (actionKeys "HideMap") + (actionKeys "NextChannel") + (actionKeys "PrevChannel") + (actionKeys "PushToTalk") + (actionKeys "PushToTalkAll") + (actionKeys "PushToTalkCommand") + (actionKeys "PushToTalkDirect") + (actionKeys "PushToTalkGroup") + (actionKeys "PushToTalkSide") + (actionKeys "PushToTalkVehicle") + [0x32,0x01,0xD2];
	BRPVP_assignedVehicle = objNull;
	BRPVP_sellReceptacle = objNull;
	BRPVP_disabledWeapon = "";
	BRPVP_disabledDamage = 0;
	BRPVP_disabledBleed = 0;
	BRPVP_playerLastCorpse = objNull;
	BRPVP_onSiegeIcons = [];
	BRPVP_playerIsCaptive = false;
	BRPVP_indiceDebugTxt = "Main Debug!";
	BRPVP_txtIcones = "Default!";
	BRPVP_mtdr_lootTable_bobj_local = [];
	BRPVP_playerDamaged = false;
	BRPVP_fazRadarBip = false;
	BRPVP_ganchoDesvira = [];
	BRPVP_tempoUltimaAtuAmigos = 0;
	BRPVP_achaMeuStuffRodou = false;
	BRPVP_objetoMarcado = objNull;
	BRPVP_meuVeiculoNow = [];
	BRPVP_idcIconesAntes = -1;
	BRPVP_idcIcones = 0;
	BRPVP_iconesLocais = [];
	BRPVP_iconesLocaisPlayers = [];
	BRPVP_iconesLocaisAmigos = [];
	BRPVP_iconesLocaisBots = [];
	BRPVP_iconesLocaisVeiculi = [];
	BRPVP_iconesLocaisStuff = [];
	BRPVP_iconesLocaisSempre = [];
	BRPVP_experienciaZerada = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
	BRPVP_expLegenda = ["Players Killed","Deaths from Players","AIs killed","Deaths from AI","Walk Points","Eat Times","Headshots from players","Headshots on players","Headshots from AI","Headshots on AI","Constructed Items","Fall Deaths","Suicides","Destroyed Vehicles"];
	BRPVP_expLegendaSimples = ["matou_player","player_matou","matou_bot","bot_matou","andou","comeu","levou_tiro_cabeca_player","deu_tiro_cabeca_player","levou_tiro_cabeca_bot","deu_tiro_cabeca_bot","itens_construidos","queda","suicidou","matou_veiculo"];
	BRPVP_acoesClick = [];
	//FIRST ID IS THE BRPVP/BRPVE DEVELOPER
	BRPVP_admins = ["SteamID","SteamID"];
	BRPVP_indiceDebugItens = [
		"%6
		<t align='left' color='#FFFFFF'>VEH: %5</t><t align='right' color='#FFFFFF'>FPS: %7</t><br/>
		<t align='left' color='#FF3333'>LIFE:</tr><t align='right' color='#FFFFFF'>%1/100</t><br/>
		<t align='left' color='#FF3333'>MONEY: </t><t align='right' color='#FFFFFF'>%10</t><br/>
		<t align='left' color='#FF3333'>Player Menu:</t><t align='right' color='#8888FF'>alt + q</t><br/>
		<t align='left' color='#FF3333'>ZOMBIES: </t><t align='right' color='#FFFFFF'>%11 %3</t>",
		
		"<t align='left' color='#FFFFFF'>SERVER FPS:</t><t align='right' color='#8888FF'>%8</t><br/>
		<t align='left' color='#FFFFFF'>PLAYERS:</t><t align='right' color='#8888FF'>%2</t><br/><br/>
		<t align='left' color='#FF3333'>change debug:</t><t align='right' color='#8888FF'>insert</t><br/>
		<t align='left' color='#FF3333'>change map icons:</t><t align='right' color='#8888FF'>ctrl + insert</t><br/>
		<t align='left' color='#FF3333'>Player Menu:</t><t align='right' color='#8888FF'>alt + q</t><br/>
		<t align='left' color='#FF3333'>Admin Menu:</t><t align='right' color='#8888FF'>alt + e</t>",
		"<t align='left' color='#FFFFFF'>LIFE: %1/100</t><br/>
		<t align='left' color='#FFFFFF'>MONEY: %10</t>"
	];
	BRPVP_todasAnimAndando = ["amovpercmrunsnonwnondf","amovpercmrunsraswrfldf","amovpercmrunsraswpstdf","amovpercmwlksnonwnondf","amovpercmwlksraswrfldf","amovpercmwlksraswpstdf","amovpercmevasnonwnondf","amovpercmevasraswrfldf","amovpercmevasraswpstdf"];
	BRPVP_trataseDeAdmin = (getPlayerUID player) in BRPVP_admins;
	player setVariable ["nm",name player,true];
	player setVariable ["dd",-1,true];
	player setVariable ["id",getPlayerUID player,true];
	setPlayerRespawnTime 500;
	BRPVP_myStuff = [];
	BRPVP_stuff = objNull;

	//PLAYER TRAITS
	player setUnitTrait ["engineer",true];
	player setUnitTrait ["explosiveSpecialist",true];
	player setUnitTrait ["medic",true];
	
	//MISSION ROOT: http://killzonekid.com/arma-scripting-tutorials-mission-root/
	BRPVP_missionRoot = str missionConfigFile select [0, count str missionConfigFile - 15];

	//DISABLED SOUNDS
	BRPVP_disabledSoundsIdc = 0;
	BRPVP_disabledSounds = ["disabled1.ogg","disabled2.ogg","disabled3.ogg","disabled4.ogg","disabled5.ogg","disabled6.ogg","disabled7.ogg","disabled8.ogg","disabled9.ogg","disabled10.ogg","disabled11.ogg"];
	BRPVP_disabledSounds = BRPVP_disabledSounds apply {[random 1000,_x]};
	BRPVP_disabledSounds sort true;
	BRPVP_disabledSounds = BRPVP_disabledSounds apply {_x select 1};

	//GET LAST BRPVP_ownedHouses AND BRPVP SIMPLE OBJECTS VARIABLES
	BRPVP_ownedHouses = nil;
	BRPVP_ownedHousesSolicita = player;
	publicVariableServer "BRPVP_ownedHousesSolicita";
	waitUntil {!isNil "BRPVP_ownedHouses"};
	diag_log ("[BRPVP OH] BRPVP_ownedHouses = " + str BRPVP_ownedHouses + ".");
	
	//SCRIPTS
	call compile preprocessFileLineNumbers "principais\itemMarketVariables.sqf";
	call compile preprocessFileLineNumbers "principais\constructionFunctionsAndVars.sqf";
	call compile preprocessFileLineNumbers "principais\clientOnlyFunctions.sqf";
	call compile preprocessFileLineNumbers "principais\sistema_loot.sqf";
	call compile preprocessFileLineNumbers "principais\clientPublicVariableEventHandler.sqf";
	call compile preprocessFileLineNumbers "principais\playerCustomKeys.sqf";
	call compile preprocessFileLineNumbers "principais\playerMenuSystem.sqf";
	call compile preprocessFileLineNumbers "principais\clientLoop.sqf";
	call compile preprocessFileLineNumbers "principais\playerEventHandlers.sqf";
	execVM "principais\brpvp_ryanzombies.sqf";
	
	//NASCIMENTO
	BRPVP_nascimento_player = compileFinal preprocessFileLineNumbers "principais\playerFillAndSpawn.sqf";
	
	//SIEGE ICONS
	BRPVP_closedCityRunning call BRPVP_processSiegeIcons;

	//MapSingleClick MISSION EH
	BRPVP_onMapSingleClick = BRPVP_padMapaClique;
	BRPVP_onMapSingleClickExtra = {};
	addMissionEventHandler ["MapSingleClick",{
		params ["_units","_pos","_alt","_shift"];
		_comPadrao = [_alt,_pos,_shift] call BRPVP_onMapSingleClick;
		if !(_comPadrao) then {
			_comPadrao = [_alt,_pos,_shift] call BRPVP_onMapSingleClickExtra;
		};
		_comPadrao
	}];
	
	BRPVP_onAction = {
		_object = _this select 0;
		_action = _this select 3;
		_name = _this select 4;
		_isDoorA = _action find "Door" != -1 || _action find "door" != -1;
		_isDoorA = _isDoorA && {_action find "Open" != -1 || _action find "open" != -1 || _action find "Close" != -1 || _action find "close" != -1};
		_isDoorB = _name find "Door" != -1 || _name find "door" != -1;
		_isDoorB = _isDoorB && {_name find "Open" != -1 || _name find "open" != -1 || _name find "Close" != -1 || _name find "close" != -1};
		if (_action == "Rearm" || _isDoorA || _isDoorB) then {
			_canAccess = _object call BRPVP_checaAcesso;
			if !(_canAccess) then {
				["You don't have access...",3,10,677] call BRPVP_hint;
			};
			!_canAccess;
		} else {
			false;
		};
	};
	inGameUISetEventHandler ["Action","_this call BRPVP_onAction"];
	
	//MOSTRA ICONES
	[] call BRPVP_atualizaIcones;

	//EachFrame MISSION EH
	BRPVP_draw3DCount = 1;
	BRPVP_friendsIconCache = [];
	BRPVP_drawIcon3DMark = [];
	BRPVP_drawAll = true;
	addMissionEventHandler ["EachFrame",{
		if (visibleMap) then {
			call BRPVP_mapDraw;
			BRPVP_drawAll = true;
		} else {
			if (visibleGPS) then {
				if (BRPVP_draw3DCount in [2,6] || BRPVP_drawAll) then {
					call BRPVP_mapDraw;
				};
			};
			_drawIcon3D = [];
			_img = "";

			//ANTI ZOOM
			_antiZoom = 1/(call KK_fnc_trueZoom);
			
			if (BRPVP_draw3DCount == 4 || BRPVP_drawAll) then {
				_antiZoomQuad = _antiZoom^2;
				
				//ICONES DE AMIGOS NA TELA 3D CALC
				_BRPVP_meusAmigosObjMarks = [];
				_BRPVP_ignoreM = [];
				_ignore = [];
				BRPVP_friendsIconCacheSingle = [];
				BRPVP_friendsIconCacheGroup = [];
				_plyPosWld = getPosWorld player;
				{
					_unit = _x;
					if (_unit getVariable ["sok",false] && {_unit getVariable ["dd",-1] <= 0}) then {
						_pd = _unit getVariable ["pd",[]];
						_BRPVP_meusAmigosObjMarks pushBack _pd;
						if (count _pd == 0) then {_BRPVP_ignoreM pushBack _forEachIndex;};
						if !(_unit in _ignore) then {
							_pos = getPosWorld _unit;
							_dist = player distanceSqr _unit;
							_nearLimit = 0.04 * _dist * _antiZoomQuad;
							_grp = [_unit];
							{
								if (_unit distanceSqr _x < _nearLimit) then {
									_grp pushBack _x;
									_pos = _pos vectorAdd (getPosASL _x);
								};
							} forEach (BRPVP_meusAmigosObj - (_ignore + [_unit]));
							_ignore append _grp;
							_gCnt = count _grp;
							_inCombat = {_x getVariable ["cmb",false]} count _grp;
							_rgba = [1,1 - 0.8 * _inCombat/_gCnt,0.2,1];
							_pos = _pos vectorMultiply (1/_gCnt);
							_dist = player distance ASLToAGL _pos;
							_div = 1;
							_unid = "m";
							if (_dist >= 500) then {
								_div = 1000;
								_unid = "km";
							};
							_3dDist = str round (_dist/_div) + " " + _unid;
							_v1 = _pos vectorDiff _plyPosWld;
							_v2 = [0,0,10];
							_v3 = _v1 vectorCrossProduct _v2;
							_v4 = _v3 vectorCrossProduct _v1;
							_adjust = (vectorNormalized _v4) vectorMultiply (0.0315 * (_dist min BRPVP_viewDist));
							if (_gCnt == 1) then {
								_img = "BRP_imagens\icones3d\" + (if (_unit getVariable ["bdg",false]) then {"working.paa"} else {"amigo.paa"});
								BRPVP_friendsIconCacheSingle pushback [_unit,_unit getVariable "nm",_3dDist,_img,_rgba,_adjust];
							} else {
								BRPVP_friendsIconCacheGroup pushback [_grp,_gCnt,_3dDist,_rgba,_adjust];
							};
						};
					} else {
						_ignore pushBack _unit;
						_BRPVP_meusAmigosObjMarks pushBack [];
						_BRPVP_ignoreM pushBack _forEachIndex;
					};
				} forEach BRPVP_meusAmigosObj;
				
				//FRIENDS 3D MARKS
				BRPVP_drawIcon3DMark = [];
				{
					if !(_forEachIndex in _BRPVP_ignoreM) then {
						_fei = _forEachIndex;
						_pdi = _x;
						_pd = ATLToASL _x;
						_dist = player distanceSqr _x;
						_nearLimit = 0.04 * _dist * _antiZoomQuad;
						_grp = [_fei];
						{
							if !(_forEachIndex in _BRPVP_ignoreM || _forEachIndex == _fei) then {
								if (_pdi distanceSqr _x < _nearLimit) then {
									_grp pushBack _forEachIndex;
									_pd = _pd vectorAdd (ATLToASL _x);
								};
							};
						} forEach _BRPVP_meusAmigosObjMarks;
						_BRPVP_ignoreM append _grp;
						_gCnt = count _grp;
						_ni = BRPVP_countSecs mod _gCnt;
						_name = (BRPVP_meusAmigosObj select (_grp select _ni)) getVariable "nm";
						_pd = _pd vectorMultiply (1/_gCnt);
						_pd = ASLToATL _pd;
						_dist = player distance _pd;
						_div = 1;
						_unid = "m";
						if (_dist >= 500) then {
							_div = 1000;
							_unid = "km";
						};
						_3dDist = str round (_dist/_div) + " " + _unid;
						_txt = if (_gCnt == 1) then {_name + " | " + _3dDist} else {"x" + str (_cntNear + 1) + " | " + _name + " | " + _3dDist};
						BRPVP_drawIcon3DMark pushBack [BRPVP_missionRoot + "BRP_imagens\icones3d\marca_dest_amigo.paa",[1,1,1,1],_pd ,0.525,0.525,0,_txt,0,0.021];
					};
				} forEach _BRPVP_meusAmigosObjMarks;
			};
			if (BRPVP_draw3DCount == 8 || BRPVP_drawAll) then {
				BRPVP_drawIcon3DC = [];
				
				//RASTRO DE BALA
				if (BRPVP_rastroBalasLigado) then {
					_linhaIni = BRPVP_rastroPosicoes select 0;
					_distTotal = 0;
					{
						_distTotal = _distTotal + (_linhaIni distance _x);
						_txt = str round (_distTotal/100);
						_tamanho = (1/(1 + (_x distance player)/250)) max 0.15;
						_img = "BRP_imagens\icones3d\rastro.paa";
						if (terrainIntersect [ASLToAGL eyePos player,_x]) then {_img = "BRP_imagens\icones3d\rastro_pb.paa";};
						BRPVP_drawIcon3DC pushBack [BRPVP_missionRoot + _img,[1,1,1,1],_x,_tamanho/2,_tamanho/2,0,_txt,0,0.021];
						_linhaIni = _x;
					} forEach BRPVP_rastroPosicoes;
					reverse BRPVP_drawIcon3DC;
				};
			
				//SETAS PARA AMIGOS
				{[_x,_x getVariable "nm"] call BRPVP_drawSetas;} forEach BRPVP_meusAmigosObj;
				[player,player getVariable "nm"] call BRPVP_drawSetas;

				//MY 3D MARK
				_pd = player getVariable ["pd",[]];
				if (count _pd > 0) then {
					_dist = player distance _pd;
					_div = 1;
					_unid = "m";
					if (_dist >= 500) then {_div = 1000;_unid = "km";};
					_3dDist = str round (_dist/_div) + " " + _unid;
					_texto = (player getVariable "nm") + " | " + _3dDist;
					BRPVP_drawIcon3DC pushBack [BRPVP_missionRoot + "BRP_imagens\icones3d\marca_dest.paa",[1,1,1,1],_pd ,0.625,0.625,0,_texto,0,0.021];
				};
			};

			//FRIENDS 3D ICON - GROUP
			{
				_x params ["_grp","_gCnt","_3dDist","_rgba","_adjust"];
				_u = _grp select (BRPVP_countSecs mod _gCnt);
				_img = "BRP_imagens\icones3d\" + (if (_u getVariable ["bdg",false]) then {"working.paa"} else {"amigo.paa"});
				_name = _u getVariable "nm";
				_pos = [0,0,0];
				{_pos = _pos vectorAdd (getPosASLVisual _x);} forEach _grp;
				_pos = _pos vectorMultiply (1/_gCnt);
				_txt = "x" + str _gCnt + " | " + _name + " | " + _3dDist;
				_pos = _pos vectorAdd [0,0,2.25] vectorAdd (_adjust vectorMultiply _antiZoom);
				_pos = ASLToAGL _pos;
				_drawIcon3D pushBack [BRPVP_missionRoot + _img,_rgba,_pos,0.625,0.625,0,_txt,0,0.021];
			} forEach BRPVP_friendsIconCacheGroup;

			//FRIENDS 3D ICON - SINGLE
			{
				_x params ["_unit","_name","_3dDist","_img","_rgba","_adjust"];
				_pos = (getPosASLVisual _unit) vectorAdd [0,0,2.25] vectorAdd (_adjust vectorMultiply _antiZoom);
				_pos = ASLToAGL _pos;
				_txt = _name + " | " + _3dDist;
				_drawIcon3D pushBack [BRPVP_missionRoot + _img,_rgba,_pos,0.625,0.625,0,_txt,0,0.021];
			} forEach BRPVP_friendsIconCacheSingle;
			
			//GANCHO DESVIRA VEICULO
			{
				_pos = (_x select 0) vectorAdd [0,0,1];
				_dist = player distance _pos;
				if (_dist < 2500) then {
					_size = (40/_dist min 2) * (_x select 1);
					_drawIcon3D pushBack [BRPVP_missionRoot + "BRP_imagens\icones3d\gancho.paa",[1,1,1,1],_pos,2 * _size,_size,0,""];
				};
			} forEach BRPVP_ganchoDesvira;

			{drawIcon3D _x;} forEach BRPVP_drawIcon3DC;
			{drawIcon3D _x;} forEach BRPVP_drawIcon3DMark;
			{drawIcon3D _x;} forEach _drawIcon3D;
			
			if (BRPVP_drawAll) then {
				BRPVP_drawAll = false;
				BRPVP_draw3DCount = 1;
			} else {
				BRPVP_draw3DCount = BRPVP_draw3DCount + 1;
				if (BRPVP_draw3DCount == 9) then {
					BRPVP_draw3DCount = 1;
				};
			};
		};
	}];

	[] spawn {
		waitUntil {!isNull (findDisplay 12 displayCtrl 51)};
		(findDisplay 12 displayCtrl 51) ctrlAddEventHandler ["Draw",{
			_scale = ctrlMapScale (_this select 0);
			{
				private ["_rectangle"];
				if !(_x call BRPVP_IsMotorized) then {
					_isSO = _x call BRPVP_isSimpleObject;
					if (_isSO) then {
						_rectangle = [_x,"fmr",[]] call BRPVP_getVariable;
					} else {
						_rectangle = _x getVariable ["fmr",[]];
					};
					if (count _rectangle > 0) then {
						(_this select 0) drawRectangle _rectangle;
					} else {
						_color = "#(rgb,8,8,3)color(0,1,0,1)";
						if (_x getVariable ["mapa",false]) then {_color = "#(rgb,8,8,3)color(1,0,0,1)";};
						_bBox = boundingBoxReal _x;
						_xHSide = abs((_bBox select 0 select 0) - (_bBox select 1 select 0))/2;
						_yHSide = abs((_bBox select 0 select 1) - (_bBox select 1 select 1))/2;
						_rectangle = [getPosWorld _x,_xHSide,_yHSide,getDir _x,[1,1,1,1],_color];
						if (_isSO) then {
							[_x,"fmr",_rectangle,false] call BRPVP_setVariable;
						} else {
							_x setVariable ["fmr",_rectangle,false];
						};
						(_this select 0) drawRectangle _rectangle;
					};
				};
			} forEach BRPVP_myStuff;
			//if (BRPVP_radarDist > 0 && random 1 < 0.25) then {
				{
					(_this select 0) drawIcon [BRPVP_missionRoot + "BRP_imagens\icones3D\missao1.paa",[1,1,1,1],getPosASL _x,20,20,0,"",false,0.05,"puristaMedium","right"];
				} forEach BRPVP_missPrediosEm;
				{
					(_this select 0) drawIcon [BRPVP_missionRoot + "BRP_imagens\icones3d\siege.paa",[1,1,1,1],_x,30,30,0,"",false,0.05,"puristaMedium","right"];
				} forEach BRPVP_onSiegeIcons;			
				{
					if (!isNull _x) then {
						(_this select 0) drawIcon [BRPVP_missionRoot + "BRP_imagens\icones3d\corrupt.paa",[1,1,1,1],_x,35,35,_x getVariable ["dir",0],"",false,0.05,"puristaMedium","right"];
					};
				} forEach BRPVP_corruptMissIcon;
				{
					_composition = _x select 0;
					_crew = _x select 1;
					_kPaa = _x select 2;
					_color = _x select 3;
					_compositionOk = [];
					{if (canMove _x) then {_compositionOk pushBack _x;};} forEach _composition;
					_center = [0,0,0];
					{_center = _center vectorAdd getPosASL _x;} forEach _compositionOk;
					_cntC = count _compositionOk;
					if (_cntC > 0) then {_center = _center vectorMultiply (1/_cntC);};
					if (_scale < 0.15) then {
						{
							_pos = getposASL _x;
							(_this select 0) drawline [_center,_pos,[1,0,0,1]];
							(_this select 0) drawIcon [BRPVP_missionRoot + "BRP_imagens\icones3d\kveh.paa",[1,1,1,1],_pos,20,20,0,"",false,0.05,"puristaMedium","right"];
						} forEach _compositionOk;
					};
					if (_cntC == 0) then {
						_cUts = 0;
						{
							if (_x == vehicle _x && {alive _x}) then {
								_pu = getposASL _x;
								_cUts = _cUts + 1;
								_center = _center vectorAdd _pu;
							};
						} forEach _crew;
						if (_cUts > 0) then {_center = _center vectorMultiply (1/_cUts);};
					};
					if (_scale < 0.025) then {
						{
							if (_x == vehicle _x && {alive _x}) then {
								_pu = getposASL _x;
								_assignedVehicle = assignedVehicle _x;
								if (!isNull _assignedVehicle && {canMove _assignedVehicle}) then {
									(_this select 0) drawline [getPosASL _assignedVehicle,_pu,[1,0.65,0,1]];
								} else {
									(_this select 0) drawline [_center,_pu,[1,0.65,0,1]];
								};
								(_this select 0) drawIcon [BRPVP_missionRoot + "BRP_marcas\bot.paa",_color,_pu,20,20,0,"",false,0.05,"puristaMedium","right"];
							};
						} forEach _crew;
					};
					if (_center distanceSqr [0,0,0] != 0) then {
						(_this select 0) drawIcon [BRPVP_missionRoot + "BRP_imagens\icones3d\" + _kPaa,[1,1,1,1],_center,25,25,0,"Destroy",false,0.05,"puristaMedium","right"];
					};
				} forEach BRPVP_konvoyCompositions;
			//};				
		}];
	};
} else {
	//REDEFINE VARIAVEIS	
	call BRPVP_variavies;
};

//INICIA PROCESSO DE NASCIMENTO/SPAWN DO PLAYER
call BRPVP_nascimento_player;

diag_log "[BRPVP FILE] init.sqf END REACHED";
