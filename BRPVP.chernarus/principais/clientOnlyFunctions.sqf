diag_log "[BRPVP FILE] funcoes.sqf INITIATED";

BRPVP_playerCanBuild = {
	!BRPVP_construindo && !BRPVP_menuExtraLigado && !(player getVariable ["cmb",false])
};
BRPVP_radarAdd = {
	BRPVP_radarConfigPool pushBack _this;
	BRPVP_radarConfigPool sort false;
};
BRPVP_radarRemove = {
	_index = -1;
	{
		if (_this isEqualTo _x) exitWith {_index = _forEachIndex;};
	} forEach BRPVP_radarConfigPool;
	if (_index != -1) then {
		BRPVP_radarConfigPool deleteAt _index;
	};
};
BRPVP_infoMyStuff = { //NOT USING
	params ["_alt","_pos","_shift"];
	_retorno = false;
	if (player getVariable "sok") then {
		_min = 1000000;
		_BRPVP_stuff = objNull;
		{
			_dist = _pos distance2D _x;
			if (_dist < _min) then {
				_min = _dist;
				_BRPVP_stuff = _x;
			};
		} forEach BRPVP_myStuff;
		if (!isNull _BRPVP_stuff && _min < 50) then {
			_ok = [22,true] call BRPVP_iniciaMenuExtra;
			if (_ok) then {
				BRPVP_stuff = _BRPVP_stuff;
				_retorno = true;
			};
		};
	};
	_retorno
};
BRPVP_showTerrains = {
	if (!BRPVP_terrenosMapaLigado) then {
		if (!BRPVP_terrenosMapaLigadoAdmin) then {
			BRPVP_terrenosMapaLigado = true;
			["Terrains draw on map!",0] call BRPVP_hint;
			cutText ["CLICK ON THE TERRAIN TO GET MORE INFORMATION","PLAIN"];
			_addTIcons = {
				_pp = getPosATL player;
				_pp set [2,0];
				_limit = BRPVP_terrainShowDistanceLimit^2;
				BRPVP_maxTerrainShowIdc = 0;
				{
					_pos = _x select 0;
					if (_pos distanceSqr _pp < _limit) then {
						BRPVP_maxTerrainShowIdc = BRPVP_maxTerrainShowIdc + 1;
						_tam = _x select 1;
						_prc = _x select 4;
						_cor = "ColorRed";
						if (_prc >= 3 && _prc <= 4) then {_cor = "ColorYellow";};
						if (_prc >= 6 && _prc <= 9) then {_cor = "ColorGreen";};
						_marca = createMarkerLocal ["TERR_" + str BRPVP_maxTerrainShowIdc,_pos];
						_marca setMarkerShapeLocal "RECTANGLE";
						_marca setMarkerBrushLocal "SOLID";
						_marca setMarkerColorLocal _cor;
						_marca setMarkerSizeLocal [(_tam/2)*0.925,(_tam/2)*0.925];
					};
				} forEach BRPVP_terrenos;
				BRPVP_onMapSingleClickExtra = BRPVP_infoTerreno;
			};
			["ADD TERRAIN ICONS",_addTIcons,false] call BRPVP_execFast;
			[] spawn {
				waitUntil {!BRPVP_terrenosMapaLigado};
				["Terrains removed from map...",0] call BRPVP_hint;
				_removeTIcons = {for "_i" from 1 to BRPVP_maxTerrainShowIdc do {deleteMarkerLocal ("TERR_" + str _i);};};
				["REMOVE TERRAIN ICONS",_removeTIcons,false] call BRPVP_execFast;
				BRPVP_onMapSingleClickExtra = BRPVP_infoTrader;
				if (BRPVP_trataseDeAdmin) then {BRPVP_onMapSingleClick = BRPVP_adminMapaClique;} else {BRPVP_onMapSingleClick = BRPVP_padMapaClique;};
			};
		} else {
			["Turn off admin terrain view first!",6,20] call BRPVP_hint;
		};
	} else {
		BRPVP_terrenosMapaLigado = false;
		cutText ["","PLAIN"];
	};
};
LOL_fnc_showNotification = {
	params ["_endType","_mess"];
	if (_endType == "BRPVP_morreu_1") then {
		_mess params ["_name","_ofensor","_wep","_dist","_most","_mperc"];
		_txt = _name + " was killed by " + _ofensor + " with " + _wep + " from " + _dist + " m.";
		_txt = _txt + "\nMost agressor: " + _most + " with " + _mperc + ".";
		[_txt,6.5,20,1414,"radarbip"] call BRPVP_hint;
	};
	if (_endType == "BRPVP_morreu_2") then {
		_mess params ["_name","_last","_time"];
		[_name + " died!" + "\nlast attack by " + _last + ", " + _time + " seconds ago!",5,20,1414,"radarbip"] call BRPVP_hint;
	};
	if (_endType == "BRPVP_morreu_3") then {
		_mess params ["_name"];
		[_name + " died!",3.5,15,1414,"radarbip"] call BRPVP_hint;
	};
};
BRPVP_actionSellClose = {
	_sr = BRPVP_sellReceptacle;
	_srIdx = _sr getVariable "bidx";
	
	_armas = [[],[]];
	_magas = magazinesAmmoCargo _sr;
	_mochi = getBackpackCargo _sr;
	_itens = getItemCargo _sr;
	_conts = everyContainer _sr;
	_weaponsItemsCargo = weaponsItemsCargo _sr;

	clearWeaponCargoGlobal _sr;
	clearMagazineCargoGlobal _sr;
	clearBackpackCargoGlobal _sr;
	clearItemCargoGlobal _sr;

	{_weaponsItemsCargo = _weaponsItemsCargo + (weaponsItemsCargo (_x select 1));} forEach _conts;
	{
		_arma = _x;
		{
			if (_forEachIndex == 0) then {
				_armas = [_armas,_x call BIS_fnc_baseWeapon] call BRPVP_adicCargo;
			} else {
				if (typeName _x == "ARRAY") then {if (count _x > 0) then {_magas append [_x];};};
				if (typeName _x == "STRING") then {if (_x != "") then {_itens = [_itens,_x] call BRPVP_adicCargo;};};
			};
		} forEach _arma;
	} forEach _weaponsItemsCargo;
	{
		_cont = _x select 1;
		_magas append magazinesAmmoCargo _cont;
		_itensC = getItemCargo _cont;
		{
			_qt = _itensC select 1 select _forEachIndex;
			for "_i" from 1 to _qt do {_itens = [_itens,_x] call BRPVP_adicCargo;};
		} forEach (_itensC select 0);
	} forEach _conts;

	_estadoVault = [
		getPlayerUID player,
		[_armas,_magas,_mochi,_itens],
		_sr getVariable ["stp",1]
	];

	_estadoPlayer = if (_this) then {player call BRPVP_pegaEstadoPlayer} else {[]};
	BRPVP_salvaPlayerVault = [_estadoPlayer,[_estadoVault,_srIdx]];
	publicVariableServer "BRPVP_salvaPlayerVault";

	{
		detach _x;
		deleteVehicle _x;
	} forEach (attachedObjects _sr);
	deleteVehicle _sr;

	BRPVP_sellStage = 5;
};
BRPVP_buyersPlace = {
	private ["_actBuyers"];
	_hs = nearestObjects [player,["Land_GH_Gazebo_F"],200];
	_h = _hs select 0;
	_actBuyers1 = -1;
	_actBuyers2 = -1;
	_srIdx = _h getVariable ["bidx",-1];
	BRPVP_sellInCourtyard = false;
	BRPVP_sellStage = 0;
	waitUntil {
		waitUntil {
			BRPVP_sellInCourtyard = [player,_h] call PDTH_pointIsInBox;
			!(BRPVP_inBuyersPlace == _this) || BRPVP_sellInCourtyard
		};
		if (BRPVP_sellInCourtyard) then {
			BRPVP_sellStage = 1;
			_v = vehicle player;
			if (_v != player && {driver _v == player && {fuel _v < 0.9 && {_v call BRPVP_checaAcesso}}}) then {
				_v setFuel 1;
				["Fuel set to 100%",0] call BRPVP_hint;
			};
			_actBuyers1 = player addAction [("<t color='#00BB00'>Open Sell Receptacle</t>"),"actions\actionSell.sqf",_srIdx,100,true];
			waitUntil {
				BRPVP_sellInCourtyard = [player,_h] call PDTH_pointIsInBox;
				!BRPVP_sellInCourtyard || BRPVP_sellStage == 2
			};
			player removeAction _actBuyers1;
			if (BRPVP_sellStage == 2) then {
				_actBuyers2 = player addAction [("<t color='#FF0000'>Apply Sell</t>"),"actions\actionSellApply.sqf",[],100,true];
				waitUntil {!(BRPVP_inBuyersPlace == _this) || BRPVP_sellStage in [3,4,5]};
				player removeAction _actBuyers2;
				if (BRPVP_sellStage in [3,4,5]) then {
					if (BRPVP_sellStage == 3) then {
						waitUntil {BRPVP_sellStage == 4};
						BRPVP_sellStage = 0;
					} else {
						BRPVP_sellStage = 0;
					};
				} else {
					true call BRPVP_actionSellClose;
					waitUntil {BRPVP_sellStage == 5};
					BRPVP_sellStage = 0;
				};
			} else {
				BRPVP_sellStage = 0;
			};
		};
		!(BRPVP_inBuyersPlace == _this)
	};
};
BRPVP_hideObject = {
	BRPVP_hideObjectSv = _this;
	publicVariableServer "BRPVP_hideObjectSv";	
};
BRPVP_processSiegeIcons = {
	_BRPVP_onSiegeIcons = [];
	{
		if (_x == 2) then {
			_BRPVP_onSiegeIcons pushBack (BRPVP_locaisImportantes select _forEachIndex select 0);
		};
	} forEach _this;
	BRPVP_onSiegeIcons = _BRPVP_onSiegeIcons;
};
BRPVP_soundHelipads = [];
BRPVP_playHelipadSound = {
	params ["_obj","_snd","_dist"];
	/*
	_ihp = "Land_HelipadEmpty_F" createVehicleLocal [0,0,0];
	_ihp setVariable ["brn",time,false];
	BRPVP_soundHelipads pushBack _ihp;
	_ihp attachTo [_obj,[0,0,0]];
	_ihp say [_snd,_dist];
	*/
	_obj say [_snd,_dist];
};
BRPVP_playSoundAllCli = {
	BRPVP_tocaSom = _this;
	publicVariable "BRPVP_tocaSom";
	_this call BRPVP_playHelipadSound;
};
BRPVP_mudaExp = {
	//CHECA SE EXISTE A VARIAVEL DE OBJETO exp NO PLAYER
	_atual = player getVariable "exp";
	
	//ATUALIZA ESTATISTICAS DO PLAYER
	_mudanca = + BRPVP_experienciaZerada;
	_mudou = false;
	{
		_tipo = _x select 0;
		_valor = _x select 1;
		_idc = BRPVP_expLegendaSimples find _tipo;
		if (_idc >= 0) then {
			_mudanca set [_idc,(_mudanca select _idc) + _valor];
			_mudou = true;
		};
	} forEach _this;
	if (_mudou) then {
		{_atual set [_forEachIndex,(_atual select _forEachIndex) + _x];} forEach _mudanca;
		player setVariable ["exp",_atual,true];
	};
};
BRPVP_hintHistoricTime = [];
BRPVP_hint = {
	params ["_msg",["_time",0],["_limitPlus",200],["_mshare",0],["_snd","hint"]];
	if (_time == 0) then {
		5 cutText ["\n\n\n\n" + _msg,"PLAIN",5/10,true];
		if (_snd != "") then {playSound _snd;};
	} else {
		_limit = time + _limitPlus;
		_time = _time/10;
		BRPVP_hintHistorico pushBack [["\n" + _msg,"PLAIN DOWN",_time,true],_snd,_limit,_mshare];
	};
};
[] spawn {
	_timeLock = 0;
	_lmshare = 0;
	waitUntil {
		if (count BRPVP_hintHistorico > 0) then {
			_timeNow = time;
			_case = BRPVP_hintHistorico select 0;
			_mshare = _case select 3;
			if (_timeNow >= _timeLock || (_mshare == _lmshare && _mshare != 0)) then {
				_msg = _case select 0;
				_snd = _case select 1;
				_limit = _case select 2;
				_lmshare = _mshare;
				if (_timeNow <= _limit) then {
					_timeLock = _timeNow + (_msg select 2) * 10;
					10 cutText _msg;
					if (_snd != "") then {playSound _snd;};
				};
				BRPVP_hintHistorico deleteAt 0;
			};
		};
		false
	};
};
BRPVP_adicionaIconeLocal = {
	params ["_ambito","_iName","_iObj","_iColor","_iText","_iType","_iRaioIdc"];
	
	//CRIA ICONE
	_icone = createMarkerLocal [_iName,BRPVP_posicaoFora];
	_icone setMarkerShapeLocal "Icon";
	_icone setMarkerTypeLocal _iType;
	_icone setMarkerColorLocal _iColor;
	_icone setMarkerTextLocal _iText;
	
	//INSERE ICONE NOS ARRAYS DE ICONES
	if (_ambito == "players") then {
		BRPVP_iconesLocaisPlayers append [[_iName,_iObj]];
	};
	if (_ambito == "geral") then {
		BRPVP_iconesLocais append [[_iName,_iObj]];
	};
	if (_ambito == "amigos") then {
		BRPVP_iconesLocaisAmigos append [[_iName,_iObj]];
	};
	if (_ambito == "bots") then {
		BRPVP_iconesLocaisBots append [[_iName,_iObj]];
	};
	if (_ambito == "veiculi") then {
		BRPVP_iconesLocaisVeiculi append [[_iName,_iObj]];
	};
	if (_ambito == "mastuff") then {
		BRPVP_iconesLocaisStuff append [[_iName,_iObj]];
	};
	if (_ambito == "sempre") then {
		BRPVP_iconesLocaisSempre append [[_iName,_iObj]];
	};
};
BRPVP_removeTodosIconesLocais = {
	//REMOVE ICONES DE TODOS OS TIPOS
	if (_this == "players") then {
		{deleteMarkerLocal (_x select 0);} forEach BRPVP_iconesLocaisPlayers;
		BRPVP_iconesLocaisPlayers = [];
	};
	if (_this == "geral") then {
		{deleteMarkerLocal (_x select 0);} forEach BRPVP_iconesLocais;
		BRPVP_iconesLocais = [];
	};
	if (_this == "amigos") then {
		{deleteMarkerLocal (_x select 0);} forEach BRPVP_iconesLocaisAmigos;
		BRPVP_iconesLocaisAmigos = [];
	};
	if (_this == "bots") then {
		{deleteMarkerLocal (_x select 0);} forEach BRPVP_iconesLocaisBots;
		BRPVP_iconesLocaisBots = [];
	};
	if (_this == "veiculi") then {
		{deleteMarkerLocal (_x select 0);} forEach BRPVP_iconesLocaisVeiculi;
		BRPVP_iconesLocaisVeiculi = [];
	};
	if (_this == "mastuff") then {
		{deleteMarkerLocal (_x select 0);} forEach BRPVP_iconesLocaisStuff;
		BRPVP_iconesLocaisStuff = [];
	};
	if (_this == "sempre") then {
		{deleteMarkerLocal (_x select 0);} forEach BRPVP_iconesLocaisSempre;
		BRPVP_iconesLocaisSempre = [];
	};
};	
BRPVP_escolheModaPlayer = {
	//NUDA PLAYER (TIRA TUDO DELE)
	{player removeMagazine _x;} forEach  magazines player;
	{player removeWeapon _x;} forEach weapons player;
	{player removeItem _x;} forEach items player;
	removeAllAssignedItems player;
	removeBackpackGlobal player;
	removeUniform player;
	removeVest player;
	removeHeadGear player;
	removeGoggles player;
	
	//VESTE PLAYER CASO PARAMETRO SEJA TRUE
	if (_this) then {
		//BANCO DE MODA
		_uniformes = ["U_O_CombatUniform_ocamo","U_O_CombatUniform_oucamo","U_O_SpecopsUniform_ocamo","U_O_SpecopsUniform_blk","U_O_OfficerUniform_ocamo"];
		_vestimentas = ["V_BandollierB_blk","V_BandollierB_cbr","V_BandollierB_khk","V_BandollierB_oli","V_BandollierB_rgr"];
		_caps = ["H_Bandanna_mcamo","H_Bandanna_surfer","H_Hat_blue","H_Hat_tan","H_StrawHat_dark","H_Bandanna_surfer_grn","H_Cap_surfer"];
		_oculosTipos = ["G_Squares","G_Diving"];
		
		//ESCOLHE MODA
		_moda = floor random (50 + 1);
		_uniforme = _uniformes select (_moda mod count _uniformes);
		_vestimenta = _vestimentas select (_moda mod count _vestimentas);
		_cap = _caps select (_moda mod count _caps);
		_oculos = _oculosTipos select (_moda mod count _oculosTipos);
		
		//APLICA MODA
		player forceAddUniform _uniforme;
		player addVest _vestimenta;
		if (_moda mod 5 != 0) then {player addHeadGear _cap;};
		if (_moda mod 5 == 0) then {player addGoggles _oculos;};
	};
};
BRPVP_pegaEstadoPlayer = {
	//ARMAS (P,S,G)
	_armaPriNome = primaryWeapon _this;
	_armaSecNome = secondaryWeapon _this;
	_armaGunNome = handGunWeapon _this;
	
	//ARMAS ASSIGNED
	_aPI = primaryWeaponItems _this;
	_aSI = secondaryWeaponItems _this;
	_aGI = handGunItems _this;
	
	//CONTAINERS
	_backPackName = backpack _this;
	_vestName = vest _this;
	_uniformName = uniform _this;
	
	//APETRECHOS
	_capacete = headGear _this;
	_oculos = goggles _this;
	
	//SAUDE
	_hpd = getAllHitPointsDamage _this;

	//PLAYERS CONTAINERS
	_bpc = backpackContainer _this;
	_vtc = vestContainer _this;
	_ufc = uniformContainer _this;
	
	//PLAYERS CONTAINERS MAGAZINES AMMO
	if (!isNull _bpc) then {_bpc = magazinesAmmoCargo _bpc;} else {_bpc = [];};
	if (!isNull _vtc) then {_vtc = magazinesAmmoCargo _vtc;} else {_vtc = [];};
	if (!isNull _ufc) then {_ufc = magazinesAmmoCargo _ufc;} else {_ufc = [];};
	
	//ESTADO PLAYER
	_BRPVP_salvaPlayer = [
		//ID DO PLAYER
		getPlayerUID _this,
		//ARMAS E ASSIGNED ITEMS
		[
			assignedItems _this,
			[_armaPriNome,_aPI,primaryWeaponMagazine _this],
			[_armaSecNome,_aSI,secondaryWeaponMagazine _this],
			[_armaGunNome,_aGI,handGunMagazine _this]
		],
		//CONTAINERS (BACKPACK, VEST, UNIFORME)
		[
			[_backpackName,[getWeaponCargo backpackContainer _this,getItemCargo backpackContainer _this,_bpc]],
			[_vestName,[getWeaponCargo vestContainer _this,getItemCargo vestContainer _this,_vtc]],
			[_uniformName,[getWeaponCargo uniformContainer _this,getItemCargo uniformContainer _this,_ufc]]
		],
		//DIRECAO E POSICAO
		[getDir _this,getPosWorld _this],
		//SAUDE
		[[_hpd select 1,_hpd select 2],[BRPVP_alimentacao,100],damage _this],
		//MODELO E APETRECHOS
		[typeOf _this,_capacete,_oculos],
		//ARMA NA MAO
		currentWeapon _this,
		//AMIGOS
		_this getVariable "amg",
		//VIVO OU MORTO
		if (alive _this) then {1} else {0},
		//EXPERIENCIA
		_this getVariable "exp",
		//DEFAULT SHARE TYPE
		_this getVariable "dstp",
		//ID BD
		_this getVariable "id_bd",
		//MONEY
		_this getVariable "mny",
		//SPECIAL ITEMS
		_this getVariable "sit"
	];
	_BRPVP_salvaPlayer
};
BRPVP_ligaModoSeguro = {
	if (BRPVP_ligaModoSeguroQt == 0) then {
		if (_this) then {["You are in a safezone.",2.5,6.5,786] call BRPVP_hint;};
		BRPVP_ehNaoAtira = true;
		player allowDamage false;
		player setCaptive true;
		player setVariable ["umok",false,true];
		if (BRPVP_safeZone) then {
			_veiculo = vehicle player;
			if (_veiculo != player) then {if (local _veiculo) then {_veiculo allowDamage false;};};
		};
	};
	BRPVP_ligaModoSeguroQt = BRPVP_ligaModoSeguroQt + 1;
};
BRPVP_desligaModoSeguro = {
	private ["_humanos"];
	BRPVP_ligaModoSeguroQt = BRPVP_ligaModoSeguroQt - 1;
	if (BRPVP_ligaModoSeguroQt == 0) then {
		if (_this) then {["You left the safezone.",2.5,6.5,786] call BRPVP_hint;};
		BRPVP_ehNaoAtira = false;
		player allowDamage true;
		player setCaptive false;
		player setVariable ["umok",true,true];
		if (BRPVP_safeZone) then {
			_veiculo = vehicle player;
			if (_veiculo != player) then {if (local _veiculo) then {_veiculo allowDamage true;};};
		};
		_humanos = player nearEntities ["CAManBase",150];
		{if (!isPlayer _x) then {_x reveal [player,1.5];};} forEach _humanos;
	};
};
BRPVP_funcaoMinDist = {
	private ["_raioB","_dist","_minDist","_maisPerto","_posA","_posB","_raioA"];
	_posA = _this select 0;
	_minDist = 1000000;
	{
		if !(_forEachIndex in BRPVP_dentroDe) then {
			_posB = _x select 0;
			_raioB = _x select 1;
			_dist = (_posA distance _posB) - _raioB;
			if (_dist < _minDist && _dist > 1 - _raioB) then {_minDist = _dist;_maisPerto = _forEachIndex;};
		};
	} forEach (_this select 1);
	_maisPerto
};
BRPVP_arred = {
	private ["_valor","_fator"];
	_valor = _this select 0;
	_fator = 10^(_this select 1);
	(floor(_valor*_fator))/_fator
};
BRPVP_efeitosSaude = {
	private ["_tipo","_dano"];
	_males = _this;
	_txt = "";
	if ("fome" in _males) then {
		_dano = 0.025 * BRPVP_multiplicadorDanoAdmin;
		player setDamage ((damage player) + _dano);
		_txt = _txt + "hungry... ";
	};
	if ("fomeBraba" in _males) then {
		_dano = 0.050 * BRPVP_multiplicadorDanoAdmin;
		player setDamage ((damage player) + _dano);
		_txt = _txt + "starving! ";
	};
	if (_txt != "") then {
		["You are " + _txt,2,10] call BRPVP_hint;
	};
};
BRPVP_curaPlayer = {
	if (alive player) then {
		player setDamage 0;
		BRPVP_alimentacao = 105;
		player setVariable ["sud",[round BRPVP_alimentacao,100],true];
		["You were healed!",2,6.5] call BRPVP_hint;
		playsound "heal";
	};
};
BRPVP_aceleraPara = {
	_tempo = time;
	_param = BRPVP_paraParam select 0;
	if (_this == "subir") then {_param = BRPVP_paraParam select 1;};
	waitUntil {
		_qps = diag_fps;
		_qpsFator = 15/_qps;
		_para = vehicle player;
		_vel = velocity _para;
		_velMag = vectorMagnitude _vel;
		_paraDir2D = vectorDir _para;
		_paraDir2D set [2,0];
		_paraDir2DNrm = vectorNormalized _paraDir2D;
		_vel2D = + _vel;
		_vel2D set [2,0];
		_vel2DMag = vectorMagnitude _vel2D;
		_ang = acos (_paraDir2D vectorCos [0,1,0]);
		if (_paraDir2D select 0 < 0) then {_ang = 360 - _ang;};
		_velAmigo = [_vel2DMag * sin _ang,_vel2DMag * cos _ang,_vel select 2];
		_aVecDir = _paraDir2DNrm vectorMultiply ((_param select 0) * _velMag * _qpsFator);
		_aVecZ = (vectorNormalized [0,0,_param select 1]) vectorMultiply abs((_param select 1) * _velMag * _qpsFator);
		_velNovo = (_velAmigo vectorAdd _aVecDir) vectorAdd _aVecZ;
		_para setVelocity _velNovo;
		time - _tempo > 0.25 || isNil "BRPVP_nascendoParaQuedas"
	};
	BRPVP_aceleraParaRodando = false;
};
BRPVP_infoTerreno = {
	params ["_alt","_pos","_shift"];
	if (!_shift && !_alt) then {
		{
			_cnt = _x select 0;
			_tam = _x select 1;
			if (abs((_pos select 0)-(_cnt select 0)) < _tam/2 && abs((_pos select 1)-(_cnt select 1)) < _tam/2) then {
				_ang = _x select 2;
				_livre = _x select 3;
				_qualidade = _x select 4;
				_prc = (_qualidade*(_tam/45)^2)*(20000/9); //IMPORTANTE
				_prcTxt = (str round (_prc/1000))+"K  $";
				_txt = "TERRAIN NUMBER: " + str _forEachIndex;
				_txt = _txt + "\nSIZE: " + str _tam + " X " + str _tam;
				_txt = _txt + "\nSLOPE: " + str round _ang + " degrees";
				_txt = _txt + "\n OBJECTS: " + str round _livre;
				_txt = _txt + "\nQUALITY: " + str _qualidade + "/9 points";
				//_txt = _txt + "\nPRICE: " + _prcTxt;
				cutText [_txt,"PLAIN"];
			};
		} forEach BRPVP_terrenos;
		true
	} else {
		false
	};
};
BRPVP_infoTrader = {
	params ["_alt","_pos","_shift"];
	private ["_idc","_retorno"];
	_retorno = false;
	if (!_shift && !_alt) then {
		{
			_centro = _x select 0;
			_raio = _x select 1;
			if (_pos distance2D _centro <= _raio) then {
				_mercador = BRPVP_mercadorObjs select _forEachIndex;
				_idc = _mercador getVariable ["mcdr",-1];
				if (_idc != -1) then {
					_loja = BRPVP_mercadoresEstoque select (_idc mod (count BRPVP_mercadoresEstoque)) select 0;
					_txt = "";
					{_txt = _txt + (BRPVP_mercadoNomes select _x) + "\n";} forEach _loja;
					cutText [_txt,"PLAIN",1];
					_retorno = true;
				};
			};
		} forEach BRPVP_mercadoresPos;
	};
	_retorno
};
BRPVP_padMapaClique = {
	params ["_alt","_pos","_shift"];
	if (_shift && !_alt) then {
		_pos2 = _pos apply {(round(_x * 10))/10};
		player setVariable ["pd",_pos2,true];
	};
	false
};
BRPVP_adminMapaClique = {
	params ["_alt","_pos","_shift"];
	if (_shift && !_alt) then {
		_pos2 = _pos apply {(round(_x * 10))/10};
		player setVariable ["pd",_pos2,true];
	};
	if (_alt && !_shift) exitWith {
		(vehicle player) setPos _pos;
		openMap false;
		true
	};
	false
};
BRPVP_nascMapaClique = {
	params ["_alt","_pos","_shift"];
	private ["_respawnPos"];
	if (_shift && !_alt) then {
		_pos2 = _pos apply {(round(_x * 10))/10};
		player setVariable ["pd",_pos2,true];
	};
	if (!_shift && !_alt) then {
		if (!isNull BRPVP_respawnSpot && {_pos distance2D BRPVP_respawnSpot < 50}) then {
			BRPVP_posicaoDeNascimento = ["ground",getPos BRPVP_respawnSpot];
		} else {
			if (BRPVP_vePlayers) then {
				BRPVP_posicaoDeNascimento = ["ground",_pos];
			} else {
				_posOk = false;
				_liberado = false;
				{
					_bdi = _x select 0;
					_raio = _x select 1;
					_posOk = _pos distance2D _bdi < _raio;
					if (_posOk) exitWith {
						_respawnPos = _bdi;
						_liberado = time > (BRPVP_temposLocais select _forEachIndex);
					};
				} forEach BRPVP_locaisImportantes;
				cutText ["","PLAIN",1];
				if (!_posOk) then {
					playSound "erro";
					15 cutText ["You can't spawn on this position!\nSelect an orange area!","PLAIN",0.5,true];
				} else {
					if (_liberado) then {
						BRPVP_posicaoDeNascimento = ["air",_respawnPos];
					} else {
						playSound "erro";
						15 cutText ["This local is locked.\nWait for the count down to finish!","PLAIN",0.5,true];
					};
				};
			};
		};
	};
	false
};
BRPVP_usouSangue = {
	BRPVP_transfu = true;
	_this spawn {
		playSound "coracao";
		_minDam = _this;
		_start = time;
		_stamina = getStamina player;
		player setStamina 0;
		waitUntil {time - _start > 8};
		["Life was restored in " + str ((1-_minDam)*100)+ " %.",3.5,6.5] call BRPVP_hint;
		_hpd = getAllHitPointsDamage player;
		_dam = damage player;
		player setDamage 0;
		{
			_hit = _hpd select 2 select _forEachIndex;
			player setHit [_x,_minDam min (_dam + _hit - _dam * _hit)];
		} forEach (_hpd select 1);
		player setStamina _stamina;
		BRPVP_transfu = false;
	};
};
BRPVP_ligaRadio = {
	BRPVP_tocandoRadio = true;
	_this spawn {
		for "_x" from 1 to (_this select 2) do {
			player say [(_this select 0),1];
			BRPVP_tocaSom = [player,(_this select 0),1];
			publicVariable "BRPVP_tocaSom";
			uiSleep (_this select 1);
		};
		BRPVP_tocandoRadio = false;
	};
};
BRPVP_ligaModoCombate = {
	BRPVP_ultimoCombateTempo = time;
	if !(player getVariable ["cmb",false]) then {
		player setVariable ["cmb",true,true];
		_nil = [] spawn {
			waitUntil {
				_fim = BRPVP_ultimoCombateTempo + 45;
				time >= _fim || !alive player
			};
			player setVariable ["cmb",false,true];
		};
	};
};
BRPVP_atualizaIconesSpawn = {
	["geral"] call BRPVP_atualizaIcones;
	"veiculi" call BRPVP_removeTodosIconesLocais;
	"bots" call BRPVP_removeTodosIconesLocais;
};
BRPVP_atualizaIcones = {
	if ("veiculi" in _this || count _this == 0) then {
		//ICONES VEICULOS: CARROS PLAYER, HELIS PLAYER
		"veiculi" call BRPVP_removeTodosIconesLocais;
		{["veiculi","PCAR_" + str _forEachIndex,_x,"ColorGreen","L","mil_dot"] call BRPVP_adicionaIconeLocal;} forEach BRPVP_carrosObjetos;
		{["veiculi","PHEL_" + str _forEachIndex,_x,"ColorGreen","H","mil_dot"] call BRPVP_adicionaIconeLocal;} forEach BRPVP_helisObjetos;
	};
	if ("players" in _this || count _this == 0) then {
		//ICONES PLAYERS
		"players" call BRPVP_removeTodosIconesLocais;
		{["players","PLAYERS_" + str _forEachIndex,_x,"ColorRed","","mil_dot"] call BRPVP_adicionaIconeLocal;} forEach allPlayers;
	};
	if ("bots" in _this || count _this == 0) then {
		//ICONES BOTS: SOLDADOS, REVOLTOSOS, BLINDADOS, WALKERS, HELIS
		"bots" call BRPVP_removeTodosIconesLocais;
		{["bots","BOT_" + str _forEachIndex,_x,"ColorRed","","mil_dot"] call BRPVP_adicionaIconeLocal;} forEach BRPVP_bots;
		{["bots","REV_" + str _forEachIndex,_x,"ColorRed","","mil_dot"] call BRPVP_adicionaIconeLocal;} forEach BRPVP_revoltosos;
		{["bots","BLINDERS_" + str _forEachIndex,_x,"ColorBlue","","mil_dot"] call BRPVP_adicionaIconeLocal;} forEach BRPVP_unidBlindados;
		{["bots","WKR_" + str _forEachIndex,_x,"ColorOrange","","mil_dot"] call BRPVP_adicionaIconeLocal;} forEach BRPVP_walkersObj;
		{["bots","BUAI_" + str _forEachIndex,_x,"ColorRed","","mil_dot"] call BRPVP_adicionaIconeLocal;} forEach BRPVP_missBotsEm;
	};
	if ("mastuff" in _this || count _this == 0) then {
		//ICONES DO STUFF DO PLAYER
		"mastuff" call BRPVP_removeTodosIconesLocais;
		{
			if (_x call BRPVP_isMotorized) then {
				["mastuff","STUFF_" + str _forEachIndex,_x,"ColorYellow",getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName"),"mil_box"] call BRPVP_adicionaIconeLocal;
			};
		} forEach BRPVP_myStuff;
	};
	if ("geral" in _this || count _this == 0) then {
		//ICONES GERAL: PLAYER, CORPO
		"geral" call BRPVP_removeTodosIconesLocais;
		{["geral","PMORTO_" + str _forEachIndex,_x,"ColorYellow","Body","mil_dot"] call BRPVP_adicionaIconeLocal;} forEach BRPVP_meuAllDead;
		{["geral","LOCAL_PLAYER",_x,"ColorYellow","","mil_start"] call BRPVP_adicionaIconeLocal;} forEach [player];
		{["geral","RESPAWN_SPOT",_x,"ColorOrange","","mil_end"] call BRPVP_adicionaIconeLocal;} forEach [BRPVP_respawnSpot];
	};
	if ("sempre" in _this || count _this == 0) then {
		//ICONES SEMPRE: TRADERS, COLLECTORS
		"sempre" call BRPVP_removeTodosIconesLocais;
		{["sempre","MERCADORES_" + str _forEachIndex,_x,"ColorPink",BRPVP_mercadoresEstoque select ((_x getVariable ["mcdr",-1]) mod (count BRPVP_mercadoresEstoque)) select 1,"mil_triangle"] call BRPVP_adicionaIconeLocal;} forEach BRPVP_mercadorObjs;
		{["sempre","VENDAVE_" + str _forEachIndex,_x,"ColorWhite",(_x getVariable ["vndv",["CIVIL"]]) select 0,"mil_triangle"] call BRPVP_adicionaIconeLocal;} forEach BRPVP_vendaveObjs;
		{["sempre","BUYERS_" + str _forEachIndex,_x,"ColorWhite","Collectors " + str (_forEachIndex + 1),"mil_triangle"] call BRPVP_adicionaIconeLocal;} forEach BRPVP_buyersObjs;
	};
	//BRPVP_fazRadarBip = true;
};
BRPVP_rastroWhile = {
	private ["_angSoma","_distSoma","_pos","_nPos","_vel","_nVel","_angDlt","_posFinal"];
	while {true} do {
		waitUntil {!isNull BRPVP_bala || !BRPVP_rastroBalasLigado};
		if (!BRPVP_rastroBalasLigado) exitWith {};
		_pos = position BRPVP_bala;
		_vel = velocity BRPVP_bala;
		_angSoma = 0;
		_distSoma = 0;
		while {!isNull BRPVP_bala} do {
			_nVel = velocity BRPVP_bala;
			_nPos = position BRPVP_bala;
			_angDlt = acos (_vel vectorCos _nVel);
			_angSoma = _angSoma + _angDlt;
			_distSoma = _distSoma + (_nPos distance _pos);
			if (_angDlt >= 2.5 || _angSoma >= 20 || _distSoma >= 100) then {
				_angSoma = 0;
				_distSoma = 0;
				if (str _nPos != "[0,0,0]") then {BRPVP_rastroPosicoes = BRPVP_rastroPosicoes + [_nPos];};
			};
			_pos = _nPos;
			_vel = _nVel;
			_posFinal = _nPos;
		};
		if (str _posFinal != "[0,0,0]") then {BRPVP_rastroPosicoes = BRPVP_rastroPosicoes + [_posFinal];};
	};
};

//ATUALIZA AMIGOS (MA TELA 3D E NO MAPA)
BRPVP_daUpdateNosAmigos = {
	[] spawn {
		sleep 1;
		private ["_update"];
		_BRPVP_meusAmigosObj = [];
		{
			if (_x getVariable ["sok",false]) then {
				if (_x call BRPVP_checaAcesso || BRPVP_vePlayers) then {
					_BRPVP_meusAmigosObj pushBack _x;
				};
			};
		} forEach (allPlayers - [player]);
		if (count BRPVP_meusAmigosObj == count _BRPVP_meusAmigosObj) then {
			_update = false;
			{if !(_x in BRPVP_meusAmigosObj) exitWith {_update = true;};} forEach _BRPVP_meusAmigosObj;
		} else {
			_update = true;
		};	
		if (_update) then {
			BRPVP_meusAmigosObj = + _BRPVP_meusAmigosObj;
			"amigos" call BRPVP_removeTodosIconesLocais;
			{["amigos","AMIGO_" + str _forEachIndex,_x,"ColorYellow",_x getVariable "nm","mil_dot"] call BRPVP_adicionaIconeLocal;} forEach BRPVP_meusAmigosObj;
		};
	};
};

//FUNCAO PARA PROCESSAR ICONES NO MAPA
BRPVP_mapDrawPrecisao = -10;
BRPVP_iconesTotaisOnBeep = [];
BRPVP_iconesTotaisOnBeepDist = [];
BRPVP_iconesTotaisOnBeepHurt = [];
BRPVP_addAllwaysIcon = {
	params ["_marca","_objeto"];
	if (!isNull _objeto) then {
		_marca setMarkerPosLocal getPosWorld _objeto;
		if (_objeto == player) then {_marca setMarkerDirLocal getDir _objeto;};
	} else {
		_marca setMarkerPosLocal BRPVP_posicaoFora;
	};
};
BRPVP_addBlinkIcon = {
	params ["_marca","_objeto"];
	if (!isNull _objeto && {alive _objeto}) then {
		_pos = getPosWorld _objeto;
		_dist = _objeto distance BRPVP_radarCenter;
		if (BRPVP_vePlayers) then {
			_marca setMarkerPosLocal _pos;
			_marca setMarkerAlphaLocal 1;
		} else {
			if (_dist < BRPVP_radarDist * 2 && {!(terrainIntersectASL [AGLToASL BRPVP_radarCenter,_pos])}) then {
				_show = true;
				_pO = [_pos,random (BRPVP_radarDistErr * _dist),random 360] call BIS_fnc_relPos;
				if (_objeto isKindOf "Man") then {
					_veic = vehicle _objeto;
					if (_veic != _objeto) then {
						if !(_veic in _allVeics) then {
							_allVeics pushBack _veic;
						} else {
							_pO = BRPVP_posicaoFora;
							_show = false;
						};
					};
				};
				_marca setMarkerPosLocal _pO;
				if (_show) then {
					_signalHurt1 = (selectBestPlaces [_objeto,1,"forest",1,1]) select 0 select 1;
					_nearestBuilding = nearestObject [_objeto,"Building"];
					_nearestDistance = if (!isNull _nearestBuilding) then {[_objeto,_nearestBuilding] call PDTH_distance2Box} else {100};
					_signalHurt2 = 1 - (((_nearestDistance - 5) max 0) min 20)/20;
					_signalHurt = _signalHurt1 max _signalHurt2;
					BRPVP_iconesTotaisOnBeep pushBack _this;
					BRPVP_iconesTotaisOnBeepDist pushBack _dist;
					BRPVP_iconesTotaisOnBeepHurt pushBack _signalHurt;
					//diag_log (str _this + " / " + str _dist + " / " + str _signalHurt);
					//diag_log (str count BRPVP_iconesTotaisOnBeep + " / " + str count BRPVP_iconesTotaisOnBeepDist + " / " + str count BRPVP_iconesTotaisOnBeepHurt);
				};
			} else {
				_marca setMarkerPosLocal BRPVP_posicaoFora;
			};
		};
	} else {
		_marca setMarkerPosLocal BRPVP_posicaoFora;
	};
};
BRPVP_mapDraw = {
	private ["_allVeics"];
	_time = time;
	_passou = _time - BRPVP_mapDrawPrecisao;
	if (_passou >= BRPVP_radarBeepInterval || BRPVP_fazRadarBip) then {
		_radarConfig = if (BRPVP_vePlayers) then {[0,0,0.5,[0,0,0]]} else {BRPVP_radarConfigPool select 0};
		BRPVP_radarDist = _radarConfig select 0;
		BRPVP_radarDistErr = _radarConfig select 1;
		BRPVP_radarBeepInterval = _radarConfig select 2;
		BRPVP_radarCenter = _radarConfig select 3;
		if (typeName BRPVP_radarCenter == "OBJECT") then {
			BRPVP_radarCenter = getPosWorld BRPVP_radarCenter;
			BRPVP_radarCenter = ASLToAGL BRPVP_radarCenter;
			_extraH = if (count _radarConfig == 5) then {_radarConfig select 4} else {0};
			BRPVP_radarCenter set [2,2 * (BRPVP_radarCenter select 2) + _extraH];
		};
		BRPVP_fazRadarBip = false;
		BRPVP_mapDrawPrecisao = _time;
		BRPVP_iconesTotaisOnBeep = [];
		BRPVP_iconesTotaisOnBeepDist = [];
		BRPVP_iconesTotaisOnBeepHurt = [];
		if (!visibleGPS && BRPVP_radarDist > 0) then {playSound "ciclo";};
		_allVeics =[];
		{
			_unit = _x select 1;
			if !(_unit in BRPVP_meusAmigosObj || _unit == player ) then {
				_x call BRPVP_addBlinkIcon;
			};
		} forEach BRPVP_iconesLocaisBots;
		{
			_veh = _x select 1;
			_crew = crew _veh;
			if (count _crew > 0) then {
				_carWithFriend = false;
				{
					if (_x in BRPVP_meusAmigosObj || _x == player) exitWith {_carWithFriend = true;};
				} forEach _crew;
				if (!_carWithFriend) then {
					_x call BRPVP_addBlinkIcon;
				};
			} else {
				_x call BRPVP_addBlinkIcon;
			};
		} forEach BRPVP_iconesLocaisVeiculi;
		{_x call BRPVP_addAllwaysIcon;} forEach BRPVP_iconesLocaisSempre;
	};
	{_x call BRPVP_addAllwaysIcon;} forEach BRPVP_iconesLocais;
	{_x call BRPVP_addAllwaysIcon;} forEach BRPVP_iconesLocaisStuff;
	_uOff = [];
	_vehicles = [];
	{
		_marca = _x select 0;
		_objeto = _x select 1;
		if (!isNull _objeto && {!(_objeto in _uOff) && {_objeto getVariable ["sok",false] && _objeto getVariable ["dd",-1] <= 0}}) then {
			_veh = vehicle _objeto;
			_inVeh = _objeto != _veh;
			_checkAgain = false;
			if (_inVeh && {!(_veh in _vehicles)}) then {
				_vehicles pushBack _veh;
				_crew = crew _veh;
				_one = _crew select (BRPVP_countSecs mod count _crew);
				_uOff append (_crew - [_one]);
				_checkAgain = true;
			};
			if (!_checkAgain || {!(_objeto in _uOff)}) then {
				_marca setMarkerPosLocal getPosWorld _objeto;
			} else {
				_marca setMarkerPosLocal BRPVP_posicaoFora;
			};
		} else {
			_marca setMarkerPosLocal BRPVP_posicaoFora;
		};
	} forEach BRPVP_iconesLocaisAmigos;
	_intPerda = (0.25 + 1.75 * _passou/BRPVP_radarBeepInterval)^2;
	{
		_marca = _x select 0;
		if (!BRPVP_vePlayers) then {
			_objeto = _x select 1;
			_dist = (BRPVP_iconesTotaisOnBeepDist select _forEachIndex) * _intPerda;
			_hurt = BRPVP_iconesTotaisOnBeepHurt select _forEachIndex;
			_mostra = false;
			if (BRPVP_radarDist != 0 && {random 1 < ((BRPVP_radarDist - _dist)/BRPVP_radarDist) * (1 - _hurt)}) then {
				_mostra = true;
			};
			if (_mostra) then {
				_marca setMarkerAlphaLocal 1;
			} else {
				_marca setMarkerAlphaLocal 0;
			};
		};
	} forEach BRPVP_iconesTotaisOnBeep;
};

//ATUALIZAR INFORMACOES DO DEBUG
BRPVP_atualizaDebug = {
	if !(BRPVP_construindo || BRPVP_menuExtraLigado) then {
		private ["_veiculo","_imagem","_iTam"];
		_vPlayer = vehicle player;
		if (player == _vPlayer) then {
			_veiculo = "No Vehicle";
			_imagem = getText (configFile >> "CfgWeapons" >> (currentWeapon player) >> "picture");
			_iTam = 4.5;
		} else {
			_veiculo = getText (configFile >> "CfgVehicles" >> (typeOf _vPlayer) >> "displayName");
			_imagem = (getText (configFile >> "CfgVehicles" >> (typeOf _vPlayer) >> "picture"));
			_iTam = 4;
		};
		_danoGeral = 1 - damage player;
		_danoPartes = (player getHit "head") + (player getHit "legs") + (player getHit "arms") + (player getHit "body");
		BRPVP_ultimoDebugDoHint = format [
			BRPVP_indiceDebugItens select BRPVP_indiceDebug,
			round ((100 - _danoPartes * 25) * _danoGeral),
			count allPlayers,
			"%",
			round (BRPVP_alimentacao),
			_veiculo,
			if (_imagem != "") then {"<img size='" + str _iTam + "' image='" + _imagem + "'/><br/>"} else {""},
			round diag_fps,
			BRPVP_servidorQPS,
			round ((BRPVP_playerSemFadigaTempo - time) max 0),
			" $ " + str (player call BRPVP_qjsValorDoPlayer),
			(round((100*BRPVP_zombieFactor/BRPVP_zombieFactorLimit)/5))*5
		];
		hintSilent parseText BRPVP_ultimoDebugDoHint;
	};
};
BRPVP_atualizaDebugMenu = {
	if (BRPVP_construindo) then {
		hintSilent parseText call BRPVP_construcaoHint;
	} else {
		if (BRPVP_menuExtraLigado) then {
			if !(call BRPVP_menuForceExit) then {
				hintSilent parseText call BRPVP_menuHtml;
			} else {
				playSound "erro";
				BRPVP_menuExtraLigado = false;
				call BRPVP_atualizaDebug;
			};
		};
	};
};

//PLAYER COMPROU ITEM
BRPVP_comprouItem = {
	params ["_item","_preco"];
	if ((BRPVP_compraPrecoTotal + _preco) * BRPVP_precoMult <= player call BRPVP_qjsValorDoPlayer) then {
		BRPVP_compraPrecoTotal = BRPVP_compraPrecoTotal + _preco;
		BRPVP_compraItensTotal pushBack _item;
		BRPVP_compraItensPrecos pushBack _preco;
		playSound "negocio";
	} else {
		playSound "erro";
		["You don't have enough money.\nRemove one or more items.",0] call BRPVP_hint;
	};
};
BRPVP_comprouItemFinaliza = {
	diag_log "[BRPVP TRADER] BRPVP_comprouItemFinaliza STARTED!";
	if (count BRPVP_compraItensTotal > 0) then {
		_money = player getVariable ["mny",0];
		_price = BRPVP_compraPrecoTotal * BRPVP_precoMult;
		if (_money < _price) then {
			["You need more $ " + str (_price - _money) + ".",4,5] call BRPVP_hint;
			playSound "erro";
		} else {
			_minhasComprasWH = createVehicle ["GroundWeaponHolder",getPosATL player,[],0,"CAN_COLLIDE"];
			_minhasComprasWH setVariable ["own",player getVariable ["id_bd",-1],true];
			_minhasComprasWH setVariable ["amg",player getVariable ["amg",[]],true];
			_minhasComprasWH setVariable ["stp",2,true];
			player setVariable ["mny",(player getVariable ["mny",0]) - _price,true];
			_onGround = [player,BRPVP_compraItensTotal,_minhasComprasWH] call BRPVP_addLoot;
			if (_onGround) then {
				["Some items are on the ground!",4,15] call BRPVP_hint;
			} else {
				["You have all the items!",3,10] call BRPVP_hint;
			};
			playSound "negocio";
			playSound "ugranted";
		};
	};
};
BRPVP_vaultAbre = {
	playSound "abrevault";
	_posPlayer = getPosATL player;
	_multiplicador = 0;
	if (_posPlayer select 2 > 0.1) then {_multiplicador = 1;};
	_posPlayerZ0 = [_posPlayer select 0,_posPlayer select 1,0];
	_posPlayerASL = ATLtoASL _posPlayerZ0;
	_ang = getDir player;
	_posVault = [(_posPlayer select 0) + 2 * sin _ang,(_posPlayer select 1) + 2 * cos _ang,_posPlayer select 2];
	_posVaultZ0 = [_posVault select 0,_posVault select 1,0];
	_posVaultASL = ATLtoASL _posVaultZ0;
	_hExtra = (_posPlayerASL select 2) - (_posVaultASL select 2);
	_posVault set [2,(_posVault select 2) + _hExtra * _multiplicador];
	BRPVP_holderVault = "Box_NATO_WpsSpecial_F" createVehicle [0,0,0];
	BRPVP_holderVault setVariable ["stp",0,true];
	BRPVP_holderVault setDir getDir player;
	BRPVP_holderVault addEventHandler ["HandleDamage",{0}];
	BRPVP_holderVault setPos _posVault;
	clearWeaponCargoGlobal BRPVP_holderVault;
	clearMagazineCargoGlobal BRPVP_holderVault;
	clearBackPackCargoGlobal BRPVP_holderVault;
	clearItemCargoGlobal BRPVP_holderVault;
	BRPVP_holderVault setVariable ["own",player getVariable ["id_bd",-1],true];
	BRPVP_holderVault setVariable ["amg",player getVariable ["amg",[]],true];
	BRPVP_holderVault setPosATL _posVault;
	if (_multiplicador == 1) then {BRPVP_holderVault setVectorUp [0,0,1];};
	_posVault set [2,(_posVault select 2) + 0.5];
	BRPVP_pegaVaultPlayerBdRetorno = nil;
	BRPVP_pegaVaultPlayerBd = [player,0];
	publicVariableServer "BRPVP_pegaVaultPlayerBd";
	//BRPVP_myStuff append [BRPVP_holderVault];
	//["mastuff"] call BRPVP_atualizaIcones;
};
BRPVP_vaultRecolhe = {
	playSound "fechavault";
	BRPVP_holderVault setPos [0,0,0];
	_armas = [[],[]];
	_magas = magazinesAmmoCargo BRPVP_holderVault;
	_mochi = getBackpackCargo BRPVP_holderVault;
	_itens = getItemCargo BRPVP_holderVault;
	_conts = everyContainer BRPVP_holderVault;
	_weaponsItemsCargo = weaponsItemsCargo BRPVP_holderVault;
	{_weaponsItemsCargo = _weaponsItemsCargo + (weaponsItemsCargo (_x select 1));} forEach _conts;
	{
		_arma = _x;
		{
			if (_forEachIndex == 0) then {
				_armas = [_armas,_x call BIS_fnc_baseWeapon] call BRPVP_adicCargo;
			} else {
				if (typeName _x == "ARRAY") then {if (count _x > 0) then {_magas append [_x];};};
				if (typeName _x == "STRING") then {if (_x != "") then {_itens = [_itens,_x] call BRPVP_adicCargo;};};
			};
		} forEach _arma;
	} forEach _weaponsItemsCargo;
	{
		_cont = _x select 1;
		_magas append magazinesAmmoCargo _cont;
		_itensC = getItemCargo _cont;
		{
			_qt = _itensC select 1 select _forEachIndex;
			for "_i" from 1 to _qt do {_itens = [_itens,_x] call BRPVP_adicCargo;};
		} forEach (_itensC select 0);
	} forEach _conts;
	_estadoVault = [
		getPlayerUID player,
		[_armas,_magas,_mochi,_itens],
		BRPVP_holderVault getVariable ["stp",1]
	];
	diag_log ("[BRPVP VAULT] SAVING VAULT: " + str _estadoVault);
	_estadoPlayer = player call BRPVP_pegaEstadoPlayer;
	player setVariable ["wh",objNull,true];
	BRPVP_salvaPlayerVault = [_estadoPlayer,[_estadoVault,0]];
	publicVariableServer "BRPVP_salvaPlayerVault";
	clearWeaponCargoGlobal BRPVP_holderVault;
	clearMagazineCargoGlobal BRPVP_holderVault;
	clearBackpackCargoGlobal BRPVP_holderVault;
	clearItemCargoGlobal BRPVP_holderVault;
	//_idc = BRPVP_myStuff find BRPVP_holderVault;
	//if (_idc >= 0) then {BRPVP_myStuff deleteAt _idc};
	//["mastuff"] call BRPVP_atualizaIcones;
	deleteVehicle BRPVP_holderVault;
};
BRPVP_incluiPlayerBd = {
	_hpd = getAllHitPointsDamage player;
	_estado = [
		getPlayerUID player,
		[[],["",["","","",""],[]],["",["","","",""],[]],["",["","","",""],[]]],
		[["",[[[],[]],[[],[]],[[],[]]]],["",[[[],[]],[[],[]],[[],[]]]],["",[[[],[]],[[],[]],[[],[]]]]],
		[0,[0,0,0]],
		[[_hpd select 1,_hpd select 2],[100,100],damage player],
		[typeOf player,"",""],
		"",
		player getVariable ["nm","sem_nome"],
		BRPVP_experienciaZerada,
		BRPVP_startingMoney,
		[]
	];
	BRPVP_incluiPlayerNoBd = [player,_estado];
	publicVariableServer "BRPVP_incluiPlayerNoBd";
};
BRPVP_protejeCarro = {
	params ["_v","_motorOn"];
	_deGeral = _v getVariable ["own",-1] == -1;
	if (_deGeral) then {
		cutText ["","PLAIN",1];
		cutText ["Public Vehicle!","PLAIN",0.25];
	} else {
		waitUntil {local _v};
		_gasLock = {
			_fV = fuel _v;
			if (_fV > 0) then {
				_v setVariable ["gas",_fV,true];
				_v setFuel 0;
				//[_v,"alarme_carro",1] call BRPVP_playSoundAllCli;
				playSound "erro";
			};
		};
		_releaseGasLock = {
			_gas = _v getVariable ["gas",-1];
			if (_gas >= 0) then {
				_v setFuel _gas;
				_v setVariable ["gas",-1,true];
			};
		};
		call _releaseGasLock;
		_uAtuAmg = BRPVP_tempoUltimaAtuAmigos;
		_uStp = _v getVariable ["stp",0];
		if (_motorOn) then {
			waitUntil {!isEngineOn _v || driver _v != player || !alive _v || !alive player};
		};
		if ((alive player && alive _v && !isEngineOn _v && driver _v == player) || !_motorOn) then {
			private ["_lib"];
			if (_v call BRPVP_checaAcesso) then {
				cutText ["","PLAIN",1];
				cutText ["Private Vehicle - Allowed to use","PLAIN",0.25];
				_lib = true;
			} else {
				cutText ["","PLAIN",1];
				cutText ["Private Vehicle - Protection on!","PLAIN",0.25];
				_lib = false;
			};
			_atento = true;
			waitUntil {
				if (_atento) then {
					_nStp = _v getVariable ["stp",0];
					if (_uAtuAmg != BRPVP_tempoUltimaAtuAmigos || _nStp != _uStp) then {
						_uAtuAmg = BRPVP_tempoUltimaAtuAmigos;
						_uStp = _nStp;
						if (_v call BRPVP_checaAcesso) then {
							if (!_lib) then {
								cutText ["","PLAIN",1];
								cutText ["Private Vehicle - Allowed to use","PLAIN",0.25];
								call _releaseGasLock;
								_lib = true;
							};
						} else {
							if (_lib) then {
								cutText ["","PLAIN",1];
								cutText ["Private Vehicle - Protection on!","PLAIN",0.25];
								_lib = false;
							};
						};
					};
					if (isEngineOn _v) then {
						if (_v call BRPVP_checaAcesso) then {
							_atento = false;
						} else {
							cutText ["","PLAIN",1];
							cutText ["LOCK ON!","PLAIN",0.25];
							call _gasLock;
						};
					};
				} else {
					if (!isEngineOn _v) then {_atento = true;};
				};
				driver _v != player || !alive _v || !alive player
			};
			cutText ["","PLAIN",1];
		};
	};
};
BRPVP_switchMove = {
	if (typeName _this == "STRING") then {
		BRPVP_switchMoveSv = [player,_this];
	} else {
		BRPVP_switchMoveSv = _this;
	};
	 publicVariableServer "BRPVP_switchMoveSv";
};
BRPVP_drawSetas = {
	params ["_obj","_txt"];
	{
		_count = count _x;
		if (_count > 0) then {
			if (_count == 3) then {
				BRPVP_drawIcon3DC pushBack [BRPVP_missionRoot + "BRP_imagens\icones3d\setabu" + str _forEachIndex + ".paa",[1,1,1,1],_x,0.55,0.55,0,_txt,0,0.02];
			} else {
				if (_count == 2) then {
					BRPVP_drawIcon3DC pushBack [BRPVP_missionRoot + "BRP_imagens\icones3d\setacha" + str _forEachIndex + ".paa",[1,1,1,1],_x + [0],0.55,0.55,0,_txt,0,0.02];
				};
			};
		};
	} forEach (_obj getVariable ["sts",[]]);
};
BRPVP_checaAcesso = {
	//MINHAS RELACOES
	_id_bd = player getVariable ["id_bd",-1];
	_amg = player getVariable ["amg",[]];

	//RELACOES OBJ CHECADO
	_oOwn = _this getVariable ["own",-1];
	_oAmg = _this getVariable ["amg",[]];
	_oShareT = _this getVariable ["stp",1];
	
	//FOR "MO ONE" SHARE
	if (_oShareT == 4 && !BRPVP_vePlayers) exitWith {false};
	
	//CHECA ACESSO
	_retorno = false;
	if (BRPVP_vePlayers || _oOwn == -1 || _id_bd == _oOwn || _oShareT == 3) then {
		_retorno = true;
	} else {
		if (_oShareT != 0) then {
			if (_oShareT == 1) then {
				if (_id_bd in _oAmg) then {_retorno = true;};
			} else {
				if (_oShareT == 2) then {
					if (_id_bd in _oAmg && _oOwn in _amg) then {_retorno = true;};
				};
			};
		};
	};
	_retorno
};
BRPVP_atualizaMeuStuffAmg = {
	_amg = player getVariable ["amg",[]];
	{
		if (!isNull _x) then {
			if !(_x call BRPVP_isSimpleObject) then {
				_x setVariable ["amg",_amg,true];
				if !(_x getVariable ["slv_amg",false]) then {_x setVariable ["slv_amg",true,true];};
			};
		};
	} forEach BRPVP_myStuff;
};
BRPVP_compEstado = {
	_estado = _this getVariable ["stp",-1];
	_result = "Unknow Share Type";
	if (_estado == -1) then {
		_result = "Everyone (Public)";
	} else {
		if (_estado == 0) then {
			_result = "Me";
		} else {
			if (_estado == 1) then {
				_result = "Me + Who i trust";
			} else {
				if (_estado == 2) then {
					_result = "Me + Who i trust reciprocally";
				} else {
					if (_estado == 3) then {
						_result = "Everyone (Private)";
					} else {
						if (_estado == 4) then {
							_result = "No One";
						};
					};
				};
			};
		};
	};
	_result
};
BRPBP_achaMeuStuff = {
	_id_bd = player getVariable ["id_bd",-1];
	_pAmg = player getVariable ["amg",[]];
	if (_id_bd != -1) then {
		_BRPVP_myStuff = [];
		_completeObjs = [];
		{
			if (_x call BRPVP_isSimpleObject) then {
				if ([_x,"own",-1] call BRPVP_getVariable == _id_bd) then {
					_BRPVP_myStuff pushBack _x;
					_typeOf = _x call BRPVP_typeOf;
					if (_typeOf in BRP_kitRespawnA || _typeOf in BRP_kitRespawnB) then {
						BRPVP_respawnSpot = _x;
					};
				};
			} else {
				_completeObjs pushBack _x;
			};
		} forEach BRPVP_ownedHouses;
		_normalVarSet = BRPVP_centroMapa nearEntities [["LandVehicle","Air","Ship"],20000];
		_normalVarSet append _completeObjs;
		{
			if (_x getVariable ["own",-1] == _id_bd) then {
				_xAmg = _x getVariable ["amg",[]];
				if !(_xAmg isEqualTo _pAmg) then {
					_x setVariable ["amg",_pAmg,true];
					if !(_x getVariable ["slv_amg",false]) then {_x setVariable ["slv_amg",true,true];};
				};
				_BRPVP_myStuff pushBack _x;
			};
		} forEach _normalVarSet;
		BRPVP_myStuff = +_BRPVP_myStuff;
	};
};
BRPVP_mudaDonoPropriedade = {
	_props = _this select 0;
	_novoDono = _this select 1;
	if (typeName _props != "ARRAY") then {_props = [_props];};
	_ok = false;
	if (_novoDono isEqualTo "") then {
		{
			_x setVariable ["own",-1,true];
			_x setVariable ["stp",1,true];
			_x setVariable ["amg",[],true];
			if (_x getVariable ["mapa",false]) then {
				BRPVP_mapHouseRemoveDb = _x;
				publicVariableServer "BRPVP_mapHouseRemoveDb";
			} else {
				if !(_x getVariable ["slv_amg",false]) then {_x setVariable ["slv_amg",true,true];};
			};
		} forEach _props;
		_ok = true;
	} else {
		if (!isNull _novoDono) then {
			BRPVP_mudaDonoPropriedadeSV = [_props,_novoDono];
			publicVariableServer "BRPVP_mudaDonoPropriedadeSV";
			_ok = true;
		};
	};
	if (_ok) then {
		BRPVP_myStuff = BRPVP_myStuff - _props;
		if (BRPVP_stuff in _props) then {
			BRPVP_stuff = objNull;
		};
		["mastuff"] call BRPVP_atualizaIcones;
	};
};

diag_log "[BRPVP FILE] funcoes.sqf END REACHED";