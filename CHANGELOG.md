######v1.5
* Updated UI for BFA pre-patch
* Bugs still remain, but I will work on them over time.
* TODO: UnitFrames/Auras

######v1.4.3
* Updated readme with FailcoderAddons link from failcoder
* Updated InfoBottom to no longer offset right and overlap the border for issue #161
* Removed extraneous size change for issue #160
* Reordered NPC Model function calls for issue #176
* Added BfA Currencies to tokens.lua report
* Added BfA Breakables to breakstuff.lua
* Added Dark Iron Dwarf racial to misc.lua Docklet as a Hearthstone option

######v1.4.2
* Curse build should have all features now

######v1.4.1
* Quick Join Toast skin now positions properly

######v1.4
* Full 7.3 compatibility
* New Feature - Added Quick Join Toast skin
* Tons of skin fixes
* Bug fixes galore

######v1.3.5
* Some skin fixes for many blizz frames
* Fixed guild bank background issue

######v1.3.3
* Fixed Demon Hunter issues

######v1.3.21
* Fixed warlock shard count
* Fixed errors in druid bar
* Removed erroneous code from nameplates
* Revised health and power bar handlers for more accurate updates

######v1.3.2
* Fixed shaman/mage/pally/rogue resources
* Nameplates are usable again though for now they are very stripped down
* inventory bugs fixed
* added all the new power types to color options
* other misc bugs fixed

######v1.3.19
* Fixed final rogue resource bug
* Updated mage resources
* Updated many fx animations that lost their shape
* Heavily stripped down nameplates so that they can utilize the new native plates for now
* Fixed bag sorting errors
* Resolve bar for tanks is disabled by default now

######v1.3.1
* Fixed class resources for warlock/druid/dk and rogues
* Fixed errors coming from installer

######v1.3.0
* Fixed breaking changes from client patch 7.0.3, more to come

######v1.2.8
* Fixed bad skins

######v1.2.71
* Updated raid group layout for vertical settings

######v1.2.7
* Fixed and adjusted raid/party/raidpet frame layout anchoring. They will no longer scatter when removing groups or showing labels
* Adjusted raid debuff appearances. Icons will properly hide name text when shown to keep the frames from being unread-ably cluttered. Colored overlays are FAR less overpowering now and will properly color the frame border .
* Fixed several issues with tooltips when mousing over units that for one reason or another are not yet broadcasting their name/class/level etc... this was causing terrible errors.
* Fixed several token readouts in data texts (reports). Conquest for example will now properly display week max values.
* Adjusted the way that capture bars are handled and anchored. They were dancing around the screen before.
* Made many logical changes to dock functionality. (internal) 
 
######v1.2.67
* Adjusted skin for Storyline
* Fixed an issue with popup quest completion
* Added admirals compass to hearth button options 
 
######v1.2.65
* Adding full support and skinning of Storyline to SVUI_Skins
* Fixed an issue with shared data regarding embeds (addon docks)
* Stage 1 of some needed code optimizations 
 
######v1.2.63
* Fixed screen scaling issues
* Added advanced profile button to options screen
* Cleaned up vehicle bar code 
 
######v1.2.61
* Added shared options to profile settings (for Docks and Chat).
* Fixed ActionBar vehicle assignments.
* Changed a few options menu layouts (Profiles, ActionBars)
* Fixed bad skinning on Raid Leader docklet
* Released SVUI's unforgiving control over Ace libs (found a better way to do what I need) 
 
######v1.2.6
* Added ability to set vehicle bar other than bar 1.
* Added toggle for "!" aggro icon.
* Adjusted layout of auctionhouse skin.
* Fixed positioning of craft and fight o-matics.
* Internal improvements 
 
######v1.2.5
* Fixed LFG/LFD role skins, chat handlers, data retention and rarity coloring on character screen slots and tooltips
* Quest popups fixed. Combat fader adjusted for player frame 
 
######v1.2.46
* Fixed Chat frame alignments
* More adjustments to chat channel handling (persisting issues may require resetting all chat options)
* Removed Details docking ability (this was incredibly unstable), this will not be returning but the skinning of Details will remain
* Adjusted several frames that had bad default alignments
* Several skins have been updated
* Fixed potential bug in unitframe portraits 
 
######v1.2.4
* Made improvements to chat frames allowing them to more effectively save selected channel/message type selections
* Fixed issue where new chat frames would not show the backdrop
* Fixed issue where accidentally dragging a tab would dislodge the chat frame
* Adjusted colors for "paper" type skins
* Reduced the opacity of the frame moving backdrop
* Misc internal fixes... 
 
