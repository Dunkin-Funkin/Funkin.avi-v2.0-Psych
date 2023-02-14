package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxStringUtil;
import flash.system.System;
import openfl.filters.ShaderFilter as Filters;
import PlayState;

class PauseSpanishState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = [
		'Continuar', 
		'Reiniciar', 
		'Opciones', 
		'Salir'
	];
	var difficultyChoices = [];
	var curSelected:Int = 0;
	var composer:String = '';
	var charter:String = '';

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:Alphabet;
	var curTime:Float = Math.max(0, Conductor.songPosition);
	//var botplayText:FlxText;

	public static var songName:String = '';

	public function new(x:Float, y:Float)
	{
		super();
		if(CoolUtil.difficulties.length < 2) menuItemsOG.remove('Cambiar Difficultad'); //No need to change difficulty if there is only one!

		if(PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'dejar charteo');
			
			var num:Int = 0;
			if(!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(3, 'Salir');
			}
			menuItemsOG.insert(3 + num, 'terminar');
			menuItemsOG.insert(4 + num, 'practica');
			menuItemsOG.insert(5 + num, 'Botplay');
		}
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficulties.length) {
			var diff:String = '' + CoolUtil.difficulties[i];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('Volver');


		pauseMusic = new FlxSound();
		if(songName != null) {
			pauseMusic.loadEmbedded(Paths.music(songName), true, true);
		} else if (songName != 'None') {
			pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)), true, true);
		}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		switch(PlayState.SONG.song)
				{
					case 'Isolated' | 'Laugh Track':
					Application.current.window.title = "Funkin.avi - " + WeekData.getCurrentWeek().weekName + ": " + PlayState.SONG.song + " - Hecho Por: Yama haki & obscurity. (PAUSADO)";
					case 'Lunacy' | 'Malfunction' | 'Mercy':
					Application.current.window.title = "Funkin.avi - " + WeekData.getCurrentWeek().weekName + ": " + PlayState.SONG.song + " - Hecho Por: obscurity. (PAUSADO)";
					case 'Delusional':
					Application.current.window.title = "Funkin.avi - " + WeekData.getCurrentWeek().weekName + ": " + PlayState.SONG.song + " - Hecho Por: FR3SHMoure (PAUSADO)";
					case 'Isolated Old' | "Don't Cross!":
					Application.current.window.title = "Funkin.avi - " + WeekData.getCurrentWeek().weekName + ": " + PlayState.SONG.song + " - Hecho Por: Yama haki (PAUSADO)";
					case 'Twisted Grins':
					Application.current.window.title = "Funkin.avi - " + WeekData.getCurrentWeek().weekName + ": " + PlayState.SONG.song + " - Hecho Por: Sayan Sama (PAUSADO)";
					case 'Hunted':
					Application.current.window.title = "Funkin.avi - " + WeekData.getCurrentWeek().weekName + ": " + PlayState.SONG.song + " - Hecho Por: JBlitz (PAUSADO)";
					default:
					Application.current.window.title = "Funkin.avi - " + WeekData.getCurrentWeek().weekName + ": " + PlayState.SONG.song + " (PAUSADO)";
				}

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var composerCredit:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		switch(PlayState.SONG.song)
		{
			case 'Isolated' | 'Laugh Track':
			composer = 'By Yama haki & obscurity.';
			case 'Lunacy' | 'Malfunction' | 'Mercy':
			composer = 'By obscurity.';
			case 'Delusional':
			composer = 'By FR3SHMoure';
			case 'Isolated Old' | "Don't Cross!":
			composer = 'By Yama haki';
			case 'Twisted Grins':
			composer = 'By Sama Yama';
			case 'Hunted':
			composer = 'By JBlitz';
		}
		composerCredit.text += composer;
		composerCredit.scrollFactor.set();
		composerCredit.setFormat(Paths.font('NewWaltDisneyFontRegular-BPen.ttf'), 32);
		composerCredit.updateHitbox();
		add(composerCredit);

		var charterCredit:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		switch(PlayState.SONG.song)
		{
			case 'Isolated' | 'Laugh Track' | 'Isolated Old' | 'Twisted Grins' | 'Malfunction' | 'Mercy':
			charter = 'Chart by DEMOLITIONDON96';
			case 'Lunacy':
			charter = 'Chart by obscurity';
			case 'Delusional':
			charter = 'Chart by Blake-whatsapp';
			case 'Hunted':
			charter = 'Chart by Noppz';
			case 'Birthday':
			charter = 'Chart by PhantomNexus';
			case "Don't Cross!":
			charter = 'Chart by fakeburritos123 & DEMOLITIONDON96';
		}
		charterCredit.text += charter;
		charterCredit.scrollFactor.set();
		charterCredit.setFormat(Paths.font('NewWaltDisneyFontRegular-BPen.ttf'), 32);
		charterCredit.updateHitbox();
		add(charterCredit);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 96, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('NewWaltDisneyFontRegular-BPen.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 128, 0, "", 32);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('NewWaltDisneyFontRegular-BPen.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 162, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('NewWaltDisneyFontRegular-BPen.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		var chartingText:FlxText = new FlxText(20, 15 + 162, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('NewWaltDisneyFontRegular-BPen.ttf'), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		blueballedTxt.alpha = 0;
		composerCredit.alpha = 0;
		charterCredit.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		composerCredit.x = FlxG.width - (composerCredit.width + 20);
		charterCredit.x = FlxG.width - (charterCredit.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});
		FlxTween.tween(composerCredit, {alpha: 1, y: composerCredit.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(charterCredit, {alpha: 1, y: charterCredit.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 1.1});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);
		updateSkipTextStuff();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var doReturn = controls.BACK;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}
		if(doReturn) //certificed Geometry Dash moment
		{
			switch(PlayState.SONG.song.toLowerCase())
			{
				case 'isolated' | 'lunacy' | 'delusional' | 'twisted grins' | 'facade' | 'mortiferum risus':
					MusicBeatState.switchState(new EpisodesState());
				case 'hunted' | 'isolated old' | 'isolated beta' | 'malfunction' | "don't cross!" | 'neglection' | 'cycled sins' | 'bless' | 'mercy' | 'scrapped': //omg too many extras (jason)
					MusicBeatState.switchState(new ExtrasState());
			    case 'isolated legacy' | 'lunacy legacy' | 'malfunction legacy' | 'mercy legacy':
					MusicBeatState.switchState(new LegacyState());
				case 'birthday':
					MusicBeatState.switchState(new EpicSelectorWOOO());
			}
		}
		var daSelected:String = menuItems[curSelected];
		switch (daSelected)
		{
			case 'Saltar':
				if (controls.UI_LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}

				if(controls.UI_LEFT || controls.UI_RIGHT)
				{
					holdTime += elapsed;
					if(holdTime > 0.5)
					{
						curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
					}

					if(curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
					else if(curTime < 0) curTime += FlxG.sound.music.length;
					updateSkipTimeText();
				}
		}

		if (accepted)
		{
			if (menuItems == difficultyChoices)
			{
				if(menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected)) {
					var name:String = PlayState.SONG.song;
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = curSelected;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					PlayState.chartingMode = false;
					skipTimeTracker = null;

					if(skipTimeText != null)
					{
						skipTimeText.kill();
						remove(skipTimeText);
						skipTimeText.destroy();
					}
					skipTimeText = null;
					return;
				}

				menuItems = menuItemsOG;
				regenMenu();
			}

			switch (daSelected)
			{
				case "Continuar":
					switch(PlayState.SONG.song)
				{
					case 'Isolated' | 'Laugh Track':
					Application.current.window.title = "Funkin.avi - " + WeekData.getCurrentWeek().weekName + ": " + PlayState.SONG.song + " - Hecho Por: Yama haki & obscurity.";
					case 'Lunacy' | 'Malfunction' | 'Mercy':
					Application.current.window.title = "Funkin.avi - " + WeekData.getCurrentWeek().weekName + ": " + PlayState.SONG.song + " - Hecho Por: obscurity.";
					case 'Delusional':
					Application.current.window.title = "Funkin.avi - " + WeekData.getCurrentWeek().weekName + ": " + PlayState.SONG.song + " - Hecho Por: FR3SHMoure";
					case 'Isolated Old' | "Don't Cross!":
					Application.current.window.title = "Funkin.avi - " + WeekData.getCurrentWeek().weekName + ": " + PlayState.SONG.song + " - Hecho Por: Yama haki";
					case 'Twisted Grins':
					Application.current.window.title = "Funkin.avi - " + WeekData.getCurrentWeek().weekName + ": " + PlayState.SONG.song + " - Hecho Por: Sayan Sama";
					case 'Hunted':
					Application.current.window.title = "Funkin.avi - " + WeekData.getCurrentWeek().weekName + ": " + PlayState.SONG.song + " - Hecho Por: JBlitz";
					default:
					Application.current.window.title = "Funkin.avi - " + WeekData.getCurrentWeek().weekName + ": " + PlayState.SONG.song;
				}
					//PlayState.startCountdown();
					close();
				case 'Cambiar Difficultad':
					menuItems = difficultyChoices;
					regenMenu();
				case 'practica':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
					practiceText.visible = PlayState.instance.practiceMode;
				case "Reiniciar":
					restartSong();
				case "dejar charteo":
					restartSong();
					PlayState.chartingMode = false;
				case 'saltar':
					if(curTime < Conductor.songPosition)
					{
						PlayState.startOnTime = curTime;
						restartSong(true);
					}
					else
					{
						if (curTime != Conductor.songPosition)
						{
							PlayState.instance.clearNotesBefore(curTime);
							PlayState.instance.setSongTime(curTime);
						}
						close();
					}
				case "terminar":
					close();
					PlayState.instance.finishSong(true);
				case 'Botplay':
						Application.current.window.alert('No, LOL');
						System.exit(0);
				case "Salir":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;
					if(PlayState.isStoryMode) {
						Application.current.window.title = "Funkin.avi";
						MusicBeatState.switchState(new StoryMenuState());
					} else {
						Application.current.window.title = "Funkin.avi";
						switch(PlayState.SONG.song)
						{
							default:
								MusicBeatState.switchState(new EpisodesState());
						}
					}
					PlayState.cancelMusicFadeTween();
					FlxG.sound.playMusic(Paths.music('funkinAVI/menu/MenuMusic'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
				case "Opciones":
					Application.current.window.title = "Funkin.avi - Settings";
					LoadingState.loadAndSwitchState(new OptionsAlt());
			}
		}
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('funkinAVI/menu/scroll_sfx'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));

				if(item == skipTimeTracker)
				{
					curTime = Math.max(0, Conductor.songPosition);
					updateSkipTimeText();
				}
			}
		}
	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length) {
			var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
			item.isMenuItem = true;
			item.targetY = i;
			grpMenuShit.add(item);

			if(menuItems[i] == 'Skip Time')
			{
				skipTimeText = new FlxText(0, 0, 0, '', 64);
				skipTimeText.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				skipTimeText.scrollFactor.set();
				skipTimeText.borderSize = 2;
				skipTimeTracker = item;
				add(skipTimeText);

				updateSkipTextStuff();
				updateSkipTimeText();
			}
		}
		curSelected = 0;
		changeSelection();
	}
	
	function updateSkipTextStuff()
	{
		if(skipTimeText == null) return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText()
	{
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}
}
