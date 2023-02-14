package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class EpicSelectorWOOO extends MusicBeatState
//just a copy of MainMenuState of 0.6.2 lmao
//also from a build to get hired on pibby corrupted :skull:
{
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var theThing:Array<String> = [
		'main',
		'extras',
	//	#if MODS_ALLOWED 'mods', #end
	//	#if ACHIEVEMENTS_ALLOWED 'awards', #end
	//	"don't_cross_secret",
	//	#if !switch 'donate', #end
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	//super useless
	var char:FlxSprite; 
	var char2:FlxSprite;

	override function create()
	{

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In Freeplay", "Category Menu", null, 'icon');
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (theThing.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(theThing.length > 6) {
			scale = 6 / theThing.length;
		}*/

		for (i in 0...theThing.length)
		{
			var offset:Float = 108 - (Math.max(theThing.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(590, (i * 140)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + theThing[i]);
			menuItem.animation.addByPrefix('idle', theThing[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', theThing[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (theThing.length - 4) * 0.130;
			if(theThing.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

	//	FlxG.camera.follow(camFollowPos, null, 1);

		/*var versionShit:FlxText = new FlxText(12, FlxG.height - 73, 0, "Pibby Corrupted v" + bitch, 20);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit); //i told u
		var versionShit:FlxText = new FlxText(12, FlxG.height - 54, 0, "Chosse...", 20);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);*/

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		super.create();

		/*switch(FlxG.random.int(1, 2)) the thing + test
		{
			case 1:
			char = new FlxSprite(110, 180).loadGraphic(Paths.image('characters/BOYFRIEND', 'shared'));//put your cords and image here
            char.frames = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared');//here put the name of the xml
            char.animation.addByPrefix('idle', 'BF idle dance', 24, true);//on 'idle normal' change it to your xml one
            char.animation.play('idle');//you can rename the anim however you want to
            char.scrollFactor.set();
            //FlxG.sound.play(Paths.sound('appear'), 2);
            char.flipX = true;//this is for flipping it to look left instead of right you can make it however you want
            char.antialiasing = ClientPrefs.globalAntialiasing;
            add(char);

			case 2:
				char2 = new FlxSprite(110, 210).loadGraphic(Paths.image('characters/senpai', 'shared'));//put your cords and image here
				char2.frames = Paths.getSparrowAtlas('characters/senpai', 'shared');//here put the name of the xml
				char2.animation.addByPrefix('idle', 'Senpai Idle instance ', 24, true);//on 'idle normal' change it to your xml one
				char2.animation.play('idle');//you can rename the anim however you want to
				char2.scrollFactor.set();
				//FlxG.sound.play(Paths.sound('appear'), 2);
				char2.flipX = true;//this is for flipping it to look left instead of right you can make it however you want
				char2.antialiasing = ClientPrefs.globalAntialiasing;
				add(char2);
	}*/
}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));
					MusicBeatState.switchState(new MainMenuState());
				}

			if (controls.ACCEPT)
			{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = theThing[curSelected];

								switch (daChoice)
								{
									case 'main':
										MusicBeatState.switchState(new EpisodesState());
									case 'extras':
										MusicBeatState.switchState(new ExtrasState());
								}
							});
						}
					});
				}
			}
			/*#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end*/
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			//spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