######v1.2.36
* Dock backgrounds and alpha states have been improved
* Revised the debuff highlight texture for better visibility
* Added new Master Profile option under Profiles. enabling this will allow you to have a one-click install process for any new characters you log in with (new meaning, has not had SVUI installed for it yet) 
 
######v1.2.35
* Fixed many broken color and texture customization options
* Added more textures to the shared library (see "SVUI Model BG 2" thru "SVUI Model BG 30")
* Improved the "Dead" and "Tapped" icons for smaller unit frames.
* New layout commands available (type "/sv move help" for more info)
* Misc bug fixes. 
 
######v1.2.3
* Filtered auras will now properly appear in the "Aura Filters" option menu
* NEW: NPC models for gossip, merchant and quest windows. (toggle option is under FunStuff)
* Fixed a few misc errors from skins and unitframes
* Added toggles for Monk stagger bar, and druid combo/mana/eclipse elements
* Re-styled the NPC models to make them "fit" more comfortably
* Actionbutton glowing on procs is fixed
* Added toggle options for the calendar and tracking shortcuts
* Zygor code change (thanks to antisocialian)
* Adjusted a few prev/next button skins 
 
######v1.2.29
* Classic style class resources for DeathKnights and Rogues added (options->UnitFrames->Player->ClassBar->**)
* Darkmoon bags will no longer appear behind the main bag frame
* Assist units will now hide properly when toggled to do so
* Chat vanishing fix revised 
 
######v1.2.2
* Added (SHIFT right/left) click option menus for hearthstone button
* Tooltips will stay hidden when the dock containing it has been faded out
* Added Oil to tokens data text, alpha-ordered the list as well
* More backend changes for chat window reactions
* Other error fixes
* Chat vanishing issue resolved
* Added multi-realm support to profiles 
 
######v1.2.14
* Fixed many dock button click functions that were not previously working
* Skada will once again dock and the dock button will allways show if a qualifying addon is loaded. This allows you access when wanting to embed an addon.
* Fixed some DeathKnight bugs
* Added new corner dock buttons (gear icon) to allow menu access to enabled/disabled docks and chat tabs.
* Changed the original corner dock button icons
* Quests will no longer show completed objectives improperly 
 
######v1.2.1
* Chat features enhanced and further integrated into the SVUI docking system
* Many skins adjusted
* Nameplate threat coloring is more intuitive
* quest objectives showing complete incorrectly are fixed 
 
######v1.2.02
* small adjustments to skins, chat anchoring, zone ability button styling and nameplate options
* visibility adjustments
* friends list (datatext) revised
* fixed combat issue in docks causing silent errors 
 
######v1.2.01
* layout updates and bug fixes
* Mentalo can now resize some frames
* party/raid/raidpet RaidDebuffs and Debuff highlighting is fully operational 
 
######v1.2.0
* Dock buttons can be moved by [shift+click+drag] now
* Docks now save the last docklet you had open to reload when logging in
* Docks for other addons have bug fixes and have been improved in general
* Quest item bar has been tweaked to fix some errors and improve its layout
* Addons list is now styled
* The gold reading on the inventory frame now has a tooltip that will show totals for all server characters
* The frame moving tool now has an individual reset button that can be accessed when right-clicking a frame (aka the precision frame)
* Greatly improved nameplates and the use of threat coloring within them
* Revised some missing styles from various skins including PVP and LFD/LFG frames
* WorldStateCaptureBars updated
* More code cleanup.

######v1.1.952:
* Added options under General->Gear for enabling/disabling iLevel texts
* Adjusted LFG/LFR skins
* Code cleanup

######v1.1.95:
* Added many more background textures for units and other frames
* Credits and credit roll feature updated
* Updated skins for encounterjournal, waorldmap and others to prepare for the next game patch
* Fixed QuestTracker row height usage
* Adjusted QuestTracker popup quest layout
* Fixed AutoGreed bugs
* Hotfix for chat font resets
* Default action bars positioning adjusted
* BG colors on 3D portrait overlays have been darkened to make the actual health bar stand out more
* Adjusted the color transitions for the overlay health bar
* Slight adjustments to unitframe borders and info/text shadows
* Default unitframe aura timers updated to use a cleaner font
* Made some changes to frame style API to keep some templates more consistent
* Mouseover highlighting of a bags containers has now been added to the bank bags as well.
* Fixed the default Blizzard bag sorting integration. To use just hold SHIFT when clicking the Sort button.
* iLevels, buff casters, chat url links and art updates.

