BRPVP_terrainShowDistanceLimit = 1250;
BRPVP_startingMoney = 8000;
BRPVP_marketPricesMultiply = 1.55;
BRPVP_sellTerrainPlaces = [[13933,3331,7934,3854],[1,2,3,4]]; //[[Terrain numbers],[index of the Sell Receptacles (can't be 0)]]
BRPVP_sellPricesMultiplier = 0.5; //PLAYER SELL PRICES CUT
BRPVP_restartTimes = [4,8,12,16,20,24]; //RESTART HOURS IN 24H FORMAT
BRPVP_restartWarnings = [30,20,15,10,5,1]; //RESTART WARNINGS TO BE SHOW X MINUTES BEFORE RESTART (X <= 30)
BRPVP_tempoDeVeiculoTemporarioNascimento = 600;
BRPVP_veiculoTemporarioNascimento = "C_Quadbike_01_F";
BRPVP_servidorQPS = 0;
BRPVP_mapaDimensoes = [15360,15360];
BRPVP_centroMapa = [6780,9220,0];
BRPVP_spawnAIFirstPos = [1712,19500,0];
BRPVP_posicaoFora = [-14430,22900,0];
BRPVP_lootMult = 1;
BRPVP_vendaveCats = ["Tanks","Cars","APCs","Helicopters","Anti-Air","Artillery","Turrets","Planes"];
BRPVP_vendaveCatsPreco = [25000,8000,15000,20000,15000,15000,5000,25000];
BRPVP_vendaveCivilCut = 0.50;
BRPVP_ganhoDinheiroMult = 1; //IMPLEMENTAR
BRPVP_viewDist = 1600;
BRPVP_viewObjsDist = 1200;
BRPVP_hParaMaxVOD = 400;
BRPVP_terrainGrid = 25;
BRPVP_overcast = 0;
BRPVP_fog = 0;
BRPVP_timeMultiplier = 1;
BRPVP_mapaRodando = [
	//MAPA
	"chernarus",
	//LOCAIS DE CURA
	["Land_Church_03","Land_Church_01","Land_Church_05R"],
	//QUANTIA DE MERCADOS
	15,
	//PERCENTAGEM VAULT
	1,
	//CARROS
	[220,10],
	//HELIS
	[10,25,["Land_Mil_hangar_EP1"],10],
	//BOTS A PE
	[true,[10,200]],
	//REVOLTOSOS
	[true,15],
	//VEICULOS BOT
	[false,[[[[3],0],[[5],0],[[6],0],[[3],1],[[5],1],[[6],1]],5]],
	//QUANTIA DE WALKERS
	[true,5],
	//DISTANCIA MINIMA DE CRUZAMENTOS DE RUA
	500,
	//MISSOES BRAVO POINT
	[true,["Land_Mil_Barracks_i"],[true],2],
	//EXTDB3 DATABASE ENTRY (NOT THE SCHEMA NAME IN MYSQL)
	"brpvp_chernarus",
	//LOOT BOM
	[
		"Land_Mil_Barracks_i", //62
		"Land_GH_Gazebo_F", //3
		"Land_rails_bridge_40", //4
		"Land_Brana02nodoor", //9
		"Land_Ind_SawMillPen", //6
		"Land_Ind_SawMill", //5
		"Land_Rail_House_01", //9
		"Land_Shed_Ind02", //13
		"Land_Misc_PowerStation", //11
		"Land_A_GeneralStore_01a", //8
		"Land_A_FuelStation_Shed", //8
		"Land_HouseV2_03B", //11
		"Land_HouseBlock_A3", //11
		"Land_HouseBlock_A1_1", //11
		"Land_Barn_Metal", //4
		"Land_Repair_center", //8
		"Land_NAV_Lighthouse", //4
		"Land_Vysilac_FM", //5
		"Land_Church_03", //5
		"Land_Nasypka", //31
		"Land_Hangar_2", //19
		"Land_Tovarna2", //4
		"land_nav_pier_m_end", //4
		"Land_nav_pier_m_2", //5
		"Land_Ind_Expedice_3", //6
		"Land_Mil_House", //5
		"Land_A_TVTower_Base", //1
		"Land_A_Office01", //3
		"Land_Ind_IlluminantTower", //8
		"Land_HouseV2_03", //8
		"Land_Komin", //4
		"Land_Sara_hasic_zbroj", //2
		"Land_Sara_domek_zluty", //3
		"Land_Ss_hangar", //12
		"Land_Misc_Cargo1Ao", //2
		"MASH", //37
		"Land_Panelak", //8
		"Land_ruin_01", //4
		"Barrack2", //4
		"Land_A_Villa_EP1", //4
		"Land_Mil_ControlTower", //5
		"Land_a_stationhouse", //6
		"Land_A_statue02", //3
		"Land_Ind_SiloVelke_01", //2
		"Land_Ind_Pec_01", //2
		"Land_Church_01", //6
		"Land_Barn_W_02", //3
		"Land_Misc_Cargo1Bo", //2
		"Land_Ind_MalyKomin", //8
		"CampEast_EP1", //1
		"CampEast", //6
		"Land_Molo_drevo_bs", //5
		"Land_rail_station_big", //3
		"Land_Ind_Mlyn_01", //1
		"Land_Ind_Mlyn_04", //1
		"Land_Ind_Vysypka", //2
		"Land_Ind_Mlyn_02", //1
		"Land_Ind_Mlyn_03", //1
		"Land_A_GeneralStore_01", //3
		"Land_Vez_Silo", //2
		"Land_A_Castle_Gate", //3
		"Land_Ind_Expedice_1", //5
		"Land_Telek1", //4
		"Land_A_Castle_Bergfrit", //3
		"Land_A_Pub_01", //8
		"Land_HouseBlock_A1", //3
		"Land_radar_EP1", //1
		"Land_WoodenRamp", //6
		"Land_A_MunicipalOffice", //2
		"Land_HouseB_Tenement", //1
		"Land_A_Castle_Wall1_20", //6
		"Land_A_Castle_Wall1_20_Turn", //4
		"Land_A_Castle_Stairs_A", //3
		"Land_A_Castle_Wall1_Corner_2", //2
		"Land_A_Crane_02b", //14
		"Land_A_Crane_02a", //14
		"Land_IndPipe1_stair", //7
		"land_nav_pier_m_1", //6
		"land_nav_pier_c_big", //2
		"land_nav_pier_c_t20", //6
		"land_nav_pier_M_fuel", //3
		"Land_A_BuildingWIP", //3
		"Land_A_CraneCon", //1
		"Land_Church_05R", //1
		"Land_NAV_Lighthouse2", //1
		"Land_Misc_Scaffolding", //4
		"Land_Dam_Conc_20", //9
		"Land_Dam_ConcP_20", //3
		"land_nav_pier_c2_end", //7
		"Land_Ind_Stack_Big", //2
		"Land_Dum_mesto2", //1
		"Land_Molo_drevo_end", //4
		"Land_A_Castle_Wall1_Corner", //1
		"Land_Nav_Boathouse", //2
		"Land_Shed_wooden", //4
		"land_nav_pier_c2", //2
		"Camp", //4
		"Land_Ind_Quarry" //1
	],
	//LOOT RUIM
	[
		"Land_HouseV_1L2", //101
		"Land_Kulna", //76
		"Land_HouseV_1I1", //103
		"Land_HouseV_1I4", //115
		"Land_HouseV_3I2", //101
		"Land_Misc_deerstand", //56
		"Land_HouseV_1L1", //97
		"Land_houseV_2T2", //61
		"Land_Ind_Workshop01_01", //62
		"Land_Wall_CBrk_5_D", //46
		"Land_Hlidac_budka", //44
		"Land_Ind_Garage01", //28
		"MASH_EP1" //15
	],
	//LOOT MEDIO
	[
		"Land_Barn_W_01", //31
		"Land_Vez", //33
		"Land_Stodola_open", //20
		"Land_HouseV2_01B", //20
		"Land_HouseV2_01A", //26
		"Land_Farm_Cowshed_a", //23
		"Land_Farm_Cowshed_b", //37
		"Land_HouseV2_05", //19
		"Land_Wall_CGry_5_D", //26
		"Land_Farm_Cowshed_c", //23
		"Land_Hut06", //53
		"Land_Ind_Workshop01_02", //42
		"Land_Ind_Workshop01_04", //37
		"Land_A_FuelStation_Build", //15
		"Land_Trafostanica_velka", //16
		"Land_Ind_Workshop01_L", //33
		"Land_Stodola_old_open", //21
		"Land_Mil_Guardhouse", //20
		"Land_HouseV2_02_Interier" //18
	],
	//VENDEDORES VEICULOS
	[[3339,["CIVIL"]],[7115,["CAPTALISM"]],[6921,["COMUNISM"]],[2584,["GUERRILLA"]],[1407,["CIVIL"]],[7375,["CAPTALISM"]],[4809,["COMUNISM"]],[6153,["GUERRILLA"]],[8370,["COMUNISM"]],[1137,["GUERRILLA"]],[5448,["CAPTALISM"]]],
	//FACCOES IGNORAR
	[],
	//INCIDENCIA LOOT
	[0.25/*LOOT RUIM*/,0.5/*LOOT MEDIO*/,0.75/*LOOT BOM*/,1/*PERC REUSO DE LOCAL DE LOOT*/],
	//SIEGE MISSIONS
	[true,2],
	//CONVOY MISSIONS
	[
		true,
		4,
		[
			[1,[1325,256,19781,7863,3148,4070,13643,18878,3099,5952,7400,8139,5009]] //MAIN CONTINENT
		]
	],
	//CIVIL PLANE CRASH MISSION - FIND THE CORRUPT POLITICIAN
	[true,[[BRPVP_centroMapa,6000]],1,30,50000]
];

