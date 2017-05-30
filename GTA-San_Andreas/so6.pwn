#include <a_samp>
native IsValidVehicle(vehicleid);
#include <zcmd>
#include <Dini>
#include <sscanf2>
#include <getvehicledriver>

new pickup_concess, pickup_repair, pickup_menuiserie, pickup_mineur;
new essais = 0;
new heure, minute, seconde;
new PlayerText:textRadTD, PlayerText:fondRadTD, PlayerText:barRadTD, PlayerText:compteurKMH,  PlayerText:heureTextDraw, PlayerText:degatTextDraw, PlayerText:carburantTextDraw, Float:vHealth, strDegat[10], PlayerText:fondTD, PlayerText:petitechelleTD, PlayerText:grandechelleTD, PlayerText:planchesTD, PlayerText:cabaneTD, PlayerText:fermerTD;
new PlayerText:fond2RadTD, PlayerText:batonTD, PlayerText:demarreTD, PlayerText:bidonTD, PlayerText:coffreTD, timerBarrageID;

//Paramètres
#define MaxCarBarrage 300
#define MaxEauBarrage 100

//Couleurs classiques
#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_ORANGE 0xFF8000FF
#define COLOR_TURQUOISE 0x2EFEF7FF
#define COLOR_GREEN 0x33FF33AA
#define COLOR_RED 0xFF0000AA
#define COLOR_BLUE 0x81F79FFF
#define COLOR_BLACK 0x000000FF
#define COLOR_BLUETD 0x0080FFFF
#define COLOR_GRIS 0xABABABFF

//Couleurs radiations
#define COLOR_RADIATION 0x1DB019FF
#define COLOR_RADIATION2 0x0B610BFF
#define COLOR_RAD_DAMAGE 0xF5DA81FF

//Couleurs radio
#define COLOR_RADIO1 0x76BBFFFF
#define COLOR_RADIO2 0x4DA6FFFF
#define COLOR_RADIO3 0x4492DFFF
#define COLOR_RADIO4 0x3A7BBCFF
#define COLOR_RADIO5 0x32689FFF

//Couleurs Aide
#define COLOR_CMD 0xE58A8500
#define COLOR_YELLOW 0xFFFF00FF

//Couleurs Blanches
#define COLOR_FADE1 0xFFFFFFFF
#define COLOR_FADE2 0xC8C8C8C8
#define COLOR_FADE3 0xAAAAAAAA
#define COLOR_FADE4 0x8C8C8C8C
#define COLOR_FADE5 0x6E6E6E6E

//Couleurs /me
#define COLOR_VIOLET1 0xED7EE700
#define COLOR_VIOLET2 0xDB74D600
#define COLOR_VIOLET3 0xBC63B800
#define COLOR_VIOLET4 0xA454A000
#define COLOR_VIOLET5 0x7F3F7B00

//DIALOG ARMES
#define DIALOG_ARMES (1)
#define DIALOG_ARMES_BLANCHES (2)
#define DIALOG_ARMES_POING (3)
#define DIALOG_FUSILS (4)
#define DIALOG_ARMES_EXPLOSIVES (5)
#define DIALOG_OBJETS (6)
#define DIALOG_GRENADES (7)

//DIALOG VEHICULES
#define DIALOG_VEHICLE (8)
#define DIALOG_AVIONS (9)
#define DIALOG_HELICO (10)
#define DIALOG_MOTOS (11)
#define DIALOG_TOIT (12)
#define DIALOG_INDUSTRIELS (13)
#define DIALOG_LOWRIDERS (14)
#define DIALOG_4x4 (15)
#define DIALOG_SERVICES (16)
#define DIALOG_NORMALES (17)
#define DIALOG_SPORTS (18)
#define DIALOG_FAMILIAUX (19)
#define DIALOG_BATEAUX (20)
#define DIALOG_INCLASSABLES (21)
#define DIALOG_MINIATURES (22)
#define DIALOG_LOGIN (23)
#define DIALOG_REGISTER (24)
#define DIALOG_AUTRE1 (25)
#define DIALOG_AUTRE2 (26)

public OnGameModeInit()
{
	//Met le bon horaire
	SendRconCommand("weather 12");
	SendRconCommand("mapname Apocalypse");
	SetGameModeText("ATF RP v0.1");
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	EnableVehicleFriendlyFire();
	EnableStuntBonusForAll(0);
	DisableNameTagLOS();
	ManualVehicleEngineAndLights();
	SetTeamCount(200);
	DisableInteriorEnterExits();
	//Assignation de l'heure
	gettime(heure, minute, seconde);
	SetWorldTime(heure);
	//Pickups
	pickup_concess = CreatePickup(1239, 2, -2241.2, 2296.1, 5.2, -1);
	pickup_repair = CreatePickup(1239, 2, -2231.2, 2299.3, 5.4, -1);
	pickup_menuiserie = CreatePickup(1239, 2, 291.2, 307.3, 999.14, -1);
	pickup_mineur = CreatePickup(1239, 2, -1071, 2153.2, 86.2, -1);
	//Placement des objets
	for(new objectid = 0; objectid < 1000; objectid++)
	{
		new fileName[32], nfileName[32], modelid, Float:o_pos[ 6 ], modelidTXT, txdname[48], texturename[48];
		format(fileName, sizeof(fileName), "objects/%i.txt", objectid);
		if(dini_Exists(fileName))
		{
			modelid = dini_Int(fileName, "modelid");
			o_pos[ 0 ] = dini_Float(fileName,"posX");
			o_pos[ 1 ] = dini_Float(fileName,"posY");
			o_pos[ 2 ] = dini_Float(fileName,"posZ");
			o_pos[ 3 ] = dini_Float(fileName,"rotX");
			o_pos[ 4 ] = dini_Float(fileName,"rotY");
			o_pos[ 5 ] = dini_Float(fileName,"rotZ");
			modelidTXT = dini_Int(fileName, "modelidTXT");
			format(txdname, sizeof(txdname), "%s", dini_Get(fileName, "txdname"));
			format(texturename, sizeof(texturename), "%s", dini_Get(fileName, "texturename"));
			dini_Remove(fileName);
			if(modelid == 0) continue;
			new nobjectid = CreateObject(modelid, o_pos[ 0 ], o_pos[ 1 ], o_pos[ 2 ], o_pos[ 3 ], o_pos[ 4 ], o_pos[ 5 ], 30000);
			if(modelidTXT != 0) SetObjectMaterial(nobjectid, 0, modelidTXT, txdname, texturename, 0);
			format(nfileName, sizeof(nfileName), "objects/%i.txt", nobjectid);
			dini_Create(nfileName);
            dini_IntSet(nfileName, "modelid", modelid);
			dini_FloatSet(nfileName,"posX", o_pos[ 0 ]);
			dini_FloatSet(nfileName,"posY", o_pos[ 1 ]);
			dini_FloatSet(nfileName,"posZ", o_pos[ 2 ]);
			dini_FloatSet(nfileName,"rotX", o_pos[ 3 ]);
			dini_FloatSet(nfileName,"rotY", o_pos[ 4 ]);
			dini_FloatSet(nfileName,"rotZ", o_pos[ 5 ]);
			dini_IntSet(nfileName, "modelidTXT", modelidTXT);
			dini_Set(nfileName, "txdname", txdname);
			dini_Set(nfileName, "texturename", texturename);
		}
		objectid = objectid++;
	}
	//Placement des cabanes
	for(new cabid = 0; cabid < 1000; cabid++)
	{
		new fileName[32], nfileName[32], Float:c_pos[ 6 ], proprio[MAX_PLAYER_NAME];
		format(fileName, sizeof(fileName), "objects/cabanes/%i.ini", cabid);
		if(dini_Exists(fileName))
		{
			c_pos[ 0 ] = dini_Float(fileName,"posX");
			c_pos[ 1 ] = dini_Float(fileName,"posY");
			c_pos[ 2 ] = dini_Float(fileName,"posZ");
			c_pos[ 3 ] = dini_Float(fileName,"rotX");
			c_pos[ 4 ] = dini_Float(fileName,"rotY");
			c_pos[ 5 ] = dini_Float(fileName,"rotZ");
			format(proprio, sizeof(proprio), "%s", dini_Get(fileName, "proprio"));
			dini_Remove(fileName);
			new ncabaneid = CreateObject(3417, c_pos[ 0 ], c_pos[ 1 ], c_pos[ 2 ], c_pos[ 3 ], c_pos[ 4 ], c_pos[ 5 ], 30000);
			format(nfileName, sizeof(nfileName), "objects/cabanes/%i.ini", ncabaneid);
			dini_Create(nfileName);
            dini_Set(nfileName, "proprio", dini_Get(fileName, "proprio"));
			dini_FloatSet(nfileName,"posX", c_pos[ 0 ]);
			dini_FloatSet(nfileName,"posY", c_pos[ 1 ]);
			dini_FloatSet(nfileName,"posZ", c_pos[ 2 ]);
			dini_FloatSet(nfileName,"rotX", c_pos[ 3 ]);
			dini_FloatSet(nfileName,"rotY", c_pos[ 4 ]);
			dini_FloatSet(nfileName,"rotZ", c_pos[ 5 ]);
		}
	}
	//Placement des petites échelles
	for(new cabid = 0; cabid < 1000; cabid++)
	{
		new fileName[32], nfileName[32], Float:c_pos[ 6 ], proprio[MAX_PLAYER_NAME];
		format(fileName, sizeof(fileName), "objects/pechelles/%i.ini", cabid);
		if(dini_Exists(fileName))
		{
			c_pos[ 0 ] = dini_Float(fileName,"posX");
			c_pos[ 1 ] = dini_Float(fileName,"posY");
			c_pos[ 2 ] = dini_Float(fileName,"posZ");
			c_pos[ 3 ] = dini_Float(fileName,"rotX");
			c_pos[ 4 ] = dini_Float(fileName,"rotY");
			c_pos[ 5 ] = dini_Float(fileName,"rotZ");
			format(proprio, sizeof(proprio), "%s", dini_Get(fileName, "proprio"));
			dini_Remove(fileName);
			new ncabaneid = CreateObject(1428, c_pos[ 0 ], c_pos[ 1 ], c_pos[ 2 ], c_pos[ 3 ], c_pos[ 4 ], c_pos[ 5 ], 30000);
			format(nfileName, sizeof(nfileName), "objects/pechelles/%i.ini", ncabaneid);
			dini_Create(nfileName);
            dini_Set(nfileName, "proprio", dini_Get(fileName, "proprio"));
			dini_FloatSet(nfileName,"posX", c_pos[ 0 ]);
			dini_FloatSet(nfileName,"posY", c_pos[ 1 ]);
			dini_FloatSet(nfileName,"posZ", c_pos[ 2 ]);
			dini_FloatSet(nfileName,"rotX", c_pos[ 3 ]);
			dini_FloatSet(nfileName,"rotY", c_pos[ 4 ]);
			dini_FloatSet(nfileName,"rotZ", c_pos[ 5 ]);
		}
	}
	//Placement des grandes échelles
	for(new cabid = 0; cabid < 1000; cabid++)
	{
		new fileName[32], nfileName[32], Float:c_pos[ 6 ], proprio[MAX_PLAYER_NAME];
		format(fileName, sizeof(fileName), "objects/gechelles/%i.ini", cabid);
		if(dini_Exists(fileName))
		{
			c_pos[ 0 ] = dini_Float(fileName,"posX");
			c_pos[ 1 ] = dini_Float(fileName,"posY");
			c_pos[ 2 ] = dini_Float(fileName,"posZ");
			c_pos[ 3 ] = dini_Float(fileName,"rotX");
			c_pos[ 4 ] = dini_Float(fileName,"rotY");
			c_pos[ 5 ] = dini_Float(fileName,"rotZ");
			format(proprio, sizeof(proprio), "%s", dini_Get(fileName, "proprio"));
			dini_Remove(fileName);
			new ncabaneid = CreateObject(1437, c_pos[ 0 ], c_pos[ 1 ], c_pos[ 2 ], c_pos[ 3 ], c_pos[ 4 ], c_pos[ 5 ], 30000);
			format(nfileName, sizeof(nfileName), "objects/gechelles/%i.ini", ncabaneid);
			dini_Create(nfileName);
            dini_Set(nfileName, "proprio", dini_Get(fileName, "proprio"));
			dini_FloatSet(nfileName,"posX", c_pos[ 0 ]);
			dini_FloatSet(nfileName,"posY", c_pos[ 1 ]);
			dini_FloatSet(nfileName,"posZ", c_pos[ 2 ]);
			dini_FloatSet(nfileName,"rotX", c_pos[ 3 ]);
			dini_FloatSet(nfileName,"rotY", c_pos[ 4 ]);
			dini_FloatSet(nfileName,"rotZ", c_pos[ 5 ]);
		}
	}
	//Placement des coffres
	for(new cabid = 0; cabid < 1000; cabid++)
	{
		new fileName[32], nfileName[32], Float:c_pos[ 6 ], proprio[MAX_PLAYER_NAME], slot1Name[32], slot2Name[32], slot3Name[32], slot4Name[32], slot5Name[32], slot1id[32], slot2id[32], slot3id[32], slot4id[32], slot5id[32], slot1Ammo[32], slot2Ammo[32], slot3Ammo[32], slot4Ammo[32], slot5Ammo[32];
		format(fileName, sizeof(fileName), "objects/coffres/%i.ini", cabid);
		if(dini_Exists(fileName))
		{
			c_pos[ 0 ] = dini_Float(fileName,"posX");
			c_pos[ 1 ] = dini_Float(fileName,"posY");
			c_pos[ 2 ] = dini_Float(fileName,"posZ");
			c_pos[ 3 ] = dini_Float(fileName,"rotX");
			c_pos[ 4 ] = dini_Float(fileName,"rotY");
			c_pos[ 5 ] = dini_Float(fileName,"rotZ");
			format(proprio, sizeof(proprio), "%s", dini_Get(fileName, "proprio"));
			format(slot1Name, sizeof(slot1Name), "%s", dini_Get(fileName, "slot1Name"));
			format(slot2Name, sizeof(slot2Name), "%s", dini_Get(fileName, "slot2Name"));
			format(slot3Name, sizeof(slot3Name), "%s", dini_Get(fileName, "slot3Name"));
			format(slot4Name, sizeof(slot4Name), "%s", dini_Get(fileName, "slot4Name"));
			format(slot5Name, sizeof(slot5Name), "%s", dini_Get(fileName, "slot5Name"));
			format(slot1id, sizeof(slot1id), "%s", dini_Get(fileName, "slot1id"));
			format(slot2id, sizeof(slot2id), "%s", dini_Get(fileName, "slot2id"));
			format(slot3id, sizeof(slot3id), "%s", dini_Get(fileName, "slot3id"));
			format(slot4id, sizeof(slot4id), "%s", dini_Get(fileName, "slot4id"));
			format(slot5id, sizeof(slot5id), "%s", dini_Get(fileName, "slot5id"));
			format(slot1Ammo, sizeof(slot1Ammo), "%s", dini_Get(fileName, "slot1Ammo"));
			format(slot2Ammo, sizeof(slot2Ammo), "%s", dini_Get(fileName, "slot2Ammo"));
			format(slot3Ammo, sizeof(slot3Ammo), "%s", dini_Get(fileName, "slot3Ammo"));
			format(slot4Ammo, sizeof(slot4Ammo), "%s", dini_Get(fileName, "slot4Ammo"));
			format(slot5Ammo, sizeof(slot5Ammo), "%s", dini_Get(fileName, "slot5Ammo"));
			dini_Remove(fileName);
			new ncabaneid = CreateObject(964, c_pos[ 0 ], c_pos[ 1 ], c_pos[ 2 ], c_pos[ 3 ], c_pos[ 4 ], c_pos[ 5 ], 3000);
			format(nfileName, sizeof(nfileName), "objects/coffres/%i.ini", ncabaneid);
			dini_Create(nfileName);
            dini_Set(nfileName, "proprio", proprio);
			dini_FloatSet(nfileName,"posX", c_pos[ 0 ]);
			dini_FloatSet(nfileName,"posY", c_pos[ 1 ]);
			dini_FloatSet(nfileName,"posZ", c_pos[ 2 ]);
			dini_FloatSet(nfileName,"rotX", c_pos[ 3 ]);
			dini_FloatSet(nfileName,"rotY", c_pos[ 4 ]);
			dini_FloatSet(nfileName,"rotZ", c_pos[ 5 ]);
			dini_Set(nfileName, "slot1Name", slot1Name);
			dini_Set(nfileName, "slot1id", slot1id);
			dini_Set(nfileName, "slot1Ammo", slot1Ammo);
			dini_Set(nfileName, "slot2Name", slot2Name);
			dini_Set(nfileName, "slot2id", slot2id);
			dini_Set(nfileName, "slot2Ammo", slot2Ammo);
			dini_Set(nfileName, "slot3Name", slot3Name);
			dini_Set(nfileName, "slot3id", slot3id);
			dini_Set(nfileName, "slot3Ammo", slot3Ammo);
			dini_Set(nfileName, "slot4Name", slot4Name);
			dini_Set(nfileName, "slot4id", slot4id);
			dini_Set(nfileName, "slot4Ammo", slot4Ammo);
			dini_Set(nfileName, "slot5Name", slot5Name);
			dini_Set(nfileName, "slot5id", slot5id);
			dini_Set(nfileName, "slot5Ammo", slot5Ammo);
		}
	}
	//Objets de l'éditor
    CreateObject(9689, -2681.42603, 1692.51917, 14.67767,   60.00000, 0.00000, -180.00000, 30000);
    CreateObject(3364, -2368.73413, 2374.86621, 3.62654,   11.00000, 0.00000, -76.00000, 30000);
    CreateObject(1358, -2409.09912, 2359.25586, 5.23777,   3.14159, 0.00000, 1.88390, 30000);
    CreateObject(1697, -2409.34668, 2379.97046, 7.71467,   -10.00000, 0.00000, 199.00000, 30000);
    CreateObject(1697, -2403.96509, 2382.01807, 7.71467,   -10.00000, 0.00000, 199.00000, 30000);
    CreateObject(1697, -2407.69165, 2372.26392, 6.74332,   -7.00000, 0.00000, 199.00000, 30000);
    CreateObject(1697, -2402.50220, 2374.49243, 6.60860,   -9.00000, 0.00000, 199.00000, 30000);
    CreateObject(1684, -2396.45752, 2391.22046, 8.97171,   0.00000, -2.00000, -19.00000, 30000);
    CreateObject(16003, -2239.52930, 2296.37769, 5.92660,   0.00000, 0.00000, 91.00000, 30000);
    CreateObject(17039, -2231.37939, 2299.53906, 4.01440,   0.00000, 0.00000, 90.00000, 30000);
    CreateObject(3279, -2283.88770, 2278.74194, 4.00072,   0.00000, 0.00000, 0.00000, 30000);
    CreateObject(16692, -2143.39893, 2678.33936, 7.79907,   0.00000, 0.00000, 0.00000, 30000);
    CreateObject(10985, -2235.32153, 2640.63281, 55.81401,   0.00000, 0.00000, 65.45998, 30000);
    CreateObject(10985, -2206.06934, 2640.98364, 56.15024,   0.00000, 0.00000, 0.00000, 30000);
    CreateObject(1282, -2736.14526, 2386.14478, 72.15575,   0.00000, 0.00000, 63.90006, 30000);
    CreateObject(1282, -2745.46362, 2385.71118, 72.38213,   0.00000, 0.00000, 123.84001, 30000);
    CreateObject(1282, -2744.34351, 2386.86475, 72.38704,   0.00000, 0.00000, -58.43998, 30000);
    CreateObject(1282, -2737.42676, 2386.82129, 72.21901,   0.00000, 0.00000, 64.74004, 30000);
    CreateObject(3594, -2691.10742, 1798.55908, 67.66904,   0.00000, 0.00000, 64.07999, 30000);
    CreateObject(10984, -2672.83398, 1798.10181, 67.80014,   0.00000, 0.00000, 47.22000, 30000);
    CreateObject(1463, -687.36127, 970.09045, 11.92412,   0.00000, 0.00000, 0.00000, 30000);
    CreateObject(14872, -694.60980, 971.14795, 11.68779,   0.00000, 0.00000, -180.35988, 30000);
    CreateObject(13435, -679.15503, 974.59430, 13.95110,   1.00000, -4.00000, 87.00000, 30000);
    CreateObject(1219, -687.49261, 970.21906, 11.35891,   0.00000, 0.00000, 0.00000, 30000);
    CreateObject(1438, -681.51813, 961.33759, 11.29327,   0.00000, 0.00000, -179.64005, 30000);
    CreateObject(1415, -681.28394, 970.40894, 11.30646,   0.00000, 0.00000, -51.72001, 30000);
    CreateObject(1616, -694.00464, 960.55237, 16.37781,   0.00000, 0.00000, 0.00000, 30000);
    CreateObject(12807, -794.61578, 864.42151, 15.61535,   0.00000, -3.00000, 286.67972, 30000);
    CreateObject(834, -743.80151, 840.82056, 16.30855,   0.00000, 0.00000, 0.00000, 30000);
    CreateObject(831, -758.80560, 876.57562, 12.14783,   0.00000, 0.00000, 0.00000, 30000);
    CreateObject(831, -788.50140, 850.26154, 12.95626,   9.66000, 0.90000, 89.33994, 30000);
    CreateObject(845, -784.13965, 827.31860, 13.44595,   -3.66000, 5.22000, 31.32000, 30000);
    CreateObject(12808, -780.80170, 800.95190, 17.42018,   -3.00000, -2.34000, -56.88003, 30000);
    CreateObject(879, -741.56659, 879.31805, 12.59186,   0.00000, 0.00000, 0.00000, 30000);
    CreateObject(2115, -689.04199, 960.85931, 11.16407,   0.00000, 0.00000, 2.94000, 30000);
    CreateObject(341, -688.63226, 960.78033, 12.21442,   -8.09999, 33.30000, 32.10001, 30000);
    //Intérieurs
    CreateObject(5107, -27.12352, -273.87442, 1002.46887,   0.00000, 0.00000, 0.00000);
	//Placement des pickup et 3DTL de biz
	for(new roomID = 0; roomID <= 200; roomID++)
    {
        for(new vwID; vwID <= 30; vwID++)
        {
            new ifileName[32];
        	format(ifileName, sizeof(ifileName), "houses/%i/%i.txt", roomID, vwID);
        	if(dini_Exists(ifileName))
        	{
        		new Float:b_pos[3], pickupmodelid, id3DTL1, id3DTL2, str3DTL1[48], str3DTL2[48], pickupid, type;
				b_pos[0] = dini_Float(ifileName, "posX");
				b_pos[1] = dini_Float(ifileName, "posY");
				b_pos[2] = dini_Float(ifileName, "posZ");
				type = dini_Int(ifileName, "type");
				if(type == 1 || type == 3)//Acheté
				{
					format(str3DTL1, sizeof(str3DTL1), "%s", dini_Get(ifileName, "nom"));
					format(str3DTL2, sizeof(str3DTL2), "Proprio : %s", dini_Get(ifileName, "proprio"));
				}
				else if(type == 2 || type == 4)//A vendre
				{
				    format(str3DTL1, sizeof(str3DTL1), "%s", dini_Get(ifileName, "nom"));
					format(str3DTL2, sizeof(str3DTL2), "Prix : %i $", dini_Int(ifileName, "montant"));
				}
				else if(type == 5)
				{
				    format(str3DTL1, sizeof(str3DTL1), "%s", dini_Get(ifileName, "nom"));
				}
				pickupmodelid = dini_Int(ifileName, "pickupmodelid");
				pickupid = CreatePickup(pickupmodelid, 1, b_pos[0], b_pos[1], b_pos[2], -1);
				id3DTL1 = Create3DTextLabel(str3DTL1, COLOR_WHITE, b_pos[0], b_pos[1], b_pos[2], 6.0, 0, -1);
				id3DTL2 = Create3DTextLabel(str3DTL2, COLOR_WHITE, b_pos[0], b_pos[1], b_pos[2]-0.06, 6.0, 0, -1);
				dini_IntSet(ifileName, "pickupid", pickupid);
				dini_IntSet(ifileName, "3DTL1id", id3DTL1);
				dini_IntSet(ifileName, "3DTL2id", id3DTL2);
			}
		}
	}
	//Placement des points de TP
	for(new tpnb; tpnb <= 75; tpnb++)
	{
		new tpfileName[32];
		format(tpfileName, sizeof(tpfileName), "tppoint/%i.ini", tpnb);
		if(dini_Exists(tpfileName))
		{
		    new Float:e_pos[3], eVirtual, TextID, pickupmodelid, pickupid;
		    e_pos[0] = dini_Float(tpfileName, "eposX");
		    e_pos[1] = dini_Float(tpfileName, "eposY");
		    e_pos[2] = dini_Float(tpfileName, "eposZ");
		    eVirtual = dini_Int(tpfileName, "eVirtual");
		    pickupmodelid = dini_Int(tpfileName, "pickupmodelid");
		    pickupid = CreatePickup(pickupmodelid, 1, e_pos[0], e_pos[1], e_pos[2], eVirtual);
			TextID = Create3DTextLabel("Appuie sur \"H\" pour entrer", COLOR_TURQUOISE, e_pos[0], e_pos[1], e_pos[2], 6.0, eVirtual, 1);
			dini_IntSet(tpfileName, "pickupid", pickupid);
			dini_IntSet(tpfileName, "TextID", TextID);
		}
	}
	//Placement des arbres
	SetTimer("s1Timer", 1000, true);
	SetTimer("s3Timer", 3000, true);
	SetTimer("s30Timer", 30000, true);
	for(new arbreid = 0; arbreid <= 1000; arbreid++)
	{
	    new arfileName[32], modelid, Float:ar_pos[6];
		format(arfileName, sizeof(arfileName), "arbres/%i.ini", arbreid);
		if(dini_Exists(arfileName))
		{
			modelid = dini_Int(arfileName, "modelid");
			ar_pos[ 0 ] = dini_Float(arfileName,"posX");
			ar_pos[ 1 ] = dini_Float(arfileName,"posY");
			ar_pos[ 2 ] = dini_Float(arfileName,"posZ");
			ar_pos[ 3 ] = dini_Float(arfileName,"rotX");
			ar_pos[ 4 ] = dini_Float(arfileName,"rotY");
			ar_pos[ 5 ] = dini_Float(arfileName,"rotZ");
			arbreid = CreateObject(modelid, ar_pos[0], ar_pos[1], ar_pos[2], ar_pos[3], ar_pos[4], ar_pos[5], 30000);
			dini_Remove(arfileName);
			format(arfileName, sizeof(arfileName), "arbres/%i.ini", arbreid);
			dini_Create(arfileName);
			dini_IntSet(arfileName, "modelid", modelid);
			dini_IntSet(arfileName, "coupe", 0);
			dini_FloatSet(arfileName, "posX", ar_pos[0]);
			dini_FloatSet(arfileName, "posY", ar_pos[1]);
			dini_FloatSet(arfileName, "posZ", ar_pos[2]);
			dini_FloatSet(arfileName, "rotX", ar_pos[3]);
			dini_FloatSet(arfileName, "rotY", ar_pos[4]);
			dini_FloatSet(arfileName, "rotZ", ar_pos[5]);
		}
	}
	//Spawn des véhicules
	for(new fileID = 0; fileID < 1000; fileID++)
	{
		new Float:v_pos[ 4 ], Float:vehHealth, fileName[32], pfileName[32], vfileName[32], proprio1[48], proprio2[48], proprio3[48], maxCar, curCar, modelid, color1, color2, vehicleid, vehiclenb[32], vehnb, moteur, phares, alarme, portes, capot, coffre, objective;
		format(fileName, sizeof(fileName), "vehicules/%i.ini", fileID);
	    if(dini_Exists(fileName))
		{
		    //On va chercher les différentes variables du véhicule
			v_pos[ 0 ] = dini_Float(fileName, "SpawnX");
			v_pos[ 1 ] = dini_Float(fileName, "SpawnY");
			v_pos[ 2 ] = dini_Float(fileName, "SpawnZ");
			v_pos[ 3 ] = dini_Float(fileName, "SpawnA");
			modelid = dini_Int(fileName, "modelid");
			color1 = dini_Int(fileName, "couleur1");
			color2 = dini_Int(fileName, "couleur2");
			vehnb = dini_Int(fileName, "vehiclenb");
			portes = dini_Int(fileName, "portes");
			vehHealth = dini_Float(fileName, "health");
			maxCar = dini_Int(fileName, "maxCar");
			curCar = dini_Int(fileName, "curCar");
			format(proprio1, sizeof(proprio1), "%s", dini_Get(fileName, "proprio1"));
			format(proprio2, sizeof(proprio2), "%s", dini_Get(fileName, "proprio2"));
			format(proprio3, sizeof(proprio3), "%s", dini_Get(fileName, "proprio3"));
			//Création du véhicule et capture de son ID
			vehicleid = CreateVehicle(modelid, v_pos[0], v_pos[1], v_pos[2], v_pos[3] , color1, color2, -1);
			SetVehicleHealth(vehicleid, vehHealth);
			//Initialisation des noms de fichiers
			format(pfileName, sizeof(pfileName), "players/%s.ini", dini_Get(fileName, "proprio1"));
			format(vfileName, sizeof(vfileName), "vehicules/%i.ini", vehicleid);
			format(vehiclenb, sizeof(vehiclenb), "vehicle%i", vehnb);
			//Assignation du nouvel ID dans le fichier du joueur
			dini_IntSet(pfileName, vehiclenb, vehicleid);
			dini_Remove(fileName);
			//Création du nouveau fichier
			dini_Create(vfileName);
			dini_IntSet(vfileName, "modelid", modelid);
			dini_IntSet(vfileName, "couleur1", color1);
			dini_IntSet(vfileName, "couleur2", color2);
			dini_IntSet(vfileName, "maxCar", maxCar);
			dini_IntSet(vfileName, "curCar", curCar);
			dini_Set(vfileName, "proprio1", proprio1);
			dini_Set(vfileName, "proprio2", proprio2);
			dini_Set(vfileName, "proprio3", proprio3);
			dini_IntSet(vfileName, "vehiclenb", vehnb);
			dini_FloatSet(vfileName, "SpawnX", v_pos[ 0 ]);
			dini_FloatSet(vfileName, "SpawnY", v_pos[ 1 ]);
			dini_FloatSet(vfileName, "SpawnZ", v_pos[ 2 ]);
			dini_FloatSet(vfileName, "SpawnA", v_pos[ 3 ]);
            SetVehicleParamsEx(vehicleid, moteur, phares, alarme, portes, capot, coffre, objective);
		}
	}
	return 1;
}

