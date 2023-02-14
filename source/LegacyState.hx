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
import flixel.tweens.FlxTween;
import flash.system.System;
import flixel.text.FlxText;
import flixel.FlxCamera;
import lime.app.Application;
import flixel.util.FlxColor;
import flash.system.System;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import Shaders;

using StringTools;

class LegacyState extends MusicBeatState{

	var bloomShit:WIBloomEffect;
	var chrom:ChromaticAberrationEffect;
	var blurThisShit:TiltshiftEffect;
	var greyscale:GreyscaleEffect;
	var distort:WIDistortionEffect;

	var shaders:Array<ShaderEffect> = [];

	var songs:Array<SongMetadataLegacy> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;
	var leChars:Array<String> = [];

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	override function create()
	{
		FPClientPrefs.loadShit();

        addSong('Isolated Legacy', 3, 'legacy', FlxColor.fromRGB(60, 60, 60));
        addSong('Lunacy Legacy', 3, 'legacy', FlxColor.fromRGB(60, 60, 60));
        addSong('Malfunction Legacy', 3, 'square-legacy-pixel', FlxColor.fromRGB(60, 60, 60));
        addSong('Mercy Legacy', 3, 'walt', FlxColor.fromRGB(153, 148, 112));

        /*if(FPClientPrefs.episode1FPLock == 'unlocked')
        {
			if(FPClientPrefs.huntedLock != 'beaten' && FPClientPrefs.huntedLock != 'unlocked') addSong('Hunted', 3, 'mysterymouse', FlxColor.fromRGB(0, 60, 40), FlxG.save.data.huntedLock); else addSong('Hunted', 3, 'goofy', FlxColor.fromRGB(0, 60, 40), FlxG.save.data.huntedLock);
            if(FPClientPrefs.oldisolateLock != 'beaten' && FPClientPrefs.oldisolateLock != 'unlocked') addSong('Isolated Old', 3, 'mysterymouse', FlxColor.fromRGB(60, 60, 60), FlxG.save.data.oldisolateLock); else addSong('Isolated Old', 3, 'legacy', FlxColor.fromRGB(60, 60, 60), FlxG.save.data.oldisolateLock);
			if(FPClientPrefs.betaisolateLock != 'beaten' && FPClientPrefs.betaisolateLock != 'unlocked') addSong('Isolated Beta', 3, 'mysterymouse', FlxColor.fromRGB(60, 60, 60), FlxG.save.data.betaisolateLock); else addSong('Isolated Beta', 3, 'legacy', FlxColor.fromRGB(60, 60, 60), FlxG.save.data.betaisolateLock);
			if(FPClientPrefs.crossinLock != 'beaten' && FPClientPrefs.crossinLock != 'unlocked') addSong("Don't Cross!", 3, 'mysterymouse', FlxColor.RED, FlxG.save.data.crossinLock); else addSong("Don't Cross!", 3, 'ohgod', FlxColor.RED, FlxG.save.data.crossinLock);
            if(FPClientPrefs.malfunctionLock != 'beaten' && FPClientPrefs.malfunctionLock != 'unlocked') addSong('Malfunction', 3, 'mysterymouse', FlxColor.fromRGB(140, 120, 180), FlxG.save.data.malfunctionLock); else addSong('Malfunction', 3, 'square-pixel', FlxColor.fromRGB(140, 120, 180), FlxG.save.data.malfunctionLock);
           // addSong('Revenge', 3, 'face', FlxColor.WHITE, FlxG.save.data.revengeLock);
        }

        if(FPClientPrefs.episode2FPLock == 'unlocked')
        {
            if(FPClientPrefs.sinsLock != 'beaten' && FPClientPrefs.sinsLock != 'unlocked') addSong('Cycled Sins', 3, 'mysterymouse', FlxColor.fromRGB(115, 86, 86), FlxG.save.data.sinsLock); else addSong('Cycled Sins', 3, 'relapse-pixel', FlxColor.fromRGB(115, 86, 86), FlxG.save.data.sinsLock);
            if(FPClientPrefs.warLock != 'beaten' && FPClientPrefs.warLock != 'unlocked') addSong('War Dilemma', 3, 'mysterymouse', FlxColor.fromRGB(105, 17, 10), FlxG.save.data.warLock); else addSong('War Dilemma', 3, 'warmick', FlxColor.fromRGB(105, 17, 10), FlxG.save.data.warLock);
			if(FPClientPrefs.scrappedLock != 'beaten' && FPClientPrefs.scrappedLock != 'unlocked') addSong('Scrapped', 3, 'mysterymouse', FlxColor.BLACK, FlxG.save.data.scrappedLock); else addSong('Scrapped', 3, 'rs', FlxColor.BLACK, FlxG.save.data.scrappedLock);
			if(FPClientPrefs.pnmLock != 'beaten' && FPClientPrefs.pnmLock != 'unlocked') addSong('Neglection', 3, 'mysterymouse', FlxColor.CYAN, FlxG.save.data.pnmLock); else addSong('Neglection', 3, 'pnm', FlxColor.CYAN, FlxG.save.data.pnmLock);
            if(FPClientPrefs.blessLock != 'beaten' && FPClientPrefs.blessLock != 'unlocked') addSong('Bless', 3, 'mysterymouse', FlxColor.WHITE, FlxG.save.data.blessLock); else addSong('Bless', 3, 'whitenew', FlxColor.WHITE, FlxG.save.data.blessLock);
            if(FPClientPrefs.mercyLock != 'beaten' && FPClientPrefs.mercyLock != 'unlocked') addSong('Mercy', 3, 'mysterymouse', FlxColor.fromRGB(153, 148, 112), FlxG.save.data.mercyLock); else addSong('Mercy', 3, 'walt', FlxColor.fromRGB(153, 148, 112), FlxG.save.data.mercyLock);
        }*/

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In Freeplay", "Legacy Songs", null, 'icon');
		#end

		Application.current.window.title = "Funkin.avi - Freeplay: Legacy Songs";

		/*		//KIND OF BROKEN NOW AND ALSO PRETTY USELESS//
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}*/

		bg = new FlxSprite().loadGraphic(Paths.image('menuFreeplay'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItemCenter = true;
			songText.targetY = i;
			grpSongs.add(songText);

			if (songText.width > 980)
			{
				var textScale:Float = 980 / songText.width;
				songText.scale.x = textScale;
				for (letter in songText.lettersArray)
				{
					letter.x *= textScale;
					letter.offset.x *= textScale;
				}
				//songText.updateHitbox();
				//trace(songs[i].songName + ' new scale: ' + textScale);
			}

			Paths.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeSelection();
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/*
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));
			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;
			FlxG.stage.addChild(texFel);
			// scoreText.textField.htmlText = md;
			trace(md);
		 */

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		if(ClientPrefs.language == "Spanish") {
			var leText:String = "Presiona CTRL Para Modifical El GamePlay / Presiona R Para Reiniciar El Progreso De La Cancion.";
			var size:Int = 18;
			var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
			text.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), size, FlxColor.WHITE, RIGHT);
			text.scrollFactor.set();
			add(text);
			} else {
			var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
			var size:Int = 18;
			var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
			text.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), size, FlxColor.WHITE, RIGHT);
			text.scrollFactor.set();
			add(text);
			}

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

	function clearShader()
		{
			shaders = [];
			var newCamEffects:Array<BitmapFilter> = [];
			FlxG.camera.setFilters(newCamEffects);
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

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadataLegacy(songName, weekNum, songCharacter, color));
	}

	
	override function beatHit()
		{
			super.beatHit();
			if (curBeat % 1 == 0 && ClientPrefs.camZooms)
				FlxG.camera.zoom = 1.015;
		}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>, weekColor:Int, difficulties:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num], weekColor);
			this.songs[this.songs.length-1].color = weekColor;

			if (songCharacters.length != 1)
				num++;
		}
	}

	var instPlaying:Int = -1;
	private static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(songs.length > 1)
		{
			if (upP)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (downP)
			{
				changeSelection(shiftMult);
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
					changeDiff();
				}
			}
		}

		if (FlxG.mouse.wheel != 0)
			{
				if (FlxG.mouse.wheel > 0)
				{
					changeSelection(-1);
				}
				else
				{
					changeSelection(1);
				}
			}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);
		else if (upP || downP) changeDiff();

		if (controls.BACK)
		{
			persistentUpdate = false;
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new EpicSelectorWOOO());
		}

		if(ctrl)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
			if(instPlaying != curSelected && ClientPrefs.instPlaying)
			{
				#if (PRELOAD_ALL && desktop)
				destroyFreeplayVocals();
				EpisodesState.destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				Paths.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());

				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				instPlaying = curSelected;
				/*switch(PlayState.SONG.song)
				{
					case 'Laugh Track':
					Application.current.window.title = "Funkin.avi - Listening to: " + PlayState.SONG.song + " - Composed by: Yama haki & obscurity.";
					case 'Isolated Old' | "Don't Cross!":
					Application.current.window.title = "Funkin.avi - Listening to: " + PlayState.SONG.song + " - Composed by: Yama haki";
					case 'Malfunction' | 'Mercy':
					Application.current.window.title = "Funkin.avi - Listening to: " + PlayState.SONG.song + " - Composed by: obscurity.";
					case 'Twisted Grins':
					Application.current.window.title = "Funkin.avi - Listening to: " + PlayState.SONG.song + " - Composed by: Sayan Sama";
					case 'Hunted':
					Application.current.window.title = "Funkin.avi - Listening to: " + PlayState.SONG.song + " - Composed by: JBlitz";
					default:
					Application.current.window.title = "Funkin.avi - Listening to: " + PlayState.SONG.song;
				}*/
				Application.current.window.title = "Funkin.avi - Listening to: " + PlayState.SONG.song + " - Composed by: " + PlayState.SONG.composer;
				#end
			}
		else if (accepted || FlxG.mouse.justPressed)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			/*#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}*/
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
			}
			
			if (FlxG.keys.pressed.SHIFT){
				Application.current.window.alert('No Cheating ofc (this should be a cheating cover btw)');
				System.exit(0);
			}else{
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.mouse.visible = false;
			}

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
			EpisodesState.destroyFreeplayVocals();
		}
		else if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scroll_sfx'));
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
			diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
			diffText.color = FlxColor.WHITE;
		positionHighscore();
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('funkinAVI/menu/scroll_sfx'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
			
		var newColor:Int = songs[curSelected].color;
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

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		
		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}

			/*FlxG.camera.flash(FlxColor.BLACK, 0.2);
			if(ClientPrefs.shaders)
			{
			clearShader();
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
			FlxG.camera.shake(0.004, 0);*/
			}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}
}

class SongMetadataLegacy
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var difficulties:Array<String> = [""];

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}