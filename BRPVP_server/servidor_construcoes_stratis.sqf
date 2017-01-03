diag_log "[BRPVP EXTRA] LOADING EXTRA CONSTRUCTIONS FOR STRATIS.";
BRPVP_fakeMapDefault = [];
{
	_bu = createVehicle [_x select 0,_x select 1 select 0,[],0,"CAN_COLLIDE"];
	BRPVP_fakeMapDefault pushBack _bu;
	_bu setVectorDirAndUp (_x select 1 select 1);
	_bu setPosWorld (_x select 1 select 0);
	{
		_lamp = createVehicle ["Land_LampStreet_F",([_bu,6] +_x) call BRPVP_emVoltaBBManual,[],0,"CAN_COLLIDE"];
		_lamp setDir ([_lamp,_bu] call BIS_fnc_dirTo);
	} forEach [/*[0,0],[1,0],[2,0],[3,0],*/[0,0.5],[1,0.5],[2,0.5],[3,0.5]];
	_altoFalante = createVehicle ["Land_Loudspeakers_F",[_bu,6,1,0] call BRPVP_emVoltaBBManual,[],0,"CAN_COLLIDE"];
} forEach [
	["Land_Offices_01_V1_F",[[4491.74,4394.64,208.985],[[0.959412,0.282009,0],[0,0,1]]]],
	["Land_Church_01_V1_F",[[4270.78,3053.42,126.767],[[-0.96875,-0.247765,0.0116577],[0.0139713,-0.00758174,0.999874]]]],
	["Land_i_Barracks_V1_F",[[3858.33,6402.16,105],[[-0.482666,-0.875804,0],[0,0,1]]]],
	["Land_dp_mainFactory_F",[[6229.92,5613.75,12.8389],[[0.782898,-0.62215,0],[0,0,1]]]],
	["Land_Church_01_V1_F",[[3288.83,6699.42,58.17],[[-0.233337,0.972396,0],[0,0,1]]]]
];
publicVariable "BRPVP_fakeMapDefault";