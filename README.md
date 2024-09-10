# Announcer Role for Custom Roles for TTT
![Announcer.png](https://steamuserimages-a.akamaihd.net/ugc/1807645146664865545/0CEBDF9495D3098FCA6096E9032E60AB3D2880B3/?imw=637&imh=358&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=true)

The Announcer is a member of the detective team that can see whenever someone buys an item!\
\
Whenever an item is bought, they see a notification in the centre of their screen, telling them the name of the weapon that was bought, the role of the player that bought the item, but not who it was.\
\
The traitors are notified when there is a announcer at the start of the round, as well as any other role that can buy items.

## ConVars
**ttt_announcer_enabled** (Default 0)\
*Whether or not the Announcer should spawn*\
\
**ttt_announcer_show_role** (Default 0)\
*Whether the announcer sees the role of the item-buying player*\
\
**ttt_announcer_spawn_weight** (Default 1)\
*The weight assigned to spawning the Announcer*\
\
**ttt_announcer_min_players** (Default 0)\
*The minimum number of players required to spawn the Announcer*\
\
**ttt_announcer_starting_health** (Default 100)\
*The amount of health the Announcer starts with*\
\
**ttt_announcer_max_health** (Default 100)\
*The maximum amount of health the Announcer can have*\
\
**ttt_announcer_shop_sync** (Default 0)\
*Whether the Announcer should have access to all detective shop items*\
\
**ttt_announcer_credits_starting** (Default 1)\
*The number of credits the Announcer should start with*\
\
**ttt_announcer_shop_random_enabled** (Default 0)\
*Whether the Announcer's shop contains a random selection of items it's assigned*\
\
**ttt_announcer_shop_random_percent** (Default 100)\
*The percent chance that each weapon in the Announcer's shop will not be shown*\
\
**ttt_announcer_name** (Default Announcer)\
*The name of the Announcer role*\
\
**ttt_announcer_name_plural** (Default Announcers)\
*The name of multiple Announcer roles*\
\
**ttt_announcer_name_article** (Default a)\
*The indefinite article of the Announcer's name (a/an)*

## You must enable the role for it to spawn!
If hosting a game from the main menu, put **ttt_announcer_enabled 1** in your listenserver.cfg.\
(Normally at: C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod\cfg)\
\
If hosting a game from a dedicated server, put **ttt_announcer_enabled 1** in your server.cfg.

## Credits
Credit goes to [Malivil](https://github.com/Malivil) for the original functionality of getting the names of weapons in his version of the randomat mod.
And of course a huge thank you to [Noxx](https://github.com/NoxxFlame) and [Malivil](https://github.com/Malivil) for making Custom Roles itself, and external roles possible!

## Steam Workshop Link
https://steamcommunity.com/sharedfiles/filedetails/?id=2813656943