public OnGameModeExit()
{
	//Paramètres du véhicule
	for(new vehicleid = 0; vehicleid < 1000; vehicleid++)
	{
	    if(IsValidVehicle(vehicleid))
	    {
	    	new Float:v_pos[4], Float:vehHealth, fileName[32], moteur, phares, alarme, portes, capot, coffre, objective;
	    	format(fileName, sizeof(fileName), "vehicules/%i.ini", vehicleid);
	    	if(!dini_Exists(fileName)) continue;
	    	GetVehicleParamsEx(vehicleid, moteur, phares, alarme, portes, capot, coffre, objective);
			GetVehiclePos(vehicleid, v_pos[0], v_pos[1], v_pos[2]);
			GetVehicleZAngle(vehicleid, v_pos[3]);
			GetVehicleHealth(vehicleid, vehHealth);
			dini_FloatSet(fileName, "SpawnX", v_pos[0]);
			dini_FloatSet(fileName, "SpawnY", v_pos[1]);
			dini_FloatSet(fileName, "SpawnZ", v_pos[2]);
			dini_FloatSet(fileName, "SpawnA", v_pos[3]);
			dini_FloatSet(fileName, "health", vehHealth);
			dini_IntSet(fileName, "portes", portes);
		}
	}
	//Argent et stats des joueurs
	for(new playerid = 0; playerid <= MAX_PLAYERS; playerid++)
	{
	    new pName[32], pfileName[32];
		GetPlayerName(playerid, pName, sizeof(pName));
	    format (pfileName, sizeof(pfileName), "players/%s.ini", pName);
		new iArgent = GetPlayerMoney(playerid);
		dini_IntSet(pfileName, "iArgent", iArgent);
	}
	//Met tous les véhicules éteint dans le allume.ini
	for(new nb = 0; nb <=50; nb++)
	{
		new strnb[3];
		format(strnb, sizeof(strnb), "%i", nb);
		dini_IntSet("vehicules/allume.ini", strnb, 0);
		dini_IntSet("vehicules/demarre.ini", strnb, 0);
	}
	for(new frequence = 0; frequence <= 10000; frequence++)
	{
	    new rfileName[48], strRadio[48];
	    format(rfileName, sizeof(rfileName), "radio/%i.ini", frequence);
	    if(dini_Exists(rfileName))
	    {
	    	for(new radioNB = 0; radioNB <= 50; radioNB++)
	    	{
	       		format(strRadio, sizeof(strRadio), "%i", radioNB);
	        	dini_IntSet(rfileName, strRadio, 999);
	    	}
		}
	}
	return 1;
}
public OnPlayerSpawn(playerid)
{
    TogglePlayerSpectating(playerid, 0);
	SetPlayerHealth(playerid, 100.0);
    //Chargement des satistiques
    new pName[MAX_PLAYER_NAME], pfileName[32], Float:p_pos[ 3 ], virtualWorld, team;
	GetPlayerName(playerid, pName, sizeof(pName));
	format (pfileName, sizeof(pfileName), "players/%s.ini", pName);
	p_pos[0] = dini_Float(pfileName, "SpawnX");
	p_pos[1] = dini_Float(pfileName, "SpawnY");
 	p_pos[2] = dini_Float(pfileName, "SpawnZ");
	new interior = dini_Int(pfileName, "SpawnI");
	virtualWorld = dini_Int(pfileName, "SpawnVW");
 	new skinid = dini_Int(pfileName, "Skin");
	team = dini_Int(pfileName, "team");
	SetPlayerTeam(playerid, team);
 	dini_IntSet(pfileName, "Mort", 0);
 	SetPlayerInterior(playerid, interior);
 	SetPlayerVirtualWorld(playerid, virtualWorld);
 	SetPlayerSkin(playerid, skinid);
 	SetPlayerPos(playerid, p_pos[ 0 ], p_pos[ 1 ], p_pos[ 2 ]+0.5);
	TogglePlayerControllable(playerid, 1);
 	ApplyAnimation(playerid, "BASEBALL", "Bat_M", 1.0, 0, 0, 0, 0, 250, 1);
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	DisablePlayerCheckpoint(playerid);
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	if(pickupid == pickup_concess) GameTextForPlayer(playerid, "/veh pour ouvrir le menu d'achat", 2, 1);
	else if(pickupid == pickup_repair) GameTextForPlayer(playerid, "/rep pour reparer ton vehicule", 2, 1);
	else if(pickupid == pickup_menuiserie) GameTextForPlayer(playerid, "/menuiserie pour afficher le menu d'achat", 2, 1);
	else if(pickupid == pickup_mineur) GameTextForPlayer(playerid, "/equiper pour pouvoir miner", 2, 1);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	new pName[MAX_PLAYER_NAME], pfileName[28];
	GetPlayerName(playerid, pName, sizeof(pName));
	format (pfileName, sizeof(pfileName), "players/%s.ini", pName);
	new iArgent = dini_Int(pfileName, "iArgent");
	dini_IntSet(pfileName, "iArgent", iArgent);
	//ResetPlayerMoney(playerid);
	if(killerid != INVALID_PLAYER_ID)
	{
		new string[128], kName[MAX_PLAYER_NAME];
		GetPlayerName(killerid, kName, sizeof(kName));
    	format(string, sizeof(string), "%s a été tué par %s.", pName, kName);
    	SendClientMessageToAll(0xAC58FA00, string);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{

    if(IsPlayerNPC(playerid) == 1) return SpawnPlayer(playerid);
	//Messages d'accueil et nouveautés
	SendClientMessage(playerid, COLOR_YELLOW, "Bienveneue sur After The Fall Roleplay. Le serveur RolePlay post-apocalyptique de référence.");
	SendClientMessage(playerid, COLOR_TURQUOISE, "La barre de radiations est arrivée.");
	//Vérification du nom
	new pName[MAX_PLAYER_NAME], pfileName[28], string[64], loginTimerID, registerTimerID;
	GetPlayerName(playerid, pName, sizeof(pName));
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	//Message à tout le monde
	format(string, sizeof(string),"%s vient de se connecter", pName);
    SendClientMessageToAll(COLOR_ORANGE, string);
	if(strfind(pName, "_") == -1)
	{
	    new kickTimerID;
		SendClientMessage(playerid, COLOR_RED, "Ton pseudo doit être sous la forme Prénom_Nom");
		kickTimerID = SetTimerEx("DelayKick", 500, false, "ii", playerid, kickTimerID);
		return 1;
	}
	if(dini_Exists(pfileName))
	{
	    GameTextForPlayer(playerid, "Chargement en cours", 4000, 6);
        loginTimerID = SetTimerEx("DelayLogin", 4000, false, "ii", playerid, loginTimerID);
	}
	else
	{
	    GameTextForPlayer(playerid, "Chargement en cours", 4000, 6);
        registerTimerID = SetTimerEx("DelayRegister", 4000, false, "ii", playerid, registerTimerID);
	}
    SetPlayerColor(playerid, COLOR_WHITE);
    TogglePlayerSpectating(playerid, 1);
    //Enlève les feux
    RemoveBuildingForPlayer(playerid, 1262, 0.0, 0.0, 0.0, 4000.0);
    RemoveBuildingForPlayer(playerid, 1263, 0.0, 0.0, 0.0, 4000.0);
    RemoveBuildingForPlayer(playerid, 1283, 0.0, 0.0, 0.0, 4000.0);
    RemoveBuildingForPlayer(playerid, 1284, 0.0, 0.0, 0.0, 4000.0);
    RemoveBuildingForPlayer(playerid, 1315, 0.0, 0.0, 0.0, 4000.0);
    RemoveBuildingForPlayer(playerid, 1350, 0.0, 0.0, 0.0, 4000.0);
    RemoveBuildingForPlayer(playerid, 1351, 0.0, 0.0, 0.0, 4000.0);
    RemoveBuildingForPlayer(playerid, 1352, 0.0, 0.0, 0.0, 4000.0);
    RemoveBuildingForPlayer(playerid, 3516, 0.0, 0.0, 0.0, 4000.0);
    //Suppression des arbres naturels dans la zone Bucheron
    RemoveBuildingForPlayer(playerid, 669, -753.3516, 921.1563, 10.9297, 200);
    RemoveBuildingForPlayer(playerid, 691, -753.3516, 921.1563, 10.9297, 200);
    RemoveBuildingForPlayer(playerid, 700, -753.3516, 921.1563, 10.9297, 200);
    RemoveBuildingForPlayer(playerid, 705, -753.3516, 921.1563, 10.9297, 200);
    RemoveBuildingForPlayer(playerid, 708, -753.3516, 921.1563, 10.9297, 200);
    RemoveBuildingForPlayer(playerid, 713, -753.3516, 921.1563, 10.9297, 200);
    //Met tes objets à supprimer ici
    RemoveBuildingForPlayer(playerid, 1282, -2401.9219, 2352.6953, 4.6563, 0.25);
    RemoveBuildingForPlayer(playerid, 1282, -2399.6406, 2353.2188, 4.6563, 0.25);
    RemoveBuildingForPlayer(playerid, 1358, -2401.6250, 2357.5313, 5.1250, 0.25);
    RemoveBuildingForPlayer(playerid, 9687, -2681.4922, 1684.4609, 120.4531, 0.25);
    RemoveBuildingForPlayer(playerid, 9689, -2681.4922, 1684.4609, 120.4531, 0.25);
    RemoveBuildingForPlayer(playerid, 1290, -2681.5859, 1609.8828, 70.0938, 0.25);
    RemoveBuildingForPlayer(playerid, 1290, -2681.5859, 1735.3125, 73.3438, 0.25);
    RemoveBuildingForPlayer(playerid, 1290, -2681.5859, 1672.6016, 72.3047, 0.25);
    RemoveBuildingForPlayer(playerid, 691, -773.9922, 813.5938, 11.3750, 0.25);
    RemoveBuildingForPlayer(playerid, 705, -756.3516, 871.1563, 10.9297, 0.25);
    //Chargement des stats
	if(dini_Int(pfileName, "ban") == 1)
	{
	    new kickTimerID;
		SendClientMessage(playerid, COLOR_RED, dini_Get(pfileName, "banRaison"));
		kickTimerID = SetTimerEx("DelayKick", 500, false, "ii", playerid, kickTimerID);
		return 1;
	}
	//Creation des TextDraw
	compteurKMH = CreatePlayerTextDraw(playerid, 320, 380, "0");
	heureTextDraw = CreatePlayerTextDraw(playerid, 320, 420, "0");
	degatTextDraw = CreatePlayerTextDraw(playerid, 420, 420, "0");
	carburantTextDraw = CreatePlayerTextDraw(playerid, 220, 420, "0");
	demarreTD = CreatePlayerTextDraw(playerid, 200, 85, "~y~Demarrage...");
	//KM/H
	PlayerTextDrawTextSize(playerid, compteurKMH, 2.0, 3.6);
	PlayerTextDrawFont(playerid, compteurKMH, 2);
	PlayerTextDrawAlignment(playerid, compteurKMH, 2);
	//Heure
	PlayerTextDrawTextSize(playerid, heureTextDraw, 2.0, 3.6);
	PlayerTextDrawFont(playerid, heureTextDraw, 2);
	PlayerTextDrawAlignment(playerid, heureTextDraw, 2);
	//Degats
	PlayerTextDrawTextSize(playerid, degatTextDraw, 2.0, 3.6);
	PlayerTextDrawFont(playerid, degatTextDraw, 2);
	PlayerTextDrawAlignment(playerid, degatTextDraw, 2);
	//Carburant
	PlayerTextDrawTextSize(playerid, carburantTextDraw, 2.0, 3.6);
	PlayerTextDrawFont(playerid, carburantTextDraw, 2);
	PlayerTextDrawAlignment(playerid, carburantTextDraw, 2);
	//Démarrer
	PlayerTextDrawFont(playerid, demarreTD, 2);
	PlayerTextDrawLetterSize(playerid, demarreTD, 0.35, 1.0);
	//Radiations
	textRadTD = CreatePlayerTextDraw(playerid, 548.5, 23, "RADIATION");
	PlayerTextDrawLetterSize(playerid, textRadTD, 0.3, 0.7);
	PlayerTextDrawSetShadow(playerid, textRadTD, 0);
	PlayerTextDrawColor(playerid, textRadTD, COLOR_RADIATION);
	PlayerTextDrawShow(playerid, textRadTD);

	fondRadTD = CreatePlayerTextDraw(playerid, 546, 33.5, "_");
	PlayerTextDrawUseBox(playerid, fondRadTD, 1);
	PlayerTextDrawFont(playerid, fondRadTD, TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawBackgroundColor(playerid, fondRadTD, COLOR_BLACK);
	PlayerTextDrawTextSize(playerid, fondRadTD, 61.0, 10.0);
	PlayerTextDrawAlignment(playerid, fondRadTD, 1);
	PlayerTextDrawSetPreviewModel(playerid, fondRadTD, 1489);
	PlayerTextDrawShow(playerid, fondRadTD);
	
	fond2RadTD = CreatePlayerTextDraw(playerid, 548.5, 36, "_");
	PlayerTextDrawFont(playerid, fond2RadTD, TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawBackgroundColor(playerid, fond2RadTD, COLOR_RADIATION2);
	PlayerTextDrawTextSize(playerid, fond2RadTD, 56, 5.5);
	PlayerTextDrawAlignment(playerid, fond2RadTD, 1);
	PlayerTextDrawSetPreviewModel(playerid, fond2RadTD, 1489);
	PlayerTextDrawShow(playerid, fond2RadTD);
	
	new radLevel, Float:radSize;
	radLevel = dini_Int(pfileName, "radlevel");
	radSize = radLevel * 56 / 100;
	if(radLevel == 0) radSize = 0.1;
	barRadTD = CreatePlayerTextDraw(playerid, 548.5, 36, "_");
	PlayerTextDrawFont(playerid, barRadTD, TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawBackgroundColor(playerid, barRadTD, COLOR_RADIATION);
	PlayerTextDrawTextSize(playerid, barRadTD, radSize, 5.5);
	PlayerTextDrawAlignment(playerid, barRadTD, 1);
	PlayerTextDrawSetPreviewModel(playerid, barRadTD, 1489);
	PlayerTextDrawShow(playerid, barRadTD);

	//Initialisation de la radio
	new freq, strRadio[48], rfileName[48], team;
	team = dini_Int(pfileName, "team");
	SetPlayerTeam(playerid, team);
	freq = dini_Int(pfileName, "frequence");
	format(rfileName, sizeof(rfileName), "radio/%i.ini", freq);
	for(new radionb = 0; radionb <= 50; radionb++)
	{
	    format(strRadio, sizeof(strRadio), "%i", radionb);
	    if(dini_Int(rfileName, strRadio) == 999)
	    {
	        dini_IntSet(rfileName, strRadio, playerid);
	        return 1;
	    }
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	new pName[MAX_PLAYER_NAME], pfileName[48], string[39 + MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, sizeof(pName));
	if(IsPlayerNPC(playerid)) return 1;
	if (reason == 0)
	{
		format(string, sizeof(string),"%s vient de se déconnecter(Crash/Timed Out)", pName);
	}
	if (reason == 1)
	{
        format(string, sizeof(string),"%s vient de se déconnecter", pName);
	}
	if (reason == 2)
	{
		format(string, sizeof(string),"%s vient de se déconnecter(Kick/Ban)", pName);
	}
	SendClientMessageToAll(COLOR_ORANGE, string);
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	new iArgent = GetPlayerMoney(playerid), rfileName[48], freq, strRadio[48], team;
	dini_IntSet(pfileName, "iArgent", iArgent);
	//Team
	team = GetPlayerTeam(playerid);
	dini_IntSet(pfileName, "team", team);
	//Barrage
	if(GetPlayerTeam(playerid) == 5)
	{
	    new strplayerBarid[8];
	    for(new playerBarid; playerBarid <= 15; playerBarid++)
	    {
	        format(strplayerBarid, sizeof(strplayerBarid), "%i", playerBarid);
	        if(dini_Int("barrage.ini", strplayerBarid) == playerid)
	        {
	            dini_IntSet("barrage.ini", strplayerBarid, 999);
	        }
	    }
 	}
	//Radio
	freq = dini_Int(pfileName, "frequence");
	format(rfileName, sizeof(rfileName), "radio/%i.ini", freq);
	for(new radionb = 0; radionb <= 50; radionb++)
	{
	    format(strRadio, sizeof(strRadio), "%i", radionb);
	    if(dini_Int(rfileName, strRadio) == playerid)
	    {
	        dini_IntSet(rfileName, strRadio, 999);
	        return 1;
	    }
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
	new pName[24], str[128], strBubble[128], pfileName[64];
	GetPlayerName(playerid, pName, 24);
    format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	new mort = dini_Int(pfileName, "Mort");
	if(mort == 1) return SendClientMessage(playerid, COLOR_RED, "Tu es inconscient.");
    format(str, sizeof(str), "%s dit: %s", pName, text);
    ProxDetector(30.0, playerid, str, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4, COLOR_FADE5);
    format(strBubble, sizeof(strBubble), "%s", text);
	SetPlayerChatBubble(playerid, strBubble, COLOR_WHITE, 30, 3000);
    return 0;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
	    new vehicleid, moteur, phares, alarme, portes, capot, coffre, objective, vfileName[32];
		vehicleid = GetPlayerVehicleID(playerid);
		GetVehicleParamsEx(vehicleid, moteur, phares, alarme, portes, capot, coffre, objective);
		format(vfileName, sizeof(vfileName), "vehicules/%i.ini", vehicleid);
		new curCar = dini_Int(vfileName, "curCar");
		//Allumer le moteur
		if (newkeys & KEY_YES)
		{
		    if (GetPlayerVehicleSeat(playerid) == 0)
		    {
				if(moteur == 1)
				{
					SetVehicleParamsEx(vehicleid, 0, phares, alarme, portes, capot, coffre, objective);
					new vehiclenb[3];
 	    			for(new vehnb = 1; vehnb <= 50; vehnb++)
 	    			{
 	        			format(vehiclenb, sizeof(vehiclenb), "%i", vehnb);
						new vehid = dini_Int("vehicules/allume.ini", vehiclenb);
						if(vehid == vehicleid)
						{
			    			dini_IntSet("vehicules/allume.ini", vehiclenb, 0);
			    			goto finepkey;
						}
					}
					finepkey:
					PlayerTextDrawHide(playerid, degatTextDraw);
					PlayerTextDrawHide(playerid, carburantTextDraw);
					PlayerTextDrawHide(playerid, heureTextDraw);
					PlayerTextDrawHide(playerid, compteurKMH);
					SendClientMessage(playerid, COLOR_GREEN, "Ton véhicule est éteint.");
				}
				else if(moteur != 1)
				{
				    if(curCar < 1) return SendClientMessage(playerid, COLOR_RED, "Ton véhicule est en panne d'essence");
		    		for(new vehnombre = 0; vehnombre <= 50; vehnombre++)
		    		{
						new vehnb, strvehnb[16];
						format(strvehnb, sizeof(strvehnb), "%i", vehnombre);
						vehnb = dini_Int("vehicules/demarre.ini", strvehnb);
						if(vehnb == vehicleid) return 1;
						if(vehnb == 0)
						{
						    dini_IntSet("vehicules/demarre.ini", strvehnb, vehicleid);
						    PlayerTextDrawShow(playerid, demarreTD);
						    goto findemarre;
						}
		    		}
		    		findemarre:
                    new vehiclenb[3];
 	    			for(new vehnb = 1; vehnb <= 50; vehnb++)
 	    			{
 	        			format(vehiclenb, sizeof(vehiclenb), "%i", vehnb);
						new vehid = dini_Int("vehicules/allume.ini", vehiclenb);
						if(vehid == 0)
						{
			   				dini_IntSet("vehicules/allume.ini", vehiclenb, vehicleid);
			   				goto finapkey;
						}
					}
					finapkey:
					new carString[32], maxCar;
 					maxCar = dini_Int(vfileName, "maxCar");
 					format(carString, sizeof(carString), "%i/%i", curCar, maxCar);
 					PlayerTextDrawSetString(playerid, carburantTextDraw, carString);
				}
			}
		}
		//Allumer les phares
		else if (newkeys & KEY_SUBMISSION)
		{
		    if (GetPlayerVehicleSeat(playerid) == 0 || IsPlayerAdmin(playerid) == 1)
		    {
				if(phares == 1)
				{
  					SetVehicleParamsEx(vehicleid, moteur, 0, alarme, portes, capot, coffre, objective);
				}
				else
				{
			   		SetVehicleParamsEx(vehicleid, moteur, 1, alarme, portes, capot, coffre, objective);
				}
			}
  		}
	}
	//Lock
	if (newkeys & KEY_NO)
	{

	    if(IsPlayerInAnyVehicle(playerid))
	    {
	        new vehicleid, moteur, phares, alarme, portes, capot, coffre, objective;
    		vehicleid = GetPlayerVehicleID(playerid);
			GetVehicleParamsEx(vehicleid, moteur, phares, alarme, portes, capot, coffre, objective);
			if(portes == 1)
			{
				SetVehicleParamsEx(vehicleid, moteur, phares, alarme, 0, capot, coffre, objective);
				GameTextForPlayer(playerid, "~w~Portes ~g~ouvertes", 1500, 6);
			}
			else
			{
				SetVehicleParamsEx(vehicleid, moteur, phares, alarme, 1, capot, coffre, objective);
				GameTextForPlayer(playerid, "~w~Portes ~r~fermees", 1500, 6);
			}
		}
		else
		{
      		
		    for(new vehnb = 0; vehnb <= 10; vehnb++)
			{
				new vehid, pName[MAX_PLAYER_NAME], pfileName[48], vehiclenb[32], Float:v_pos[3];
				GetPlayerName(playerid, pName, sizeof(pName));
				format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
				format(vehiclenb, sizeof(vehiclenb), "vehicle%i", vehnb);
				vehid = dini_Int(pfileName, vehiclenb);
				GetVehiclePos(vehid, v_pos[0], v_pos[1], v_pos[2]);
				if(IsPlayerInRangeOfPoint(playerid, 3.5, v_pos[0], v_pos[1], v_pos[2]) == 1)
				{
					new moteur, phares, alarme, portes, capot, coffre, objective;
					GetVehicleParamsEx(vehid, moteur, phares, alarme, portes, capot, coffre, objective);
				    if(portes == 1)
					{
						SetVehicleParamsEx(vehid, moteur, phares, alarme, 0, capot, coffre, objective);
						GameTextForPlayer(playerid, "~w~Portes ~g~ouvertes", 1500, 6);
					}
					else
					{
						SetVehicleParamsEx(vehid, moteur, phares, alarme, 1, capot, coffre, objective);
						GameTextForPlayer(playerid, "~w~Portes ~r~fermees", 1500, 6);
					}
					break;
				}
			}
		}
	}
	//Entrer/Sortir des intérieurs
	if (newkeys & KEY_SECONDARY_ATTACK)
	{
	    new virtualworld;
		virtualworld = GetPlayerVirtualWorld(playerid);
		if(virtualworld == 0)
		{
		    new ifileName[32], cfgfileName[32];
    		for(new roomID; roomID <= 200; roomID++)
    		{
        		for(new vwID; vwID <= 30; vwID++)
        		{
        			format(ifileName, sizeof(ifileName), "houses/%i/%i.txt", roomID, vwID);
        			new Float:b_pos[3];
					b_pos[0] = dini_Float(ifileName, "posX");
					b_pos[1] = dini_Float(ifileName, "posY");
					b_pos[2] = dini_Float(ifileName, "posZ");
					if(IsPlayerInRangeOfPoint(playerid, 1.0, b_pos[0], b_pos[1], b_pos[2]) && dini_Exists(ifileName))
					{
			    		format(cfgfileName, sizeof(cfgfileName), "houses/%i/cfg.txt", roomID);
			    		new bInterior = dini_Int(cfgfileName, "interior"), pfileName[32], pName[MAX_PLAYER_NAME], Float:i_pos[3];
			    		i_pos[0] = dini_Float(cfgfileName, "posX");
			    		i_pos[1] = dini_Float(cfgfileName, "posY");
			    		i_pos[2] = dini_Float(cfgfileName, "posZ");
			    		SetPlayerInterior(playerid, bInterior);
			    		SetPlayerVirtualWorld(playerid, vwID);
			    		SetPlayerPos(playerid, i_pos[0], i_pos[1], i_pos[2]);
						GetPlayerName(playerid, pName, sizeof(pName));
						format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
						dini_IntSet(pfileName, "roomID", roomID);
						return 1;
					}
				}
			}
		}
		else
		{
		    new pName[MAX_PLAYER_NAME], pfileName[48], ifileName[48], cfgfileName[32], Float:e_pos[3], Float:b_pos[3];
		    GetPlayerName(playerid, pName, sizeof(pName));
			format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
			new roomID = dini_Int(pfileName, "roomID");
			format(ifileName, sizeof(ifileName), "houses/%i/%i.txt", roomID, virtualworld);
			format(cfgfileName, sizeof(cfgfileName), "houses/%i/cfg.txt", roomID);
			e_pos[0] = dini_Float(cfgfileName, "posX");
			e_pos[1] = dini_Float(cfgfileName, "posY");
			e_pos[2] = dini_Float(cfgfileName, "posZ");
			if(!IsPlayerInRangeOfPoint(playerid, 1.0, e_pos[0], e_pos[1], e_pos[2])) return SetPlayerCheckpoint(playerid, e_pos[0], e_pos[1], e_pos[2], 1.0);
			b_pos[0] = dini_Float(ifileName, "posX");
			b_pos[1] = dini_Float(ifileName, "posY");
			b_pos[2] = dini_Float(ifileName, "posZ");
			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);
			SetPlayerPos(playerid, b_pos[0], b_pos[1], b_pos[2]);
		}
	}
	//Entrer dans un point de TP
	if (newkeys & KEY_CTRL_BACK)
	{
		new tpfileName[32];
		for(new tpnb = 1; tpnb <= 75; tpnb++)
		{
		    format(tpfileName, sizeof(tpfileName), "tppoint/%i.ini", tpnb);
		    if(dini_Exists(tpfileName))
		    {
		        new Float:e_pos[3];
		        e_pos[0] = dini_Float(tpfileName, "eposX");
		        e_pos[1] = dini_Float(tpfileName, "eposY");
		        e_pos[2] = dini_Float(tpfileName, "eposZ");
		        if(IsPlayerInRangeOfPoint(playerid, 1.0, e_pos[0], e_pos[1], e_pos[2]))
		        {
					new Float:d_pos[3], dVirtual, dInterior;
					d_pos[0] = dini_Float(tpfileName, "dposX");
		        	d_pos[1] = dini_Float(tpfileName, "dposY");
		        	d_pos[2] = dini_Float(tpfileName, "dposZ");
		        	dInterior = dini_Int(tpfileName, "dInterior");
		        	dVirtual = dini_Int(tpfileName, "dVirtual");
		        	if(IsPlayerInAnyVehicle(playerid) == 1)
		            {
		                new vehicleid;
		                vehicleid = GetPlayerVehicleID(playerid);
		                SetVehiclePos(vehicleid, d_pos[0], d_pos[1], d_pos[2]);
						LinkVehicleToInterior(vehicleid, dInterior);
						SetVehicleVirtualWorld(vehicleid, dVirtual);
						PutPlayerInVehicle(playerid, vehicleid, 0);
		        		SetPlayerInterior(playerid, dInterior);
		        		SetPlayerVirtualWorld(playerid, dVirtual);
						return 1;
		            }
		        	SetPlayerInterior(playerid, dInterior);
		        	SetPlayerVirtualWorld(playerid, dVirtual);
		        	SetPlayerPos(playerid, d_pos[0], d_pos[1], d_pos[2]);
		        }
		    }
		}
	}
	//Arrêter l'animation
	if (newkeys & KEY_SPRINT)
	{
		new pName[MAX_PLAYER_NAME], pfileName[48], animation;
		GetPlayerName(playerid, pName, sizeof(pName));
		format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
		animation = dini_Int(pfileName, "animation");
		if(animation == 1)
		{
	    	ClearAnimations(playerid);
	    	dini_IntSet(pfileName, "animation", 0);
		}
	}
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
 	new vehiclenb[32], vfileName[32], pfileName[32], vehnb;
	format(vfileName, sizeof(vfileName), "vehicules/%i.ini", vehicleid);
   	format(pfileName, sizeof(pfileName), "players/%s.ini", dini_Get(vfileName, "proprio"));
	vehnb = dini_Int(vfileName, "vehiclenb");
	format(vehiclenb, sizeof(vehiclenb), "vehicle%i", vehnb);
	dini_IntSet(pfileName, vehiclenb, 0);
	dini_Remove(vfileName);
	for(new vehnomb = 1; vehnomb <= 50; vehnomb++)
	{
		format(vehiclenb, sizeof(vehiclenb), "%i", vehnomb);
		new vehid = dini_Int("vehicules/allume.ini", vehiclenb);
		if(vehid == vehicleid) dini_IntSet("vehicules/allume.ini", vehiclenb, 0);
	}
	PlayerTextDrawHide(killerid, degatTextDraw);
	PlayerTextDrawHide(killerid, carburantTextDraw);
	PlayerTextDrawHide(killerid, heureTextDraw);
	PlayerTextDrawHide(killerid, compteurKMH);
	DestroyVehicle(vehicleid);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == 2)
	{
		SendClientMessage(playerid, COLOR_YELLOW, "Appuie sur \"Y\" pour démarrer/arrêter le véhicule");
	}
	else if(oldstate == 2)
 	{
        PlayerTextDrawHide(playerid, degatTextDraw);
		PlayerTextDrawHide(playerid, carburantTextDraw);
		PlayerTextDrawHide(playerid, heureTextDraw);
		PlayerTextDrawHide(playerid, compteurKMH);
		PlayerTextDrawHide(playerid, demarreTD);
 	}
	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{
	new playerMessage[64], damagedMessage[64], victime[24];
	GetPlayerName(damagedid, victime, sizeof (victime));
	new Float:health, Float:damage, Float:gilet;
 	if(damagedid != INVALID_PLAYER_ID)
	{
	   //Colt 8
		if (weaponid == 22)
		{
			damage = 30;
		}
		//Silencieux 13
		else if (weaponid == 23)
		{
			damage = 35;
		}
		//Deagle 23
		else if (weaponid == 24)
		{
			damage = 60;
		}
		//Rifle 24
		else if (weaponid == 33)
		{
			damage = 46;
		}
		//Sniper 41
		else if (weaponid == 34)
		{
			damage = 95;
		}
		//ak47 9
		else if (weaponid == 30)
		{
			damage = 30;
		}
		//m4 9
		else if (weaponid == 31)
		{
			damage = 26;
		}
		//Tec-9 6
		else if (weaponid == 32)
		{
			damage = 15;
		}
		//UZI 6
		else if (weaponid == 28)
		{
			damage = 14;
		}
		//Shotgun 49
		else if (weaponid == 25)
		{
			damage = 60;
		}
		//Shawnoff
		else if (weaponid == 26)
		{
			damage = 18;
		}
		//Mp5 8
		else if (weaponid == 29)
		{
			damage = 9;
		}
		//RPG
		else if (weaponid == 35)
		{
			damage = 50;
		}
		//C4
		else if (weaponid == 39)
		{
			damage = 50;
		}
		//SprayCan
		else if (weaponid == 41)
		{
			damage = 5;
		}
		//Fire Extinguisher
		else if (weaponid == 42)
		{
			damage = 1;
		}
		//Brass Knuckles
		else if (weaponid == 1)
		{
			damage = 4;
		}
		//Pool Cue Billard
		else if (weaponid == 7)
		{
			damage = 8;
		}
		//Katana
		else if (weaponid == 8)
		{
			damage = 20;
		}
		//Baseball Bat
		else if (weaponid == 5)
		{
			damage = 10;
		}
		//Shovel pelle
		else if (weaponid == 6)
		{
			damage = 8;
		}
		//Chainsaw
		else if (weaponid == 9)
		{
			damage = 0;
		}
		//Knife
		else if (weaponid == 4)
		{
			damage = 15;
		}
		//NughtStick matraque
		else if (weaponid == 3)
		{
			damage = 9;
		}
		//Fist Poing
		else if (weaponid == 0)
		{
			damage = 2;
		}
		else
		{
		    damage = amount;
		}
		//Dégâts
		new pfileName[32], pName[MAX_PLAYER_NAME], status;
		GetPlayerHealth(damagedid, health);
		GetPlayerArmour(damagedid, gilet);
		GetPlayerName(damagedid, pName, sizeof(pName));
		format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
		status = dini_Int(pfileName, "Mort");
		if (status == 1) return 1;
		if(health<=damage && gilet<=0 && bodypart==3)
		{
			RemovePlayerFromVehicle(damagedid);
		    SetPlayerHealth(damagedid, 0.1);
			ApplyAnimation(damagedid, "ped", "KO_shot_stom", 4.1, 0, 0, 0, 1, 0, 1);
			dini_IntSet(pfileName, "Mort", 1);
			SendClientMessage(damagedid, COLOR_RED, "Tu es mort. Utilise \"/mourir\" pour réapparaître");
		}
		else if(health<=damage && gilet<=0 && bodypart==9)
		{
			RemovePlayerFromVehicle(damagedid);
		    SetPlayerHealth(damagedid, 0.1);
			ApplyAnimation(damagedid, "ped", "KO_shot_face", 4.1, 0, 0, 0, 1, 0, 1);
            dini_IntSet(pfileName, "Mort", 1);
			SendClientMessage(damagedid, COLOR_RED, "Tu es mort. Utilise \"/mourir\" pour réapparaître");
		}
		else if(gilet<=damage && gilet>0)
		{
		    SetPlayerArmour(damagedid, 0);
			health = floatsub(health, damage);
			SetPlayerHealth(damagedid,health);
			//ApplyAnimation(damagedid, "PED", "KO_skid_front", 4.1, 0, 0, 0, 1, 1500, 1);
			ApplyAnimation(damagedid, "PED", "GETUP", 5.0, 0, 0, 0, 0, 2500, 1);
		}
		else if(health>damage && gilet<=0)
		{
		    SetPlayerArmour(damagedid, 0);
		    health = floatsub(health, damage);
		    SetPlayerHealth(damagedid, health);
		}
		else
		{
			new Float:dHealth = 0.2*damage;
			health = floatsub(health, dHealth);
			SetPlayerHealth(damagedid,health);
			new Float:dGilet = 0.8*damage;
			gilet = floatsub(gilet, dGilet);
			if (gilet <= 0) SetPlayerArmour(damagedid, 0);
			ApplyAnimation(damagedid, "SUNBATHE", "LAY_bac_out", 4.0, 0, 0, 0, 0, 2500, 1);
		}

		format(playerMessage, sizeof(playerMessage), "~g~%.0f", damage);
		format(damagedMessage, sizeof(damagedMessage), "~r~%.0f", damage);
		GameTextForPlayer(playerid, playerMessage, 1000, 6);
		GameTextForPlayer(damagedid, damagedMessage, 1000, 6);
	}
	return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	//Login
	if(dialogid == DIALOG_LOGIN)
	{
	    if(response)
	    {
	        new pName[MAX_PLAYER_NAME], pfileName[48], password[128];
	        if(isnull(inputtext)) return ShowPlayerDialog(playerid, 23, DIALOG_STYLE_PASSWORD, "Connexion", "Entrez votre mot de passe.", "Connexion", "Annuler");
			GetPlayerName(playerid, pName, sizeof(pName));
			format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
			format(password, sizeof(password), "%s", dini_Get(pfileName, "Password"));
			if(strcmp(password, inputtext) == 0)
			{
				new iArgent, spawnTimerID;
				iArgent = dini_Int(pfileName, "iArgent");
				GivePlayerMoney(playerid, iArgent);
				dini_IntSet(pfileName, "essais", 0);
				spawnTimerID = SetTimerEx("DelaySpawn", 2000, false, "ii", playerid, spawnTimerID);
			}
			else
			{
				essais = dini_Int(pfileName, "essais") + 1;
				if(essais >= 3)
				{
				    SendClientMessage(playerid, COLOR_RED, "Là tu abuses, t'es viré !");
				    dini_IntSet(pfileName, "essais", 0);
					new kickTimerID = SetTimerEx("DelayKick", 500, false, "ii", playerid, kickTimerID);
				}
				else
				{
					ShowPlayerDialog(playerid, 23, DIALOG_STYLE_PASSWORD, "Connexion", "Entrez votre mot de passe.", "Connexion", "Annuler");
				    dini_IntSet(pfileName, "essais", essais);
					SendClientMessage(playerid, COLOR_RED, "Réessaye, tu vas y arriver.");
				}
			}
	    }
	    return 1;
	}
	
	//Enregistrement
	if(dialogid == DIALOG_REGISTER)
	{
	    if(response)
	    {

			if(isnull(inputtext)) return ShowPlayerDialog(playerid, 24, DIALOG_STYLE_PASSWORD, "Enregistrement", "Entrez votre mot de passe(ne pas entrer de mot de passe personnel, les admins le verront):~n~~r~Tu dois entrer un mot de passe", "Enregistrer", "Annuler");
	    	new pfileName[64], pName[MAX_PLAYER_NAME];
			GetPlayerName(playerid, pName, sizeof(pName));
			format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
			dini_Create(pfileName);
			dini_Set(pfileName, "Password", inputtext);
			dini_IntSet(pfileName, "bArgent", 1000000);
			dini_IntSet(pfileName, "iArgent", 500);
			dini_IntSet(pfileName, "Skin", 26);
			dini_IntSet(pfileName, "TP", 1);
			dini_IntSet(pfileName, "SpawnX", 1743);
			dini_IntSet(pfileName, "SpawnY", -1862);
			dini_IntSet(pfileName, "SpawnZ", 14);
			dini_IntSet(pfileName, "SpawnI", 0);
			SendClientMessage(playerid, COLOR_GREEN, "Compte créé avec succès!");
			ShowPlayerDialog(playerid, 23, DIALOG_STYLE_PASSWORD, "Connexion", "Entrez votre mot de passe.", "Connexion", "Annuler");
			return 1;
		}
	}
	
	//Menu principal
	if(dialogid == DIALOG_ARMES)
	{
		if (response)
		{
			switch(listitem)
	    	{
			case 0: ShowPlayerDialog(playerid, 2, DIALOG_STYLE_LIST, "Armes blanches", "Poing Américain\nClub de golf\nMatraque\nCouteau\nBatte\nPelle\nQueue de billard\nKatana\nTronçonneuse\nCanne\n \nRetour", "Choisir", "Annuler");
			case 1: ShowPlayerDialog(playerid, 3, DIALOG_STYLE_LIST, "Armes de poing", "Colt\nColt silencieux\nDesert Eagle\nTec-9\nUzi\n \nRetour", "Choisir", "Annuler");
			case 2: ShowPlayerDialog(playerid, 4, DIALOG_STYLE_LIST, "Fusils", "Fusil à pompe\nFusil à canon scié\nFusil de combat\nMP5\nAK-47\nM4\nRifle\nFusil de Sniper\n \nRetour", "Choisir", "Annuler");
			//case 3: ShowPlayerDialog(playerid, 5, DIALOG_STYLE_LIST, "Armes explosives", "RPG\nHS Rocket\nLance Flamme\n \nRetour", "Choisir", "Annuler");
			case 3: ShowPlayerDialog(playerid, 6, DIALOG_STYLE_LIST, "Objets", "God Violet\nGod classique\nVibro-masseur\nVibro-masseur argenté\nFleurs\nBombe de peinture\nExtincteur\nAppareil Photo\nParachute\n \nRetour", "Choisir", "Annuler");
			case 4: ShowPlayerDialog(playerid, 7, DIALOG_STYLE_LIST, "Grenades", "Grenade explosive\nGrenade fumigène\nCocktail Molotov\nC4\n \nRetour", "Choisir", "Annuler");
			}
		}
		return 1;
	}

	//Armes Blanches
	if(dialogid == DIALOG_ARMES_BLANCHES)
	{
		if(response)
		{
			switch(listitem)
 			{
  				case 0: GivePlayerWeapon(playerid, 1, 1);//Poing américain
 			 	case 1: GivePlayerWeapon(playerid, 2, 1);//Club de golf
  		 		case 2: GivePlayerWeapon(playerid, 3, 1);//Matraque
  				case 3: GivePlayerWeapon(playerid, 4, 1);//Couteau
    	    	case 4: GivePlayerWeapon(playerid, 5, 1);//Batte
        		case 5: GivePlayerWeapon(playerid, 6, 1);//Pelle
     		   	case 6: GivePlayerWeapon(playerid, 7, 1);//Queue de billard
        		case 7: GivePlayerWeapon(playerid, 8, 1);//Katana
        		case 8: GivePlayerWeapon(playerid, 9, 1);//Tronçonneuse
        		case 9: GivePlayerWeapon(playerid, 15, 1);//Canne
        		case 11: ShowPlayerDialog(playerid, 1, DIALOG_STYLE_LIST, "Catégories d'armes", "Armes blanches\nArmes de poing\nFusils\nObjets\nGrenades", "Choisir", "Annuler");
    		}
			return 1;
		}
    }

    if(dialogid == DIALOG_ARMES_POING)
    {
        if(response)
        {
        	switch(listitem)
        	{
            	case 0: GivePlayerWeapon(playerid, 22, 1000);//Colt
           		case 1: GivePlayerWeapon(playerid, 23, 1000);//Colt Silencieux
            	case 2: GivePlayerWeapon(playerid, 24, 1000);//Deagle
            	case 3: GivePlayerWeapon(playerid, 32, 1000);//Tec-9
        		case 4: GivePlayerWeapon(playerid, 28, 1000);//Uzi
        		case 6: ShowPlayerDialog(playerid, 1, DIALOG_STYLE_LIST, "Catégories d'armes", "Armes blanches\nArmes de poing\nFusils\nObjets\nGrenades", "Choisir", "Annuler");
        	}
			return 1;
		}
    }

    if(dialogid == DIALOG_FUSILS)
    {
        if(response)
        {
        	switch(listitem)
        	{
            	case 0: GivePlayerWeapon(playerid, 25, 1000);//Pompe
            	case 1: GivePlayerWeapon(playerid, 26, 1000);//Canon scié
        		case 2: GivePlayerWeapon(playerid, 27, 1000);//Combat
        		case 3: GivePlayerWeapon(playerid, 29, 1000);//MP5
        		case 4: GivePlayerWeapon(playerid, 30, 1000);//AK 47
        		case 5: GivePlayerWeapon(playerid, 31, 1000);//M4
        		case 6: GivePlayerWeapon(playerid, 33, 1000);//Rifle
        		case 7: GivePlayerWeapon(playerid, 34, 1000);//Sniper
        		case 9: ShowPlayerDialog(playerid, 1, DIALOG_STYLE_LIST, "Catégories d'armes", "Armes blanches\nArmes de poing\nFusils\nObjets\nGrenades", "Choisir", "Annuler");
        	}
		}
        return 1;
    }

    if(dialogid == DIALOG_ARMES_EXPLOSIVES)
    {
        if(response)
        {
    	    switch(listitem)
        	{
            	case 0: GivePlayerWeapon(playerid, 35, 1000);//RPG
            	case 1: GivePlayerWeapon(playerid, 36, 1000);//HS Rocket
            	case 2: GivePlayerWeapon(playerid, 37, 1000);//Lance Flamme
            	case 4: ShowPlayerDialog(playerid, 1, DIALOG_STYLE_LIST, "Catégories d'armes", "Armes blanches\nArmes de poing\nFusils\nObjets\nGrenades", "Choisir", "Annuler");
        	}
		}
        return 1;
	}

    if(dialogid == DIALOG_OBJETS)
    {
        if(response)
        {
        	switch(listitem)
        	{
            	case 0: GivePlayerWeapon(playerid, 10, 1);//God Violet
        		case 1: GivePlayerWeapon(playerid, 11, 1);//God classique
        		case 2: GivePlayerWeapon(playerid, 12, 1);//Vibro classique
        		case 3: GivePlayerWeapon(playerid, 13, 1);//Vibro argenté
        		case 4: GivePlayerWeapon(playerid, 14, 1);//Fleurs
				case 5: GivePlayerWeapon(playerid, 41, 5000);//Bombe de peinture
        		case 6: GivePlayerWeapon(playerid, 42, 5000);//Extincteur
        		case 7: GivePlayerWeapon(playerid, 43, 1000);//Camera
        		case 8: GivePlayerWeapon(playerid, 46, 1000);//Parachute
        		case 10: ShowPlayerDialog(playerid, 1, DIALOG_STYLE_LIST, "Catégories d'armes", "Armes blanches\nArmes de poing\nFusils\nObjets\nGrenades", "Choisir", "Annuler");
        	}
		}
        return 1;
    }

    if(dialogid == DIALOG_GRENADES)
	{
	    if(response)
	    {
			switch(listitem)
 			{
  				case 0: GivePlayerWeapon(playerid, 16, 500);//Explosive
            	case 1: GivePlayerWeapon(playerid, 17, 500);//Fumigène
            	case 2: GivePlayerWeapon(playerid, 18, 500);//Molotov
            	case 3: GivePlayerWeapon(playerid, 39, 500);//C4
            	case 5: ShowPlayerDialog(playerid, 1, DIALOG_STYLE_LIST, "Catégories d'armes", "Armes blanches\nArmes de poing\nFusils\nObjets\nGrenades", "Choisir", "Annuler");
    		}
		}
    	return 1;
    }
    
    //Vehicules
	if(response == 1)
	{
    if(dialogid == DIALOG_VEHICLE)
	{
	    switch(listitem)
	    {
	    	case 0: ShowPlayerDialog(playerid, 9, DIALOG_STYLE_LIST, "Avions", "Skimmer(100 000$)\nRustler(100 000$)\nBeagle(50 000$)\nCropduster(75 000$)\nStuntplane(75 000$)\nShamal(300 000$)\nHydra(500 000$)\nNevada(500 000$)\nAndromada(600 000$)\nAT-400(500 000$)\nDodo(50 000$)", "Choisir", "Annuler");
	    	case 1: ShowPlayerDialog(playerid, 10, DIALOG_STYLE_LIST, "Hélicoptères", "Cargobob(700 000$)\nHunter(1 000 000$)\nLeviathan(400 000$)\nMaverick 4p(300 000$)\nMaverick 2p(250 000$)\nRaindance(500 000$)\nSeasparrow(60 000$)\nSparrow(50 000$)", "Choisir", "Annuler");
	    	case 2: ShowPlayerDialog(playerid, 11, DIALOG_STYLE_LIST, "Deux roues", "Vélo(1 000$)\nBMX(1 500$)\nVTT(2 000$)\nScooter(5 000$)\nBF-400(15 000$)\nNRG-500(160 000$)\nPCJ-600(20 000$)\nFCR-900(40 000$)\nFreeway(35 000$)\nWayfarer(45 000$)\nSanchez(25 000$)\nQuad(25 000$)", "Choisir", "Annuler");
	    	case 3: ShowPlayerDialog(playerid, 12, DIALOG_STYLE_LIST, "Toit ouvrant", "Comet(170 000$)\nFeltzer(80 000$)\nStallion(50 000$)\nWindsor(70 000$)", "Choisir", "Annuler");
	    	case 4: ShowPlayerDialog(playerid, 13, DIALOG_STYLE_LIST, "Industriels", "Benson(40 000$)\nBobcat(35 000$)\nBurrito(70 000$)\nBoxville(60 000$)\nBoxburg(65 000$)\nCamion ciment(100 000$)\nDFT-30(70 000$)\nCamion-benne(80 000$)\nCamion américain(110 000$)\nMule(75 000$)\nNewsvan(50 000$)\nPacker(150 000$)\nPétrolier(150 000$)\nPicador(45 000$)\nPony(50 000$)\nRoadtrain(90 000$)", "Choisir", "Annuler");
			case 5: ShowPlayerDialog(playerid, 14, DIALOG_STYLE_LIST, "Lowriders", "Blade(50 000$)\nBroadway(35 000$)\nRemington(50 000$)\nSavanna(55 000$)\nSlamvan(60 000$)\nTahoma(40 000$)\nTornado(30 000$)\nVoodoo(45 000$)", "Choisir", "Annuler");
	    	case 6: ShowPlayerDialog(playerid, 15, DIALOG_STYLE_LIST, "4x4", "Bandito(40 000$)\nBF Injection(45 000$)\nCamion Paris-Dakkar(80 000$)\nHuntley(75 000$)\nLandstalker(45 000$)\nMesa(45 000$)\nMonster Truck(85 000$)\nPatriot(80 000$)\nRancher(70 000$)\nSandking(65 000$)", "Choisir", "Annuler");
	    	case 7: ShowPlayerDialog(playerid, 16, DIALOG_STYLE_LIST, "Services publiques", "Ambulance\nBarracks\nBus\nVieux taxi\nMoto de police\nCamionnette de Police\nFBI Rancher\nFBI Truck\nFiretruck\nVoiture de police(LSPD)\nVoiture de police(LVPD)\nVoiture de police(SFPD)\nRanger\nSWAT\nTaxi", "Choisir", "Annuler");
	    	case 8: ShowPlayerDialog(playerid, 17, DIALOG_STYLE_LIST, "Voitures normales", "Admiral(35 000$)\nBloodring Banger(20 000$)\nBravura(35 000$)\nBuccaneer(37 000$)\nCadrona(35 000$)\nClover(40 000$)\nElegant(40 000$)\nElegy(90 000$)\nEmperor(45 000$)\nEsperanto(40 000$)\nFortune(40 000$)\nGlendale(cassée)(10 000$)\nGlendale(25 000$)\nGreenwood(35 000$)\nHermes(35 000$)", "Choisir", "Annuler");
	    	case 9: ShowPlayerDialog(playerid, 18, DIALOG_STYLE_LIST, "Voitures de sport", "Alpha(80 000$)\nBanshee\nBlista Compact\nBuffalo\nBullet\nCheetah\nClub\nEuros\nFlash\nHotring racer\nInfernus\nJester\nPhoenix\nSabre\nSuperGT\nTurismo\nUranus\nZR-350", "Choisir", "Annuler");
	    	case 10: ShowPlayerDialog(playerid, 19, DIALOG_STYLE_LIST, "Véhicules familiaux", "Moonbeam\nPerenniel\nRegina\nSolair\nStratum", "Choisir", "Annuler");
	    	case 11: ShowPlayerDialog(playerid, 20, DIALOG_STYLE_LIST, "Bateaux", "Coastguard\nDinghy\nJetmax\nLaunch\nMarquis\nPredator\nReefer\nSpeeder\nSquallo\nTropic", "Choisir", "Annuler");
	    	case 12: ShowPlayerDialog(playerid, 21, DIALOG_STYLE_LIST, "Inclassables", "UMP\nLimousine\nGlacier\nFourgon blindé\nHotknife\nCorbillard\nTram\nVoiture de golf\nMinibus\nTransporteur de bagages\nBulldozer\nCamping Car\nDépanneuse\nForklift\nMoissonneuse\nLocomotive\nTrain de passagers\nVortex\nHustler\nKart\nTracteur tondeuse\nBalayeuse\nCamion de HotDog", "Choisir", "Annuler");
	    	case 13: ShowPlayerDialog(playerid, 22, DIALOG_STYLE_LIST, "Véhicules miniatures", "RC Bandit\nRC Baron\nRC Raider\nRC Goblin\nRC Tiger\nRC Cam", "Choisir", "Annuler");
			case 14: ShowPlayerDialog(playerid, 25, DIALOG_STYLE_LIST, "Autres 1", "Rumpo(65 000$)\nSadler(40 000$)\nSadler cassée(15 000$)\nTopfun(55 000$)\nTractor(15 000$)\nCamion à poubelles(110 000$)\nPlombier(55 000$)\nWalton(35 000$)\nYankee(80 000$)\nYosemite(65 000$)", "Choisir", "Anuuler");
            case 15: ShowPlayerDialog(playerid, 26, DIALOG_STYLE_LIST, "Autres 2","Intruder(38 000$)\nMajestic(38 000$)\nManana(35 000$)\nMerit(45 000$)\nNebula(45 000$)\nOceanic(30 000$)\nPremier(45 000$)\nPrevion(40 000$)\nPrimo(43 000$)\nSentinel(50 000$)\nStafford(47 000$)\nSultan(200 000$)\nSunrise(50 000$)\nTampa(40 000$)\nVincent(45 000$)\nVirgo(40 000$)\nWillard(40 000$)\nWashington(40 000$)", "Choisir", "Annuler");
		}
		return 1;
 	}
 	new modelid, money, vehicleid, tCarburant;
	new Float:carburant = 100;
	new Float:p_pos[3];
	GetPlayerPos(playerid, p_pos[0], p_pos[1], p_pos[2]);
 	if(dialogid == DIALOG_AVIONS)
	{
	    switch(listitem)
	    {
			case 0: modelid = 460, money = 100000, carburant = 150, tCarburant = 4;
			case 1: modelid = 476, money = 100000, carburant = 150, tCarburant = 4;
			case 2: modelid = 511, money = 50000, carburant = 180, tCarburant = 4;
			case 3: modelid = 512, money = 75000, carburant = 150, tCarburant = 4;
			case 4: modelid = 513, money = 75000, carburant = 150, tCarburant = 4;
			case 5: modelid = 519, money = 300000, carburant = 250, tCarburant = 4;
			case 6: modelid = 520, money = 500000, carburant = 100, tCarburant = 4;
			case 7: modelid = 553, money = 500000, carburant = 350, tCarburant = 4;
			case 8: modelid = 592, money = 600000, carburant = 400, tCarburant = 4;
			case 9: modelid = 577, money = 500000, carburant = 300, tCarburant = 4;
			case 10: modelid = 593, money = 50000, carburant = 150, tCarburant = 4;
		}
	}
	
	if(dialogid == DIALOG_HELICO)
	{
	    switch(listitem)
	    {
			case 0: modelid = 548, money = 700000, carburant = 150, tCarburant = 4;
			case 1: modelid = 425, money = 1000000, carburant = 50, tCarburant = 4;
			case 2: modelid = 417, money = 450000, carburant = 120, tCarburant = 4;
			case 3: modelid = 487, money = 320000, carburant = 80, tCarburant = 4;
			case 4: modelid = 488, money = 260000, carburant = 40, tCarburant = 4;
			case 5: modelid = 563, money = 500000, carburant = 120, tCarburant = 4;
			case 6: modelid = 447, money = 350000, carburant = 80, tCarburant = 4;
			case 7: modelid = 469, money = 250000, carburant = 40, tCarburant = 4;
		}
	}
	
	if(dialogid == DIALOG_MOTOS)
	{
	    switch(listitem)
	    {
	        case 0: modelid = 509, money = 1000, carburant = 40, tCarburant = 5;
	        case 1: modelid = 481, money = 1500, carburant = 70, tCarburant = 5;
	        case 2: modelid = 510, money = 2000, carburant = 120, tCarburant = 5;
	        case 3: modelid = 462, money = 5000, carburant = 60, tCarburant = 2;
	        case 4: modelid = 581, money = 15000, carburant = 50, tCarburant = 2;
	        case 5: modelid = 522, money = 160000, carburant = 90, tCarburant = 2;
	        case 6: modelid = 461, money = 20000, carburant = 60, tCarburant = 2;
	        case 7: modelid = 521, money = 40000, carburant = 80, tCarburant = 2;
	        case 8: modelid = 463, money = 35000, carburant = 80, tCarburant = 2;
	        case 9: modelid = 586, money = 45000, carburant = 120, tCarburant = 2;
	        case 10: modelid = 468, money = 25000, carburant = 50, tCarburant = 2;
	        case 11: modelid = 471, money = 25000, carburant = 80, tCarburant = 1;
	    }
	}
	
	if(dialogid == DIALOG_TOIT)
	{
	    switch(listitem)
	    {
	        case 0: modelid = 480, money = 170000, carburant = 80, tCarburant = 2;
	        case 1: modelid = 533, money = 80000, carburant = 80, tCarburant = 2;
	        case 2: modelid = 439, money = 50000, carburant = 80, tCarburant = 2;
	        case 3: modelid = 555, money = 70000, carburant = 70, tCarburant = 2;
	    }
	}
	

	if(dialogid == DIALOG_INDUSTRIELS)
	{
	    switch(listitem)
	    {
	        case 0: modelid = 499, money = 40000, carburant = 60, tCarburant = 1;
	        case 1: modelid = 422, money = 35000, carburant = 60, tCarburant = 1;
	        case 2: modelid = 482, money = 70000, carburant = 80, tCarburant = 1;
	        case 3: modelid = 498, money = 60000, carburant = 70, tCarburant = 1;
	        case 4: modelid = 609, money = 65000, carburant = 70, tCarburant = 1;
	        case 5: modelid = 524, money = 100000, carburant = 140, tCarburant = 1;
	        case 6: modelid = 578, money = 70000, carburant = 70, tCarburant = 1;
	        case 7: modelid = 455, money = 80000, carburant = 100, tCarburant = 1;
	        case 8: modelid = 403, money = 100000, carburant = 140, tCarburant = 1;
	        case 9: modelid = 414, money = 75000, carburant = 80, tCarburant = 1;
	        case 10: modelid = 582, money = 50000, carburant = 70, tCarburant = 1;
	        case 11: modelid = 443, money = 150000, carburant = 120, tCarburant = 1;
	        case 12: modelid = 514, money = 150000, carburant = 240, tCarburant = 1;
	        case 13: modelid = 600, money = 45000, carburant = 70, tCarburant = 1;
	        case 14: modelid = 413, money = 50000, carburant = 70, tCarburant = 1;
	        case 15: modelid = 515, money = 90000, carburant = 110, tCarburant = 1;
	        case 16: modelid = 440, money = 65000, carburant = 80, tCarburant = 1;
	        case 17: modelid = 543, money = 40000, carburant = 70, tCarburant = 1;
	        case 18: modelid = 605, money = 15000, carburant = 40, tCarburant = 1;
	        case 19: modelid = 459, money = 55000, carburant = 70, tCarburant = 1;
	        case 20: modelid = 531, money = 15000, carburant = 80, tCarburant = 1;
            case 21: modelid = 408, money = 140000, carburant = 70, tCarburant = 1;
            case 22: modelid = 552, money = 55000, carburant = 80, tCarburant = 1;
            case 23: modelid = 478, money = 20000, carburant = 60, tCarburant = 1;
            case 24: modelid = 456, money = 80000, carburant = 80, tCarburant = 1;
            case 25: modelid = 554, money = 80000, carburant = 100, tCarburant = 1;
	    }
	}

	if(dialogid == DIALOG_LOWRIDERS)
	{
	    switch(listitem)
	    {
	        case 0: modelid = 536, money = 50000;
	        case 1: modelid = 575, money = 35000;
	        case 2: modelid = 534, money = 50000;
	        case 3: modelid = 567, money = 55000;
	        case 4: modelid = 535, money = 60000;
	        case 5: modelid = 566, money = 40000;
	        case 6: modelid = 576, money = 30000;
	        case 7: modelid = 412, money = 45000;
	    }
	}
	
	if(dialogid == DIALOG_4x4)
	{
	    switch(listitem)
	    {
	        case 0: modelid = 568, money = 40000;
	        case 1: modelid = 424, money = 45000;
	        case 2: modelid = 573, money = 80000;
	        case 3: modelid = 579, money = 75000;
	        case 4: modelid = 400, money = 45000;
	        case 5: modelid = 500, money = 45000;
	        case 6: modelid = 444, money = 85000;
	        case 7: modelid = 470, money = 80000;
	        case 8: modelid = 489, money = 70000;
	        case 9: modelid = 495, money = 65000;
	    }
	}
	
	if(dialogid == DIALOG_NORMALES)
	{
	    switch(listitem)
	    {
	        case 0: modelid = 445, money = 35000;
	        case 1: modelid = 504, money = 20000;
	        case 2: modelid = 401, money = 35000;
	        case 3: modelid = 518, money = 37000;
	        case 4: modelid = 527, money = 35000;
	        case 5: modelid = 542, money = 40000;
	        case 6: modelid = 507, money = 40000;
	        case 7: modelid = 562, money = 90000;
	        case 8: modelid = 585, money = 45000;
	        case 9: modelid = 419, money = 40000;
	        case 10: modelid = 526, money = 40000;
	        case 11: modelid = 604, money = 10000;
	        case 12: modelid = 466, money = 25000;
	        case 13: modelid = 492, money = 35000;
	        case 14: modelid = 474, money = 35000;
	        case 15: modelid = 546, money = 38000;
	        case 17: modelid = 517, money = 38000;
	        case 18: modelid = 410, money = 35000;
	        case 19: modelid = 551, money = 45000;
	        case 20: modelid = 516, money = 45000;
	        case 21: modelid = 467, money = 30000;
	        case 22: modelid = 426, money = 45000;
	        case 23: modelid = 436, money = 40000;
	        case 24: modelid = 547, money = 43000;
	        case 25: modelid = 405, money = 50000;
	        case 26: modelid = 580, money = 47000;
	        case 27: modelid = 560, money = 200000;
	        case 28: modelid = 550, money = 50000;
	        case 29: modelid = 549, money = 40000;
	        case 30: modelid = 540, money = 45000;
	        case 31: modelid = 491, money = 40000;
	        case 32: modelid = 529, money = 40000;
	        case 33: modelid = 421, money = 40000;
	    }
	}
	
	if(dialogid == DIALOG_SERVICES)
	{
	    switch(listitem)
	    {
	        case 0: modelid = 416;
	        case 1: modelid = 433, money = 0, carburant = 100;
	        case 2: modelid = 431, money = 0, carburant = 100;
	        case 3: modelid = 438, money = 0, carburant = 100;
	        case 4: modelid = 523, money = 0, carburant = 100;
	        case 5: modelid = 427, money = 0, carburant = 100;
	        case 6: modelid = 490, money = 0, carburant = 100;
	        case 7: modelid = 528, money = 0, carburant = 100;
	        case 8: modelid = 407, money = 0, carburant = 100;
	        case 9: modelid = 596, money = 0, carburant = 100;
	        case 10: modelid = 598, money = 0, carburant = 100;
	        case 11: modelid = 597, money = 0, carburant = 100;
	        case 12: modelid = 599, money = 0, carburant = 100;
	        case 13: modelid = 601, money = 0, carburant = 100;
	        case 14: modelid = 420, money = 0, carburant = 100;
	    }
	}
	
	if(dialogid == DIALOG_SPORTS)
	{
	    switch(listitem)
	    {
	        case 0: modelid = 602, money = 80000, carburant = 80;
	        case 1: modelid = 429, money = 0, carburant = 100;
	        case 2: modelid = 496, money = 0, carburant = 100;
	        case 3: modelid = 402, money = 0, carburant = 100;
	        case 4: modelid = 541, money = 0, carburant = 100;
	        case 5: modelid = 415, money = 0, carburant = 100;
	        case 6: modelid = 589, money = 0, carburant = 100;
	        case 7: modelid = 587, money = 0, carburant = 100;
	        case 8: modelid = 565, money = 0, carburant = 100;
	        case 9: modelid = 494, money = 0, carburant = 100;
	        case 10: modelid = 411, money = 0, carburant = 100;
	        case 11: modelid = 559, money = 0, carburant = 100;
	        case 12: modelid = 603, money = 0, carburant = 100;
	        case 13: modelid = 475, money = 0, carburant = 100;
	        case 14: modelid = 506, money = 0, carburant = 100;
	        case 15: modelid = 451, money = 0, carburant = 100;
	        case 16: modelid = 558, money = 0, carburant = 100;
	        case 17: modelid = 477, money = 0, carburant = 100;
	    }
	}
	
	if(dialogid == DIALOG_FAMILIAUX)
	{
	    switch(listitem)
	    {
	        case 0: modelid = 418, money = 0, carburant = 100;
	        case 1: modelid = 404, money = 0, carburant = 100;
	        case 2: modelid = 479, money = 0, carburant = 100;
	        case 3: modelid = 458, money = 0, carburant = 100;
	        case 4: modelid = 561, money = 0, carburant = 100;
	    }
	}
	
	if(dialogid == DIALOG_BATEAUX)
	{
	    switch(listitem)
	    {
	        case 0: modelid = 472, money = 0, carburant = 100;
	        case 1: modelid = 473, money = 0, carburant = 100;
	        case 2: modelid = 493, money = 0, carburant = 100;
	        case 3: modelid = 595, money = 0, carburant = 100;
	        case 4: modelid = 484, money = 0, carburant = 100;
	        case 5: modelid = 430, money = 0, carburant = 100;
	        case 6: modelid = 453, money = 0, carburant = 100;
	        case 7: modelid = 452, money = 0, carburant = 100;
	        case 8: modelid = 446, money = 0, carburant = 100;
	        case 9: modelid = 454, money = 0, carburant = 100;
     	}
	}
	
	if(dialogid == DIALOG_INCLASSABLES)
	{
	    switch(listitem)
	    {
	        case 0: modelid = 406, money = 0, carburant = 100;
	        case 1: modelid = 409, money = 0, carburant = 100;
	        case 2: modelid = 423, money = 0, carburant = 100;
	        case 3: modelid = 428, money = 0, carburant = 100;
	        case 4: modelid = 434, money = 0, carburant = 100;
	        case 5: modelid = 442, money = 0, carburant = 100;
	        case 6: modelid = 449, money = 0, carburant = 100;
	        case 7: modelid = 457, money = 0, carburant = 100;
	        case 8: modelid = 483, money = 0, carburant = 100;
	        case 9: modelid = 485, money = 0, carburant = 100;
	        case 10: modelid = 486, money = 0, carburant = 100;
	        case 11: modelid = 508, money = 0, carburant = 100;
	        case 12: modelid = 525, money = 0, carburant = 100;
	        case 13: modelid = 530, money = 0, carburant = 100;
	        case 14: modelid = 532, money = 0, carburant = 100;
	        case 15: modelid = 537, money = 0, carburant = 100;
	        case 16: modelid = 538, money = 0, carburant = 100;
	        case 17: modelid = 539, money = 0, carburant = 100;
	        case 18: modelid = 545, money = 0, carburant = 100;
	        case 19: modelid = 571, money = 0, carburant = 100;
	        case 20: modelid = 572, money = 0, carburant = 100;
	        case 21: modelid = 574, money = 0, carburant = 100;
	        case 22: modelid = 583, money = 0, carburant = 100;
	        case 23: modelid = 588, money = 0, carburant = 100;
		}
	}
	
	if(dialogid == DIALOG_MINIATURES)
	{
	    switch(listitem)
	    {
	        case 0: modelid = 441, money = 0, carburant = 100;
	        case 1: modelid = 464, money = 0, carburant = 100;
	        case 2: modelid = 465, money = 0, carburant = 100;
	        case 3: modelid = 501, money = 0, carburant = 100;
	        case 4: modelid = 564, money = 0, carburant = 100;
	        case 5: modelid = 594, money = 0, carburant = 100;
		}
	}

    if(dialogid == DIALOG_AUTRE1)
	{
	    switch(listitem)
	    {
         	case 0: modelid = 440, money = 0, carburant = 100;
         	case 1: modelid = 543, money = 0, carburant = 100;
         	case 2: modelid = 605, money = 0, carburant = 100;
         	case 3: modelid = 459, money = 0, carburant = 100;
         	case 4: modelid = 531, money = 0, carburant = 100;
         	case 5: modelid = 408, money = 0, carburant = 100;
         	case 6: modelid = 552, money = 0, carburant = 100;
         	case 7: modelid = 478, money = 0, carburant = 100;
         	case 8: modelid = 456, money = 0, carburant = 100;
         	case 9: modelid = 554, money = 0, carburant = 100;
		}
	}
	
	if(dialogid == DIALOG_AUTRE2)
	{
	    switch(listitem)
	    {
	        case 0: modelid = 546, money = 0, carburant = 100;
	        case 1: modelid = 517, money = 0, carburant = 100;
	        case 2: modelid = 410, money = 0, carburant = 100;
	        case 3: modelid = 551, money = 0, carburant = 100;
	        case 4: modelid = 516, money = 0, carburant = 100;
	        case 5: modelid = 467, money = 0, carburant = 100;
	        case 6: modelid = 426, money = 0, carburant = 100;
	        case 7: modelid = 436, money = 0, carburant = 100;
	        case 8: modelid = 547, money = 0, carburant = 100;
	        case 9: modelid = 405, money = 0, carburant = 100;
	        case 10: modelid = 580, money = 0, carburant = 100;
	        case 11: modelid = 560, money = 0, carburant = 100;
	        case 12: modelid = 550, money = 0, carburant = 100;
	        case 13: modelid = 549, money = 0, carburant = 100;
	        case 14: modelid = 540, money = 0, carburant = 100;
	        case 15: modelid = 491, money = 0, carburant = 100;
	        case 16: modelid = 529, money = 0, carburant = 100;
	        case 17: modelid = 421, money = 0, carburant = 100;
		}
	}

	new pVirtual, pInterior, couleur1, couleur2;
	couleur1 = random(256);
	couleur2 = random(256);
	vehicleid = CreateVehicle(modelid, p_pos[0], p_pos[1], p_pos[2]+1, 270.0, couleur1, couleur2, -1);
	pVirtual = GetPlayerVirtualWorld(playerid);
	pInterior = GetPlayerInterior(playerid);
	LinkVehicleToInterior(vehicleid, pInterior);
	SetVehicleVirtualWorld(vehicleid, pVirtual);
	PutPlayerInVehicle(playerid, vehicleid, 0);
	money = 0;
	GivePlayerMoney(playerid, money);
	new fileName[24], pfileName[32+MAX_PLAYER_NAME], pName[32], string[16];
	GetPlayerName(playerid, pName, sizeof(pName));
	SendClientMessage(playerid, COLOR_GREEN, "Ton véhicule est prêt.");
	format(fileName, sizeof(fileName), "vehicules/%i.ini", vehicleid);
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	//Paramètres du véhicule
	dini_Create(fileName);
	dini_IntSet(fileName, "modelid", modelid);
	dini_IntSet(fileName, "couleur1", couleur1);
	dini_IntSet(fileName, "couleur2", couleur2);
	dini_Set(fileName, "proprio1", pName);
	dini_FloatSet(fileName, "maxCar", carburant);
	dini_FloatSet(fileName, "curCar", carburant);
	dini_IntSet(fileName, "typeCar", tCarburant);
	//Définit le propriétaire
	for(new vid = 1; vid <= 10; vid++)
	{
	    format(string, sizeof(string), "vehicle%i", vid);
		new vnb = dini_Int(pfileName, string);
		if (vnb == 0)
		{
			dini_IntSet(pfileName, string, vehicleid);
			dini_IntSet(fileName, "vehiclenb", vid);
			break;
		}
	}
	}
	return 0;
}

public OnPlayerSelectObject(playerid, type, objectid, modelid, Float:fX, Float:fY, Float:fZ)
{
    new ofileName[32], pfileName[48], pName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pName, sizeof(pName));
    format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
    format(ofileName, sizeof(ofileName), "objects/%i.txt", objectid);
    if(dini_Int(pfileName, "selection") == 0)//Modifier
    {
		EditObject(playerid, objectid);
	}
	else if(dini_Int(pfileName, "selection") == 1)//Copie
	{
	    new nobjectid, Float:o_pos[6], nofileName[58];
	    GetObjectPos(objectid, o_pos[0], o_pos[1], o_pos[2]);
	    GetObjectRot(objectid, o_pos[3], o_pos[4], o_pos[5]);
	    nobjectid = CreateObject(modelid, o_pos[0], o_pos[1], o_pos[2], o_pos[3], o_pos[4], o_pos[5], 30000);
	    format(nofileName, sizeof(nofileName), "objects/%i.txt", nobjectid);
	    dini_Create(nofileName);
	    dini_IntSet(nofileName, "modelid", modelid);
    	EditObject(playerid, nobjectid);
	}
	return 1;
}

public OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
	new ofileName[32], cfileName[52], pefileName[52], gefileName[52], arfileName[24], cofileName[24];
	format(ofileName, sizeof(ofileName), "objects/%i.txt", objectid);
	format(cfileName, sizeof(cfileName), "objects/cabanes/%i.ini", objectid);
	format(pefileName, sizeof(pefileName), "objects/pechelles/%i.ini", objectid);
	format(gefileName, sizeof(gefileName), "objects/gechelles/%i.ini", objectid);
	format(cofileName, sizeof(cofileName), "objects/coffres/%i.ini", objectid);
	format(arfileName, sizeof(arfileName), "arbres/%i.ini", objectid);
	//Arbres
	if(dini_Exists(arfileName) == 1)
	{
	    if(response != 2)
	    {
	    	dini_FloatSet(arfileName,"posX", fX);
			dini_FloatSet(arfileName,"posY", fY);
			dini_FloatSet(arfileName,"posZ", fZ);
			dini_FloatSet(arfileName,"rotX", fRotX);
			dini_FloatSet(arfileName,"rotY", fRotY);
			dini_FloatSet(arfileName,"rotZ", fRotZ);
			SetObjectPos(objectid, fX, fY, fZ);
			return SetObjectRot(objectid, fRotX, fRotY, fRotZ);
		}
	}
	//Objets mapping
	else if(dini_Exists(ofileName) == 1)
	{
		if(response == 1)
		{
   			dini_FloatSet(ofileName,"posX", fX);
			dini_FloatSet(ofileName,"posY", fY);
			dini_FloatSet(ofileName,"posZ", fZ);
			dini_FloatSet(ofileName,"rotX", fRotX);
			dini_FloatSet(ofileName,"rotY", fRotY);
			dini_FloatSet(ofileName,"rotZ", fRotZ);
			SetObjectPos(objectid, fX, fY, fZ);
			return SetObjectRot(objectid, fRotX, fRotY, fRotZ);
		}
		if(response == 0)
		{
			DestroyObject(objectid);
			dini_Remove(ofileName);
			return SendClientMessage(playerid, COLOR_GREEN, "Objet supprimé.");
		}
	}
	//Cabanes
	else if(dini_Exists(cfileName) == 1)
	{
	    if(response != 2)
	    {
	   		dini_FloatSet(cfileName,"posX", fX);
			dini_FloatSet(cfileName,"posY", fY);
			dini_FloatSet(cfileName,"posZ", fZ);
			dini_FloatSet(cfileName,"rotX", fRotX);
			dini_FloatSet(cfileName,"rotY", fRotY);
			dini_FloatSet(cfileName,"rotZ", fRotZ);
			SetObjectPos(objectid, fX, fY, fZ);
			return SetObjectRot(objectid, fRotX, fRotY, fRotZ);
		}
	}
	//Petites échelles
	else if(dini_Exists(pefileName) == 1)
	{
	    if(response != 2)
	    {
	   		dini_FloatSet(pefileName,"posX", fX);
			dini_FloatSet(pefileName,"posY", fY);
			dini_FloatSet(pefileName,"posZ", fZ);
			dini_FloatSet(pefileName,"rotX", fRotX);
			dini_FloatSet(pefileName,"rotY", fRotY);
			dini_FloatSet(pefileName,"rotZ", fRotZ);
			SetObjectPos(objectid, fX, fY, fZ);
			return SetObjectRot(objectid, fRotX, fRotY, fRotZ);
		}
	}
	//Grandes échelles
	else if(dini_Exists(gefileName) == 1)
	{
	    if(response != 2)
	    {
	   		dini_FloatSet(gefileName,"posX", fX);
			dini_FloatSet(gefileName,"posY", fY);
			dini_FloatSet(gefileName,"posZ", fZ);
			dini_FloatSet(gefileName,"rotX", fRotX);
			dini_FloatSet(gefileName,"rotY", fRotY);
			dini_FloatSet(gefileName,"rotZ", fRotZ);
			SetObjectPos(objectid, fX, fY, fZ);
			return SetObjectRot(objectid, fRotX, fRotY, fRotZ);
		}
	}
	//Coffres
	else if(dini_Exists(cofileName) == 1)
	{
	    if(response != 2)
	    {
	   		dini_FloatSet(cofileName,"posX", fX);
			dini_FloatSet(cofileName,"posY", fY);
			dini_FloatSet(cofileName,"posZ", fZ);
			dini_FloatSet(cofileName,"rotX", fRotX);
			dini_FloatSet(cofileName,"rotY", fRotY);
			dini_FloatSet(cofileName,"rotZ", fRotZ);
			SetObjectPos(objectid, fX, fY, fZ);
			return SetObjectRot(objectid, fRotX, fRotY, fRotZ);
		}
	}
	return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if(playertextid == petitechelleTD)
    {
        new pfileName[48], pName[MAX_PLAYER_NAME], iPlanches, ipEchelle;
        GetPlayerName(playerid, pName, sizeof(pName));
        format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
		iPlanches = dini_Int(pfileName, "iPlanches");
        if(iPlanches >= 3)
        {
			CancelSelectTextDraw(playerid);
			PlayerTextDrawHide(playerid, fondTD);
			PlayerTextDrawHide(playerid, petitechelleTD);
			PlayerTextDrawHide(playerid, grandechelleTD);
			PlayerTextDrawHide(playerid, planchesTD);
			PlayerTextDrawHide(playerid, cabaneTD);
			PlayerTextDrawHide(playerid, fermerTD);
			PlayerTextDrawHide(playerid, batonTD);
			ipEchelle = dini_Int(pfileName, "ipEchelle");
			dini_IntSet(pfileName, "ipEchelle", ipEchelle+1);
			dini_IntSet(pfileName, "iPlanches", iPlanches-3);
  			SendClientMessage(playerid, COLOR_GREEN, "Tu as reçu une petite échelle en échange de 3 planches.");
		}
		else SendClientMessage(playerid, COLOR_RED, "Tu as besoin de 3 planches pour fabriquer une petite échelle.");
    }
    
    else if(playertextid == grandechelleTD)
    {
        new pfileName[48], pName[MAX_PLAYER_NAME], iPlanches, igEchelle;
        GetPlayerName(playerid, pName, sizeof(pName));
        format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
		iPlanches = dini_Int(pfileName, "iPlanches");
        if(iPlanches >= 5)
        {
			CancelSelectTextDraw(playerid);
			PlayerTextDrawHide(playerid, fondTD);
			PlayerTextDrawHide(playerid, petitechelleTD);
			PlayerTextDrawHide(playerid, grandechelleTD);
			PlayerTextDrawHide(playerid, planchesTD);
			PlayerTextDrawHide(playerid, cabaneTD);
			PlayerTextDrawHide(playerid, fermerTD);
			PlayerTextDrawHide(playerid, batonTD);
			igEchelle = dini_Int(pfileName, "igEchelle");
			dini_IntSet(pfileName, "igEchelle", igEchelle+1);
			dini_IntSet(pfileName, "iPlanches", iPlanches-5);
  			SendClientMessage(playerid, COLOR_GREEN, "Tu as reçu une petite échelle en échange de 5 planches.");
		}
		else SendClientMessage(playerid, COLOR_RED, "Tu as besoin de 5 planches pour fabriquer une grande échelle.");
    }
    
    else if(playertextid == planchesTD)
    {
        new pfileName[48], pName[MAX_PLAYER_NAME], iArbre, iPlanches;
        GetPlayerName(playerid, pName, sizeof(pName));
        format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
		iArbre = dini_Int(pfileName, "iArbre");
        if(iArbre >= 1)
        {
			CancelSelectTextDraw(playerid);
			PlayerTextDrawHide(playerid, fondTD);
			PlayerTextDrawHide(playerid, petitechelleTD);
			PlayerTextDrawHide(playerid, grandechelleTD);
			PlayerTextDrawHide(playerid, planchesTD);
			PlayerTextDrawHide(playerid, cabaneTD);
			PlayerTextDrawHide(playerid, fermerTD);
			PlayerTextDrawHide(playerid, batonTD);
			iPlanches = dini_Int(pfileName, "iPlanches");
			dini_IntSet(pfileName, "iPlanches", iPlanches+6);
			dini_IntSet(pfileName, "iArbre", iArbre-1);
  			SendClientMessage(playerid, COLOR_GREEN, "Tu as reçu 6 planches en échange d'un arbre.");
		}
		else SendClientMessage(playerid, COLOR_RED, "Tu dois avoir coupé un arbre pour recevoir des planches.");
    }
    
    else if(playertextid == cabaneTD)
    {
        new pfileName[48], pName[MAX_PLAYER_NAME], iPlanches, iCabane;
        GetPlayerName(playerid, pName, sizeof(pName));
        format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
		iPlanches = dini_Int(pfileName, "iPlanches");
        if(iPlanches >= 10)
        {
			CancelSelectTextDraw(playerid);
			PlayerTextDrawHide(playerid, fondTD);
			PlayerTextDrawHide(playerid, petitechelleTD);
			PlayerTextDrawHide(playerid, grandechelleTD);
			PlayerTextDrawHide(playerid, planchesTD);
			PlayerTextDrawHide(playerid, cabaneTD);
			PlayerTextDrawHide(playerid, fermerTD);
			PlayerTextDrawHide(playerid, batonTD);
			iCabane = dini_Int(pfileName, "iCabane");
			dini_IntSet(pfileName, "iCabane", iCabane+1);
			dini_IntSet(pfileName, "iPlanches", iPlanches-10);
  			SendClientMessage(playerid, COLOR_GREEN, "Tu as reçu une cabane en échange de 10 planches.");
		}
		else SendClientMessage(playerid, COLOR_RED, "Tu as besoin de 10 planches pour fabriquer une cabane.");
    }
    
    else if(playertextid == batonTD)
    {
        new pfileName[48], pName[MAX_PLAYER_NAME], iArbre, iBaton;
        GetPlayerName(playerid, pName, sizeof(pName));
        format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
		iArbre = dini_Int(pfileName, "iArbre");
        if(iArbre >= 1)
        {
			CancelSelectTextDraw(playerid);
			PlayerTextDrawHide(playerid, fondTD);
			PlayerTextDrawHide(playerid, petitechelleTD);
			PlayerTextDrawHide(playerid, grandechelleTD);
			PlayerTextDrawHide(playerid, planchesTD);
			PlayerTextDrawHide(playerid, cabaneTD);
			PlayerTextDrawHide(playerid, fermerTD);
			PlayerTextDrawHide(playerid, batonTD);
			iBaton = dini_Int(pfileName, "iBaton");
			dini_IntSet(pfileName, "iBaton", iBaton+10);
			dini_IntSet(pfileName, "iArbre", iArbre-1);
  			SendClientMessage(playerid, COLOR_GREEN, "Tu as reçu 10 bâtons en échange d'un arbre");
		}
		else SendClientMessage(playerid, COLOR_RED, "Tu dois avoir un arbre pour fabriquer 10 bâtons.");
    }
    
    else if(playertextid == fermerTD)
    {
        CancelSelectTextDraw(playerid);
        PlayerTextDrawHide(playerid, fondTD);
		PlayerTextDrawHide(playerid, petitechelleTD);
		PlayerTextDrawHide(playerid, grandechelleTD);
		PlayerTextDrawHide(playerid, planchesTD);
		PlayerTextDrawHide(playerid, cabaneTD);
		PlayerTextDrawHide(playerid, fermerTD);
		PlayerTextDrawHide(playerid, batonTD);
		
		PlayerTextDrawHide(playerid, bidonTD);
		PlayerTextDrawHide(playerid, coffreTD);
	}
	
	else if(playertextid == coffreTD)
	{
        new pfileName[48], pName[MAX_PLAYER_NAME], iLingotFer, iCoffre;
        GetPlayerName(playerid, pName, sizeof(pName));
        format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
		iLingotFer = dini_Int(pfileName, "iLingotFer");
        if(iLingotFer >= 5)
        {
			CancelSelectTextDraw(playerid);
			PlayerTextDrawHide(playerid, fondTD);
			PlayerTextDrawHide(playerid, fermerTD);
			PlayerTextDrawHide(playerid, coffreTD);
			PlayerTextDrawHide(playerid, bidonTD);
			iCoffre = dini_Int(pfileName, "iCoffre");
			dini_IntSet(pfileName, "iCoffre", iCoffre+1);
			dini_IntSet(pfileName, "iLingotFer", iLingotFer-5);
  			SendClientMessage(playerid, COLOR_GREEN, "Tu as reçu 1 coffre en échange de 5 lingots de fer.");
		}
		else SendClientMessage(playerid, COLOR_RED, "Tu dois avoir 5 lingots de fer pour fabriquer 1 coffre.");
    }
    
    else if(playertextid == bidonTD)
	{
        new pfileName[48], pName[MAX_PLAYER_NAME], iLingotFer;
        GetPlayerName(playerid, pName, sizeof(pName));
        format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
		iLingotFer = dini_Int(pfileName, "iLingotFer");
        if(iLingotFer >= 2)
        {
			CancelSelectTextDraw(playerid);
			PlayerTextDrawHide(playerid, fondTD);
			PlayerTextDrawHide(playerid, fermerTD);
			PlayerTextDrawHide(playerid, coffreTD);
			PlayerTextDrawHide(playerid, bidonTD);
   			//iBidonVide = dini_Int(pfileName, "iBidonVide");
   			dini_IntSet(pfileName, "iBidonType", 10);
			dini_IntSet(pfileName, "iLingotFer", iLingotFer-2);
  			SendClientMessage(playerid, COLOR_GREEN, "Tu as reçu 1 bidon en échange de 2 lingots de fer.");
		}
		else SendClientMessage(playerid, COLOR_RED, "Tu dois avoir 2 lingots de fer pour fabriquer 1 bidon.");
    }
	return 1;
}

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
	if(response)
	{
	    new strPos[128], strPos2[128];
	    format(strPos, 128, "OffsetX : %.2f | OffsetY : %.2f | OffsetZ : %i | RotX : %.2f | RotY : %.2f | RotZ : %.2f", fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ);
        format(strPos2, 128, "ScaleX : %.2f | ScaleY : %.2f | SclaeZ : %.2f", fScaleX, fScaleY, fScaleZ);
		SendClientMessage(playerid, COLOR_TURQUOISE, strPos);
		SendClientMessage(playerid, COLOR_TURQUOISE, strPos2);
	}
	return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    SetPlayerPosFindZ(playerid, fX, fY, fZ);
    return 1;
}

//Fonctions personnelles
forward ProxDetector(Float:radi, playerid, string[],col1,col2,col3,col4,col5);
public ProxDetector(Float:radi, playerid, string[],col1,col2,col3,col4,col5)
{
    if(IsPlayerConnected(playerid))
    {
        new Float:posx, Float:posy, Float:posz;
        new Float:oldposx, Float:oldposy, Float:oldposz;
        new Float:tempposx, Float:tempposy, Float:tempposz;
        GetPlayerPos(playerid, oldposx, oldposy, oldposz);
        //radi = 2.0; //Trigger Radius
        for(new i = 0; i < MAX_PLAYERS; i++)
        {
            if(IsPlayerConnected(i) && (GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i)))
            {
                GetPlayerPos(i, posx, posy, posz);
                tempposx = (oldposx -posx);
                tempposy = (oldposy -posy);
                tempposz = (oldposz -posz);
                if (((tempposx < radi/5) && (tempposx > -radi/5)) && ((tempposy < radi/5) && (tempposy > -radi/5)) && ((tempposz < radi/5) && (tempposz > -radi/5)))
                {
                    SendClientMessage(i, col1, string);
                }
                else if (((tempposx < radi/4) && (tempposx > -radi/4)) && ((tempposy < radi/4) && (tempposy > -radi/4)) && ((tempposz < radi/4) && (tempposz > -radi/4)))
                {
                    SendClientMessage(i, col2, string);
                }
                else if (((tempposx < radi/3) && (tempposx > -radi/3)) && ((tempposy < radi/3) && (tempposy > -radi/3)) && ((tempposz < radi/3) && (tempposz > -radi/3)))
                {
                    SendClientMessage(i, col3, string);
                }
                else if (((tempposx < radi/2) && (tempposx > -radi/2)) && ((tempposy < radi/2) && (tempposy > -radi/2)) && ((tempposz < radi/2) && (tempposz > -radi/2)))
                {
                    SendClientMessage(i, col4, string);
                }
                else if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
                {
                    SendClientMessage(i, col5, string);
                }
            }
            else
            {
                SendClientMessage(i, col1, string);
            }
        }
	}
}

forward DelayKick(playerid, kickTimerID);
public DelayKick(playerid, kickTimerID)
{
	Kick(playerid);
	KillTimer(kickTimerID);
}

forward DelayLogin(playerid, loginTimerID);
public DelayLogin(playerid, loginTimerID)
{
    ShowPlayerDialog(playerid, 23, DIALOG_STYLE_PASSWORD, "Connexion", "Entrez votre mot de passe.", "Connexion", "Annuler");
    SetPlayerCameraPos(playerid, -2254.0400, 2085.8298, 56.8500);
	SetPlayerCameraLookAt(playerid, -2254.4351, 2086.7454, 56.6500);
	KillTimer(loginTimerID);
}

forward DelayRegister(playerid, registerTimerID);
public DelayRegister(playerid, registerTimerID)
{
    ShowPlayerDialog(playerid, 24, DIALOG_STYLE_PASSWORD, "Enregistrement", "Entrez votre mot de passe(ne pas entrer de mot de passe personnel, les admins le verront):", "Enregistrer", "Annuler");
    SetPlayerCameraPos(playerid, -2254.0400, 2085.8298, 56.8500);
	SetPlayerCameraLookAt(playerid, -2254.4351, 2086.7454, 56.6500);
	KillTimer(registerTimerID);
}

forward DelaySpawn(playerid, spawnTimerID);
public DelaySpawn(playerid, spawnTimerID)
{
    TogglePlayerSpectating(playerid, 0);
	SpawnPlayer(playerid);
}

forward s1Timer();
public s1Timer()
{
	//Véhicules
	new ovehiclenb[8], vehicleID;
	for(new vehnb = 1; vehnb <= 50; vehnb++)
	{
	    format(ovehiclenb, sizeof(ovehiclenb), "%i", vehnb);
		vehicleID = dini_Int("vehicules/allume.ini", ovehiclenb);
		if(vehicleID != 0)
		{
		    //Compteur HMH
		    new Float:v_vel[3], vString[16], Float:speed, playerid, hString[10];
			GetVehicleVelocity(vehicleID, v_vel[0], v_vel[1], v_vel[2]);
			if(v_vel[0] < 0) v_vel[0] = -(v_vel[0]);
			if(v_vel[1] < 0) v_vel[1] = -(v_vel[1]);
			if(v_vel[2] < 0) v_vel[2] = -(v_vel[2]);
			speed = (v_vel[0] + v_vel[1] + v_vel[2]) * 100;
			format(vString, sizeof(vString), "%.0f KM/H", speed);
			playerid = GetVehicleDriver(vehicleID);
			PlayerTextDrawSetString(playerid, compteurKMH, vString);
			//Dégâts
			GetVehicleHealth(vehicleID, vHealth);
			format(strDegat, sizeof(strDegat), "%.0f", vHealth);
			PlayerTextDrawSetString(playerid, degatTextDraw, strDegat);
			//Heure
			gettime(heure, minute, seconde);
			if(minute < 10) format(hString, sizeof(hString), "%i:0%i", heure, minute);
			else format(hString, sizeof(hString), "%i:%i", heure, minute);
			PlayerTextDrawSetString(playerid, heureTextDraw, hString);
			//Affiche les TD
			PlayerTextDrawShow(playerid, degatTextDraw);
			PlayerTextDrawShow(playerid, carburantTextDraw);
			PlayerTextDrawShow(playerid, heureTextDraw);
			PlayerTextDrawShow(playerid, compteurKMH);
		}
 	}
	return 1;
}

forward s3Timer();
public s3Timer()
{
	new VEHID, strNOMBRE[48];
	for(new nombreVEH = 0; nombreVEH <= 50; nombreVEH++)
	{
	    format(strNOMBRE, sizeof(strNOMBRE), "%i", nombreVEH);
		VEHID = dini_Int("vehicules/demarre.ini", strNOMBRE);
		if(VEHID != 0)
		{
		    new moteur, phares, alarme, portes, capot, coffre, objective, playerid;
			GetVehicleParamsEx(VEHID, moteur, phares, alarme, portes, capot, coffre, objective);
			SetVehicleParamsEx(VEHID, 1, phares, alarme, portes, capot, coffre, objective);
			playerid = GetVehicleDriver(VEHID);
			dini_IntSet("vehicules/demarre.ini", strNOMBRE, 0);
			PlayerTextDrawShow(playerid, degatTextDraw);
			PlayerTextDrawShow(playerid, carburantTextDraw);
			PlayerTextDrawShow(playerid, heureTextDraw);
			PlayerTextDrawShow(playerid, compteurKMH);
			PlayerTextDrawHide(playerid, demarreTD);
			SendClientMessage(playerid, COLOR_GREEN, "Ton véhicule est démarré.");
		}
	}
	return 1;
}

forward s30Timer();
public s30Timer()
{
	gettime(heure, minute, seconde);
	SetWorldTime(heure);
	//Arbres
    for(new arbreid = 0; arbreid <= 1000; arbreid++)
	{
	    new afileName[32], Float:a_pos[6], Aheure, Aminute, Amodelid, soucheid;
		format(afileName, sizeof(afileName), "arbres/%i.ini", arbreid);
		Aheure = dini_Int(afileName, "heure");
		Aminute = dini_Int(afileName, "minute");
		if(Aheure == heure && Aminute == minute)
		{
			soucheid = dini_Int(afileName, "soucheid");
			DestroyObject(soucheid);
	    	Amodelid = dini_Int(afileName, "modelid");
			a_pos[0] = dini_Float(afileName, "posX");
			a_pos[1] = dini_Float(afileName, "posY");
			a_pos[2] = dini_Float(afileName, "posZ");
			a_pos[3] = dini_Float(afileName, "rotX");
			a_pos[4] = dini_Float(afileName, "rotY");
			a_pos[5] = dini_Float(afileName, "rotZ");
			arbreid = CreateObject(Amodelid, a_pos[0], a_pos[1], a_pos[2], a_pos[3], a_pos[4], a_pos[5], 30000);
			dini_Remove(afileName);
			format(afileName, sizeof(afileName), "arbres/%i.ini", arbreid);
			dini_Create(afileName);
			dini_IntSet(afileName, "soucheid", 9999);
			dini_IntSet(afileName, "modelid", Amodelid);
			dini_IntSet(afileName, "coupe", 0);
			dini_FloatSet(afileName, "posX", a_pos[0]);
			dini_FloatSet(afileName, "posY", a_pos[1]);
			dini_FloatSet(afileName, "posZ", a_pos[2]);
			dini_FloatSet(afileName, "rotX", a_pos[3]);
			dini_FloatSet(afileName, "rotY", a_pos[4]);
			dini_FloatSet(afileName, "rotZ", a_pos[5]);
			goto suite30s1;
		}
	}
	suite30s1:
	//Carburant
	for(new vehNB; vehNB <= 50; vehNB++)
	{
	    new vehicleNB[5], Idveh;
		format(vehicleNB, sizeof(vehicleNB), "%i", vehNB);
		Idveh = dini_Int("vehicules/allume.ini", vehicleNB);
		if(Idveh != 0)
		{
		    new vehfileName[32], carString[32], vcarburant, vcurCarburant, playerid;
		    playerid = GetVehicleDriver(Idveh);
			format(vehfileName, sizeof(vehfileName), "vehicules/%i.ini", Idveh);
 			vcarburant = dini_Int(vehfileName, "maxCar");
 			vcurCarburant = dini_Int(vehfileName, "curCar");
 			if(vcurCarburant >= 1)
 			{
				vcurCarburant = vcurCarburant - 1;
 				dini_IntSet(vehfileName, "curCar", vcurCarburant);
 				format(carString, sizeof(carString), "%i/%i", vcurCarburant, vcarburant);
 				PlayerTextDrawSetString(playerid, carburantTextDraw, carString);
				goto suite30s2;
			}
			if(vcurCarburant < 1)
			{
		    	new cmoteur, cphares, calarme, cportes, ccapot, ccoffre, cobjective;
		    	dini_IntSet("vehicules/allume.ini", vehicleNB, 0);
		    	PlayerTextDrawHide(playerid, degatTextDraw);
				PlayerTextDrawHide(playerid, carburantTextDraw);
				PlayerTextDrawHide(playerid, heureTextDraw);
				PlayerTextDrawHide(playerid, compteurKMH);
		    	GetVehicleParamsEx(Idveh, cmoteur, cphares, calarme, cportes, ccapot, ccoffre, cobjective);
   	    		SetVehicleParamsEx(Idveh, 0, cphares, calarme, cportes, ccapot, ccoffre, cobjective);
				goto suite30s2;
			}
		}
	}
	suite30s2:
	//Radiations
	for(new playerid; playerid <= MAX_PLAYERS; playerid++)
	{
	    new pfileName[48], pName[MAX_PLAYER_NAME], radLevel;
	    GetPlayerName(playerid, pName, sizeof(pName));
	    format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
		radLevel = dini_Int(pfileName, "radlevel");
	    if(radLevel >= 100)
		{
			new Float:pHealth;
			dini_IntSet(pfileName, "radLevel", 100);
			radLevel = 100;
			PlayerTextDrawHide(playerid, barRadTD);
			PlayerTextDrawTextSize(playerid, barRadTD, 56, 5.5);
			PlayerTextDrawShow(playerid, barRadTD);
			GetPlayerHealth(playerid, pHealth);
			SetPlayerHealth(playerid, pHealth - (random(10) + 7));
			goto suite30s3;
		}
	    if(IsPlayerInRangeOfPoint(playerid, 3800.0, 2650.0, -2116.0, 15.0))
	    {
			new Float:radSize, Float:distance, masque, radDamage;
			masque = dini_Int(pfileName, "masque");
			if(masque == 1) goto suite30s3;
			distance = GetPlayerDistanceFromPoint(playerid, 2650.0, -2116.0, 15.0);
			if(distance < 400) radDamage = 40;
			else if(distance >= 500 && distance < 1000) radDamage = 35;
			else if(distance >= 1000 && distance < 1500) radDamage = 30;
			else if(distance >= 1500 && distance < 2000) radDamage = 25;
			else if(distance >= 2000 && distance < 2500) radDamage = 20;
			else if(distance >= 2500 && distance < 3000) radDamage = 15;
			else if(distance >= 3000 && distance < 3500) radDamage = 10;
			else radDamage = 5;
			radLevel = radLevel + radDamage;
	    	if(radLevel >= 100)
			{
				new Float:pHealth;
				dini_IntSet(pfileName, "radLevel", 100);
				radLevel = 100;
				GetPlayerHealth(playerid, pHealth);
				SetPlayerHealth(playerid, pHealth - (random(10) + 7));
				goto suite30s3;
			}
			dini_IntSet(pfileName, "radLevel", radLevel);
			radSize = radLevel * 56 / 100;
			PlayerTextDrawHide(playerid, barRadTD);
			PlayerTextDrawTextSize(playerid, barRadTD, radSize, 5.5);
			PlayerTextDrawShow(playerid, barRadTD);
			SendClientMessage(playerid, COLOR_RAD_DAMAGE, "Attention ! Tu es dans une zone infectée, mets un masque.");
			goto suite30s3;
		}
	}
	suite30s3:
	return 1;
}

forward BarrageLaunch(PlayerText:chargementTD, PlayerText:activationTD, PlayerText:filtrageTD);
public BarrageLaunch(PlayerText:chargementTD, PlayerText:activationTD, PlayerText:filtrageTD)
{
	new strpSlot[16], playerid;
	for(new playerSlot; playerSlot <= 15; playerSlot++)
	{
	    format(strpSlot,sizeof(strpSlot), "%i", playerSlot);
	    playerid = dini_Int("barrage.ini", strpSlot);
	    if(dini_Int("barrage.ini", strpSlot) != 999)
	    {
			new barCar, barStatus;
			barCar = dini_Int("barrage.ini", "barCar");
			barStatus = dini_Int("barrage.ini", "barStatus");
			if(barCar >= 10) dini_IntSet("barrage.ini", "barCar", barCar-10);
			if(barStatus == 1)
			{
	   			dini_IntSet("barrage.ini", "barStatus", 2);
	    		PlayerTextDrawSetString(playerid, chargementTD, "~g~O ~w~Chargement du carburant");
	    		PlayerTextDrawSetString(playerid, activationTD, "~y~O ~w~Activation des pompes");
			}
			else if(barStatus == 2)
			{
	   			dini_IntSet("barrage.ini", "barStatus", 3);
	    		PlayerTextDrawSetString(playerid, activationTD, "~g~O ~w~Activation des pompes");
	    		PlayerTextDrawSetString(playerid, filtrageTD, "~y~O ~w~Filtrage de l'eau");
   			}
   			else if(barStatus == 3)
			{
			    new barEau;
	   			dini_IntSet("barrage.ini", "barStatus", 4);
			    barEau = dini_Int("barrage.ini", "barEau");
	   			dini_IntSet("barrage.ini", "barEau", barEau+5);
	    		PlayerTextDrawSetString(playerid, filtrageTD, "~g~O ~w~Filtrage de l'eau");
				SendClientMessage(playerid, COLOR_GREEN, "Le barrage a récupéré et filtré 5L d'eau qui ont été versé dans la réserve.");
   			}
   			else if(barStatus == 4)
			{
	   			dini_IntSet("barrage.ini", "barStatus", 0);
				PlayerTextDrawHide(playerid, chargementTD);
				PlayerTextDrawDestroy(playerid, chargementTD);
				PlayerTextDrawHide(playerid, activationTD);
				PlayerTextDrawDestroy(playerid, activationTD);
				PlayerTextDrawHide(playerid, filtrageTD);
				PlayerTextDrawDestroy(playerid, filtrageTD);
				dini_IntSet("barrage.ini", strpSlot, 999);
				KillTimer(timerBarrageID);
   			}
	    }
 	}
}

stock RemovePlayerWeapon(playerid, weaponid)
{
	new plyWeapons[12];
	new plyAmmo[12];

	for(new slot = 0; slot != 12; slot++)
	{
		new wep, ammo;
		GetPlayerWeaponData(playerid, slot, wep, ammo);

		if(wep != weaponid)
		{
			GetPlayerWeaponData(playerid, slot, plyWeapons[slot], plyAmmo[slot]);
		}
	}

	ResetPlayerWeapons(playerid);
	for(new slot = 0; slot != 12; slot++)
	{
		GivePlayerWeapon(playerid, plyWeapons[slot], plyAmmo[slot]);
	}
}

/*
===================================Script des aides
*/
CMD:aide(playerid)
{
    SendClientMessage(playerid, COLOR_YELLOW, "Liste des aides");
	SendClientMessage(playerid, COLOR_CMD, "/aideveh <- Aide à propos des véhicules");
	SendClientMessage(playerid, COLOR_CMD, "/aidechat <- Aide à propos du chat");
	SendClientMessage(playerid, COLOR_CMD, "/aidegenerale <- Commandes générales");
	SendClientMessage(playerid, COLOR_CMD, "/aidetele <- Liste des points de téléportation");
	SendClientMessage(playerid, COLOR_CMD, "/aideterrain <- Aide à propos du mapping(commandes admins)");
	SendClientMessage(playerid, COLOR_CMD, "/aideanim <- Liste des animations");
	SendClientMessage(playerid, COLOR_CMD, "/aidemaison <- Commandes de biz et de maisons");
	SendClientMessage(playerid, COLOR_CMD, "/aidejob <- Commandes communes aux jobs");
	SendClientMessage(playerid, COLOR_CMD, "/aidebois <- Commandes pour les bûcherons");
	SendClientMessage(playerid, COLOR_CMD, "/aidesoigneur <- Commandes pour les soigneurs");
	SendClientMessage(playerid, COLOR_CMD, "/aidemineur <- Commandes pour les mineurs");
	return 1;
}

CMD:aideanim(playerid)
{
    SendClientMessage(playerid, COLOR_YELLOW, "Liste des animations");
	SendClientMessage(playerid, COLOR_CMD, "/assis [1-7]      |      /pose [1-3]      |      /coucher [1-2]");
	SendClientMessage(playerid, COLOR_CMD, "/masturber        |      /pisser [1-2]    |      /fumer [1-2]");
	return 1;
}
CMD:aideveh(playerid)
{
    SendClientMessage(playerid, COLOR_YELLOW, "Aide véhicules");
	SendClientMessage(playerid, COLOR_CMD, "/veh <- Ouvre le menu d'achat de véhicules au concessionnaire(\"/concess\"");
	SendClientMessage(playerid, COLOR_CMD, "/vvendre <- Vendre le véhicule à n'importe quel endroit");
	SendClientMessage(playerid, COLOR_CMD, "/des <- Détruit le véhicule(ne pas le faire avec un véhicule acheté au concessionnaire)");
	SendClientMessage(playerid, COLOR_CMD, "/rep <- Répare le véhicule");
	SendClientMessage(playerid, COLOR_CMD, "Touche \"Y\"<- Démarrer/Eteindre le véhicule");
	SendClientMessage(playerid, COLOR_CMD, "Touche \"é/2\"<- Allume/Etient les phares de votre véhicule");
	SendClientMessage(playerid, COLOR_CMD, "Touche \"N\"<- Verrouiller/Déverrouiller le véhicule");
	SendClientMessage(playerid, COLOR_CMD, "/plaque [texte] <- Change la plaque de votre véhicule");
	SendClientMessage(playerid, COLOR_CMD, "/capot <- Ouvre/Ferme le capot de votre véhicule");
	SendClientMessage(playerid, COLOR_CMD, "/coffre <- Ouvre/Ferme le coffre de votre véhicule");
	SendClientMessage(playerid, COLOR_CMD, "/color [ID couleur 1] [ID couleur 2] <- Change la couleur de votre véhicule");
	SendClientMessage(playerid, COLOR_CMD, "/remplir [litres] <- Remplit votre véhicule avec le nombre ");
	SendClientMessage(playerid, COLOR_CMD, "Les véhicules que vous avez acheté respawn à l'endroit où ils étaient quand le serveur a reboot.");
	return 1;
}

CMD:aidechat(playerid)
{
    SendClientMessage(playerid, COLOR_YELLOW, "Aide Chat");
	SendClientMessage(playerid, COLOR_CMD, "/me [action]");
	SendClientMessage(playerid, COLOR_CMD, "/do [texte]");
	SendClientMessage(playerid, COLOR_CMD, "/b [texte] <- Canal local OOC");
	SendClientMessage(playerid, COLOR_CMD, "/g [texte] <- Canal global OOC");
	SendClientMessage(playerid, COLOR_CMD, "/c [texte] <- Permet de crier");
	SendClientMessage(playerid, COLOR_CMD, "/chu [texte] <- Permet de chuchoter");
	SendClientMessage(playerid, COLOR_CMD, "/r [message] <- Permet de parler en radio");
	SendClientMessage(playerid, COLOR_CMD, "/frequence [fréquence] <- Permet de régler la fréquence de votre radio");
	return 1;
}

CMD:aidegenerale(playerid)
{
    SendClientMessage(playerid, COLOR_YELLOW, "Aide générale");
	SendClientMessage(playerid, COLOR_CMD, "/heal <- Permet de remettre sa vie au maximum");
    SendClientMessage(playerid, COLOR_CMD, "/gilet <- Permet de (re)mettre un gilet pare-balles neuf");
    SendClientMessage(playerid, COLOR_CMD, "/kill <- Vous tue");
    SendClientMessage(playerid, COLOR_CMD, "/skin [ID du skin (0->299)] <- Change votre skin");
    SendClientMessage(playerid, COLOR_CMD, "/jetpack [on/off] <-Equiper/Deséquiper Jetpack");
	return 1;
}

CMD:aidetele(playerid)
{
	SendClientMessage(playerid, COLOR_YELLOW, "Téléportations");
    SendClientMessage(playerid, COLOR_CMD, "/tpon <- Autorise les joueurs à se téléporter sur vous");
    SendClientMessage(playerid, COLOR_CMD, "/tpoff <- Désactive la téléportation sur vous");
	SendClientMessage(playerid, COLOR_CMD, "/tp [ID du joueur] <- Vous téléporte au joueur séléctionné");
	SendClientMessage(playerid, COLOR_CMD, "/changerspawn <- Change l'emplacement de votre spawn à votre position actuelle");
	SendClientMessage(playerid, COLOR_CMD, "/spawn <- Votre point de spawn");
	SendClientMessage(playerid, COLOR_CMD, "/pizzeria <- Pizzeria d'Iddlewood");
	SendClientMessage(playerid, COLOR_CMD, "/ammu1 <- Ammu-nation centre");
	SendClientMessage(playerid, COLOR_CMD, "/ammu2 <- Petite Ammu-nation");
	SendClientMessage(playerid, COLOR_CMD, "/banque <- Banque");
	SendClientMessage(playerid, COLOR_CMD, "/ville <- Ville RolePlay");
	SendClientMessage(playerid, COLOR_CMD, "/airport1 <- Aéroport de Los Santos");
	SendClientMessage(playerid, COLOR_CMD, "/airport2 <- Aéroport de San Fierro(endroit de spawn des avions)");
	SendClientMessage(playerid, COLOR_CMD, "/concess <- Concessionnaire");
	SendClientMessage(playerid, COLOR_CMD, "/fonderie <- Fonderie");
	SendClientMessage(playerid, COLOR_CMD, "/bois <- Arbres à couper");
	return 1;
}

CMD:aidebanque(playerid)
{
    SendClientMessage(playerid, COLOR_YELLOW, "Aide banque");
	SendClientMessage(playerid, COLOR_CMD, "/argent <- Afficher le solde de votre compte");
	SendClientMessage(playerid, COLOR_CMD, "/deposer [montant] <- Déposer de l'argent sur votre compte en banque");
	SendClientMessage(playerid, COLOR_CMD, "/retirer [montant] <- Récupèrer de l'argent");
	SendClientMessage(playerid, COLOR_CMD, "/payer [ID du joueur] [montant] <- Donner de l'argent à une personne proche de vous");
	SendClientMessage(playerid, COLOR_CMD, "/gargent [montant] <- Vous donne de l'argent");
	return 1;
}

CMD:aideterrain(playerid)
{
    SendClientMessage(playerid, COLOR_YELLOW, "Aide terrain(commandes administrateur pour le moment)");
	SendClientMessage(playerid, COLOR_CMD, "/placer [ID de l'objet] <- Place un objet sur votre position");
	SendClientMessage(playerid, COLOR_CMD, "/modifier <- Permet de sélectionner un objet avec votre curseur");
	SendClientMessage(playerid, COLOR_CMD, "\"ECHAP\" lors de l'édition pour supprimer un object");
	SendClientMessage(playerid, COLOR_CMD, "/supprimer [ID de l'objet] <- Supprime l'objet avec l'ID correspondant");
	SendClientMessage(playerid, COLOR_CMD, "/cbat [Modèle de pickup] [Numéro de la maison] [Prix d'achat(inutile pour les bat' publics)] [Type de batiment(public, maison, biz)]<- Crée un batiment à ta position");
	SendClientMessage(playerid, COLOR_CMD, "/desbat <- Supprime le bâtiment à ta position");
	SendClientMessage(playerid, COLOR_CMD, "/cfg [Numéro de la maison] [InteriorID] [Pos X] [Pos Y] [Pos Z] <- Permet de configurer les intérieurs avec les paramètres de \"http://so6.eu/interior.html\"");
	return 1;
}

CMD:aidemaison(playerid)
{
    SendClientMessage(playerid, COLOR_YELLOW, "Aide maison");
	SendClientMessage(playerid, COLOR_CMD, "/bat [acheter | nom | vendre] <- Actions possibles sur un bâtiment");
	return 1;
}

CMD:aideadmin(playerid)
{
    SendClientMessage(playerid, COLOR_YELLOW, "Aide Admin");
    SendClientMessage(playerid, COLOR_CMD, "/desall <- Supprime tous les véhicules");
    SendClientMessage(playerid, COLOR_CMD, "/carbre <- Crée un arbre coupable");
    SendClientMessage(playerid, COLOR_CMD, "/deparbre <- Permet de déplacer un arbre coupable");
    SendClientMessage(playerid, COLOR_CMD, "/desarbre <- Détruit l'arbre lorsque vous êtes à proximité");
    SendClientMessage(playerid, COLOR_CMD, "/team [ID du joueur] [ID de la team] <- Met un job/team à un joueur");
    SendClientMessage(playerid, COLOR_CMD, "/nom [Nouveau nom] <- Change ton nom(les stats ne seront plus les tiennes)");
    SendClientMessage(playerid, COLOR_CMD, "/time [heure] <- Change l'heure(jusqu'à la prochaine update toutes les 30 sec)");
    SendClientMessage(playerid, COLOR_CMD, "/cop [ID de l'objet]<- Crée un objet en mouvement(pas au point du tout)");
    SendClientMessage(playerid, COLOR_CMD, "/rem [ID du model] <- Supprime l'objet à proximité s'il a le modelID indiqué");
    SendClientMessage(playerid, COLOR_CMD, "/desarme [ID du joueur] <- Supprime les armes du joueur indiqué");
    SendClientMessage(playerid, COLOR_CMD, "/setvw [ID du joueur] [VirtualWorld] <- Change le Virtual World du joueur indiqué");
    SendClientMessage(playerid, COLOR_CMD, "/cbat [Modèle de pickup] [Numéro de la maison] [Prix d'achat(inutile pour les bat' publics)] [Type de batiment(public, maison, biz)]<- Crée un batiment à ta position");
	SendClientMessage(playerid, COLOR_CMD, "/desbat <- Supprime le bâtiment à ta position");
	SendClientMessage(playerid, COLOR_CMD, "/cfg [Numéro de la maison] [InteriorID] [Pos X] [Pos Y] [Pos Z] <- Permet de configurer les intérieurs avec les paramètres de \"http://so6.eu/interior.html\"");
	return 1;
}

CMD:aidejob(playerid)
{
	SendClientMessage(playerid, COLOR_YELLOW, "Aide jobs");
    SendClientMessage(playerid, COLOR_CMD, "/job [Bucheron | Soigneur] <- Choisir son job");
    SendClientMessage(playerid, COLOR_CMD, "/equiper <- Vous équipe selon votre job");
	return 1;
}

CMD:aidebois(playerid)
{
    SendClientMessage(playerid, COLOR_YELLOW, "Aide bois");
	SendClientMessage(playerid, COLOR_CMD, "/bois <- Téléportation au bon endroit");
	SendClientMessage(playerid, COLOR_CMD, "/couper <- Coupe un arbre");
	SendClientMessage(playerid, COLOR_CMD, "/menuiserie <- Ouvre le menu d'achat de la menuiserie");
	return 1;
}

CMD:aidesoigneur(playerid)
{
    SendClientMessage(playerid, COLOR_YELLOW, "Aide soigneur");
	SendClientMessage(playerid, COLOR_CMD, "/soigner [ID du joueur] <- Soigner un joueur");
	return 1;
}

CMD:aidemineur(playerid)
{
    SendClientMessage(playerid, COLOR_YELLOW, "Aide mineur");
	SendClientMessage(playerid, COLOR_CMD, "/miner [minerai] <- Miner un minerai");
    SendClientMessage(playerid, COLOR_CMD, "/broyer [nombre de pierres] <- Broyer un certain nombre de pierres(/broyer pour plus d'informations)");
	return 1;
}

/*
===================================Script de la banque
*/
CMD:argent(playerid)
{
    new pName[MAX_PLAYER_NAME], fileName[28], string[128];   //Initialisation des variables
	GetPlayerName(playerid, pName, sizeof(pName));  //Prend le nom du joueur
	format (fileName, sizeof(fileName), "players/%s.ini", pName);   //Indique la localisation du fichier
	new bArgent = dini_Int(fileName,"bArgent");   //Va chercher l'argent du joueur
	format (string, sizeof(string), "Tu as %i$ sur ton compte en banque.", bArgent);
	SendClientMessage(playerid, COLOR_TURQUOISE, string);
	return 1;
}

CMD:gargent(playerid, params[])
{
	new montant = strval(params), string[128], pName[MAX_PLAYER_NAME], fileName[64], pMoney;
	pMoney = GetPlayerMoney(playerid);
	if(montant + pMoney > 999999999) return SendClientMessage(playerid, COLOR_RED, "Montant trop élevé");
	if(montant<999999999 && montant>0)
	{
		GetPlayerName(playerid, pName, sizeof(pName));
		format (fileName, sizeof(fileName), "players/%s.ini", pName);
		GivePlayerMoney(playerid, montant);
		dini_IntSet(fileName, "iArgent", montant);
		format(string, sizeof(string), "Tu as reçu %i$", montant);
		SendClientMessage(playerid, COLOR_GREEN, string);
 	}
 	else SendClientMessage(playerid, COLOR_RED, "Montant trop élevé");
	return 1;
}

CMD:deposer(playerid, params[])
{
	if(IsPlayerInRangeOfPoint(playerid, 20.0, 1722.5808, -1655.5, 20.9))
	{
    	if (isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/deposer [montant]\"");
    	new pName[MAX_PLAYER_NAME], fileName[28], string[128];
		GetPlayerName(playerid, pName, sizeof(pName));
		format (fileName, sizeof(fileName), "players/%s.ini", pName);
 		new iArgent = GetPlayerMoney(playerid);
 		new dArgent = strval(params);
 		if (dArgent < 0) return SendClientMessage(playerid, COLOR_RED, "Le montant ne peut pas être négatif.");
		if(dArgent <= iArgent)
		{
			new bArgent = dini_Int(fileName, "bArgent");
			GivePlayerMoney(playerid, -dArgent);
			new tArgent = bArgent + dArgent;
			dini_IntSet(fileName, "bArgent", tArgent);
			iArgent = GetPlayerMoney(playerid);
			dini_IntSet(fileName, "iArgent", iArgent);
			format(string, sizeof(string), "Montant déposé : %i$ | Ancien solde : %i$ | Nouveau Solde : %i$", dArgent, bArgent, tArgent);
			SendClientMessage(playerid, COLOR_TURQUOISE, string);
		}
		else
		{
	    SendClientMessage(playerid, COLOR_RED, "Tu n'as pas suffisament d'argent sur toi.");
		}
	}
	else
	{
	    SendClientMessage(playerid, COLOR_RED, "Tu n'es pas à la banque. Utilise \"/banque\" pour y aller");
	}
	return 1;
}

CMD:retirer(playerid, params[])
{
    if(IsPlayerInRangeOfPoint(playerid, 20.0, 1722.5808, -1655.5, 20.9))
	{
    	if (isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/retirer [montant]\"");
    	new pName[MAX_PLAYER_NAME], fileName[28], string[128];
		GetPlayerName(playerid, pName, sizeof(pName));
		format (fileName, sizeof(fileName), "players/%s.ini", pName);
 		new iArgent = GetPlayerMoney(playerid);
 		new bArgent = dini_Int(fileName, "bArgent");
 		new rArgent = strval(params);
 		if (rArgent < 0) return SendClientMessage(playerid, COLOR_RED, "Le montant ne peut pas être négatif.");
		if(rArgent < bArgent)
		{
			GivePlayerMoney(playerid, rArgent);
			new tArgent = bArgent - rArgent;
			dini_IntSet(fileName, "bArgent", tArgent);
			iArgent = GetPlayerMoney(playerid);
			dini_IntSet(fileName, "iArgent", iArgent);
			format(string, sizeof(string), "Montant retiré : %i$ | Ancien solde : %i$ | Nouveau Solde : %i$", rArgent, bArgent, tArgent);
			SendClientMessage(playerid, COLOR_TURQUOISE, string);
		}
		else
		{
	    	SendClientMessage(playerid, COLOR_RED, "Tu n'as pas suffisament d'argent sur ton compte en banque.");
		}
	}
	else
	{
	    SendClientMessage(playerid, COLOR_RED, "Tu n'es pas à la banque. Utilise \"/banque\" pour y aller");
	}
	return 1;
}

/*
===================================Script Général
*/
CMD:nom(playerid, params[])
{
	if(IsPlayerAdmin(playerid) == 1)
	{
		new string[32];
		format(string, sizeof(string),"%s", params);
		SetPlayerName(playerid, string);
		SendClientMessage(playerid, COLOR_GREEN, "Nom changé");
	}
	return 1;
}

CMD:heal(playerid, params[])
{
	if (isnull(params))
	{
	    SetPlayerHealth(playerid, 100);
	}
	else if (IsPlayerAdmin(playerid))
	{
	    new healid = strval(params);
	    SetPlayerHealth(healid, 100);
	    SendClientMessage(healid, COLOR_TURQUOISE, "Tu as été soigné par un administrateur.");
	}
	return 1;
}

CMD:gilet(playerid, params[])
{
	if (isnull(params))
	{
	    SetPlayerArmour(playerid, 100);
	}
	else if (IsPlayerAdmin(playerid))
	{
	    new giletid = strval(params);
	    SetPlayerArmour(giletid, 100);
	    SendClientMessage(giletid, COLOR_TURQUOISE, "Un administrateur t'a mis un gilet neuf.");
	}
	return 1;
}

CMD:skin(playerid, params[])
{
	new skinid = strval(params);
 	if (isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/skin [ID du skin(0->299)]\"");
	else if (skinid>299 || skinid < 0) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/skin [ID du skin(0->299)]\"");
    new string[128];
	SetPlayerSkin(playerid, skinid);
	format (string, sizeof(string), "Tu as désormais le skin %i", skinid);
	SendClientMessage(playerid, COLOR_GREEN, string);
    new pName[MAX_PLAYER_NAME], fileName[28];
	GetPlayerName(playerid, pName, sizeof(pName));
	format (fileName, sizeof(fileName), "players/%s.ini", pName);
	dini_IntSet(fileName, "Skin", skinid);
	return 1;
}

