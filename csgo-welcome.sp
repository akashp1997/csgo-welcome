//Sourcemod Includes
#include <sourcemod>
#include <multicolors>

//Pragma
#pragma semicolon 1
#pragma newdecls required

//Globals
bool g_bMessagesShown[MAXPLAYERS + 1];

ConVar textColor;
ConVar separatorColor;
ConVar linkTextColor;
ConVar serverNameTextColor;
ConVar playerNameTextColor;

ConVar serverDisplayName;
ConVar serverLink;
ConVar websiteLink;
ConVar feedbackLink;

static char separator[] = "--------------------------------------------------------------------------";

public Plugin myinfo = 
{
	name = "Welcome Message", 
	author = "Akash Purandare", 
	description = "Welcome message sent to each user for joining the server", 
	version = "1.0.0", 
	url = "https://fegaming.xyz"
};

public void OnPluginStart()
{
	ConVar g_cServerDisplayName = CreateConVar("sv_displayname", "", "Name of the CS:GO server");

	ConVar g_cTextColor = CreateConVar("sm_msg_text_color", "white", "The color name for the base text");
	ConVar g_cSeparatorColor = CreateConVar("sm_msg_separator_color", "white", "The color name for the separator");
	ConVar g_cLinkTextColor = CreateConVar("sm_msg_link_text_color", "blue", "The color name for the link text");

	ConVar g_cServerNameTextColor = CreateConVar("sm_msg_server_name_text_color", "green", "The color name for the server name text");
	ConVar g_cPlayerNameTextColor = CreateConVar("sm_msg_player_name_text_color", "red", "The color name for the player name text");

	ConVar g_cServerLink = CreateConVar("sm_msg_server", "", "URL to your CS:GO server");
	ConVar g_cWebsiteLink = CreateConVar("sm_msg_website", "", "Link to your website");
	ConVar g_cFeedbackLink = CreateConVar("sm_msg_feedback", "", "Link to your feedback URL");
	// https://forms.gle/7L3X6zedh4PuwNEU6
	
	AutoExecConfig(true, "csgo-welcome");
	g_cTextColor.GetString(textColor, sizeof(textColor));
	g_cLinkTextColor.GetString(linkTextColor, sizeof(linkTextColor));
	g_cSeparatorColor.GetString(separatorColor, sizeof(separatorColor));
	g_cServerNameTextColor.GetString(serverNameTextColor, sizeof(serverNameTextColor));
	g_cPlayerNameTextColor.GetString(playerNameTextColor, sizeof(playerNameTextColor));

	g_cServerDisplayName.GetString(serverDisplayName, sizeof(serverDisplayName));
	g_cServerLink.GetString(sServerLink, sizeof(sServerLink));
	g_cWebsiteLink.GetString(sWebsiteLink, sizeof(sWebsiteLink));

	LoadTranslations("csgo-welcome.phrases");
	HookEvent("player_spawn", Event_OnPlayerSpawn);
}

public void OnMapStart()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		g_bMessagesShown[i] = false;
	}
}

public void Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (client == 0 || IsFakeClient(client))
	{
		return;
	}
	
	CreateTimer(0.2, Timer_DelaySpawn, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public void Print_Separator(int client)
{
	char separatorColor[128];
	g_cSeparatorColor.GetString(separatorColor, sizeof(separatorColor));

	char message[128];
	Format(message, sizeof(message), "{grey}%s{default}", separator);
	CFormatColor(message, sizeof(message));
	CPrintToChat(client, "%s", message);
}

public void Print_Title(int client)
{

}

public Action Timer_DelaySpawn(Handle timer, int clientId)
{
	int client = GetClientOfUserId(clientId);
	
	if (client == 0 || !IsPlayerAlive(client) || g_bMessagesShown[client])
	{
		return Plugin_Continue;
	}
	char clientName[128];
	if (!GetClientName(client, clientName, sizeof(clientName))) {
		return Plugin_Continue;
	}

	char textColor[128];
	char linkTextColor[128];
	char serverNameTextColor[128];
	char playerNameTextColor[128];

	char serverDisplayName[128];
	char sServerLink[128];
	char sWebsiteLink[128];


	
	Print_Separator(client);
	CPrintToChat(client, "%t", "CLine1", textColor, serverNameTextColor, serverDisplayName, playerNameTextColor, clientName);
	CPrintToChat(client, "%t", "CLine2", textColor, linkTextColor, sServerLink);
	Print_Separator(client);
	g_bMessagesShown[client] = true;
	
	return Plugin_Continue;
}

public void OnClientDisconnect(int client)
{
	g_bMessagesShown[client] = false;
}
