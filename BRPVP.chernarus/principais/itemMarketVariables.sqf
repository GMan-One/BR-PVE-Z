diag_log "[BRPVP FILE] variaveis_mercado.sqf INITIATED";

//INDICES DE VENDA
BRPVP_mercadorIdc1 = -1;
BRPVP_mercadorIdc2 = -1;
BRPVP_mercadorIdc3 = -1;

//DEPARTAMENTOS
BRPVP_mercadoNomes = [
	"Backpacks",
	"Uniforms/Helmet",
	"Vests",
	"Assault Rifles",
	"Snipers",
	"Pistols",
	"Machine Guns",
	"Ammo Pistols/SMG",
	"Ammo Machine Gun",
	"Ammo Sniper",
	"Optics",
	"Equipment",
	"Weapon Acessories",
	"Launchers",
	"Explosives",
	"Ammo Assault Rifles",
	"Construction",
	"Extra Items"
];
BRPVP_mercadoNomesNomes = [
	["Cool","Pro","Super"],
	["Uniforms","Special","Helmets"],
	["Many Pockets","Light Armor","Ultra Heavy"],
	["A3 Vanilla","Apex DLC"],
	["A3 Vanilla","Marksman DLC"],
	["A3 Vanilla"],
	["Light MG","Medium MG"],
	["9 mm e .45"],
	["Light MG ammo","Medium MG ammo"],
	["A3 Vanilla","Marksman DLC"],
	["Basic","Mid-Range","High-Range"],
	["Default","Special"],
	["Supressors","Bi-pods","Others"],
	["Launchers","Rockets"],
	["Mines","Grenades","Slugs"],
	["556 545 762 650 050"],
	["Simple","Strong","Special","Objects","Base Usefull","Extra Extrucs I","Houses"] + BRPVP_mercadoNomesNomesConstructionExtra,
	["Extra Items"]
];

//LOJA PADRAO

BRPVP_mercadoresEstoque = [
	[[0,1,2,11,5,3,6,4,7,15,8,9,13,10,12,14,16],"Brogda"],
	[[0,1,2,11,5,3,6,4,7,15,8,9,13,10,12,14,16],"Dazos"],
	[[0,1,2,11,5,3,6,4,7,15,8,9,13,10,12,14,16],"Lamaul"],
	[[0,1,2,11,5,3,6,4,7,15,8,9,13,10,12,14,16],"Soros"],
	[[0,1,2,11,5,3,6,4,7,15,8,9,13,10,12,14,16],"Balior"],
	[[0,1,2,11,5,3,6,4,7,15,8,9,13,10,12,14,16],"Caca"],
	[[0,1,2,11,5,3,6,4,7,15,8,9,13,10,12,14,16],"Norberg"],
	[[0,1,2,11,5,3,6,4,7,15,8,9,13,10,12,14,16],"Famus"],
	[[0,1,2,11,5,3,6,4,7,15,8,9,13,10,12,14,16],"Silva"],
	[[0,1,2,11,5,3,6,4,7,15,8,9,13,10,12,14,16],"Bob"],
	[[0,1,2,11,5,3,6,4,7,15,8,9,13,10,12,14,16],"Tarkov"],
	[[0,1,2,11,5,3,6,4,7,15,8,9,13,10,12,14,16],"Ginard"],
	[[0,1,2,11,5,3,6,4,7,15,8,9,13,10,12,14,16],"Mr. Butt"],
	[[0,1,2,11,5,3,6,4,7,15,8,9,13,10,12,14,16],"Darjna"],
	[[0,1,2,11,5,3,6,4,7,15,8,9,13,10,12,14,16],"Kerk"],
	[[0,1,2,11,5,3,6,4,7,15,8,9,13,10,12,14,16],"Fantasia"],
	[[0,1,2,11,5,3,6,4,7,15,8,9,13,10,12,14,16],"Millard"],
	[[0,1,2,11,5,3,6,4,7,15,8,9,13,10,12,14,16],"Tortein"],
	[[0,1,2,11,5,3,6,4,7,15,8,9,13,10,12,14,16],"Grazza"],
	[[0,1,2,11,5,3,6,4,7,15,8,9,13,10,12,14,16],"Sonderj"]
];
BRPVP_mercadoPrecos = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
BRPVP_mercadoPrecos = BRPVP_mercadoPrecos apply {_x * BRPVP_marketPricesMultiply};