CMD:kill(playerid, params[])
{
	if (isnull(params))
	{
	    SetPlayerHealth(playerid, -1);
	}
	else if (IsPlayerAdmin(playerid))
	{
	    new killid = strval(params);
	    SetPlayerHealth(killid, 0);
	    SendClientMessage(killid, COLOR_TURQUOISE, "Tu as été tué par un administrateur.");
	}
	return 1;
}

CMD:changerspawn(playerid)
{
	new Float:x, Float:y, Float:z, pName[MAX_PLAYER_NAME], fileName[28], virtualWorld;
	GetPlayerPos(playerid, x, y, z);
	new interior = GetPlayerInterior(playerid);
	GetPlayerName(playerid, pName, sizeof(pName));
	virtualWorld = GetPlayerVirtualWorld(playerid);
	format (fileName, sizeof(fileName), "players/%s.ini", pName);
	dini_FloatSet(fileName, "SpawnX", x);
	dini_FloatSet(fileName, "SpawnY", y);
	dini_FloatSet(fileName, "SpawnZ", z);
	dini_IntSet(fileName, "SpawnI", interior);
	dini_IntSet(fileName, "SpawnVW", virtualWorld);
	SendClientMessage(playerid, COLOR_GREEN, "Spawn changé! Utilise \"/spawn\" pour y aller.");
	return 1;
}

