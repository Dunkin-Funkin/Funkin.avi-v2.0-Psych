// i'mma have the songs separate in 2 different menus from here
package;

#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;
//just a copy from FreeplayState lol

class FreeplayCategoryState extends MusicBeatState
{
        var episodies:FlxSprite;
        var extras:FlxSprite;
        var selectorBox:FlxSprite;
  
        var bg:FlxSprite;
	      public var camZooming:Bool = false;
  
        override function create()
      	{
                Paths.clearStoredMemory();
		            Paths.clearUnusedMemory();
		
		            persistentUpdate = true;

		    #if desktop
	            // Updating Discord Rich Presence
	            DiscordClient.changePresence("In Freeplay Category", null);
	            #end
                  
                bg = new FlxSprite().loadGraphic(Paths.image('menuFreeplayCate'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
                bg.color = 0xFF424d54;
		add(bg);
		bg.screenCenter();
          
                extras = new FlxSprite().loadGraphic(Paths.image('this_shit/awsome'));
                extras.antialiasing = ClientPrefs.globalAntialiasing;
                add(extras);
          	
		episodies = new FlxSprite().loadGraphic(Paths.image('this_shit/for-test'));
                episodies.antialiasing = ClientPrefs.globalAntialiasing;
                add(episodies);
		
                selectorBox = new FlxSprite().loadGraphic(Paths.image('daSelecta'));
                selectorBox.antialiasing = ClientPrefs.globalAntialiasing;
          
                super.create();
        }
}
//We workin' on this, clearly not finished lmao
//well idk ngl