//SPECIAL ITEMS
BRPVP_specialItems = [
	"BRP_kitLight",
	"BRP_kitCamuflagem",
	"BRP_kitAreia",
	"BRP_kitCidade",
	"BRP_kitStone",
	"BRP_kitCasebres",
	"BRP_kitConcreto",
	"BRP_kitPedras",
	"BRP_kitTorres",
	"BRP_kitEspecial",
	"BRP_kitTableChair",
	"BRP_kitBeach",
	"BRP_kitReligious",
	"BRP_kitStuffo1",
	"BRP_kitStuffo2",
	"BRP_kitLamp",
	"BRP_kitRecreation",
	"BRP_kitMilitarSign",
	"BRP_kitFuelStorage",
	"BRP_kitWrecks",
	"BRP_kitSmallHouse",
	"BRP_kitAverageHouse",
	"BRP_kitAntennaA",
	"BRP_kitAntennaB",
	"BRP_kitMovement",
	"BRP_kitRespawnA",
	"BRP_kitRespawnB",
	"BRP_kitHelipad"
] + BRPVP_specialItemsExtra;

//SPECIAL ITEMS NAMES
BRPVP_specialItemsNames = [
	"Light Kit",
	"Camouflage Kit",
	"Sand Barrier Kit",
	"Modern City Kit",
	"Stone City Kit",
	"Slum Houses Kit",
	"Concrete Kit",
	"Rough Kit",
	"Towers Kit",
	"Special Kit",
	"Table and Chair",
	"Beach Items",
	"Religious Items",
	"Stuffos I",
	"Stuffos II",
	"Light and Lamp",
	"Recreation Items",
	"Militar Signs",
	"Fuel and Storage",
	"Wrecks",
	"Small Houses",
	"Average Houses",
	"Radar Spots",
	"Radar U-Spots",
	"Movement Blocks",
	"Respawn Generic",
	"Respawn Stealth",
	"Helipads"
] + BRPVP_specialItemsNamesExtra;

//SPECIAL ITEMS IMAGES
BRPVP_specialItemsImages = [
	"BRP_imagens\items\BRP_kitLight.paa",
	"BRP_imagens\items\BRP_kitCamuflagem.paa",
	"BRP_imagens\items\BRP_kitAreia.paa",
	"BRP_imagens\items\BRP_kitCidade.paa",
	"BRP_imagens\items\BRP_kitStone.paa",
	"BRP_imagens\items\BRP_kitCasebres.paa",
	"BRP_imagens\items\BRP_kitConcreto.paa",
	"BRP_imagens\items\BRP_kitPedras.paa",
	"BRP_imagens\items\BRP_kitTorres.paa",
	"BRP_imagens\items\BRP_kitEspecial.paa",
	"BRP_imagens\items\BRP_kitTableChair.paa",
	"BRP_imagens\items\BRP_kitBeach.paa",
	"BRP_imagens\items\BRP_kitReligious.paa",
	"BRP_imagens\items\BRP_kitStuffo1.paa",
	"BRP_imagens\items\BRP_kitStuffo2.paa",
	"BRP_imagens\items\BRP_kitLamp.paa",
	"BRP_imagens\items\BRP_kitRecreation.paa",
	"BRP_imagens\items\BRP_kitMilitarSign.paa",
	"BRP_imagens\items\BRP_kitFuelStorage.paa",
	"BRP_imagens\items\BRP_kitWrecks.paa",
	"BRP_imagens\items\BRP_kitSmallHouse.paa",
	"BRP_imagens\items\BRP_kitAverageHouse.paa",
	"BRP_imagens\items\BRP_kitAntennaA.paa",
	"BRP_imagens\items\BRP_kitAntennaB.paa",
	"BRP_imagens\items\BRP_kitMovement.paa",
	"BRP_imagens\items\BRP_kitRespawnA.paa",
	"BRP_imagens\items\BRP_kitRespawnB.paa",
	"BRP_imagens\items\BRP_kitHelipad.paa"
] + BRPVP_specialItemsImagesExtra;

