package;

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

class DisclaimerState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var bloomShit:WIBloomEffect;
	var chrom:ChromaticAberrationEffect;
	var blurThisShit:TiltshiftEffect;
	var greyscale:GreyscaleEffect;

	var shaders:Array<ShaderEffect> = [];

	var blackFade:FlxSprite;
	var dumbBG:FlxSprite;
	var disclaimText:FlxText;
	var disclaimText2:FlxText;
	var disclaimText3:FlxText;
	override function create()
	{
		super.create();

		/*if(ClientPrefs.funiShaders)
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


					}*/

		dumbBG = new FlxSprite();
		dumbBG.loadGraphic(Paths.image('WARNING/Avi_Disclaimer'), false);
		dumbBG.screenCenter();
		dumbBG.scale.x = 0.68;
		dumbBG.scale.y = 0.67;
		add(dumbBG);

		var redFormat = new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED, true, true), '^');

		if(ClientPrefs.language == "English") {
		disclaimText = new FlxText(20, 40, FlxG.width,
			"DISCLAIMER:",
			64);
			
		disclaimText2 = new FlxText(15, 150, FlxG.width,
			"Mickey Mouse is a character owned by Disney!\n
			Flashing Lights are in this mod so Be careful.\n
			Press ENTER to continue further to the game.\n
			Press ESCAPE to disable flashes now.",
			20);
			
		disclaimText3 = new FlxText(15, 440, FlxG.width,
			"^LAST CHANCE...^",
			74);
		} else if(ClientPrefs.language == "Spanish") {
		disclaimText = new FlxText(20, 40, FlxG.width,
			"DESCARGO DE RESPONSABILIDAD:",
			40);
		
		disclaimText2 = new FlxText(15, 150, FlxG.width,
			"¡Mickey Mouse es un personaje propiedad de Disney!\n
			Las luces intermitentes están en este mod, así que ten cuidado.\n
			Presione ENTER para continuar con el juego.\n
			Presione ESCAPE para desactivar los flashes ahora.",
			20);
			
		disclaimText3 = new FlxText(15, 440, FlxG.width,
			"^ÚLTIMA OPORTUNIDAD...^",
			74);
		}	
		disclaimText.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 64, FlxColor.WHITE, LEFT);
		add(disclaimText);
		
		disclaimText2.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 32, FlxColor.WHITE, LEFT);
		add(disclaimText2);

		disclaimText3.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 74, FlxColor.WHITE, LEFT); //Buggy Mixed text
		disclaimText3.applyMarkup(disclaimText3.text, [redFormat]);
		add(disclaimText3);

		blackFade = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(blackFade);

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

		FlxTween.tween(blackFade, {alpha: 0}, 1);
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
		Application.current.window.title = "Funkin.avi - DISCLAIMER";
		
		if(!leftState) {
			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if(!back) {
					ClientPrefs.flashing = true;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('funkinAVI/menu/select_sfx'));
					FlxTween.tween(blackFade, {alpha: 1}, 1, {
						onComplete: function (twn:FlxTween) {
							if(ClientPrefs.language == "Spanish") {
							MusicBeatState.switchState(new SpanishTitleState());
						} else {
							MusicBeatState.switchState(new TitleState());
						}
					} 
					});
				} else {
					ClientPrefs.flashing = false;
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxTween.tween(blackFade, {alpha: 1}, 1, { 
						onComplete: function (twn:FlxTween) {
							if(ClientPrefs.language == "Spanish") {
								MusicBeatState.switchState(new SpanishTitleState());  
							} else {
								MusicBeatState.switchState(new TitleState());
							}
						}
					});
				}
			}
		}
		super.update(elapsed);
	}
}
