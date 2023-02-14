package options.spanish;

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

class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Configuracion De GamePlay';
		rpcTitle = 'Gameplay Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Control De Consola',
			'Activalo Is Quieres Jugar Con Control De XBox/PS4',
			'controllerMode',
			'bool',
			false);
		addOption(option);

		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Downscroll', //Name
			'El Scroll Ira De Arriba A Abajo', //Description
			'downScroll', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Middlescroll',
			'El Scroll Ira Al Centro',
			'middleScroll',
			'bool',
			false);
		addOption(option);

		/*var option:Option = new Option(
			'Mecanicas',
			'Desactivalo Si No Tienes Habilidad Con Las Mecanicas!',
			'mechanics',
			'bool',
			true);
		addOption(option);*/
		
		var option:Option = new Option('Difficultad De Vida:',
			"Cual Debe Ser la Dificultad De Vida De Malfunction", 
			'lives', 
			'string', 
			'normal',
			['easy', 'normal', 'hard']);
		addOption(option);
		
		var option:Option = new Option('Ocultar contador de rating',
			'Activalo Para Ocultar El texto a la derecha',
			'hideJudgement',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Anti-perdida',
			"Activalo Para No Tener Perdidas Al Tocar Notas",
			'ghostTapping',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Desactivar Boton De Reiniciar',
			"Si Lo Activas, Presionar R No Afecta nada",
			'noReset',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Marvelous',
		'Solo Añade "Maravelous"',
		'marvelouses',
		'bool',
		true); //Default value
		addOption(option);

		var option:Option = new Option('Rating Offset',
			'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.',
			'ratingOffset',
			'int',
			0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Marvelous Hit Window',
			'Changes the amount of time you have\nfor hitting a "Marvelous" in milliseconds.\n(Must have "Marvelouses Rating" on for this to work)',
			'marvelousWindow',
			'int',
			25);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15;
		option.maxValue = 25;
		addOption(option);

		var option:Option = new Option('Sick! Hit Window',
			'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.',
			'sickWindow',
			'int',
			45);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15;
		option.maxValue = 45;
		addOption(option);

		var option:Option = new Option('Good Hit Window',
			'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.',
			'goodWindow',
			'int',
			90);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 15;
		option.maxValue = 90;
		addOption(option);

		var option:Option = new Option('Bad Hit Window',
			'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.',
			'badWindow',
			'int',
			135);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15;
		option.maxValue = 135;
		addOption(option);

		var option:Option = new Option('Salvar Frames',
			'Changes how many frames you have for\nhitting a note earlier or late.',
			'safeFrames',
			'float',
			10);
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);

		super();
	}
}
