#pragma semicolon 1

#define DEBUG

#define PLUGIN_NAME "Download List"
#define PLUGIN_AUTHOR "Rowdy4E."
#define PLUGIN_DESC "Download list with supported files for precaching."
#define PLUGIN_VERSION "1.00"
#define PLUGIN_URL "https://steamcommunity.com/profiles/76561198307962930"

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

public Plugin myinfo = 
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESC,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

public void OnMapStart()
{
	LoadConfig();
}

void LoadConfig() {
	char Path[248];
	BuildPath(Path_SM, Path, sizeof(Path), "configs/download_list.cfg");
	
	Handle hFile;
	if (!FileExists(Path)) {
		hFile = OpenFile(Path, "w");
		if (hFile != null) {
			WriteFileLine(hFile, "# Supported files for precaching: .mp3 .wav .mdl .pcf");
			WriteFileLine(hFile, "# Author: Rowdy4E.");
			WriteFileLine(hFile, "# Contact: https://steamcommunity.com/profiles/76561198307962930");
			
			delete hFile;
		}
	}
	
	char buffer[512];
	hFile = OpenFile(Path, "r");
	
	if (hFile != null) {
		while (ReadFileLine(hFile, buffer, sizeof(buffer))) {		
			if (strlen(buffer) > 0 && buffer[strlen(buffer) - 1] == '\n')
				buffer[strlen(buffer) - 1] = '\0';
			TrimString(buffer);
			if (strlen(buffer) == 0)
				continue;
			if (StrContains(buffer, "\\") != -1)
				ReplaceString(buffer, sizeof(buffer), "\\", "/");
			if (StrContains(buffer, "//") != -1 || StrContains(buffer, "#") != -1)
				continue; 
			if (StrContains(buffer, ".mdl") != -1) {
				if (!IsModelPrecached(buffer))
					PrecacheModel(buffer);
			}
			if (StrContains(buffer, ".pcf") != -1) {
				if (!IsModelPrecached(buffer))
					PrecacheGeneric(buffer, true);
			}
			if (StrContains(buffer, ".mp3") != -1 || StrContains(buffer, ".wav") != -1) {
				if (StrContains(buffer, "sound/") != -1)
					ReplaceString(buffer, sizeof(buffer), "sound/", "");
				if (!IsSoundPrecached(buffer))
					PrecacheSound(buffer, true);
				Format(buffer, sizeof(buffer), "sound/%s", buffer);
			}
			AddFileToDownloadsTable(buffer);
		}
		delete hFile;
	}
	
}