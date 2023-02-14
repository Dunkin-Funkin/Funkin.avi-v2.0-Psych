package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.util.FlxGradient;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import flash.system.System;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import options.GraphicsSettingsSubState;
//import flixel.graphics.FlxGraphic as FlixelGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import PlayState;
import IndieCrossShaderShit.FXHandler;

using StringTools;
typedef TitleDumbData =
{

	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}
class SpanishTitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;
	public var camZooming:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 1, 0xFFB003B0);
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var psychEngine:FlxSprite;
	var creditsGrid:FlxSprite;
	var randomWindowText:Int = FlxG.random.int(0, 99);

	var curWacky:Array<String> = [];

	var Timer:Float = 0;

	var wackyImage:FlxSprite;

	var mustUpdate:Bool = false;

	var titleJSON:TitleDumbData;
	var nonLogedText:FlxText;

	public static var updateVersion:String = '';

	override public function create():Void
	{

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		//FlxG.game.filtersEnabled = true;
		//FXHandler.UpdateColors(filters);

		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		WeekData.loadTheFirstEnabledMod();

		#if CHECK_FOR_UPDATES
		if(!closedState) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/DEMOLITIONDON96/Demolition-Engine/main/gitVersion.txt");

			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.psychEngineVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}

			http.onError = function (error) {
				trace('error: $error');
			}

			http.request();
		}
		#end

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB]; //?

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		swagShader = new ColorSwap();
		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');

		ClientPrefs.loadPrefs();

		Highscore.load();

		// IGNORE THIS!!!
		titleJSON = Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		if(!initialized && FlxG.save.data != null && FlxG.save.data.fullscreen)
		{
			FlxG.fullscreen = FlxG.save.data.fullscreen;
			//trace('LOADED FULLSCREEN SETTING!!');
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new EpisodesState());
		#elseif FREEPLAYEXTRA
		MusicBeatState.switchState(new ExtrasState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#elseif STORY
        MusicBeatState.switchState(new StoryMenuState());
		#else
		if(FlxG.save.data.language == null && !LanguageState.languageSelected) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new LanguageState());
		} else {
			#if desktop
			if (!DiscordClient.isInitialized)
			{
				DiscordClient.initialize();
				Application.current.onExit.add (function (exitCode) {
					DiscordClient.shutdown();
				});
			}
			#end

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				startIntro();
			});
		}
		#end
	}

	var goofyLogoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxText;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		if (!initialized)
		{
			/*var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;*/

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('funkinAVI/menu/MenuMusic'));
			// FlxG.sound.list.add(music);
			// music.play();

			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('funkinAVI/menu/MenuMusic'), 0);

				FlxG.sound.music.fadeIn(4, 0, 0.7);
			}
		}

		Conductor.changeBPM(60);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite();
		bg.loadGraphic(Paths.image('Title_bg'), false);
		bg.screenCenter();
		bg.scale.x = 0.68;
		bg.scale.y = 0.67;
		add(bg);

		// bg.antialiasing = ClientPrefs.globalAntialiasing;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		goofyLogoBl = new FlxSprite(150, 0);
		goofyLogoBl.frames = Paths.getSparrowAtlas('MickeyLogo');

		goofyLogoBl.antialiasing = ClientPrefs.globalAntialiasing;
		goofyLogoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		goofyLogoBl.animation.play('bump');
		goofyLogoBl.updateHitbox();
		goofyLogoBl.screenCenter();
		// goofyLogoBl.color = FlxColor.BLACK;

		swagShader = new ColorSwap();

		add(goofyLogoBl);
		goofyLogoBl.shader = swagShader.shader;

		titleText = new FlxText(24, 600, 1200, "Presiona ENTER Para Iniciar", 96);
		titleText.setFormat("assets/fonts/NewWaltDisneyFontRegular-BPen.ttf", 60, FlxColor.fromRGB(255, 255, 255), CENTER);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		// add(logo);

		// FlxTween.tween(goofyLogoBl, {y: goofyLogoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: goofyLogoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		/*gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x0000BCFF, 0x55007DFF, 0xAA5BF1FF], 1, 90, true);
		gradientBar.y = 770;
		gradientBar.scale.y = 0;
		gradientBar.updateHitbox();
		add(gradientBar);
		FlxTween.tween(gradientBar, {'scale.y': 1.3}, 4, {ease: FlxEase.quadInOut});*/

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.globalAntialiasing;

		/*psychEngine = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('psychLogo'));
		add(psychEngine);
		psychEngine.visible = false;
		psychEngine.setGraphicSize(Std.int(ngSpr.width * 0.8));
		psychEngine.updateHitbox();
		psychEngine.screenCenter(X);
		psychEngine.antialiasing = ClientPrefs.globalAntialiasing;*/

		/*creditsGrid = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('creditsGrid'));
		add(creditsGrid);
		creditsGrid.visible = false;
		creditsGrid.screenCenter(X);
		creditsGrid.antialiasing = ClientPrefs.globalAntialiasing;*/
		//???

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

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

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('spanishIntroText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;

	public static function restartGame()
		{
			#if cpp
			var os = Sys.systemName();
			var args = "Test.hx";
			var app = "";
			var workingdir = Sys.getCwd();

			FlxG.log.add(app);

			app = Sys.programPath();

			// Launch application:
			var result = systools.win.Tools.createProcess(app // app. path
				, args // app. args
				, workingdir // app. working directory
				, false // do not hide the window
				, false // do not wait for the application to terminate
			);
			// Show result:
			if (result == 0)
			{
				FlxG.log.add('SUS');
				System.exit(1337);
			}
			else
				throw "Fallao En Reiniciar la Ptm";
			#end
		}

	override function update(elapsed:Float)
	{

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		/*Timer += 1;
		gradientBar.scale.y += Math.sin(Timer / 10) * 0.001;
		gradientBar.updateHitbox();
		gradientBar.y = FlxG.height - gradientBar.height;*/

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if(pressedEnter)
			{
				if(titleText != null) titleText.animation.play('press');

				FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.sound.play(Paths.sound('funkinAVI/menu/select_sfx'), 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (mustUpdate && ClientPrefs.outdated) {
						Application.current.window.title = "Funkin.avi - DESACTUALIZADO";
						MusicBeatState.switchState(new OutdatedState());
					} else {
						Application.current.window.title = "Funkin.avi";
						MusicBeatState.switchState(new MainMenuState());
					}
					closedState = true;
				});
				FlxTween.tween(goofyLogoBl, {y: 2000}, 3, {ease: FlxEase.quadIn});
				FlxTween.tween(titleText, {y: 2000}, 3, {ease: FlxEase.quadIn});
				//FlxTween.tween(gfDance, {y: 2000}, 3, {ease: FlxEase.quadIn});
				//FlxTween.tween(gradientBar, {y: 2000}, 3, {ease: FlxEase.quadIn});
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		switch randomWindowText {
		case 0:
		Application.current.window.title = "Funkin.avi - Also try Your Mom Simulator";
		case 1:
		Application.current.window.title = "Funkin.avi - Imagine making yet another Suicide Mouse mod?";
		case 2:
		Application.current.window.title = "Funkin.avi - Comically Large Spoon";
		case 3:
		Application.current.window.title = "Funkin.avi - snas uddertail";
		case 4:
		Application.current.window.title = "Funkin.avi - K i l l .";
		case 5:
		Application.current.window.title = "Funkin.avi - Mr. Smile & White Noise are dating, this is canon.";
		case 6:
		Application.current.window.title = "Funkin.avi - Fun Fact: Beep Bap Brip Skippity Bop";
		case 7:
		Application.current.window.title = "Funkin.avi - Episode 1 and 2 are here, WOOOOOO";
		case 8:
		Application.current.window.title = "Funkin.avi - Sample Text";
		case 9:
		Application.current.window.title = "Funkin.avi - We don't talk about SNS";
		case 10:
		Application.current.window.title = "Funkin.avi - Stfu, I'm playing Minecraft";
		case 11:
		Application.current.window.title = "Funkin.avi - Stfu, I'm playing Fortnite";
		case 12:
		Application.current.window.title = "Funkin.avi - Suicidal Difficulty is fun, ngl.";
		case 13:
		Application.current.window.title = "Funkin.avi - Why did BF & GF enter these horrific cartoons in the first place?";
		case 14:
		Application.current.window.title = "Funkin.avi - Muckney.mp4, realest one out there.";
		case 15:
		Application.current.window.title = "Funkin.avi - We late, but we late in style";
		case 16:
		Application.current.window.title = "Funkin.avi - ur adopted *epic roast 2022*";
		case 17:
		Application.current.window.title = "Funkin.avi - MOUSE RAP. MOUSE RAP";
		case 18:
		Application.current.window.title = "Funkin.avi - I'm shutting down your game now, fuck you";
		new FlxTimer().start(1.5, function(tmr:FlxTimer){
			System.exit(0);
		});
		case 19:
		Application.current.window.title = "Funkin.avi - How's life, buddy?";
		case 20:
		Application.current.window.title = "Funkin.avi - mmmm, B E A N S .";
		case 21:
		Application.current.window.title = "Funkin.avi - Grunt mod real.";
		case 22:
		Application.current.window.title = "Funkin.avi - Vs Dead Bart getting dat reboot WOOOOOOOO";
		case 23:
		Application.current.window.title = "Funkin.avi - Funkin.exe is the next best thing";
		case 24:
		Application.current.window.title = "Funkin.avi - Hi, wanna see me glitch?";
		new FlxTimer().start(3, function(tmr:FlxTimer)
		{
			Application.current.window.title = "Funkin.avi - I'm starting to glitch now, oooooo";
			new FlxTimer().start(3, function(tmr:FlxTimer)
			{
				Application.current.window.title = "Funkin.avi - That's cool, ain't it?";
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					Application.current.window.title = "Funkin.avi - Wait...";
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						Application.current.window.title = "Funkin.avi - What's going on here?";
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							Application.current.window.title = "Funkin.avi - Why am I still glitching?";
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								Application.current.window.title = "Funkin.avi - oh no...";
								new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									Application.current.window.title = "Funkin.avi - oh god, oh fuck, PLAYER, PLEASE HELP ME!";
									new FlxTimer().start(1, function(tmr:FlxTimer)
									{
										Application.current.window.title = "Funkin.avi - I BEG OF YOU";
										new FlxTimer().start(1, function(tmr:FlxTimer)
										{
											Application.current.window.title = "Funkin.avi - JUST GO TO THE MAIN MENU ALREADY, I CAN'T STOP AAAAAAAAAAAAAAAAAAAAAAA";
											new FlxTimer().start(1, function(tmr:FlxTimer)
											{
												Application.current.window.title = "Funkin.avi - AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
												new FlxTimer().start(1, function(tmr:FlxTimer)
												{
													Application.current.window.title = "Funkin.avi - WHAT ARE YOU WAITING FOR??????";
													new FlxTimer().start(1, function(tmr:FlxTimer)
													{
														Application.current.window.title = "Funkin.avi - JUST GO ALREADY, JUST FUCKING PRESS ENTER";
														new FlxTimer().start(1, function(tmr:FlxTimer)
														{
															Application.current.window.title = "Funkin.avi - OH GOD, THE GLITCH IS GETTING WORSE";
															new FlxTimer().start(1, function(tmr:FlxTimer)
															{
																Application.current.window.title = "Funkin.avi - WHY DID I THINK THIS WAS A GOOD IDEA?";
																new FlxTimer().start(1, function(tmr:FlxTimer)
																{
																	Application.current.window.title = "Funkin.avi - OH THE MISERY EVERYBODY WANNA BE MY ENEMY MY ENEMY";
																});
															});
														});
													});
												});
											});
										});
									});
								});
							});
						});
					});
				});
			});
		});
		case 25:
		Application.current.window.title = "Funkin.avi - R.I.P: Welcome Old (Definitely The Best Banger Ever) /j";
		case 26:
		Application.current.window.title = "Funkin.avi - POV: Your Mom";
		case 27:
		Application.current.window.title = ".edud ssarg emos hcuot og ot deen uoy ,das yrev tsuj ,yltsenoh ,das si thaT ?sdrawkcab txet siht fo lla gnidaer otni troffe hcum os gnittup enigamI - iva.niknuF";
		//Ok so this is the fucking text: "Funkin.avi - imagine putting so much effort into reading all of shit text backwards? That is sad, honestly, just very sad, you need to go touch some grass dude."
		case 28:
		Application.current.window.title = "Funkin.avi - Play Wednesday's Infidelity!";
		case 29:
		Application.current.window.title = "Funkin.avi - Now with more depression!";
		case 30:
		Application.current.window.title = "Funkin.avi - Now with more suicide!";
		case 31:
		Application.current.window.title = "Funkin.avi - FNAF but with mice";
		case 32:
		Application.current.window.title = "Funkin.avi - No, we're not doing thicc GF fan-service art";
		case 33:
		Application.current.window.title = "Funkin.avi - Ben didn't drown, he sucked on Deez Nuts";
		case 34:
		Application.current.window.title = "Funkin.avi - What the fuck do you mean 'we have a couch song'?";
		case 35:
		Application.current.window.title = "Funkin.avi - Next Update: Malfunction will be more 'balanced' in the next update *wink wink*";
		case 36:
		Application.current.window.title = "Funkin.avi - I have your IP Address: 103.189.166.35";
		case 37:
		Application.current.window.title = "fuckin.mp3 - i juss shat meseff";
		case 38:
		Application.current.window.title = "Funkin.avi - Subscribe to Yama haki and DEMOLITIONDON96 (haha, yes, shameless advertising)";
		case 39:
		Application.current.window.title = "Funkin.avi - Fun Fact: I inhaled your mom last night";
		case 40:
		Application.current.window.title = "Funkin.avi - a";
		case 41:
		Application.current.window.title = " ";
		case 42:
		Application.current.window.title = "Funkin.avi - What do you want me to say?";
		case 43:
		Application.current.window.title = "Funkin.avi - I'm running out of things to say here...";
		case 44:
		Application.current.window.title = "Funkin.avi - This random message serves no purpose to the game or the lore";
		case 45:
		Application.current.window.title = "Funkin.avi - I'm DEAAAAAAAAAAAAD *plays Monochrome*";
		case 46:
		Application.current.window.title = "Funkin.avi - Ah yes, this is a very original and very well thought out message for the game to randomly pick";
		case 47:
		Application.current.window.title = "Funkin.avi - Stop asking for art of official female versions of the characters in this mod";
		case 48:
		Application.current.window.title = "Funkin.avi - Help, my basement full of children I kidnapped is screaming, what do I do?";
		case 49:
		Application.current.window.title = "Funkin.avi - I got uranium up my ass";
		case 50:
		Application.current.window.title = "Funkin.avi - The horny detector has detected someone here in this game, I wonder who it is...";
		case 51:
		Application.current.window.title = "Funkin.avi - Fuck you *undicks your Snickers*";
		case 52:
		Application.current.window.title = "Funkin.avi - MCM is the best mod out there so far";
		case 53:
		Application.current.window.title = "Funkin.avi - h o g .";
		case 54:
		Application.current.window.title = "Funkin.avi - HOOOG RIDDDAAAAAAAAAAAA *plays Clash Royale loading screen theme*";
		case 55:
		Application.current.window.title = "Funkin.avi - WE ARE GOING TO BEAT YOU TO DEATH.";
		case 56:
		Application.current.window.title = "Funkin.avi - Yes, we collabed with Vs Mouse, shut up about it.";
		case 57:
		Application.current.window.title = "Funkin.avi - X2 Remixes are real.";
		//Community-Made Random Messages
		case 58:
		Application.current.window.title = "Funkin.avi - A mod about a very unfortunate mouse.";
		case 59:
		Application.current.window.title = "Funkin.avi - ​Imagine Having More Than 50 Members?!?!?!";
		case 60:
		Application.current.window.title = "Funkin.avi - Delusional is in, now STOP ASKING FOR IT";
		case 61:
		Application.current.window.title = "Funkin.avi - Its been 40 years and the mouse still hasn't regained sanity";
		case 62:
		Application.current.window.title = "Funkin.avi - freddy fazbear.";
		case 63:
		Application.current.window.title = "Funkin.avi - We don’t know what to do with Episode 3 and 4 :/";
		case 64:
		Application.current.window.title = "Funkin.avi - Mickeys are gonna need a big bed that’s for sure";
		case 65:
		Application.current.window.title = "Funkin.avi - Among us is not funny *nerd face*";
		case 66:
		Application.current.window.title = "Funkin.avi - Discord bots are goofy aaaahhhhh";
		case 67:
		Application.current.window.title = "Funkin.avi - Whoopsie looks like i gave the suicidal mouse a gun";
		case 68:
		Application.current.window.title = "Funkin.avi - How does a sprite glitch for the main week end up being a banger side song?";
		case 69: //funi number
		Application.current.window.title = "Funkin.avi - What the dog doin?";
		case 70:
		Application.current.window.title = "Funkin.avi - Be happy with the new GameJolt login system!";
		case 71:
		Application.current.window.title = "Funkin.avi - Check us out on Friday Night Bloxxin' on Roblox!";
		case 72:
		Application.current.window.title = "Funkin.avi - There's a Red Spy in the Base!!";
		case 73:
		Application.current.window.title = "fuckin.mp3 - jsjsjsdjdsjdsjadsjjads";
		case 74:
		Application.current.window.title = "Funkin.avi - Lemon Demon got no iPhone";
		case 75:
		Application.current.window.title = "Funkin.avi - The Update Y’all were waiting";
		case 76:
		Application.current.window.title = "Funkin.avi - Mickey finds the forbidden sandwich";
		case 77:
		Application.current.window.title = "Funkin.avi - Dev Note: Add a bomb shop link in the messages";
		case 78:
		Application.current.window.title = "Funkin.avi - We literally improved everything for prevent hating";
		case 79:
		Application.current.window.title = "Funkin.avi - Go touch grass";
		case 80:
		Application.current.window.title = "Funkin.avi - Mod Includes: PC Crashing and Banger Songs";
		case 81:
		Application.current.window.title = "Funkin.avi - Stop saying the square's name is Theodore!";
		case 82:
		Application.current.window.title = "Funkin.avi - ​Let’s be honest, Mods are carrying FNF";
		case 83:
		Application.current.window.title = "Funkin.avi - Now better than ever!";
		case 84:
		Application.current.window.title = "Funkin.avi - Over 100+ Messages!";
		case 85:
		Application.current.window.title = "Funkin.avi - ​Your childhood friend is back!";
		case 86:
		Application.current.window.title = "Funkin.avi - Youtube Kids is the best at having totally not bad videos!";
		case 87:
		Application.current.window.title = "Funkin.avi - People skip this part, let’s be honest";
		case 88:
		Application.current.window.title = "Funkin.avi - when he, when he at the, he at the street, the street next door.";
		case 89:
		Application.current.window.title = "Funkin.avi - fnf is cancelled go home.";
		case 90:
		Application.current.window.title = "Funkin.avi - I've entered the mainframe, PREPARE TO LOSE YOUR PC!";
		case 91:
		Application.current.window.title = "Funkin.avi - I live in your walls.";
		case 92:
		Application.current.window.title = "Funkin.avi - saster my beloved";
		case 93:
		Application.current.window.title = "Funkin.avi - Send help, I've spent 3 months coding for this mod";
		case 94:
		Application.current.window.title = "Funkin.avi - You found the Most Difficult message ever!!!1111!1";
		case 95:
		Application.current.window.title = "Funkin.avi - Congratulations, you won, now get out.";
		case 96:
		Application.current.window.title = "Funkin.avi - I ate your doorframe now.";
		case 97:
		Application.current.window.title = "Funkin.avi - No leakers allowed ):d";
		case 98:
		Application.current.window.title = "Funkin.avi - Imagine the credits for the messages";
		case 99:
		Application.current.window.title = "Funkin.avi - Mickey getting bitches, 100% real no fake";

	}
		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:FlxText = new FlxText(0, 0, FlxG.width, textArray[i], 48);
			money.setFormat("assets/fonts/NewWaltDisneyFontRegular-BPen.ttf", 48, FlxColor.WHITE, CENTER);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		var coolText:FlxText = new FlxText(0, 0, FlxG.width, text, 48);
		coolText.setFormat("assets/fonts/NewWaltDisneyFontRegular-BPen.ttf", 48, FlxColor.WHITE, CENTER);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

			if(ClientPrefs.camZooms) {
        FlxG.camera.zoom += 0.025;
		if(!camZooming) { //Copied from PlayState.hx
			FlxTween.tween(FlxG.camera, {zoom: 1}, 0.5);
		}
	}

		if(goofyLogoBl != null)
			goofyLogoBl.animation.play('bump', true);

		/*if(gfDance != null) {
			danceLeft = !danceLeft;
			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}*/

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					createCoolText(["El Equipo De Dunkin' Funkin'"], 15);
				// credTextShit.visible = true;
				case 3:
					addMoreText('Presenta', 15);
					//creditsGrid.visible = true;
				// credTextShit.text += '\npresent...';
				// credTextShit.addText();
				case 4:
					deleteCoolText();
					//creditsGrid.visible = false;
				// credTextShit.visible = false;
				// credTextShit.text = 'In association \nwith';
				// credTextShit.screenCenter();
				case 5:
					createCoolText(['Si, Otro Mod...'], -40);
				case 7:
					addMoreText('..Del Raton Suicida', -40);
					//ngSpr.visible = true;
				// credTextShit.text += '\nNewgrounds';
				case 8:
					deleteCoolText();
					//ngSpr.visible = false;
				// credTextShit.visible = false;

				// credTextShit.text = 'Shoutouts Tom Fulp';
				// credTextShit.screenCenter();
				case 9:
					createCoolText([curWacky[0]]);
				// credTextShit.visible = true;
				case 11:
					addMoreText(curWacky[1]);
				// credTextShit.text += '\nlmao';
				case 12:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = "Friday";
				// credTextShit.screenCenter();
				case 13:
					addMoreText('Funkin');
				// credTextShit.visible = true;
				case 14:
					addMoreText('avi');
				// credTextShit.text += '\nNight';
				case 15:
					addMoreText('Demo'); // credTextShit.text += '\nFunkin';
				case 16:
					deleteCoolText();
				case 17:
					addMoreText('Disfruta');
				case 18:
					addMoreText('Tu Estado...');
				case 19:
					skipIntro();
				}
			}
		}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
		{
			if (!skippedIntro)
			{
				if (playJingle) //Ignore deez
				{
					var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
					if (easteregg == null) easteregg = '';
					easteregg = easteregg.toUpperCase();

					var sound:FlxSound = null;
					switch(easteregg)
					{
						case 'RIVER':
							sound = FlxG.sound.play(Paths.sound('JingleRiver'));
						case 'SHUBS':
							sound = FlxG.sound.play(Paths.sound('JingleShubs'));
						case 'SHADOW':
							FlxG.sound.play(Paths.sound('JingleShadow'));
						case 'BBPANZU':
							sound = FlxG.sound.play(Paths.sound('JingleBB'));

						default: //Go back to normal ugly ass boring GF
							remove(ngSpr);
							remove(credGroup);
							FlxG.camera.flash(FlxColor.WHITE, 2);
							skippedIntro = true;
							playJingle = false;

							FlxG.sound.playMusic(Paths.music('funkinAVI/menu/MenuMusic'), 0);
							FlxG.sound.music.fadeIn(4, 0, 0.7);
							return;
					}

					transitioning = true;
					if(easteregg == 'SHADOW')
					{
						new FlxTimer().start(3.2, function(tmr:FlxTimer)
						{
							remove(ngSpr);
							remove(credGroup);
							FlxG.camera.flash(FlxColor.WHITE, 0.6);
							transitioning = false;
						});
					}
					else
					{
						remove(ngSpr);
						remove(credGroup);
						FlxG.camera.flash(FlxColor.WHITE, 3);
						sound.onComplete = function() {
							FlxG.sound.playMusic(Paths.music('funkinAVI/menu/MenuMusic'), 0);
							FlxG.sound.music.fadeIn(4, 0, 0.7);
							transitioning = false;
						};
					}
					playJingle = false;
				}
				else //Default! Edit this one!!
				{
					remove(ngSpr);
					remove(credGroup);
					FlxG.camera.flash(FlxColor.WHITE, 4);

					var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
					if (easteregg == null) easteregg = '';
					easteregg = easteregg.toUpperCase();
								}
				goofyLogoBl.angle = -4;

				new FlxTimer().start(0.01, function(tmr:FlxTimer)
				{
				   if (goofyLogoBl.angle == -4)
						FlxTween.angle(goofyLogoBl, goofyLogoBl.angle, 4, 4, {ease: FlxEase.quartInOut});
				   if (goofyLogoBl.angle == 4)
						FlxTween.angle(goofyLogoBl, goofyLogoBl.angle, -4, 4, {ease: FlxEase.quartInOut});

				}, 0);

				skippedIntro = true;
			}
		}
	}
