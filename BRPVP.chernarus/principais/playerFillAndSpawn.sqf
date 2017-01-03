diag_log "[BRPVP FILE] nascimento_player.sqf INITIATED";

//PRIVATE VARS
private ["_tempofora"];

//TELA PRETA
cutText ["","BLACK FADED",10];

//IS REVIVE?
_revive = !isNull BRPVP_playerLastCorpse && {BRPVP_playerLastCorpse getVariable ["dd",1] == 2};
diag_log ("[BRPVP PLAYER SPAWN] _revive = " + str _revive);

//RESETA VOLUME
if (!_revive) then {
	0 fadeSound 1;
	
	//PLAYER RATING
	player addRating 1000000;

};

//VERSAO
BRPVP_VB = "V0.2B2";

//CLICK MAPA
if (!_revive) then {
	BRPVP_onMapSingleClick = BRPVP_padMapaClique;
	BRPVP_onMapSingleClickExtra = {};
};

//ESPERA O ANTI-AMARELOU ACABAR
if (!_revive) then {
	while {(getPlayerUID player) in BRPVP_noAntiAmarelou} do {
		cutText ["YOU ARE STILL ON THE LOGOFF PROTECTION, PLEASE WAIT...","BLACK FADED",10];
		sleep 1;
	};
	cutText ["","BLACK FADED",10];
};

//X SECONDS UNIT MOVEMENT CHECK
_init = time;

if (!_revive) then {
	//ACHA CORPOS DO PLAYER
	_ultimo = 0;
	{
		_mId = _x getVariable ["id","0"];
		if (getPlayerUID player == _mId) then {
			BRPVP_meuAllDead append [_x];
			_ultimo = _ultimo max (_x getVariable ["hrm",0]);
		};
	} forEach allDead;
	_tempofora = serverTime - _ultimo;

	//DELETA CORPOS EM EXCESSO (MAXIMO DE 2)
	while {count BRPVP_meuAllDead > 3} do {
		_maisAntigo = 100000;
		_idcDel = 0;
		{
			_ant = _x getVariable ["hrm",100000];
			if (_ant < _maisAntigo) then {
				_maisAntigo = _ant;
				_idcDel = _forEachIndex;
			};
		} forEach BRPVP_meuAllDead;
		_corpo = BRPVP_meuAllDead select _idcDel;
		deleteVehicle _corpo;
		BRPVP_meuAllDead set [_idcDel,-1];
		BRPVP_meuAllDead = BRPVP_meuAllDead - [-1];
	};
};

//SET CAPTIVE STATE
if (BRPVP_playerIsCaptive) then {
	player setCaptive true;
};


if (_revive) then {
	BRPVP_checaExistenciaPlayerBdRetorno = "revive";
} else {
	//CHECA ESTADO DO PLAYER NO BANCO DE DADOS
	BRPVP_checaExistenciaPlayerBdRetorno = nil;
	BRPVP_checaExistenciaPlayerBd = [player,BRPVP_VB];
	publicVariableServer "BRPVP_checaExistenciaPlayerBd";
	waitUntil {!isNil "BRPVP_checaExistenciaPlayerBdRetorno"};
};

