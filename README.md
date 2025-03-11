# T5-ZM-AFK-Script

A Call of Duty: Black Ops 1 Zombies GSC script for Plutonium that lets players "pause the game" without disrupting gameplay for others.

Install by moving `afkScript.gsc` to `%localappdata%\Plutonium\storage\t5\scripts\sp\zom`

## Features:

### AFK Mode
- Toggle AFK mode with **[Aim Down Sights] + [Melee]**.  
- **60-second cooldown** between activations (configurable). 
- **Auto-disables after 2 minutes** (configurable).  
- Teleports player to a **safe AFK position** with a nice view 😎
- **God mode enabled** and controls frozen to prevent shooting.  
- Optional on-screen **HUD information** while AFK.
- Notify all players when someone enters/leaves AFK.

### AFK Return & Grace Period  
- **Teleports player back** to map spawn.  
- **10-second grace period** with **God mode enabled** (configurable).   
- Visual countdown before grace period ends.  

### Map Support  
- Predefined **AFK positions** for:
  - **Kino der Toten**  
  - **Five**  
  - Default fallback for unsupported maps. (May or may not work)
 
## 📌 Todo
 - Check if the player is alive or downed before enabling AFK mode.
 - Implement "anti cheese" to deny afk entry if zombies within set radius.
 - Refactor position variables, origin and angles can be set in one line?
 - Assign unique AFK teleport positions for all four players to avoid clipping when multiple players are frozen.
 - Implement a failsafe AFK return position system based on the player's location before AFK.  
  - Some maps require multiple return positions (e.g., Moon).
 - If possible find a way to set ignore player for those in AFK

---

## 🤝 Want to Contribute? (I don't own all maps)

### Instructions 
1. **Run the AFK script** on your own server or in client LAN mode.  
2. **Enable Debug Mode** by setting `debugMode` to true in GSC file.  
3. **Turn on sv_cheats** and use `ufo` to find a suitable AFK spot:  
   - Preferably somewhere with a good **map view** and **no zombie access/pathing**.  
4. **Collect Position Data**:  
   - Press the **Frag Button** to record both AFK and return positions.  
   - Ensure the return spot doesn't cause the player to get softlocked.  
5. **Submit Your Positions**:  
   - Add your coordinates to the **switch statement**.  
   - Create a **Pull Request** with your changes.  


## Preview, Kino Der Toten:

![image](https://github.com/user-attachments/assets/b38ac4d9-8176-4a72-8a34-bc9bd3d583e5)