//MAP EXTRA BUILDINGS
BRP_kitChernarusBuildingsI = ["Land_Ind_Garage01","Land_Ind_Workshop01_01","Land_Hlidac_budka","Land_A_statue01","Land_Ind_Workshop01_L","CampEast","USMC_WarfareBFieldhHospital"];
BRPVP_specialItemsExtra = ["BRP_kitChernarusBuildingsI"];
BRPVP_specialItemsNamesExtra = ["Small Buildings"];
BRPVP_specialItemsImagesExtra = ["BRP_imagens\items\BRP_kitMapSpecific.paa"];
BRPVP_mercadoItensExtra = [[16,7,0,"BRP_kitChernarusBuildingsI",6.25]];
BRPVP_mercadoNomesNomesConstructionExtra = ["Chernarus"];
BRPVP_buildingHaveDoorListExtra = ["Land_Ind_Garage01","Land_Ind_Workshop01_01","Land_Hlidac_budka","Land_Ind_Workshop01_L"];
BRPVP_buildingHaveDoorListReverseDoorExtra = ["Land_Hlidac_budka"];

//RADAR SPOTS
_antennasVanilla = ["Land_TTowerSmall_1_F","Land_TTowerSmall_2_F","Land_TTowerBig_1_F","Land_TTowerBig_2_F"];
_antennasVanillaForce = [[1200,0.1,5],[800,0.025,2],[2250,0.1,5],[1500,0.025,2]];
_antennasCustom = [];
_antennasCustomForce = [];
BRPVP_antennasObjs = _antennasVanilla + _antennasCustom;
BRPVP_antennasObjsForce = _antennasVanillaForce + _antennasCustomForce;