CMD:spawn(playerid)
{
    SpawnPlayer(playerid);
	return 1;
}

CMD:time(playerid, time[])
{
	heure = strval(time);
	SetWorldTime(heure);
	return 1;
}

CMD:accepter(playerid, params[])
{
	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/accepter [vente | reparer | soigner]\"");
	new msgPlayer[64], msgTele[64], vehicleid, teleid, montant, pfileName[MAX_PLAYER_NAME + 15], tfileName[MAX_PLAYER_NAME + 15], pName[MAX_PLAYER_NAME], tName[MAX_PLAYER_NAME], pMoney;
	GetPlayerName(playerid, pName, sizeof(pName));//Acheteur
	GetPlayerName(playerid, tName, sizeof(tName));//Vendeur
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	format(tfileName, sizeof(tfileName), "players/%s.ini", tName);
	vehicleid = dini_Int(pfileName, "accVehicleID");
	teleid = dini_Int(pfileName, "accVendeurID");
	montant = dini_Int(pfileName, "accMontant");
	pMoney = GetPlayerMoney(playerid);
	if(pMoney - montant < 0) return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas assez d'argent sur toi.");
	//Accepter vendre à
	if(strcmp(params, "vente", true) == 0)
	{
  		new p2fileName[MAX_PLAYER_NAME + 15], p3fileName[MAX_PLAYER_NAME + 15], vfileName[48], string[48], vehiclenb[15], vehnb;
		if(teleid == 999) return SendClientMessage(playerid, COLOR_RED, "Personne ne t'a proposé de véhicule.");
		format(vfileName, sizeof(vfileName), "vehicules/%i.ini", vehicleid);
		vehnb = dini_Int(vfileName, "vehiclenb");
		format(vehiclenb, sizeof(vehiclenb), "vehicle%i", vehnb);
		//Enlève le véhicule au vendeur(tele)
		montant = dini_Int(pfileName, "accMontant");
		GivePlayerMoney(teleid, montant);
		GivePlayerMoney(playerid, -montant);
		dini_IntSet(tfileName, vehiclenb, 0);
		//Ajoute le véhicule à l'acheteur(player)
		dini_Set(vfileName, "proprio1", pName);
		dini_Set(vfileName, "proprio2", "Aucun");
		dini_Set(vfileName, "proprio3", "Aucun");
		//Proprio 1 <-- Ajoute le véhicule au proprio 1
		for(new vid = 1; vid <= 10; vid++)
		{
	    	format(string, sizeof(string), "vehicle%i", vid);
			new vnb = dini_Int(pfileName, string);
			if (vnb == 0)
			{
				dini_IntSet(pfileName, string, vehicleid);
				dini_IntSet(vfileName, "vehiclenb", vid);
				break;
			}
		}
		//Proprio 2 <-- Enlève le véhicule du proprio actuel
		format(p2fileName, sizeof(p2fileName), "players/%s.ini", dini_Get(vfileName, "proprio2"));
		for(new vid = 1; vid <= 10; vid++)
		{
	    	format(string, sizeof(string), "vehicle%i", vid);
			new vnb = dini_Int(p2fileName, string);
			if (vnb == vehicleid)
			{
				dini_IntSet(p2fileName, string, 0);
				break;
			}
		}
		//Proprio 3
		format(p3fileName, sizeof(p3fileName), "players/%s.ini", dini_Get(vfileName, "proprio3"));
		for(new vid = 1; vid <= 10; vid++)
		{
	    	format(string, sizeof(string), "vehicle%i", vid);
			new vnb = dini_Int(p3fileName, string);
			if (vnb == vehicleid)
			{
				dini_IntSet(p3fileName, string, vehicleid);
				break;
			}
		}
		//Envoie des messages à chaque joueur
		format(msgPlayer, sizeof(msgPlayer), "%s a acheté ton véhicule pour %i$.", tName, montant);
		format(msgTele, sizeof(msgTele), "Tu as acheté le véhicule de %s pour %i$.", pName, montant);
	}
	//Reparer
	else if(strcmp(params, "reparer", true) == 0)
	{
		if(teleid == 999) return SendClientMessage(playerid, COLOR_RED, "Personne ne t'a proposé de réparer ton véhicule.");
	    RepairVehicle(vehicleid);
	    GivePlayerMoney(playerid, -montant);
	    GivePlayerMoney(teleid, montant);
		format(msgPlayer, sizeof(msgPlayer), "%s a réparé ton véhicule pour %i$.", tName, montant);
		format(msgTele, sizeof(msgTele), "Tu as réparé le véhicule de %s pour %i$.", pName, montant);
	}
	//Soigner
	else if(strcmp(params, "soigner", true) == 0)
	{
		if(teleid == 999) return SendClientMessage(playerid, COLOR_RED, "Personne ne t'a proposé de soins.");
		
		dini_IntSet(tfileName, "Mort", 0);
		SetPlayerHealth(playerid, 100.0);
    	ClearAnimations(playerid);

		format(msgPlayer, sizeof(msgPlayer), "%s t'a soigné %i$.", tName, montant);
		format(msgTele, sizeof(msgTele), "Tu as soigné %s pour %i$.", pName, montant);
	}

	//Réinitialiser les valeurs d'acceptation
	dini_IntSet(pfileName, "accMontant", -1);
	dini_IntSet(pfileName, "accVehicleID", 0);
	dini_IntSet(pfileName, "accVendeurID", 999);
	SendClientMessage(playerid, COLOR_GREEN, msgPlayer);
	SendClientMessage(teleid, COLOR_GREEN, msgTele);
	return 1;
}

