cutText["Server initiating, please wait.","BLACK FADED",10];
if (isNil "BRPVP_primeiraRodadaOk") then {
	call compile preprocessFileLineNumbers "generalVariables.sqf";
	call compile preprocessFileLineNumbers "serverAndClientFunctions.sqf";
	call compile preprocessFileLineNumbers "precalculated.sqf";
};
setTerrainGrid BRPVP_terrainGrid;
0 setOvercast BRPVP_overcast;
if (hasInterface) then {
	waitUntil {!isNull player};
	sleep 0.001;
	player allowDamage false;
	player call BRPVP_pelaUnidade;
	if (isNil "BRPVP_primeiraRodadaOk") then {
		BRPVP_serverTimeSend = serverTime;
		publicVariableServer "BRPVP_serverTimeSend";
		enableRadio false;
		enableSentences false;
	};
	player setVariable ["umok",false,true];
	player addWeapon "ItemMap";
	waitUntil {!isNil "BRPVP_terminaMissao"};
	if (BRPVP_terminaMissao) then {
		cutText ["SERVER RESTARTING OR STOPPED BY AN ADMIN!\nPLEASE WAIT...","BLACK FADED",10];
		sleep 10;
		endMission "END1";
	};
	if (isNil "BRPVP_serverBelezinha") then {
		hint parseText "<t size='2' align='center' color='#00FF00'>INITIATING</tr><br/>
						<t size='2' align='center' color='#00FF00'>SERVER</tr><br/>
						<t size='2' align='center' color='#00FF00'>...</tr>";
		if (isNil "BRPVP_serverTrabalhando") then {BRPVP_serverTrabalhando = ["",""];};
		_oldPercentage = "";
		_startTime = time;
		_percentage = "";
		waitUntil {
			_percentage = BRPVP_serverTrabalhando select 1;
			if (_percentage != _oldPercentage) then {hintSilent parseText _percentage;};
			_oldPercentage = _percentage;
			if (time - _startTime > 2.5) then {
				_startTime = time;
				cutText ["Client initiating, please wait...","BLACK FADED",10];
			};
			!isNil "BRPVP_serverBelezinha"
		};
		hint parseText (_percentage + "<br/><t color='#FF0000' size='2'>DEPLOYING...</tr>");
	};
	call compile preprocessFileLineNumbers "principais\playerInit.sqf";
};
if (isServer) then {
	sleep 0.001;
	EAST setFriend [EAST,1];
	EAST setFriend [CIVILIAN,1];
	EAST setFriend [WEST,0];
	EAST setFriend [INDEPENDENT,0];
	WEST setFriend [WEST,1];
	WEST setFriend [CIVILIAN,1];
	WEST setFriend [EAST,0];
	WEST setFriend [INDEPENDENT,0];
	INDEPENDENT setFriend [INDEPENDENT,1];
	INDEPENDENT setFriend [CIVILIAN,1];
	INDEPENDENT setFriend [EAST,0];
	INDEPENDENT setFriend [WEST,0];
	if (BRPVP_timeMultiplier > 1) then {setTimeMultiplier BRPVP_timeMultiplier;};
	setViewDistance BRPVP_viewDist;
	setObjectViewDistance BRPVP_viewObjsDist;
	0 setFog BRPVP_fog;
	call compile preProcessFileLineNumbers "\BRPVP_server\servidor_init.sqf";
	BRPVP_serverBelezinha = true;
	publicVariable "BRPVP_serverBelezinha";
	diag_log "[BRPVP] SERVER STUFF LOADED! NOW STARTING CLIENTS...";
};