//RYAN ZOMBIES
BRPVP_zombiesMaxGroups = 30;
BRPVP_ryanZombiesClasses = [
	"RyanZombieC_man_1",
	"RyanZombieC_man_polo_1_F",
	"RyanZombieC_man_polo_2_F",
	"RyanZombieC_man_polo_4_F",
	"RyanZombieC_man_polo_5_F",
	"RyanZombieC_man_polo_6_F",
	"RyanZombieC_man_p_fugitive_F",
	"RyanZombieC_man_w_worker_F",
	"RyanZombieC_scientist_F",
	"RyanZombieC_man_hunter_1_F",
	"RyanZombieC_man_pilot_F",
	"RyanZombieC_journalist_F",
	"RyanZombieC_Orestes",
	"RyanZombieC_Nikos",
	"RyanZombie15",
	"RyanZombie16",
	"RyanZombie17",
	"RyanZombie18",
	"RyanZombie19",
	"RyanZombie20",
	"RyanZombie21",
	"RyanZombie22",
	"RyanZombie23",
	"RyanZombie24",
	"RyanZombie25",
	"RyanZombie26",
	"RyanZombie27",
	"RyanZombie28",
	"RyanZombie29",
	"RyanZombie30",
	"RyanZombie31",
	"RyanZombie32",
	"RyanZombieB_Soldier_02_f",
	"RyanZombieB_Soldier_02_f_1",
	"RyanZombieB_Soldier_02_f_1_1",
	"RyanZombieB_Soldier_03_f",
	"RyanZombieB_Soldier_03_f_1",
	"RyanZombieB_Soldier_03_f_1_1",
	"RyanZombieB_Soldier_04_f",
	"RyanZombieB_Soldier_04_f_1",
	"RyanZombieB_Soldier_04_f_1_1",
	"RyanZombieB_Soldier_lite_F",
	"RyanZombieB_Soldier_lite_F_1",
	"RyanZombieC_man_1medium",
	"RyanZombieC_man_polo_1_Fmedium",
	"RyanZombieC_man_polo_2_Fmedium",
	"RyanZombieC_man_polo_4_Fmedium",
	"RyanZombieC_man_polo_5_Fmedium",
	"RyanZombieC_man_polo_6_Fmedium",
	"RyanZombieC_man_p_fugitive_Fmedium",
	"RyanZombieC_man_w_worker_Fmedium",
	"RyanZombieC_scientist_Fmedium",
	"RyanZombieC_man_hunter_1_Fmedium",
	"RyanZombieC_man_pilot_Fmedium",
	"RyanZombieC_journalist_Fmedium",
	"RyanZombieC_Orestesmedium",
	"RyanZombieC_Nikosmedium",
	"RyanZombie15medium",
	"RyanZombie16medium",
	"RyanZombie17medium",
	"RyanZombie18medium",
	"RyanZombie19medium",
	"RyanZombie20medium",
	"RyanZombie21medium",
	"RyanZombie22medium",
	"RyanZombie23medium",
	"RyanZombie24medium",
	"RyanZombie25medium",
	"RyanZombie26medium",
	"RyanZombie27medium",
	"RyanZombie28medium",
	"RyanZombie29medium",
	"RyanZombie30medium",
	"RyanZombie31medium",
	"RyanZombie32medium",
	"RyanZombieB_Soldier_02_fmedium",
	"RyanZombieB_Soldier_02_f_1medium",
	"RyanZombieB_Soldier_02_f_1_1medium",
	"RyanZombieB_Soldier_03_fmedium",
	"RyanZombieB_Soldier_03_f_1medium",
	"RyanZombieB_Soldier_03_f_1_1medium",
	"RyanZombieB_Soldier_04_fmedium",
	"RyanZombieB_Soldier_04_f_1medium",
	"RyanZombieB_Soldier_04_f_1_1medium",
	"RyanZombieB_Soldier_lite_Fmedium",
	"RyanZombieB_Soldier_lite_F_1medium",
	"RyanZombieC_man_1slow",
	"RyanZombieC_man_polo_1_Fslow",
	"RyanZombieC_man_polo_2_Fslow",
	"RyanZombieC_man_polo_4_Fslow",
	"RyanZombieC_man_polo_5_Fslow",
	"RyanZombieC_man_polo_6_Fslow",
	"RyanZombieC_man_p_fugitive_Fslow",
	"RyanZombieC_man_w_worker_Fslow",
	"RyanZombieC_scientist_Fslow",
	"RyanZombieC_man_hunter_1_Fslow",
	"RyanZombieC_man_pilot_Fslow",
	"RyanZombieC_journalist_Fslow",
	"RyanZombieC_Orestesslow",
	"RyanZombieC_Nikosslow",
	"RyanZombie15slow",
	"RyanZombie16slow",
	"RyanZombie17slow",
	"RyanZombie18slow",
	"RyanZombie19slow",
	"RyanZombie20slow",
	"RyanZombie21slow",
	"RyanZombie22slow",
	"RyanZombie23slow",
	"RyanZombie24slow",
	"RyanZombie25slow",
	"RyanZombie26slow",
	"RyanZombie27slow",
	"RyanZombie28slow",
	"RyanZombie29slow",
	"RyanZombie30slow",
	"RyanZombie31slow",
	"RyanZombie32slow",
	"RyanZombieB_Soldier_02_fslow",
	"RyanZombieB_Soldier_02_f_1slow",
	"RyanZombieB_Soldier_02_f_1_1slow",
	"RyanZombieB_Soldier_03_fslow",
	"RyanZombieB_Soldier_03_f_1slow",
	"RyanZombieB_Soldier_03_f_1_1slow",
	"RyanZombieB_Soldier_04_fslow",
	"RyanZombieB_Soldier_04_f_1slow",
	"RyanZombieB_Soldier_04_f_1_1slow",
	"RyanZombieB_Soldier_lite_Fslow",
	"RyanZombieB_Soldier_lite_F_1slow",
	"RyanZombieC_man_1Walker",
	"RyanZombieC_man_polo_1_FWalker",
	"RyanZombieC_man_polo_2_FWalker",
	"RyanZombieC_man_polo_4_FWalker",
	"RyanZombieC_man_polo_5_FWalker",
	"RyanZombieC_man_polo_6_FWalker",
	"RyanZombieC_man_p_fugitive_FWalker",
	"RyanZombieC_man_w_worker_FWalker",
	"RyanZombieC_scientist_FWalker",
	"RyanZombieC_man_hunter_1_FWalker",
	"RyanZombieC_man_pilot_FWalker",
	"RyanZombieC_journalist_FWalker",
	"RyanZombieC_OrestesWalker",
	"RyanZombieC_NikosWalker",
	"RyanZombie15walker",
	"RyanZombie16walker",
	"RyanZombie17walker",
	"RyanZombie18walker",
	"RyanZombie19walker",
	"RyanZombie20walker",
	"RyanZombie21walker",
	"RyanZombie22walker",
	"RyanZombie23walker",
	"RyanZombie24walker",
	"RyanZombie25walker",
	"RyanZombie26walker",
	"RyanZombie27walker",
	"RyanZombie28walker",
	"RyanZombie29walker",
	"RyanZombie30walker",
	"RyanZombie31walker",
	"RyanZombie32walker",
	"RyanZombieB_Soldier_02_fWalker",
	"RyanZombieB_Soldier_02_f_1Walker",
	"RyanZombieB_Soldier_02_f_1_1Walker",
	"RyanZombieB_Soldier_03_fWalker",
	"RyanZombieB_Soldier_03_f_1Walker",
	"RyanZombieB_Soldier_03_f_1_1Walker",
	"RyanZombieB_Soldier_04_fWalker",
	"RyanZombieB_Soldier_04_f_1Walker",
	"RyanZombieB_Soldier_04_f_1_1Walker",
	"RyanZombieB_Soldier_lite_FWalker",
	"RyanZombieB_Soldier_lite_F_1Walker",
	"RyanZombieSpider1",
	"RyanZombieSpider2",
	"RyanZombieSpider3",
	"RyanZombieSpider4",
	"RyanZombieSpider5",
	"RyanZombieSpider6",
	"RyanZombieSpider7",
	"RyanZombieSpider8",
	"RyanZombieSpider9",
	"RyanZombieSpider10",
	"RyanZombieSpider11",
	"RyanZombieSpider12",
	"RyanZombieSpider13",
	"RyanZombieSpider14",
	"RyanZombieSpider15",
	"RyanZombieSpider16",
	"RyanZombieSpider17",
	"RyanZombieSpider18",
	"RyanZombieSpider19",
	"RyanZombieSpider20",
	"RyanZombieSpider21",
	"RyanZombieSpider22",
	"RyanZombieSpider23",
	"RyanZombieSpider24",
	"RyanZombieSpider25",
	"RyanZombieSpider26",
	"RyanZombieSpider27",
	"RyanZombieSpider28",
	"RyanZombieSpider29",
	"RyanZombieSpider30",
	"RyanZombieSpider31",
	"RyanZombieSpider32"
	/*
	"RyanZombieCrawler1",
	"RyanZombieCrawler2",
	"RyanZombieCrawler3",
	"RyanZombieCrawler4",
	"RyanZombieCrawler5",
	"RyanZombieCrawler6",
	"RyanZombieCrawler7",
	"RyanZombieCrawler8",
	"RyanZombieCrawler9",
	"RyanZombieCrawler10",
	"RyanZombieCrawler11",
	"RyanZombieCrawler12",
	"RyanZombieCrawler13",
	"RyanZombieCrawler14",
	"RyanZombieCrawler15",
	"RyanZombieCrawler16",
	"RyanZombieCrawler17",
	"RyanZombieCrawler18",
	"RyanZombieCrawler19",
	"RyanZombieCrawler20",
	"RyanZombieCrawler21",
	"RyanZombieCrawler22",
	"RyanZombieCrawler23",
	"RyanZombieCrawler24",
	"RyanZombieCrawler25",
	"RyanZombieCrawler26",
	"RyanZombieCrawler27",
	"RyanZombieCrawler28",
	"RyanZombieCrawler29",
	"RyanZombieCrawler30",
	"RyanZombieCrawler31",
	"RyanZombieCrawler32",
	*/
];
