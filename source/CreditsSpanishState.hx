//This is mostly a placeholder, because i have planned remade it enterily soon

package;

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
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;

using StringTools;

class CreditsSpanishState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var noLink:Bool;
	var descBox:AttachedSprite;

	var offsetThing:Float = -75;
	public var camZooming:Bool = false;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Checkando Creditor", null, null, 'icon');
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();
		
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		#if MODS_ALLOWED
		var path:String = 'modsList.txt';
		if(FileSystem.exists(path))
		{
			var leMods:Array<String> = CoolUtil.coolTextFile(path);
			for (i in 0...leMods.length)
			{
				if(leMods.length > 1 && leMods[0].length > 0) {
					var modSplit:Array<String> = leMods[i].split('|');
					if(!Paths.ignoreModFolders.contains(modSplit[0].toLowerCase()) && !modsAdded.contains(modSplit[0]))
					{
						if(modSplit[1] == '1')
							pushModCreditsToList(modSplit[0]);
						else
							modsAdded.push(modSplit[0]);
					}
				}
			}
		}

		var arrayOfFolders:Array<String> = Paths.getModDirectories();
		arrayOfFolders.push('');
		for (folder in arrayOfFolders)
		{
			pushModCreditsToList(folder);
		}
		#end

		var pisspoop:Array<Array<String>> = [ //Name - Icon name - Description - Link - BG Color
			//use this as a template:
			//['',	'',	'',	'',	''],
            //TOP 5 how to die
['Equipo de Funkin.avi'],
['Gracias especiales'],
['Yama haki', 'yama', "Tú eres la razón por la que este mod es popular ahora,\ngracias.", 'https://www.youtube.com/channel/UCm2eFBC_lMxkRO8JF17ArFg', 'FFFFFF'],
[''],
['Directores'],
['DEMOLITIONDON96', 'demolitiondon96', 'Director de Funkin.avi', 'https://youtube.com/c/DEMOLITIONDON96', 'FFFFFF'],
['Nutsack', 'nutsack', 'Segundo director', 'https://twitter.com/Nutblocked', 'FFFFFF'],
['GavinTheCartoonist', 'icono perdido', 'Codirector de Funkin.avi', 'https://twitter.com/AnimationFelix', 'FFFFFF'],
            ['HazeyPurple', 'haze', 'Segundo codirector', 'https://twitter.com/HazeyPurple_x', 'FFFFFF'],
[''],
['Artistas'],
['Mr.IDK', 'idk', 'Artista de iconos y sprites', 'https://twitter.com/Mr_IDKK?t=iYM1mlQcv4_UVmxtW2kvig&s=09', 'FFFFFF'],
['AustinTheRedDragon', 'austin', 'Creador de Mr. Smiles y artista conceptual', 'https://twitter.com/Austinthereddr3?t=ZQVsYKPA_aseqQ5EBImdWQ&s=09', 'FFFFFF'],
['GavinTheCartoonist', 'icono perdido', 'Artista', 'https://twitter.com/AnimationFelix', 'FFFFFF'],
['HazeyPurple', 'haze', 'Artista', 'https://twitter.com/HazeyPurple_x', 'FFFFFF'],
['DEMOLITIONDON96', 'demolitiondon96', 'Artista conceptual', 'https://youtube.com/c/DEMOLITIONDON96', 'FFFFFF'],
['Awe', 'icono perdido', 'Artista conceptual', 'https://twitter.com/awesitoelpapu', 'FFFFFF'],
['JaoXD', 'jao', 'Artista de los Ícono', 'https://twitter.com/JaoXDDD?t=M5UEMC9nLAVOyOejPfbDJw&s=09', 'FFFFFF'],
['Xarion', 'xarion', 'Su trabajo es épico, no es broma', 'https://twitter.com/Xar1on', 'FFFFFF'],
['HassenX', 'icono perdido', 'Un animador genial', 'nolink', 'FFFFFF'],
['Tycho', 'tycho', 'Ilustraciones de Cycled Sins', 'https://twitter.com/TychoFNFastral?t=nNkNFz_kCO4qMRMElrhVfA&s=09', 'FFFFFF'],
['SirSpookySkeleton', 'espeluznante', 'spoopy', 'https://twitter.com/SirSpookySkeltn?t=zdg7Urcfn5QhllZxADekpA&s=09', 'FFFFFF'],
['Jsa010', 'jsa010', "Arte conceptual", 'https://twitter.com/_Jsa010_', 'FFFFFF'],
['Z3r0', 'cero', 'Artista 3D épico', 'nolink', 'FFFFFF'],
['MalyPlus', 'maly', 'Pixel Arist', 'https://gamebanana.com/members/2014862', 'FFFFFF'],
['Genorelm_lmao', 'genore', 'Artista', 'https://twitter.com/Genorelm_', 'FFFFFF'],
['Nutsack', 'nutsack', 'Episode 1 Assets', 'https://twitter.com/Nutblocked', 'FFFFFF'],
['kyz', 'icono perdido', 'Artista', 'nolink', 'FFFFFF'],
['rezeo.rs', 'icono perdido', 'Artista', 'nolink', 'FFFFFF'],
['Cheez', 'cheez', 'Animador para algunos personajes', 'https://gamebanana.com/members/1784678', 'FFFFFF'],
['JDrive', 'drive', 'Pixel Artist Genial', 'https://twitter.com/JimmyDetector', 'FFFFFF'],
['BonoanAnything', 'bonoan', 'Animador de escenas\n(También hizo el tráiler)', 'https://www.youtube.com/channel/UCvSHOa48e2HJrRjwEjpx1Hw', 'FFFFFF'],
['COOLTE3YET', 'cool', 'Artista de miniaturas para las páginas de GJ y GB\n(Dales crédito)', 'https://gamebanana.com/members/2005084', 'FFFFFF'],
[''],
['Compositores'],
['FR3SHMoure', 'fresh', 'Compositor de Delusional', 'https://twitter.com/FR3SHAnimates?t=woj1MCTZ95ucJ33ngNSspA&s=09', 'FFFFFF'],
['Yama haki', 'yama', 'Hizo la mayoría de las canciones con la ayuda de otros', 'https://www.youtube.com/channel/UCm2eFBC_lMxkRO8JF17ArFg', 'FFFFFF'],
['oscuridad.', 'icono perdido', 'Compositor épico', 'https://twitter.com/MrObscuritylol', 'FFFFFF'],
['Sayan Sama', 'sama', 'Compositor de Las Canciones De Mr.Smiles', 'https://gamebanana.com/members/1825237', 'FFFFFF'],
['AzkoBlitz', 'azko', 'Compositor', 'https://twitter.com/Azko57478381', 'FFFFFF'],
['JBlitz', 'blitz', 'Compositor de Cycled Sins y El Menu', 'https://twitter.com/JBlitz_', 'FFFFFF'],
['HassenX', 'icono perdido', 'Componsitor', 'nolink', 'FFFFFF'],
['END_SELLA', 'Sella', 'Compositor', 'https://www.youtube.com/c/seibichu%E3%83%84/videos', 'FFFFFF'],
['JUSTIN X', 'justin', 'Creador de las cromaticas', 'https://twitter.com/CbmShow', 'FFFFFF'],
['AttackPan', 'icono perdido', 'Instrumentales para algunas canciones', 'nolink', 'FFFFFF'],
[''],
['Cartas'],
['DEMOLITIONDON96', 'demolitiondon96', 'Hice algunos charts', 'https://youtube.com/c/DEMOLITIONDON96', 'FFFFFF'],
['Yama haki', 'yama', 'charteo isolated old', 'https://www.youtube.com/channel/UCm2eFBC_lMxkRO8JF17ArFg', 'FFFFFF'],
['Dreupy', 'Dreupy', 'Charter para algunas de las canciones', 'nolink', 'FFFFFF'],
['Dest', 'dest', 'Charter', 'https://gamebanana.com/members/2095443', 'FFFFFF'],
['Noppz', 'missing-icon', 'Él hace charts bastante buenos', 'https://www.youtube.com/channel/UCuz26FymzG_4tluOooxT-xQ', 'FFFFFF'],
['PhantomNexus', 'nexus', 'charts menores', 'https://twitter.com/archerthewolf2', 'FFFFFF'],
['Zer0XD', 'icono perdido', 'charts divertidos', 'https://www.youtube.com/channel/UCq9VLHYIwoCU7hnr0TK9yuA', 'FFFFFF'],
['fakeburritos123', 'burrito', "Charted Don't Cross! \n(Don se aseguró de que fuera el mejor chart de la historia)", 'nolink', 'FFFFFF'],
[''],
['Actores de doblaje'],
['Flaconadir', 'flacon', 'Actor de doblaje', 'https://twitter.com/flaconadir', 'FFFFFF'],
['AustinTheRedDragon', 'austin', 'Actor de doblaje para algunas escenas', 'https://twitter.com/Austinthereddr3?t=ZQVsYKPA_aseqQ5EBImdWQ&s=09', 'FFFFFF'],
[''],
['Codificadores'],
['DEMOLITIONDON96', 'demolitiondon96', "Codificador principal de Funkin.avi", 'https://youtube.com/c/DEMOLITIONDON96', 'FFFFFF'],
['Jsa010', 'jsa010', "Codificador secundario de Funkin.avi", 'https://twitter.com/_Jsa010_', 'FFFFFF'],
['TonyTime!', 'matt', 'Se fue pero ha vuelto', 'https://github.com/TonyTimee', 'FFFFFF'],
['Goofgoof43', 'icono perdido', 'Tipo bastante genial, diría', 'nolink', 'FFFFFF'],
//['MalyPlus', 'maly', 'Programador más nuevo del equipo', 'https://gamebanana.com/members/2014862', 'FFFFFF'],
['A3ro', 'icono perdido', 'También un codificador nuevo', 'nolink', 'FFFFFF'],
[''],
['Traductores'],
['Jsa010', 'jsa010', "Traduci casi todo el mod", 'https://twitter.com/_Jsa010_', 'FFFFFF'],
['DEMOLITIONDON96', 'demolitiondon96', "Todas las advertencias traducidas", 'https://youtube.com/c/DEMOLITIONDON96', 'FFFFFF'],
[''],
['Antiguos miembros de Funkin avi'],
['pig69', 'missing-icon', 'Ex-artista de funkin.avi', 'nolink', 'FFFFFF'], //Estaba en los créditos de GB, nada más que hacer
[''],
            [''],
            ['Equipo del engine'],
            ['DEMOLITIONDON96', 'demolitiondon96', 'Creador del Engine', 'https://youtube.com/c/DEMOLITIONDON96', '03C6FC'],
            ['¡Tony Time!', 'matt', 'Codificador Epico \n(hizo muchas cosas geniales)', 'https://github.com/TonyTimee', '444444'],
            ['Cherif107', 'missing-icon', 'Programador genial\nBuen Tipo', 'https://github.com/Cherif107', 'FFFFFF'],
            ['PrismLight', 'prism', 'Código menor', 'https://github.com/PrismLight', '3B3B3B',],
            ['Theoyeah', 'theoyeah credit', 'Ayuda con algo de código', 'https://github.com/Theoyeah', 'FFFFFF'],	
            [''],
['Código adicional'],
['mayo78', 'missing-icon', 'Código de máscara de CPU épica', 'https://github.com/mayo78', 'FFFFFF'],
['Wither362', 'wither362', 'Compatibilidad con archivos .mp3 y .wav\n (y por permitirme agregar algo genial que hicieron)', 'https://www.youtube.com/channel/UCsVr- qBLxT0uSWH037BmlHw', '009BF4'],
['lemz1', 'lemz1', 'Código Modchart para la ventana del juego', 'https://github.com/lemz1', '383838'],
['Phoneguytech75', 'missing-icon', 'Aspectos de notas: D', 'https://github.com/Phoneguytech75', 'FFFFFF'],
['HiroMizuki', 'hiro', 'Salpicaduras de píxeles y \nCódigo de resolución de pantalla', 'https://github.com/HiroMizuki', '3DED02'],
['8bitjake', 'missing-icon', 'Retención de piezas arregladas para gráficos de desplazamiento lateral', 'https://github.com/ShadowMario/FNF-PsychEngine/pull/8676', 'FFFFFF'],
['magnumsrtisswag', 'mag', 'Editor de escena', 'https://github.com/magnumsrtisswag', '0B03FC'],
['AlexDrar', 'missing-icon', 'Mierda de canción de código duro', 'https://github.com/mayo78/PSYCHDISCUSSIONS/discussions/85', 'FFFFFF'],
['Muffins de Blancanieves', 'missing-icon', 'Moviendo código del menú principal', 'https://www.youtube.com/watch?v=QZQJ701tAqQ', 'FFFFFF'],
['TimothyFnf', 'missing-icon', 'Algo de crédito por el código', 'https://gamebanana.com/mods/370936', 'FFFFFF'],
['KutikiPlayz', 'missing-icon', 'Evento de tipo de desplazamiento', 'https://github.com/KutikiPlayz', 'FFFFFF'],
['Ash237', 'missing-icon', 'Código Divertido', 'https://github.com/alexlolxp/baldi-source/commit/8bc86a45de3fba962539cab1258ebd48daf324a0', 'FFFFFF'],
['Chimmie-mpeg', 'missing-icon', 'Cromáticos para omni lol', 'https://github.com/Chimmie-mpeg/FNF-FANMADE-CHROMATIC-SCALES/tree/main/Chromatics%202.0', 'FFFFFF'],
['NoahWantsDie', 'missing-icon', 'MIDI para omni (yo mismo quiero morir /j)', 'https://www.youtube.com/watch?v=2s5mDJrkFoc', 'FFFFFF'],
['SaadTheDrip', 'missing-icon', 'mierda del navegador abierto', 'https://github.com/mayo78/PSYCHDISCUSSIONS/discussions/611', 'FFFFFF'],
[''],
['Equipo de Psych Engine'],
['Shadow Mario', 'shadowmario', 'Programador principal de Psych Engine', 'https://twitter.com/Shadow_Mario_', '444444'],
['RiverOaken', 'river', 'Artista principal/Animadora de Psych Engine', 'https://twitter.com/RiverOaken', 'B42F71'],
['shubs', 'shubs', 'Programador adicional de Psych Engine', 'https://twitter.com/yoshubs', '5E99DF'],
[''],
['Antiguos miembros del engine'],
['bb-panzu', 'bb', 'Exprogramador de Psych Engine', 'https://twitter.com/bbsub3', '3E813A'],
[''],
['Contribuidores del engine'],
['iFlicky', 'flicky', 'Compositor de Psync y Tea Time\nHizo los sonidos del diálogo', 'https://twitter.com/flicky_i', '9E29CF'],
['SqirraRNG', 'sqirra', 'Crash Handler y código base para la forma de onda del editor de gráficos', 'https://twitter.com/gedehari', 'E1843A'],
['PolybiusProxy', 'proxy', 'Biblioteca del cargador de video .MP4 (hxCodec)', 'https://twitter.com/polybiusproxy', 'DCD294'],
/*KADEDEV!!!*/ ['KadeDev', 'kade', 'Se corrigieron algunas cosas geniales en Chart Editor\ny otras PRs', 'https://twitter.com/kade0912', '64A250'],
['Keoiki', 'keoiki', 'Animaciones de la chapoteada de notas', 'https://twitter.com/Keoiki_', 'D2D2D2'],
['Nebula the Zorua', 'nebula', 'LUA JIT Fork y algunas reelaboraciones de Lua', 'https://twitter.com/Nebula_Zorua', '7D40B2'],
['Smokey', 'smokey', 'Soporte de Sprite Atlas', 'https://twitter.com/Smokey_5_', '483D92'],
[''],
["Funkin Crew"],
['ninjamuffin99', 'ninjamuffin99', "Programador de Friday Night Funkin'", 'https://twitter.com/ninja_muffin99', 'CF2D2D'],
['PhantomArcade', 'phantomarcade', 'Animador de Friday Night Funkin', 'https://twitter.com/PhantomArcade3K', 'FADC45'],
['evilsk8r', 'evilsk8r', "Artista de Friday Night Funkin'", 'https://twitter.com/evilsk8r', '5ABD4B'],
['kawaisprite', 'kawaisprite', "Compositor de Friday Night Funkin'", 'https://twitter.com/kawaisprite', '378FC7']
			//[''],
			//["Slutty Crew"],
			//['Ben UWU',		'ben',	"Got Drip And Is So Slutty",						"https://www.youtube.com/watch?v=v5F5WyhzW9M",		'FFFFFF']
		];
		
		for(i in pisspoop){
			creditsStuff.push(i);
		}
	
		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			optionText.yAdd -= 70;
			if(isSelectable) {
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			//optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(isSelectable) {
				if(creditsStuff[i][5] != null)
				{
					Paths.currentModDirectory = creditsStuff[i][5];
				}

				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
				Paths.currentModDirectory = '';

				if(curSelected == -1) curSelected = i;
			}
		}
		
		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		//descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();

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
		
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if(!quitting)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP)
				{
					changeSelection(-1 * shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(1 * shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

				if(creditsStuff[curSelected][3] == 'nolink') {

  					noLink = true;
  				}else{
  					noLink = false;
  				}
  				if(noLink) {
  				if(controls.ACCEPT) {
  					FlxG.sound.play(Paths.sound('cancelMenu'));
  				} 
  				}else {
  					if(controls.ACCEPT) {
  					CoolUtil.browserLoad(creditsStuff[curSelected][3]);
  				}

			}

			if (controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
					MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}
			}
		
		for (item in grpOptions.members)
		{
			if(!item.isBold)
			{
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
				if(item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(lastX, item.x - 70, lerpVal);
					item.forceX = item.x;
				}
				else
				{
					item.x = FlxMath.lerp(item.x, 200 + -40 * Math.abs(item.targetY), lerpVal);
					item.forceX = item.x;
				}
			}
		}
		super.update(elapsed);
	}
	
		override function beatHit()
	{
		super.beatHit();
			if(ClientPrefs.camZooms) {
        FlxG.camera.zoom += 0.015;
		if(!camZooming) { //Copied from PlayState.hx
			FlxTween.tween(FlxG.camera, {zoom: 1}, 0.5);
		}
	}
	}
	
	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('funkinAVI/menu/scroll_sfx'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:Int =  getCurrentBGColor();
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}

		descText.text = creditsStuff[curSelected][2];
		descText.y = FlxG.height - descText.height + offsetThing - 60;

		if(moveTween != null) moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	#if MODS_ALLOWED
	private var modsAdded:Array<String> = [];
	function pushModCreditsToList(folder:String)
	{
		if(modsAdded.contains(folder)) return;

		var creditsFile:String = null;
		if(folder != null && folder.trim().length > 0) creditsFile = Paths.mods(folder + '/data/credits.txt');
		else creditsFile = Paths.mods('data/credits.txt');

		if (FileSystem.exists(creditsFile))
		{
			var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
			for(i in firstarray)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if(arr.length >= 5) arr.push(folder);
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);
		}
		modsAdded.push(folder);
	}
	#end

	function getCurrentBGColor() {
		var bgColor:String = creditsStuff[curSelected][4];
		if(!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
