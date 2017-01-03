diag_log "[BRPVP FILE] sistema_menus.sqf STARTING";

//FUNCOES DAS OPCOES DE MENU
BRPVP_menuSleep = 0;
BRPVP_menuIdc = -1;
BRPVP_menuIdcSafe = 30;
BRPVP_menuCustomKeysOff = false;
BRPVP_deixarDeConfiar = {
	_meusAmigosId = player getVariable "amg";
	_meusAmigosId = _meusAmigosId - [_this select 0];
	BRPVP_amigosAtualizaServidor = [player getVariable "id_bd",_meusAmigosId];
	publicVariableServer "BRPVP_amigosAtualizaServidor";
	[("You revoked your confidence in " + (_this select 1) + "."),5,15] call BRPVP_hint;
	_playerAvisar = objNull;
	{
		if ((_x getVariable ["id_bd",-1]) == (_this select 0)) exitWith {_playerAvisar = _x;};
	} forEach allPlayers;
	BRPVP_mudouConfiancaEmVoceSV = [_playerAvisar,player,false,_meusAmigosId];
	publicVariableServer "BRPVP_mudouConfiancaEmVoceSV";
	call BRPVP_daUpdateNosAmigos;
	call BRPVP_atualizaMeuStuffAmg;
	BRPVP_tempoUltimaAtuAmigos = time;
	0 spawn BRPVP_menuMuda;
};
BRPVP_confiarEmAlguem = {
	_meusAmigosId = player getVariable "amg";
	_meusAmigosId pushBack (_this select 0);
	BRPVP_amigosAtualizaServidor = [player getVariable "id_bd",_meusAmigosId];
	publicVariableServer "BRPVP_amigosAtualizaServidor";
	[("You trust in " + (_this select 1) + "."),3.5,15] call BRPVP_hint;
	BRPVP_mudouConfiancaEmVoceSV = [_this select 2,player,true,_meusAmigosId];
	publicVariableServer "BRPVP_mudouConfiancaEmVoceSV";
	call BRPVP_daUpdateNosAmigos;
	call BRPVP_atualizaMeuStuffAmg;
	BRPVP_tempoUltimaAtuAmigos = time;
	0 spawn BRPVP_menuMuda;
};

// FUNCOES DO SISTEMA DE MENU
BRPVP_criaImagemTag = {
	_typeOf = typeOf _this;
	if (isText (configFile >> "CfgVehicles" >> _typeOf >> "picture") && _this call BRPVP_IsMotorized) then {
		(" image='" + getText (configFile >> "CfgVehicles" >> _typeOf >> "picture") + "'")
	} else {
		" image='BRP_marcas\muro.paa'"
	};
};
BRPVP_arrayParaListaHtml = {
	params ["_arr","_sel","_cor"];
	_itensAcAb = 5;
	_idcFinal = (count _arr) - 1;
	_ini = 0;
	_fim = _idcFinal;
	if (count _arr > _itensAcAb * 2 + 1) then {
		_ajF = 0;
		if (_sel < _itensAcAb) then {_ajF = _itensAcAb - _sel;};
		_ajI = 0;
		if (_sel + _itensAcAb > _idcFinal) then {_ajI = (_sel + _itensAcAb) - _idcFinal;};
		_ini = ((_sel - _itensAcAb) max 0) - _ajI;
		_fim = ((_sel + _itensAcAb) min _idcFinal) + _ajF;
	};
	_txt = "";
	for "_u" from _ini to _fim do {
		_preFix = "<t size='1.3'>";
		_suFix = "</t><br/>";
		if (_u == _sel) then {_preFix = "<t size='1.3' color='" + _cor + "'>";};
		_txt = _txt + _preFix + (_arr select _u) + _suFix
	};
	_txt
};
BRPVP_pegaListaPlayers = {
	BRPVP_menuOpcoes = [];
	BRPVP_menuExecutaParam = [];
	{
		if (alive _x && _x getVariable ["sok",false]) then {
			_id_bd = _x getVariable ["id_bd",-1];
			if (_id_bd >= 0) then {
				BRPVP_menuOpcoes pushBack (str _id_bd + " - " + name _x);
				BRPVP_menuExecutaParam pushBack _x;
			};
		};
	} forEach (allPlayers - [player]);
};
BRPVP_pegaListaPlayersAll = {
	BRPVP_menuOpcoes = [];
	BRPVP_menuExecutaParam = [];
	{
		if (_x getVariable ["sok",false]) then {
			_id_bd = _x getVariable ["id_bd",-1];
			if (_id_bd >= 0) then {
				BRPVP_menuOpcoes pushBack (str _id_bd + " - " + name _x);
				BRPVP_menuExecutaParam pushBack _x;
			};
		};
	} forEach (allPlayers - [player]);
};
BRPVP_menuMuda = {
	BRPVP_menuCustomKeysOff = true;
	_inicio = time;
	_menuIdcAntigo = if (_this != BRPVP_menuIdc) then {BRPVP_menuIdc} else {BRPVP_menuIdcSafe};
	BRPVP_menuIdc = _this;
	BRPVP_menuForceExit = {false};
	call (BRPVP_menu select _this);
	if (count BRPVP_menuOpcoes == 0) exitWith {
		playSound "erro";
		["No options to show!",0] call BRPVP_hint;
		_menuIdcAntigo spawn BRPVP_menuMuda;
	};
	_mPos = BRPVP_menuPos select BRPVP_menuIdc;
	if (_mPos < (count BRPVP_menuOpcoes) - 1) then {
		BRPVP_menuOpcoesSel = _mPos;
	} else {
		BRPVP_menuOpcoesSel = (count BRPVP_menuOpcoes) - 1;
	};
	//BRPVP_menuExtraLigado = true;
	call BRPVP_atualizaDebugMenu;
	_passou = time - _inicio;
	if (_passou < BRPVP_menuSleep) then {sleep (BRPVP_menuSleep - _passou);};
	BRPVP_menuCustomKeysOff = false;
};
BRPVP_extraMenuCanBeCloseForced = false;
BRPVP_iniciaMenuExtra = {
	private ["_id","_canForcePrevious","_newCanBeForced"];
	if (typeName _this == "SCALAR") then {
		_id = _this;
		_canForcePrevious = BRPVP_extraMenuCanBeCloseForced;
		_newCanBeForced = false;
	};
	if (typeName _this == "ARRAY") then {
		_id = (_this select 0);
		_canForcePrevious = BRPVP_extraMenuCanBeCloseForced;
		_newCanBeForced = (_this select 1);
	};
	if ((!BRPVP_menuExtraLigado && !BRPVP_construindo) || (_canForcePrevious && !BRPVP_construindo)) then {
		BRPVP_menuExtraLigado = true;
		BRPVP_extraMenuCanBeCloseForced = _newCanBeForced;
		_id spawn BRPVP_menuMuda;
		playSound "achou_loot";
		[] spawn {
			_priority = 410;
			_handle = -1;
			while {_handle == -1} do {
				_handle = ppEffectCreate ["DynamicBlur",_priority];
				_priority = _priority + 1;
			};
			_handle ppEffectEnable true;
			_handle ppEffectAdjust [2.25];
			_handle ppEffectCommit 0;
			waitUntil {!BRPVP_menuExtraLigado};
			_handle ppEffectEnable false;
			ppEffectDestroy _handle;
		};		
		true
	} else {
		["You need to close the actual menu first!",0] call BRPVP_hint;
		playSound "erro";
		false
	};
};
BRPVP_menuHtml = {
	_html = call (BRPVP_menuCabecalhoHtml select BRPVP_menuIdc);
	_html = _html + ([BRPVP_menuOpcoes,BRPVP_menuOpcoesSel,BRPVP_menuCorSelecao] call BRPVP_arrayParaListaHtml);
	if (BRPVP_menuTipoImagem == 1) then {_html = _html + "<br/>" + BRPVP_menuImagem;};
	if (BRPVP_menuTipoImagem == 2) then {_html = _html + "<br/>" + (BRPVP_menuImagem select BRPVP_menuOpcoesSel);};
	_html = _html + (call (BRPVP_menuRodapeHtml select BRPVP_menuIdc));
	_html
};

