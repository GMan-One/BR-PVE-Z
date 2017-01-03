_obj = _this select 3;
[player,_obj getVariable ["mny",0]] call BRPVP_qjsAdicClassObjeto;
playSound "negocio";
deleteVehicle _obj;