CMD:masque(playerid)
{
	new pfileName[48], pName[MAX_PLAYER_NAME], masque;
    GetPlayerName(playerid, pName, sizeof(pName));
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	masque = dini_Int(pfileName, "masque");
	if(masque == 0)
	{
		dini_IntSet(pfileName, "masque", 1);
		return SendClientMessage(playerid, COLOR_GREEN, "Tu as mis ton masque.");
	}
	else if(masque == 1)
	{
	    dini_IntSet(pfileName, "masque", 0);
		return SendClientMessage(playerid, COLOR_GREEN, "Tu as enlevé ton masque.");
	}
	else
	{
		return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas acheté de masque.");
	}
}

CMD:antidote(playerid)
{
    new pfileName[48], pName[MAX_PLAYER_NAME], iAntidotes;
    GetPlayerName(playerid, pName, sizeof(pName));
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	iAntidotes = dini_Int(pfileName, "iAntidotes");
	if(iAntidotes >= 0)
	{
	    dini_IntSet(pfileName, "radLevel", 0);
		PlayerTextDrawHide(playerid, barRadTD);
		PlayerTextDrawTextSize(playerid, barRadTD, 0.1, 5.5);
		PlayerTextDrawShow(playerid, barRadTD);
	    SendClientMessage(playerid, COLOR_GREEN, "Tu as pris une antidote, tu n'as plus de radiations.");
	}
	return 1;
}

/*
===================================Script Chat Local
*/
CMD:b(playerid, params[])
{
    if (isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/b [Texte]\"");
	new sendername[MAX_PLAYER_NAME], string[128];
    GetPlayerName(playerid, sendername, sizeof(sendername));
    format(string, sizeof(string), "(( %s: %s ))", sendername, params);
    ProxDetector(30.0, playerid, string, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4, COLOR_FADE5);
    return 1;
}

CMD:me(playerid, params[])
{
    if (isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/me [Texte]\"");
	new pname[24], str[128];
    GetPlayerName(playerid, pname, 24);
    format(str, sizeof(str), "%s %s", pname, params);
    ProxDetector(30.0, playerid, str, COLOR_VIOLET1, COLOR_VIOLET2, COLOR_VIOLET3, COLOR_VIOLET4, COLOR_VIOLET5);
    return 1;
}

CMD:do(playerid, params[])
{
    if (isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/do [Texte]\"");
	new pname[24], str[128];
    GetPlayerName(playerid, pname, 24);
    format(str, sizeof(str), "%s ((%s))", params, pname);
    ProxDetector(30.0, playerid, str, COLOR_VIOLET1, COLOR_VIOLET2, COLOR_VIOLET3, COLOR_VIOLET4, COLOR_VIOLET5);
    return 1;
}

CMD:c(playerid, params[])
{
    if (isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/c [Texte]\"");
	new pname[24], str[128];
    GetPlayerName(playerid, pname, 24);
    format(str, sizeof(str), "%s crie: %s", pname, params);
    ProxDetector(45.0, playerid, str, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4, COLOR_FADE5);
    return 1;
}

CMD:g(playerid, params[])
{
    if (isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/g [Texte]\"");
	new pname[24], str[128];
    GetPlayerName(playerid, pname, 24);
    format(str, sizeof(str), "[GLOBAL]%s : %s", pname, params);
    SendClientMessageToAll(COLOR_BLUE, str);
    return 1;
}

CMD:chu(playerid, params[])
{
    if (isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/chu [Texte]\"");
	new pname[24], str[128];
    GetPlayerName(playerid, pname, 24);
    format(str, sizeof(str), "%s chuchote: %s", pname, params);
    ProxDetector(5.0, playerid, str, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4, COLOR_FADE5);
    return 1;
}

CMD:frequence(playerid, params[])
{
	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/frequence [fréquence]\"");
	new freq, rfileName[16], pName[MAX_PLAYER_NAME], strSlot[10], strSlotMember[10], pFreqid, pfileName[48], oldFreq, oldpFreqid, oldrfileName[48];
	freq = strval(params);
	if(freq <= 0) return SendClientMessage(playerid, COLOR_RED, "Tu ne peux pas utiliser cette fréquence.");
	GetPlayerName(playerid, pName, sizeof(pName));
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	format(rfileName, sizeof(rfileName), "radio/%i.ini", freq);
	oldFreq = dini_Int(pfileName, "frequence");
	format(oldrfileName, sizeof(oldrfileName), "radio/%i.ini", oldFreq);
	if(!dini_Exists(rfileName))
	{
		dini_Create(rfileName);
		for(new rMember = 0; rMember <= 50; rMember++)
		{
		    format(strSlotMember, sizeof(strSlotMember), "%i", rMember);
			dini_IntSet(rfileName, strSlotMember, 999);
		}
	}
	for(new radionb=0; radionb <= 50; radionb++)
	{
	    format(strSlot, sizeof(strSlot), "%i", radionb);
		pFreqid = dini_Int(rfileName, strSlot);
		oldpFreqid = dini_Int(oldrfileName, strSlot);
		if(oldpFreqid == playerid)
		{
		    dini_IntSet(oldrfileName, strSlot, 999);
		}
		if(pFreqid == 999)
		{
			dini_IntSet(rfileName, strSlot, playerid);
			dini_IntSet(pfileName, "frequence", freq);
			SendClientMessage(playerid, COLOR_GREEN, "Fréquence changée avec succès.");
			return 1;
		}
	}
	return 1;
}

CMD:r(playerid, params[])
{
	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/r [message]\"");
	new msg[128], pName[MAX_PLAYER_NAME], pfileName[64], rfileName[64], freq;
	GetPlayerName(playerid, pName, sizeof(pName));
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	freq = dini_Int(pfileName, "frequence");
	if(freq <= 0) return SendClientMessage(playerid, COLOR_RED, "Tu dois d'abord définir une fréquence(/frequence [fréquence])");
	format(rfileName, sizeof(rfileName), "radio/%i.ini", freq);
	format(msg, sizeof(msg), "[Radio]%s dit: %s", pName, params);
	for(new freqMember=0; freqMember <= 50; freqMember++)
	{
	    new memberid, strMember[10];
	    format(strMember, sizeof(strMember), "%i", freqMember);
	    memberid = dini_Int(rfileName, strMember);
	    if(memberid == playerid) goto suiteRadio;
		if(memberid != 999)
		{
		    SendClientMessage(memberid, COLOR_RADIO1, msg);
		}
		suiteRadio:
	}
	
	ProxDetector(30.0, playerid, msg, COLOR_RADIO1, COLOR_RADIO2, COLOR_RADIO3, COLOR_RADIO4, COLOR_RADIO5);
	return 1;
}

/*
===================================Script Téléportation
*/
CMD:pos(playerid)
{
	new string[128], Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	format (string, sizeof(string), "PosX:%.4f | PosY:%.4f | PosZ:%.4f", x, y, z);
	SendClientMessage(playerid, COLOR_TURQUOISE, string);
	return 1;
}

CMD:tpon(playerid)
{
    new pName[MAX_PLAYER_NAME], fileName[28];
	GetPlayerName(playerid, pName, sizeof(pName));
	format (fileName, sizeof(fileName), "players/%s.ini", pName);
	dini_IntSet(fileName, "TP", 1);
	SendClientMessage(playerid, COLOR_GREEN, "Les joueurs peuvent désormais se téléporter sur vous.");
	return 1;
}

CMD:tpoff(playerid)
{
    new pName[MAX_PLAYER_NAME], fileName[28];
	GetPlayerName(playerid, pName, sizeof(pName));
	format (fileName, sizeof(fileName), "players/%s.ini", pName);
	dini_IntSet(fileName, "TP", 0);
	SendClientMessage(playerid, COLOR_GREEN, "Les joueurs ne peuvent plus se téléporter sur vous.");
	return 1;
}

CMD:tp(playerid, params[])
{
    new pName[MAX_PLAYER_NAME], tName[MAX_PLAYER_NAME], fileName[28];
	new teleid = strval(params);
	GetPlayerName(playerid, pName, sizeof(pName));
	GetPlayerName(teleid, tName, sizeof(tName));
	if(playerid == teleid) return SendClientMessage(playerid, COLOR_RED, "Tu ne peux pas te téléporter à toi-même.");
	format (fileName, sizeof(fileName), "players/%s.ini", tName);
	new tpValue = dini_Int(fileName, "TP");
	if(tpValue == 1 || IsPlayerAdmin(playerid) == 1 )
	{
		if (isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/tp [ID du joueur]\"");
		new playerMessage[64], teleMessage[64], Float:x, Float:y, Float:z;
		if (teleid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "Le joueur demandé n'existe pas.");
		GetPlayerPos(teleid, x, y, z);
		new interior = GetPlayerInterior(teleid);
		new virtualWorld = GetPlayerVirtualWorld(teleid);
		SetPlayerInterior(playerid, interior);
		SetPlayerVirtualWorld(playerid, virtualWorld);
		if(!IsPlayerInAnyVehicle(teleid)) SetPlayerPos(playerid, x+0.5, y+0.5, z+0.5);
		else
		{
		    new vehicleid;
		    vehicleid = GetPlayerVehicleID(teleid);
		    PutPlayerInVehicle(playerid, vehicleid, 0);
		}
		format(playerMessage, sizeof(playerMessage), "Tu t'es téléporté à %s.", tName);
		format(teleMessage, sizeof(teleMessage), "%s s'est téléporté à toi.", pName);
		SendClientMessage(playerid, COLOR_GREEN, playerMessage);
		SendClientMessage(teleid, COLOR_GREEN, teleMessage);
	}
	else if(teleid == playerid)
	{
	    SendClientMessage(playerid, COLOR_RED, "Tu ne peux pas te téléporter sur toi-même.");
	}
	else
	{
	    SendClientMessage(playerid, COLOR_RED, "Ce joueur n'a pas activé la téléportation.");
	}
	return 1;
}

CMD:tppos(playerid, params[])
{
	new Float:player_pos[3];
    if(sscanf(params, "fff", player_pos[0], player_pos[1], player_pos[2])) return SendClientMessage(playerid, COLOR_RED, "Utilise /tppos [posX] [posY] [posZ]");
	else
	{
	    SetPlayerPosFindZ(playerid, player_pos[0], player_pos[1], player_pos[2]+0.5);
	}
	return 1;
}

CMD:ctppoint(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "Tu n'es pas administrateur.");
	new Float:e_pos[3], Float:d_pos[3], dInterior, pickupmodelid, pickupid, tpfileName[32], TextID, dVirtual, eVirtual;
	if(sscanf(params, "fffiii", d_pos[0], d_pos[1], d_pos[2], dInterior, pickupmodelid, dVirtual)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/ctppoint [posX] [posY] [posZ] [Interior] [Pickup ID] [Virtual World]\"");
	GetPlayerPos(playerid, e_pos[0], e_pos[1], e_pos[2]);
	eVirtual = GetPlayerVirtualWorld(playerid);
	pickupid = CreatePickup(pickupmodelid, 1, e_pos[0], e_pos[1], e_pos[2], eVirtual);
	TextID = Create3DTextLabel("Appuie sur \"H\" pour entrer", COLOR_TURQUOISE, e_pos[0], e_pos[1], e_pos[2], 6.0, eVirtual, 1);
	for(new tpnb = 1; tpnb <= 75; tpnb++)
	{
	    format(tpfileName, sizeof(tpfileName), "tppoint/%i.ini", tpnb);
	    if(!dini_Exists(tpfileName))
	    {
	        dini_Create(tpfileName);
	        dini_IntSet(tpfileName, "pickupmodelid", pickupmodelid);
	        dini_IntSet(tpfileName, "pickupid", pickupid);
	        dini_IntSet(tpfileName, "TextID", TextID);
	        dini_FloatSet(tpfileName, "eposX", e_pos[0]);
	        dini_FloatSet(tpfileName, "eposY", e_pos[1]);
	        dini_FloatSet(tpfileName, "eposZ", e_pos[2]);
	        dini_IntSet(tpfileName, "eVirtual", eVirtual);
	        dini_FloatSet(tpfileName, "dposX", d_pos[0]);
	        dini_FloatSet(tpfileName, "dposY", d_pos[1]);
	        dini_FloatSet(tpfileName, "dposZ", d_pos[2]);
	        dini_IntSet(tpfileName, "dInterior", dInterior);
	        dini_IntSet(tpfileName, "dVirtual", dVirtual);
	        return 1;
	    }
	}
	return 1;
}

CMD:destp(playerid, params[])
{
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "Tu n'es pas administrateur.");
    new tpfileName[32];
	for(new tpnb = 1; tpnb <= 75; tpnb++)
	{
	    format(tpfileName, sizeof(tpfileName), "tppoint/%i.ini", tpnb);
	    if(dini_Exists(tpfileName))
	    {
	        new Float:e_pos[3];
	        e_pos[0] = dini_Float(tpfileName, "eposX");
	        e_pos[1] = dini_Float(tpfileName, "eposY");
	        e_pos[2] = dini_Float(tpfileName, "eposZ");
	        if(IsPlayerInRangeOfPoint(playerid, 1.0, e_pos[0], e_pos[1], e_pos[2]))
	        {
	            new pickupid, TextID;
	            pickupid = dini_Int(tpfileName, "pickupid");
	            TextID = dini_Int(tpfileName, "TextID");
	            DestroyPickup(pickupid);
	            Delete3DTextLabel(TextID);
				dini_Remove(tpfileName);
				return 1;
	        }
	    }
	}
	return 1;
}

//Points de téléportation
CMD:pizzeria(playerid)
{
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, 2132, -1787, 13);
	return 1;
}

CMD:banque(playerid)
{
	SetPlayerCheckpoint(playerid, 1726.6, -1636.4, 20.21, 3.5);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, 1722, -1628, 20.2);
	return 1;
}

CMD:ammu1(playerid)
{
    SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, 1365, -1286, 13);
	return 1;
}

CMD:ammu2(playerid)
{
    SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, 2396, -1979, 13);
	return 1;
}

CMD:airport1(playerid)
{
    SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, 1982, -2270, 13.5);
	return 1;
}

CMD:airport2(playerid)
{
    SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, -1272.0, -206.0, 14.0);
	return 1;
}
CMD:pont(playerid)
{
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, -2781.0, 1761.0, 68.0);
	return 1;
}

CMD:ville(playerid)
{
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, -2264.0, 2340.0, 5.0);
	return 1;
}

CMD:concess(playerid)
{
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, -2230.0, 2295.0, 5.0);
	return 1;
}

CMD:bois(playerid)
{
    SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, -699.0, 957.0, 12.0);
	return 1;
}

CMD:fonderie(playerid)
{
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, -1440.0, 1939.0, 51.5);
	return 1;
}

CMD:carriere(playerid)
{
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, -1090.0, 2121.0, 89.0);
	return 1;
}

CMD:barrage(playerid)
{
    SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, -595.0, 2023.0, 60.3);
	return 1;
}

/*
===================================Script Terrain
*/
CMD:placer(playerid, params[])
{
	if(IsPlayerAdmin(playerid) == 1 || GetPlayerTeam(playerid) == 1)
	{
    	if (isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/placer [ID de l'objet]\"");
		new string[128], Float:x, Float:y, Float:z;
		new modelid = strval(params);
		GetPlayerPos(playerid, x, y, z);
		new objectid = CreateObject(modelid, x+2, y+2, z+0.5, 0, 0, 0, 30000);
		new Float:posX, Float:posY, Float:posZ, Float:rotX, Float:rotY, Float:rotZ, fileName[32];
 		GetObjectPos(objectid, posX, posY, posZ);
  		GetObjectRot(objectid, rotX, rotY, rotZ);
		format(fileName, sizeof(fileName), "objects/%i.txt", objectid);
		if(!dini_Exists(fileName))
		{
		    dini_Create(fileName);
		}
		dini_IntSet(fileName,"modelid", modelid);
		dini_FloatSet(fileName,"posX", posX);
		dini_FloatSet(fileName,"posY", posY);
		dini_FloatSet(fileName,"posZ", posZ);
		dini_FloatSet(fileName,"rotX", rotX);
		dini_FloatSet(fileName,"rotY", rotY);
		dini_FloatSet(fileName,"rotZ", rotZ);
		format (string, sizeof(string), "Objet placé ! ID : %i", objectid);
		EditObject(playerid, objectid);
		SendClientMessage(playerid, COLOR_GREEN, string);
	}
	return 1;
}

CMD:modifier(playerid)
{
    if(IsPlayerAdmin(playerid) == 1 || GetPlayerTeam(playerid) == 1)
	{

		new pName[MAX_PLAYER_NAME], pfileName[48];
    	GetPlayerName(playerid, pName, sizeof(pName));
    	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
    	dini_IntSet(pfileName, "selection", 0);
    	SelectObject(playerid);
	}
    return 1;
}

/*CMD:desobj(playerid)
{
	if(IsPlayerAdmin(playerid) == 1 || GetPlayerTeam(playerid) == 1)
	{
    	for(new id = 0; id < 10000; id++)
		{
		    id = id++;
			DestroyObject(id);
		    new fileName[32];
		    format(fileName, sizeof(fileName), "objects/%i.txt", id);
			dini_Remove(fileName);
		}
	}
	return 1;
}*/

CMD:cop(playerid, objectid[], speed[])
{
    if(IsPlayerAdmin(playerid) == 1 || GetPlayerTeam(playerid) == 1)
	{
		new objetid = strval(objectid), Float:posX, Float:posY, Float:posZ;
		GetObjectPos(objetid, posX, posY, posZ);
		MoveObject(objetid, 0, 0, 10, 2.00);
	}
	return 1;
}

CMD:supprimer(playerid, params[])
{
	if(IsPlayerAdmin(playerid) == 1 || GetPlayerTeam(playerid) == 1)
	{
    	if (isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/supprimer [ID de l'objet]\"");
		new objectid = strval(params), fileName[32];
		if(IsValidObject(objectid))
		{
			DestroyObject(objectid);
			format(fileName, sizeof(fileName), "objects/%i.txt", objectid);
			dini_Remove(fileName);
			SendClientMessage(playerid, COLOR_GREEN, "Objet supprimé.");
		}
		else
		{
            SendClientMessage(playerid, COLOR_RED, "Objet non trouvé.");
		}
	}
	return 1;
}

CMD:rem(playerid, params[])
{
	new objectid = strval(params), Float:player_pos[3];
	GetPlayerPos(playerid, player_pos[0], player_pos[1], player_pos[2]);
	RemoveBuildingForPlayer(playerid, objectid, player_pos[0], player_pos[1], player_pos[2], 3.0);
	return 1;
}

CMD:texture(playerid, params[])
{
	if(GetPlayerTeam(playerid) != 1 && !IsPlayerAdmin(playerid)) return 1;
	new objectid, modelid, txdname[48], texturename[48];
	if(sscanf(params, "iiss", objectid, modelid, txdname, texturename)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/texture [objectID] [modelID] [TXD Name] [Texture Name]\"");
	SetObjectMaterial(objectid, 0, modelid, txdname, texturename, 0);
	new ofileName[48];
	format(ofileName, sizeof(ofileName), "objects/%i.txt", objectid);
    dini_IntSet(ofileName, "modelidTXT", modelid);
	dini_Set(ofileName, "txdname", txdname);
	dini_Set(ofileName, "texturename", texturename);
    SendClientMessage(playerid, COLOR_GREEN, "Texture changée avec succès.");
	return 1;
}

CMD:copie(playerid)
{
    if(IsPlayerAdmin(playerid) == 1 || GetPlayerTeam(playerid) == 1)
	{
		new pName[MAX_PLAYER_NAME], pfileName[48];
    	GetPlayerName(playerid, pName, sizeof(pName));
    	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
    	dini_IntSet(pfileName, "selection", 1);
	    SelectObject(playerid);
	}
    return 1;
}

/*
===================================Script Véhicules
*/

CMD:desall(playerid)
{
    if(IsPlayerAdmin(playerid))
    {
		for(new vehicleid = 0; vehicleid < 1000; vehicleid++)
		{
		    vehicleid = vehicleid++;
			new vfileName[32];
			format(vfileName, sizeof(vfileName), "vehicules/%i.ini", vehicleid);
			dini_Remove(vfileName);
			DestroyVehicle(vehicleid);
		}
		SendClientMessage(playerid, COLOR_GREEN, "Véhicules détruit avec succès");
	}
	return 1;
}

CMD:rep(playerid)
{
    if (GetPlayerVehicleSeat(playerid) == 0 || IsPlayerAdmin(playerid) == 1)
    {
		if(IsPlayerInRangeOfPoint(playerid, 7, -2231.4, 2299.1, 5.4)) return SendClientMessage(playerid, COLOR_RED, "Tu n'es pas au garage!");
		else if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "Tu n'es pas dans un véhicule!");
		else
		{
			RepairVehicle(GetPlayerVehicleID(playerid));
			SendClientMessage(playerid, COLOR_GREEN, "Véhicule réparé.");
		}
	}
	else
	{
 		SendClientMessage(playerid, COLOR_RED, "Tu dois être au volant du véhicule.");
	}
	return 1;
}

CMD:lock(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
	    {
			new vehicleid, moteur, phares, alarme, portes, capot, coffre, objective;
    		vehicleid = GetPlayerVehicleID(playerid);
			GetVehicleParamsEx(vehicleid, moteur, phares, alarme, portes, capot, coffre, objective);
			if(portes == 1)
			{
				SetVehicleParamsEx(vehicleid, moteur, phares, alarme, 0, capot, coffre, objective);
				GameTextForPlayer(playerid, "~w~Portes ~g~ouvertes", 1500, 6);
			}
			else
			{
				SetVehicleParamsEx(vehicleid, moteur, phares, alarme, 1, capot, coffre, objective);
				GameTextForPlayer(playerid, "~w~Portes ~r~fermee", 1500, 6);
			}
		}
}

CMD:veh(playerid, params[])
{
    if(!IsPlayerInRangeOfPoint(playerid, 3.0, -2239.52930, 2296.37769, 5.92660))
    {
		ShowPlayerDialog(playerid, 8, DIALOG_STYLE_LIST, "Catégories de véhicules", "Avions\nHélicoptères\nDeux roues\nToit ouvrant\nIndustriels\nLowriders\n4x4\nServices publiques\nVoitures normales\nVoitures de sport\nVéhicules familiaux\nBateaux\nInclassables\nVéhicules miniatures\nAutre 1\nAutre 2", "Choisir", "Annuler");
	}
	else
	{
	    SendClientMessage(playerid, COLOR_RED, "Tu n'es pas au concessionnaire. Utilise \"/concess\" pour y aller.");
	}
	return 1;
}

CMD:m(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
 		if (GetPlayerVehicleSeat(playerid) == 0 || IsPlayerAdmin(playerid) == 1)
   		{
  			new vehicleid, moteur, phares, alarme, portes, capot, coffre, objective;
 			vehicleid = GetPlayerVehicleID(playerid);
			GetVehicleParamsEx(vehicleid, moteur, phares, alarme, portes, capot, coffre, objective);
			if(moteur == 1)
			{
				SetVehicleParamsEx(vehicleid, 0, phares, alarme, portes, capot, coffre, objective);
			}
			else
			{
		    	SetVehicleParamsEx(vehicleid, 1, phares, alarme, portes, capot, coffre, objective);
			}
		}
		else
		{
		    SendClientMessage(playerid, COLOR_RED, "Tu dois être au volant du véhicule.");
		}
	}
	return 1;
}

CMD:v(playerid, params[])
{
	new strAction[32], strParams[32];
	sscanf(params, "ss", strAction, strParams);
	if(isnull(params)) goto finv;
	
	//Plaque
	if(strcmp(strAction, "plaque", true) == 0)
	{
	    if (IsPlayerInAnyVehicle(playerid))
		{
	    	if(isnull(strParams)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/v plaque [AA-00-AA]\"");
			new Float:x, Float:y, Float:z, moteur, phares, alarme, portes, capot, coffre, objective, pName[MAX_PLAYER_NAME], couleur1, couleur2, Float:vehHealth, vfileName[48];
			new vehicleid = GetPlayerVehicleID(playerid);
			format(vfileName, sizeof(vfileName), "vehicules/%i.ini", vehicleid);
			GetPlayerName(playerid, pName, sizeof(pName));
			if(strcmp(pName, dini_Get(vfileName, "proprio1"), true) != 0) return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas les clefs de ce véhicule.");
			else if(strcmp(pName, dini_Get(vfileName, "proprio2"), true) != 0) return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas les clefs de ce véhicule.");
			else if(strcmp(pName, dini_Get(vfileName, "proprio3"), true) != 0) return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas les clefs de ce véhicule.");
			GetVehicleParamsEx(vehicleid, moteur, phares, alarme, portes, capot, coffre, objective);
			couleur1 = dini_Int(vfileName, "couleur1");
			couleur2 = dini_Int(vfileName, "couleur2");
			GetVehicleHealth(vehicleid, vehHealth);
			
			SetVehicleNumberPlate(vehicleid, strParams);
			GetVehiclePos(vehicleid, x, y, z);
			SetVehicleToRespawn(vehicleid);
			SetVehiclePos(vehicleid, x, y, z);
			SetVehicleParamsEx(vehicleid, moteur, phares, alarme, portes, capot, coffre, objective);
			SetVehicleHealth(vehicleid, vehHealth);
			ChangeVehicleColor(vehicleid, couleur1, couleur2);
			return PutPlayerInVehicle(playerid, vehicleid, 0);
		}
		else return SendClientMessage(playerid, COLOR_RED, "Tu dois être dans un véhicule pour changer sa plaque.");
	}
	//Acheter
	else if(strcmp(strAction, "acheter", true) == 0)
	{
	    if (IsPlayerInAnyVehicle(playerid))
		{
			new fileName[24], pfileName[32+MAX_PLAYER_NAME], pName[32], string[16], vehicleid;
			GetPlayerName(playerid, pName, sizeof(pName));
			vehicleid = GetPlayerVehicleID(playerid);
			format(fileName, sizeof(fileName), "vehicules/%i.ini", vehicleid);
			format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
			if(strcmp(dini_Get(fileName, "proprio1"), "Aucun", true) != 0) return SendClientMessage(playerid, COLOR_RED, "Ce véhicule n'est pas à vendre.");
			//Paramètres du véhicule
			dini_Set(fileName, "proprio1", pName);
			//Définit le propriétaire
			for(new vid = 1; vid <= 10; vid++)
			{
	    		format(string, sizeof(string), "vehicle%i", vid);
				new vnb = dini_Int(pfileName, string);
				if (vnb == 0)
				{
					dini_IntSet(pfileName, string, vehicleid);
					dini_IntSet(fileName, "vehiclenb", vid);
					break;
				}
			}
			SendClientMessage(playerid, COLOR_GREEN, "Véhicule acheté");
		}
	}
	//Capot
	else if(strcmp(strAction, "capot", true) == 0)
	{
	    if(IsPlayerInAnyVehicle(playerid))
		{
 			if (GetPlayerVehicleSeat(playerid) == 0 || IsPlayerAdmin(playerid) == 1)
   			{
  				new vehicleid, moteur, phares, alarme, portes, capot, coffre, objective;
 				vehicleid = GetPlayerVehicleID(playerid);
				GetVehicleParamsEx(vehicleid, moteur, phares, alarme, portes, capot, coffre, objective);
				if(capot == 1) return SetVehicleParamsEx(vehicleid, moteur, phares, alarme, portes, 0, coffre, objective);
				else return SetVehicleParamsEx(vehicleid, moteur, phares, alarme, portes, 1, coffre, objective);
			}
			else return SendClientMessage(playerid, COLOR_RED, "Tu dois être au volant du véhicule.");
		}
		else return SendClientMessage(playerid, COLOR_RED, "Tu dois être au volant d'un véhicule.");
	}
	
	//Coffre
	else if(strcmp(strAction, "coffre", true) == 0)
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
 			if (GetPlayerVehicleSeat(playerid) == 0 || IsPlayerAdmin(playerid) == 1)
   			{
  				new vehicleid, moteur, phares, alarme, portes, capot, coffre, objective;
 				vehicleid = GetPlayerVehicleID(playerid);
				GetVehicleParamsEx(vehicleid, moteur, phares, alarme, portes, capot, coffre, objective);
				if(coffre == 1) return SetVehicleParamsEx(vehicleid, moteur, phares, alarme, portes, capot, 0, objective);
				else return SetVehicleParamsEx(vehicleid, moteur, phares, alarme, portes, capot, 1, objective);
			}
			else return SendClientMessage(playerid, COLOR_RED, "Tu dois être au volant du véhicule.");
		}
		else return SendClientMessage(playerid, COLOR_RED, "Tu dois être au volant d'un véhicule.");
	}
	
	//Vendre
	else if(strcmp(strAction, "vendre", true) == 0)
	{
		new vehicleid, vehnb, vehiclenb[15],pName[MAX_PLAYER_NAME], vfileName[32], pfileName[MAX_PLAYER_NAME + 15], IDveh;
		vehicleid = GetPlayerVehicleID(playerid);
		GetPlayerName(playerid, pName, sizeof(pName));
		//Enlève des véhicules allumés
		for(new vehNb = 0; vehNb <= 50; vehNb++)
 		{
 	    	format(vehiclenb, sizeof(vehiclenb), "%i", vehNb);
			IDveh = dini_Int("vehicules/allume.ini", vehiclenb);
			if(IDveh == vehicleid)
			{
		   		dini_IntSet("vehicules/allume.ini", vehiclenb, 0);
				goto finvvendre;
			}
		}
  		finvvendre:
  		//Cacher le compteur
		PlayerTextDrawHide(playerid, degatTextDraw);
		PlayerTextDrawHide(playerid, carburantTextDraw);
		PlayerTextDrawHide(playerid, heureTextDraw);
		PlayerTextDrawHide(playerid, compteurKMH);
		//Détruit le fichier
		format(vfileName, sizeof(vfileName), "vehicules/%i.ini", vehicleid);
		format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
		vehnb = dini_Int(vfileName, "vehiclenb");
		format(vehiclenb, sizeof(vehiclenb), "vehicle%i", vehnb);
		dini_IntSet(pfileName, vehiclenb, 0);
		dini_Remove(vfileName);
		DestroyVehicle(vehicleid);
		return 1;
	}
	
	//Vendre à
	else if(strcmp(strAction, "vendrea", true) == 0)
	{
	    if(isnull(strParams)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/v vendrea [ID du joueur] [montant]\"");
	    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "Tu dois être dans un véhicule pour pouvoir le vendre.");
		new vehicleid, tName[MAX_PLAYER_NAME], vfileName[32], tfileName[48], pName[MAX_PLAYER_NAME], msgPlayer[128], msgTele[128], teleid, montant, tMoney, Float:t_pos[3];
	    sscanf(strParams, "ii", teleid, montant);
	    if(teleid == playerid) return SendClientMessage(playerid, COLOR_RED, "Tu ne peux pas vendre ton véhicule à toi-même.");
		vehicleid = GetPlayerVehicleID(playerid);
		GetPlayerName(playerid, pName, sizeof(pName));//Vendeur
		GetPlayerName(teleid, tName, sizeof(tName));//Acheteur
		GetPlayerPos(teleid, t_pos[0], t_pos[1], t_pos[2]);
		if(!IsPlayerInRangeOfPoint(playerid, 5.0, t_pos[0], t_pos[1], t_pos[2])) return SendClientMessage(playerid, COLOR_RED, "Ce joueur est trop éloigné de toi.");
		tMoney = GetPlayerMoney(playerid);
		if(montant <= 0) return SendClientMessage(playerid, COLOR_RED, "Montant trop faible.");
		if(tMoney < montant) return SendClientMessage(playerid, COLOR_RED, "Ce joueur n'a pas assez d'argent.");
		format(tfileName, sizeof(tfileName), "players/%s.ini", tName);
		format(vfileName, sizeof(vfileName), "vehicules/%i.ini", vehicleid);
		dini_IntSet(tfileName, "accVehicleID", vehicleid);
		dini_IntSet(tfileName, "accVendeurID", playerid);
		dini_IntSet(tfileName, "accMontant", montant);
		format(msgPlayer, sizeof(msgPlayer), "Tu as proposé ton/ta %s à %s pour %i$.", dini_Get(vfileName, "modelName"), tName, montant);
		format(msgTele, sizeof(msgTele), "%s te propose son/sa %s pour %i$.(\"/accepter vehicule\" pour accepter l'offre)", pName, dini_Get(vfileName, "modelName"), montant);
		SendClientMessage(playerid, COLOR_GREEN, msgPlayer);
		SendClientMessage(teleid, COLOR_GREEN, msgTele);
	}
	
	//Couleurs
	else if(strcmp(strAction, "couleur", true) == 0)
	{
		new vehicleid = GetPlayerVehicleID(playerid), color1, color2, vfileName[32];
    	if(sscanf(strParams, "ii", color1, color2)) return SendClientMessage(playerid, COLOR_RED, "Utilise /v couleur [couleur 1] [couleur 2]");
    	ChangeVehicleColor(vehicleid, color1, color2);
    	format(vfileName, sizeof(vfileName), "vehicules/%i.ini", vehicleid);
    	dini_IntSet(vfileName, "couleur1", color1);
    	dini_IntSet(vfileName, "couleur2", color2);
		return 1;
	}
	
	//Remplir
	else if(strcmp(strAction, "remplir", true) == 0)
	{
	    new stfileName[48], Float:st_pos[3];
	    for(new stationid = 1; stationid <= 30; stationid++)
	    {
			format(stfileName, sizeof(stfileName), "stations/%i.ini", stationid);
			st_pos[0] = dini_Float(stfileName, "posX");
			st_pos[1] = dini_Float(stfileName, "posY");
			st_pos[2] = dini_Float(stfileName, "posZ");
			if(IsPlayerInRangeOfPoint(playerid, 15.0, st_pos[0], st_pos[1], st_pos[2]))
			{
			    new vfileName[32], carString[16];
				if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/v remplir [litres]\".");
				else if(isnull(strParams)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/v remplir [litres]\".");
    			new vehicleid = GetPlayerVehicleID(playerid);
    			new Float:litres = floatstr(strParams);
				format(vfileName, sizeof(vfileName), "vehicules/%i.ini", vehicleid);
				new Float:carburant = dini_Float(vfileName, "maxCar");
				new Float:curCarburant = dini_Float(vfileName, "curCar");
				new Float:newCarburant = floatadd(curCarburant, litres);
				if(carburant < newCarburant ) return SendClientMessage(playerid, COLOR_RED, "Nombre de litre trop élevé.");
				dini_FloatSet(vfileName, "curCarburant", newCarburant);
				format(carString, sizeof(carString), "%.0f/%.0f", newCarburant, carburant);
 				PlayerTextDrawSetString(playerid, carburantTextDraw, carString);
 				return SendClientMessage(playerid, COLOR_GREEN, "Tu as remplit ton véhicule.");
			}
	    }
 	}
 	
 	//Nitro
    else if(strcmp(strAction, "nitro", true) == 0)
	{
		new vehicleid;
		vehicleid = GetPlayerVehicleID(playerid);
		AddVehicleComponent(vehicleid, 1010);
		return SendClientMessage(playerid, COLOR_GREEN, "Tu as ajouté du NOS sur ton véhicule.");
	}
	
	//Aide
 	else
	{
	    finv:
	    SendClientMessage(playerid, COLOR_YELLOW, "                    Actions possibles :");
		SendClientMessage(playerid, COLOR_TURQUOISE, "vendre   |   acheter   |   capot   |   coffre   |   couleur");
		SendClientMessage(playerid, COLOR_TURQUOISE, "remplir  |    plaque   |   nitro   |   vendrea  |   ...");
	}
	return 1;
}

