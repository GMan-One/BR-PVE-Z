diag_log "[BRPVP FILE] PVEH.sqf STARTING";

"BRPVP_remoteRemoveMyStuff" addPublicVariableEventHandler {
	_obj = _this select 1;
	_index = BRPVP_myStuff find _obj;
	if (_index != -1) then {
		BRPVP_myStuff deleteAt _index;
	};
};
"BRPVP_newCarAddClients" addPublicVariableEventHandler {
	BRPVP_carrosObjetos pushBackUnique (_this select 1);
};
"BRPVP_newHeliAddClients" addPublicVariableEventHandler {
	BRPVP_helisObjetos pushBackUnique (_this select 1);
};
"BRPVP_variablesObjectsAdd" addPublicVariableEventHandler {
	(_this select 1) params ["_o","_n","_v",["_sv",false]];
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
	if (_sv) then {
		diag_log ("[OBJ VARIABLE RECEIVED FROM SERVER - VAR SET ON SERVER] " + str [_o,_n,_v]);
	} else {
		diag_log ("[OBJ VARIABLE RECEIVED FROM SERVER - VAR SET ON A CLIENT] " + str [_o,_n,_v]);
	};
};
"BRPVP_setWeatherClient" addPublicVariableEventHandler {
	0 setOvercast (_this select 1 select 0 select 0);
	0 setGusts (_this select 1 select 0 select 1);
	["Weather changed by admin.\nSyncing...",0] call BRPVP_hint;
};
"BRPVP_giveMoney" addPublicVariableEventHandler {
	[player,_this select 1] call BRPVP_qjsAdicClassObjeto;
	playSound "negocio";
};
"BRPVP_switchMoveCli" addPublicVariableEventHandler {
	(_this select 1) params ["_unit","_state"];
	diag_log ("[BRPVP SWITCH MOVE] _unit = " + str _unit);
	diag_log ("[BRPVP SWITCH MOVE] _state = " + _state);
	_unit switchMove _state;
};
"BRPVP_closedCityRunning" addPublicVariableEventHandler {
	(_this select 1) call BRPVP_processSiegeIcons;
};
"BRPVP_moveInClient" addPublicVariableEventHandler {
	(_this select 1) params ["_unit","_vehicle","_type"];
	if (_type == "Driver") then {_unit moveInDriver _vehicle;};
	if (_type == "Commander") then {_unit moveInCommander _vehicle;};
	if (_type == "Gunner") then {_unit moveInGunner _vehicle;};
	if (_type == "Cargo") then {_unit moveInCargo _vehicle;};
};
"BRPVP_ganchoDesviraAdd" addPublicVariableEventHandler {
	BRPVP_ganchoDesvira pushBack (_this select 1);
};
"BRPVP_ganchoDesviraRemove" addPublicVariableEventHandler {
	BRPVP_ganchoDesvira = BRPVP_ganchoDesvira - [_this select 1];
};
"BRPVP_propriedadeTira" addPublicVariableEventHandler {
	if (BRPVP_achaMeuStuffRodou) then {
		BRPVP_myStuff = BRPVP_myStuff - (_this select 1);
		if (BRPVP_stuff in (_this select 1)) then {BRPVP_stuff = objNull;};
		["mastuff"] call BRPVP_atualizaIcones;
	};
};
"BRPVP_mudaDonoPropriedadeRecebeu" addPublicVariableEventHandler {
	_props = _this select 1;
	_maphouses = [];
	{
		if (_x getVariable ["mapa",false]) then {
			_maphouses pushBack _x;
		} else {
			_x setVariable ["own",player getVariable ["id_bd",-1],true];
			_x setVariable ["amg",player getVariable ["amg",[]],true];
			_x setVariable ["stp",player getVariable ["dstp",1],true];
			if !(_x getVariable ["slv_amg",false]) then {_x setVariable ["slv_amg",true,true];};
		};
	} forEach _props;
	BRPVP_myStuff append _props;
	["You received one or more properties!",4,15] call BRPVP_hint;
	["mastuff"] call BRPVP_atualizaIcones;
	if (count _maphouses > 0) then {
		[_maphouses,""] call BRPVP_mudaDonoPropriedade;
		if (count _maphouses == 1) then {
			["Some near map house became public! Catch it if you want!",6,15] call BRPVP_hint;
		} else {
			["Some near map houses became public! Catch it if you want!",6,15] call BRPVP_hint;
		};
	};
};
"BRPVP_pegaVaultPlayerBdRetorno" addPublicVariableEventHandler {
	private ["_vault"];
	_resultadoCompilado = call compile (_this select 1);
	_resultadoCompilado = _resultadoCompilado select 1;
	_inventario = _resultadoCompilado select 0 select 0;
	_comp = _resultadoCompilado select 0 select 1;
	_idx = _resultadoCompilado select 0 select 2;
	diag_log "---------------------------------------------------------------------------------------------";
	diag_log ("---- [VAULT ACTIVATED. IDX = " + str _idx + ".VAULT ITEMS ARE:]");
	diag_log ("---- _inventario = " + str _inventario);
	diag_log "---------------------------------------------------------------------------------------------";
	if (_idx == 0) then {
		_vault = BRPVP_holderVault;
	} else {
		_vault = BRPVP_sellReceptacle;
	};
	_vault setVariable ["stp",_comp,true];
	{
		_vault addWeaponCargoGlobal [_x,_inventario select 0 select 1 select _forEachIndex];
	} forEach (_inventario select 0 select 0);
	{
		_vault addMagazineAmmoCargo [_x select 0,1,_x select 1];
	} forEach (_inventario select 1);
	{
		_vault addBackpackCargoGlobal [_x,_inventario select 2 select 1 select _forEachIndex];
	} forEach (_inventario select 2 select 0);
	{
		_vault addItemCargoGlobal [_x,_inventario select 3 select 1 select _forEachIndex];
	} forEach (_inventario select 3 select 0);
	{
		_c = _x select 1;
		clearWeaponCargoGlobal _c;
		clearMagazineCargoGlobal _c;
		clearItemCargoGlobal _c;
		clearBackpackCargoGlobal _c;
	} forEach everyContainer _vault;
	if (_idx == 0) then {
		player setVariable ["wh",_vault,true];
	} else {
		player setVariable ["sr",_vault,true];
	};
};
"BRPVP_rapelRopeUnwindPV" addPublicVariableEventHandler {
	if (!isNull (_this select 1 select 0)) then {
		ropeUnwind (_this select 1);
	};
};
"BRPVP_svCriaVehRetorno" addPublicVariableEventHandler {
	BRPVP_rapelRope = ropeCreate [_this select 1,[0,0,0],player,[0,0,1],1.5];
};
"BRPVP_fastRopeEnrola" addPublicVariableEventHandler {
	(_this select 1) params ["_corda","_step"];
	ropeUnwind [_corda,5,(((ropeLength _corda) + _step) max 2.5) min 50];
};
"BRPVP_switchMoveRem" addPublicVariableEventHandler {
	(_this select 1) params ["_unid","_move"];
	_unid switchMove _move;
};
"BRPVP_missBotsEm" addPublicVariableEventHandler {
	["bots"] call BRPVP_atualizaIcones;
};
"BRPVP_mudaExpPedidoServidor" addPublicVariableEventHandler {
	(_this select 1) call BRPVP_mudaExp;
};
"BRPVP_PUSV" addPublicVariableEventHandler {
	call BRPVP_daUpdateNosAmigos;
	["players"] call BRPVP_atualizaIcones;
};
"BRPVP_tocaSom" addPublicVariableEventHandler {
	(_this select 1) call BRPVP_playHelipadSound;
};
"BRPVP_hintEmMassa" addPublicVariableEventHandler {
	(_this select 1) call BRPVP_hint;
};
"BRPVP_mudouConfiancaEmVoce" addPublicVariableEventHandler {
	(_this select 1) params ["_pAction","_action"];
	if (_action) then {
		["TRUST: " + name _pAction + " trust you now!",4,15,857] call BRPVP_hint;
	} else {
		["REVOKE TRUST: " + name _pAction + " don't trust you anymore.",4,15,857] call BRPVP_hint;
	};
	call BRPVP_daUpdateNosAmigos;
	BRPVP_tempoUltimaAtuAmigos = time;
};
"BRPVP_terminaMissao" addPublicVariableEventHandler {
	endMission "END1";
};
"BRPVP_mensagemDeKillTxtSend" addPublicVariableEventHandler {
	(_this select 1) call LOL_fnc_showNotification;
};

diag_log "[BRPVP FILE] PVEH.sqf END REACHED";