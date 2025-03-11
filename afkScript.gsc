#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\_hud_util;

init()
{
	level.debugMode = true;
    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{
    self endon("disconnect");
	
    for(;;)
    {
        self waittill("spawned_player");
		self iPrintLn("AFK plugin initialized");
        self thread menuOpenListener();
		self thread debugMenuListener();
    }
}

menuOpenListener()
{
    self endon("disconnect");
	
    for(;;)
    {
        if(self adsButtonPressed() && self meleeButtonPressed())
        {
            self toggleAFKMode();
            wait 0.5;
        }
        wait 0.05;
    }
}

debugMenuListener()
{
    self endon("disconnect");
	
	if(level.debugMode == true)
	{
	    self iPrintLnBold("Server: Debug mode active");
		
		for(;;)
		{
			if(self fragButtonPressed())
			{
				self thread doGetposition();
				self thread givePoints();
			}
			wait 0.05;
		}
	}
}

toggleAFKMode()
{
    if (!isDefined(self.lastAFKToggleTime))
    {
        self.lastAFKToggleTime = 0;
    }

    currentTime = int(getTime() / 1000); // Convert to seconds

    // Restrict enabling AFK mode if less than 60 seconds have passed
    if ((!isDefined(self.isAFK) || !self.isAFK) && (currentTime - self.lastAFKToggleTime < 60))
    {
        self iPrintLnBold("^1AFK Mode can only be enabled once per minute!");
        return;
    }

    self.lastAFKToggleTime = currentTime; // Update last toggle time only on enable

    if (!isDefined(self.isAFK) || !self.isAFK)
    {
        self.isAFK = true;
        //self iPrintLnBold("AFK Mode: ON");
        self thread afkModeOn();
    }
    else
    {
        self.isAFK = false;
        //self iPrintLnBold("AFK Mode: OFF");
        self thread afkModeOff();
    }
    
    self closeMenu();
}


afkModeOn()
{
    self endon("disconnect");
	self thread notifyAFK();
	
    // Enable god mode
    if (!self.god)
    {
        self doGod();
    }

    // Optionally, you can freeze the player in place
    self freezeControls(true);
	
	test = spawnStruct();
	
	test.origin = ( -431, 22, 258 );
	test.angles = ( 0, 58, 0 );
	
	ship = GetEnt( "model_zombie_rocket", "targetname" );
	teleportPlayer(self, test);
	
	//playerName = self.name;
	
	//level iPrintln("AFK: ^2+playerName");
    // Add a visual indicator in the middle of the screen
	self.afkText = newClientHudElem(self);
	self.afkText.alignX = "center";
	self.afkText.alignY = "center";
	self.afkText.x = 80;  // Moved right
	self.afkText.y = 20;
	self.afkText.fontScale = 2.0;
	self.afkText.alpha = 0.8;
	self.afkText setText("^5AFK MODE ON");

	self.afkText2 = newClientHudElem(self);
	self.afkText2.alignX = "center";
	self.afkText2.alignY = "center";
	self.afkText2.x = 80;  // Moved right
	self.afkText2.y = 50;
	self.afkText2.fontScale = 1.2;
	self.afkText2.alpha = 0.8;
	self.afkText2 setText("^7Press ^5[Right Click (AimDownSights)] ^7& ^5[V (Melee Button)] ^7to exit AFK");

	self.afkText3 = newClientHudElem(self);
	self.afkText3.alignX = "center";
	self.afkText3.alignY = "center";
	self.afkText3.x = 80;  // Moved right
	self.afkText3.y = 80;
	self.afkText3.fontScale = 1.2;
	self.afkText3.alpha = 0.8;
	self.afkText3 setText("^7Now playing:");

	self.afkText4 = newClientHudElem(self);
	self.afkText4.alignX = "center";
	self.afkText4.alignY = "center";
	self.afkText4.x = 80;  // Moved right
	self.afkText4.y = 110;
	self.afkText4.fontScale = 1.2;
	self.afkText4.alpha = 0.8;
	self.afkText4 setText("^5Oluthuone ^7| ^5No Perk Limit ^7| ^5PhD & Stam");


    // Wait for the player to turn off AFK mode
    self waittill("afk_mode_off");
}

afkModeOff()
{
    self notify("afk_mode_off");
	
	trigger_name = "trigger_teleport_pad_0";
	core = getent( trigger_name, "targetname" );
	pad = getent( core.target, "targetname" );
	
	teleportPlayer(self, pad);

    // Remove the visual indicator
    if (isDefined(self.afkText))
    {
        self.afkText destroy();
		self.afkText2 destroy();
		self.afkText3 destroy();
		self.afkText4 destroy();
        self.afkText = undefined;
    }

    // Unfreeze the player if you froze them
    self freezeControls(false);

    // Start the grace period
    self thread afkGracePeriod();
}

afkGracePeriod()
{
    self endon("disconnect");

    // Create a centered HUD element for the grace period message
    graceText = newClientHudElem(self);
    graceText.alignX = "left";
    graceText.alignY = "left";
    graceText.x = 20;
    graceText.y = 20;
    graceText.fontScale = 1.2;
    graceText.alpha = 0.8;
    graceText setText("^3Grace period: 10 seconds");

    // Ensure god mode is on for the grace period
    if (!self.god)
    {
        self doGod();
    }

    wait 5;
	
	graceText setText("^3Grace period: 5 seconds");
	wait 2;
	graceText setText("^3Grace period: 3 seconds");
	wait 3;
    // Disable god mode after grace period if it was enabled by AFK mode
    if (self.god)
    {
        self doGod();
    }

    // Update the grace period message
    graceText setText("^1Grace period ended");
    wait 2;  // Display the message for 2 seconds
    graceText destroy();  // Remove the HUD element
}

doGod()
{
    if(self.god == false)
    {
        self enableInvulnerability();
		//self SetClientDvar("notarget", "1");
        //self iPrintln("Godmode: ^2Enabled");
		//self.isnotarget = true;
        self.god = true;
    }
    else if(self.god == true)
    {
        self disableInvulnerability();
		//self SetClientDvar("notarget", "0");
        //self iPrintln("Godmode: ^1Disabled");
		//self.isnotarget = false;
        self.god = false;
    }
}

doGetposition()
{
	self endon ("disconnect"); 
	self endon ("death"); 

	for(;;)
	{
		playerName = self.playername;
	
		graceText = newHudElem(self);
		graceText.alignX = "left";
		graceText.alignY = "left";
		graceText.x = 20;
		graceText.y = 20;
		//graceText.foreground = 1;
		graceText.fontScale = 1.2;
		graceText.alpha = 0.8;
		graceText setText("^3Grace period: 10 seconds"+playerName);
	
		self iPrintln("AFK: ^2"+playerName);
		self iPrintln("Angle: "+self.angles+"\nPosition: "+self.origin);
		wait 5;
		graceText destroy();
		break;
	}
}

teleportPlayer(player, o)
{
	//trigger_name = "trigger_teleport_pad_0";
	//projroom_name = "projroom";
	//core = getent( trigger_name, "targetname" );
	//pad = getent( core.target, "targetname" );
	//ship = GetEnt( "model_zombie_rocket", "targetname" );
	//projroom = getent( projroom_name, "targetname" );
	player setOrigin( o.origin + (RandomFloat(48), RandomFloat(48), 0)); //avoid telefrag
    player setPlayerAngles(o.angles);
}

givePoints()
{
	self.score += 20000;
}

notifyAFK()
{	
	playerName = self.playername;

	// Show AFK message
	notifyText = newHudElem(self);
	notifyText.alignX = "left";
	notifyText.alignY = "left";
	notifyText.x = 20;
	notifyText.y = 140;
	notifyText.fontScale = 1.2;
	notifyText.alpha = 0.8;
	notifyText SetText("^4" + playerName + " ^7is now AFK");

	wait 5;
	notifyText Destroy();

	self waittill("afk_mode_off");

	// Show AFK OFF message
	notifyText = newHudElem(self);
	notifyText.alignX = "left";
	notifyText.alignY = "left";
	notifyText.x = 20;
	notifyText.y = 140;
	notifyText.fontScale = 1.2;
	notifyText.alpha = 0.8;
	notifyText SetText("^4" + playerName + " ^7is no longer AFK");

	wait 5;
	notifyText Destroy();
}