//CABECALHO DO MENU
BRPVP_menuCabecalhoHtml = [
	{"<t align='center' size='1.8' color='#FFFFFF'>CHOOSE AN OPTION:</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>PEOPLE I TRUST</t><br/><br/><t size='1.15' align='center' color='#FFFFFF'>List of persons you trust.</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>WHO TRUST ME?</t><br/><br/><t size='1.15' align='center' color='#FFFFFF'>People that trust in me.</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>RECIPROCAL TRUST</t><br/><br/><t size='1.15' align='center' color='#FFFFFF'>People i trust and that trust in me reciprocally.</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>ADD NEW TRUSTED ONE</t><br/><br/><t size='1.15' align='center' color='#FFFFFF'>Select the person you want to trust.</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>REVOKE A TRUST</t><br/><br/><t size='1.15' align='center' color='#FFFFFF'>Select a person to revoke your trust.</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>YOUR STATISTICS:</t><br/><br/><t size='1.15' align='center' color='#FFFFFF'>Your life is on those numerology bellow!</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>SERVER RANKING:</t><br/><br/><t size='1.15' align='center' color='#FFFFFF'>See the server Top 10 for each statistic. Can find yourself in any?</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>SPECIFIC RANKING:</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>CHOOSE SECTION:</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>SECTION " + BRPVP_menuVar1 + "<br/>PRODUCT TYPE?</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>SECTION " + BRPVP_menuVar1 + "<br/>TYPE " + BRPVP_menuVar2 + "<br/>CHOOSE A PRODUCT:</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>CONFIRM SHOPPING?</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>CHOOSE A SIDE</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>" + BRPVP_menuVar1 + "</t><br/><t align='center' size='1.8' color='#FFFFFF'>CHOOSE A FACTION</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>" + BRPVP_menuVar1 + "</t><br/><t align='center' size='1.8' color='#FFFFFF'>" + BRPVP_menuVar2 + "</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>" + BRPVP_menuVar1 + "</t><br/><t align='center' size='1.8' color='#FFFFFF'>" + BRPVP_menuVar2 + "</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>ACTION OVER A PLAYER</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>BRING PLAYER TO ME</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>GO TO A PLAYER</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>HEAL A PLAYER</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>KILL A PLAYER</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>YOUR PROPERTIES</t><br/>								<img size='5.0' align='center'" + (BRPVP_stuff call BRPVP_criaImagemTag) + "/><br/><t align='center' size='1.3' color='#FFFFFF'>" + getText (configFile >> "CfgVehicles" >> BRPVP_stuff call BRPVP_typeOf >> "displayName") + "</t><br/><t align='center' size='1.3' color='#CCCCCC'> Health: " + str round ((1 - (damage BRPVP_stuff)) * 100)  + " %</t><br/><br/><t align='center' size='1.5' color='#FFFFFF'>Choose an option:</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>CHOOSE SHARE TYPE</t><br/>							<img size='5.0' align='center'" + (BRPVP_stuff call BRPVP_criaImagemTag) + "/><br/><t align='center' size='1.3' color='#FFFFFF'>" + getText (configFile >> "CfgVehicles" >> BRPVP_stuff call BRPVP_typeOf >> "displayName") + "</t><br/><br/><t align='center' size='1.5' color='#66CC66'>Actual Share: </t><t align='center' size='1.5' color='#77FF77'>" + (BRPVP_stuff call BRPVP_compEstado) + "</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>SELECT A PLAYER TO RECEIVE YOUR PROPERTIE</t><br/>	<img size='5.0' align='center'" + (BRPVP_stuff call BRPVP_criaImagemTag) + "/><br/><t align='center' size='1.3' color='#FFFFFF'>" + getText (configFile >> "CfgVehicles" >> BRPVP_stuff call BRPVP_typeOf >> "displayName") + "</t><br/><br/><t align='center' size='1.5' color='#66CC66'>Choose a player!</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>CONFIRM EXPROPRIATION</t><br/>						<img size='5.0' align='center'" + (BRPVP_stuff call BRPVP_criaImagemTag) + "/><br/><t align='center' size='1.3' color='#FFFFFF'>" + getText (configFile >> "CfgVehicles" >> BRPVP_stuff call BRPVP_typeOf >> "displayName") + "</t><br/><br/><t align='center' size='1.5' color='#66CC66'>Choose an option:</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>CONFIRM DESTRUCTION</t><br/>							<img size='5.0' align='center'" + (BRPVP_stuff call BRPVP_criaImagemTag) + "/><br/><t align='center' size='1.3' color='#FFFFFF'>" + getText (configFile >> "CfgVehicles" >> BRPVP_stuff call BRPVP_typeOf >> "displayName") + "</t><br/><br/><t align='center' size='1.5' color='#66CC66'>Choose an option:</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>INSIDE OR REALLY NEAR</t><br/>						<img size='5.0' align='center'" + (BRPVP_stuff call BRPVP_criaImagemTag) + "/><br/><t align='center' size='1.3' color='#FFFFFF'>" + getText (configFile >> "CfgVehicles" >> BRPVP_stuff call BRPVP_typeOf >> "displayName") + "</t><br/><br/><t align='center' size='1.3' color='#FFFFFF'>Only players that trust in you will be show.</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>INSIDE OR IN LESS THAN 10 M</t><br/>					<img size='5.0' align='center'" + (BRPVP_stuff call BRPVP_criaImagemTag) + "/><br/><t align='center' size='1.3' color='#FFFFFF'>" + getText (configFile >> "CfgVehicles" >> BRPVP_stuff call BRPVP_typeOf >> "displayName") + "</t><br/><br/><t align='center' size='1.3' color='#FFFFFF'>Only players that trust in you will be show.</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>ADMIN MENU</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>PLAYER MENU</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>REMOVE ITEMS</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>SELECT THE A PLAYER</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>TRNASFER TO PLAYER:<br/>" + name BRPVP_menuVar1 + "</t><br/><t align='center' size='1.8' color='#FFFFFF'>SELECT AMOUNT:</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>CONFIRM TRANSFER OF $ " + str  BRPVP_menuVar2 + " TO PLAYER " + name BRPVP_menuVar1 + "</t><br/><br/>"},
	{"<img size='2.0' align='center' image='BRP_imagens\interface\box.paa'/> <t align='center' size='1.8' color='#FFFFFF'>SPECIAL ITEMS</t> <img size='2.0' align='center' image='BRP_imagens\interface\box.paa'/><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>SELECT DAY HOUR</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>SELECT HOUR MINUTES</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>SET TIME MULTIPLIER</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>SET WEATHER: CLOUDS</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>SET WEATHER: RAIN</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>SET WEATHER: WIND</t><br/><t align='center' size='1.3' color='#FF0000'>Wind direction will be set to your player direction.</t><br/><br/>"},
	{"<t align='center' size='1.8' color='#FFFFFF'>SET WEATHER: GUSTS</t><br/><br/>"}
];