V1.1.9:
* New textures added for unitframe backdrops (3D portrait overlay only)
* New utility added to randomly select and set a backdrop across all unitframes 
* Fixed tracking arrow for quest tracker when using Track-O-Matic
* Fixed chat fonts resetting when starting/stopping pet battles
* New auto loot roll options (max level, quality and others)
* Added 3D effects to shaman and druid (eclipse) class bars, also optimized their code.
* Fixed spacing issue in tooltips
* More TBA

######v1.1.81 (no version change):
* Added the ability to DETACH the power bar from any unit frame (that has a power bar ofc)
* Added a spacing option to unit frame buffs and debuffs for more customization with layouts
* Made some more anchoring corrections for various textures that had been bleeding outside of their borders
* Some adjustments to scaling, correcting previous issues.

######v1.1.8:
* NEW BodyGuard frame
* Fixed issues with UnitFrame portraits and scaling
* Added orientation options for health and mana (ie... horizontal or vertical)
* Chat timestamps and filters cleaned up
* More skin adjustments to various elements
* Some scaling changes for textures
* Quest Tracker item buttons have improved show/hide accuracy now
* toc license info updates

######v1.1.7:
* Tooltips now have the option to add player character gender.
* XP report has click-options for formatting now.
* Fixed bad show/hide states for bottom left dock items. (Garrison and chat tabs)
* Fixed bad channel handling for chat windows
* Added new color option for unit health backdrops
* Adjusted spellbook fonts
* Credits updated
* QoL changes and more code cleaning.

######v1.1.6(2): (no official version change)
* Chat channels are fixed for all created windows.
* Adjusted positioning for credits and now you can simply click them to hide.

######v1.1.61:
* Added log in credits (a crazy idea I had that I have fallen in love with). These can be disabled in options under General (right next to the option for login messages)
* Fixed Tank/Assist option errors
* Fixed inventory searching when including your bank/reagents
* Re-positioned a few elements
* Added WoD lures to the CraftOMatic fishing mode (thank you madde007)
* Fixed a bug causing errors sometimes when you receive a whisper
* Other misc code cleanup


######v1.1.6:
* Added Open-Dyslexic font to shared media
* Fixed display bug in docklet tooltips
* Adjusted stance/pet bar anchoring
* Fixed issue causing conflict with Zygor

######v1.1.5:
* Map zone text updated to minor location, actual zone will show when moused over.
* Bag toggle issues COMPLETELY fixed.
* Alt character loot count functions have been updated to be fully accurate (this may take one more round of logging on each toon to populate).
* Fixed AFK bug preventing the animation from hiding when needed.
* Added remaining henchmen to the (ESC) game menu feature.
* Fixed some issues keeping CraftOMatic from swapping gear properly.
* other minor changes...

######v1.1.4:
* Fixed pet action bar checked textures
* Fixed remaining bag toggle issues

######v1.1.3:
* missing UnitFrame options for the "Tank" and "Assist" frames are available
* Adjusted some events involved with opening and closing bags. There were a few more instances where you would have to hotkey twice to open them again.
* Some slight style improvements to QuestTracker rows
* CharacterFrame Titles list is once again using the SVUI default font object and can be adjusted.
* Quest reward highlight adjusted again
* AceGUI errors when attempting to drag frames are fixed
* Moved the lua settings specifically for DAMAGE TEXT to its own script (SVUI_!Core\system\damage_text.lua) for those who are manually changing these settings
* All LICENSE files have been properly updated (thanks Bob)

######v1.1.2:
* Fixed unitframe healthbar framelevel issue
* Made some code improvements to the mail minion
* Archaeology window in CraftOMatic was not showing properly, this is now fixed

######v1.1.102:
* Removed debug messages from data brokers
* Made adjustments to the AceGUI overrides to add more consistent style to UI widgets
* Added missing options for threat thermometer and the ability to disable drunk mode entirely

######v1.1.1:
* Fixed totem bar auras and their right-click-to-deactivate functionality. (it appears that shaman were NEVER able to do this in previous versions of SVUI)
* Fixed quest choice texturing and removed debug code from function hook
* released libsharedmedia from my evil clutches (this will fix the texture issues in CoolLine and DXE among others)
* cleaned up a hand full of needless scripts (and comments)

######v1.1.081:
* Made some small adjustments to UnitFrame auras to hopefully relieve certain filtering issues
* NEW: Finally finished adding the "Proc Watch" feature. This is found in the SVUI_Auras addon options and you can add/remove spells from it under "Aura Filters"->Procs

