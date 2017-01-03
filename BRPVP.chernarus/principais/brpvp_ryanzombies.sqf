if (isClass (configFile >> "CfgVehicles" >> "RyanZombieC_man_1")) then {
	_pos = ASLToAGL getPosASL player;
	_init = time;
	_lastZombieSpawn = 0;
	waitUntil {
		_time = time;
		_deltaTime = _time - _init;
		if (_deltaTime > 0.35) then {
			_init = _time;
			_coolDown = _time - _lastZombieSpawn < BRPVP_zombieCoolDown || !(player getVariable ["sok",false]) || (player getVariable ["dd",false]) > -1;
			if (!_coolDown) then {
				_housesNear = count (player nearObjects ["House",35]);
				_amongHousesFactor = if (_housesNear == 0) then {0} else {0.5 + (_housesNear min 6)/6};
				_posNew = ASLToAGL getPosASL player;
				_posChanged = _posNew distance _pos > _deltaTime * 1;
				_pos = _posNew;
				if (_posChanged) then {
					BRPVP_zombieFactor = (BRPVP_zombieFactor - _deltaTime) max 0;
				} else {
					BRPVP_zombieFactor = (BRPVP_zombieFactor + _deltaTime * _amongHousesFactor) min BRPVP_zombieFactorLimit;
				};
				if (BRPVP_zombieFactor >= BRPVP_zombieFactorLimit) then {
					_antiZombieStructures = nearestObjects [player,BRP_kitReligious,65];
					_hasAntiZombie = ({_x getVariable ["id_bd",-1] != -1} count _antiZombieStructures) > 0;
					if (!_hasAntiZombie) then {
						_lastZombieSpawn = time;
						_amount = 3;
						_dist = 30 + random 30;
						_posSpawn = [player,_dist,(getDir player) - 35 + random 70] call BIS_fnc_relPos;
						BRPVP_spawnZombiesServer = [player,_posSpawn,_amount];
						publicVariableServer "BRPVP_spawnZombiesServer";
					};
				};
			} else {
				BRPVP_zombieFactor = 0;
			};
		};
		false
	};
};