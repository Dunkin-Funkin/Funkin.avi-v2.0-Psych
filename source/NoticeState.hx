package;

import GameJolt.GameJoltAPI;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flash.system.System;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import Shaders;

class NoticeState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var bloomShit:WIBloomEffect;
	var chrom:ChromaticAberrationEffect;
	var blurThisShit:TiltshiftEffect;
	var greyscale:GreyscaleEffect;

	var shaders:Array<ShaderEffect> = [];

	var warnText:FlxText;
	override function create()
	{
		super.create();

		GameJoltAPI.connect();
        GameJoltAPI.authDaUser(FlxG.save.data.gjUser, FlxG.save.data.gjToken);

		if(ClientPrefs.funiShaders)
					{
						chrom = new ChromaticAberrationEffect();
						blurThisShit = new TiltshiftEffect(0.4, 0);
						bloomShit = new WIBloomEffect(0);
						greyscale = new GreyscaleEffect();
						//uncomment these fucking pieces of shit if you feel like testing it.

						addShader(chrom);
						addShader(blurThisShit);
						addShader(bloomShit);
						addShader(greyscale);
						//uncomment these fucking pieces of shit if you feel like testing it.

						if (chrom != null)
						chrom.setChrome(0.003);

						if (bloomShit != null)
						bloomShit.setSize(18.0);

						if(blurThisShit != null)
						blurThisShit.setBlur(0.4);
						//uncomment these fucking pieces of shit if you feel like testing it.


					}
	
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		if(ClientPrefs.language == "English") {
		warnText = new FlxText(0, 0, FlxG.width,
			"NOTICE:\n
			This Mod contains some higher end graphics,\n
			thus causing lag or crashing your PC.\n
			Press ENTER to keep Shaders on.\n
			Press ESCAPE to Disable them.\n
			Thank you for playing!",
			32);
		} else if(ClientPrefs.language == "Spanish") {
		warnText = new FlxText(0, 0, FlxG.width,
			"AVISO:\n
			Este Mod contiene algunos gráficos de gama alta,\n
			causando así retrasos o fallas en su PC.\n
			Presiona ENTER para mantener Shaders activados.\n
			Presiona ESCAPE para deshabilitarlos.\n
			¡Gracias por jugar!",
			32);
		}
			
		warnText.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);

		var scratchStuff:FlxSprite = new FlxSprite();
		scratchStuff.frames = Paths.getSparrowAtlas('funkinAVI-filters/scratchShit');
		scratchStuff.animation.addByPrefix('idle', 'scratch thing 1', 24, true);
		scratchStuff.animation.play('idle');
		scratchStuff.screenCenter();
		scratchStuff.scale.x = 1.1;
		scratchStuff.scale.y = 1.1;
		add(scratchStuff);

		var grain:FlxSprite = new FlxSprite();
		grain.frames = Paths.getSparrowAtlas('funkinAVI-filters/Grainshit');
		grain.animation.addByPrefix('idle', 'grains 1', 24, true);
		grain.animation.play('idle');
		grain.screenCenter();
		grain.scale.x = 1.1;
		grain.scale.y = 1.1;
		add(grain);
	}

	function addShader(effect:ShaderEffect)
	{
		if (!ClientPrefs.funiShaders)
			return;

		shaders.push(effect);

		var newCamEffects:Array<BitmapFilter> = [];

		for (i in shaders)
		{
			newCamEffects.push(new ShaderFilter(i.shader));
		}

		FlxG.camera.setFilters(newCamEffects);
	}

	override function update(elapsed:Float)
	{
			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back) {
				FlxTransitionableState.skipNextTransIn = true;
				if(!back) {
					ClientPrefs.funiShaders = true;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('funkinAVI/menu/select_sfx'));
					FlxTween.tween(warnText, {alpha: 0}, 1, {
						onComplete: function (twn:FlxTween) {
									MusicBeatState.switchState(new MainMenuState());
							}
					});
				} else {
					ClientPrefs.funiShaders = false;
					FlxG.sound.play(Paths.sound('funkinAVI/menu/select_sfx'));
					FlxTween.tween(warnText, {alpha: 0}, 1, {
						onComplete: function (twn:FlxTween) {
                            MusicBeatState.switchState(new MainMenuState());
						}
					});
				}
			}
		super.update(elapsed);
	}
}