//PRODUTOS
BRPVP_mercadoItens = [
	//BAGS LEGAIS
	[0,0,0,"B_AssaultPack_blk",165],
	[0,0,1,"B_AssaultPack_khk",165],
	[0,0,2,"B_AssaultPack_rgr",165],
	[0,0,3,"B_AssaultPack_sgg",200],
	[0,0,4,"B_AssaultPack_dgtl",200],

	//BAGS PRO
	[0,1,0,"C_Bergen_blu",330],
	[0,1,1,"C_Bergen_grn",330],
	[0,1,2,"C_Bergen_red",330],
	[0,1,3,"B_TacticalPack_mcamo",360],
	[0,1,4,"B_TacticalPack_ocamo",360],
	
	//BAGS SUPER
	[0,2,0,"B_Carryall_oli",500],
	[0,2,1,"B_Carryall_oucamo",500],
	[0,2,2,"B_Carryall_khk",500],
	[0,2,3,"B_Carryall_mcamo",530],
	[0,2,4,"B_Carryall_ocamo",530],

	//UNIFORMES PADRAO
	[1,0,0,"U_O_CombatUniform_ocamo",215],
	[1,0,1,"U_O_PilotCoveralls",215],
	[1,0,2,"U_O_Wetsuit",215],
	[1,0,3,"U_O_CombatUniform_oucamo",215],
	[1,0,4,"U_O_SpecopsUniform_ocamo",215],
	[1,0,5,"U_O_SpecopsUniform_blk",215],
	[1,0,6,"U_O_OfficerUniform_ocamo",215],
	[1,0,7,"U_O_Protagonist_VR",215],
	[1,0,8,"U_O_Soldier_VR",215],
	[1,0,9,"U_O_T_Soldier_F",215],
	[1,0,10,"U_O_T_Officer_F",215],
	[1,0,11,"U_O_T_Sniper_F",215],
	[1,0,12,"U_O_V_Soldier_Viper_F",215],
	[1,0,13,"U_O_V_Soldier_Viper_hex_F",215],
	
	//UNIFORMES ESPECIAIS
	[1,1,0,"U_O_GhillieSuit",380],
	[1,1,1,"U_O_FullGhillie_lsh",380],
	[1,1,2,"U_O_FullGhillie_sard",380],
	[1,1,3,"U_O_FullGhillie_ard",380],
	[1,1,4,"U_O_T_FullGhillie_tna_F",430],
	
	//CAPACETES
	[1,2,0,"H_Cap_red",65],
	[1,2,1,"H_Cap_blu",65],
	[1,2,2,"H_Cap_oli",65],
	[1,2,3,"H_Cap_tan",65],
	[1,2,4,"H_Cap_blk",65],
	[1,2,5,"H_Cap_grn",65],
	[1,2,6,"H_Shemag_olive",65],
	[1,2,7,"H_Watchcap_camo",130],
	[1,2,8,"H_PilotHelmetHeli_O",160],
	[1,2,9,"H_PilotHelmetFighter_O",215],

	//VESTS BOLSOS
	[2,0,0,"V_Chestrig_blk",200],
	[2,0,1,"V_Chestrig_khk",200],
	[2,0,2,"V_Chestrig_oli",200],
	[2,0,3,"V_Chestrig_rgr",200],
	
	//VESTS LIGHT ARMOR
	[2,1,0,"V_PlateCarrier_Kerry",400],
	[2,1,1,"V_PlateCarrier2_rgr",400],
	[2,1,2,"V_PlateCarrierIA2_dgtl",440],

	//VESTS ULTRA HEAVY	
	[2,2,0,"V_PlateCarrierGL_rgr",600],
	[2,2,1,"V_PlateCarrierIAGL_dgtl",600],
	[2,2,2,"V_TacVest_blk_POLICE",600],
	[2,2,3,"V_PlateCarrierSpec_rgr",700],
	
	//ASSAULT RIFLES
	[3,0,0,"arifle_Katiba_F",600],
	[3,0,1,"arifle_MX_F",600],
	[3,0,2,"arifle_TRG20_F",600],
	[3,0,3,"arifle_Mk20_GL_F",600],
	[3,0,4,"arifle_TRG21_GL_F",600],
	[3,0,5,"arifle_MX_SW_F",600],
	
	//ASSAULT RIFLES (APEX DLC)
	[3,1,0,"arifle_AKS_F",600],
	[3,1,1,"arifle_AK12_F",660],
	[3,1,2,"arifle_AK12_GL_F",720],
	[3,1,3,"arifle_AKM_F",660],
	[3,1,4,"arifle_AKM_FL_F",720],
	[3,1,5,"arifle_ARX_blk_F",735],
	[3,1,6,"arifle_ARX_hex_F",735],
	[3,1,7,"arifle_ARX_ghex_F",735],

	//SNIPER RIFLES
	[4,0,0,"srifle_DMR_01_F",625],
	[4,0,1,"srifle_EBR_F",625],
	[4,0,2,"srifle_GM6_F",1250],
	[4,0,3,"srifle_LRR_F",1250],
	[4,0,4,"srifle_GM6_camo_F",1375],
	[4,0,5,"srifle_LRR_camo_F",1375],
	
	//SNIPER RIFLES (MARSKMAN DLC)
	[4,1,0,"srifle_DMR_02_F",1250],
	[4,1,1,"srifle_DMR_02_camo_F",1375],
	[4,1,2,"srifle_DMR_02_sniper_F",1375],
	[4,1,3,"srifle_DMR_03_F",1250],
	[4,1,4,"srifle_DMR_03_khaki_F",1375],
	[4,1,5,"srifle_DMR_03_tan_F",1375],
	[4,1,6,"srifle_DMR_03_multicam_F",1375],
	[4,1,7,"srifle_DMR_03_woodland_F",1375],
	[4,1,8,"srifle_DMR_04_F",1250],
	[4,1,9,"srifle_DMR_04_Tan_F",1375],
	[4,1,10,"srifle_DMR_05_blk_F",1375],
	[4,1,11,"srifle_DMR_05_hex_F",1375],
	[4,1,12,"srifle_DMR_05_tan_f",1375],
	[4,1,13,"srifle_DMR_06_camo_F",1375],
	[4,1,14,"srifle_DMR_06_olive_F",1375],
	[4,1,15,"srifle_DMR_07_blk_F",1375],
	[4,1,16,"srifle_DMR_07_hex_F",1375],
	[4,1,17,"srifle_DMR_07_ghex_F",1375],

	//PISTOLAS
	[5,0,0,"hgun_ACPC2_F",300],
	[5,0,1,"hgun_Pistol_heavy_01_F",360],
	[5,0,2,"hgun_Pistol_heavy_02_F",360],
	
	//MACHINE GUNS
	[6,0,0,"LMG_03_F",850],
	[6,0,1,"LMG_Mk200_F",1000],
	[6,0,2,"LMG_Zafir_F",1200],
	[6,1,0,"MMG_01_hex_F",1350],
	[6,1,1,"MMG_01_tan_F",1350],
	[6,1,2,"MMG_02_camo_F",1500],
	[6,1,3,"MMG_02_black_F",1500],
	[6,1,4,"MMG_02_sand_F",1500],

	//BASIC AMMO: 9.0 MM E .45
	[7,0,0,"16Rnd_9x21_Mag",50],
	[7,0,1,"30Rnd_9x21_Mag",90],
	[7,0,2,"6Rnd_45ACP_Cylinder",40],
	[7,0,3,"9Rnd_45ACP_Mag",40],
	[7,0,4,"11Rnd_45ACP_Mag",50],
	
	//MACHINE GUN AMMO: LIGHT MG / MEDIUM MG
	[8,0,0,"200Rnd_556x45_Box_F",150],
	[8,0,1,"200Rnd_556x45_Box_Tracer_F",150],
	[8,0,2,"200Rnd_65x39_cased_Box",180],
	[8,0,3,"200Rnd_65x39_cased_Box_Tracer",200],
	[8,0,4,"150Rnd_762x54_Box",215],
	[8,0,5,"150Rnd_762x54_Box_Tracer",230],
	[8,1,0,"150Rnd_93x64_Mag",250],
	[8,1,1,"130Rnd_338_Mag",250],
	
	//SNIPER AMMO: PADRAO / MARKSMAN
	[9,0,0,"10Rnd_762x54_Mag",100],
	[9,0,1,"20Rnd_762x51_Mag",130],
	[9,0,2,"5Rnd_127x108_Mag",250],
	[9,0,3,"5Rnd_127x108_APDS_Mag",260],
	[9,0,4,"7Rnd_408_Mag",260],
	[9,1,0,"20Rnd_650x39_Cased_Mag_F",120],
	[9,1,1,"20Rnd_762x51_Mag",140],
	[9,1,2,"10Rnd_338_Mag",290],
	[9,1,3,"10Rnd_127x54_Mag",290],
	[9,1,4,"10Rnd_93x64_DMR_05_Mag",290],

	//OPTICS BASICO
	[10,0,0,"optic_Aco_smg",150],
	[10,0,1,"optic_ACO_grn_smg",150],
	[10,0,2,"optic_Holosight_smg",150],
	[10,0,3,"optic_Aco",150],
	[10,0,4,"optic_ACO_grn",150],
	[10,0,5,"optic_Holosight",150],
	[10,0,6,"optic_Yorris",120],
	[10,0,7,"optic_MRD",120],

	//OPTICS M-RANGE
	[10,1,0,"optic_AMS",250],
	[10,1,1,"optic_AMS_khk",250],
	[10,1,2,"optic_AMS_snd",250],
	[10,1,3,"optic_KHS_blk",250],
	[10,1,4,"optic_KHS_hex",250],
	[10,1,5,"optic_KHS_old",250],
	[10,1,6,"optic_KHS_tan",250],
	[10,1,7,"optic_DMS",250],
	[10,1,8,"optic_SOS",250],
	[10,1,9,"optic_NVS",250],
	[10,1,10,"optic_Hamr",250],
	[10,1,11,"optic_Arco",250],
	[10,1,12,"optic_MRCO",250],

	//OIPTICS H-RANGE
	[10,2,0,"optic_LRPS",425],
	[10,2,1,"optic_tws",600],
	[10,2,2,"optic_tws_mg",600],
	[10,2,3,"optic_Nightstalker",600],
	
	//EQUIPAMENTOS
	[11,0,0,"ItemMap",50],
	[11,0,1,"Chemlight_green",65],
	[11,0,2,"ItemWatch",100],
	[11,0,3,"FirstAidKit",100],
	[11,0,4,"ItemCompass",200],
	[11,1,0,"Binocular",300],
	[11,1,1,"NVGoggles",300],
	[11,1,2,"ItemGPS",500],
	[11,1,3,"Rangefinder",500],
	[11,1,4,"ToolKit",1500],
	[11,1,5,"MediKit",1500],
	//[11,1,6,"MineDetector",5],
	
	//ACESSORIOS ARMA SUPRESSORES
	[12,0,0,"muzzle_snds_338_black",250],
	[12,0,1,"muzzle_snds_338_green",250],
	[12,0,2,"muzzle_snds_338_sand",250],
	[12,0,3,"muzzle_snds_93mmg",250],
	[12,0,4,"muzzle_snds_93mmg_tan",250],
	[12,0,5,"muzzle_snds_acp",250],
	[12,0,6,"muzzle_snds_B",250],
	[12,0,7,"muzzle_snds_H",250],
	[12,0,8,"muzzle_snds_H_MG",250],
	[12,0,9,"muzzle_snds_H_SW",250],
	[12,0,10,"muzzle_snds_L",250],
	[12,0,11,"muzzle_snds_M",250],

	//ACESSORIOS ARMA APOIOS
	[12,1,0,"bipod_01_F_mtp",120],
	[12,1,1,"bipod_01_F_snd",120],
	[12,1,2,"bipod_02_F_blk",120],
	[12,1,3,"bipod_02_F_hex",120],
	[12,1,4,"bipod_02_F_tan",120],
	[12,1,5,"bipod_03_F_oli",120],

	//ACESSORIOS ARMA OUTROS
	[12,2,0,"acc_flashlight",300],
	[12,2,1,"acc_pointer_IR",300],
	
	//LAUNCHERS
	[13,0,0,"launch_RPG32_F",800],
	[13,0,1,"launch_NLAW_F",1000],
	[13,0,2,"launch_B_Titan_tna_F",1500],
	
	//LAUNCHERS AMMO
	[13,1,0,"RPG32_F",150],
	[13,1,1,"NLAW_F",165],
	[13,1,2,"Titan_AT",300],

	//EXPLOSIVOS
	[14,0,0,"SLAMDirectionalMine_Wire_Mag",140],
	[14,0,1,"APERSTripMine_Wire_Mag",140],
	[14,0,2,"APERSMine_Range_Mag",200],
	[14,0,3,"APERSBoundingMine_Range_Mag",200],
	[14,0,4,"ATMine_Range_Mag",200],
	[14,0,5,"DemoCharge_Remote_Mag",260],
	[14,0,6,"ClaymoreDirectionalMine_Remote_Mag",260],

	//GRENADES
	[14,1,0,"B_IR_Grenade",90],
	[14,1,1,"HandGrenade",90],
	[14,1,2,"MiniGrenade",90],
	[14,1,3,"SmokeShell",80],
	[14,1,4,"SmokeShellOrange",80],
	[14,1,5,"SmokeShellGreen",80],
	[14,1,6,"SmokeShellPurple",80],
	[14,1,7,"SmokeShellBlue",80],
	
	//SLUGS
	[14,2,0,"1Rnd_HE_Grenade_shell",90],
	[14,2,1,"3Rnd_HE_Grenade_shell",100],
	[14,2,2,"1Rnd_Smoke_Grenade_shell",80],
	[14,2,3,"1Rnd_SmokeOrange_Grenade_shell",80],
	[14,2,4,"1Rnd_SmokeGreen_Grenade_shell",80],
	[14,2,5,"1Rnd_SmokePurple_Grenade_shell",80],
	[14,2,6,"1Rnd_SmokeBlue_Grenade_shell",80],
	
	//ASSAULT RIFLE AMMO
	[15,0,0,"30Rnd_556x45_Stanag",100],
	[15,0,1,"30Rnd_556x45_Stanag_Tracer_Red",105],
	[15,0,2,"30Rnd_556x45_Stanag_Tracer_Green",105],
	[15,0,3,"30Rnd_556x45_Stanag_Tracer_Yellow",105],
	[15,0,4,"30Rnd_545x39_Mag_F",90],
	[15,0,5,"30Rnd_545x39_Mag_Tracer_F",90],
	[15,0,6,"30Rnd_762x39_Mag_F",90],
	[15,0,7,"30Rnd_762x39_Mag_Tracer_F",90],
	[15,0,8,"30Rnd_65x39_caseless_green",100],
	[15,0,9,"30Rnd_65x39_caseless_green_mag_Tracer",100],
	[15,0,10,"10Rnd_50BW_Mag_F",125],

	//CONSTRUCAO SIMPLES
	[16,0,0,"BRP_kitCamuflagem",1000],
	[16,0,1,"BRP_kitLight",1000],
	[16,0,2,"BRP_kitAreia",1150],

	//CONSTRUCAO FORTE
	[16,1,0,"BRP_kitCidade",1200],
	[16,1,1,"BRP_kitStone",1200],
	[16,1,2,"BRP_kitCasebres",1200],
	[16,1,3,"BRP_kitConcreto",1650],

	//CONSTRUCAO ESPECIAL
	[16,2,0,"BRP_kitPedras",3000],
	[16,2,1,"BRP_kitRespawnA",5000],
	[16,2,2,"BRP_kitRespawnB",7500],
	[16,2,3,"BRP_kitTorres",10000],
	[16,2,4,"BRP_kitAntennaA",10000],
	[16,2,5,"BRP_kitEspecial",15000],
	[16,2,6,"BRP_kitAntennaB",15000],
		
	//OBJECTS
	[16,3,0,"BRP_kitTableChair",800],
	[16,3,1,"BRP_kitBeach",800],
	[16,3,2,"BRP_kitStuffo1",800],
	[16,3,3,"BRP_kitStuffo2",800],

	//BASE USEFULL I
	[16,4,0,"BRP_kitMilitarSign",1500],
	[16,4,1,"BRP_kitLamp",2500],
	[16,4,2,"BRP_kitMovement",2500],
	[16,4,3,"BRP_kitFuelStorage",4000],
		
	//EXTRA STRUCTURES I
	[16,5,0,"BRP_kitWrecks",2500],
	[16,5,1,"BRP_kitRecreation",2500],
	[16,5,2,"BRP_kitHelipad",3000],
	[16,5,3,"BRP_kitReligious",4000],
	
	//HOUSAS
	[16,6,0,"BRP_kitSmallHouse",10000],
	[16,6,1,"BRP_kitAverageHouse",15000],

	//EXTRA ITEMS
	[17,0,0,"30Rnd_65x39_caseless_mag_Tracer",100],
	[17,0,1,"100Rnd_65x39_caseless_mag_Tracer",160],
	[17,0,2,"ItemRadio",100],
	[17,0,3,"hgun_P07_F",120],
	[17,0,4,"SMG_02_F",220],
	[17,0,5,"V_BandollierB_blk",150],
	[17,0,6,"arifle_Mk20C_F",300],
	[17,0,7,"arifle_Mk20_F",300],
	[17,0,8,"hgun_PDW2000_F",120],
	[17,0,9,"FlareYellow_F",2000],
	[17,0,10,"FlareWhite_F",1000],
	[17,0,11,"arifle_MXM_F",300],
	[17,0,12,"H_HelmetIA",220],
	[17,0,13,"V_TacVest_oli",165],
	[17,0,14,"arifle_MXC_khk_F",300],
	[17,0,15,"B_Kitbag_rgr_BTAA_F",120],
	[17,0,16,"V_PlateCarrier1_tna_F",450]
] + BRPVP_mercadoItensExtra;

