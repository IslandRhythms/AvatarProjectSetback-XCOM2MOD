//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_AvatarProjectSetback.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_AvatarProjectSetback extends X2DownloadableContentInfo;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{}

static event OnPostMission() {
	local XComGameState_BattleData BattleData;
	local XComGameState_AdventChosen ChosenState;
	local X2MissionTemplateManager MissionTemplateManager;
	local X2MissionTemplate MissionTemplate;
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_HeadquartersAlien AlienHQ;
	local bool MissionSuccess;
	local string obj, ChosenType;
	local int i;
	History = `XCOMHISTORY;
	AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));

	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	// reports that some clauses aren't executing, so add a second clause that double checks everything
	if (BattleData.ChosenRef.ObjectID == 0) {
		return;
	}
	ChosenState = XComGameState_AdventChosen(`XCOMHISTORY.GetGameStateForObjectID(BattleData.ChosenRef.ObjectID));
	ChosenType = string(ChosenState.GetMyTemplateName());
	ChosenType = Split(ChosenType, "_", true);
	// This should work because once the chosen is permanently defeated, we'll never encounter them again.
	MissionTemplateManager = class'X2MissionTemplateManager'.static.GetMissionTemplateManager();
	MissionTemplate = MissionTemplateManager.FindMissionTemplate(BattleData.MapData.ActiveMission.MissionName);
	MissionSuccess = BattleData.bLocalPlayerWon && !BattleData.bMissionAborted;
	obj = MissionTemplate.DisplayName;
	if (MissionSuccess && (obj == "Defeat Chosen Warlock" || (ChosenType == "Warlock" && BattleData.bChosenDefeated))) {
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Subtract Doom Timer due to Chosen Defeat");
		AlienHQ = XComGameState_HeadquartersAlien(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersAlien', AlienHQ.ObjectID));
		AlienHQ.RemoveDoomFromFortress(NewGameState, 2, "Chosen Warlock Exterminated");
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
		} else if (MissionSuccess && (obj == "Defeat Chosen Assassin" || (ChosenType == "Assassin" && BattleData.bChosenDefeated))) {
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Subtract Doom Timer due to Chosen Defeat");
			AlienHQ = XComGameState_HeadquartersAlien(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersAlien', AlienHQ.ObjectID));
			AlienHQ.RemoveDoomFromFortress(NewGameState, 2, "Chosen Assassin Exterminated");
			`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
		} else if (MissionSuccess && (obj == "Defeat Chosen Hunter" || (ChosenType == "Hunter" && BattleData.bChosenDefeated))) {
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Subtract Doom Timer due to Chosen Defeat");
			AlienHQ = XComGameState_HeadquartersAlien(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersAlien', AlienHQ.ObjectID));
			AlienHQ.RemoveDoomFromFortress(NewGameState, 2, "Chosen Hunter Exterminated");
			`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
		}
}