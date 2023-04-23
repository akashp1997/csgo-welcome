//Sourcemod Includes
#include <sourcemod>
#include <chat-processor>
#include <colorvariables>

//Pragma
#pragma semicolon 1
#pragma newdecls required

//Globals
bool g_bMessagesShown[MAXPLAYERS + 1];

ConVar g_cTextColor;
ConVar g_cSeparatorColor;
ConVar g_cLinkTextColor;
ConVar g_cServerNameTextColor;
ConVar g_cPlayerNameTextColor;

ConVar g_cServerDisplayName;
ConVar g_cServerLink;
ConVar g_cWebsiteLink;
ConVar g_cFeedbackLink;

char serverLink[128];
char websiteLink[128];
char feedbackLink[128];

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
	g_cServerDisplayName = CreateConVar("sm_hostname", "", "Name of the CS:GO server");

	g_cTextColor = CreateConVar("sm_msg_text_color", "default", "The color name for the base text");
	g_cSeparatorColor = CreateConVar("sm_msg_separator_color", "grey2", "The color name for the separator");
	g_cLinkTextColor = CreateConVar("sm_msg_link_text_color", "blue", "The color name for the link text");

	g_cServerNameTextColor = CreateConVar("sm_msg_server_name_text_color", "green", "The color name for the server name text");
	g_cPlayerNameTextColor = CreateConVar("sm_msg_player_name_text_color", "red", "The color name for the player name text");

	g_cServerLink = CreateConVar("sm_msg_server", "", "URL to your CS:GO server");
	g_cWebsiteLink = CreateConVar("sm_msg_website", "", "Link to your website");
	g_cFeedbackLink = CreateConVar("sm_msg_feedback", "", "Link to your feedback URL");
	// https://forms.gle/7L3X6zedh4PuwNEU6
	
	AutoExecConfig(true, "csgo-welcome");

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
	CPrintToChat(client, "%t", "Separator", separatorColor);
}

public void Print_Welcome_Line(int client)
{
	char textColor[128];
	char linkTextColor[128];
	char serverNameTextColor[128];
	char playerNameTextColor[128];
	char serverDisplayName[128];

	g_cTextColor.GetString(textColor, sizeof(textColor));
	g_cLinkTextColor.GetString(linkTextColor, sizeof(linkTextColor));
	g_cServerNameTextColor.GetString(serverNameTextColor, sizeof(serverNameTextColor));
	g_cPlayerNameTextColor.GetString(playerNameTextColor, sizeof(playerNameTextColor));
	g_cServerDisplayName.GetString(serverDisplayName, sizeof(serverDisplayName));

	char clientName[128];
	if (!GetClientName(client, clientName, sizeof(clientName))) {
		LogError("Unable to get client name for ID: %d", client);
		return;
	}
	CPrintToChat(client, "%t", "Welcome_Line", textColor, serverNameTextColor, serverDisplayName, textColor, playerNameTextColor, clientName, textColor);
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

	Print_Separator(client);
	Print_Welcome_Line(client);
	//CPrintToChat(client, "%t", "CLine2", textColor, linkTextColor, serverLink);
	Print_Separator(client);
	g_bMessagesShown[client] = true;
	
	return Plugin_Continue;
}

public void OnClientDisconnect(int client)
{
	g_bMessagesShown[client] = false;
}