//ONLY ITEM CLASSES
BRPVP_mercadoItensClass = [];
{
	BRPVP_mercadoItensClass pushBack (_x select 3);
} forEach BRPVP_mercadoItens;
diag_log ("[BRPVP MARKET] BRPVP_mercadoItensClass = " + str BRPVP_mercadoItensClass + ".");

//ITEMS CFG TYPE AND PARENTS
BRPVP_mercadoItensParents = [];
{
	private ["_item","_ic","_ip"];
	_item = _x select 3;
	if (_item in BRPVP_specialItems) then {
		_ic = 0;
		_ip = [];
	} else {
		if (isClass (configFile >> "CfgMagazines" >> _item)) then {
			_ic = 0;
			_ip = [configfile >> "CfgMagazines" >> _item,true] call BIS_fnc_returnParents;
		} else {
			if (isClass (configFile >> "CfgWeapons" >> _item)) then {
				_ic = 1;
				_ip = [configfile >> "CfgWeapons" >> _item,true] call BIS_fnc_returnParents;
			} else {
				if (isClass (configFile >> "CfgVehicles" >> _item)) then {
					_ic = 2;
					_ip = [configfile >> "CfgVehicles" >> _item,true] call BIS_fnc_returnParents;
				};
			};
		};
	};
	BRPVP_mercadoItensParents pushBack [_item,_ic,_ip];
} forEach BRPVP_mercadoItens;
diag_log ("[BRPVP MARKET] BRPVP_mercadoItensParents = " + str BRPVP_mercadoItensParents + ".");

diag_log "[BRPVP FILE] variaveis_mercado.sqf END REACHED";