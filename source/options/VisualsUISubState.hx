package options;

import GameplayChangersSubstate.GameplayOption;
#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;
import IndieCrossShaderShit.FXHandler;

using StringTools;

class VisualsUISubState extends BaseOptionsMenu
{

	public function new()
	{
		title = 'Visuals and UI';
		rpcTitle = 'Visuals & UI Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Language',
		"What Language The Game Should Run?",
		'language',
		'string',
		'English',
		['English', 'Spanish']);
		addOption(option);

		var option:Option = new Option('Cutscenes',
			"If checked, cutscenes will show (this will affect Freeplay too).",
			'cutscenes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Cursor Style:', 
		'What Texture Should The Cursor Be?', 
		'cursor', 
		'string', 
		'Default', 
		['Default', 'Hand', 'Mickey', 'Silhouette', 'The Eye']);
		addOption(option);
		option.onChange = onChangeCursorSkin;

		var option:Option = new Option('Note Splashes',
			"If unchecked, hitting \"Sick!\" notes won't show particles.",
			'noteSplashes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('HUD Style:',
			"What HUD would you like to play with?",
			'hudSelection',
			'string',
			'Psych',
			['Psych', 'Vanilla', 'Demolition']); //HUDs to add: Demolition HUD, Funkin.avi HUD, Red-Bun's HUD.
			addOption(option);
		
		var option:Option = new Option('Winning Icons',
			'If checked, enables extra icon frames',
			'winningIcon',
			'bool',
			true);

		var option:Option = new Option('Hide HUD',
			'If checked, hides most HUD elements.',
			'hideHud',
			'bool',
			false);
		addOption(option);
		
		/*var option:Option = new Option('Time Bar:',
			"What should the Time Bar display?",
			'timeBarType',
			'string',
			'Time Left',
			['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
		addOption(option);*/

		var option:Option = new Option('Color Blind Filther:',
			"What should the Color Blind Filther display?",
			'colorblind',
			'string',
			'No color filter',
			['No color filter', 'Protanopia filter', 'Protanomaly filter', 'Deuteranopia filter', 'Deuteranomaly filter', 'Tritanopia filter', 'Tritanomaly filter', 'Achromatopsia filter', 'Achromatomaly filter']);
		addOption(option);
		option.onChange = onChangeCBFilther;
		
		var option:Option = new Option('Icon Bounce:',
			'How should your icons bounce?',
			'iconBounce',
			'string',
			'Default',
			['Default', 'Golden Apple', 'None']);
		addOption(option);

		var option:Option = new Option('Judgement Skin:', 
		"What should your judgements look like?", 
		'uiSkin', 
		'string', 
		'Demolition',
			['Demolition', 'Classic', 'BEAT!', 'BEAT! Gradient', 'Bedrock', 'Matt :)', 'Funkin.avi']);
		addOption(option);
		
		var option:Option = new Option('Simplify Score Text',
			"If checked, Score Text under the Health Bar \ndisplays less text",
			'simplifiedScore',
			'bool',
		        false);
		addOption(option);

		var option:Option = new Option('Camera Movement',
			"If checked, camera moves to the corresponding arrow!",
			'camMove',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Screen Shake',
			"Uncheck this if you're sensitive to screen shake!",
			'screenShake',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Show Watermarks',
			"If unchecked, hides engine watermarks from the bottom left corner.", 
			'showWatermarks', 
			'bool', 
			true);
		addOption(option);

		var option:Option = new Option('Camera Zooms',
			"If unchecked, the camera won't zoom in on a beat hit.",
			'camZooms',
			'bool',
			true);
		addOption(option);
		
		/*var option:Option = new Option('Center Menu',
			"If unchecked, the Menu will be on the left, idk.",
			'center',
			'bool',
			true);
		addOption(option);*/

		var option:Option = new Option('Score Text Zoom on Hit',
			"If unchecked, disables the Score text zooming\neverytime you hit a note.",
			'scoreZoom',
			'bool',
			true);
		addOption(option);
		
		/*var option:Option = new Option('Long Health Bar',
			"If unchecked, the health bar will be short.",
			'longBar',
			'bool',
			true);
		addOption(option);*/
		//NO MORE LONG HEALTH BAR TOGGLE, THANK FUCKING GOD.

		var option:Option = new Option('Health Bar Transparency',
			'How much transparent should the health bar and icons be.',
			'healthBarAlpha',
			'percent',
			1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		
		#if !mobile
		var option:Option = new Option('FPS Counter',
			'If unchecked, hides FPS Counter.',
			'showFPS',
			'bool',
			true);
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end
		
		var option:Option = new Option('Pause Screen Song:',
			"What song do you prefer for the Pause Screen?",
			'pauseMusic',
			'string',
			'Tea Time',
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;

		super();
	}

	var changedCursor:Bool = false;
	function onChangeCursorSkin()
	{
		FlxG.mouse.load("assets/images/mouse/" + ClientPrefs.cursor + ".png");

		changedCursor = true;
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)));

		changedMusic = true;
	}

	var changedCB:Bool = false;
	function onChangeCBFilther()
	{
		if(ClientPrefs.colorblind == 'No color filter')
			FlxG.sound.music.volume = 0;
		else
			FXHandler.UpdateColors();
	
		changedCB = true;
	}

	override function destroy()
	{
		if(changedMusic) FlxG.sound.playMusic(Paths.music('funkinAVI/menu/MenuMusic'));
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
	#end
}