CMD:cveh(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return 1;
	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/cveh [Nom du véhicule]\"");
    new vfileName[48], cfgfileName[48], Float:p_pos[4], modelid, vehicleid, couleur1, couleur2, pfileName[32+MAX_PLAYER_NAME], string[16], typeCar;
	format(cfgfileName, sizeof(cfgfileName), "vehicules/models/%s.ini", params);
	if(!dini_Exists(cfgfileName)) return SendClientMessage(playerid, COLOR_RED, "Ce véhicule n'existe pas.");
	GetPlayerFacingAngle(playerid, p_pos[3]);
	GetPlayerPos(playerid, p_pos[0], p_pos[1], p_pos[2]);
	
	modelid = dini_Int(cfgfileName, "modelid");
	couleur1 = random(256);
	couleur2 = random(256);
	typeCar = dini_Int(cfgfileName, "typeCar");
	vehicleid = CreateVehicle(modelid, p_pos[0], p_pos[1],  p_pos[2]+1,  p_pos[3], 0, 0, -1);
	format(vfileName, sizeof(vfileName), "vehicules/%i.ini", vehicleid);
	//Paramètres du véhicule
	dini_Create(vfileName);
	dini_IntSet(vfileName, "modelid", dini_Int(cfgfileName, "modelid"));
	dini_Set(vfileName, "modelName", params);
	dini_IntSet(vfileName, "curCar", dini_Int(cfgfileName, "maxCar"));
	dini_IntSet(vfileName, "maxCar", dini_Int(cfgfileName, "maxCar"));
	dini_IntSet(vfileName, "typeCar", typeCar);
	dini_IntSet(vfileName, "couleur1", couleur1);
	dini_IntSet(vfileName, "couleur2", couleur2);
    dini_Set(vfileName, "proprio1", "Aucun");
    dini_Set(vfileName, "proprio2", "Aucun");
    dini_Set(vfileName, "proprio3", "Aucun");
	//Définit le propriétaire
	for(new vid = 1; vid < 10; vid++)
	{
	    format(string, sizeof(string), "vehicle%i", vid);
		new vnb = dini_Int(pfileName, string);
		if (vnb == 0)
		{
			dini_IntSet(pfileName, string, vehicleid);
			dini_IntSet(vfileName, "vehiclenb", vid);
			break;
		}
	}
    new pVirtual, pInterior;
	pVirtual = GetPlayerVirtualWorld(playerid);
	pInterior = GetPlayerInterior(playerid);
	LinkVehicleToInterior(vehicleid, pInterior);
	SetVehicleVirtualWorld(vehicleid, pVirtual);
	PutPlayerInVehicle(playerid, vehicleid, 0);
	SendClientMessage(playerid, COLOR_GREEN, "Véhicule spawn.");
	return 1;
}

CMD:cfgveh(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return 1;
	new modelName[48], modelid, typeCar, maxCar, cfgfileName[48];
	if(sscanf(params, "siii", modelName, modelid, typeCar, maxCar)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/cfgveh [Nom du véhicule] [modelid] [Type de carburant] [Carburant maximum]\" <- Les différentes informations sont sur Moxtra");
	format(cfgfileName, sizeof(cfgfileName), "vehicules/models/%s.ini", modelName);
	if(!dini_Exists(cfgfileName)) dini_Create(cfgfileName);
	dini_IntSet(cfgfileName, "modelid", modelid);
	dini_IntSet(cfgfileName, "typeCar", typeCar);
	dini_IntSet(cfgfileName, "maxCar", maxCar);
	SendClientMessage(playerid, COLOR_GREEN, "Véhicule paramétré.");
	return 1;
}

CMD:vhealth(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return 1;
	new vehicleid, Float:vhealth;
	if(sscanf(params, "if", vehicleid, vhealth)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/vhealth [Vehicle ID] [Vie du véhicule]\"");
	SetVehicleHealth(vehicleid, vhealth);
	return SendClientMessage(playerid, COLOR_GREEN, "Tu as réglé la vie du véhicule.");
}

CMD:vehstats(playerid, params[])
{
	new cfgfileName[32], typeCar, str1[64], str2[64], str3[64];
	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/vehstats [Nom du véhicule]\"");
	format(cfgfileName, sizeof(cfgfileName), "vehicules/models/%s.ini", params);
	if(!dini_Exists(cfgfileName)) return SendClientMessage(playerid, COLOR_RED, "Ce modèle n'est pas enregistré.");
	format(str1, sizeof(str1), "========%s(%i)========", params, dini_Int(cfgfileName, "modelid"));
	typeCar = dini_Int(cfgfileName, "typeCar");
	if(typeCar == 1) format(str2, sizeof(str2), "Carburant : Diesel(%i)", typeCar);
	else if(typeCar == 2) format(str2, sizeof(str2), "Carburant : Kerozen(%i)", typeCar);
	else if(typeCar == 3) format(str2, sizeof(str2), "Carburant : Electricité(%i)", typeCar);
	format(str3, sizeof(str3), "Capacité du réservoir : %i", dini_Int(cfgfileName, "maxCar"));
	SendClientMessage(playerid, COLOR_YELLOW, str1);
	SendClientMessage(playerid, COLOR_YELLOW, str2);
	SendClientMessage(playerid, COLOR_YELLOW, str3);
	return 1;
}

CMD:cstation(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return 1;
	new diesel, kerozen, electricite, stfileName[32];
	if(sscanf(params, "iii", diesel, kerozen, electricite)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/cstation [Diesel(0 ou 1)] [Kerozen(0 ou 1)] [Eléctricité(0 ou 1)]\"");
	for(new stationid = 1; stationid <= 20; stationid++)
	{
		format(stfileName, sizeof(stfileName), "stations/%i.ini", stationid);
		if(!dini_Exists(stfileName))
		{
			new Float:p_pos[3];
			dini_Create(stfileName);
			GetPlayerPos(playerid, p_pos[0], p_pos[1], p_pos[2]);
		    dini_FloatSet(stfileName, "posX", p_pos[0]);
		    dini_FloatSet(stfileName, "posY", p_pos[1]);
		    dini_FloatSet(stfileName, "posZ", p_pos[2]);
		    dini_IntSet(stfileName, "diesel", diesel);
		    dini_IntSet(stfileName, "kerozen", kerozen);
		    dini_IntSet(stfileName, "electricite", electricite);
		    return SendClientMessage(playerid, COLOR_GREEN, "Station créée avec succès.");
		}
	}
	return 1;
}

CMD:desstation(playerid)
{
    new stfileName[48], Float:st_pos[3];
    for(new stationid = 1; stationid <= 30; stationid++)
	{
		format(stfileName, sizeof(stfileName), "stations/%i.ini", stationid);
		st_pos[0] = dini_Float(stfileName, "posX");
		st_pos[1] = dini_Float(stfileName, "posY");
		st_pos[2] = dini_Float(stfileName, "posZ");
		if(IsPlayerInRangeOfPoint(playerid, 15.0, st_pos[0], st_pos[1], st_pos[2]))
		{
		    dini_Remove(stfileName);
		    SendClientMessage(playerid, COLOR_GREEN, "Station détruite avec succès.");
		}
	}
	return 1;
}

/*
===================================Script Armes
*/
CMD:arme(playerid)
{
	ShowPlayerDialog(playerid, 1, DIALOG_STYLE_LIST, "Catégories d'armes", "Armes blanches\nArmes de poing\nFusils\nObjets\nGrenades", "Choisir", "Annuler");
	SetPlayerSkillLevel(playerid, 0, 1);
    SetPlayerSkillLevel(playerid, 1, 1);
    SetPlayerSkillLevel(playerid, 2, 1);
    SetPlayerSkillLevel(playerid, 3, 1);
    SetPlayerSkillLevel(playerid, 4, 1);
    SetPlayerSkillLevel(playerid, 5, 1);
    SetPlayerSkillLevel(playerid, 6, 1);
    SetPlayerSkillLevel(playerid, 7, 1);
    SetPlayerSkillLevel(playerid, 8, 1);
    SetPlayerSkillLevel(playerid, 9, 1);
    SetPlayerSkillLevel(playerid, 10, 1);
	return 1;
}

CMD:jetpack(playerid, params[])
{
	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise /jetpack [ON/OFF]");
	if(strcmp(params, "off", true) == 0)
	{
	    SetPlayerSpecialAction(playerid, 0);
    	SendClientMessage(playerid, COLOR_GREEN, "Tu as été déséquipé de ton Jetpack.");
	}
	if(strcmp(params, "on", true) == 0)
	{
	    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
    	SendClientMessage(playerid, COLOR_GREEN, "Tu as été équipé d'un Jetpack.");
	}
	return 1;
}

CMD:desarme(playerid, params[])
{
	if(isnull(params)) ResetPlayerWeapons(playerid);
	else
	{
	    if(IsPlayerAdmin(playerid))
	    {
	        new teleid;
			teleid = strval(params);
			ResetPlayerWeapons(teleid);
			SendClientMessage(playerid, COLOR_GREEN, "Le joueur n'a plus d'armes.");
	    }
	    else ResetPlayerWeapons(playerid);
	}
		
	return 1;
}

CMD:mourir(playerid)
{
	new pfileName[48], pName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, sizeof(pName));
	format(pfileName, 48, "players/%s.ini", pName);
	if(dini_Int(pfileName, "Mort") != 1) return SendClientMessage(playerid, COLOR_RED, "Tu es parfaitement conscient.");
    ClearAnimations(playerid);
	SetPlayerHealth(playerid, 0.0);
	return 1;
}

/*
===================================Script Job général
*/
CMD:team(playerid, params[])
{
	if(IsPlayerAdmin(playerid) == 1 || GetPlayerTeam(playerid) == 1)
	{
		new pstring[128], tstring[128], teleid, teamid, tName[MAX_PLAYER_NAME], pName[MAX_PLAYER_NAME], tfileName[52];
		if(sscanf(params, "ii", teleid, teamid)) return SendClientMessage(playerid, COLOR_RED, "Utilise /team [ID du joueur] [ID de la team]");
		else if(!sscanf(params, "ii", teleid, teamid))
		{
			SetPlayerTeam(teleid, teamid);
			GetPlayerName(teleid, tName, sizeof(tName));
			GetPlayerName(playerid, pName, sizeof(pName));
			format(tfileName, sizeof(tfileName), "players/%s.ini", tName);
			dini_IntSet(tfileName, "team", teamid);
			format(pstring, sizeof(pstring), "Tu as mis %s dans la team %i", tName, teamid);
			format(tstring, sizeof(tstring), "Tu as été mis dans la team %i par %s", teamid, pName);
			SendClientMessage(playerid, COLOR_GREEN, pstring);
			SendClientMessage(teleid, COLOR_GREEN, tstring);
		}
	}
	return 1;
}

CMD:job(playerid, params[])
{
	new pfileName[48], pName[MAX_PLAYER_NAME], team;
	GetPlayerName(playerid, pName, sizeof(pName));
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	if(isnull(params))
	{
		SendClientMessage(playerid, COLOR_TURQUOISE, "Liste des jobs:");
		SendClientMessage(playerid, COLOR_TURQUOISE, "Bucheron   |   Soigneur   |   Mineur  |  Eau   |   Mecanicien");
	}
	if(strcmp(params, "bucheron", true) == 0)
	{
		SendClientMessage(playerid, COLOR_GREEN, "Tu es désormais bûcheron.");
	    team = 2;
	    SetPlayerTeam(playerid, 2);
	}
	else if(strcmp(params, "soigneur", true) == 0)
	{
	    SendClientMessage(playerid, COLOR_GREEN, "Tu es désormais soigneur.");
	    team = 3;
	    SetPlayerTeam(playerid, 3);
	}
	else if(strcmp(params, "mineur", true) == 0)
	{
	    SendClientMessage(playerid, COLOR_GREEN, "Tu es désormais mineur.");
	    team = 4;
	    SetPlayerTeam(playerid, 4);
	}
	else if(strcmp(params, "eau", true) == 0)
	{
	    SendClientMessage(playerid, COLOR_GREEN, "Tu es désormais porteur d'eau.");
	    team = 5;
	    SetPlayerTeam(playerid, 5);
	}
	else if(strcmp(params, "mecanicien", true) == 0)
	{
	    SendClientMessage(playerid, COLOR_GREEN, "Tu es désormais mécanicien.");
	    team = 6;
	    SetPlayerTeam(playerid, 6);
	}
	dini_IntSet(pfileName, "team", team);
	return 1;
}

CMD:equiper(playerid)
{
	if(GetPlayerSkin(playerid) == 27)
	{
	    new pfileName[48], pName[MAX_PLAYER_NAME], skinid;
		GetPlayerName(playerid, pName, sizeof(pName));
	    format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	    skinid = dini_Int(pfileName, "Skin");
	    SetPlayerSkin(playerid, skinid);
	    RemovePlayerAttachedObject(playerid, 1);
	    RemovePlayerWeapon(playerid, 9);
	    return 1;
	}
	if(GetPlayerTeam(playerid) == 2)//Bucheron
	{
	    SetPlayerSkin(playerid, 27);
	    GivePlayerWeapon(playerid, 9, 5000);
	}
	else if(GetPlayerTeam(playerid) == 4)//Mineur
	{
	    SetPlayerSkin(playerid, 27);
	    SetPlayerAttachedObject(playerid, 1, 2228, 6, 0.0, 0.06, 0.35, 0, 167.19, -86.4, 1.0, 1.0, 1.0);
	}
	else
	{
     	SendClientMessage(playerid, COLOR_RED, "Ton job ne requiert pas d'équipement : \"/job [job]\"");
	}
	return 1;
}

CMD:editequip(playerid, params[])
{
	new index;
	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/editequip [index]\"");
	index = strval(params);
	EditAttachedObject(playerid, index);
	return 1;
}

/*
===================================Script Bucheron
*/
CMD:carbre(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return 1;
	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/carbre [ID modèle de l'arbre]\"");
	new afileName[32];
	new arbreid = strval(params), Float:player_pos[3];
	GetPlayerPos(playerid, player_pos[0], player_pos[1], player_pos[2]);
	new objectid = CreateObject(arbreid, player_pos[0], player_pos[1], player_pos[2]-1.15, -1.917004, 0, 0, 20000);
	format(afileName, sizeof(afileName), "arbres/%i.ini", objectid);
	dini_Create(afileName);
	dini_IntSet(afileName, "modelid", arbreid);
 	dini_IntSet(afileName, "coupe", 0);
	dini_FloatSet(afileName, "posX", player_pos[0]);
	dini_FloatSet(afileName, "posY", player_pos[1]);
	dini_FloatSet(afileName, "posZ", player_pos[2]-1.15);
	dini_FloatSet(afileName, "rotX", -1.917004);
	dini_FloatSet(afileName, "rotY", 0);
	dini_FloatSet(afileName, "rotZ", 0);
	SetPlayerPos(playerid, player_pos[0], player_pos[1]+2, player_pos[2]);
	return SendClientMessage(playerid, COLOR_GREEN, "Arbre créé avec succès.");
}

CMD:deparbre(playerid)
{
	if(!IsPlayerAdmin(playerid)) return 1;
	new Float:player_pos[3];
    GetPlayerPos(playerid, player_pos[0], player_pos[1], player_pos[2]);
    for(new arbreid = 0; arbreid <= 1000; arbreid++)
	{
	    new afileName[32], Float:a_pos[3];
		format(afileName, sizeof(afileName), "arbres/%i.ini", arbreid);
		if(dini_Exists(afileName))
		{
			a_pos[0] = dini_Float(afileName, "posX");
			a_pos[1] = dini_Float(afileName, "posY");
			a_pos[2] = dini_Float(afileName, "posZ");
	    	if(IsPlayerInRangeOfPoint(playerid, 3.0, a_pos[0], a_pos[1], a_pos[2]))
	    	{
				return EditObject(playerid, arbreid);
	    	}
		}
	}
	return 1;
}

CMD:couper(playerid)
{
	if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "Tu dois descendre de ton véhicule pour pouvoir couper un arbre.");
	if(GetPlayerWeapon(playerid) != 9 || GetPlayerTeam(playerid) != 2) return SendClientMessage(playerid, COLOR_RED, "Tu dois être bûcheron et être équipé d'une tronçonneuse.");
    new Float:player_pos[3], Float:a_pos[3], pName[MAX_PLAYER_NAME], pfileName[48];
    GetPlayerName(playerid, pName, sizeof(pName));
    format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
    new pArbre = dini_Int(pfileName, "iArbre");
    if (pArbre >= 3) return SendClientMessage(playerid, COLOR_RED, "Tu as déjà coupé 3 arbres. Vas à la menuiserie pour les utiliser(/menuiserie).");
	GetPlayerPos(playerid, player_pos[0], player_pos[1], player_pos[2]);
	for(new arbreid = 0; arbreid <= 1000; arbreid++)
	{
	    new afileName[32];
		format(afileName, sizeof(afileName), "arbres/%i.ini", arbreid);
		a_pos[0] = dini_Float(afileName, "posX");
		a_pos[1] = dini_Float(afileName, "posY");
		a_pos[2] = dini_Float(afileName, "posZ");
	    if(IsPlayerInRangeOfPoint(playerid, 3.0, a_pos[0], a_pos[1], a_pos[2]))
	    {
	        new coupe, soucheid, Float:a_rot[3];
			coupe = dini_Int(afileName, "coupe");
			if(coupe == 1) return SendClientMessage(playerid, COLOR_RED, "Cet arbre est déjà coupé.");
			ApplyAnimation(playerid, "CHAINSAW", "Csaw_G", 3.1, 1, 0, 0, 0, 15000, 1);
			DestroyObject(arbreid);
			a_rot[0] = dini_Float(afileName, "rotX");
			a_rot[1] = dini_Float(afileName, "rotY");
			a_rot[2] = dini_Float(afileName, "rotZ");
			soucheid = CreateObject(831, a_pos[0], a_pos[1], a_pos[2]+0.3, a_rot[0], a_rot[1], a_rot[2], 30000);
			dini_IntSet(afileName, "soucheid", soucheid);
			dini_IntSet(afileName, "coupe", 1);
			gettime(heure, minute, seconde);
			heure = heure + 0;
			minute = minute + 1;
			if(heure == 24) heure = 0;
			dini_IntSet(afileName, "heure", heure);
			dini_IntSet(afileName, "minute", minute);
			dini_IntSet(pfileName, "iArbre", pArbre+1);
			return SendClientMessage(playerid, COLOR_GREEN, "Arbre coupé avec succès.");
	    }
	}
	SendClientMessage(playerid, COLOR_RED, "Il n'y a aucun arbre à proximité.");
	return 1;
}

CMD:desarbre(playerid)
{
	if(!IsPlayerAdmin(playerid) && GetPlayerTeam(playerid) != 1) return SendClientMessage(playerid, COLOR_RED, "Tu n'es pas constructeur ou administrateur.");
    new Float:player_pos[3], Float:a_pos[3];
	GetPlayerPos(playerid, player_pos[0], player_pos[1], player_pos[2]);
	for(new arbreid = 0; arbreid <= 1000; arbreid++)
	{
	    new afileName[32];
		format(afileName, sizeof(afileName), "arbres/%i.ini", arbreid);
		a_pos[0] = dini_Float(afileName, "posX");
		a_pos[1] = dini_Float(afileName, "posY");
		a_pos[2] = dini_Float(afileName, "posZ");
	    if(IsPlayerInRangeOfPoint(playerid, 3.0, a_pos[0], a_pos[1], a_pos[2]))
	    {
	        DestroyObject(arbreid);
	        dini_Remove(afileName);
			return SendClientMessage(playerid, COLOR_GREEN, "Arbre détruit avec succès.");
	    }
	}
	return 1;
}

CMD:cancel(playerid)
{
	SelectTextDraw(playerid, COLOR_WHITE);
	return 1;
}