######v1.1.08:
* Fixed bug preventing users from excluding the unitframes module without causing screen errors.

######v1.1.079: (No ACTUAL version change)
* Adjusted a few more skins (Garrison, Encounter Journal, Collections... others)
* Fixed issue with media tables trying to load UnitFrames even if they do not exist.
* Added a slash command "/sobriety" that will END drunk mode.
* The "End Taxi Ride Early" button has been added (it actually the same as the exit vehicle button, just added the functionality)
* Move the Skins messages (such as "[Skinned] Skada: Is Now Fancy!") to a hidden table accessible by using the command "/sv skins". These were starting to get annoying when having to /reload a lot.
* Made some changes to the "/jenkins" countdown timer's appearance.

######v1.1.07: (No version change)
* Adjusted a few skins to prevent taints

######v1.1.07:
* UnitFrame bug when changing to 2D portraits fixed
* Bag loot counts for all characters were inaccurate, this has been fixed
* time, reputation and other data text bugs fixed (not including bugs from OTHER addons)
* New profile sharing system is up and running, not exactly user friendly yet but it works. More details on this soon.
* Vanishing filters, and frame positions are now fixed
* Debugging code removed
* Custom class color selection really fixed this time!
* Weirdness with installer and action bars fixed
* Fixed enabling and disabling of unitframe auras
* Target-of-target's default position was previously changed and never fully coded, this is now fixed.
* Added an option for unitframes that allows you to hide/show the black gradient behind your unitframe's infopanel

######v1.1.064:
* Patched several bugs

######v1.1.062:
* Windows will again honor color scheme selections
* Altered the color scheme "Darkness", it really wasnt dark enough
* Unitframe icon auras were not recalculating time properly when they had more than one stack, this is now fixed.
* Totems were causing issues with mouse clicks, totems being cancelled for no reason and a slew of other nightmares. These are now fixed.
* There was a rare condition that was causing custom filters to vanish, emphasis on "was".

######v1.1.06:
* Adjusted data cleaning functions to prevent unnecessary loss of layout data
* Data storage of data texts has been re-written and (consequently) required a settings reset of docked text choices. This was necessary as there was a bug causing savedVariable files to explode with needless table indexes.

######v1.1.05:
* Ace overrides are again in place but properly implemented this time. Addons will no longer experience issues from missing library data.
* The override system is now somewhat forgiving for nearly all possible libraries. The only things severely restricted are AceConfig-3.0 (widgets) and LibWindow-1.1.
* ADDED: Found some skins that were not working as intended (Garrison recruiter and player trade)
* ADDED: Fixed keybinds and other missed internals for action bars 7-10
* ADDED: Fixed one final issue with AceGUI override
* ADDED: Adjusted unitframe portraits and powerbars. I had noticed that several different layouts were leaving ugly transparent gaps.

NOTE: LibWindow-1.1 HAS to be controlled in order to allow Skada to be safely docked.

######v1.1.05:
>Reverting Ace changes for now

######v1.1.01:
* Final revision to profiles (all tests are good now)
* Final revision to Skada issues (tested good)

######v1.1.0:
* Fixed bad handling of dockable addon windows and their options
* Complete refresh of profile functionality (limited settings loss)

######v1.0.092:
* Fixed options crash caused by colorpicker

######v1.0.09:
* Fixed options crash caused by certain aura filter choices
* Massive cleanup of bad globals and localized functions. This resulted in an increase of 10~40 FPS.

######v1.0.072:
* Fixed Skada docking (for good this time)
* When selecting addons to dock, you will no longer be restricted by the order which you assign them to either primary or secondary docks. (see note below)
* Adjusted castbar text wrapping
* Adjusted docked addon styling slightly

NOTE: Before, the primary dock would always be the FULL WIDTH docklet while secondary (when assigned) would cause the dock to SPLIT. This has changed. Now, regardless of which dock you place an addon in, if it is the ONLY dock with and addon it WILL BE FULL WIDTH. You will also not have to worry about the options greying out and locking choices ever again.


######v1.0.071:
* Fixed Zygor map button
* Fixed bug in misc skin
* Small adjustment to profile copying

######v1.0.07:
* Updated profiles, fixed bad matching of selected profile keys with live data
* All known option bugs fixed
* Adjusted quite a few styles and skins
* Tweet buttons working
* Experience bug fixed
* Auto vendoring bug fixed

* Added Zygor support to minimap buttons
* Added chat channel abbreviation option (default is enabled)
* More fixes to Profiles
* More fixes to automations