//CORPO DO MENU
BRPVP_menu = [
	//MENU 0
	{
		BRPVP_menuSleep = 0;
		BRPVP_menuTipo = 0;
		BRPVP_menuTipoImagem = 1; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		BRPVP_menuImagem = "<img size='4.0' align='center' image='BRP_imagens\interface\amigo_color.paa'/>";
		BRPVP_menuCorSelecao = "#FF3333";
		BRPVP_menuDestino = [1,2,3,4,5];
		BRPVP_menuCodigo = {};
		BRPVP_menuVoltar = {30 spawn BRPVP_menuMuda;};
		BRPVP_menuOpcoes = [
			"People i trust?",
			"Who trust me?",
			"Reciprocal trust",
			"Trust someone (on-line)",
			"Revoke a trust"
		];
	},
	
	//MENU 1
	{
		BRPVP_menuTipo = 1;
		BRPVP_menuCorSelecao = "#DDDDDD";
		BRPVP_pegaNomePeloIdBd1 = [player getVariable "amg",player,false];
		publicVariableServer "BRPVP_pegaNomePeloIdBd1";
		BRPVP_pegaNomePeloIdBd1Retorno = nil;
		waitUntil {!isNil "BRPVP_pegaNomePeloIdBd1Retorno"};
		BRPVP_menuOpcoes = BRPVP_pegaNomePeloIdBd1Retorno;
		BRPVP_menuVoltar = {0 spawn BRPVP_menuMuda;};
	},
	
	//MENU 2
	{
		BRPVP_menuTipo = 1;
		BRPVP_menuCorSelecao = "#DDDDDD";
		BRPVP_pegaNomePeloIdBd2 = [player getVariable ["id_bd",-1],player];
		publicVariableServer "BRPVP_pegaNomePeloIdBd2";
		BRPVP_pegaNomePeloIdBd2Retorno = nil;
		waitUntil {!isNil "BRPVP_pegaNomePeloIdBd2Retorno"};
		BRPVP_menuOpcoes = BRPVP_pegaNomePeloIdBd2Retorno;
		BRPVP_menuVoltar = {0 spawn BRPVP_menuMuda;};
	},
	
	//MENU 3
	{
		BRPVP_menuTipo = 1;
		BRPVP_menuCorSelecao = "#DDDDDD";
		BRPVP_pegaNomePeloIdBd3 = [player getVariable "amg",player getVariable "id_bd",player];
		publicVariableServer "BRPVP_pegaNomePeloIdBd3";
		BRPVP_pegaNomePeloIdBd3Retorno = nil;
		waitUntil {!isNil "BRPVP_pegaNomePeloIdBd3Retorno"};
		BRPVP_menuOpcoes = BRPVP_pegaNomePeloIdBd3Retorno;
		BRPVP_menuVoltar = {0 spawn BRPVP_menuMuda;};
	},
	
	//MENU 4
	{
		BRPVP_menuTipo = 2;
		BRPVP_menuOpcoes = [];
		BRPVP_menuExecutaParam = [];
		{
			_id_bd = _x getVariable ["id_bd",-1];
			if (_id_bd >= 0) then {
				if !(_id_bd in (player getVariable "amg")) then {
					BRPVP_menuOpcoes pushBack (_x getVariable "nm");
					BRPVP_menuExecutaParam pushBack [_id_bd,_x getVariable "nm",_x];
				};
			};
		} forEach (allPlayers - [player]);
		BRPVP_menuExecutaFuncao = BRPVP_confiarEmAlguem;
		BRPVP_menuVoltar = {0 spawn BRPVP_menuMuda;};
	},
	
	//MENU 5
	{
		BRPVP_menuTipo = 2;
		BRPVP_pegaNomePeloIdBd1 = [player getVariable "amg",player,true];
		publicVariableServer "BRPVP_pegaNomePeloIdBd1";
		BRPVP_pegaNomePeloIdBd1Retorno = nil;
		waitUntil {!isNil "BRPVP_pegaNomePeloIdBd1Retorno"};
		BRPVP_menuOpcoes = BRPVP_pegaNomePeloIdBd1Retorno select 0;
		BRPVP_menuExecutaParam = [];
		{BRPVP_menuExecutaParam append [[BRPVP_pegaNomePeloIdBd1Retorno select 1 select _forEachIndex,_x]];} forEach BRPVP_menuOpcoes;
		BRPVP_menuExecutaFuncao = BRPVP_deixarDeConfiar;
		BRPVP_menuVoltar = {0 spawn BRPVP_menuMuda;};
	},
	
	//MENU 6
	{
		BRPVP_menuSleep = 0;
		BRPVP_menuTipo = 1;
		BRPVP_menuTipoImagem = 2; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		_experiencia = player getVariable ["exp",BRPVP_experienciaZerada];
		BRPVP_menuImagem = [];
		{BRPVP_menuImagem append ["<img size='3.0' align='center' image='BRP_imagens\interface\experiencia.paa'/><t size='2.5' align='center'>" + str _x + " </t>"];} forEach _experiencia;
		BRPVP_menuCorSelecao = "#FF3333";
		BRPVP_menuOpcoes = BRPVP_expLegenda;
		BRPVP_menuVoltar = {30 spawn BRPVP_menuMuda;};
	},
	
	//MENU 7
	{
		BRPVP_menuSleep = 0;
		BRPVP_menuTipo = 0;
		BRPVP_menuTipoImagem = 0; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		BRPVP_menuImagem = "";
		BRPVP_menuCorSelecao = "#FF3333";
		BRPVP_menuDestino = 8;
		BRPVP_menuCodigo = {
			BRPVP_menuVar1 = BRPVP_menuOpcoes select BRPVP_menuOpcoesSel;
			BRPVP_menuVar2 = BRPVP_menuOpcoesSel;
		};
		BRPVP_menuVoltar = {30 spawn BRPVP_menuMuda;};
		BRPVP_menuOpcoes = BRPVP_expLegenda;
	},
	
	//MENU 8
	{
		BRPVP_menuTipo = 1;
		BRPVP_menuTipoImagem = 1; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		BRPVP_menuImagem = "<t size='2.0' color='#FFFF33' align='center'>" + BRPVP_menuVar1 + "</t><br/><img size='2.0' align='center' image='BRP_imagens\interface\top_10.paa'/>";
		BRPVP_menuCorSelecao = "#DDDDDD";
		BRPVP_pegaTop10Estatistica = [BRPVP_menuVar2,player];
		publicVariableServer "BRPVP_pegaTop10Estatistica";
		BRPVP_pegaTop10EstatisticaRetorno = nil;
		waitUntil {!isNil "BRPVP_pegaTop10EstatisticaRetorno"};
		BRPVP_menuOpcoes = BRPVP_pegaTop10EstatisticaRetorno;
		BRPVP_menuVoltar = {7 spawn BRPVP_menuMuda;};
	},
	
	//MENU 9
	{
		BRPVP_menuIdcSafe = 9;
		BRPVP_menuSleep = 0;
		BRPVP_menuTipo = 0;
		BRPVP_menuTipoImagem = 1; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		BRPVP_menuImagem = "<img size='4.0' align='center' image='BRP_imagens\interface\dinheiro.paa'/>";
		BRPVP_menuCorSelecao = "#FF3333";
		BRPVP_menuDestino = 10;
		BRPVP_menuOpcoes = [];
		BRPVP_menuVal = [];
		{
			BRPVP_menuOpcoes pushBack (BRPVP_mercadoNomes select _x);
			BRPVP_menuVal pushBack _x;
		} forEach (BRPVP_mercadoresEstoque select BRPVP_mercadorIdc1 select 0);
		BRPVP_menuCodigo = {
			BRPVP_mercadorIdc2 = BRPVP_menuVal select BRPVP_menuOpcoesSel;
			BRPVP_menuVar1 = BRPVP_menuOpcoes select BRPVP_menuOpcoesSel;
		};
		BRPVP_menuVoltar = {
			if (count BRPVP_compraItensTotal > 0) then {
				12 spawn BRPVP_menuMuda;
			} else {
				BRPVP_menuExtraLigado = false;
				call BRPVP_atualizaDebug;
			};
		};
		BRPVP_menuPos set [10,0];
		BRPVP_menuPos set [11,0];
		BRPVP_menuPos set [12,0];		
	},
	
	//MENU 10
	{
		BRPVP_menuTipoImagem = 1; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		_precoBase = BRPVP_mercadoPrecos select BRPVP_mercadorIdc2;
		BRPVP_menuImagem = "<t size='2.0' color='#FFFF33' align='center'>Base: $ " + str round _precoBase + "</t>";
		BRPVP_menuDestino = 11;
		BRPVP_menuCodigo = {
			BRPVP_mercadorIdc3 = BRPVP_menuOpcoesSel;
			BRPVP_menuVar2 = BRPVP_menuOpcoes select BRPVP_menuOpcoesSel;
		};
		BRPVP_menuVoltar = {9 spawn BRPVP_menuMuda;};
		BRPVP_menuOpcoes = BRPVP_mercadoNomesNomes select BRPVP_mercadorIdc2;
	},
	
	//MENU 11
	{
		BRPVP_menuTipoImagem = 2; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		BRPVP_menuOpcoes = [];
		BRPVP_menuImagem = [];
		BRPVP_menuVal = [];
		_txt = "<t size='2.0' color='#FFFF33' align='center'>Price: $ %1</t><br/><img size='6.0' align='center' image='%2'/>";
		{
			if (_x select 0 == BRPVP_mercadorIdc2 && _x select 1 == BRPVP_mercadorIdc3) then {
				private ["_imagem","_nomeBonito"];
				_it = _x select 3;
				_idc = BRPVP_specialItems find _it;
				if (_idc >= 0) then {
					_imagem = BRPVP_specialItemsImages select _idc;
					_nomeBonito = BRPVP_specialItemsNames select _idc;
				} else {
					_imagem = "BRP_imagens\interface\amigo_color.paa";
					_nomeBonito = "ITEM ?";
					_isM = isClass (configFile >> "CfgMagazines" >> _it);
					if (_isM) then {
						_imagem = getText (configFile >> "CfgMagazines" >> _it >> "picture");
						_nomeBonito = getText (configFile >> "CfgMagazines" >> _it >> "displayName");
					} else {
						_isW = isClass (configFile >> "CfgWeapons" >> _it);
						if (_isW) then {
							_imagem = getText (configFile >> "CfgWeapons" >> _it >> "picture");
							_nomeBonito = getText (configFile >> "CfgWeapons" >> _it >> "displayName");
						} else {
							_isV = isClass (configFile >> "CfgVehicles" >> _it);
							if (_isV) then {
								_imagem = getText (configFile >> "CfgVehicles" >> _it >> "picture");
								_nomeBonito = getText (configFile >> "CfgVehicles" >> _it >> "displayName");
							};
						};
					};
				};
				_preco = (BRPVP_mercadoPrecos select BRPVP_mercadorIdc2) * (_x select 4);
				BRPVP_menuOpcoes pushBack _nomeBonito;
				BRPVP_menuImagem pushBack format[_txt,round _preco,_imagem];
				BRPVP_menuVal pushBack [_it,_preco];
			};
		} forEach BRPVP_mercadoItens;
		BRPVP_menuDestino = 11;
		BRPVP_menuCodigo = {(BRPVP_menuVal select BRPVP_menuOpcoesSel) call BRPVP_comprouItem;};
		BRPVP_menuVoltar = {10 spawn BRPVP_menuMuda;};
	},
	
	//MENU 12
	{
		BRPVP_menuTipo = 2;
		BRPVP_menuTipoImagem = 1; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		BRPVP_menuImagem = "<img size='4.0' align='center' image='BRP_imagens\interface\dinheiro.paa'/>";
		BRPVP_menuOpcoes = ["Check/Remove","Buy","Cancel"];
		BRPVP_menuExecutaParam = [0,1,2];
		BRPVP_menuExecutaFuncao = {
			if (_this == 0) then {
				31 spawn BRPVP_menuMuda;
			} else {
				BRPVP_menuExtraLigado = false;
				call BRPVP_atualizaDebug;
				if (_this == 1) then {
					call BRPVP_comprouItemFinaliza;
				};
			};
		};
		BRPVP_menuVoltar = {9 spawn BRPVP_menuMuda;};
	},
	
	//MENU 13
	{
		BRPVP_menuSleep = 0;
		BRPVP_menuTipo = 0;
		BRPVP_menuTipoImagem = 2; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		BRPVP_menuImagem = [];
		BRPVP_menuCorSelecao = "#FF3333";
		BRPVP_menuDestino = 14;
		BRPVP_menuOpcoes = [];
		{
			_lado = _x select 0;
			if (!(_lado in BRPVP_menuOpcoes) && _lado in (BRPVP_vendaveAtivos select 0)) then {
				BRPVP_menuOpcoes append [_lado];
				BRPVP_menuImagem append ["<img size='6.0' align='center' image='BRP_imagens\interface\" + _lado + ".paa'/>"];
			};
		} forEach BRPVP_tudoA3;
		BRPVP_menuCodigo = {
			BRPVP_menuVar1 = BRPVP_menuOpcoes select BRPVP_menuOpcoesSel;
			BRPVP_menuVar4 = BRPVP_menuImagem select BRPVP_menuOpcoesSel;
		};
		BRPVP_menuVoltar = {
			BRPVP_menuExtraLigado = false;
			call BRPVP_atualizaDebug;
		};
	},

	//MENU 14
	{
		BRPVP_menuTipoImagem = 1; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		BRPVP_menuImagem = BRPVP_menuVar4;
		BRPVP_menuDestino = 15;
		BRPVP_menuOpcoes = [];
		{
			_lado = _x select 0;
			_fac = _x select 1;
			if (!(_fac in BRPVP_menuOpcoes) && _lado == BRPVP_menuVar1) then {
				BRPVP_menuOpcoes append [_fac];
			};
		} forEach BRPVP_tudoA3;
		BRPVP_menuCodigo = {BRPVP_menuVar2 = BRPVP_menuOpcoes select BRPVP_menuOpcoesSel;};
		BRPVP_menuVoltar = {13 spawn BRPVP_menuMuda;};
	},
	
	//MENU 15
	{
		BRPVP_menuTipoImagem = 1; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		BRPVP_menuImagem = BRPVP_menuVar4;
		BRPVP_menuDestino = 16;
		BRPVP_menuOpcoes = [];
		{
			_lado = _x select 0;
			_fac = _x select 1;
			_tipo = _x select 2;
			if (!(_tipo in BRPVP_menuOpcoes) && _tipo in (BRPVP_vendaveAtivos select 1) && _lado == BRPVP_menuVar1 && _fac == BRPVP_menuVar2) then {
				BRPVP_menuOpcoes append [_tipo];
			};
		} forEach BRPVP_tudoA3;
		BRPVP_menuCodigo = {BRPVP_menuVar3 = BRPVP_menuOpcoes select BRPVP_menuOpcoesSel;};
		BRPVP_menuVoltar = {14 spawn BRPVP_menuMuda;};
	},
	
	//MENU 16
	{
		BRPVP_menuTipoImagem = 2; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		BRPVP_menuImagem = [];
		BRPVP_menuDestino = -1;
		BRPVP_menuOpcoes = [];
		BRPVP_menuVal = [];
		{
			_x params ["_lado","_fac","_tipo","_classe","_descr"];
			if (_lado == BRPVP_menuVar1 && _fac == BRPVP_menuVar2 && _tipo == BRPVP_menuVar3) then {
				BRPVP_menuOpcoes append [_descr];
				_preco = BRPVP_vendaveCatsPreco select (BRPVP_vendaveCats find BRPVP_menuVar3);
				if (BRPVP_menuVar1 == "CIVIL") then {
					_preco = round (_preco * BRPVP_vendaveCivilCut);
				} else {
					_preco = round (_preco * BRPVP_vendaveCivilCut * 1.25);
				};
				BRPVP_menuVal append [[_classe,_preco]];
				_imagem = (getText (configFile >> "CfgVehicles" >> _classe >> "picture"));
				BRPVP_menuImagem append ["<t size='2.0' color='#FFFF33' align='center'>Price: $ " + str _preco + "</t><br/><img size='6.0' align='center' image='" + _imagem + "'/>"];
			};
		} forEach BRPVP_tudoA3;
		BRPVP_menuCodigo = {
			_mult = BRPVP_vendaveAtivos select 2;
			_preco = (BRPVP_menuVal select BRPVP_menuOpcoesSel select 1) * _mult;
			_posS = getPosATL player;
			if (player call BRPVP_qjsValorDoPlayer >= _preco) then {
				_nulo = [_posS,_mult,_preco,BRPVP_menuOpcoesSel] spawn {
					params ["_posS","_mult","_preco","_BRPVP_menuOpcoesSel"];
					if (_mult > 0) then {
						_bunker = nearestObject [player,"Land_Bunker_F"];
						BRPVP_tocaSom = [_bunker,"elevador",0.1];
						publicVariable "BRPVP_tocaSom";
						_bunker say ["elevador",0.1];
						sleep 10;
					};
					_money = player getVariable ["mny",0];
					if (_money < _preco) exitWith {
						playSound "erro";
						["You don't have enough money :|",0] call BRPVP_hint;
					};
					player setVariable ["mny",(player getVariable ["mny",0]) - _preco,true];
					_veiculo = BRPVP_menuVal select _BRPVP_menuOpcoesSel select 0;
					_raio = (sizeOf _veiculo)/2;
					_posOk = [_posS,[0,0,0],0,0,200,0,_raio*0.25,_raio*0.25,_raio,true,5,20,["Man","Building","Air","LandVehicle"],["a3\plants_f\Tree\","a3\rocks_f\"],0,false] call BRPVP_achaLocal;
					_plac = if (str _posOk == "[0,0,0]") then {"NONE"} else {"CAN_COLLIDE"};
					_placRad = if (str _posOk == "[0,0,0]") then {15} else {0};
					_vObj = createVehicle [_veiculo,_posOk,[],_placRad,_plac];
					clearWeaponCargoGlobal _vObj;
					clearMagazineCargoGlobal _vObj;
					clearItemCargoGlobal _vObj;
					clearBackpackCargoGlobal _vObj;
					_vObj allowDamage false;
					_vObj setVariable ["own",player getVariable ["id_bd",-1],true];
					_vObj setVariable ["stp",player getVariable ["dstp",1],true];
					_vObj setVariable ["amg",player getVariable ["amg",[]],true];
					BRPVP_myStuff pushBack _vObj;
					["mastuff"] call BRPVP_atualizaIcones;
					_vObj setVelocity [0,0,2];
					playSound "negocio";
					playSound "ugranted";
					sleep 3;
					_estadoCons = [
						[[[],[]],[[],[]],[[],[]],[[],[]]],
						[getPosWorld _vObj,[vectorDir _vObj,vectorUp _vObj]],
						typeOf _vObj,
						_vObj getVariable ["own",-1],
						_vObj getVariable ["stp",1],
						_vObj getVariable ["amg",[]],
						""
					];
					BRPVP_adicionaConstrucaoBd = [false,_vObj,_estadoCons];
					publicVariableServer "BRPVP_adicionaConstrucaoBd";
					sleep 5;
					_vObj allowDamage true;
				};
			} else {
				["you don't have enough money :(",0] call BRPVP_hint;
				playSound "erro";
			};
			BRPVP_menuExtraLigado = false;
			call BRPVP_atualizaDebug;
		};
		BRPVP_menuVoltar = {15 spawn BRPVP_menuMuda;};
	},

	//MENU 17
	{
		BRPVP_menuTipo = 0;
		BRPVP_menuTipoImagem = 1; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		BRPVP_menuImagem = "<img size='4.0' align='center' image='BRP_imagens\interface\amigo_color.paa'/>";
		BRPVP_menuCorSelecao = "#FF3333";
		BRPVP_menuDestino = [18,19,20,21];
		BRPVP_menuCodigo = {BRPVP_menuVoltar = {17 spawn BRPVP_menuMuda;};};
		BRPVP_menuVoltar = {29 spawn BRPVP_menuMuda;};
		BRPVP_menuOpcoes = [
			"Bring player to me",
			"Teleport to a player",
			"Heal players",
			"Kill players"
		];
	},

	//MENU 18
	{
		BRPVP_menuTipo = 2;
		call BRPVP_pegaListaPlayers;
		BRPVP_menuExecutaFuncao = {
			if (!isNull _this && {alive _this}) then {
				_pass = false;
				_vip = false;
				_dvr = false;
				_ishigh = false;
				_pv = vehicle _this;
				_BRPVP_setPos = {
					params ["_unit"];
					_unit allowDamage false;
					if (vehicle _unit != _unit) then {
						moveOut _unit;
						sleep 0.001;
					};
					_av = vehicle player;
					if (_av != player) then {
						BRPVP_moveInServer = [];
						if (_av emptyPositions "Cargo" > 0) then {
							BRPVP_moveInServer = [_unit,_av,"Cargo"];
						} else {
							if (_av emptyPositions "Gunner" > 0) then {
								BRPVP_moveInServer = [_unit,_av,"Gunner"];
							} else {
								if (_av emptyPositions "Commander" > 0) then {
									BRPVP_moveInServer = [_unit,_av,"Commander"];
								} else {
									if (_av emptyPositions "Driver" > 0) then {
										BRPVP_moveInServer = [_unit,_av,"Driver"];
									} else {
										if (getposATL _av select 2 < 2 && speed _av < 2) then {
											_unit setVehiclePosition [ASLToAGL getPosASL player,[],5,"NONE"];
											[(_unit getVariable "nm") + " was moved.",5,7.5] call BRPVP_hint;
										} else {
											["Your vehicle is in use and\n don't have empty positions.\nNot moved...",5,7.5] call BRPVP_hint;
										};
									};
								};
							};
						};
						if (count BRPVP_moveInServer > 0) then {
							publicVariableServer "BRPVP_moveInServer";
							[(_unit getVariable "nm") + " was moved.",5,7.5] call BRPVP_hint;
						};
					} else {
						_unit setVehiclePosition [ASLToAGL getPosASL player,[],2.5,"NONE"];
						[(_this getVariable "nm") + " was moved.",5,7.5] call BRPVP_hint;
					};
					sleep 0.001;
					_unit allowDamage true;
				};
				if (_pv != _this) then {
					_vip = _pv isKindOf "B_Parachute";
					_pass = true;
					if (driver _pv == _this) then {
						_dvr = true;
						if ((getPosATL _pv select 2) > 2) then {
							_ishigh = true;
						};
					};
				};
				if (!_pass) then {
					_this spawn _BRPVP_setPos;
				} else {
					if (!_dvr) then {
						_this spawn _BRPVP_setPos;
					} else {
						if (!_ishigh || {_vip}) then {
							_this spawn _BRPVP_setPos;
						} else {
							["The player is driver on a flying\nvehicle and can't be teleported.",0] call BRPVP_hint;
						};
					};
				};
			} else {
				playSound "erro";
			};
			BRPVP_menuExtraLigado = false;
			call BRPVP_atualizaDebug;
		};
	},

	//MENU 19
	{
		BRPVP_menuTipo = 2;
		call BRPVP_pegaListaPlayersAll;
		BRPVP_menuExecutaFuncao = {
			if (!isNull _this && {alive _this}) then {
				BRPVP_multiplicadorDanoAdmin = 0;
				if (vehicle player != player) then {
					moveOut player;
				};
				_pv = vehicle _this;
				if (_pv != _this) then {
					if (_pv emptyPositions "Cargo" > 0) then {
						player moveInCargo _pv;
					} else {
						if (_pv emptyPositions "Gunner" > 0) then {
							player moveInGunner _pv;
						} else {
							if (_pv emptyPositions "Commander" > 0) then {
								player moveInCommander _pv;
							} else {
								if (_pv emptyPositions "Driver" > 0) then {
									player moveInDriver _pv;
								} else {
									if (getposATL _pv select 2 < 2 && speed _pv < 2) then {
										player setVehiclePosition [ASLToAGL getPosASL _this,[],5,"NONE"];
									} else {
										[(_this getVariable "nm") + " is in a vehicle with no empty positions.\nMoved to near the vehicle.",5,7.5] call BRPVP_hint;
										player setVehiclePosition [ASLToAGL getPosASL _this,[],15,"NONE"];
									};
								};
							};
						};
					};
				} else {
					player setVehiclePosition [ASLToAGL getPosASL _this,[],2.5,"NONE"];
				};
				BRPVP_multiplicadorDanoAdmin = 1;
			} else {
				playSound "erro";
			};
			BRPVP_menuExtraLigado = false;
			call BRPVP_atualizaDebug;
		};
	},

	//MENU 20
	{
		BRPVP_menuTipo = 2;
		BRPVP_menuForceExit = {
			_true = !isNil "ACE_Medical";
			if (_true) then {["ACE Medical is on. Can't use this option.",0] call BRPVP_hint;};
			_true
		};
		call BRPVP_pegaListaPlayers;
		BRPVP_menuExecutaFuncao = {
			if (!isNull _this && {alive _this}) then {
				_this setDamage 0;
			} else {
				playSound "erro";
				BRPVP_menuExtraLigado = false;
				call BRPVP_atualizaDebug;
			};
		};
	},

	//MENU 21
	{
		BRPVP_menuTipo = 2;
		call BRPVP_pegaListaPlayers;
		BRPVP_menuExecutaFuncao = {
			if (!isNull _this && {alive _this}) then {
				_this setDamage 1;
			} else {
				playSound "erro";
				BRPVP_menuExtraLigado = false;
				call BRPVP_atualizaDebug;
			};
		};
	},

	//MENU 22
	{
		BRPVP_menuSleep = 0;
		BRPVP_menuTipo = 0;
		BRPVP_menuTipoImagem = 0; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		BRPVP_menuImagem = "<img size='4.0' align='center' image='BRP_imagens\interface\amigo_color.paa'/>";
		BRPVP_menuCorSelecao = "#FF3333";
		BRPVP_menuCodigo = {};
		BRPVP_menuVoltar = {
			BRPVP_menuExtraLigado = false;
			call BRPVP_atualizaDebug;
		};
		if (BRPVP_stuff call BRPVP_IsMotorized) then {
			BRPVP_menuOpcoes = ["Choose Share Type","Give to someone","Make public","Destroy"];
			BRPVP_menuDestino = [23,24,25,26];
		} else {
			if (BRPVP_stuff call BRPVP_isSimpleObject) then {
				BRPVP_menuOpcoes = ["Destroy"];
				BRPVP_menuDestino = [26];
			} else {
				if (BRPVP_stuff getVariable ["mapa",false]) then {
					if (BRPVP_stuff getVariable ["bis_disabled_Door_1",-1] == -1) then {
						BRPVP_menuOpcoes = ["Choose Share Type","Make public"];
						BRPVP_menuDestino = [23,25];
					} else {
						BRPVP_menuOpcoes = ["Make public"];
						BRPVP_menuDestino = [25];
					};
				} else {
					BRPVP_menuOpcoes = ["Choose Share Type","Destroy"];
					BRPVP_menuDestino = [23,26];
				};
			};
		};
		playSound "hint";
	},

	//MENU 23
	{
		BRPVP_menuTipo = 2;
		BRPVP_menuOpcoes = [
			"Me",
			"Me + Who i trust",
			"Me + Who i trust reciprocally",
			"Everyone",
			"No one"
		];
		if (BRPVP_stuff call BRPVP_isSimpleObject) then {
			BRPVP_menuPos set [BRPVP_menuIdc,[BRPVP_stuff,"stp",0] call BRPVP_getVariable];
		} else {
			BRPVP_menuPos set [BRPVP_menuIdc,BRPVP_stuff getVariable ["stp",0]];
		};
		BRPVP_menuExecutaParam = [0,1,2,3,4];
		BRPVP_menuExecutaFuncao = {
			BRPVP_stuff setVariable ["stp",_this,true];
			if !(BRPVP_stuff getVariable ["slv_amg",false]) then {BRPVP_stuff setVariable ["slv_amg",true,true];};
			call BRPVP_atualizaDebugMenu;
		};
		BRPVP_menuVoltar = {22 spawn BRPVP_menuMuda;};
	},

	//MENU 24
	{
		BRPVP_menuTipo = 2;
		call BRPVP_pegaListaPlayersAll;
		BRPVP_menuExecutaFuncao = {
			if (!isNull _this) then {
				[BRPVP_stuff,_this] call BRPVP_mudaDonoPropriedade;
				playSound "ugranted";
				["Propertie [" + BRPVP_stuff call BRPVP_typeOf + "] given to " + name _this + ".",4,15] call BRPVP_hint;
			} else {
				playSound "erro";
			};
			BRPVP_menuExtraLigado = false;
			call BRPVP_atualizaDebug;
		};
		BRPVP_menuVoltar = {22 spawn BRPVP_menuMuda;};
	},

	//MENU 25
	{
		BRPVP_menuTipo = 2;
		BRPVP_menuOpcoes = ["Confirm","Cancel"];
		BRPVP_menuExecutaParam = [true,false];
		BRPVP_menuExecutaFuncao = {
			if (_this) then {
				[BRPVP_stuff,""] call BRPVP_mudaDonoPropriedade;
				BRPVP_menuExtraLigado = false;
				call BRPVP_atualizaDebug;
			} else {
				22 spawn BRPVP_menuMuda;
			};
		};
		BRPVP_menuVoltar = {22 spawn BRPVP_menuMuda;};
	},
	
	//MENU 26
	{
		BRPVP_menuTipo = 2;
		BRPVP_menuOpcoes = ["Confirm","Cancel"];
		BRPVP_menuExecutaParam = [true,false];
		BRPVP_menuExecutaFuncao = {
			if (_this) then {
				_tipo = "The construction";
				if (BRPVP_stuff call BRPVP_IsMotorized) then {_tipo = "The vehicle";};
				_pAvisa = [];
				{if ([_x,BRPVP_stuff] call PDTH_distance2BoxQuad < 225) then {_pAvisa pushBack _x;};} forEach allPlayers;
				BRPVP_avisaExplosao = [BRPVP_stuff,_pAvisa];
				publicVariableServer "BRPVP_avisaExplosao";
				BRPVP_menuExtraLigado = false;
				call BRPVP_atualizaDebug;
				[BRPVP_stuff,""] call BRPVP_mudaDonoPropriedade;
			} else {
				22 spawn BRPVP_menuMuda;
			};
		};
		BRPVP_menuVoltar = {22 spawn BRPVP_menuMuda;};
	},

	//MENU 27
	{
		BRPVP_menuTipo = 1;
		BRPVP_menuCorSelecao = "#DDDDDD";
		BRPVP_menuOpcoes = [];
		_id_bd = player getVariable ["id_bd",-1];
		{
			if (_id_bd in (_x getVariable ["amg",[]]) || _x == player) then {
				if ([_x,BRPVP_stuff] call PDTH_pointIsInBox) then {
					BRPVP_menuOpcoes pushBack ((name _x) + " " + str round ((1 - damage _x) * 100) + " %");
				};
			};
		} forEach allPlayers;
		BRPVP_menuVoltar = {22 spawn BRPVP_menuMuda;};
	},

	//MENU 28
	{
		BRPVP_menuTipo = 1;
		BRPVP_menuCorSelecao = "#DDDDDD";
		BRPVP_menuOpcoes = [];
		_id_bd = player getVariable ["id_bd",-1];
		{
			if (_id_bd in (_x getVariable ["amg",[]]) || _x == player) then {
				if ([_x,BRPVP_stuff] call PDTH_distance2BoxQuad <= 100) then {
					BRPVP_menuOpcoes pushBack ((name _x) + " " + str round ((1 - damage _x) * 100) + " %");
				};
			};
		} forEach allPlayers;
		BRPVP_menuVoltar = {22 spawn BRPVP_menuMuda;};
	},
	
	//MENU 29
	{
		BRPVP_menuSleep = 0;
		BRPVP_menuTipo = 2;
		BRPVP_menuCorSelecao = "#FF3333";
		BRPVP_menuTipoImagem = 1; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		BRPVP_menuImagem = "<img size='4.0' align='center' image='BRP_imagens\interface\amigo_color.paa'/>";
		BRPVP_menuOpcoes = [
			"(" + (if (BRPVP_godMode) then {"X"} else {"   "}) + ") God Mode",
			"(" + (if (BRPVP_vePlayers) then {"X"} else {"   "}) + ") See and Access All",
			"(" + (if (BRPVP_playerIsCaptive) then {"X"} else {"   "}) + ") Invisible to AI",
			"(" + (if (BRPVP_terrenosMapaLigadoAdmin) then {"X"} else {"   "}) + ") Show All Terrains",
			"Admin Market - Items",
			"Admin Market - Vehicle",
			"Action over a player",
			"Set Day Time",
			"Set Time Multiplier",
			"Set Weather",
			"Spectator Mode",
			"MISSION: Start Bravo",
			"MISSION: Start Siege",
			"MISSION: Start Convoy",
			"MISSION: Start Plane Crash"
		];
		BRPVP_menuExecutaParam = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14];
		BRPVP_menuExecutaFuncao = {
			if (_this == 0) then {
				if (isNil "ACE_Medical") then {
					if (BRPVP_godMode) then {
						BRPVP_multiplicadorDanoAdmin = 1;
						["God Mode off.",0] call BRPVP_hint;
						BRPVP_godMode = false;
					} else {
						BRPVP_multiplicadorDanoAdmin = 0;
						["God Mode on.\nInfinite ammo. Respawn anywhere.",0] call BRPVP_hint;
						BRPVP_godMode = true;
						_curar = [player];
						_veic = vehicle player;
						if (_veic != player) then {_curar pushBack _veic;};
						{_x setDamage 0;} forEach _curar;
						_wpn = currentWeapon player;
						_amm = player ammo _wpn;
						if (_amm == 0) then {player setAmmo [_wpn,1];};
					};
					29 spawn BRPVP_menuMuda;
				} else {
					["Can't use God Mode with ACE Medical.",0] call BRPVP_hint;
				};
			};
			if (_this == 1) then {
				if (!BRPVP_vePlayers) then {
					BRPVP_vePlayers = true;
					["See and Access everything is on!",0] call BRPVP_hint;
				} else {
					BRPVP_vePlayers = false;
					["See and Access everything is off!",0] call BRPVP_hint;
				};
				BRPVP_mapDrawPrecisao = -10;
				call BRPVP_daUpdateNosAmigos;
				29 spawn BRPVP_menuMuda;
			};
			if (_this == 2) then {
				if (!BRPVP_playerIsCaptive) then {
					BRPVP_playerIsCaptive = true;
					player setCaptive true;
				} else {
					BRPVP_playerIsCaptive = false;
					player setCaptive false;
					{
						if (!isPlayer _x) then {
							_x reveal [player,1.5];
						};
					} forEach (player nearEntities ["Man",300]);
				};
				29 spawn BRPVP_menuMuda;
			};
			if (_this == 3) then {
				if (!BRPVP_terrenosMapaLigadoAdmin) then {
					if (!BRPVP_terrenosMapaLigado) then {
						BRPVP_terrenosMapaLigadoAdmin = true;
						["Terrains draw on map!",0] call BRPVP_hint;
						cutText ["CLICK ON THE TERRAIN TO GET MORE INFORMATION","PLAIN"];
						_addTIcons = {
							{
								_idc = _forEachIndex;
								_pos = _x select 0;
								_tam = _x select 1;
								_prc = _x select 4;
								_cor = "ColorRed";
								if (_prc >= 3 && _prc <= 4) then {_cor = "ColorYellow";};
								if (_prc >= 6 && _prc <= 9) then {_cor = "ColorGreen";};
								_marca = createMarkerLocal ["TERR_" + str _idc,_pos];
								_marca setMarkerShapeLocal "RECTANGLE";
								_marca setMarkerBrushLocal "SOLID";
								_marca setMarkerColorLocal _cor;
								_marca setMarkerSizeLocal [(_tam/2)*0.925,(_tam/2)*0.925];
								BRPVP_onMapSingleClickExtra = BRPVP_infoTerreno;
							} forEach BRPVP_terrenos;
						};
						["ADD TERRAIN ICONS",_addTIcons,false] call BRPVP_execFast;
						[] spawn {
							waitUntil {!BRPVP_terrenosMapaLigadoAdmin};
							["Terrains removed from map...",0] call BRPVP_hint;
							_removeTIcons = {{_idc = _forEachIndex;deleteMarkerLocal ("TERR_" + str _idc);} forEach BRPVP_terrenos;};
							["REMOVE TERRAIN ICONS",_removeTIcons,false] call BRPVP_execFast;
							BRPVP_onMapSingleClickExtra = {};
							//if (BRPVP_trataseDeAdmin) then {BRPVP_onMapSingleClick = BRPVP_adminMapaClique;} else {BRPVP_onMapSingleClick = BRPVP_padMapaClique;};
						};
					} else {
						["Turn off default terrain view first!",6,20] call BRPVP_hint;
					};
				} else {
					BRPVP_terrenosMapaLigadoAdmin = false;
					cutText ["","PLAIN"];
				};
				29 spawn BRPVP_menuMuda;
			};
			if (_this == 4) then {
				BRPVP_menuExtraLigado = false;
				[0,0,0,[player,0,0]] execVm "actions\actionTrader.sqf";
			};
			if (_this == 5) then {
				BRPVP_menuExtraLigado = false;
				_sides = ["CIVIL","CAPTALISM","COMUNISM","GUERRILLA"];
				_cats = ["Tanks","Cars","APCs","Helicopters","Anti-Air","Artillery","Turrets","Planes"];
				[0,0,0,[player,_sides,_cats,0]] execVm "actions\actionVehicleTrader.sqf";
			};
			if (_this == 6) then {
				17 spawn BRPVP_menuMuda;
			};
			if (_this == 7) then {
				36 spawn BRPVP_menuMuda;
			};
			if (_this == 8) then {
				38 spawn BRPVP_menuMuda;
			};
			if (_this == 9) then {
				39 spawn BRPVP_menuMuda;
			};
			if (_this == 10) then {
				if (!BRPVP_espectando) then {
					_pP = getPosASL player;
					_pD = damage player;
					BRPVP_espectando = true;
					BRPVP_menuExtraLigado = false;
					call BRPVP_atualizaDebug;
					["Spectate yourself in 1st person and move to exit spectator mode.",10,30,167] call BRPVP_hint;
					["Initialize",[player,[],true,true,true,true,true,true,true,true]] call BIS_fnc_EGSpectator;
					_nulo = [_pP,_pD] spawn {
						params ["_pP","_pD"];
						waitUntil {_pP distanceSqr (getPosASL player) > 1 || damage player < _pD};
						["Terminate"] call BIS_fnc_EGSpectator;
						BRPVP_espectando = false;
					};
				};
			};
			if (_this == 11) then {
				BRPVP_bravoRun = player;
				publicVariableServer "BRPVP_bravoRun";
			};
			if (_this == 12) then {
				BRPVP_siegeRun = player;
				publicVariableServer "BRPVP_siegeRun";
			};
			if (_this == 13) then {
				BRPVP_convoyRun = player;
				publicVariableServer "BRPVP_convoyRun";
			};
			if (_this == 14) then {
				BRPVP_runCorruptMissSpawn = player;
				publicVariableServer "BRPVP_runCorruptMissSpawn";
			};
		};
		BRPVP_menuVoltar = {
			BRPVP_menuExtraLigado = false;
			call BRPVP_atualizaDebug;
		};
	},
	
	//MENU 30
	{
		BRPVP_menuSleep = 0;
		BRPVP_menuTipo = 2;
		BRPVP_menuCorSelecao = "#FF3333";
		BRPVP_menuTipoImagem = 1; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		BRPVP_menuImagem = "<img size='4.0' align='center' image='BRP_imagens\interface\amigo_color.paa'/>";
		BRPVP_menuOpcoes = [
			"(" + BRPVP_indiceDebugTxt + ") Debug Type",
			"(" + (if (BRPVP_vaultLigada) then {"X"} else {"   "}) + ") Open Vault",
			"(" + (if (BRPVP_earPlugs) then {"X"} else {"   "}) + ") Ear Plugs",
			"(" + (if (BRPVP_terrenosMapaLigado) then {"X"} else {"   "}) + ") Show Terrains",
			"(" + (if (BRPVP_rastroBalasLigado) then {"X"} else {"   "}) + ") Bullet Tragetory",
			"COMM: Weapon on Back",
			"COMM: Suicide Press +" + str BRPVP_suicidouTrava,
			"MENU: Special ITems",
			"MENU: Own Statistic",
			"MENU: All Players Statistic",
			"MENU: Manage Friendship",
			"MENU: Give Money",
			"INFO: Friend Marks",
			"INFO: Open Parachute",
			"INFO: Sky Diver"
		];
		BRPVP_menuExecutaParam = [0,1,2,3,4,5,6,7,8,9,10,11,12,13];
		BRPVP_menuExecutaFuncao = {
			if (player getVariable ["sok",false] && alive player) then {
				if (_this == 0) then {
					BRPVP_indiceDebug = (BRPVP_indiceDebug + 1) mod (count BRPVP_indiceDebugItens);
					if (BRPVP_indiceDebug == 0) then {
						BRPVP_indiceDebugTxt = "Main Debug!";
					};
					if (BRPVP_indiceDebug == 1) then {
						BRPVP_indiceDebugTxt = "Info Debug!";
					};
					if (BRPVP_indiceDebug == 2) then {
						BRPVP_indiceDebugTxt = "Min Debug!";
					};
					30 spawn BRPVP_menuMuda;
					["Shortcut Insert.",0] call BRPVP_hint;
				};
				if (_this == -1) then {
					BRPVP_idcIcones = (BRPVP_idcIcones + 1) mod 4;
					BRPVP_txtIcones = ["Default!","AI!","Vehicles!","My Stuff!"] select BRPVP_idcIcones;
					[BRPVP_txtIcones,0] call BRPVP_hint;
					["Shortcut Ctrl + Insert.",0] call BRPVP_hint;
					30 spawn BRPVP_menuMuda;
				};
				if (_this == 1) then {
					_tempo = (BRPVP_vaultAcaoTempo - time) max 0;
					if (_tempo > 0) then {
						["Shortcut Alt + v.\nWait " + str ((round _tempo) max 1) + " seconds to close/open the vault again!",0] call BRPVP_hint;
					} else {
						if (!BRPVP_vaultLigada) then {
							BRPVP_vaultLigada = true;
							BRPVP_vaultAcaoTempo = time + 10;
							call BRPVP_vaultAbre;
						} else {
							BRPVP_vaultLigada = false;
							BRPVP_vaultAcaoTempo = time + 10;
							call BRPVP_vaultRecolhe;
						};
						["Shortcut Alt + v.",0] call BRPVP_hint;
					};
					30 spawn BRPVP_menuMuda;
				};
				if (_this == 2) then {
					if (!BRPVP_earPlugs) then {
						1 fadeSound 0.4;
						BRPVP_earPlugs = true;
					} else {
						1 fadeSound 1;
						BRPVP_earPlugs = false;
					};
					30 spawn BRPVP_menuMuda;
				};
				if (_this == 3) then {
					BRPVP_terrainShowDistanceLimit call BRPVP_showTerrains;
					30 spawn BRPVP_menuMuda;
				};
				if (_this == 4) then {
					if (BRPVP_rastroBalasLigado) then {
						BRPVP_rastroBalasLigado = false;
						["Bullet path off!",0] call BRPVP_hint;
					} else {
						BRPVP_rastroBalasLigado = true;
						["Bullet path on!",0] call BRPVP_hint;
						_nulo = [] spawn BRPVP_rastroWhile;
					};
					30 spawn BRPVP_menuMuda;
				};
				if (_this == 5) then {
					if (speed player < 0.1) then {
						_retorno = true;
						player action ["SwitchWeapon",player,player,100];
					};
				};
				if (_this == 6) then {
					BRPVP_suicidouTrava = BRPVP_suicidouTrava - 1;
					if (BRPVP_suicidouTrava == 0) then {
						BRPVP_suicidou = true;
						[["suicidou",1]] call BRPVP_mudaExp;
						player setDamage 1;
						[] spawn {
							_ini = time;
							waitUntil {(player getVariable "dd") == 0 || (time - _ini) > 1};
							player setVariable ["dd",1,true];
						};
					};
					playSound "radarbip";
					30 spawn BRPVP_menuMuda;
				};
				if (_this == 7) then {
					35 call BRPVP_menuMuda;
					["Shortcut Alt + i.",0] call BRPVP_hint;
				};
				if (_this == 8) then {
					6 call BRPVP_menuMuda;
				};
				if (_this == 9) then {
					7 call BRPVP_menuMuda;
				};
				if (_this == 10) then {
					0 call BRPVP_menuMuda;
				};
				if (_this == 11) then {
					32 call BRPVP_menuMuda;
				};
				if (_this == 12) then {
					["Press Ctrl + 1, Ctrl + 2 or Ctrl + 3\nto mark objects and position for your\nfriends on the 3D screen.",10,15,70] call BRPVP_hint;
					30 spawn BRPVP_menuMuda;
				};
				if (_this == 13) then {
					["When Spawning, press SPACE BAR to open your parachute.",5,15,70] call BRPVP_hint;
					30 spawn BRPVP_menuMuda;
				};
				if (_this == 14) then {
					["When spawning, before open your parachute, you can use sky diver with Shift + W and Shift + S.\nThis will make you travel greate distances before you open your parachute.",10,15,70] call BRPVP_hint;
					30 spawn BRPVP_menuMuda;				
				};
			};
		};
		BRPVP_menuVoltar = {
			BRPVP_menuExtraLigado = false;
			call BRPVP_atualizaDebug;
		};
	},

	//MENU 31
	{
		BRPVP_menuTipo = 0;
		BRPVP_menuTipoImagem = 2; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		BRPVP_menuOpcoes = [];
		BRPVP_menuImagem = [];
		BRPVP_menuVal = [];
		_txt = "<t size='2.0' color='#FFFF33' align='center'>Price: $ %1</t><br/><img size='6.0' align='center' image='%2'/>";
		{
			private ["_imagem","_nomeBonito"];
			_it = _x;
			_idc = BRPVP_specialItems find _it;
			if (_idc >= 0) then {
				_imagem = BRPVP_specialItemsImages select _idc;
				_nomeBonito = BRPVP_specialItemsNames select _idc;
			} else {
				_imagem = "BRP_imagens\interface\amigo_color.paa";
				_nomeBonito = "ITEM ?";
				_isM = isClass (configFile >> "CfgMagazines" >> _it);
				if (_isM) then {
					_imagem = getText (configFile >> "CfgMagazines" >> _it >> "picture");
					_nomeBonito = getText (configFile >> "CfgMagazines" >> _it >> "displayName");
				} else {
					_isW = isClass (configFile >> "CfgWeapons" >> _it);
					if (_isW) then {
						_imagem = getText (configFile >> "CfgWeapons" >> _it >> "picture");
						_nomeBonito = getText (configFile >> "CfgWeapons" >> _it >> "displayName");
					} else {
						_isV = isClass (configFile >> "CfgVehicles" >> _it);
						if (_isV) then {
							_imagem = getText (configFile >> "CfgVehicles" >> _it >> "picture");
							_nomeBonito = getText (configFile >> "CfgVehicles" >> _it >> "displayName");
						};
					};
				};
			};
			_preco = BRPVP_compraItensPrecos select _forEachIndex;
			BRPVP_menuOpcoes pushBack _nomeBonito;
			BRPVP_menuImagem pushBack format[_txt,round _preco,_imagem];
			BRPVP_menuVal pushBack [_forEachIndex,_preco];
		} forEach BRPVP_compraItensTotal;
		BRPVP_menuDestino = 31;
		BRPVP_menuCodigo = {
			_idc = BRPVP_menuVal select BRPVP_menuOpcoesSel select 0;
			_preco = BRPVP_menuVal select BRPVP_menuOpcoesSel select 1;
			BRPVP_compraPrecoTotal = BRPVP_compraPrecoTotal - _preco;
			BRPVP_compraItensTotal deleteAt _idc;
			BRPVP_compraItensPrecos deleteAt _idc;
			playSound "granted";
		};
		BRPVP_menuVoltar = {12 spawn BRPVP_menuMuda;};
	},
	
	//MENU 32
	{
		BRPVP_menuTipo = 0;
		BRPVP_menuTipoImagem = 1; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		BRPVP_menuImagem = "<img size='4.0' align='center' image='BRP_imagens\interface\dinheiro.paa'/> <img size='4.0' align='center' image='BRP_imagens\interface\amigo_color.paa'/>";
		BRPVP_menuCorSelecao = "#FF3333";
		BRPVP_menuDestino = 33;
		call BRPVP_pegaListaPlayers;
		BRPVP_menuCodigo = {
			BRPVP_menuVar1 = BRPVP_menuExecutaParam select BRPVP_menuOpcoesSel;
			BRPVP_menuVar2 = 0;
		};
		BRPVP_menuVoltar = {30 spawn BRPVP_menuMuda;};
	},

	//MENU 33
	{
		BRPVP_menuTipo = 2;
		BRPVP_menuForceExit = {
			_true = isNull BRPVP_menuVar1 && {isPlayer BRPVP_menuVar1};
			if (_true) then {["Player disconected or respawned.",0] call BRPVP_hint;};
			_true
		};
		BRPVP_menuOpcoes = ["add 10 $","add 50 $","add 250 $","add 1000 $","add 5000 $","add 10000 $","reset to 0 $"];
		BRPVP_menuExecutaParam = [10,50,250,1000,5000,10000,0];
		BRPVP_menuExecutaFuncao = {
			if (_this == 0) then {
				BRPVP_menuVar2 = 0;
			} else {
				_money = player getVariable "mny";
				if (_money >= BRPVP_menuVar2 + _this) then {
					BRPVP_menuVar2 = BRPVP_menuVar2 + _this;
					playSound "hint";
				} else {
					playSound "erro";
				};
			};
			call BRPVP_atualizaDebugMenu;
		};
		BRPVP_menuVoltar = {
			if (BRPVP_menuVar2 == 0) then {
				32 spawn BRPVP_menuMuda;
			} else {
				34 spawn BRPVP_menuMuda;
			};
		};
	},
	
	//MENU 34
	{
		BRPVP_menuTipo = 2;
		BRPVP_menuForceExit = {
			_true = isNull BRPVP_menuVar1 && {isPlayer BRPVP_menuVar1};
			if (_true) then {["Player disconected or respawned.",0] call BRPVP_hint;};
			_true
		};
		BRPVP_menuOpcoes = ["Give Money","Cancel"];
		BRPVP_menuExecutaParam = [0,1];
		BRPVP_menuExecutaFuncao = {
			if (_this == 0) then {
				_money = player getVariable "mny";
				if (_money >= BRPVP_menuVar2 && {isplayer BRPVP_menuVar1 && {BRPVP_menuVar1 getVariable "dd" == -1}}) then {
					player setVariable ["mny",_money - BRPVP_menuVar2,true];
					BRPVP_giveMoneySV = [BRPVP_menuVar1,BRPVP_menuVar2];
					publicVariableServer "BRPVP_giveMoneySV";
					playSound "negocio";
				} else {
					playSound "erro";
				};
			};
			32 spawn BRPVP_menuMuda;
		};
		BRPVP_menuVoltar = {33 spawn BRPVP_menuMuda;};
	},
	
	//MENU 35
	{
		BRPVP_menuTipo = 0;
		BRPVP_menuTipoImagem = 2; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		BRPVP_menuImagem = [];
		BRPVP_menuCorSelecao = "#FF3333";
		BRPVP_menuDestino = 35;
		BRPVP_menuOpcoes = [];
		{
			_q = {_x == _forEachIndex} count (player getVariable "sit");
			BRPVP_menuOpcoes pushBack ("X" + str _q + " " + _x);
			_img = BRPVP_specialItemsImages select _forEachIndex;
			BRPVP_menuImagem pushBack ("<img size='4.5' align='center' image='" + _img + "'/>");
		} forEach BRPVP_specialItemsNames;
		BRPVP_menuCodigo = {
			_ii = BRPVP_menuOpcoesSel;
			if (_ii in (player getVariable "sit")) then {
				BRPVP_menuExtraLigado = false;
				call BRPVP_atualizaDebug;
				[call compile (BRPVP_specialItems select _ii),"",_ii] call BRPVP_construir;
			} else {
				playSound "erro";
			};
		};
		BRPVP_menuVoltar = {
			BRPVP_menuExtraLigado = false;
			call BRPVP_atualizaDebug;
		};
	},
	
	//MENU 36
	{
		BRPVP_menuSleep = 0;
		BRPVP_menuTipo = 2;
		BRPVP_menuCorSelecao = "#FF3333";
		BRPVP_menuTipoImagem = 1; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		BRPVP_menuImagem = "<img size='4.25' align='center' image='BRP_imagens\interface\daytime.paa'/>";
		BRPVP_menuOpcoes = [
			"Set to 00:00",
			"Set to 01:00",
			"Set to 02:00",
			"Set to 03:00",
			"Set to 04:00",
			"Set to 05:00",
			"Set to 06:00",
			"Set to 07:00",
			"Set to 08:00",
			"Set to 09:00",
			"Set to 10:00",
			"Set to 11:00",
			"Set to 12:00",
			"Set to 13:00",
			"Set to 14:00",
			"Set to 15:00",
			"Set to 16:00",
			"Set to 17:00",
			"Set to 18:00",
			"Set to 19:00",
			"Set to 20:00",
			"Set to 21:00",
			"Set to 22:00",
			"Set to 23:00"
		];
		BRPVP_menuExecutaParam = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23];
		BRPVP_menuExecutaFuncao = {
			BRPVP_menuVar1 = _this;
			37 spawn BRPVP_menuMuda;
		};
		BRPVP_menuVoltar = {
			29 spawn BRPVP_menuMuda;
		};
	},
	
	//MENU 37
	{
		BRPVP_menuTipo = 2;
		BRPVP_menuOpcoes = [
			"Set to " + str BRPVP_menuVar1 + ":00",
			"Set to " + str BRPVP_menuVar1 + ":05",
			"Set to " + str BRPVP_menuVar1 + ":10",
			"Set to " + str BRPVP_menuVar1 + ":15",
			"Set to " + str BRPVP_menuVar1 + ":20",
			"Set to " + str BRPVP_menuVar1 + ":25",
			"Set to " + str BRPVP_menuVar1 + ":30",
			"Set to " + str BRPVP_menuVar1 + ":35",
			"Set to " + str BRPVP_menuVar1 + ":40",
			"Set to " + str BRPVP_menuVar1 + ":45",
			"Set to " + str BRPVP_menuVar1 + ":50",
			"Set to " + str BRPVP_menuVar1 + ":55"
		];
		BRPVP_menuExecutaParam = [0,5,10,15,20,25,30,35,40,45,50,55];
		BRPVP_menuExecutaFuncao = {
			_date = date;
			_date set [3,BRPVP_menuVar1];
			_date set [4,_this];
			BRPVP_setDateSV = _date;
			publicVariableServer "BRPVP_setDateSV";
			29 spawn BRPVP_menuMuda;
		};
	},
	
	//MENU 38
	{
		BRPVP_menuSleep = 0;
		BRPVP_menuTipo = 2;
		BRPVP_menuCorSelecao = "#FF3333";
		BRPVP_menuTipoImagem = 1; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		BRPVP_menuImagem = "<img size='4.25' align='center' image='BRP_imagens\interface\timemultiplier.paa'/>";
		BRPVP_menuOpcoes = [
			"Time X 0.5",
			"Time X 1",
			"Time X 2",
			"Time X 3",
			"Time X 4",
			"Time X 5",
			"Time X 10",
			"Time X 15",
			"Time X 20",
			"Time X 30",
			"Time X 40",
			"Time X 50",
			"Time X 75",
			"Time X 100"
		];
		BRPVP_menuExecutaParam = [0.5,1,2,3,4,5,10,15,20,30,40,50,75,100];
		BRPVP_menuExecutaFuncao = {
			BRPVP_setTimeMultiplierSV = _this;
			publicVariableServer "BRPVP_setTimeMultiplierSV";
			29 spawn BRPVP_menuMuda;
		};
		BRPVP_menuVoltar = {
			29 spawn BRPVP_menuMuda;
		};
	},
	
	//MENU 39
	{
		BRPVP_menuSleep = 0;
		BRPVP_menuTipo = 2;
		BRPVP_menuCorSelecao = "#FF3333";
		BRPVP_menuTipoImagem = 1; //0 - NENHUMA | 1 - FIXA | 2 - UMA POR OPCAO
		BRPVP_menuImagem = "<img size='3.0' align='center' image='BRP_imagens\interface\setweather.paa'/>";
		BRPVP_menuOpcoes = [
			"Clouds to 0%",
			"Clouds to 20%",
			"Clouds to 40%",
			"Clouds to 60% (can rain)",
			"Clouds to 80% (can rain)",
			"Clouds to 100% (can rain)"
		];
		BRPVP_menuExecutaParam = [0,0.2,0.4,0.6,0.8,1];
		BRPVP_menuExecutaFuncao = {
			BRPVP_menuVar1 = [_this];
			BRPVP_menuVar2 = [];
			if (BRPVP_menuVar1 select 0 >= 0.6) then {
				40 spawn BRPVP_menuMuda;
			} else {
				BRPVP_menuVar2 pushBack 0;
				41 spawn BRPVP_menuMuda;
			};
		};
		BRPVP_menuVoltar = {
			29 spawn BRPVP_menuMuda;
		};
	},

	//MENU 40
	{
		BRPVP_menuOpcoes = [
			"Rain to 0%",
			"Rain to 20%",
			"Rain to 40%",
			"Rain to 60%",
			"Rain to 80%",
			"Rain to 100%"
		];
		BRPVP_menuExecutaParam = [0,0.2,0.4,0.6,0.8,1];
		BRPVP_menuExecutaFuncao = {
			BRPVP_menuVar2 pushBack _this;
			41 spawn BRPVP_menuMuda;
		};
		BRPVP_menuVoltar = {
			39 spawn BRPVP_menuMuda;
		};
	},
	
	//MENU 41
	{
		BRPVP_menuOpcoes = [
			"Wind to 0 m/s",
			"Wind to 1 m/s",
			"Wind to 3 m/s",
			"Wind to 5 m/s",
			"Wind to 7 m/s",
			"Wind to 10 m/s",
			"Wind to 15 m/s",
			"Wind to 20 m/s"
		];
		BRPVP_menuExecutaParam = [0,1,3,5,7,10,15,20];
		BRPVP_menuExecutaFuncao = {
			BRPVP_menuVar2 pushBack [_this,getDir player];
			42 spawn BRPVP_menuMuda;
		};
		BRPVP_menuVoltar = {
			if (BRPVP_menuVar1 select 0 >= 0.6) then {
				40 spawn BRPVP_menuMuda;
			} else {
				39 spawn BRPVP_menuMuda;
			};
		};
	},
	
	//MENU 42
	{
		BRPVP_menuOpcoes = [
			"Gusts to 0%",
			"Gusts to 20%",
			"Gusts to 40%",
			"Gusts to 60%",
			"Gusts to 80%",
			"Gusts to 100%"
		];
		BRPVP_menuExecutaParam = [0,0.2,0.4,0.6,0.8,1];
		BRPVP_menuExecutaFuncao = {
			BRPVP_menuVar1 pushBack _this;
			BRPVP_setWeatherServer = [BRPVP_menuVar1,BRPVP_menuVar2];
			publicVariableServer "BRPVP_setWeatherServer";
			29 spawn BRPVP_menuMuda;
		};
		BRPVP_menuVoltar = {
			41 spawn BRPVP_menuMuda;
		};
	}
];

//ROEDAPE DO MENU
_defaultFooter = {"<br/><br/><t size='1.2' align='left' color='#FF3333'>Navigate:</t><t size='1.2' align='right' color='#FFFFFF'>Keys w and s</t><br/><t size='1.2' align='left' color='#FF3333'>Select:</t><t size='1.2' align='right' color='#FFFFFF'>Key space bar</t><br/><t size='1.2' align='left' color='#FF3333'>Back:</t><t size='1.2' align='right' color='#FFFFFF'>Key a</t>"};
BRPVP_menuRodapeHtml = [
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	{"<br/><br/><t size='1.5' color='#FFFF33' align='center'>YOUR MONEY: $ " + str (player call BRPVP_qjsValorDoPlayer) + "</t><br/><t size='1.5' color='#FFFF33' align='center'>TOTAL PRICE: $ " + str round BRPVP_compraPrecoTotal + "</t><br/><br/><t size='1.2' align='left' color='#FF3333'>Navigate:</t><t size='1.2' align='right' color='#FFFFFF'>Keys w and s</t><br/><t size='1.2' align='left' color='#FF3333'>Select:</t><t size='1.2' align='right' color='#FFFFFF'>Key space bar</t><br/><t size='1.2' align='left' color='#FF3333'>Back:</t><t size='1.2' align='right' color='#FFFFFF'>Key a</t>"},
	{"<br/><br/><t size='1.5' color='#FFFF33' align='center'>YOUR MONEY: $ " + str (player call BRPVP_qjsValorDoPlayer) + "</t><br/><t size='1.5' color='#FFFF33' align='center'>TOTAL PRICE: $ " + str round BRPVP_compraPrecoTotal + "</t><br/><br/><t size='1.2' align='left' color='#FF3333'>Navigate:</t><t size='1.2' align='right' color='#FFFFFF'>Keys w and s</t><br/><t size='1.2' align='left' color='#FF3333'>Select:</t><t size='1.2' align='right' color='#FFFFFF'>Key space bar</t><br/><t size='1.2' align='left' color='#FF3333'>Back:</t><t size='1.2' align='right' color='#FFFFFF'>Key a</t>"},
	{"<br/><br/><t size='1.5' color='#FFFF33' align='center'>YOUR MONEY: $ " + str (player call BRPVP_qjsValorDoPlayer) + "</t><br/><t size='1.5' color='#FFFF33' align='center'>TOTAL PRICE: $ " + str round BRPVP_compraPrecoTotal + "</t><br/><br/><t size='1.2' align='left' color='#FF3333'>Navigate:</t><t size='1.2' align='right' color='#FFFFFF'>Keys w and s</t><br/><t size='1.2' align='left' color='#FF3333'>Select:</t><t size='1.2' align='right' color='#FFFFFF'>Key space bar</t><br/><t size='1.2' align='left' color='#FF3333'>Back:</t><t size='1.2' align='right' color='#FFFFFF'>Key a</t>"},
	{"<br/><br/><t size='1.5' color='#FFFF33' align='center'>YOUR MONEY: $ " + str (player call BRPVP_qjsValorDoPlayer) + "</t><br/><t size='1.5' color='#FFFF33' align='center'>TOTAL PRICE: $ " + str round BRPVP_compraPrecoTotal + "</t><br/><br/><t size='1.2' align='left' color='#FF3333'>Navigate:</t><t size='1.2' align='right' color='#FFFFFF'>Keys w and s</t><br/><t size='1.2' align='left' color='#FF3333'>Select:</t><t size='1.2' align='right' color='#FFFFFF'>Key space bar</t><br/><t size='1.2' align='left' color='#FF3333'>Back:</t><t size='1.2' align='right' color='#FFFFFF'>Key a</t>"},
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	{"<br/><br/><t size='1.5' color='#FFFF33' align='center'>YOUR MONEY: $ " + str (player call BRPVP_qjsValorDoPlayer) + "</t><br/><t size='1.5' color='#FFFF33' align='center'>TOTAL PRICE: $ " + str round BRPVP_compraPrecoTotal + "</t><br/><br/><t size='1.2' align='left' color='#FF3333'>Navigate:</t><t size='1.2' align='right' color='#FFFFFF'>Keys w and s</t><br/><t size='1.2' align='left' color='#FF3333'>Select:</t><t size='1.2' align='right' color='#FFFFFF'>Key space bar</t><br/><t size='1.2' align='left' color='#FF3333'>Back:</t><t size='1.2' align='right' color='#FFFFFF'>Key a</t>"},
	{"<br/><br/><t size='1.5' color='#FFFF33' align='center'>YOUR MONEY: $ " + str (player call BRPVP_qjsValorDoPlayer) + "</t><br/><br/><t size='1.2' align='left' color='#FF3333'>Navigate:</t><t size='1.2' align='right' color='#FFFFFF'>Keys w and s</t><br/><t size='1.2' align='left' color='#FF3333'>Select:</t><t size='1.2' align='right' color='#FFFFFF'>Key space bar</t><br/><t size='1.2' align='left' color='#FF3333'>Back:</t><t size='1.2' align='right' color='#FFFFFF'>Key a</t>"},
	{"<br/><br/><t size='1.5' color='#FFFF33' align='center'>YOUR MONEY: $ " + str (player call BRPVP_qjsValorDoPlayer) + "</t><br/><t size='1.5' color='#FFFF33' align='center'>TO GIVE: $ " + str round BRPVP_menuVar2 + "</t><br/><br/><t size='1.2' align='left' color='#FF3333'>Navigate:</t><t size='1.2' align='right' color='#FFFFFF'>Keys w and s</t><br/><t size='1.2' align='left' color='#FF3333'>Select:</t><t size='1.2' align='right' color='#FFFFFF'>Key space bar</t><br/><t size='1.2' align='left' color='#FF3333'>Back:</t><t size='1.2' align='right' color='#FFFFFF'>Key a</t>"},
	{"<br/><br/><t size='1.5' color='#FFFF33' align='center'>YOUR MONEY: $ " + str (player call BRPVP_qjsValorDoPlayer) + "</t><br/><t size='1.5' color='#FFFF33' align='center'>TO GIVE: $ " + str round BRPVP_menuVar2 + "</t><br/><br/><t size='1.2' align='left' color='#FF3333'>Navigate:</t><t size='1.2' align='right' color='#FFFFFF'>Keys w and s</t><br/><t size='1.2' align='left' color='#FF3333'>Select:</t><t size='1.2' align='right' color='#FFFFFF'>Key space bar</t><br/><t size='1.2' align='left' color='#FF3333'>Back:</t><t size='1.2' align='right' color='#FFFFFF'>Key a</t>"},
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,
	_defaultFooter,	
	_defaultFooter
];

//POSICOES DOS MENUS
BRPVP_menuPos = [];
{BRPVP_menuPos append [0];} forEach BRPVP_menu;

diag_log "[BRPVP FILE] sistema_menus.sqf END REACHED";