//EXECUTA SE O PLAYER E ANTIGO E ESTA VIVO NO BANCO DE DADOS OU EM CASO DE REANIMACAO
if (BRPVP_checaExistenciaPlayerBdRetorno == "no_bd_e_vivo" || _revive) then {
	private ["_resultadoCompilado","_armaNaMao"];
	
	//MOSTRA ICONES PERTINENTES
	if (!_revive) then {
		call BRPVP_atualizaIconesSpawn;
	};
	
	//GET PLAYER DATA FROM BODY (REVIVE) OR DATA BASE
	if (_revive) then {
		cutText ["RETURNING TO LIFE...","BLACK FADED",10];
		
		//GET BODY GEAR
		_plyDef = BRPVP_playerLastCorpse call BRPVP_pegaEstadoPlayer;
		_plyOk = [];
		{
			_plyOk pushBack (_plyDef select _x);
		} forEach [1,2,3,4,5,6,7,9,11,10,12,13];
		_resultadoCompilado = [_plyOk];
	} else {
		cutText ["PLEASE WAIT...","BLACK FADED",10];
		
		//PEGA PLAYER NO BD
		BRPVP_pegaPlayerBdRetorno = nil;
		BRPVP_pegaPlayerBd = player;
		publicVariableServer "BRPVP_pegaPlayerBd";
		waitUntil {!isNil "BRPVP_pegaPlayerBdRetorno"};

		//COMPILA INFORMACOES DO PLAYER VIVO
		_resultadoCompilado = call compile BRPVP_pegaPlayerBdRetorno;
		_resultadoCompilado = _resultadoCompilado select 1;
	};
	
	//PELA PLAYER (DEIXA ELE PELADO)
	false call BRPVP_escolheModaPlayer;
	
	//MONEY
	_money = _resultadoCompilado select 0 select 10;
	player setVariable ["mny",_money,true];

	//SPECIAL ITEMS
	_sit = _resultadoCompilado select 0 select 11;
	player setVariable ["sit",_sit,true];
	
	//CAPACETE E OCULOS
	_modelo = _resultadoCompilado select 0 select 4;
	if (_modelo select 1 != "") then {player addHeadGear (_modelo select 1);};
	if (_modelo select 2 != "") then {player addGoggles (_modelo select 2);};
	
	//COMPARTILHAMENTO PADRAO
	player setVariable ["dstp",_resultadoCompilado select 0 select 9,true];
	
	//ID DO BANCO DE DADOS
	_id_bd = _resultadoCompilado select 0 select 8;
	player setVariable ["id_bd",_id_bd,true];
	if (!_revive) then {
		BRPVP_salvaNomePeloIdBd = [_id_bd,player getVariable "nm"];
		publicVariableServer "BRPVP_salvaNomePeloIdBd";
	};
	
	//ASSIGNED PLAYER E (ARMAS + ASSIGNED)
	_inventario = _resultadoCompilado select 0 select 0;
	
	//ASSIGNED PLAYER
	{player addWeapon _x;} forEach (_inventario select 0);
	
	//ADICIONA VEST PARA RECEBER MAGAZINES DAS ARMAS
	player addBackpack "B_Carryall_oli";
	
	//ARMA PRIMARIA
	_wep = _inventario select 1 select 0;
	if (_wep != "") then {
		{player addMagazine _x;} forEach (_inventario select 1 select 2);
		player addWeapon _wep;
		{if (_x != "") then {player addPrimaryWeaponItem _x;};} forEach (_inventario select 1 select 1);
	};
	
	//ARMA SECUNDARIA
	_wep = _inventario select 2 select 0;
	if (_wep != "") then {
		{player addMagazine _x;} forEach (_inventario select 2 select 2);
		player addWeapon _wep;
		{if (_x != "") then {player addSecondaryWeaponItem _x;};} forEach (_inventario select 2 select 1);
	};
	
	//ARMA TERCIARIA
	_wep = _inventario select 3 select 0;
	if (_wep != "") then {
		{player addMagazine _x;} forEach (_inventario select 3 select 2);
		player addWeapon _wep;
		{if (_x != "") then {player addHandGunItem _x;};} forEach (_inventario select 3 select 1);
	};
	
	//REMOVE VEST UTILIZADA PARA RECEBER MAGAZINES DAS ARMAS
	removeBackpack player;

	//BACKPACK
	_backpack = _resultadoCompilado select 0 select 1;
	if ((_backpack select 0) select 0 != "") then {
		player addBackpack ((_backpack select 0) select 0);
		_BpObjeto = backpackContainer player;
		clearWeaponCargoGlobal _BpObjeto;
		clearItemCargoglobal _BpObjeto;
		clearMagazineCargoGlobal _BpObjeto;
		{_BpObjeto addWeaponCargoGlobal [_x,_backpack select 0 select 1 select 0 select 1 select _forEachIndex];} forEach (_backpack select 0 select 1 select 0 select 0);
		{_BpObjeto addItemCargoGlobal [_x,_backpack select 0 select 1 select 1 select 1 select _forEachIndex];} forEach (_backpack select 0 select 1 select 1 select 0);
		
		//TEMPORARIO
		_c = _backpack select 0 select 1 select 2;
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
			{_BpObjeto addMagazineAmmoCargo [_x select 0,1,_x select 1];} forEach (_backpack select 0 select 1 select 2);
		} else {
			{_BpObjeto addMagazineCargoGlobal [_x,_backpack select 0 select 1 select 2 select 1 select _forEachIndex];} forEach (_backpack select 0 select 1 select 2 select 0);
		};
	};
	
	//VEST
	if ((_backpack select 1) select 0 != "") then {
		player addVest ((_backpack select 1) select 0);
		_BpObjeto = vestContainer player;
		clearWeaponCargoGlobal _BpObjeto;
		clearItemCargoglobal _BpObjeto;
		clearMagazineCargoGlobal _BpObjeto;
		{_BpObjeto addWeaponCargoGlobal [_x,_backpack select 1 select 1 select 0 select 1 select _forEachIndex];} forEach (_backpack select 1 select 1 select 0 select 0);
		{_BpObjeto addItemCargoGlobal [_x,_backpack select 1 select 1 select 1 select 1 select _forEachIndex];} forEach (_backpack select 1 select 1 select 1 select 0);

		//TEMPORARIO
		_c = _backpack select 1 select 1 select 2;
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
			{_BpObjeto addMagazineAmmoCargo [_x select 0,1,_x select 1];} forEach (_backpack select 1 select 1 select 2);
		} else {
			{_BpObjeto addMagazineCargoGlobal [_x,_backpack select 1 select 1 select 2 select 1 select _forEachIndex];} forEach (_backpack select 1 select 1 select 2 select 0);
		};
	};
	
	//UNIFORME
	if ((_backpack select 2) select 0 != "") then {
		player forceAddUniform ((_backpack select 2) select 0); //TESTE TESTE TESTE
		_BpObjeto = uniformContainer player;
		clearWeaponCargoGlobal _BpObjeto;
		clearItemCargoglobal _BpObjeto;
		clearMagazineCargoGlobal _BpObjeto;
		{_BpObjeto addWeaponCargoGlobal [_x,_backpack select 2 select 1 select 0 select 1 select _forEachIndex];} forEach (_backpack select 2 select 1 select 0 select 0);
		{_BpObjeto addItemCargoGlobal [_x,_backpack select 2 select 1 select 1 select 1 select _forEachIndex];} forEach (_backpack select 2 select 1 select 1 select 0);

		//TEMPORARIO
		_c = _backpack select 2 select 1 select 2;
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
			{_BpObjeto addMagazineAmmoCargo [_x select 0,1,_x select 1];} forEach (_backpack select 2 select 1 select 2);
		} else {
			{_BpObjeto addMagazineCargoGlobal [_x,_backpack select 2 select 1 select 2 select 1 select _forEachIndex];} forEach (_backpack select 2 select 1 select 2 select 0);
		};
	};

	//ARMA NA MAO
	if (!_revive) then {
		_armaNaMao = _resultadoCompilado select 0 select 5;
		/*
		if (_armaNaMao != "") then {
			player selectWeapon _armaNaMao;
			player action ["WeaponInHand",player];
		};
		*/
	};

	//POSICAO
	_posicao = _resultadoCompilado select 0 select 2;
	_posS = _posicao select 1;
	player setDir (_posicao select 0);
	if (_revive) then {
		playSound3D [BRPVP_missionRoot + "BRP_sons\wakeup.ogg",BRPVP_playerLastCorpse,false,getPosASL BRPVP_playerLastCorpse,0.35,1,0];
		[player,true] call BRPVP_hideObject;
		player setPosATL ((getPosATL BRPVP_playerLastCorpse) vectorAdd [0,0,0.5]);
		waitUntil {time - _init >= 3};
		player playActionNow "Crouch";
		waitUntil {time - _init >= 5};
		[player,false] call BRPVP_hideObject;
		if (BRPVP_disabledWeapon != "") then {
			[BRPVP_playerLastCorpse,true] call BRPVP_hideObject;
			BRPVP_corpseToDelAdd = BRPVP_playerLastCorpse;
			publicVariableServer "BRPVP_corpseToDelAdd";
		} else {
			deleteVehicle BRPVP_playerLastCorpse;
		};
		BRPVP_playerLastCorpse = objNull;
		playSound3D [BRPVP_missionRoot + "BRP_sons\revive.ogg",player,false,getPosASL player,0.25,1,0];
	} else {
		waitUntil {time - _init >= 3};
		_objs = nearestObjects [player,["LandVehicle","Air","Ship"],15];
		_obj = objNull;
		{
			if ([ASLToAGL _posS,_x] call PDTH_pointIsInBox) exitWith {_obj = _x;};
		} forEach _objs;
		if (isNull _obj) then {
			player setPosWorld _posS;			
		} else {
			player setVehiclePosition [_posS,[],0,"NONE"];
		};
	};

	//SAUDE
	_saude = _resultadoCompilado select 0 select 3;
	player allowDamage true;
	
	if (_revive) then {
		//DAMAGE
		diag_log ("[BRPVP REVIVE-SPAWN DMG] Come Back Damage (max of 0.5) = " + str (BRPVP_disabledDamage + BRPVP_disabledBleed));
		_damage = (BRPVP_disabledDamage + BRPVP_disabledBleed) min 0.5;
		_damage = _damage * 2;
		_damage = (_damage max 0.2) min 0.9;
		_damage = (-2 + sqrt(4 - 4 * _damage))/(-2);
		player setDamage _damage;
		{player setHit [_x,_damage];} forEach (_saude select 0 select 0);
		call BRPVP_atualizaDebug;
		cutText ["","PLAIN",1];
	} else {
		//AMIGOS
		_amigos = _resultadoCompilado select 0 select 6;
		player setVariable ["amg",_amigos,true];

		//PEGA MEU STUFF
		if (!BRPVP_achaMeuStuffRodou) then {
			BRPVP_achaMeuStuffRodou = true;
			["FIND MY STUFF",BRPBP_achaMeuStuff] call BRPVP_execFast;
		};

		//EXPERIENCIA
		_experiencia = _resultadoCompilado select 0 select 7;
		player setVariable ["exp",_experiencia,true];
	
		//REVELA AO PLAYER OBJETOS POR PERTO
		{player reveal _x;} forEach (player nearObjects 35);

		//DAMAGE
		player setDamage (_saude select 2);
		{player setHit [_x,_saude select 0 select 1 select _forEachIndex];} forEach (_saude select 0 select 0);
		BRPVP_alimentacao = _saude select 1 select 0;
		player setVariable ["sud",[round BRPVP_alimentacao,100],true];

		//LOGA INFORMACOES DO PLAYER
		diag_log "--------------------------------------------------------------------------------------------";
		diag_log "---- [SPAWN: PLAYER ON DB AND ALIVE]";
		diag_log ("---- model = " + str _modelo);
		diag_log ("---- gear = " + str _inventario);
		diag_log ("---- backpack = " + str _backpack);
		diag_log ("---- health = " + str _saude);
		diag_log ("---- weapon in hand = " + str _armaNaMao);
		diag_log ("---- trust = " + str _amigos);
		diag_log ("---- experience = " + str _experiencia);
		diag_log "--------------------------------------------------------------------------------------------";

		//INICIA CONTAGEM DOS UM MINUTO DE GAMEPLAY
		_nulo = [] spawn {
			_ini = time;
			waitUntil {time - _ini > 60 || !alive player};
			if (alive player) then {player setVariable ["umok",true,true];};
		};

		playSound "ugranted";

		//MENSAGEM ABOUT PLAYER MENU
		cutText ["","PLAIN",1];
		["PRESS ALT + Q FOR PLAYER MENU.",5] call BRPVP_hint;

		//LIGA MODO ADMIN CASO SEJA UM ADMIN
		if (BRPVP_trataseDeAdmin) then {BRPVP_onMapSingleClick = BRPVP_adminMapaClique;} else {BRPVP_onMapSingleClick = BRPVP_padMapaClique;};
	};
};

