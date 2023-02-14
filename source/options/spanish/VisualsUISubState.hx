package options.spanish;

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

using StringTools;

class VisualsUISubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Visuales E UI';
		rpcTitle = 'Visuals & UI Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Lenguage:',
		"En Que lenguage El Juego Debe Correr?",
		'language',
		'string',
		'English',
		['English', 'Spanish']);
		addOption(option);

		var option:Option = new Option('Cinematicas',
			"Activalo Para Ver Cinematicas (Afecta Freeplay).",
			'cutscenes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Splash De Notas',
			"Si Se Desactivarla, No Se Mostrara Un Splash Al Hacer Un 'Sick'",
			'noteSplashes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Ocultar HUD',
			'Se Ocultaran Elementos Del HUD.',
			'hideHud',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('Barra De Tiempo',
			"Como Debe Ser La barra de tiempo?",
			'timeBarType',
			'string',
			'Time Left',
			['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
		addOption(option);
		
		var option:Option = new Option('Tipo De Icono',
			'Como Debe Ser El Tipo De Icono',
			'iconBounce',
			'string',
			'Default',
			['Default', 'Golden Apple', 'None']);
		addOption(option);

		var option:Option = new Option('Skin Del Judgement:', 
		"Como Debe Ser La TExtura Del Judgement", 
		'uiSkin', 
		'string', 
		'Demolition',
		['Demolition', 'Classic', 'BEAT!', 'BEAT! Gradient', 'Bedrock', 'Matt :)', 'Funkin.avi']);
		addOption(option);
		
		var option:Option = new Option('barra De Puntuacion Simple',
			"El Titulo Dice Todo",
			'simplifiedScore',
			'bool',
		        false);
		addOption(option);

		var option:Option = new Option('Movimiento De Camara',
			"La camara Se Movera Dependiendo la Pocision De Nota",
			'camMove',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Temblor De Camara',
		"Desactivalo Si eres sensivo al temblor de camara!",
		'screenShake',
		'bool',
		true);
	addOption(option); //haha imagine dont doing this with the rest of options

		var option:Option = new Option('Flash',
			"Desactivalo Si Eres Sensible Al Flash!",
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Mostrar marca de agua',
			"Habra Un Boton De marca de agua abajo.", 
			'showWatermarks', 
			'bool', 
			true);
		addOption(option);

		var option:Option = new Option('Zoom De camara',
			"La camara hara un zoom cada beat.",
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

		var option:Option = new Option('Zoom Al texto de Puntuacion',
			"Habra Zoom Con La barra de puntuacion Al Hacer Un Beat",
			'scoreZoom',
			'bool',
			true);
		addOption(option);
		
		#if !mobile
		var option:Option = new Option('Contador De FPS',
			'Desactivalo Para Ocultar El Contador De FPS',
			'showFPS',
			'bool',
			true);
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end
		
		var option:Option = new Option('Cancion del menu de pausa:',
			"Que cancion habra cuando estes en pausa?",
			'pauseMusic',
			'string',
			'Tea Time',
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;

		super();
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