CMD:menuiserie(playerid)
{
	if(!IsPlayerInRangeOfPoint(playerid, 6.0, 290.44, 306.34, 999.14))
	{
	    SetPlayerCheckpoint(playerid, -1063.17, 1564.0, 33.02, 2.0);
		return SendClientMessage(playerid, COLOR_RED, "Tu n'es pas au bon endroit, va au checkpoint.");
	}
	//Fond
	fondTD = CreatePlayerTextDraw(playerid, 153.0, 100.0, "_");
    PlayerTextDrawFont(playerid, fondTD, TEXT_DRAW_FONT_MODEL_PREVIEW);
    PlayerTextDrawUseBox(playerid, fondTD, 1);
	PlayerTextDrawBackgroundColor(playerid, fondTD, COLOR_BLUETD);
	PlayerTextDrawTextSize(playerid, fondTD, 480.0, 305.0);
	PlayerTextDrawAlignment(playerid, fondTD, 1);
	PlayerTextDrawSetPreviewModel(playerid, fondTD, 1489);
	PlayerTextDrawShow(playerid, fondTD);
	//Croix de fermeture
	fermerTD = CreatePlayerTextDraw(playerid, 625.0, 95.0, "X");
	PlayerTextDrawUseBox(playerid, fermerTD, 1);
	PlayerTextDrawFont(playerid, fermerTD, 1);
	PlayerTextDrawBoxColor(playerid, fermerTD, COLOR_RED);
	PlayerTextDrawAlignment(playerid, fermerTD, 1);
	PlayerTextDrawSetSelectable(playerid, fermerTD, 1);
	PlayerTextDrawShow(playerid, fermerTD);
	//Petite Echelle
	petitechelleTD = CreatePlayerTextDraw(playerid, 167.0, 115.0, "_");
	PlayerTextDrawFont(playerid, petitechelleTD, TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawBackgroundColor(playerid, petitechelleTD, 147);
	PlayerTextDrawAlignment(playerid, petitechelleTD, 1);
	PlayerTextDrawSetPreviewModel(playerid, petitechelleTD, 1428);
	PlayerTextDrawTextSize(playerid, petitechelleTD, 80.0, 80.0);
 	PlayerTextDrawUseBox(playerid, petitechelleTD, 1);
	PlayerTextDrawSetSelectable(playerid, petitechelleTD, 1);
	PlayerTextDrawShow(playerid, petitechelleTD);
	//Grande Echelle
	grandechelleTD = CreatePlayerTextDraw(playerid, 260.0, 115.0, "_");
	PlayerTextDrawFont(playerid, grandechelleTD, TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawBackgroundColor(playerid, grandechelleTD, 147);
	PlayerTextDrawAlignment(playerid, grandechelleTD, 1);
	PlayerTextDrawSetPreviewModel(playerid, grandechelleTD, 1437);
	PlayerTextDrawTextSize(playerid, grandechelleTD, 80.0, 80.0);
 	PlayerTextDrawUseBox(playerid, grandechelleTD, 1);
	PlayerTextDrawSetSelectable(playerid, grandechelleTD, 1);
	PlayerTextDrawShow(playerid, grandechelleTD);
	//Planches
    planchesTD = CreatePlayerTextDraw(playerid, 353.0, 115.0, "_");
	PlayerTextDrawFont(playerid, planchesTD, TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawBackgroundColor(playerid, planchesTD, 147);
	PlayerTextDrawAlignment(playerid, planchesTD, 1);
	PlayerTextDrawSetPreviewModel(playerid, planchesTD, 1219);
	PlayerTextDrawSetPreviewRot(playerid, planchesTD, 90.0, 0.0, 0.0, 1.0);
	PlayerTextDrawTextSize(playerid, planchesTD, 80.0, 80.0);
 	PlayerTextDrawUseBox(playerid, planchesTD, 1);
	PlayerTextDrawSetSelectable(playerid, planchesTD, 1);
	PlayerTextDrawShow(playerid, planchesTD);
	//Cabane
	cabaneTD = CreatePlayerTextDraw(playerid, 446.0, 115.0, "_");
	PlayerTextDrawFont(playerid, cabaneTD, TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawBackgroundColor(playerid, cabaneTD, 147);
	PlayerTextDrawAlignment(playerid, cabaneTD, 1);
	PlayerTextDrawSetPreviewModel(playerid, cabaneTD, 3417);
	PlayerTextDrawTextSize(playerid, cabaneTD, 80.0, 80.0);
 	PlayerTextDrawUseBox(playerid, cabaneTD, 1);
	PlayerTextDrawSetSelectable(playerid, cabaneTD, 1);
	PlayerTextDrawShow(playerid, cabaneTD);
	//Baton
	batonTD = CreatePlayerTextDraw(playerid, 539.0, 115.0, "_");
	PlayerTextDrawFont(playerid, batonTD, TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawBackgroundColor(playerid, batonTD, 147);
	PlayerTextDrawAlignment(playerid, batonTD, 1);
	PlayerTextDrawSetPreviewModel(playerid, batonTD, 338);
	PlayerTextDrawSetPreviewRot(playerid, batonTD, 0.0, 0.0, 0.0, 2.5);
	PlayerTextDrawTextSize(playerid, batonTD, 80.0, 80.0);
 	PlayerTextDrawUseBox(playerid, batonTD, 1);
	PlayerTextDrawSetSelectable(playerid, batonTD, 1);
	PlayerTextDrawShow(playerid, batonTD);

    SendClientMessage(playerid, COLOR_YELLOW, "Tape \"/cancel\" si tu as quitté le menu avec \"ECHAP\"");
	SelectTextDraw(playerid, COLOR_WHITE);
	return 1;
}

CMD:metallerie(playerid)
{
	//Fond
    fondTD = CreatePlayerTextDraw(playerid, 153.0, 100.0, "_");
    PlayerTextDrawFont(playerid, fondTD, TEXT_DRAW_FONT_MODEL_PREVIEW);
    PlayerTextDrawUseBox(playerid, fondTD, 1);
	PlayerTextDrawBackgroundColor(playerid, fondTD, COLOR_BLUETD);
	PlayerTextDrawTextSize(playerid, fondTD, 480.0, 305.0);
	PlayerTextDrawAlignment(playerid, fondTD, 1);
	PlayerTextDrawSetPreviewModel(playerid, fondTD, 1489);
	PlayerTextDrawShow(playerid, fondTD);
	//Croix de fermeture
	fermerTD = CreatePlayerTextDraw(playerid, 625.0, 95.0, "X");
	PlayerTextDrawUseBox(playerid, fermerTD, 1);
	PlayerTextDrawFont(playerid, fermerTD, 1);
	PlayerTextDrawBoxColor(playerid, fermerTD, COLOR_RED);
	PlayerTextDrawAlignment(playerid, fermerTD, 1);
	PlayerTextDrawSetSelectable(playerid, fermerTD, 1);
	PlayerTextDrawShow(playerid, fermerTD);
	//Coffre
	coffreTD = CreatePlayerTextDraw(playerid, 167.0, 115.0, "_");
	PlayerTextDrawFont(playerid, coffreTD, TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawBackgroundColor(playerid, coffreTD, 147);
	PlayerTextDrawAlignment(playerid, coffreTD, 1);
	PlayerTextDrawSetPreviewModel(playerid, coffreTD, 964);
	PlayerTextDrawTextSize(playerid, coffreTD, 80.0, 80.0);
 	PlayerTextDrawUseBox(playerid, coffreTD, 1);
	PlayerTextDrawSetPreviewRot(playerid, coffreTD, 0.0, 15.0, 30.0, 1.0);
	PlayerTextDrawSetSelectable(playerid, coffreTD, 1);
	PlayerTextDrawShow(playerid, coffreTD);
	//Bidon
	bidonTD = CreatePlayerTextDraw(playerid, 260.0, 115.0, "_");
	PlayerTextDrawFont(playerid, bidonTD, TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawBackgroundColor(playerid, bidonTD, 147);
	PlayerTextDrawAlignment(playerid, bidonTD, 1);
	PlayerTextDrawSetPreviewModel(playerid, bidonTD, 1650);
	PlayerTextDrawTextSize(playerid, bidonTD, 80.0, 80.0);
 	PlayerTextDrawUseBox(playerid, bidonTD, 1);
	PlayerTextDrawSetSelectable(playerid, bidonTD, 1);
	PlayerTextDrawShow(playerid, bidonTD);

    SendClientMessage(playerid, COLOR_YELLOW, "Tape \"/cancel\" si tu as quitté le menu avec \"ECHAP\"");
	SelectTextDraw(playerid, COLOR_WHITE);
}

/*
===================================Script Objets
*/
CMD:obj(playerid, params[])
{
	new objet[16], action[16];
	if(sscanf(params, "ss", objet, action))
	{
	    SendClientMessage(playerid, COLOR_TURQUOISE, "Cabane   |   PetiteEchelle   |   GrandeEchelle   |   Planche");
	    SendClientMessage(playerid, COLOR_TURQUOISE, "Coffre");
		return SendClientMessage(playerid, COLOR_RED, "/obj [nom de l'objet] [placer | recuperer | deplacer]");
	}
	//Cabane
	if(strcmp(objet, "cabane", true) == 0)
	{
		new pName[MAX_PLAYER_NAME], pfileName[48], iCabane;
		GetPlayerName(playerid, pName, sizeof(pName));
		format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
		iCabane = dini_Int(pfileName, "iCabane");
		//Placement de la cabane
		if(strcmp(action, "placer", true) == 0)
		{
			new cfileName[48], cabaneid, Float:p_pos[3], Float:c_pos[6];
			if(iCabane <= 0) return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas de cabane");
			GetPlayerPos(playerid, p_pos[0], p_pos[1], p_pos[2]);
			cabaneid = CreateObject(3417, p_pos[0], p_pos[1], p_pos[2]+0.5, 0, 0, 0, 10000);
			format(cfileName, sizeof(cfileName), "objects/cabanes/%i.ini", cabaneid);
			GetObjectPos(cabaneid, c_pos[0], c_pos[1], c_pos[2]);
			GetObjectRot(cabaneid, c_pos[3], c_pos[4], c_pos[5]);
			dini_Create(cfileName);
			dini_Set(cfileName, "proprio", pName);
			dini_FloatSet(cfileName, "posX", c_pos[0]);
			dini_FloatSet(cfileName, "posY", c_pos[1]);
			dini_FloatSet(cfileName, "posZ", c_pos[2]);
			dini_FloatSet(cfileName, "rotX", c_pos[3]);
			dini_FloatSet(cfileName, "rotY", c_pos[4]);
			dini_FloatSet(cfileName, "rotZ", c_pos[5]);
			dini_IntSet(pfileName, "iCabane", iCabane-1);
			return SendClientMessage(playerid, COLOR_GREEN, "Cabane placée avec succès.");
		}
		//Deplacer
		else if(strcmp(action, "deplacer", true) == 0)
		{
			new cfileName[52], Float:c_pos[3];
	 		for(new cabid = 0; cabid <= 1000; cabid++)
			{
		    	format(cfileName, sizeof(cfileName), "objects/cabanes/%i.ini", cabid);
		    	c_pos[0] = dini_Float(cfileName, "posX");
		    	c_pos[1] = dini_Float(cfileName, "posY");
		    	c_pos[2] = dini_Float(cfileName, "posZ");
 				if(IsPlayerInRangeOfPoint(playerid, 5.0, c_pos[0], c_pos[1], c_pos[2]) == 1)
		    	{
		        	if(strcmp(pName, dini_Get(cfileName, "proprio"), false) != 0) return SendClientMessage(playerid, COLOR_RED, "Cette cabane ne t'appartient pas.");
        			else return EditObject(playerid, cabid);
				}
			}
			return SendClientMessage(playerid, COLOR_RED, "Tu n'es à proximité d'aucune cabane");
		}
		//Récupérer
		else if(strcmp(action, "recuperer", true) == 0)
		{
		    new cfileName[52];
			for(new cabid = 0; cabid <= 1000; cabid++)
			{
				format(cfileName, sizeof(cfileName), "objects/cabanes/%i.ini", cabid);
				new Float:c_pos[3];
				c_pos[0] = dini_Float(cfileName, "posX");
				c_pos[1] = dini_Float(cfileName, "posY");
				c_pos[2] = dini_Float(cfileName, "posZ");
				if(IsPlayerInRangeOfPoint(playerid, 5.0, c_pos[0], c_pos[1], c_pos[2]) == 1)
				{
					if(strcmp(pName, dini_Get(cfileName, "proprio"), true) != 0) return SendClientMessage(playerid, COLOR_RED, "Cette cabane ne t'appartient pas.");
					DestroyObject(cabid);
					dini_Remove(cfileName);
					dini_IntSet(pfileName, "iCabane", iCabane+1);
			    	return SendClientMessage(playerid, COLOR_GREEN, "Tu as récupéré ta cabane.");
				}
			}
			return SendClientMessage(playerid, COLOR_RED, "Tu n'es à proximité d'aucune cabanes.");
		}
		return SendClientMessage(playerid, COLOR_RED, "Utilise \"/obj cabane [placer | recuperer | deplacer]\"");
	}
	//Petite Echelle
	if(strcmp(objet, "PetiteEchelle", true) == 0)
	{
		new pName[MAX_PLAYER_NAME], pfileName[48], ipEchelle;
		GetPlayerName(playerid, pName, sizeof(pName));
		format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
		ipEchelle = dini_Int(pfileName, "ipEchelle");
		//Placement de la petite échelle
		if(strcmp(action, "placer", true) == 0)
		{
			new pefileName[48], pechelleid, Float:p_pos[3], Float:e_pos[6];
			if(ipEchelle <= 0) return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas de petite échelle.");
			GetPlayerPos(playerid, p_pos[0], p_pos[1], p_pos[2]);
			pechelleid = CreateObject(1428, p_pos[0]+0.5, p_pos[1]+0.5, p_pos[2]+0.5, 0, 0, 0, 10000);
			format(pefileName, sizeof(pefileName), "objects/pechelles/%i.ini", pechelleid);
			GetObjectPos(pechelleid, e_pos[0], e_pos[1], e_pos[2]);
			GetObjectRot(pechelleid, e_pos[3], e_pos[4], e_pos[5]);
			dini_Create(pefileName);
			dini_Set(pefileName, "proprio", pName);
			dini_FloatSet(pefileName, "posX", e_pos[0]);
			dini_FloatSet(pefileName, "posY", e_pos[1]);
			dini_FloatSet(pefileName, "posZ", e_pos[2]);
			dini_FloatSet(pefileName, "rotX", e_pos[3]);
			dini_FloatSet(pefileName, "rotY", e_pos[4]);
			dini_FloatSet(pefileName, "rotZ", e_pos[5]);
			dini_IntSet(pfileName, "ipEchelle", ipEchelle-1);
			return SendClientMessage(playerid, COLOR_GREEN, "Petite échelle placée avec succès.");
		}
		//Deplacer
		else if(strcmp(action, "deplacer", true) == 0)
		{
			new pefileName[52], Float:e_pos[3];
	 		for(new pechelleid = 0; pechelleid <= 1000; pechelleid++)
			{
			    format(pefileName, sizeof(pefileName), "objects/pechelles/%i.ini", pechelleid);
		   		e_pos[0] = dini_Float(pefileName, "posX");
			    e_pos[1] = dini_Float(pefileName, "posY");
		    	e_pos[2] = dini_Float(pefileName, "posZ");
 				if(IsPlayerInRangeOfPoint(playerid, 5.0, e_pos[0], e_pos[1], e_pos[2]) == 1)
		    	{
		        	if(strcmp(pName, dini_Get(pefileName, "proprio"), false) != 0) return SendClientMessage(playerid, COLOR_RED, "Cette petite échelle ne t'appartient pas.");
        			else return EditObject(playerid, pechelleid);
				}
			}
			return SendClientMessage(playerid, COLOR_RED, "Tu n'es à proximité d'aucune échelle");
		}
		//Récupérer
		else if(strcmp(action, "recuperer", true) == 0)
		{
		    new pefileName[52];
			for(new pechelleid = 0; pechelleid <= 1000; pechelleid++)
			{
				format(pefileName, sizeof(pefileName), "objects/pechelles/%i.ini", pechelleid);
				new Float:e_pos[3];
				e_pos[0] = dini_Float(pefileName, "posX");
				e_pos[1] = dini_Float(pefileName, "posY");
				e_pos[2] = dini_Float(pefileName, "posZ");
				if(IsPlayerInRangeOfPoint(playerid, 5.0, e_pos[0], e_pos[1], e_pos[2]) == 1)
				{
					if(strcmp(pName, dini_Get(pefileName, "proprio"), true) != 0) return SendClientMessage(playerid, COLOR_RED, "Cette petite échelle ne t'appartient pas.");
					DestroyObject(pechelleid);
					dini_Remove(pefileName);
					dini_IntSet(pfileName, "ipEchelle", ipEchelle+1);
			  	  	return SendClientMessage(playerid, COLOR_GREEN, "Tu as récupéré ta petite échelle.");
				}
			}
			return SendClientMessage(playerid, COLOR_RED, "Tu n'es à proximité d'aucune petite échelle.");
		}
		return SendClientMessage(playerid, COLOR_RED, "Utilise \"/obj PetiteEchelle [placer | recuperer | deplacer]\"");
	}
	//Grande Echelle
	if(strcmp(objet, "GrandeEchelle", true) == 0)
	{
		new pName[MAX_PLAYER_NAME], pfileName[48], igEchelle;
		GetPlayerName(playerid, pName, sizeof(pName));
		format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
		igEchelle = dini_Int(pfileName, "igEchelle");
		//Placement de la petite échelle
		if(strcmp(action, "placer", true) == 0)
		{
			new gefileName[48], gechelleid, Float:p_pos[3], Float:e_pos[6];
			if(igEchelle <= 0) return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas de grande échelle.");
			GetPlayerPos(playerid, p_pos[0], p_pos[1], p_pos[2]);
			gechelleid = CreateObject(1437, p_pos[0]+0.5, p_pos[1]+0.5, p_pos[2]+0.5, 0, 0, 0, 10000);
			format(gefileName, sizeof(gefileName), "objects/gechelles/%i.ini", gechelleid);
			GetObjectPos(gechelleid, e_pos[0], e_pos[1], e_pos[2]);
			GetObjectRot(gechelleid, e_pos[3], e_pos[4], e_pos[5]);
			dini_Create(gefileName);
			dini_Set(gefileName, "proprio", pName);
			dini_FloatSet(gefileName, "posX", e_pos[0]);
			dini_FloatSet(gefileName, "posY", e_pos[1]);
			dini_FloatSet(gefileName, "posZ", e_pos[2]);
			dini_FloatSet(gefileName, "rotX", e_pos[3]);
			dini_FloatSet(gefileName, "rotY", e_pos[4]);
			dini_FloatSet(gefileName, "rotZ", e_pos[5]);
			dini_IntSet(pfileName, "igEchelle", igEchelle-1);
			return SendClientMessage(playerid, COLOR_GREEN, "Grande échelle placée avec succès.");
		}
		//Deplacer
		else if(strcmp(action, "deplacer", true) == 0)
		{
			new gefileName[52], Float:e_pos[3];
	 		for(new gechelleid = 0; gechelleid <= 1000; gechelleid++)
			{
			    format(gefileName, sizeof(gefileName), "objects/gechelles/%i.ini", gechelleid);
		   		e_pos[0] = dini_Float(gefileName, "posX");
			    e_pos[1] = dini_Float(gefileName, "posY");
		    	e_pos[2] = dini_Float(gefileName, "posZ");
 				if(IsPlayerInRangeOfPoint(playerid, 5.0, e_pos[0], e_pos[1], e_pos[2]) == 1)
		    	{
		        	if(strcmp(pName, dini_Get(gefileName, "proprio"), false) != 0) return SendClientMessage(playerid, COLOR_RED, "Cette petite échelle ne t'appartient pas.");
        			else return EditObject(playerid, gechelleid);
				}
			}
			return SendClientMessage(playerid, COLOR_RED, "Tu n'es à proximité d'aucune échelle");
		}
		//Récupérer
		else if(strcmp(action, "recuperer", true) == 0)
		{
		    new gefileName[52];
			for(new gechelleid = 0; gechelleid <= 1000; gechelleid++)
			{
				format(gefileName, sizeof(gefileName), "objects/gechelles/%i.ini", gechelleid);
				new Float:e_pos[3];
				e_pos[0] = dini_Float(gefileName, "posX");
				e_pos[1] = dini_Float(gefileName, "posY");
				e_pos[2] = dini_Float(gefileName, "posZ");
				if(IsPlayerInRangeOfPoint(playerid, 5.0, e_pos[0], e_pos[1], e_pos[2]) == 1)
				{
					if(strcmp(pName, dini_Get(gefileName, "proprio"), true) != 0) return SendClientMessage(playerid, COLOR_RED, "Cette petite échelle ne t'appartient pas.");
					DestroyObject(gechelleid);
					dini_Remove(gefileName);
					dini_IntSet(pfileName, "igEchelle", igEchelle+1);
			  	  	return SendClientMessage(playerid, COLOR_GREEN, "Tu as récupéré ta grande échelle.");
				}
			}
			return SendClientMessage(playerid, COLOR_RED, "Tu n'es à proximité d'aucune grande échelle.");
		}
		return SendClientMessage(playerid, COLOR_RED, "Utilise \"/obj GrandeEchelle [placer | recuperer | deplacer]\"");
	}
	//Coffre
	if(strcmp(objet, "Coffre", true) == 0)
	{
		new pName[MAX_PLAYER_NAME], pfileName[48], iCoffre;
		GetPlayerName(playerid, pName, sizeof(pName));
		format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
		iCoffre = dini_Int(pfileName, "iCoffre");
		//Placer
		if(strcmp(action, "placer", true) == 0)
		{
			new gefileName[48], coffreid, Float:p_pos[3], Float:e_pos[6], strSlotName[48], strSlotAmmo[48];
			if(iCoffre <= 0) return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas de coffre.");
			GetPlayerPos(playerid, p_pos[0], p_pos[1], p_pos[2]);
			coffreid = CreateObject(964, p_pos[0]+1.5, p_pos[1]+1.5, p_pos[2]-0.5, 0, 0, 0, 10000);
			format(gefileName, sizeof(gefileName), "objects/coffres/%i.ini", coffreid);
			GetObjectPos(coffreid, e_pos[0], e_pos[1], e_pos[2]);
			GetObjectRot(coffreid, e_pos[3], e_pos[4], e_pos[5]);
			dini_Create(gefileName);
			dini_Set(gefileName, "proprio", pName);
			dini_FloatSet(gefileName, "posX", e_pos[0]);
			dini_FloatSet(gefileName, "posY", e_pos[1]);
			dini_FloatSet(gefileName, "posZ", e_pos[2]);
			dini_FloatSet(gefileName, "rotX", e_pos[3]);
			dini_FloatSet(gefileName, "rotY", e_pos[4]);
			dini_FloatSet(gefileName, "rotZ", e_pos[5]);
			dini_IntSet(pfileName, "iCoffre", iCoffre-1);
			for(new slot = 1; slot <= 5; slot++)
			{
				format(strSlotName, sizeof(strSlotName), "slot%iName", slot);
				format(strSlotAmmo, sizeof(strSlotAmmo), "slot%iAmmo", slot);
				dini_Set(gefileName, strSlotName, "Aucune");
				dini_IntSet(gefileName, strSlotAmmo, 0);
			}
			return SendClientMessage(playerid, COLOR_GREEN, "Coffre placé avec succès.");
		}
		//Deplacer
		else if(strcmp(action, "deplacer", true) == 0)
		{
			new gefileName[52], Float:e_pos[3];
	 		for(new coffreid = 0; coffreid <= 1000; coffreid++)
			{
			    format(gefileName, sizeof(gefileName), "objects/coffres/%i.ini", coffreid);
		   		e_pos[0] = dini_Float(gefileName, "posX");
			    e_pos[1] = dini_Float(gefileName, "posY");
		    	e_pos[2] = dini_Float(gefileName, "posZ");
 				if(IsPlayerInRangeOfPoint(playerid, 5.0, e_pos[0], e_pos[1], e_pos[2]) == 1)
		    	{
		        	if(strcmp(pName, dini_Get(gefileName, "proprio"), false) != 0) return SendClientMessage(playerid, COLOR_RED, "Ce coffre ne t'appartient pas.");
        			else return EditObject(playerid, coffreid);
				}
			}
			return SendClientMessage(playerid, COLOR_RED, "Tu n'es à proximité d'aucun coffre.");
		}
		//Récupérer
		else if(strcmp(action, "recuperer", true) == 0)
		{
		    new gefileName[52];
			for(new coffreid = 0; coffreid <= 1000; coffreid++)
			{
				format(gefileName, sizeof(gefileName), "objects/coffres/%i.ini", coffreid);
				new Float:e_pos[3];
				e_pos[0] = dini_Float(gefileName, "posX");
				e_pos[1] = dini_Float(gefileName, "posY");
				e_pos[2] = dini_Float(gefileName, "posZ");
				if(IsPlayerInRangeOfPoint(playerid, 5.0, e_pos[0], e_pos[1], e_pos[2]) == 1)
				{
					if(strcmp(pName, dini_Get(gefileName, "proprio"), true) != 0) return SendClientMessage(playerid, COLOR_RED, "Ce coffre ne t'appartient pas.");
					DestroyObject(coffreid);
					dini_Remove(gefileName);
					dini_IntSet(pfileName, "iCoffre", iCoffre+1);
			  	  	return SendClientMessage(playerid, COLOR_GREEN, "Tu as récupéré ton coffre.");
				}
			}
			return SendClientMessage(playerid, COLOR_RED, "Tu n'es à proximité d'aucun coffre.");
		}
		return SendClientMessage(playerid, COLOR_RED, "Utilise \"/obj Coffre [placer | recuperer | deplacer]\"");
	}
	else
	{
	    SendClientMessage(playerid, COLOR_TURQUOISE, "Cabane   |   PetiteEchelle   |   GrandeEchelle   |   Planche");
	    SendClientMessage(playerid, COLOR_TURQUOISE, "Coffre");
		return SendClientMessage(playerid, COLOR_RED, "/obj [nom de l'objet] [placer | recuperer | deplacer]");
	}
}

CMD:mcoffre(playerid, params[])
{
	if(isnull(params))
	{
	    new cofileName[48];
	    for(new coffreid = 0; coffreid <= 1000; coffreid++)
		{
			format(cofileName, sizeof(cofileName), "objects/coffres/%i.ini", coffreid);
			new Float:co_pos[3];
			co_pos[0] = dini_Float(cofileName, "posX");
			co_pos[1] = dini_Float(cofileName, "posY");
			co_pos[2] = dini_Float(cofileName, "posZ");
			if(IsPlayerInRangeOfPoint(playerid, 5.0, co_pos[0], co_pos[1], co_pos[2]) == 1)
			{
			    new pName[MAX_PLAYER_NAME], strSlot1[48], strSlot2[48], strSlot3[48], strSlot4[48], strSlot5[48];
			    GetPlayerName(playerid, pName, sizeof(pName));
				if(strcmp(pName, dini_Get(cofileName, "proprio"), true) != 0) return SendClientMessage(playerid, COLOR_RED, "Ce coffre ne t'appartient pas.");
				format(strSlot1, sizeof(strSlot1), "1 | %s | Munitions : %i", dini_Get(cofileName, "slot1Name"), dini_Int(cofileName, "slot1Ammo"));
				format(strSlot2, sizeof(strSlot2), "2 | %s | Munitions : %i", dini_Get(cofileName, "slot2Name"), dini_Int(cofileName, "slot2Ammo"));
				format(strSlot3, sizeof(strSlot3), "3 | %s | Munitions : %i", dini_Get(cofileName, "slot3Name"), dini_Int(cofileName, "slot3Ammo"));
				format(strSlot4, sizeof(strSlot4), "4 | %s | Munitions : %i", dini_Get(cofileName, "slot4Name"), dini_Int(cofileName, "slot4Ammo"));
				format(strSlot5, sizeof(strSlot5), "5 | %s | Munitions : %i", dini_Get(cofileName, "slot5Name"), dini_Int(cofileName, "slot5Ammo"));
				SendClientMessage(playerid, COLOR_YELLOW, strSlot1);
				SendClientMessage(playerid, COLOR_YELLOW, strSlot2);
				SendClientMessage(playerid, COLOR_YELLOW, strSlot3);
				SendClientMessage(playerid, COLOR_YELLOW, strSlot4);
				SendClientMessage(playerid, COLOR_YELLOW, strSlot5);
				return SendClientMessage(playerid, COLOR_RED, "Utilise \"/mcoffre [ranger | prendre] [1-5]\"");
			}
		}
		return SendClientMessage(playerid, COLOR_RED, "Il n'y a aucun coffre près de toi.");
	}
	new strAction[16], nbSlot;
	sscanf(params, "si", strAction, nbSlot);
	if(nbSlot < 1 || nbSlot > 5) return SendClientMessage(playerid, COLOR_RED, "Slot invalide.");
	//Ranger
	if(strcmp(strAction, "ranger", true) == 0)
	{
        new cofileName[48];
	    for(new coffreid = 0; coffreid <= 1000; coffreid++)
		{
			format(cofileName, sizeof(cofileName), "objects/coffres/%i.ini", coffreid);
			new Float:co_pos[3];
			co_pos[0] = dini_Float(cofileName, "posX");
			co_pos[1] = dini_Float(cofileName, "posY");
			co_pos[2] = dini_Float(cofileName, "posZ");
			if(IsPlayerInRangeOfPoint(playerid, 2.5, co_pos[0], co_pos[1], co_pos[2]) == 1)
			{
			    new pName[MAX_PLAYER_NAME];
				GetPlayerName(playerid, pName, sizeof(pName));
				if(strcmp(pName, dini_Get(cofileName, "proprio")) != 0) return SendClientMessage(playerid, COLOR_RED, "Ce coffre ne t'appartient pas.");
				for(new weaponSlot = 0; weaponSlot <= 12; weaponSlot++)
				{
				    new weaponid, weaponAmmo, slotName[32], slotAmmo[32], slotid[32];
					GetPlayerWeaponData(playerid, weaponSlot, weaponid, weaponAmmo);
					if(weaponid == 0) continue;
					format(slotName, sizeof(slotName), "slot%iName", nbSlot);
					format(slotid, sizeof(slotid), "slot%iid", nbSlot);
					format(slotAmmo, sizeof(slotAmmo), "slot%iAmmo", nbSlot);
					if(dini_Int(cofileName, slotAmmo) > 0) return SendClientMessage(playerid, COLOR_RED, "Il y a déjà une arme dans ce slot.");
					if(weaponid == 2) dini_Set(cofileName, slotName, "Club de golf");
					else if(weaponid == 3) dini_Set(cofileName, slotName, "Matraque");
					else if(weaponid == 4) dini_Set(cofileName, slotName, "Couteau");
					else if(weaponid == 5) dini_Set(cofileName, slotName, "Batte de Baseball");
					else if(weaponid == 6) dini_Set(cofileName, slotName, "Pelle");
					else if(weaponid == 7) dini_Set(cofileName, slotName, "Queue de billard");
					else if(weaponid == 8) dini_Set(cofileName, slotName, "Katana");
					else if(weaponid == 9) dini_Set(cofileName, slotName, "Tronçonneuse");
					else if(weaponid == 10) dini_Set(cofileName, slotName, "Double God");
					else if(weaponid == 11) dini_Set(cofileName, slotName, "God");
					else if(weaponid == 12) dini_Set(cofileName, slotName, "Vibromasseur");
					else if(weaponid == 13) dini_Set(cofileName, slotName, "Vinromasseur en argent");
					else if(weaponid == 14) dini_Set(cofileName, slotName, "Bouquet de fleurs");
					else if(weaponid == 15) dini_Set(cofileName, slotName, "Canne");
					else if(weaponid == 16) dini_Set(cofileName, slotName, "Grenade");
					else if(weaponid == 17) dini_Set(cofileName, slotName, "Grenade fumigène");
					else if(weaponid == 18) dini_Set(cofileName, slotName, "Cocktail Molotov");
					else if(weaponid == 22) dini_Set(cofileName, slotName, "Colt");
					else if(weaponid == 23) dini_Set(cofileName, slotName, "Colt silencieux");
					else if(weaponid == 24) dini_Set(cofileName, slotName, "Deagle");
					else if(weaponid == 25) dini_Set(cofileName, slotName, "Fusil à pompe");
					else if(weaponid == 26) dini_Set(cofileName, slotName, "Canon scié");
					else if(weaponid == 27) dini_Set(cofileName, slotName, "Fusil de combat");
					else if(weaponid == 28) dini_Set(cofileName, slotName, "Uzi");
					else if(weaponid == 29) dini_Set(cofileName, slotName, "MP5");
					else if(weaponid == 30) dini_Set(cofileName, slotName, "AK-47");
					else if(weaponid == 31) dini_Set(cofileName, slotName, "M4");
					else if(weaponid == 32) dini_Set(cofileName, slotName, "Tec-9");
					else if(weaponid == 33) dini_Set(cofileName, slotName, "Rifle");
					else if(weaponid == 34) dini_Set(cofileName, slotName, "Sniper");
					else if(weaponid == 39) dini_Set(cofileName, slotName, "C4");
					else if(weaponid == 41) dini_Set(cofileName, slotName, "Bombe de tag");
					else if(weaponid == 42) dini_Set(cofileName, slotName, "Extincteur");
					else if(weaponid == 43) dini_Set(cofileName, slotName, "Appareil photo");
					else if(weaponid == 46) dini_Set(cofileName, slotName, "Parachute");
					else return SendClientMessage(playerid, COLOR_RED, "Tu ne peux pas stocké cette arme dans ce coffre.");
					dini_IntSet(cofileName, slotid, weaponid);
					dini_IntSet(cofileName, slotAmmo, weaponAmmo);
					RemovePlayerWeapon(playerid, weaponid);
					SetPlayerArmedWeapon(playerid, 0);
					return SendClientMessage(playerid, COLOR_GREEN, "Arme rangée avec succès.");
				}
				return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas d'arme à mettre dans le coffre.");
			}
		}
	}
	//Prendre
	if(strcmp(strAction, "prendre", true) == 0)
	{
	    new cofileName[48];
	    for(new coffreid = 0; coffreid <= 1000; coffreid++)
		{
			format(cofileName, sizeof(cofileName), "objects/coffres/%i.ini", coffreid);
			new Float:co_pos[3];
			co_pos[0] = dini_Float(cofileName, "posX");
			co_pos[1] = dini_Float(cofileName, "posY");
			co_pos[2] = dini_Float(cofileName, "posZ");
			if(IsPlayerInRangeOfPoint(playerid, 5.0, co_pos[0], co_pos[1], co_pos[2]) == 1)
			{
			    new pName[MAX_PLAYER_NAME], weaponid, weaponAmmo, slotid[32], slotAmmo[32], slotName[32];
				GetPlayerName(playerid, pName, sizeof(pName));
				if(strcmp(pName, dini_Get(cofileName, "proprio")) != 0) return SendClientMessage(playerid, COLOR_RED, "Ce coffre ne t'appartient pas.");
				format(slotName, sizeof(slotName), "slot%iName", nbSlot);
				format(slotid, sizeof(slotid), "slot%iid", nbSlot);
				format(slotAmmo, sizeof(slotAmmo), "slot%iAmmo", nbSlot);
				weaponid = dini_Int(cofileName, slotid);
				weaponAmmo = dini_Int(cofileName, slotAmmo);
				if(weaponid == 0) return SendClientMessage(playerid, COLOR_RED, "Il n'y a rien dans ce slot.");
				GivePlayerWeapon(playerid, weaponid, weaponAmmo);
				dini_Set(cofileName, slotName, "Aucune");
				dini_IntSet(cofileName, slotid, 0);
				dini_IntSet(cofileName, slotAmmo, 0);
				return SendClientMessage(playerid, COLOR_GREEN, "Arme récupérée.");
			}
		}
	}
	return 1;
}

CMD:donner(playerid, params[])
{
	new strObject[16], strParams[32];
	if(isnull(params) || sscanf(params, "ss", strObject, strParams)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/donner [arme | argent | bidon]\"");
	//Armes
	if(strcmp(strObject, "arme", true) == 0)
	{
		new teleid, Float:t_pos[3];
		teleid = strval(strParams);
		if(!IsPlayerConnected(teleid)) return SendClientMessage(playerid, COLOR_RED, "Ce joueur n'est pas connecté.");
		GetPlayerPos(teleid, t_pos[0], t_pos[1], t_pos[2]);
		if(!IsPlayerInRangeOfPoint(playerid, 3.0, t_pos[0], t_pos[1], t_pos[2])) return SendClientMessage(playerid, COLOR_RED, "Ce joueur est trop éloigné.");
		new weaponid, weaponidData, weaponAmmo, weaponSlotTele, weaponidTele, weaponAmmoTele;
		weaponid = GetPlayerWeapon(playerid);
		if(weaponid == 0) return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas d'arme en main.");
		for(new weaponSlot; weaponSlot <= 12; weaponSlot++)
		{
			GetPlayerWeaponData(playerid, weaponSlot, weaponidData, weaponAmmo);
			if(weaponid == weaponidData)
			{
				if(weaponid == 0 || weaponid == 1) weaponSlotTele = 0;
				else if(weaponid >=2 && weaponid <=9) weaponSlotTele = 1;
				else if(weaponid >=10 && weaponid <=15) weaponSlotTele = 10;
				else if(weaponid >=16 && weaponid <=18 || weaponid == 39) weaponSlotTele = 8;
				else if(weaponid >=22 && weaponid <=24) weaponSlotTele = 2;
				else if(weaponid >=25 && weaponid <=27) weaponSlotTele = 3;
				else if(weaponid >=28 && weaponid <=29 || weaponid == 32) weaponSlotTele = 4;
				else if(weaponid >=30 && weaponid <=31) weaponSlotTele = 5;
				else if(weaponid >=33 && weaponid <=34) weaponSlotTele = 6;
				else if(weaponid >=35 && weaponid <=38) weaponSlotTele = 7;
				else if(weaponid >=41 && weaponid <=43) weaponSlotTele = 9;
				GetPlayerWeaponData(teleid, weaponSlotTele, weaponidTele, weaponAmmoTele);
				if(weaponidTele != 0) return SendClientMessage(playerid, COLOR_RED, "Ce joueur a déjà une arme dans ce slot.");

				new pName[MAX_PLAYER_NAME], tName[MAX_PLAYER_NAME], msgTele[64], msgPlayer[64];
				GivePlayerWeapon(teleid, weaponid, weaponAmmo);
				RemovePlayerWeapon(playerid, weaponid);
				GetPlayerName(playerid, pName, sizeof(pName));
				GetPlayerName(teleid, tName, sizeof(tName));
				format(msgPlayer, sizeof(msgPlayer), "Tu as donné ton arme à %s.", tName);
				format(msgTele, sizeof(msgTele), "%s t'a donné une arme.", pName);
				SendClientMessage(playerid, COLOR_GREEN, msgPlayer);
				SendClientMessage(teleid, COLOR_GREEN, msgTele);
				return 1;
			}
		}
	}
	//Argent
	else if(strcmp(strObject, "argent", true) == 0)
	{
	    new montant, teleid, playerMoney, Float:t_pos[3];
		if(sscanf(strParams, "ii", teleid, montant)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/donner argent [ID du joueur] [montant]\"");
		if(!IsPlayerConnected(teleid)) return SendClientMessage(playerid, COLOR_RED, "Ce joueur n'est pas connecté.");
		GetPlayerPos(teleid, t_pos[0], t_pos[1], t_pos[2]);
		if(!IsPlayerInRangeOfPoint(playerid, 3.0, t_pos[0], t_pos[1], t_pos[2])) return SendClientMessage(playerid, COLOR_RED, "Ce joueur n'est pas près de toi.");
		playerMoney = GetPlayerMoney(playerid);
		if(playerMoney >= montant)
		{
	    	new strPlayer[64], strTele[64], pName[MAX_PLAYER_NAME], tName[MAX_PLAYER_NAME];
	    	GetPlayerName(teleid, tName, sizeof(tName));
	    	GetPlayerName(playerid, pName, sizeof(pName));
	    	format(strPlayer, sizeof(strPlayer), "Tu as donné %i $ à %s.", montant, tName);
	    	format(strTele, sizeof(strTele), "Tu as reçu %i $ de %s.", montant, pName);
			GivePlayerMoney(teleid, montant);
			GivePlayerMoney(playerid, -montant);
			SendClientMessage(playerid, COLOR_GREEN, strPlayer);
			SendClientMessage(teleid, COLOR_GREEN, strTele);
		}
		else return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas assez d'argent sur toi.");
	}
	//Bidon
	else if(strcmp(strObject, "bidon", true) == 0)
	{
	    new teleid, strCarburant[16], iBidonLitreCMD, msgTele[128], msgPlayer[128], pName[MAX_PLAYER_NAME], tName[MAX_PLAYER_NAME], pfileName[48], tfileName[48], iBidonTypeCMD, iBidonTypePlayer, iBidonLitrePlayer, iBidonTypeTele, iBidonLitreTele;
	    if(sscanf(strParams, "isi", teleid, strCarburant, iBidonLitreCMD)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/donner bidon [ID du joueur] [Type de liquide] [Nombre de litres]\"");
		if(iBidonLitreCMD < 1) return SendClientMessage(playerid, COLOR_RED, "Tu ne peux pas donner si peu de carburant");
		GetPlayerName(playerid, pName, sizeof(pName));
		GetPlayerName(teleid, tName, sizeof(tName));
		format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
		format(tfileName, sizeof(tfileName), "players/%s.ini", tName);
		if(strcmp(strCarburant, "diesel", true) == 0) iBidonTypeCMD = 1;
		else if(strcmp(strCarburant, "kerozen", true) == 0) iBidonTypeCMD = 2;
		else if(strcmp(strCarburant, "eau", true) == 0) iBidonTypeCMD = 4;
		//Verifications sur le donneur
		iBidonTypePlayer = dini_Int(pfileName, "iBidonType");
		iBidonLitrePlayer = dini_Int(pfileName, "iBidonLitre");
		if(iBidonTypePlayer != iBidonTypeCMD) return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas ce carburant dans ton bidon.");
		if(iBidonLitrePlayer < iBidonLitreCMD) return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas autant de carburant dans ton bidon.");
		if(iBidonLitrePlayer - iBidonLitreCMD < 0) return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas autant de carburant dans ton bidon.");
		//Verifications sur le receveur
		iBidonTypeTele = dini_Int(tfileName, "iBidonType");
		iBidonLitreTele = dini_Int(tfileName, "iBidonLitre");
		if(iBidonTypeTele != iBidonTypeCMD) return SendClientMessage(playerid, COLOR_RED, "Ce joueur n'a pas de bidon vide.");
		if(iBidonTypeTele != 10) return SendClientMessage(playerid, COLOR_RED, "Le bidon de ce joueur n'est pas vide.");
		if(iBidonLitreCMD + iBidonLitreTele > 30) return SendClientMessage(playerid, COLOR_RED, "Le bidon de ce joueur ne peut pas contenir une aussi grande quantité.");
		//Enlevement du bidon ou de la quantité au donneur
		dini_IntSet(pfileName, "iBidonLitre", iBidonLitrePlayer-iBidonLitreCMD);
		if(iBidonLitrePlayer - iBidonLitreCMD == 0) dini_IntSet(pfileName, "iBidonType", 10);
		//Ajout des paramètres au receveur
		dini_IntSet(tfileName, "iBidonType", iBidonTypeCMD);
		dini_IntSet(tfileName, "iBidonLitre", iBidonLitreTele + iBidonLitreCMD);
		//Envoie des messages
		format(msgPlayer, sizeof(msgPlayer), "Tu as donné %iL de %s à %s.", iBidonLitreCMD, strCarburant, tName);
		format(msgTele, sizeof(msgTele), "%s t'a donné %iL de %s.", pName, iBidonLitreCMD, strCarburant);
		SendClientMessage(playerid, COLOR_GREEN, msgPlayer);
		SendClientMessage(teleid, COLOR_GREEN, msgTele);
	}
	else
	{
	    SendClientMessage(playerid, COLOR_RED, "Utilise \"/donner [arme | argent | bidon]\"");
	}
	return 1;
}

CMD:bidon(playerid, params[])
{
	new strAction[16], strCarburant[16], litre;
	sscanf(params, "ssi", strAction, strCarburant, litre);
	if(isnull(strAction)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/bidon [remplir | vider] [Diesel | Kerozen | Eau] [Nombre de litres]\"");
	new pName[MAX_PLAYER_NAME], pfileName[48];
	GetPlayerName(playerid, pName, sizeof(pName));
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	if(strcmp(strAction, "remplir", true) == 0)
	{
	    new iBidonType, iBidonLitre, totLitre;
		if(isnull(strCarburant) || litre == 0) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/bidon remplir [Diesel | Kerozen | Eau] [Nombre de litres]\"");
	    iBidonType = dini_Int(pfileName, "iBidonType");
	    iBidonLitre = dini_Int(pfileName, "iBidonLitre");
	    totLitre = iBidonLitre + litre;
	    if(iBidonType != 10) return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas de bidon vide.");
	    if(totLitre > 30) return SendClientMessage(playerid, COLOR_RED, "Tu ne peux pas en mettre autant dans un bidon(30L maximum)");
		if(strcmp(strCarburant, "diesel", true) == 0) dini_IntSet(pfileName, "iBidonType", 1);
		else if(strcmp(strCarburant, "kerozen", true) == 0) dini_IntSet(pfileName, "iBidonType", 2);
		else if(strcmp(strCarburant, "eau", true) == 0)
		{
		    if(IsPlayerInRangeOfPoint(playerid, 20.0, -919.0, 2021.0, 61.0))
		    {
		        dini_IntSet(pfileName, "iBidonType", 4);
				new barEau = dini_Int("barrage.ini", "barEau");
				dini_IntSet("barrage.ini", "barEau", barEau-litre);
		    }
		    else
		    {
		        SetPlayerCheckpoint(playerid, -919.0, 2021.0, 61.0, 3.0);
		        return SendClientMessage(playerid, COLOR_RED, "Tu n'es pas à la réserve, va au checkpoint.");
		    }
		}
		else return SendClientMessage(playerid, COLOR_RED, "Utilise \"/bidon remplir [Diesel | Kerozen | Eau] [Nombre de litres]\"");
		dini_IntSet(pfileName, "iBidonLitre", totLitre);
	    SendClientMessage(playerid, COLOR_GREEN, "Tu as rempli ton bidon.");
	}
	else if(strcmp(strAction, "vider", true) == 0)
	{
	    if(dini_Int(pfileName, "iBidonType") == 0) return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas de bidon.");
	    dini_IntSet(pfileName, "iBidonType", 10);
	    dini_IntSet(pfileName, "iBidonLitre", 0);
	    SendClientMessage(playerid, COLOR_GREEN, "Tu as vidé ton bidon.");
	}
	return 1;
}

/*
===================================Script Soigneur
*/
CMD:soigner(playerid, params[])
{
	new teleid, montant, msgPlayer[128], msgTele[128];
	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/soigner [ID du joueur] [montant]\".");
	if(sscanf(params, "ii", teleid, montant)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/soigner [ID du joueur] [montant]\".");
	if(GetPlayerTeam(playerid) != 3) return SendClientMessage(playerid, COLOR_RED, "Tu n'es pas médecin(/job [job]).");
	if(montant < 0) return SendClientMessage(playerid, COLOR_RED, "Tu ne peux pas mettre un montant négatif.");
	if(teleid == playerid) return SendClientMessage(playerid, COLOR_RED, "Tu ne peux pas te soigner toi-même.");
	new tName[MAX_PLAYER_NAME], tfileName[48], pName[MAX_PLAYER_NAME];
 	GetPlayerName(teleid, tName, sizeof(tName));
 	GetPlayerName(playerid, pName, sizeof(pName));
	format(tfileName, sizeof(tfileName), "players/%s.ini", tName);
	dini_IntSet(tfileName, "accVendeurID", playerid);
	dini_IntSet(tfileName, "accMontant", montant);
	format(msgPlayer, sizeof(msgPlayer), "Tu proposes tes soins à %s pour %i$.", tName, montant);
	format(msgTele, sizeof(msgTele), "%s te propose des soins pour %i$.(/accepter soigner)", pName, montant);
	SendClientMessage(playerid, COLOR_GREEN, msgPlayer);
	SendClientMessage(teleid, COLOR_GREEN, msgTele);
	return 1;
}

/*
===================================Script mineur
*/
CMD:miner(playerid, params[])
{
	if(GetPlayerSkin(playerid) != 27) return SendClientMessage(playerid, COLOR_RED, "Tu dois être équipé d'une tenue et d'une pelle pour pouvoir miner.");
	if(GetPlayerTeam(playerid) != 4) return SendClientMessage(playerid, COLOR_RED, "Tu dois être mineur.(/job mineur)");
	if(IsPlayerInAnyVehicle(playerid) == 1) return SendClientMessage(playerid, COLOR_RED, "Tu dois descendre de ton véhicule.");
	if(isnull(params))
	{
	    SendClientMessage(playerid, COLOR_YELLOW, "             Minerais disponibles :");
		return SendClientMessage(playerid, COLOR_TURQUOISE, "Fer   |   Pierre   |   Cuivre   |   Charbon");
	}
	//Fer
	else if(strcmp(params, "fer", true) == 0)
	{
		new pfileName[48], pName[MAX_PLAYER_NAME];
		GetPlayerName(playerid, pName, sizeof(pName));
		format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	}
	//Pierre
	else if(strcmp(params, "pierre", true) == 0)
	{
		new pfileName[48], pName[MAX_PLAYER_NAME];
		GetPlayerName(playerid, pName, sizeof(pName));
		format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
		if(IsPlayerInRangeOfPoint(playerid, 30.0, -1277, 2056, 78))
		{
		    new iPierre;
		    iPierre = dini_Int(pfileName, "iPierre");
		    dini_IntSet(pfileName, "iPierre", iPierre+10);
			SetPlayerCheckpoint(playerid, -1048.2, 2120.86, 96.98, 1.2);
			SendClientMessage(playerid, COLOR_GREEN, "Tu as récupéré 10 bloc de pierre. Va les broyer au checkpoint maintenant.");
			return ApplyAnimation(playerid, "BASEBALL", "Bat_4", 3.1, 1, 0, 0, 0, 15000, 1);
		}
		else
		{
		    SendClientMessage(playerid, COLOR_RED, "Tu n'es pas au bon endroit. Va au checkpoint.");
		    return SetPlayerCheckpoint(playerid, -1277, 2056, 78, 10);
		}
	}
	//Charbon
	else if(strcmp(params, "charbon", true) == 0)
	{
		new pfileName[48], pName[MAX_PLAYER_NAME];
		GetPlayerName(playerid, pName, sizeof(pName));
		format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
		if(IsPlayerInRangeOfPoint(playerid, 30.0, -680, 2395, 132.4))
		{
		    new iCharbon;
		    iCharbon = dini_Int(pfileName, "iCharbon");
		    dini_IntSet(pfileName, "iCharbon", iCharbon+3);
			SendClientMessage(playerid, COLOR_GREEN, "Tu as récupéré 3 minerais de charbon.");
			return ApplyAnimation(playerid, "BASEBALL", "Bat_4", 3.1, 1, 0, 0, 0, 15000, 1);
		}
		else
		{
		    SendClientMessage(playerid, COLOR_RED, "Tu n'es pas au bon endroit. Va au checkpoint.");
		    return SetPlayerCheckpoint(playerid, -680, 2395, 132.4, 10);
		}
	}
	//Cuivre
	else if(strcmp(params, "cuivre", true) == 0)
	{
		new pfileName[48], pName[MAX_PLAYER_NAME];
		GetPlayerName(playerid, pName, sizeof(pName));
		format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	}
	return 1;
}

CMD:broyer(playerid, params[])
{

	if(IsPlayerInAnyVehicle(playerid) == 1) return SendClientMessage(playerid, COLOR_RED, "Tu dois descendre de ton véhicule.");
	if(IsPlayerInRangeOfPoint(playerid, 15.0, -1049, 2119, 97))
	{
	    if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/broyer [nombre de pierres]\"");
	    new animlib[32], animname[32];
	    GetAnimationName(GetPlayerAnimationIndex(playerid),animlib,32,animname,32);
	    if(strcmp(animname, "Bat_M", true) == 0)  return SendClientMessage(playerid, COLOR_RED, "Tu es déjà en train de broyer quelque chose.");
	    new pName[MAX_PLAYER_NAME], pfileName[48], iPierre, Float:bPierre, Float:bPierreBroyee, Float:bFer, Float:bCuivre, strResult1[128], strResult2[128], tAnim, intPierre, intPierreBroyee, intFer, intCuivre;
	    GetPlayerName(playerid, pName, sizeof(pName));
	    format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	    iPierre = dini_Int(pfileName, "iPierre");
	    intPierre = strval(params);
	    if(iPierre < intPierre) return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas autant de pierres.");
	    if(intPierre > 100) return SendClientMessage(playerid, COLOR_RED, "Tu ne peux pas broyer autant de pierres en une seule fois.");
	    if(intPierre <= 4) return SendClientMessage(playerid, COLOR_RED, "Tu ne peux pas broyer si peu de pierres.");
	    bPierre = floatstr(params);
	    bPierreBroyee = bPierre * 0.6;
	    intPierreBroyee = floatround(bPierreBroyee, floatround_round);
		bFer = random(intPierre - intPierreBroyee);
		intFer = floatround(bFer, floatround_round);
		bCuivre = random(intPierre - (intPierreBroyee + intFer));
		intCuivre = floatround(bCuivre, floatround_round);
		intPierreBroyee = intPierreBroyee + (intPierre - (intPierreBroyee + intFer + intCuivre));
		format(strResult1, sizeof(strResult1), "Sur %s pierres, tu as reçu :", params);
		format(strResult2, sizeof(strResult2), "Pierres broyées : %i   |    Minerais de fer : %i    |    Minerais de cuivre : %i", intPierreBroyee, intFer, intCuivre);
		//Nouvelles stats inventaire
		new iPierreBroyee, iCuivre, iFer;
		iPierreBroyee = dini_Int(pfileName, "iPierreBroyee");
		iFer = dini_Int(pfileName, "iFer");
		iCuivre = dini_Int(pfileName, "iCuivre");
		dini_IntSet(pfileName, "iPierre", iPierre-intPierre);
		dini_IntSet(pfileName, "iPierreBroyee", iPierreBroyee+intPierreBroyee);
		dini_IntSet(pfileName, "iFer", iFer+intFer);
		dini_IntSet(pfileName, "iCuivre", iCuivre+intCuivre);
		tAnim = intPierre*1000;
		ApplyAnimation(playerid, "BASEBALL", "Bat_M", 1.0, 0, 0, 0, 0, tAnim, 1);
		SendClientMessage(playerid, COLOR_GREEN, strResult1);
		SendClientMessage(playerid, COLOR_GREEN, strResult2);
	}
	else
	{
	    SendClientMessage(playerid, COLOR_YELLOW, "Tu n'es pas au bon endroit, va au checkpoint.");
	    SetPlayerCheckpoint(playerid, -1048.2, 2120.86, 96.98, 3.0);
	    return 1;
	}
	return 1;
}

CMD:fondre(playerid, params[])
{
    if(IsPlayerInRangeOfPoint(playerid, 12.0, 37.62, -320.44, 2.0))
	{
	    new animlib[32], animname[32];
	    GetAnimationName(GetPlayerAnimationIndex(playerid),animlib,32,animname,32);
	    if(strcmp(animname, "Bat_M", true) == 0)  return SendClientMessage(playerid, COLOR_RED, "Tu es déjà en train de fondre quelque chose.");
	    new pName[MAX_PLAYER_NAME], strMinerai[48], pfileName[48], qteMinerai;
	    GetPlayerName(playerid, pName, sizeof(pName));
	    format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
		if(sscanf(params, "si", strMinerai, qteMinerai)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/fondre [Cuivre | Fer] [quantité de minerais]\"");
	    if(strcmp(strMinerai, "cuivre", true) == 0)
	    {
			new iCuivre, iLingotCuivre, strMessage[128], tAnim;
	        if(qteMinerai <= 0) return SendClientMessage(playerid, COLOR_RED, "Tu ne peux pas faire fondre si peu de minerais.");
			iCuivre = dini_Int(pfileName, "iCuivre");
			iLingotCuivre = dini_Int(pfileName, "iLingotCuivre");
			if(iCuivre < qteMinerai) return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas autant de minerais de cuivre.");
			dini_IntSet(pfileName, "iCuivre", iCuivre-qteMinerai);
			dini_IntSet(pfileName, "iLingotCuivre", iLingotCuivre+qteMinerai);
			tAnim = qteMinerai*1000;
            ApplyAnimation(playerid, "BASEBALL", "Bat_M", 1.0, 0, 0, 0, 0, tAnim, 1);
            format(strMessage, sizeof(strMessage), "Tu as cuit %i minerai de cuivre.", qteMinerai);
            SendClientMessage(playerid, COLOR_GREEN, strMessage);
	    }
	    if(strcmp(strMinerai, "fer", true) == 0)
	    {
			new iFer, iLingotFer, strMessage[128], tAnim;
	        if(qteMinerai <= 0) return SendClientMessage(playerid, COLOR_RED, "Tu ne peux pas faire fondre si peu de minerais.");
			iFer = dini_Int(pfileName, "iFer");
			iLingotFer = dini_Int(pfileName, "iLingotFer");
			if(iFer < qteMinerai) return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas autant de minerais de fer.");
			dini_IntSet(pfileName, "iFer", iFer-qteMinerai);
			dini_IntSet(pfileName, "iLingotFer", iLingotFer+qteMinerai);
			tAnim = qteMinerai*1000;
            ApplyAnimation(playerid, "BASEBALL", "Bat_M", 1.0, 0, 0, 0, 0, tAnim, 1);
            format(strMessage, sizeof(strMessage), "Tu as cuit %i minerai de fer.", qteMinerai);
            SendClientMessage(playerid, COLOR_GREEN, strMessage);
	    }
	}
	else
	{
	    SendClientMessage(playerid, COLOR_RED, "Tu n'es pas au bon endroit. Va au checkpoint.");
	    return SetPlayerCheckpoint(playerid, -1424.64, 1942.64, 51.28, 2.5);
	}
	return 1;
}

/*
===================================Script Porteur d'eau
*/
CMD:actbarrage(playerid)
{
	if(!IsPlayerInRangeOfPoint(playerid, 7.0, -946.8, 1816, 4.8))
	{
	    if(GetPlayerVirtualWorld(playerid) != 0) SetPlayerCheckpoint(playerid, -946.8, 1816, 4.8, 3.0);
	    else SetPlayerCheckpoint(playerid, -594.4, 2018.7, 60.5, 1.0);
		return SendClientMessage(playerid, COLOR_RED, "Tu n'es pas au barrage.");
	}
	new barCar, car, iCharbon, pfileName[48], strPlayerSlot[15], barEau, pName[MAX_PLAYER_NAME], PlayerText:chargementTD, PlayerText:activationTD, PlayerText:filtrageTD, barStatus;
	barStatus = dini_Int("barrage.ini", "barStatus");
	if(barStatus != 0) return SendClientMessage(playerid, COLOR_RED, "Le barrage est déjà en cours d'utilisation.");
	GetPlayerName(playerid, pName, sizeof(pName));
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	iCharbon = dini_Int(pfileName, "iCharbon");
	car = 30;
	if(iCharbon < 1) return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas assez de charbon.");
	barCar = dini_Int("barrage.ini", "barCar");
	barCar = barCar + car;
	if(barCar > MaxCarBarrage) return SendClientMessage(playerid, COLOR_RED, "Le barrage ne peut pas stocker autant de charbon.");
	barEau = dini_Int("barrage.ini", "barEau");
	barEau = barEau + 5;
	if(barEau > MaxEauBarrage) return SendClientMessage(playerid, COLOR_RED, "La réserve va déborder, récupères d'abord de l'eau.");
	//On ajoute le joueur aux joueurs en cours de traitement
	for(new playerSlot = 1; playerSlot <= 15; playerSlot++)
	{
		format(strPlayerSlot, sizeof(strPlayerSlot), "%i", playerSlot);
		if(dini_Int("barrage.ini", strPlayerSlot) == playerid) return SendClientMessage(playerid, COLOR_RED, "Le barrage est déjà activé. Attend la fin de la session de production.");
		if(dini_Int("barrage.ini", strPlayerSlot) == 999)
		{
		    dini_IntSet("barrage.ini", strPlayerSlot, playerid);
		    goto finpSlot;
		}
	}
	SendClientMessage(playerid, COLOR_RED, "Il y a déjà trop de monde au barrage.");
	
	finpSlot:
	//On met les stats au barrage
	dini_IntSet(pfileName, "iCharbon", iCharbon-1);
	dini_IntSet("barrage.ini", "barCar", barCar);
	dini_IntSet("barrage.ini", "barStatus", 1);
	chargementTD = CreatePlayerTextDraw(playerid, 400, 380, "~y~O ~w~Chargement du carburant");
	activationTD = CreatePlayerTextDraw(playerid, 400, 400, "~r~X ~w~Activation des pompes");
	filtrageTD = CreatePlayerTextDraw(playerid, 400, 420, "~r~X ~w~Filtrage de l'eau");
	if(barStatus == 0) timerBarrageID = SetTimerEx("BarrageLaunch", 10000, true, "iiii", chargementTD, activationTD, filtrageTD);
	PlayerTextDrawShow(playerid, chargementTD);
	PlayerTextDrawShow(playerid, activationTD);
	PlayerTextDrawShow(playerid, filtrageTD);
	SendClientMessage(playerid, COLOR_GREEN, "Tu as consommé 1 minerai de charbon pour alimenter le barrage.");
	return 1;
}

CMD:stockeau(playerid)
{
	new string[128], stockEau;
	stockEau = dini_Int("barrage.ini", "barEau");
	format(string, sizeof(string), "Réservoir : %iL/100L", stockEau);
	SendClientMessage(playerid, COLOR_YELLOW, string);
	return 1;
}

/*
===================================Script Porteur d'eau
*/
CMD:reparer(playerid, params[])
{
	new teleid, montant, msgPlayer[128], msgTele[128], Float:t_pos[3], pName[MAX_PLAYER_NAME], vehicleid, tName[MAX_PLAYER_NAME], tfileName[48];
	if(GetPlayerTeam(playerid) != 6) return SendClientMessage(playerid, COLOR_RED, "Tu n'es pas mécanicien(/job)");
	if(sscanf(params, "ii", teleid, montant)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/reparer [ID du joueur] [Prix]\"");
	if(!IsPlayerConnected(teleid)) return SendClientMessage(playerid, COLOR_RED, "Ce joueur n'est pas connecté.");
	if(montant < 0) return SendClientMessage(playerid, COLOR_RED, "Tu ne peux pas faire payer un prix négatif.");
	if(teleid == playerid) return SendClientMessage(playerid, COLOR_RED, "Tu ne peux pas réparer ton propre véhicule.");
	GetPlayerPos(teleid, t_pos[0], t_pos[1], t_pos[2]);
	if(!IsPlayerInRangeOfPoint(playerid, 6.0, t_pos[0], t_pos[1], t_pos[2])) return SendClientMessage(playerid, COLOR_RED, "Ce joueur est trop éloigné de toi.");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "Ce joueur n'est pas dans un véhicule.");
	GetPlayerName(teleid, tName, sizeof(tName));
	GetPlayerName(playerid, pName, sizeof(pName));
	format(tfileName, sizeof(tfileName), "players/%s.ini", tName);
	vehicleid = GetPlayerVehicleID(playerid);
	dini_IntSet(tfileName, "accVehicleID", vehicleid);
	dini_IntSet(tfileName, "accVendeurID", playerid);
	dini_IntSet(tfileName, "accMontant", montant);
	format(msgPlayer, sizeof(msgPlayer), "Tu as proposé une réparation à %s pour %i$.", tName, montant);
	format(msgTele, sizeof(msgTele), "%s te propose une réparation pour %i$.(/accepter reparer)", pName, montant);
	SendClientMessage(playerid, COLOR_GREEN, msgPlayer);
	SendClientMessage(teleid, COLOR_GREEN, msgTele);
	return 1;
}

/*
===================================Script Maisons et Business
*/
CMD:vw(playerid)
{
	new string[32];
	new virtualWorld = GetPlayerVirtualWorld(playerid);
	format(string, sizeof(string), "Virtual World : %i", virtualWorld);
	SendClientMessage(playerid, COLOR_YELLOW, string);
	return 1;
}

CMD:setvw(playerid, params[])
{
    new teleid, virtualWorld;
    if(!IsPlayerAdmin(playerid)) return 1;
    if(sscanf(params, "ii", teleid, virtualWorld)) return SendClientMessage(playerid, COLOR_RED, "Utilise /setvw [PlayerID] [Virtual World]");
	SetPlayerVirtualWorld(teleid, virtualWorld);
	SendClientMessage(playerid, COLOR_GREEN, "Tu l'as mis dans le VW voulu");
	return 1;
}

CMD:setinterior(playerid, params[])
{
    new teleid, interior;
    if(!IsPlayerAdmin(playerid)) return 1;
    if(sscanf(params, "ii", teleid, interior)) return SendClientMessage(playerid, COLOR_RED, "Utilise /setinterior [PlayerID] [Interior]");
	SetPlayerInterior(teleid, interior);
	SendClientMessage(playerid, COLOR_GREEN, "Tu l'as mis dans l'intérieur voulu");
	return 1;
}

CMD:cbat(playerid, params[])
{
	if(IsPlayerAdmin(playerid) || GetPlayerTeam(playerid) == 1)
	{
		new pickupmodelid, pickupid, roomID, Float:player_pos[3], ifileName[32], montant, type;
		GetPlayerPos(playerid, player_pos[0], player_pos[1], player_pos[2]);
    	if(sscanf(params, "iiii", pickupmodelid, roomID, montant, type)) return SendClientMessage(playerid, COLOR_RED, "Utilise /cbat [Pickup ID] [Numéro de la maison/biz] [Prix d'achat] [Maison(2) | Biz(4) | Public(5)]");
	    pickupid = CreatePickup(pickupmodelid, 1, player_pos[0], player_pos[1], player_pos[2]-0.5, -1);
		for(new vw = 1; vw <= 30; vw++)
		{
			format(ifileName, sizeof(ifileName), "houses/%i/%i.txt", roomID, vw);
			if(!dini_Exists(ifileName))
			{
				new Text3D:id3DTL1, Text3D:id3DTL2, str3D1[48];
				format(str3D1, sizeof(str3D1), "Prix : %i $", montant);
				if(type == 5)
				{
				    id3DTL1 = Create3DTextLabel("Batiment public", COLOR_WHITE, player_pos[0], player_pos[1], player_pos[2], 6.0, 0, 0);
				    dini_Set(ifileName, "nom", "Batiment public");
				    dini_Create(ifileName);
				}
				else
				{
					id3DTL1 = Create3DTextLabel("A vendre !", COLOR_WHITE, player_pos[0], player_pos[1], player_pos[2], 6.0, 0, 0);
					id3DTL2 = Create3DTextLabel(str3D1, COLOR_WHITE, player_pos[0], player_pos[1], player_pos[2]-0.06, 6.0, 0, 0);
					dini_Set(ifileName, "nom", "A vendre !");
					dini_Create(ifileName);
					dini_IntSet(ifileName, "montant", montant);
				}
				dini_IntSet(ifileName, "pickupmodelid", pickupmodelid);
				dini_IntSet(ifileName, "pickupid", pickupid);
				dini_IntSet(ifileName, "3DTL1id", id3DTL1);
				dini_IntSet(ifileName, "3DTL2id", id3DTL2);
				dini_IntSet(ifileName, "type", type);
				dini_FloatSet(ifileName, "posX", player_pos[0]);
				dini_FloatSet(ifileName, "posY", player_pos[1]);
				dini_FloatSet(ifileName, "posZ", player_pos[2]);
				return SendClientMessage(playerid, COLOR_GREEN, "Biz/Maison créé avec succès.");
			}
		}
	}
	return 1;
}

CMD:entrer(playerid)
{
	new ifileName[32], cfgfileName[32];
    for(new roomID; roomID <= 200; roomID++)
    {
        for(new vwID; vwID <= 30; vwID++)
        {
        	format(ifileName, sizeof(ifileName), "houses/%i/%i.txt", roomID, vwID);
        	new Float:b_pos[3];
			b_pos[0] = dini_Float(ifileName, "posX");
			b_pos[1] = dini_Float(ifileName, "posY");
			b_pos[2] = dini_Float(ifileName, "posZ");
			if(IsPlayerInRangeOfPoint(playerid, 1.0, b_pos[0], b_pos[1], b_pos[2]) && dini_Exists(ifileName))
			{
			    format(cfgfileName, sizeof(cfgfileName), "houses/%i/cfg.txt", roomID);
			    new bInterior = dini_Int(cfgfileName, "interior"), pfileName[32], pName[MAX_PLAYER_NAME], Float:i_pos[3];
			    i_pos[0] = dini_Float(cfgfileName, "posX");
			    i_pos[1] = dini_Float(cfgfileName, "posY");
			    i_pos[2] = dini_Float(cfgfileName, "posZ");
			    SetPlayerInterior(playerid, bInterior);
			    SetPlayerVirtualWorld(playerid, vwID);
			    SetPlayerPos(playerid, i_pos[0], i_pos[1], i_pos[2]);
				GetPlayerName(playerid, pName, sizeof(pName));
				format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
				dini_IntSet(pfileName, "roomID", roomID);
				return 1;
			}
		}
	}
	return 1;
}

CMD:sortir(playerid)
{
	new pVirtual = GetPlayerVirtualWorld(playerid), ifileName[32], cfgfileName[32], Float:b_pos[3], pName[MAX_PLAYER_NAME], pfileName[32], Float:e_pos[3];
	if(pVirtual == 0) return 1;
	GetPlayerName(playerid, pName, sizeof(pName));
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	new roomID = dini_Int(pfileName, "roomID");
	format(ifileName, sizeof(ifileName), "houses/%i/%i.txt", roomID, pVirtual);
	format(cfgfileName, sizeof(cfgfileName), "houses/%i/cfg.txt", roomID);
	e_pos[0] = dini_Float(cfgfileName, "posX");
	e_pos[1] = dini_Float(cfgfileName, "posY");
	e_pos[2] = dini_Float(cfgfileName, "posZ");
	if(!IsPlayerInRangeOfPoint(playerid, 1.0, e_pos[0], e_pos[1], e_pos[2]))
	{
	    SetPlayerCheckpoint(playerid, e_pos[0], e_pos[1], e_pos[2], 1.0);
		return 1;
	}
	b_pos[0] = dini_Float(ifileName, "posX");
	b_pos[1] = dini_Float(ifileName, "posY");
	b_pos[2] = dini_Float(ifileName, "posZ");
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, b_pos[0], b_pos[1], b_pos[2]);
	return 1;
}

CMD:gen(playerid)
{
	if(IsPlayerAdmin(playerid))
	{
		for(new id = 0; id <= 146; id++)
		{
			new ifileName[32], idirName[32];
			format(idirName, sizeof(idirName), "houses/%i", id);
			format(ifileName, sizeof(ifileName), "houses/%i/cfg.txt", id);
			dini_Create(ifileName);
			dini_IntSet(ifileName, "interior", 0);
			dini_FloatSet(ifileName, "posX", 0);
			dini_FloatSet(ifileName, "posY", 0);
			dini_FloatSet(ifileName, "posZ", 0);
			dini_IntSet(ifileName, "actVirtual", 0);
		}
	}
	return SendClientMessage(playerid, COLOR_TURQUOISE, "Fichiers et dossiers créé.");
}

CMD:cfg(playerid, params[])
{
	if(!IsPlayerAdmin(playerid) && GetPlayerTeam(playerid) != 1) return 1;
	new numMaison, interiorid, Float:i_pos[3], hfileName[38];
    if(sscanf(params, "iifff", numMaison, interiorid, i_pos[0], i_pos[1], i_pos[2])) return SendClientMessage(playerid, COLOR_RED, "Utilise /cfg [Numéro de la maison] [InteriorID] [Pos X] [Pos Y] [Pos Z]");
	format(hfileName, sizeof(hfileName), "houses/%i/cfg.txt", numMaison);
	dini_IntSet(hfileName, "interior", interiorid);
	dini_FloatSet(hfileName, "posX", i_pos[0]);
	dini_FloatSet(hfileName, "posY", i_pos[1]);
	dini_FloatSet(hfileName, "posZ", i_pos[2]);
	SendClientMessage(playerid, COLOR_GREEN, "Batiment paramétré");
	return 1;
}

CMD:numerobat(playerid)
{
    new pVirtual = GetPlayerVirtualWorld(playerid), pName[MAX_PLAYER_NAME], pfileName[32], roomID, strRoom[128];
	if(pVirtual == 0) return SendClientMessage(playerid, COLOR_RED, "Tu es à l'extérieur");
	GetPlayerName(playerid, pName, sizeof(pName));
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	roomID = dini_Int(pfileName, "roomID");
	format(strRoom, sizeof(strRoom), "Maison n°%i", roomID);
	SendClientMessage(playerid, COLOR_GREEN, strRoom);
	return 1;
}

CMD:desbat(playerid)
{
	new ifileName[32];
	if(!IsPlayerAdmin(playerid) && GetPlayerTeam(playerid) != 1) return SendClientMessage(playerid, COLOR_RED, "Tu n'es pas constructeur ou administrateur.");
    for(new roomID; roomID <= 200; roomID++)
    {
        for(new vwID; vwID <= 30; vwID++)
        {
        	format(ifileName, sizeof(ifileName), "houses/%i/%i.txt", roomID, vwID);
        	new Float:b_pos[3];
			b_pos[0] = dini_Float(ifileName, "posX");
			b_pos[1] = dini_Float(ifileName, "posY");
			b_pos[2] = dini_Float(ifileName, "posZ");
			if(IsPlayerInRangeOfPoint(playerid, 1.0, b_pos[0], b_pos[1], b_pos[2]) && dini_Exists(ifileName))
			{
			    new pickupid, Text3D:id3DTL1, Text3D:id3DTL2;
			    pickupid = dini_Int(ifileName, "pickupid");
			    id3DTL1 = dini_Int(ifileName, "3DTL1id");
			    id3DTL2 = dini_Int(ifileName, "3DTL2id");
			    DestroyPickup(pickupid);
			    Delete3DTextLabel(id3DTL1);
			    Delete3DTextLabel(id3DTL2);
				dini_Remove(ifileName);
			    SendClientMessage(playerid, COLOR_GREEN, "Biz supprimé.");
			}
		}
	}
	return 1;
}

CMD:bat(playerid, params[])
{
	new ifileName[32], strAction[20], strNom[25], pName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, sizeof(pName));
	sscanf(params, "ss", strAction, strNom);
	//Acheter
	if(strcmp(strAction, "acheter", true) == 0)
	{
	    for(new roomID; roomID <= 200; roomID++)
    	{
        	for(new vwID; vwID <= 30; vwID++)
        	{
        		format(ifileName, sizeof(ifileName), "houses/%i/%i.txt", roomID, vwID);
        		new Float:b_pos[3];
				b_pos[0] = dini_Float(ifileName, "posX");
				b_pos[1] = dini_Float(ifileName, "posY");
				b_pos[2] = dini_Float(ifileName, "posZ");
				if(IsPlayerInRangeOfPoint(playerid, 1.0, b_pos[0], b_pos[1], b_pos[2]) && dini_Exists(ifileName))
				{
					new pMoney, bMontant, Text3D:id3DTL1, Text3D:id3DTL2, str3D1[48], type, pickupid;
					pMoney = GetPlayerMoney(playerid);
					bMontant = dini_Int(ifileName, "montant");
					type = dini_Int(ifileName, "type");
					if(pMoney < bMontant) return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas les moyens d'acheter ce bâtiment.");
					if(type == 5) return SendClientMessage(playerid, COLOR_RED, "Tu ne peux pas acheter un bâtiment public.");
					else if(type == 1 && type == 3) return SendClientMessage(playerid, COLOR_RED, "Ce bâtiment est déjà acheté.");
					else if(type == 2)
					{
						pickupid = dini_Int(ifileName, "pickupid");
						DestroyPickup(pickupid);
						pickupid = CreatePickup(1272, 1, b_pos[0], b_pos[1], b_pos[2], -1);
						dini_IntSet(ifileName, "pickupmodelid", 1272);
						dini_IntSet(ifileName, "pickupid", pickupid);
						dini_IntSet(ifileName, "type", 1);
						GivePlayerMoney(playerid, -bMontant);
						dini_Set(ifileName, "proprio", pName);
						dini_Set(ifileName, "nom", "Vendu !");
						format(str3D1, sizeof(str3D1), "Proprio : %s", pName);
						id3DTL1 = dini_Int(ifileName, "3DTL1id");
						id3DTL2 = dini_Int(ifileName, "3DTL2id");
						Update3DTextLabelText(id3DTL1, COLOR_WHITE, "Vendu !");
						Update3DTextLabelText(id3DTL2, COLOR_WHITE, str3D1);
			    		return SendClientMessage(playerid, COLOR_GREEN, "Maison achetée");
					}
					else if(type == 4)
					{
						GivePlayerMoney(playerid, -bMontant);
						dini_Set(ifileName, "proprio", pName);
						dini_Set(ifileName, "nom", "Vendu !");
						dini_IntSet(ifileName, "type", 3);
						format(str3D1, sizeof(str3D1), "Proprio : %s", pName);
						id3DTL1 = dini_Int(ifileName, "3DTL1id");
						id3DTL2 = dini_Int(ifileName, "3DTL2id");
						Update3DTextLabelText(id3DTL1, COLOR_WHITE, "Vendu !");
						Update3DTextLabelText(id3DTL2, COLOR_WHITE, str3D1);
			    		return SendClientMessage(playerid, COLOR_GREEN, "Biz acheté");
					}
				}
			}
		}
	}
	//Renommer
	else if(strcmp(strAction, "nom", true) == 0)
	{
	    if(strlen(strNom) > 24) return SendClientMessage(playerid, COLOR_RED, "Ce nom est trop long.");
	    if(sscanf(params, "ss", strAction, strNom)) return SendClientMessage(playerid, COLOR_RED, "Utilise /bat nom [Nouveau nom]");
	    for(new roomID; roomID <= 200; roomID++)
    	{
        	for(new vwID; vwID <= 30; vwID++)
        	{
        		format(ifileName, sizeof(ifileName), "houses/%i/%i.txt", roomID, vwID);
        		new Float:b_pos[3];
				b_pos[0] = dini_Float(ifileName, "posX");
				b_pos[1] = dini_Float(ifileName, "posY");
				b_pos[2] = dini_Float(ifileName, "posZ");
				if(IsPlayerInRangeOfPoint(playerid, 1.0, b_pos[0], b_pos[1], b_pos[2]) && dini_Exists(ifileName))
				{
				    new Text3D:id3DTL1, str3DTL[48], type;
				    if(strcmp(pName, dini_Get(ifileName, "proprio"), false) != 0) return SendClientMessage(playerid, COLOR_RED, "Tu n'es pas le propriétaire de ce bâtiment.");
				    type = dini_Int(ifileName, "type");
				    if(type == 5)
					{
					    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "Tu n'as pas la permission de renommer un bâtiment public.");
                        dini_Set(ifileName, "nom", strNom);
				    	id3DTL1 = dini_Int(ifileName, "3DTL1id");
				    	format(str3DTL, sizeof(str3DTL), "%s", strNom);
				    	Update3DTextLabelText(id3DTL1, COLOR_WHITE, str3DTL);
			    		return SendClientMessage(playerid, COLOR_GREEN, "Bâtiment renommé");
					}
				    dini_Set(ifileName, "nom", strNom);
				    id3DTL1 = dini_Int(ifileName, "3DTL1id");
				    format(str3DTL, sizeof(str3DTL), "%s", strNom);
				    Update3DTextLabelText(id3DTL1, COLOR_WHITE, str3DTL);
			    	return SendClientMessage(playerid, COLOR_GREEN, "Biz/Maison renommé");
				}
			}
		}
	}
	//Vendre
	else if(strcmp(strAction, "vendre", true) == 0)
	{
	    for(new roomID; roomID <= 200; roomID++)
    	{
        	for(new vwID; vwID <= 30; vwID++)
        	{
        		format(ifileName, sizeof(ifileName), "houses/%i/%i.txt", roomID, vwID);
        		new Float:b_pos[3], type;
				b_pos[0] = dini_Float(ifileName, "posX");
				b_pos[1] = dini_Float(ifileName, "posY");
				b_pos[2] = dini_Float(ifileName, "posZ");
				type = dini_Int(ifileName, "type");
				if(IsPlayerInRangeOfPoint(playerid, 1.0, b_pos[0], b_pos[1], b_pos[2]))
				{
					if(strcmp(pName, dini_Get(ifileName, "proprio")) != 0) return SendClientMessage(playerid, COLOR_RED, "Ce bâtiment ne t'appartient pas.");
					if(type == 2 || type == 4) return SendClientMessage(playerid, COLOR_RED, "Ce bâtiment n'est pas à vendre.");
					if(type == 1)
					{
				    	new pickupid, bMontant, str3D1[48], Text3D:id3DTL1, Text3D:id3DTL2;
				    	pickupid = dini_Int(ifileName, "pickupid");
						DestroyPickup(pickupid);
						pickupid = CreatePickup(1273, 1, b_pos[0], b_pos[1], b_pos[2], -1);
						dini_IntSet(ifileName, "pickupmodelid", 1273);
						dini_IntSet(ifileName, "pickupid", pickupid);
						dini_IntSet(ifileName, "type", 2);
						bMontant = dini_Int(ifileName, "montant");
						GivePlayerMoney(playerid, bMontant-20000);
						dini_Set(ifileName, "nom", "A vendre !");
						dini_Set(ifileName, "proprio", "none");
						format(str3D1, sizeof(str3D1), "Prix : %i $", bMontant);
						id3DTL1 = dini_Int(ifileName, "3DTL1id");
						id3DTL2 = dini_Int(ifileName, "3DTL2id");
						Update3DTextLabelText(id3DTL1, COLOR_WHITE, "A vendre !");
						Update3DTextLabelText(id3DTL2, COLOR_WHITE, str3D1);
			    		return SendClientMessage(playerid, COLOR_GREEN, "Maison vendue");
					}
					else if(type == 3)
					{
				    	new bMontant, str3D1[48], Text3D:id3DTL1, Text3D:id3DTL2;
						dini_IntSet(ifileName, "type", 4);
						bMontant = dini_Int(ifileName, "montant");
						GivePlayerMoney(playerid, bMontant-20000);
						dini_Set(ifileName, "nom", "A vendre !");
						dini_Set(ifileName, "proprio", "none");
						format(str3D1, sizeof(str3D1), "Prix : %i$", bMontant);
						id3DTL1 = dini_Int(ifileName, "3DTL1id");
						id3DTL2 = dini_Int(ifileName, "3DTL2id");
						Update3DTextLabelText(id3DTL1, COLOR_WHITE, "A vendre !");
						Update3DTextLabelText(id3DTL2, COLOR_WHITE, str3D1);
			    		return SendClientMessage(playerid, COLOR_GREEN, "Business vendue");
					}
				}
			}
		}
	}
	return SendClientMessage(playerid, COLOR_RED, "Utilise \"/bat [acheter | vendre | nom]\"");
}