//PARA NOVAS VIDAS, COLOCA PLAYER CAINDO DE PARAQUEDAS
if (BRPVP_checaExistenciaPlayerBdRetorno in ["nao_ta_no_bd","no_bd_e_morto"]) then {
	private ["_id_bd"];
	
	//ALGUMAS VARIAVEIS
	_experiencia = + BRPVP_experienciaZerada;
	_amigos = [];
	
	//EXECUTA SE O PLAYER JA ESTA NO BANCO DE DADOS MAS ESTA MORTO
	if (BRPVP_checaExistenciaPlayerBdRetorno == "no_bd_e_morto") then {
		BRPVP_pegaValoresContinuaRetorno = nil;
		BRPVP_pegaValoresContinua = player;
		publicVariableServer "BRPVP_pegaValoresContinua";
		waitUntil {!isNil "BRPVP_pegaValoresContinuaRetorno"};
		_resultadoCompilado = call compile BRPVP_pegaValoresContinuaRetorno;
		_resultadoCompilado = _resultadoCompilado select 1;
		_amigos = _resultadoCompilado select 0 select 0;
		_experiencia = _resultadoCompilado select 0 select 1;
		_id_bd = _resultadoCompilado select 0 select 2;
		player setVariable ["dstp",_resultadoCompilado select 0 select 3,true];
		player setVariable ["mny",_resultadoCompilado select 0 select 4,true];
		player setVariable ["sit",_resultadoCompilado select 0 select 5,true];
		diag_log "--------------------------------------------------------------------------------------------";
		diag_log "---- [SPAWN: PLAYER ON DB AND DEAD]";
		diag_log ("---- VALUES TO MANTAIN: " + str _resultadoCompilado + ".");
		diag_log "--------------------------------------------------------------------------------------------";
	};
	
	//EXECUTA SE E A PRIMEIRA VEZ DO PLAYER
	if (BRPVP_checaExistenciaPlayerBdRetorno == "nao_ta_no_bd") then {
		BRPVP_incluiPlayerNoBdRetorno = nil;
		call BRPVP_incluiPlayerBd;
		diag_log "--------------------------------------------------------------------------------------------";
		diag_log "---- [SPAWN: PLAYER NOT IN DB]";
		diag_log ("---- CREATING PLAYER ON DB");
		diag_log "--------------------------------------------------------------------------------------------";
		waitUntil {!isNil "BRPVP_incluiPlayerNoBdRetorno"};
		_id_bd = BRPVP_incluiPlayerNoBdRetorno;
		player setVariable ["dstp",1,true];
		player setVariable ["mny",BRPVP_startingMoney,true];
		player setVariable ["sit",[],true];
	};
	
	//ID DO BANCO DE DADOS
	player setVariable ["id_bd",_id_bd,true];
	BRPVP_salvaNomePeloIdBd = [_id_bd,player getVariable "nm"];
	publicVariableServer "BRPVP_salvaNomePeloIdBd";
			
	//ESCOLHE VESTIMENTA DO PLAYER
	true call BRPVP_escolheModaPlayer;
	
	//ALIMENTACAO E HIDRATACAO
	BRPVP_alimentacao = 105;
	player setVariable ["sud",[round BRPVP_alimentacao,100],true];
	
	//EXPERIENCIA
	player setVariable ["exp",_experiencia,true];

	//AMIGOS
	player setVariable ["amg",_amigos,true];
	
	//PEGA MEU STUFF
	if (!BRPVP_achaMeuStuffRodou) then {
		BRPVP_achaMeuStuffRodou = true;
		["FIND MY STUFF",BRPBP_achaMeuStuff] call BRPVP_execFast;
	};
	call BRPVP_atualizaIconesSpawn;
	
	//SET UM MINUTO DE GAMEPLAY OK PORQUE A VIDA E NOVA
	player setVariable ["umok",true,true];
	
	//ESCOLHE LOCAL DE SPAWN PARTE 1
	player addWeapon "ItemMap";
	openMap true;
	cutText ["PLEASE WAIT...","BLACK FADED",10];

	sleep 3;
	_tipSom = ASLToAGL [0,0,0] nearestObject "#soundonvehicle";
	["SELECT YOUR SPAWN PLACE!\n(ORANGE CIRCLES)\n\nSHIFT + CLICK ON MAP TO SET THE PLAYER FACING DIRECTION!",10] call BRPVP_hint;
	
	//ESCOLHE LOCAL DE SPAWN PARTE 2
	BRPVP_posicaoDeNascimento = nil;
	BRPVP_onMapSingleClick = BRPVP_nascMapaClique;
	BRPVP_temposLocais = [];
	_maxDistSoma = 0;
	_minDistSoma = 1000000;
	{
		_cnt = _x select 0;
		_raio = _x select 1;
		_iName = "CNTG_NSC_" + str _forEachIndex;
		_iType = "mil_dot";
		_iColor = "ColorRed";
		_iText = "";
		_icone = createMarkerLocal [_iName,_cnt];
		_icone setMarkerShapeLocal "Icon";
		_icone setMarkerTypeLocal _iType;
		_icone setMarkerColorLocal _iColor;
		_icone setMarkerTextLocal _iText;
		_distSoma = 0;
		{
			_corpo = _x;
			_distSoma = _distSoma + sqrt (_corpo distance2D _cnt);
		} forEach BRPVP_meuAllDead;
		BRPVP_temposLocais append [_distSoma];
		if (_distSoma > _maxDistSoma) then {_maxDistSoma = _distSoma;};
		if (_distSoma < _minDistSoma) then {_minDistSoma = _distSoma;};
	} forEach BRPVP_locaisImportantes;
	_faixa = _maxDistSoma - _minDistSoma;
	diag_log ("[BRPVP time away] = " + str _tempofora + ".");
	if (_faixa > 0) then {
		{
			BRPVP_temposLocais set [_forEachIndex,time + (1 - (_x - _minDistSoma)/_faixa) * ((110 - _tempofora) max 0)];
		} forEach BRPVP_temposLocais;
	};
	
	//ESCOLHE LOCAL DE SPAWN PARTE 3
	_ini = time - 2;
	"LOCAL_PLAYER" setMarkerAlphaLocal 0;
	waitUntil {
		if (!visibleMap) then {
			cutText ["\n\nOPEN THE MAP (DEFAULT KEY M) AND CHOOSE A PLACE TO SPAWN (ORANGE AREAS)!\nOR PRESS ESC TO LEAVE THE SERVER.","BLACK FADED"];
		} else {
			cutText ["","PLAIN"];
		};
		if (time - _ini >= 1) then {
			_ini = time;
			{
				_icone = "CNTG_NSC_" + str _forEachIndex;
				_cntg = (round (_x - _ini)) max 0;
				if (_cntg > 0) then {
					_iText = str _cntg;
					_icone setMarkerTextLocal _iText;
				} else {
					_icone setMarkerPosLocal BRPVP_posicaoFora;
				};
			} forEach BRPVP_temposLocais;
		};
		!isNil "BRPVP_posicaoDeNascimento"
	};
	{deleteMarkerLocal ("CNTG_NSC_" + str _forEachIndex);} forEach BRPVP_temposLocais;
	deleteVehicle _tipSom;
	
	//CRIA VAR COM POSICAO DE NASCIMENTO ESCOLHIDA
	_posType = BRPVP_posicaoDeNascimento select 0;
	
	if (_posType == "air") then {
		_posNasc = BRPVP_posicaoDeNascimento select 1;
		_posNasc = [(_posNasc select 0) - 100 + random 200,(_posNasc select 1) - 100 + random 200,1100];
		
		//INICIA SALTO DE PARAQUEDAS
		BRPVP_onMapSingleClick = BRPVP_padMapaClique;
		player addBackpack "B_Parachute";
		player setPos _posNasc;
		_pd = player getVariable ["pd",BRPVP_centroMapa];
		player setDir ([player,_pd] call BIS_fnc_dirTo);
		"LOCAL_PLAYER" setMarkerAlphaLocal 1;
		openMap false;
		
		//INICIA VIDA
		player allowDamage true;
		playSound "tema";
		if (isNil "BRPVP_jaNasceuUma") then {
			BRPVP_jaNasceuUma = true;
		};
		
		//LIGA MODO ADMIN CASO SEJA UM ADMIN
		if (BRPVP_trataseDeAdmin) then {BRPVP_onMapSingleClick = BRPVP_adminMapaClique;} else {BRPVP_onMapSingleClick = BRPVP_padMapaClique;};
		
		//MONITORA QUEDA E SPAWNA QUADRICICLO
		[] spawn {
			["Press [SPACE BAR] to open your parachute.\n[SHIFT + W] or [SHIFT + S] to perform sky diver.",10] call BRPVP_hint;
			
			//INICIA SKY DIVER
			BRPVP_paraParam = [[+0.025,-0.006],[+0.005,+0.020],false,false];
			BRPVP_nascendoParaQuedas = true;

			//ESPERA CHEGAR NO CHAO OU MORRER NA QUEDA
			waitUntil {((getPos player select 2) min (getPosATL player select 2)) < 1 || vehicle player != player || !alive player};
			BRPVP_nascendoParaQuedas = nil;
			waitUntil {((getPos player select 2) min (getPosATL player select 2)) < 1 || !alive player};
			moveOut player;
			cutText ["","PLAIN"];

			if (alive player) then {
				//ADD INITIAL LOOT
				_aP = ["hgun_PDW2000_F","SMG_02_F"] call BIS_fnc_selectRandom;
				_mP = getArray (configfile >> "cfgWeapons" >> _aP >> "magazines") call BIS_fnc_selectRandom;
				player addWeapon _aP;
				player addMagazine _mP;
				player addMagazine _mP;
				player addMagazine _mP;
				player addMagazine _mP;
				player addWeapon "NVGoggles";
				player addWeapon "Binocular";
				
				//SPAWNA QUADRICICLO
				_pos = getPosATL player;
				_pos set [0,(_pos select 0) + 2 + (random 5)];
				_pos set [1,(_pos select 1) + 2 + (random 5)];
				_pos set [2,0];
				_bicicleta = createVehicle [BRPVP_veiculoTemporarioNascimento,_pos,[],0,"NONE"];
				_bicicleta setVariable ["own",player getVariable "id_bd",true];
				_bicicleta setVariable ["stp",3,true];
				
				//TIRA ITENS DO QUADRICICLO
				clearWeaponCargoGlobal _bicicleta;
				clearMagazineCargoGlobal _bicicleta;
				clearITemCargoGlobal _bicicleta;
				clearBackpackCargoGlobal _bicicleta;
				
				//MAIS QUADRICICLO
				player reveal _bicicleta;
				player setVariable ["qdcl",_bicicleta];
				_bicicleta setVariable ["tmp",serverTime,true];
				["The quadricycle will remain for " + (BRPVP_tempoDeVeiculoTemporarioNascimento call BRPVP_tempoPorExtenso) + "!",5] call BRPVP_hint;
				
				//MENSAGEM DO 'INSERT'
				["PRESS ALT + Q FOR PLAYER MENU.",5] call BRPVP_hint;
			};
		};
	};
	if (_posType == "ground") then {
		_posNasc = BRPVP_posicaoDeNascimento select 1;
		BRPVP_onMapSingleClick = BRPVP_padMapaClique;
		player setPos ([_posNasc,2.5,random 360] call BIS_fnc_relpos);
		_pd = player getVariable ["pd",BRPVP_centroMapa];
		player setDir ([player,_pd] call BIS_fnc_dirTo);
		"LOCAL_PLAYER" setMarkerAlphaLocal 1;
		openMap false;
		
		//INICIA VIDA
		player allowDamage true;
		playSound "tema";
		if (isNil "BRPVP_jaNasceuUma") then {
			BRPVP_jaNasceuUma = true;
		};
		
		//LIGA MODO ADMIN CASO SEJA UM ADMIN
		if (BRPVP_trataseDeAdmin) then {BRPVP_onMapSingleClick = BRPVP_adminMapaClique;} else {BRPVP_onMapSingleClick = BRPVP_padMapaClique;};
		
		//ADD INITIAL LOOT
		_aP = ["hgun_PDW2000_F","SMG_02_F"] call BIS_fnc_selectRandom;
		_mP = getArray (configfile >> "cfgWeapons" >> _aP >> "magazines") call BIS_fnc_selectRandom;
		player addWeapon _aP;
		player addMagazine _mP;
		player addMagazine _mP;
		player addMagazine _mP;
		player addMagazine _mP;
		player addWeapon "NVGoggles";
		player addWeapon "Binocular";
		
		//MENSAGEM DO 'INSERT'
		["PRESS ALT + Q FOR PLAYER MENU.",5] call BRPVP_hint;
	};
};

if (_revive) then {
	//UPDATE PLAYER ICON ON MAP
	["geral"] call BRPVP_atualizaIcones;
} else {
	//LIGA DEBUG
	call BRPVP_atualizaDebug;

	//MOSTRA ICONES
	[] call BRPVP_atualizaIcones;

	//ATUALIZA DISTANCIA DE VISAO
	if (viewDistance != BRPVP_viewDist) then {setViewDistance BRPVP_viewDist;};
	if (getObjectViewDistance select 0 != BRPVP_viewObjsDist) then {setObjectViewDistance BRPVP_viewObjsDist;};
};

//WHO CAN SEE ME
player setVariable ["own",player getVariable "id_bd",true];
player setVariable ["stp",2,true];

//SPAWN OK
player setVariable ["sok",true,true];

//UPDATE AMIGOS
call BRPVP_daUpdateNosAmigos;
BRPVP_PUSV = true;
publicVariable "BRPVP_PUSV";

//UNBLOCK KEYBOARD
BRPVP_keyBlocked = false;

BRPVP_disabledDamage = 0;
BRPVP_disabledBleed = 0;

player enableStamina false;

diag_log "[BRPVP FILE] nascimento_player.sqf END REACHED";