/*
===================================Script Inventaire et Stats
*/
CMD:inv(playerid)
{
	new pfileName[48], stats1[128], stats2[128], stats3[128], stats4[128], stats5[128], pName[MAX_PLAYER_NAME], iArbre, iCharbon, ipEchelle, iCoffre, strBidon[16], iBidonType, iBidonLitre, igEchelle, iPlanches, iCabane, iBaton, iFer, iPierre, iPierreBroyee, iCuivre, iLingotFer, iLingotCuivre;
    GetPlayerName(playerid, pName, sizeof(pName));
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
 	iArbre = dini_Int(pfileName, "iArbre");
 	iPlanches = dini_Int(pfileName, "iPlanches");
 	ipEchelle = dini_Int(pfileName, "ipEchelle");
 	igEchelle = dini_Int(pfileName, "igEchelle");
 	iCabane = dini_Int(pfileName, "iCabane");
 	iFer = dini_Int(pfileName, "iFer");
 	iPierre = dini_Int(pfileName, "iPierre");
 	iPierreBroyee = dini_Int(pfileName, "iPierreBroyee");
 	iCuivre = dini_Int(pfileName, "iCuivre");
 	iBaton = dini_Int(pfileName, "iBaton");
 	iLingotFer = dini_Int(pfileName, "iLingotFer");
 	iLingotCuivre = dini_Int(pfileName, "iLingotCuivre");
	iCoffre = dini_Int(pfileName, "iCoffre");
	iCharbon = dini_Int(pfileName, "iCharbon");
	
	iBidonType = dini_Int(pfileName, "iBidonType");
	iBidonLitre = dini_Int(pfileName, "iBidonLitre");
	if(iBidonType == 10) format(strBidon, sizeof(strBidon), "Vide");
	else if(iBidonType == 0) format(strBidon, sizeof(strBidon), "Non");
	else if(iBidonType == 1) format(strBidon, sizeof(strBidon), "Diesel(%iL)", iBidonLitre);
	else if(iBidonType == 2) format(strBidon, sizeof(strBidon), "Kerozen(%iL)", iBidonLitre);
	else if(iBidonType == 4) format(strBidon, sizeof(strBidon), "Eau(%iL)", iBidonLitre);
	format(stats1, sizeof(stats1), "Arbres : %i                 Planches : %i               Petites échelles : %i          Grandes échelles : %i", iArbre, iPlanches, ipEchelle, igEchelle);
	format(stats2, sizeof(stats2), "Cabanes : %i                Bâtons : %i", iCabane, iBaton);
	format(stats3, sizeof(stats3), "Pierres : %i                Pierres Broyées : %i        Minerais de Fer : %i           Minerais de Cuivre : %i", iPierre, iPierreBroyee, iFer, iCuivre);
	format(stats4, sizeof(stats4), "Minerais de charbon : %i    Lingots de Fer : %i         Lingots de Cuivre : %i    ... : ", iCharbon, iLingotFer, iLingotCuivre);
	format(stats5, sizeof(stats5), "Coffres : %i                Bidon: %s          ... :                          ... : ", iCoffre, strBidon);

	SendClientMessage(playerid, COLOR_YELLOW, stats1);
	SendClientMessage(playerid, COLOR_YELLOW, stats2);
	SendClientMessage(playerid, COLOR_YELLOW, stats3);
	SendClientMessage(playerid, COLOR_YELLOW, stats4);
	SendClientMessage(playerid, COLOR_YELLOW, stats5);
	return 1;
}

CMD:stats(playerid)
{
	new pfileName[48], stats1[128], team, stats2[128], pName[MAX_PLAYER_NAME], bArgent, iArgent, freq, job[16];
    GetPlayerName(playerid, pName, sizeof(pName));
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
 	bArgent = dini_Int(pfileName, "bArgent");
 	iArgent = dini_Int(pfileName, "iArgent");
 	freq = dini_Int(pfileName, "frequence");
 	team = dini_Int(pfileName, "team");
 	if(team == 2) format(job, sizeof(job), "Bûcheron");
 	else if(team == 3) format(job, sizeof(job), "Soigneur");
 	else if(team == 4) format(job, sizeof(job), "Mineur");
 	else if(team == 5) format(job, sizeof(job), "Porteur d'eau");
 	else if(team == 6) format(job, sizeof(job), "Mécanicien");
 	else if(team == 7) format(job, sizeof(job), "Aventurier");
 	else if(team == 8) format(job, sizeof(job), "Ravitailleur");
 	else  format(job, sizeof(job), "Aucun");
    format(stats1, sizeof(stats1), "Argent en banque : %i $     Argent dans l'inventaire : %i $     Frequence : %i", bArgent, iArgent, freq);
    format(stats2, sizeof(stats2), "Job : %s", job);
	SendClientMessage(playerid, COLOR_YELLOW, stats1);
	SendClientMessage(playerid, COLOR_YELLOW, stats2);
	return 1;
}

/*
===================================Script Animations
*/
CMD:assis(playerid, params[])
{
	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/assis [1-7]\"");
	new type, pName[MAX_PLAYER_NAME], pfileName[48];
	GetPlayerName(playerid, pName, sizeof(pName));
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	type = strval(params);
	ClearAnimations(playerid);
	if(type == 1)
	{
	    ApplyAnimation(playerid, "ATTRACTORS", "Stepsit_loop", 4.1, 0, 0, 0, 1, 0, 1);
	}
	else if(type == 2)
	{
	    ApplyAnimation(playerid, "BEACH", "SitnWait_loop_W", 4.1, 0, 0, 0, 1, 0, 1);
	}
	else if(type == 3)
	{
	    ApplyAnimation(playerid, "FOOD", "FF_SIT_EAT3", 4.1, 0, 0, 0, 1, 0, 1);
	}
	else if(type == 4)
	{
	    ApplyAnimation(playerid, "INT_HOUSE", "LOU_LOOP", 4.1, 0, 0, 0, 1, 0, 1);
	}
	else if(type == 5)
	{
	    ApplyAnimation(playerid, "MISC", "SEAT_LR", 4.1, 0, 0, 0, 1, 0, 1);
	}
	else if(type == 6)
	{
	    ApplyAnimation(playerid, "MISC", "SEAT_TALK_02", 4.1, 0, 0, 0, 1, 0, 1);
	}
	else if(type == 7)
	{
	    ApplyAnimation(playerid, "PED", "SEAT_DOWN", 4.1, 0, 0, 0, 1, 0, 1);
	}
	else return SendClientMessage(playerid, COLOR_RED, "Utilise \"/assis [1-7]\"");
	dini_IntSet(pfileName, "animation", 1);
	return SendClientMessage(playerid, COLOR_YELLOW, "Appuie sur la touche \"ESPACE\" pour arrêter l'animation.");
}

CMD:pose(playerid, params[])
{
	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/pose [1-3]\"");
	new type, pName[MAX_PLAYER_NAME], pfileName[48];
	GetPlayerName(playerid, pName, sizeof(pName));
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	type = strval(params);
	ClearAnimations(playerid);
	if(type == 1)
	{
	    ApplyAnimation(playerid, "DEALER", "Dealer_idle", 4.1, 0, 0, 0, 1, 0, 1);
	}
	else if(type == 2)
	{
	    ApplyAnimation(playerid, "GANGS", "LEANIDLE", 4.1, 0, 0, 0, 1, 0, 1);
	}
	else return SendClientMessage(playerid, COLOR_RED, "Utilise \"/pose [1-3]\"");
	dini_IntSet(pfileName, "animation", 1);
	return SendClientMessage(playerid, COLOR_YELLOW, "Appuie sur la touche \"ESPACE\" pour arrêter l'animation.");
}

CMD:coucher(playerid, params[])
{
	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/coucher [1-2]\"");
	new type, pName[MAX_PLAYER_NAME], pfileName[48];
	GetPlayerName(playerid, pName, sizeof(pName));
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	type = strval(params);
	ClearAnimations(playerid);
	if(type == 1)
	{
	    ApplyAnimation(playerid, "INT_HOUSE", "Bed_In_R", 4.1, 0, 0, 0, 1, 0, 1);
	}
	else if(type == 2)
	{
	    ApplyAnimation(playerid, "INT_HOUSE", "Bed_In_L", 4.1, 0, 0, 0, 1, 0, 1);
	}
	else return SendClientMessage(playerid, COLOR_RED, "Utilise \"/coucher [1-2]\"");
	dini_IntSet(pfileName, "animation", 1);
	return SendClientMessage(playerid, COLOR_YELLOW, "Appuie sur la touche \"ESPACE\" pour arrêter l'animation.");
}

CMD:fumer(playerid, params[])
{
	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/fumer [1-2]\"");
	new type, pName[MAX_PLAYER_NAME], pfileName[48];
	GetPlayerName(playerid, pName, sizeof(pName));
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	type = strval(params);
	ClearAnimations(playerid);
	if(type == 1)
	{
	    ApplyAnimation(playerid, "LOWRIDER", "M_SMKLEAN_LOOP", 4.1, 0, 0, 0, 1, 0, 1);
	}
	else if(type == 2)
	{
	    ApplyAnimation(playerid, "LOWRIDER", "M_SMKSTND_LOOP", 4.1, 0, 0, 0, 1, 0, 1);
	}
	else return SendClientMessage(playerid, COLOR_RED, "Utilise \"/fumer [1-2]\"");
	dini_IntSet(pfileName, "animation", 1);
	return SendClientMessage(playerid, COLOR_YELLOW, "Appuie sur la touche \"ESPACE\" pour arrêter l'animation.");
}

CMD:pisser(playerid, params[])
{
	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/pisser [1-2]\"");
	new type, pName[MAX_PLAYER_NAME], pfileName[48];
	GetPlayerName(playerid, pName, sizeof(pName));
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	type = strval(params);
	ClearAnimations(playerid);
	if(type == 1)
	{
	    ApplyAnimation(playerid, "PAULNMAC", "PISS_LOOP", 4.1, 0, 0, 0, 1, 0, 1);
	}
	else if(type == 2)
	{
	    ApplyAnimation(playerid, "PAULNMAC", "PISS_IN", 4.1, 0, 0, 0, 1, 0, 1);
	}
	else return SendClientMessage(playerid, COLOR_RED, "Utilise \"/fumer [1-2]\"");
	dini_IntSet(pfileName, "animation", 1);
	return SendClientMessage(playerid, COLOR_YELLOW, "Appuie sur la touche \"ESPACE\" pour arrêter l'animation.");
}

CMD:masturber(playerid)
{
	new pName[MAX_PLAYER_NAME], pfileName[48];
	GetPlayerName(playerid, pName, sizeof(pName));
	format(pfileName, sizeof(pfileName), "players/%s.ini", pName);
	ClearAnimations(playerid);
	ApplyAnimation(playerid, "PAULNMAC", "WANK_LOOP", 4.1, 0, 0, 0, 1, 0, 1);
	dini_IntSet(pfileName, "animation", 1);
	return SendClientMessage(playerid, COLOR_YELLOW, "Appuie sur la touche \"ESPACE\" pour arrêter l'animation.");
}

/*
===================================Script Admin
*/
CMD:kick(playerid, params[])
{
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "Tu n'es pas administrateur.");
	new kickID, reason[128], kickTimerID, pName[MAX_PLAYER_NAME], kName[MAX_PLAYER_NAME], kickMSG[264];
	if(sscanf(params, "is", kickID, reason)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/kick [ID du joueur] [Raison]");
	if(!IsPlayerConnected(kickID)) return SendClientMessage(playerid, COLOR_RED, "Cet ID est inutilisé.");
	GetPlayerName(playerid, pName, sizeof(pName));
	GetPlayerName(kickID, kName, sizeof(kName));
	format(kickMSG, sizeof(kickMSG), "%s a été kick par %s. Raison : %s", kName, pName, reason);
	SendClientMessageToAll(COLOR_GRIS, kickMSG);
	kickTimerID = SetTimerEx("DelayKick", 500, false, "ii", kickID, kickTimerID);
	return 1;
}

CMD:ban(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "Tu n'es pas administrateur.");
    new banID, reason[128], kickTimerID, pName[MAX_PLAYER_NAME], banName[MAX_PLAYER_NAME], banMSG[264], pfileName[MAX_PLAYER_NAME];
	if(sscanf(params, "is", banID, reason) ) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/ban [ID du joueur] [Raison]");
	GetPlayerName(playerid, pName, sizeof(pName));
	GetPlayerName(banID, banName, sizeof(banName));
	if(!IsPlayerConnected(banID)) return SendClientMessage(playerid, COLOR_RED, "Cet ID est inutilisé.");
	format(pfileName, sizeof(pfileName), "players/%s.ini", banName);
	format(banMSG, sizeof(banMSG), "%s a été banni par %s. Raison : %s", banName, pName, reason);
	dini_IntSet(pfileName, "ban", 1);
	dini_Set(pfileName, "banRaison", banMSG);
	SendClientMessageToAll(COLOR_RED, banMSG);
	kickTimerID = SetTimerEx("DelayKick", 500, false, "ii", banID, kickTimerID);
	return 1;
}

CMD:deban(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "Tu n'es pas administrateur.");
	new pfileName[MAX_PLAYER_NAME], ban, strMsg[128];
	format(pfileName, sizeof(pfileName), "players/%s.ini", params);
	if(!dini_Exists(pfileName)) return SendClientMessage(playerid, COLOR_RED, "Ce joueur n'existe pas.");
	ban = dini_Int(pfileName, "ban");
	if(ban != 1) return SendClientMessage(playerid, COLOR_RED, "Ce joueur n'est pas banni.");
	dini_IntSet(pfileName, "ban", 0);
	format(strMsg, sizeof(strMsg), "Tu as débanni %s.", params);
	SendClientMessage(playerid, COLOR_GREEN, strMsg);
	return 1;
}

/*CMD:unsynchro(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return 1;
	if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Utilise \"/unsynchro [ID du joueur]\"");
	new strRcon[32], strIP[16], teleid;
	teleid = strval(params);
	if(!IsPlayerConnected(teleid)) return SendClientMessage(playerid, COLOR_RED, "Cet ID est inutilisé.");
    GetPlayerIp(teleid, strIP, 16);
	format(strRcon, sizeof(strRcon), "banip %s", strIP);
	SendRconCommand(strRcon);
	SetPVarString(teleid, "pIP", strRcon);
	SendClientMessage(teleid, COLOR_RED, "Reconnexion en cours...");
	return SendClientMessage(playerid, COLOR_RED, "Reconnexion du joueur en cours.");
}*/
