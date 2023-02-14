package;

import PlatformUtil;
#if desktop
import gamejolt.GJClient;
import gamejolt.formats.*;
#end
import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.animation.FlxAnimationController;
import flixel.FlxGame;
import lime.app.Application;
import flash.system.System;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.util.FlxGradient;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.ui.MouseButton;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.Window;
import flash.system.Capabilities;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
// everything else
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.display.StageScaleMode;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import openfl.filters.ShaderFilter;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxSave;
import animateatlas.AtlasFrameMaker;
import Achievements;
import DialogueBoxPsych;
import StageData;
import FunkinLua;
import data.Etterna;
import data.Ratings;
import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.MouseButton;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.Window;
import flash.system.Capabilities;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.display.Sprite;
import openfl.utils.Assets;

import flixel.system.scaleModes.BaseScaleMode;
import flixel.system.scaleModes.FillScaleMode;
import flixel.system.scaleModes.FixedScaleMode;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.system.scaleModes.RelativeScaleMode;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.system.scaleModes.PixelPerfectScaleMode;

import Shaders;
import IndieCrossShaderShit.FXHandler;
#if sys
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['Shit...', 0.2], //From 0% to 19%
		['Terrible', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Meh', 0.6], //From 50% to 59%
		['Okay', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good.', 0.8], //From 70% to 79%
		['Great!', 0.9], //from 80% to 89%
		['Sick!!', 1], //From 90% to 99%
		['Perfect!!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];
	
	//Code by lemz1
	public var window = Lib.application.window;
 	public var windowX:Int = 320;
 	public var windowY:Int = 180;
 	public var windowW:Int = 1280;
 	public var windowH:Int = 720;

	public var SCALEdebugText:FlxText;

	public var modeBase:BaseScaleMode;
	public var modeFill:FillScaleMode;
	public var modeFixed:FixedScaleMode;
	public var modeRatio:RatioScaleMode;
	public var modeRelative:RelativeScaleMode;
	public var modeStage:StageSizeScaleMode;
	public var modePixel:PixelPerfectScaleMode;
	
	//Shaders shit
	public var camGameShaders:Array<ShaderEffect> = [];
	public var camHUDShaders:Array<ShaderEffect> = [];
	public var camOtherShaders:Array<ShaderEffect> = [];
	
	var canaddshaders:Bool = ClientPrefs.funiShaders;
	var filters:Array<BitmapFilter> = [];
	
	//modchart
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130; 

	//public var hudTransitionTween:FlxTween;
	//public var hudTransitionSpeed(default, set):Float = 1;
	public var hudTransparentTween:FlxTween;
	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var camZoomTween:FlxTween;
	
	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public var shaderUpdates:Array<Float->Void> = [];
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var vocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	var isDownscroll:Bool = false;
	private var strumLine:FlxSprite;

	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;
	public var blackFadeThing:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var maxHealth:Float = 2;
	public var healthDrain:Float = 0;
	public var combo:Int = 0;
	
	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var peakCamera:FlxCamera;
	public var camCustom:FlxCamera;
	public var cameraSpeed:Float = 1;

	var dialogue:Array<String> = [
	'hi do you know who joe is?', 
	'coolswag'];
	var dialogueJson:DialogueFile = null;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyLightsColors:Array<FlxColor>;
	var phillyWindow:BGSprite;
	var phillyStreet:BGSprite;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:FlxSprite;
	var phillyWindowEvent:BGSprite;
	var trainSound:FlxSound;

	var phillyGlowGradient:PhillyGlow.PhillyGlowGradient;
	var phillyGlowParticles:FlxTypedGroup<PhillyGlow.PhillyGlowParticle>;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var foregroundSprites:FlxTypedGroup<BGSprite>;

	//Here comes the peak part of the songs going brrrrrrrrrrrrrr (jason)
	public static var hereComesThePeak:Bool = false;
	
	//Cool Ass Delusional Shit
	public var attemptsTillJumpscare:Int = 21; //Loser, you can't pause on Delusional
	var lightRain:FlxSprite;
	var heavyRain:FlxSprite;
	var rainIsHeavy:Bool = false;
	var toggleThunder:Bool = false;
	var toggleDestroyedBuildings:Bool = false;
	var transformationScreenEffect:FlxSprite;
	var fireBG:BGSprite;
	var satanSpeaks:FlxText;
	var satanJumpscare:FlxSprite;
	var satanPopup:FlxSprite; //haha, funi distorted BF face, spooky

	//Overlay Shit
	var light:BGSprite;
	var cutsceneTransitionHelper:FlxSprite;
	var treesFront:BGSprite;
	var depression:BGSprite;
	var vignetteCam:BGSprite;
	var chains:BGSprite;
	var vaultSpook:BGSprite;
	var chainsINVERT:BGSprite;
	var vaultSpookINVERT:BGSprite;
	var snsMickDed:BGSprite;

	//Couch Characters
	var rookieMick:FlxSprite;
	var randyMick:FlxSprite;
	var WIMick:FlxSprite;
	var cogMick:FlxSprite;
	var aviMick:FlxSprite;

	//Cool Visual Shit
	var spotlight:BGSprite;
	var darknessBlack:BGSprite;
	var whiteFlashBG:FlxSprite;
	var whiteFlashBGFade:FlxTween;
	var gradientBar:FlxSprite = new FlxSprite(-1200, 0).makeGraphic(FlxG.width, 1, 0xFFAA00AA);
	var rsTV:BGSprite;
	var vault:BGSprite;
	var vaultINVERT:BGSprite;
	var cinematicBars:Map<String, FlxSprite> = ["top" => null, "bottom" => null,];
	var camBars:FlxCamera; // I got lazy, sorry.
	//var rsTVColors:Int = FlxG.random.int(0, 4); this is not being used anymore :(

	//Malfunction Stuff
	var crashLives:FlxText;
	var crashLivesIcon:FlxSprite;
	public var crashLivesCounter:Int = 60;
	var mickParticles:FlxEmitter;
	var threatTrail:FlxTrail;
	var glitchTimeColors:Int = FlxG.random.int(11, 19); //timer colors go crazy
	public var funnyTimebarThing:Int;
	public var healthBarCrazy:Dynamic; //lazy to know
	var blackParticles:FlxEmitter;
	var greyParticles:FlxEmitter;

	//Walt Mechanics Stuff
	var waltText:FlxText;
	var gettinSleepy:FlxSprite;

	//Relapse shit
	var relapseChaos:BGSprite;
	var relapseCalm:BGSprite;
	var dodged:Bool;
	var shootin:Bool;
	var canDodge:Bool = true;
	var pressedSpace:Bool = false;
	var pressCounter = 0;
	//var warningText:FlxSprite;
	var detectAttack:Bool = false;
	var holyShitMOVEBITCH:FlxSprite;
	var PRESSSPACEDUMBASS:FlxText;

	//stole this from Vs Ourple Guy mod lmfao
	var zoomBeat:Float = 4;
	var zoomBounce:Float = 0;
	var songBanner:FlxSprite;
	var songBannerText:FlxText;
	var charterBanner:FlxSprite;

	public var mechanics:Bool = true;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var totalMisses:Int = 0;
	public var scoreTxt:FlxText;
	var peWatermark:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;
	var judgementCounter:FlxText;

	var healthIcon:FlxSprite;
	var healthTxt:FlxText;
	var timeIcon:FlxSprite;
	var missIcon:FlxSprite;
	var missTxt:FlxText;
	var judgementUnderlay:FlxSprite;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;
	
	public var marvelouses:Int = 0;
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	var scoreSideTxt:FlxText;
	var missesTxt:FlxText;
	var acurracyTxt:FlxText;
	var sickTxt:FlxText;
	var goodTxt:FlxText;
	var badTxt:FlxText;
	var shitTxt:FlxText;
	var songTxt:FlxText;

	var scoreGroup:FlxTypedSpriteGroup<FlxText>;

	var hudStyle = ClientPrefs.hudSelection;

	var color:FlxColor;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var curPortrait:String = "";
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;
	
	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	
	//Pause Shit ig
	public static var current:PlayState;

	var precacheList:Map<String, String> = new Map<String, String>();

	var windowDad:Window;
    var dadWin = new Sprite();
    var dadScrollWin = new Sprite();

	var windowBoyfriend:Window;
    var boyfriendWin = new Sprite();
    var bfScrollWin = new Sprite();

	override public function create()
	{
		Paths.clearStoredMemory();

		//I fucking hate saves aaaaaaaaa
		switch(SONG.song.toLowerCase()) {
			case 'hunted':
				if (FlxG.save.data.huntedLock != 'beaten') FPClientPrefs.huntedLock = 'unlocked';
				FPClientPrefs.saveShit();
			case 'isolated old':
				if (FlxG.save.data.oldisolateLock != 'beaten') FPClientPrefs.oldisolateLock = 'unlocked';
				FPClientPrefs.saveShit();
			case 'isolated beta':
				if (FlxG.save.data.betaisolateLock != 'beaten') FPClientPrefs.betaisolateLock = 'unlocked';
				FPClientPrefs.saveShit();
			case "don't cross!":
				if (FlxG.save.data.crossinLock != 'beaten') FPClientPrefs.crossinLock = 'unlocked';
				FPClientPrefs.saveShit();
			case 'malfunction':
				if (FlxG.save.data.malfunctionLock != 'beaten') FPClientPrefs.malfunctionLock = 'unlocked';
				FPClientPrefs.saveShit();
			case 'cycled sins':
				if (FlxG.save.data.sinsLock != 'beaten') FPClientPrefs.sinsLock = 'unlocked';
				FPClientPrefs.saveShit();
			case 'war dilemma':
				if (FlxG.save.data.warLock != 'beaten') FPClientPrefs.warLock = 'unlocked';
				FPClientPrefs.saveShit();
			case 'scrapped':
				if (FlxG.save.data.scrappedLock != 'beaten') FPClientPrefs.scrappedLock = 'unlocked';
				FPClientPrefs.saveShit();
			case 'bless':
				if (FlxG.save.data.blessLock != 'beaten') FPClientPrefs.blessLock = 'unlocked';
				FPClientPrefs.saveShit();
			case 'mercy':
				if (FlxG.save.data.mercyLock != 'beaten') FPClientPrefs.mercyLock = 'unlocked';
				FPClientPrefs.saveShit();
			case 'neglection':
					if (FlxG.save.data.pnmLock != 'beaten') FPClientPrefs.pnmLock = 'unlocked';
					FPClientPrefs.saveShit();
		}

		modeBase = new BaseScaleMode();
		modeFill = new FillScaleMode();
		modeFixed = new FixedScaleMode();
		modeRatio = new RatioScaleMode();
		modeRelative = new RelativeScaleMode(0.75, 0.75);
		modeStage = new StageSizeScaleMode();
		modePixel = new PixelPerfectScaleMode();

		// for lua
		instance = this;

		FlxG.game.setFilters(filters);

		FlxG.game.filtersEnabled = true;

		FXHandler.UpdateColors(filters);
		
		/*switch(ClientPrefs.lives){
			case 'easy':
				crashLivesCounter = 60; //dam

			case 'normal':
				crashLivesCounter = 30; //ok

			case 'hard':
				crashLivesCounter = 10; //a

			case 'hell':
				crashLivesCounter = 1; //needs to be a achiev
		}*/

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed', 1);

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camBars = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camCustom = new FlxCamera();
		camBars.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		camCustom.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camBars);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		FlxG.cameras.add(camCustom);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		trace('stage is: ' + curStage);
		if(SONG.stage == null || SONG.stage.length < 1) {
			switch (songName)
			{
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					curStage = 'tank';
				case 'isolated' | 'isolated-old' | 'lunacy' | 'delusional':
					curStage = 'EndlessLoop';
				case 'twisted-grins':
					curStage = 'Office';
				case 'hunted':
					curStage = 'Forest';
				case 'malfunction':
					curStage = 'PixelWorld';
				default:
					curStage = 'stage';
			}
		}
		SONG.stage = curStage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];
		
		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'stage': //Week 1

				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);
				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}

			case 'spooky': //Week 2
				if(!ClientPrefs.lowQuality) {
					halloweenBG = new BGSprite('halloween_bg', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike']);
				} else {
					halloweenBG = new BGSprite('halloween_bg_low', -200, -100);
				}
				add(halloweenBG);

				halloweenWhite = new BGSprite(null, -FlxG.width, -FlxG.height, 0, 0);
				halloweenWhite.makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), FlxColor.WHITE);
				halloweenWhite.alpha = 0;
				halloweenWhite.blend = ADD;

				//PRECACHE SOUNDS
				precacheList.set('thunder_1', 'sound');
				precacheList.set('thunder_2', 'sound');

			case 'philly': //Week 3
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('philly/sky', -100, 0, 0.1, 0.1);
					add(bg);
				}
				
				var city:BGSprite = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
				phillyWindow = new BGSprite('philly/window', city.x, city.y, 0.3, 0.3);
				phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
				phillyWindow.updateHitbox();
				add(phillyWindow);
				phillyWindow.alpha = 0;

				if(!ClientPrefs.lowQuality) {
					var streetBehind:BGSprite = new BGSprite('philly/behindTrain', -40, 50);
					add(streetBehind);
				}

				phillyTrain = new BGSprite('philly/train', 2000, 360);
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);

				phillyStreet = new BGSprite('philly/street', -40, 50);
				add(phillyStreet);

			case 'limo': //Week 4
				var skyBG:BGSprite = new BGSprite('limo/limoSunset', -120, -50, 0.1, 0.1);
				add(skyBG);

				if(!ClientPrefs.lowQuality) {
					limoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4);
					add(limoMetalPole);

					bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
					add(bgLimo);

					limoCorpse = new BGSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
					add(limoCorpse);

					limoCorpseTwo = new BGSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
					add(limoCorpseTwo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					limoLight = new BGSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
					add(limoLight);

					grpLimoParticles = new FlxTypedGroup<BGSprite>();
					add(grpLimoParticles);

					//PRECACHE BLOOD
					var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
					particle.alpha = 0.01;
					grpLimoParticles.add(particle);
					resetLimoKill();

					//PRECACHE SOUND
					precacheList.set('dancerdeath', 'sound');
				}

				limo = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);

				fastCar = new BGSprite('limo/fastCarLol', -300, 160);
				fastCar.active = true;
				limoKillingState = 0;

			case 'mall': //Week 5 - Cocoa, Eggnog
				var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				if(!ClientPrefs.lowQuality) {
					upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3);
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
				}

				var tree:BGSprite = new BGSprite('christmas/christmasTree', 370, -250, 0.40, 0.40);
				add(tree);

				bottomBoppers = new BGSprite('christmas/bottomBop', -300, 140, 0.9, 0.9, ['Bottom Level Boppers Idle']);
				bottomBoppers.animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:BGSprite = new BGSprite('christmas/fgSnow', -600, 700);
				add(fgSnow);

				santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
				add(santa);
				precacheList.set('Lights_Shut_off', 'sound');

			case 'mallEvil': //Week 5 - Winter Horrorland
				var bg:BGSprite = new BGSprite('christmas/evilBG', -400, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:BGSprite = new BGSprite('christmas/evilTree', 300, -300, 0.2, 0.2);
				add(evilTree);

				var evilSnow:BGSprite = new BGSprite('christmas/evilSnow', -200, 700);
				add(evilSnow);

			case 'school': //Week 6 - Senpai, Roses
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
				add(bgSky);
				bgSky.antialiasing = false;

				var repositionShit = -200;

				var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repositionShit, 0, 0.6, 0.90);
				add(bgSchool);
				bgSchool.antialiasing = false;

				var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionShit, 0, 0.95, 0.95);
				add(bgStreet);
				bgStreet.antialiasing = false;

				var widShit = Std.int(bgSky.width * 6);
				if(!ClientPrefs.lowQuality) {
					var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', repositionShit + 170, 130, 0.9, 0.9);
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					fgTrees.updateHitbox();
					add(fgTrees);
					fgTrees.antialiasing = false;
				}

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);
				bgTrees.antialiasing = false;

				if(!ClientPrefs.lowQuality) {
					var treeLeaves:BGSprite = new BGSprite('weeb/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
					treeLeaves.setGraphicSize(widShit);
					treeLeaves.updateHitbox();
					add(treeLeaves);
					treeLeaves.antialiasing = false;
				}

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));

				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();

				if(!ClientPrefs.lowQuality) {
					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}

			case 'schoolEvil': //Week 6 - Thorns
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				/*if(!ClientPrefs.lowQuality) { //Does this even do something?
					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
				}*/
				var posX = 400;
				var posY = 200;
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);

					bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
					bgGhouls.setGraphicSize(Std.int(bgGhouls.width * daPixelZoom));
					bgGhouls.updateHitbox();
					bgGhouls.visible = false;
					bgGhouls.antialiasing = false;
					add(bgGhouls);
				} else {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool_low', posX, posY, 0.8, 0.9);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);
				}

			case 'EndlessLoop':
				//GameOverSubstate.deathSoundName = 'fnf_loss_sfx-mickey';
				//GameOverSubstate.loopSoundName = 'gameOver-mickey';
				//GameOverSubstate.endSoundName = 'gameOverEnd-mickey';
				//GameOverSubstate.characterName = 'bf-demon-dead';

				var street:BGSprite = new BGSprite('funkinAVI/episode1/street/Mickeybg', -382, -409);
				add(street);

				if(canaddshaders)
				{
					//Epic Shaders Let's GOOOOOOOOO
					addShaderToCamera('hud', new ChromaticAberrationEffect(0.003));
					addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
					addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
					//addShaderToCamera('game', new VhsEffect(0.3, 0));
					if(!ClientPrefs.optimization) {
					addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
					addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
					}
					addShaderToCamera('hud', new GreyscaleEffect());
					addShaderToCamera('game', new GreyscaleEffect());
				}


				case 'LegacyLoop':

					var street:BGSprite = new BGSprite('funkinAVI/episode1/street/Mickeybg', -382, -409);
					add(street);

					if(canaddshaders)
						{
							//cool shaders, for real
							addShaderToCamera('camGame', new VCRDistortionEffect(0.1, true, true, true));
							addShaderToCamera('camHUD', new VCRDistortionEffect(0.1, true, true, true));
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
							addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
							addShaderToCamera('hud', new GreyscaleEffect());
							addShaderToCamera('game', new GreyscaleEffect());
						}
				
			case 'Studio':
				/*if(SONG.song == 'Delusional')
				{
					GameOverSubstate.deathSoundName = 'fnf_loss_sfx-satan';
					GameOverSubstate.loopSoundName = 'gameOver-satan';
					GameOverSubstate.endSoundName = 'gameOverEnd-satan';
					GameOverSubstate.characterName = 'bf-demon';
				}else{
					GameOverSubstate.deathSoundName = 'fnf_loss_sfx-mickey';
					GameOverSubstate.loopSoundName = 'gameOver-mickey';
					GameOverSubstate.endSoundName = 'gameOverEnd-mickey';
					GameOverSubstate.characterName = 'bf-fake-dead';
				}*/

				var studioBG:BGSprite = new BGSprite('funkinAVI/episode1/streetNEW/bg', -400, -300);
				studioBG.scale.set(1.2, 1.2);
				add(studioBG);

				var streetNEW:BGSprite = new BGSprite('funkinAVI/episode1/streetNEW/street', -400, -300);
				streetNEW.scale.set(1.2, 1.2);
				add(streetNEW);

				vignetteCam = new BGSprite('funkinAVI/episode1/streetNEW/vignetteOverlay', -400, -300, 0, 0);
				vignetteCam.cameras = [camHUD];

				depression = new BGSprite('funkinAVI/episode1/streetNEW/rain', -400, -300, 1.2, 1.2, ['Symbol 8 instance 1'], true);
				depression.scale.set(1.6, 1.6);
				depression.alpha = 0;

				if(canaddshaders)
				{
					//Epic Shaders Let's GOOOOOOOOO
					
					addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
					addShaderToCamera('game', new VhsEffect(0.3, 0));
					addShaderToCamera('hud', new TiltshiftEffect(0.25, 0));
					addShaderToCamera('game', new TiltshiftEffect(0.3, 0));
					if(!ClientPrefs.optimization) {
					addShaderToCamera('hud', new ChromaticAberrationEffect(0.0015));
					addShaderToCamera('game', new ChromaticAberrationEffect(0.003));
					addShaderToCamera('game', new WIBloomEffect(14));
				}
				addShaderToCamera('hud', new GreyscaleEffect());
				addShaderToCamera('game', new GreyscaleEffect());
				}

				/*
				if(canaddshaders){
					addShaderToCamera('game', new BrightEffect());
				}
				*/

			case 'Office':
				//GameOverSubstate.deathSoundName = 'fnf_loss_sfx-smile';
				//GameOverSubstate.loopSoundName = 'gameOver-smile';
				//GameOverSubstate.endSoundName = 'gameOverEnd-smile';
				//GameOverSubstate.characterName = 'bf-smile-dead';

				var office:BGSprite = new BGSprite('funkinAVI/mrSmile/office', 0, 0);
				add(office);

				light = new BGSprite('funkinAVI/mrSmile/officeLight', 0, 0);
				light.blend = ADD;
				light.alpha = 0.55;

				if(canaddshaders)
				{
					//Epic Shaders Let's GOOOOOOOOO
					addShaderToCamera('hud', new VCRDistortionEffect(0.05, true, true, true));
					addShaderToCamera('game', new ChromaticAberrationEffect(0.004));
					addShaderToCamera('hud', new ChromaticAberrationEffect(0.006));
					addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
					addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
					addShaderToCamera('hud', new GreyscaleEffect());
					addShaderToCamera('game', new GreyscaleEffect());
				}

			case 'PixelWorld':
				//GameOverSubstate.deathSoundName = 'fnf_loss_sfx-square';
				//GameOverSubstate.loopSoundName = 'gameOver-square';
				//GameOverSubstate.endSoundName = 'gameOverEnd-square';
				//GameOverSubstate.characterName = 'bf-square-dead';
				
				var square:BGSprite = new BGSprite('funkinAVI/SQUAREBOILOL/PixelMouse', -984, -975);
				add(square);

				//var particles = new FlxTypedGroup<FlxEmitter>();

				for (i in 1...4) {
				    mickParticles = new FlxEmitter(-2080.5, 650.4);
                    mickParticles.launchMode = FlxEmitterMode.SQUARE;
					mickParticles.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
                    mickParticles.scale.set(4, 4, 4, 4, 0, 0, 0, 0);
                    mickParticles.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
                    mickParticles.width = 4787.45;
                    mickParticles.alpha.set(1, 1);
					mickParticles.lifespan.set(1.9, 4.9);
                    mickParticles.loadParticles(Paths.image('funkinAVI/SQUAREBOILOL/mickParticle' + i), 500, 16, true);
					mickParticles.start(false, FlxG.random.float(.51, .50), 1000000);
					add(mickParticles);

					mickParticles.cameras = [camHUD];
				}

					greyParticles = new FlxEmitter(-2080.5, 650.4);
                    greyParticles.launchMode = FlxEmitterMode.SQUARE;
                    greyParticles.velocity.set(-50, -200, 50, -600, -90, 0, 90, -600);
                    greyParticles.scale.set(4, 4, 4, 4, 0, 0, 0, 0);
                    greyParticles.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
                    greyParticles.width = 4787.45;
                    greyParticles.alpha.set(1, 1);
                    greyParticles.lifespan.set(1.9, 4.9);
                    greyParticles.loadParticles(Paths.image('funkinAVI/SQUAREBOILOL/greyParticle'), 500, 16, true);
						greyParticles.start(false, FlxG.random.float(.0521, .1060), 1000000);
						add(greyParticles);

					blackParticles = new FlxEmitter(-2080.5, 1512.4);
                    blackParticles.launchMode = FlxEmitterMode.SQUARE;
                    blackParticles.velocity.set(-70, -220, 70, -620, -110, 20, 110, -620);
                    blackParticles.scale.set(6, 6, 6, 6, 2, 2, 2, 2);
                    blackParticles.drag.set(2, 2, 2, 2, 7, 7, 12, 12);
                    blackParticles.width = 4787.45;
                    blackParticles.alpha.set(1, 1);
                    blackParticles.lifespan.set(1.9, 4.9);
                    blackParticles.loadParticles(Paths.image('funkinAVI/SQUAREBOILOL/particleBlack'), 500, 16, true);

			case 'Forest':
				//GameOverSubstate.deathSoundName = 'fnf_loss_sfx-goof';
				//GameOverSubstate.loopSoundName = 'gameOver-goof';
				//GameOverSubstate.endSoundName = 'gameOverEnd-goof';
				//GameOverSubstate.characterName = 'bf-goof-dead';

				var forest:BGSprite = new BGSprite('funkinAVI/goofy/forest', 0, 0);
				add(forest);

				if(canaddshaders)
				{
					//Epic Shaders Let's GOOOOOOOOO
					addShaderToCamera('hud', new VCRDistortionEffect(0.05, true, true, true));
					addShaderToCamera('game', new ChromaticAberrationEffect(0.004));
					addShaderToCamera('hud', new ChromaticAberrationEffect(0.006));
					addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
					addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
					addShaderToCamera('hud', new GreyscaleEffect());
					addShaderToCamera('game', new GreyscaleEffect());
				}

			case 'ForestNEW':
				//GameOverSubstate.deathSoundName = 'fnf_loss_sfx-goof';
				//GameOverSubstate.loopSoundName = 'gameOver-goof';
				//GameOverSubstate.endSoundName = 'gameOverEnd-goof';
				//GameOverSubstate.characterName = 'bf-goof-dead';

				var goofyBG:BGSprite = new BGSprite('funkinAVI/goofyNEW/bg', -600, -650, 0.7, 0.7);
				goofyBG.scale.set(1.2, 1.2);
				add(goofyBG);

				var treesBack:BGSprite = new BGSprite('funkinAVI/goofyNEW/treesBack', -600, -800, 0.8, 0.8);
				treesBack.scale.set(1.2, 1.2);
				add(treesBack);

				var goofyStreet:BGSprite = new BGSprite('funkinAVI/goofyNEW/ground', -700, -1330);
				goofyStreet.scale.set(1.5, 1.9);
				add(goofyStreet);

				treesFront = new BGSprite('funkinAVI/goofyNEW/treesFront', -550, -850, 1.2, 1.2);
				treesFront.scale.set(1.5, 1.5);

				if(canaddshaders)
				{
					//Epic Shaders Let's GOOOOOOOOO
					addShaderToCamera('hud', new ChromaticAberrationEffect(0.003));
					addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
					addShaderToCamera('game', new VhsEffect(0.3, 0));
					addShaderToCamera('hud', new TiltshiftEffect(0.3, 0));
					addShaderToCamera('game', new TiltshiftEffect(0.4, 0));
					addShaderToCamera('hud', new GreyscaleEffect());
					addShaderToCamera('game', new GreyscaleEffect());
				}

			case 'WaltStage':
				//GameOverSubstate.deathSoundName = 'fnf_loss_sfx-walt';
				//GameOverSubstate.loopSoundName = 'gameOver-walt';
				//GameOverSubstate.endSoundName = 'gameOverEnd-walt';
				//GameOverSubstate.characterName = 'bf-walt-dead';

				var waltStage:BGSprite = new BGSprite('funkinAVI/walt/walt-bg', -339, -106);
				add(waltStage);

				if(canaddshaders)
				{
					addShaderToCamera('game', new VhsEffect(0.5, 0));
					addShaderToCamera('game', new VCRDistortionEffect(0, true, true, true));
					addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
					addShaderToCamera('hud', new VCRDistortionEffect(0, true, true, true));
					addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
					addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
				}

			case 'Line':
				//GameOverSubstate.deathSoundName = 'fnf_loss_sfx-crossin';
				//GameOverSubstate.loopSoundName = 'gameOver-crossin';
				//GameOverSubstate.endSoundName = 'gameOverEnd-crossin';
				//GameOverSubstate.characterName = 'bf-crossin-dead';

				var funiLine:BGSprite = new BGSprite('funkinAVI/DontCross/theLine', 0, 0);
				funiLine.scale.set(1.3, 1.3);
				add(funiLine);

			case 'RelapseStage':
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-relapsed';

				relapseCalm = new BGSprite('funkinAVI/relapse/relapse1', 0, 0, 1, 1, ['Bg bg'], true);
				relapseCalm.scale.set(5.9, 5.9);
				relapseCalm.antialiasing = false;
				add(relapseCalm);

				relapseChaos = new BGSprite('funkinAVI/relapse/relapse2', 0, 0);
				relapseChaos.scale.set(5.9, 5.9);
				relapseChaos.antialiasing = false;
				relapseChaos.alpha = 0;
				add(relapseChaos);

				if(canaddshaders)
				{
					addShaderToCamera('game', new VhsEffect(0.4, 0.3));
					addShaderToCamera('game', new VCRDistortionEffect(0, true, true, true));
					addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
					addShaderToCamera('hud', new VCRDistortionEffect(0, true, true, true));
					addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
					addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
				}

			case 'Couch':
				//GameOverSubstate.deathSoundName = 'funkinAVI/gameOver/CouchSexGameOverTheme';
				GameOverSubstate.loopSoundName = 'funkinAVI/gameOver/CouchSexGameOverTheme';
				//GameOverSubstate.endSoundName = 'gameOverEnd-crossin';
				//GameOverSubstate.characterName = 'bf-crossin-dead';

				//Placeholder BG
				var whiteBGShit:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 8), Std.int(FlxG.height * 8), FlxColor.WHITE);
				add(whiteBGShit);

				aviMick = new FlxSprite(0, -150);
				aviMick.frames = Paths.getSparrowAtlas('funkinAVI/Couch/AVIMouseCouchFNF');
				aviMick.animation.addByPrefix('idle', 'FunkMouseIDLE', 24, true);
				aviMick.animation.addByPrefix('AVILeft', 'FunkMouseLEFT', 24, true);
				aviMick.animation.addByPrefix('AVIDown', 'FunkMouseDOWN', 24, true);
				aviMick.animation.addByPrefix('AVIUp', 'FunkMouseUP', 24, true);
				aviMick.animation.addByPrefix('AVIRight', 'FunkMouseRIGHT', 24, true);
				aviMick.animation.play('idle');
				aviMick.scrollFactor.set(0.9, 0.9);

				cogMick = new FlxSprite(500, -150);
				cogMick.frames = Paths.getSparrowAtlas('funkinAVI/Couch/CogMouseCouch');
				cogMick.animation.addByPrefix('idle', 'CogMickIDLE', 24, true);
				cogMick.animation.addByPrefix('CogLeft', 'CogMickLEFT', 24, false);
				cogMick.animation.addByPrefix('CogDown', 'CogMickDOWN', 24, false);
				cogMick.animation.addByPrefix('CogUp', 'CogMickUP', 24, false);
				cogMick.animation.addByPrefix('CogRight', 'CogMickRIGHT', 24, false);
				cogMick.animation.play('idle');
				cogMick.scrollFactor.set(0.9, 0.9);				

				WIMick = new FlxSprite(1100, -150);
				WIMick.frames = Paths.getSparrowAtlas('funkinAVI/Couch/WenMickCouch');
				WIMick.animation.addByPrefix('idle', 'WenMouseIDLE', 24, true);
				WIMick.animation.addByPrefix('WILeft', 'WenMouseLEFT', 24, false);
				WIMick.animation.addByPrefix('WIDown', 'WenMouseDOWN', 24, false);
				WIMick.animation.addByPrefix('WIUp', 'WenMouseUP', 24, false);
				WIMick.animation.addByPrefix('WIRight', 'WenMouseRIGHT', 24, false);
				WIMick.animation.play('idle');
				WIMick.scrollFactor.set(0.9, 0.9);				

				randyMick = new FlxSprite(-400, -150);
				randyMick.frames = Paths.getSparrowAtlas('funkinAVI/Couch/RandyCouch');
				randyMick.animation.addByPrefix('idle', 'SMILEmouseIDLE', 24, true);
				randyMick.animation.addByPrefix('randyLeft', 'SMILEmouseLEFT', 24, false);
				randyMick.animation.addByPrefix('randyDown', 'SMILEmouseDOWN', 24, false);
				randyMick.animation.addByPrefix('randyUp', 'SMILEmouseUP', 24, false);
				randyMick.animation.addByPrefix('randyRight', 'SMILEmouseRIGHT', 24, false);
				randyMick.animation.play('idle');
				randyMick.scrollFactor.set(0.9, 0.9);				

				rookieMick = new FlxSprite(1500, -180);
				rookieMick.frames = Paths.getSparrowAtlas('funkinAVI/Couch/RookieCouch');
				rookieMick.animation.addByPrefix('idle', 'VSMouseIDLE', 24, true);
				rookieMick.animation.addByPrefix('rookieLeft', 'VSMouseLEFT', 24, false);
				rookieMick.animation.addByPrefix('rookieDown', 'VSMouseDOWN', 24, false);
				rookieMick.animation.addByPrefix('rookieUp', 'VSMouseUP', 24, false);
				rookieMick.animation.addByPrefix('rookieRight', 'VSMouseRIGHT', 24, false);
				rookieMick.animation.play('idle');
				rookieMick.scrollFactor.set(0.9, 0.9);	

				//Scale Shit
				cogMick.scale.set(1.3, 1.3);
				WIMick.scale.set(1.3, 1.3);
				randyMick.scale.set(1.3, 1.3);
				rookieMick.scale.set(1.3, 1.3);	
				aviMick.scale.set(1.3, 1.3);

				//layering the fucking mouses
				add(WIMick);
				add(cogMick);
				add(aviMick);
				add(randyMick);
				add(rookieMick);

				var couch:BGSprite = new BGSprite('funkinAVI/Couch/Couch', -660, -100);
				add(couch);

				snsMickDed = new BGSprite('funkinAVI/Couch/SNSMickeyDieded', 1270, 680, 1.1, 1.1);
				//for the love of god, why?

			case 'rs':

				rsTV = new BGSprite('funkinAVI/rs/white', -560, -340, 0.9, 0.9, ['white idle'], true);
				rsTV.scale.set(0.9, 0.9);
				rsTV.visible = false;
				add(rsTV);

				gradientBar = FlxGradient.createGradientFlxSprite(2130, 512, [0x00940606, 0x55BF0606, 0xAAFC0505], 1, 90, true);
				gradientBar.x = -740;
				gradientBar.y = 770;
				gradientBar.scale.y = 0;
				gradientBar.updateHitbox();
				add(gradientBar);

				if(canaddshaders)
				{
					addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
					addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
					addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
					addShaderToCamera('game', new VhsEffect(0.3, 0));
				}

			case 'Vault':
				vault = new BGSprite('funkinAVI/vault/vault');
				vault.scale.set(1.4, 1.4);
				add(vault);

				chains = new BGSprite('funkinAVI/vault/chains', 0, 0, 1.13, 1.13);
				chains.scale.set(1.4, 1.4);
				
				vaultSpook = new BGSprite('funkinAVI/vault/holyshitdarkness');
				vaultSpook.scale.set(1.4, 1.4);

				vaultINVERT = new BGSprite('funkinAVI/vault/vaultWhite');
				vaultINVERT.scale.set(1.4, 1.4);
				vaultINVERT.alpha = 0;
				add(vaultINVERT);

				chainsINVERT = new BGSprite('funkinAVI/vault/chainsWhite', 0, 0, 1.13, 1.13);
				chainsINVERT.scale.set(1.4, 1.4);
				chainsINVERT.alpha = 0;
				
				vaultSpookINVERT = new BGSprite('funkinAVI/vault/holyshititstoobright');
				vaultSpookINVERT.scale.set(1.4, 1.4);
				vaultSpookINVERT.alpha = 0;

				
			case 'tank': //Week 7 - Ugh, Guns, Stress
				var sky:BGSprite = new BGSprite('tankSky', -400, -400, 0, 0);
				add(sky);

				if(!ClientPrefs.lowQuality)
				{
					var clouds:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
					clouds.active = true;
					clouds.velocity.x = FlxG.random.float(5, 15);
					add(clouds);

					var mountains:BGSprite = new BGSprite('tankMountains', -300, -20, 0.2, 0.2);
					mountains.setGraphicSize(Std.int(1.2 * mountains.width));
					mountains.updateHitbox();
					add(mountains);

					var buildings:BGSprite = new BGSprite('tankBuildings', -200, 0, 0.3, 0.3);
					buildings.setGraphicSize(Std.int(1.1 * buildings.width));
					buildings.updateHitbox();
					add(buildings);
				}

				var ruins:BGSprite = new BGSprite('tankRuins',-200,0,.35,.35);
				ruins.setGraphicSize(Std.int(1.1 * ruins.width));
				ruins.updateHitbox();
				add(ruins);

				if(!ClientPrefs.lowQuality)
				{
					var smokeLeft:BGSprite = new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
					add(smokeLeft);
					var smokeRight:BGSprite = new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
					add(smokeRight);

					tankWatchtower = new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
					add(tankWatchtower);
				}

				tankGround = new BGSprite('tankRolling', 300, 300, 0.5, 0.5,['BG tank w lighting'], true);
				add(tankGround);

				tankmanRun = new FlxTypedGroup<TankmenBG>();
				add(tankmanRun);

				var ground:BGSprite = new BGSprite('tankGround', -420, -150);
				ground.setGraphicSize(Std.int(1.15 * ground.width));
				ground.updateHitbox();
				add(ground);
				moveTank();

				foregroundSprites = new FlxTypedGroup<BGSprite>();
				foregroundSprites.add(new BGSprite('tank0', -500, 650, 1.7, 1.5, ['fg']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank1', -300, 750, 2, 0.2, ['fg']));
				foregroundSprites.add(new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']));
				foregroundSprites.add(new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']));
		}

		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'stress':
				GameOverSubstate.characterName = 'bf-holding-gf-dead';
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		whiteFlashBG = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 1), Std.int(FlxG.height * 1), FlxColor.WHITE);
		whiteFlashBG.blend = ADD;
		whiteFlashBG.alpha = 0;
		whiteFlashBG.scale.set(5, 5);
		add(whiteFlashBG);


		add(gfGroup); //Needed for blammed lights

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		if(curStage == 'Line')
		{
			add(boyfriendGroup);
			add(dadGroup);
		}else{
			add(dadGroup);
			add(boyfriendGroup);
		}
		
		
		switch(curStage)
		{
			case 'Studio':
				add(depression);
				add(vignetteCam);
			case 'spooky':
				add(halloweenWhite);
			case 'Vault':
				add(chains);
				add(vaultSpook);
				add(chainsINVERT);
				add(vaultSpookINVERT);
			case 'PixelWorld':
					blackParticles.start(false, FlxG.random.float(.0368, .0841), 1000000);
					add(blackParticles);
			case 'tank':
				add(foregroundSprites);
			case 'Office':
				add(light);
			case 'ForestNEW':
				add(treesFront);
			case 'Couch':
				add(snsMickDed);
		}
		

		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush) 
			luaArray.push(new FunkinLua(luaFile));
		#end

		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				case 'tank':
					gfVersion = 'gf-tankmen';
				default:
					gfVersion = 'gf';
			}

			switch(Paths.formatToSongPath(SONG.song))
			{
				case 'stress':
					gfVersion = 'pico-speaker';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);

			if(gfVersion == 'pico-speaker')
			{
				if(!ClientPrefs.lowQuality)
				{
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					firstTank.resetShit(20, 600, true);
					firstTank.strumTime = 10;
					tankmanRun.add(firstTank);
	
					for (i in 0...TankmenBG.animationNotes.length)
					{
						if(FlxG.random.bool(16)) {
							var tankBih = tankmanRun.recycle(TankmenBG);
							tankBih.strumTime = TankmenBG.animationNotes[i][0];
							tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
							tankmanRun.add(tankBih);
						}
					}
				}
			}
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);
		
		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);
		
		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}

		switch(curStage)
		{
			case 'limo':
				resetFastCar();
				insert(members.indexOf(gfGroup) - 1, fastCar);
			
			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				insert(members.indexOf(dadGroup) - 1, evilTrail);
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000 / Conductor.songPosition; //no way idfk

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		laneunderlayOpponent = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlayOpponent.alpha = ClientPrefs.laneTransparency;
		laneunderlayOpponent.color = FlxColor.BLACK;
		laneunderlayOpponent.scrollFactor.set();

		laneunderlay = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlay.alpha = ClientPrefs.laneTransparency;
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();
	
        blackFadeThing = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		blackFadeThing.alpha = 0;
		blackFadeThing.screenCenter(X);
		blackFadeThing.screenCenter(Y);
        add(blackFadeThing);

		if (ClientPrefs.laneunderlay)
		{
			add(laneunderlay);
			add(laneunderlayOpponent);
			if(ClientPrefs.middleScroll)
			{
				remove(laneunderlayOpponent);
				laneunderlayOpponent.visible = false;
			}
		}

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		for (event in eventPushedMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection(0);

		switch(hudStyle)
		{
			case 'Psych':
				var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
				timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
				if (!isPixelStage) {
					switch(curStage)
					{
						case 'EndlessLoop' | 'Forest' | 'Office' | 'Studio' | 'ForestNEW' | 'LegacyLoop': 
							timeTxt.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						case 'PixelWorld':
							timeTxt.setFormat(Paths.font("Retro Gaming.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						default:
							timeTxt.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					}
				} else {
						timeTxt.setFormat(Paths.font("Retro Gaming.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				}
				timeTxt.scrollFactor.set();
				timeTxt.alpha = 0;
				timeTxt.borderSize = 2;

				if(ClientPrefs.mechanics)
				{
					if(curStage == 'WaltStage')
					{
						timeTxt.visible = false;
					}else{
						timeTxt.visible = showTime;
					}	
				}else{
					timeTxt.visible = showTime;
				}
				
				if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

				if(ClientPrefs.timeBarType == 'Song Name')
				{
					timeTxt.text = SONG.song;
				}
				updateTime = showTime;

				timeBarBG = new AttachedSprite('timeBar');
				timeBarBG.x = timeTxt.x;
				timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
				timeBarBG.scrollFactor.set();
				timeBarBG.alpha = 0;
				if(ClientPrefs.mechanics)
				{
					if(curStage == 'WaltStage')
					{
						timeBarBG.visible = false;
					}else{
						timeBarBG.visible = showTime;
					}
				}else{
					timeBarBG.visible = showTime;
				}
				
				
				timeBarBG.color = FlxColor.BLACK;
				timeBarBG.xAdd = -4;
				timeBarBG.yAdd = -4;
				add(timeBarBG);

				timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
					'songPercent', 0, 1);
				timeBar.scrollFactor.set();
				switch(SONG.song)
				{
					case 'Bless':
						timeBar.createFilledBar(0xFFFF0000, 0xFFFFF200);
					case 'Scrapped':
						timeBar.createFilledBar(0xFF0008FF, 0xFF11C700);
					case 'Sink':
						timeBar.createFilledBar(0xFF630000, 0xFFD70000);
					case 'Invincible':
						timeBar.createFilledBar(0xFF000000, 0xFF52627D);
					case 'Neglection':
						timeBar.createFilledBar(0xFF0088FF, 0xFFFFFFFF);
					case 'Infitrigger':
						timeBar.createFilledBar(0xFFFFFFFF, 0xFFD400FF);
					case 'Mercy':
						timeBar.createFilledBar(0xFFC78800, 0xFFFFF4BA);
					default:
						timeBar.createFilledBar(0xFF2E2E2E, 0xFFB7B7B7);
				}
				timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
				timeBar.alpha = 0;
				if(ClientPrefs.mechanics)
				{
					if(curStage == 'WaltStage')
					{
						timeBar.visible = false;
					}else{
						timeBar.visible = showTime;
					}	
				}else{
					timeBar.visible = showTime;
				}
				add(timeBar);
				add(timeTxt);
				timeBarBG.sprTracker = timeBar;

				if(ClientPrefs.timeBarType == 'Song Name')
				{
					timeTxt.size = 24;
					timeTxt.y += 3;
				}
				
			case 'Vanilla':
				var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
				timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
				if (!isPixelStage) {
					switch(curStage)
					{
						case 'EndlessLoop' | 'Forest' | 'Office' | 'Studio' | 'ForestNEW' | 'LegacyLoop': 
							timeTxt.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						case 'PixelWorld':
							timeTxt.setFormat(Paths.font("Retro Gaming.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						default:
							timeTxt.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					}
				} else {
						timeTxt.setFormat(Paths.font("Retro Gaming.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				}
				timeTxt.scrollFactor.set();
				timeTxt.alpha = 0;
				timeTxt.borderSize = 2;

				if(ClientPrefs.mechanics)
				{
					if(curStage == 'WaltStage')
					{
						timeTxt.visible = false;
					}else{
						timeTxt.visible = showTime;
					}	
				}else{
					timeTxt.visible = showTime;
				}
				
				if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

				if(ClientPrefs.timeBarType == 'Song Name')
				{
					timeTxt.text = SONG.song;
				}
				updateTime = showTime;

				timeBarBG = new AttachedSprite('timeBar');
				timeBarBG.x = timeTxt.x;
				timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
				timeBarBG.scrollFactor.set();
				timeBarBG.alpha = 0;
				if(ClientPrefs.mechanics)
				{
					if(curStage == 'WaltStage')
					{
						timeBarBG.visible = false;
					}else{
						timeBarBG.visible = showTime;
					}
				}else{
					timeBarBG.visible = showTime;
				}
				
				
				timeBarBG.color = FlxColor.BLACK;
				timeBarBG.xAdd = -4;
				timeBarBG.yAdd = -4;
				add(timeBarBG);

				timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
					'songPercent', 0, 1);
				timeBar.scrollFactor.set();
				timeBar.createFilledBar(0xFF2E2E2E, 0xFFB7B7B7);
				timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
				timeBar.alpha = 0;
				if(ClientPrefs.mechanics)
				{
					if(curStage == 'WaltStage')
					{
						timeBar.visible = false;
					}else{
						timeBar.visible = showTime;
					}	
				}else{
					timeBar.visible = showTime;
				}
				add(timeBar);
				add(timeTxt);
				timeBarBG.sprTracker = timeBar;

				if(ClientPrefs.timeBarType == 'Song Name')
				{
					timeTxt.size = 24;
					timeTxt.y += 3;
				}

				timeBar.visible = false;
				timeBarBG.visible = false;
				timeTxt.visible = false;

			case 'Demolition':
				var showTime:Bool = !ClientPrefs.hideHud;
				if(ClientPrefs.downScroll) timeTxt = new FlxText(450, 70, 400, "", 32); else timeTxt = new FlxText(450, 655, 400, "", 32);
				if (!isPixelStage) {
							timeTxt.setFormat(Paths.font("VanillaExtractRegular.ttf"), 13, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				} else {
						timeTxt.setFormat(Paths.font("m40.ttf"), 9, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				}
				timeTxt.scrollFactor.set();
				timeTxt.alpha = 0;
				timeTxt.borderSize = 2;

				if(ClientPrefs.mechanics)
				{
					if(curStage == 'WaltStage')
					{
						timeTxt.visible = false;
					}else{
						timeTxt.visible = showTime;
					}	
				}else{
					timeTxt.visible = showTime;
				}
				
				//if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

				if(ClientPrefs.timeBarType == 'Song Name')
				{
					timeTxt.text = SONG.song;
				}
				updateTime = showTime;

				timeBarBG = new AttachedSprite('healthBar');
				timeBarBG.x = 600;
				if(ClientPrefs.downScroll) timeBarBG.y = 0.063 * FlxG.height; else timeBarBG.y = 673;
				timeBarBG.scrollFactor.set();
				timeBarBG.alpha = 0;
				if(ClientPrefs.mechanics)
				{
					if(curStage == 'WaltStage')
					{
						timeBarBG.visible = false;
					}else{
						timeBarBG.visible = showTime;
					}
				}else{
					timeBarBG.visible = showTime;
				}
				
				
				timeBarBG.color = FlxColor.BLACK;
				timeBarBG.xAdd = -4;
				timeBarBG.yAdd = -4;
				add(timeBarBG);

				timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, RIGHT_TO_LEFT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
					'songPercent', 0, 1);
				timeBar.scrollFactor.set();
				switch(SONG.song)
				{
					case 'Bless':
						timeBar.createFilledBar(0xFFFF0000, 0xFFFFF200);
					case 'Scrapped':
						timeBar.createFilledBar(0xFF0008FF, 0xFF11C700);
					case 'Sink':
						timeBar.createFilledBar(0xFF630000, 0xFFD70000);
					case 'Invincible':
						timeBar.createFilledBar(0xFF000000, 0xFF52627D);
					case 'Neglection':
						timeBar.createFilledBar(0xFF0088FF, 0xFFE2E2E2);
					case 'Infitrigger':
						timeBar.createFilledBar(0xFFFFFFFF, 0xFFD400FF);
					case 'Mercy':
						timeBar.createFilledBar(0xFFC78800, 0xFFFFF4BA);
					case 'Malfunction':
					if(curBeat % 2 == 0)
						glitchTimeColors = FlxG.random.int(12, 19);

						if(curBeat % 2 == 0) {
 						switch glitchTimeColors
						{

							case 11: timeBar.createFilledBar(0xFF11C700, 0xFFFFF200);

							case 12: timeBar.createFilledBar(0xFF11C700, 0xFF0008FF);

							case 13: timeBar.createFilledBar(0xFF0008FF, 0xFF11C700);

							case 14: timeBar.createFilledBar(0xFFFFF200, 0xFFFF0000);

							case 15: timeBar.createFilledBar(0xFFFF0000, 0xFFFFF200);

							case 16: timeBar.createFilledBar(0xFFC78800, 0xFFFFF4BA);

							case 17: timeBar.createFilledBar(0xFFFFF4BA, 0xFFC78800);

							case 18: timeBar.createFilledBar(0xFF2E2E2E, 0xFFB7B7B7);

							case 19: timeBar.createFilledBar(0xFFB7B7B7, 0xFF2E2E2E);
						}
					}

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							glitchTimeColors = FlxG.random.int(12, 19);
						});

					default:
						timeBar.createFilledBar(0xFF2E2E2E, 0xFFB7B7B7);
				}
				timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
				timeBar.alpha = 0;
				if(ClientPrefs.mechanics)
				{
					if(curStage == 'WaltStage')
					{
						timeBar.visible = false;
					}else{
						timeBar.visible = showTime;
					}	
				}else{
					timeBar.visible = showTime;
				}
				add(timeBar);
				add(timeTxt);
				timeBarBG.sprTracker = timeBar;

				if(ClientPrefs.timeBarType == 'Song Name')
				{
					timeTxt.size = 24;
					timeTxt.y += 3;
				}

				/*timeIcon = new FlxSprite(500, 70).loadGraphic(Paths.image('hudAssets/demolition/time-icon'));
				timeIcon.cameras = [camHUD];
				timeIcon.scale.set(0.3, 0.3);
				timeIcon.scrollFactor.set();
				add(timeIcon);*/ //scrapped, had no use for this HUD

		}

		//no more "Custom Week" on freeplay yay
		if(isStoryMode) {
				if(ClientPrefs.language == "English") 
					Application.current.window.title = "Funkin.avi - " + WeekData.getCurrentWeek().weekName + ": " + PlayState.SONG.song + " - Composed by: " + PlayState.SONG.composer;
				else 
					Application.current.window.title = "Funkin.avi - " + WeekData.getCurrentWeek().weekName + ": " + PlayState.SONG.song + "- Hecho Por " + PlayState.SONG.composer;
			} else {
				if(ClientPrefs.language == "English") 
					Application.current.window.title = "Funkin.avi - " + PlayState.SONG.song + " - Composed by: " + PlayState.SONG.composer;
				else 
					Application.current.window.title = "Funkin.avi - " + PlayState.SONG.song + " - Hecho Por " + PlayState.SONG.composer;
			}

		switch(hudStyle)
		{
			case 'Vanilla' | 'Psych':
				healthBarBG = new AttachedSprite('healthBar');
				healthBarBG.y = FlxG.height * 0.89;
				healthBarBG.screenCenter(X);
				healthBarBG.scrollFactor.set();
				healthBarBG.visible = !ClientPrefs.hideHud;
				healthBarBG.xAdd = -4;
				healthBarBG.yAdd = -4;
				add(healthBarBG);
				if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

				healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
					'health', 0, 2);
				healthBar.scrollFactor.set();
				// healthBar
				healthBar.visible = !ClientPrefs.hideHud;
				healthBar.alpha = ClientPrefs.healthBarAlpha;
				add(healthBar);
				healthBarBG.sprTracker = healthBar;

				iconP1 = new HealthIcon(boyfriend.healthIcon, true);
				iconP1.y = healthBar.y - 75;
				iconP1.visible = !ClientPrefs.hideHud;
				if(ClientPrefs.mechanics)
				{
					if(curStage == 'WaltStage')
					{
						iconP1.visible = false;
					}else{
						iconP1.alpha = ClientPrefs.healthBarAlpha;
					}
				}else{
					iconP1.alpha = ClientPrefs.healthBarAlpha;
				}
				add(iconP1);

				iconP2 = new HealthIcon(dad.healthIcon, false);
				iconP2.y = healthBar.y - 75;
				iconP2.visible = !ClientPrefs.hideHud;
				if(ClientPrefs.mechanics)
				{
					if(curStage == 'WaltStage')
					{
						iconP2.visible = false;
					}else{
						iconP2.alpha = ClientPrefs.healthBarAlpha;
					}
				}else{
					iconP2.alpha = ClientPrefs.healthBarAlpha;
				}
				add(iconP2);
				reloadHealthBarColors();

			case 'Demolition' /*| 'Funkin.avi' | 'Red-Bun'*/:
				healthBarBG = new AttachedSprite('healthBar-Long');
				healthBarBG.y = FlxG.height * 0.95;
				healthBarBG.x = 230;
				healthBarBG.alpha = 0;
				//healthBarBG.screenCenter(X);
				healthBarBG.scrollFactor.set();
				healthBarBG.visible = !ClientPrefs.hideHud;
				healthBarBG.xAdd = -4;
				healthBarBG.yAdd = -4;
				add(healthBarBG);
				if(ClientPrefs.downScroll) healthBarBG.y = 0.05 * FlxG.height;

				healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
					'health', 0, 2);
				healthBar.scrollFactor.set();
				// healthBar
				healthBar.visible = !ClientPrefs.hideHud;
				healthBar.alpha = 0;
				add(healthBar);
				healthBarBG.sprTracker = healthBar;

				iconP1 = new HealthIcon(boyfriend.healthIcon, true);
				iconP1.scale.set(0.78, 0.78);
				iconP1.y = healthBar.y - 75;
				iconP1.alpha = 0;
				iconP1.visible = !ClientPrefs.hideHud;
				if(ClientPrefs.mechanics)
				{
					if(curStage == 'WaltStage')
					{
						iconP1.visible = false;
					}else{
						iconP1.alpha = ClientPrefs.healthBarAlpha;
					}
				}else{
					iconP1.alpha = ClientPrefs.healthBarAlpha;
				}
				add(iconP1);

				iconP2 = new HealthIcon(dad.healthIcon, false);
				iconP2.scale.set(0.78, 0.78);
				iconP2.y = healthBar.y - 75;
				iconP2.alpha = 0;
				iconP2.visible = !ClientPrefs.hideHud;
				if(ClientPrefs.mechanics)
				{
					if(curStage == 'WaltStage')
					{
						iconP2.visible = false;
					}else{
						iconP2.alpha = ClientPrefs.healthBarAlpha;
					}
				}else{
					iconP2.alpha = ClientPrefs.healthBarAlpha;
				}
				add(iconP2);
				reloadHealthBarColors();

				switch(curStage)
				{
					case 'EndlessLoop' | 'Forest' | 'Office' | 'Studio' | 'ForestNEW' | 'LegacyLoop': 
						if(ClientPrefs.downScroll) 
							healthIcon = new FlxSprite(1150, -39).loadGraphic(Paths.image('hudAssets/demolition/health-iconGREYSCALE')); 
						else 
							healthIcon = new FlxSprite(1150, 600).loadGraphic(Paths.image('hudAssets/demolition/health-iconGREYSCALE')); //I had to, looked SOOO out of place when you turn off shaders
					default:
						if(ClientPrefs.downScroll) 
							healthIcon = new FlxSprite(1150, -39).loadGraphic(Paths.image('hudAssets/demolition/health-icon')); 
						else 
							healthIcon = new FlxSprite(1150, 600).loadGraphic(Paths.image('hudAssets/demolition/health-icon'));
				}
				healthIcon.scrollFactor.set();
				healthIcon.scale.set(0.55, 0.55);
				healthIcon.alpha = 0;
				healthIcon.cameras = [camHUD];
				healthIcon.visible = !ClientPrefs.hideHud;
				add(healthIcon);

				if(ClientPrefs.downScroll) healthTxt = new FlxText(1036, 32, 400, "", 32); else healthTxt = new FlxText(1036, 670, 400, "", 32);
				if (!isPixelStage) {
							healthTxt.setFormat(Paths.font("VanillaExtractRegular.ttf"), 19, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				} else {
						healthTxt.setFormat(Paths.font("m40.ttf"), 15, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				}
				healthTxt.scrollFactor.set();
				healthTxt.cameras = [camHUD];
				healthTxt.visible = !ClientPrefs.hideHud;
				//healthTxt.alpha = 0;
				add(healthTxt);

				switch(curStage)
				{
					case 'EndlessLoop' | 'Forest' | 'Office' | 'Studio' | 'ForestNEW' | 'LegacyLoop': 
						if(ClientPrefs.downScroll) 
							missIcon = new FlxSprite(1150, 40).loadGraphic(Paths.image('hudAssets/demolition/miss-iconGREYSCALE')); 
						else
							 missIcon = new FlxSprite(1150, 500).loadGraphic(Paths.image('hudAssets/demolition/miss-iconGREYSCALE'));
					default:
						if(ClientPrefs.downScroll)
						missIcon = new FlxSprite(1150, 40).loadGraphic(Paths.image('hudAssets/demolition/miss-icon')); 
						else 
						missIcon = new FlxSprite(1150, 500).loadGraphic(Paths.image('hudAssets/demolition/miss-icon'));
				}
				missIcon.scrollFactor.set();
				missIcon.scale.set(0.25, 0.25);
				missIcon.cameras = [camHUD];
				missIcon.visible = !ClientPrefs.hideHud;
				add(missIcon);

				if(ClientPrefs.downScroll) 
				missesTxt = new FlxText(800, 120, 400, "", 32); 
				else 
				missesTxt = new FlxText(800, 580, 380, "", 32);
				if (!isPixelStage) {
					missesTxt.setFormat(Paths.font("VanillaExtractRegular.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				} else {
					missesTxt.setFormat(Paths.font("m40.ttf"), 10, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				}
				missesTxt.scrollFactor.set();
				missesTxt.cameras = [camHUD];
				missesTxt.visible = !ClientPrefs.hideHud;
				add(missesTxt);
		}

		switch(hudStyle)
		{
			case 'Psych':
				scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
					if (!isPixelStage) {
					switch(curStage)
					{
						case 'EndlessLoop' | 'Forest' | 'Office' | 'Studio' | 'ForestNEW' | 'LegacyLoop': 
							scoreTxt.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						case 'PixelWorld':
							scoreTxt.setFormat(Paths.font("Retro Gaming.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						default: 
							scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					}
				} else {
						scoreTxt.setFormat(Paths.font("Retro Gaming.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				}
				scoreTxt.scrollFactor.set();
				scoreTxt.borderSize = 1.25;
				if(ClientPrefs.mechanics)
				{
					if(curStage == 'WaltStage')
					{
						scoreTxt.visible = false;
					}else{
						scoreTxt.visible = !ClientPrefs.hideHud;
					}
				}else{
					scoreTxt.visible = !ClientPrefs.hideHud;
				}
				
				add(scoreTxt);

			case 'Vanilla':
				scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30, 0, "", 20);
				scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
				scoreTxt.scrollFactor.set();
				if(ClientPrefs.mechanics)
				{
					if(curStage == 'WaltStage')
					{
						scoreTxt.visible = false;
					}else{
						scoreTxt.visible = !ClientPrefs.hideHud;
					}
				}else{
					scoreTxt.visible = !ClientPrefs.hideHud;
				}
				
				add(scoreTxt);

			case 'Demolition':
				if(ClientPrefs.downScroll)
				{
					scoreTxt = new FlxText(-90, healthBarBG.y + 29, FlxG.width, "", 20);
				}else{
					scoreTxt = new FlxText(-90, healthBarBG.y - 31, FlxG.width, "", 20);
				}
					if (!isPixelStage) {
					
						scoreTxt.setFormat(Paths.font("VanillaExtractRegular.ttf"), 14, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				} else {
						scoreTxt.setFormat(Paths.font("m40.ttf"), 9, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				}
				scoreTxt.scrollFactor.set();
				scoreTxt.borderSize = 1.25;
				if(ClientPrefs.mechanics)
				{
					if(curStage == 'WaltStage')
					{
						scoreTxt.visible = false;
					}else{
						scoreTxt.visible = !ClientPrefs.hideHud;
					}
				}else{
					scoreTxt.visible = !ClientPrefs.hideHud;
				}
				
				add(scoreTxt);
		}

		peWatermark = new FlxText(5, FlxG.height - 29, 0, "", 16);
	        if (!isPixelStage) {
			switch(curStage)
			{
				case 'EndlessLoop' | 'Forest' | 'Office' | 'Studio' | 'ForestNEW' | 'LegacyLoop': 
					peWatermark.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				case 'PixelWorld':
					peWatermark.setFormat(Paths.font("Retro Gaming.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				default: 
					peWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			}
		} else {
                peWatermark.setFormat(Paths.font("Retro Gaming.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		#if desktop
		peWatermark.scrollFactor.set();
		peWatermark.text = "Funkin.avi" + " | " + curSong + " (" + storyDifficultyText + ")";
		peWatermark.visible = ClientPrefs.showWatermarks;
		peWatermark.cameras = [camCustom];
		add(peWatermark);
		#end

		/*SCALEdebugText = new FlxText(10,10,200,"Default scale mode (ratio)");
		SCALEdebugText.scrollFactor.set(0,0);
		SCALEdebugText.cameras = [camCustom];
		//add(SCALEdebugText);*/

		switch(hudStyle)
		{
			case 'Psych':
				botplayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (ClientPrefs.downScroll ? 100 : -100), "", 32);

				switch (FlxG.random.int(1, 7))
				{
					case 1:
						botplayTxt.text = "CHEATER!";
					case 2:
						botplayTxt.text = "HE'S FUNKIN CHEATING";
					case 3:
						botplayTxt.text = "I CAN SEE YOU CHEATING";
					case 4:
						botplayTxt.text = "CHEATING...";
					case 5:
						botplayTxt.text = "Damm bro we should make this easier";
					case 6:
						botplayTxt.text = "Showcase";
					case 7:
						botplayTxt.text = "Go to hell";
					case 8:
						botplayTxt.text = " ";
					case 9:
						botplayTxt.text = " ";
				}
				if (!isPixelStage) {
					switch(curStage)
					{
						case 'EndlessLoop' | 'Forest' | 'Office' | 'Studio' | 'ForestNEW' | 'LegacyLoop': 
							botplayTxt.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						case 'PixelWorld':
							botplayTxt.setFormat(Paths.font("Retro Gaming.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						default: 
							botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					}
				} else {
				botplayTxt.setFormat(Paths.font("Retro Gaming.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				}
				botplayTxt.scrollFactor.set();
				botplayTxt.borderSize = 1.25;
				botplayTxt.visible = cpuControlled;
				add(botplayTxt);
				if(ClientPrefs.downScroll) {
					botplayTxt.y = timeBarBG.y - 78;
				}
				case 'Vanilla':
					botplayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (ClientPrefs.downScroll ? 100 : -100), "", 32);

					switch (FlxG.random.int(1, 7))
					{
						case 1:
							botplayTxt.text = "CHEATER!";
						case 2:
							botplayTxt.text = "HE'S FUNKIN CHEATING";
						case 3:
							botplayTxt.text = "I CAN SEE YOU CHEATING";
						case 4:
							botplayTxt.text = "CHEATING...";
						case 5:
							botplayTxt.text = "Damm bro we should make this easier";
						case 6:
							botplayTxt.text = "Showcase";
						case 7:
							botplayTxt.text = "Go to hell";
						case 8:
							botplayTxt.text = " ";
						case 9:
							botplayTxt.text = " ";
					}
								botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					botplayTxt.scrollFactor.set();
					botplayTxt.borderSize = 1.25;
					botplayTxt.visible = cpuControlled;
					add(botplayTxt);
					if(ClientPrefs.downScroll) {
						botplayTxt.y = timeBarBG.y - 78;
					}
				case 'Demolition':
					botplayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (ClientPrefs.downScroll ? 100 : -100), "", 32);

					switch (FlxG.random.int(1, 7))
					{
						case 1:
							botplayTxt.text = "CHEATER!";
						case 2:
							botplayTxt.text = "HE'S FUNKIN CHEATING";
						case 3:
							botplayTxt.text = "I CAN SEE YOU CHEATING";
						case 4:
							botplayTxt.text = "CHEATING...";
						case 5:
							botplayTxt.text = "Damm bro we should make this easier";
						case 6:
							botplayTxt.text = "Showcase";
						case 7:
							botplayTxt.text = "Go to hell";
						case 8:
							botplayTxt.text = " ";
						case 9:
							botplayTxt.text = " ";
					}
					if (!isPixelStage) {
						switch(curStage)
						{
							case 'EndlessLoop' | 'Forest' | 'Office' | 'Studio' | 'ForestNEW' | 'LegacyLoop': 
								botplayTxt.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
							case 'PixelWorld':
								botplayTxt.setFormat(Paths.font("Retro Gaming.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
							default: 
								botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						}
					} else {
					botplayTxt.setFormat(Paths.font("Retro Gaming.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					}
					botplayTxt.scrollFactor.set();
					botplayTxt.borderSize = 1.25;
					botplayTxt.visible = cpuControlled;
					add(botplayTxt);
					if(ClientPrefs.downScroll) {
						botplayTxt.y = timeBarBG.y - 78;
					}
		}

	        if(!ClientPrefs.hideJudgement) {
			switch(hudStyle)
			{
				case 'Psych':
					judgementCounter = new FlxText(20, 0, 0, "", 20);
					if (!isPixelStage) {
					switch(curStage)
					{
						case 'EndlessLoop' | 'Forest' | 'Office' | 'Studio' | 'ForestNEW' | 'LegacyLoop': 
							judgementCounter.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						case 'PixelWorld':
							judgementCounter.setFormat(Paths.font("Retro Gaming.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						default: 
							judgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					}
					} else {
					judgementCounter.setFormat(Paths.font("Retro Gaming.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					}
					judgementCounter.borderSize = 2;
					judgementCounter.borderQuality = 2;
					judgementCounter.scrollFactor.set();
					judgementCounter.cameras = [camHUD];
					judgementCounter.visible = !ClientPrefs.hideHud;
					judgementCounter.screenCenter(Y);
					if (ClientPrefs.marvelouses)
						judgementCounter.text = 'Marvs: ${marvelouses}\nSicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\n';
					else
						judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\n';
					add(judgementCounter);

				case 'Vanilla':
					judgementCounter = new FlxText(20, 0, 0, "", 20);
					if (!isPixelStage) {
					switch(curStage)
					{
						case 'EndlessLoop' | 'Forest' | 'Office' | 'Studio' | 'ForestNEW' | 'LegacyLoop': 
							judgementCounter.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						case 'PixelWorld':
							judgementCounter.setFormat(Paths.font("Retro Gaming.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						default: 
							judgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					}
					} else {
					judgementCounter.setFormat(Paths.font("Retro Gaming.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					}
					judgementCounter.borderSize = 2;
					judgementCounter.borderQuality = 2;
					judgementCounter.scrollFactor.set();
					judgementCounter.cameras = [camHUD];
					judgementCounter.screenCenter(Y);
					if (ClientPrefs.marvelouses)
						judgementCounter.text = 'Marvs: ${marvelouses}\nSicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\n';
					else
						judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\n';
					add(judgementCounter);
					judgementCounter.visible = false;

				case 'Demolition':
					if(!isPixelStage)
					{
						if(ClientPrefs.downScroll) judgementUnderlay = new FlxSprite(910, 0).loadGraphic(Paths.image('hudAssets/demolition/judge-underlay')); else judgementUnderlay = new FlxSprite(890, 0).loadGraphic(Paths.image('hudAssets/demolition/judge-underlay'));
						judgementUnderlay.scrollFactor.set();
						judgementUnderlay.scale.set(0.35, 0.32);
						judgementUnderlay.alpha = 0.45;
						judgementUnderlay.cameras = [camHUD];
						judgementUnderlay.visible = !ClientPrefs.hideHud;
						add(judgementUnderlay);
					}else{
						if(ClientPrefs.downScroll) judgementUnderlay = new FlxSprite(890, 0).loadGraphic(Paths.image('hudAssets/demolition/judge-underlay')); else judgementUnderlay = new FlxSprite(870, 0).loadGraphic(Paths.image('hudAssets/demolition/judge-underlay'));
						judgementUnderlay.scrollFactor.set();
						judgementUnderlay.scale.set(0.37, 0.32);
						judgementUnderlay.alpha = 0.45;
						judgementUnderlay.cameras = [camHUD];
						judgementUnderlay.visible = !ClientPrefs.hideHud;
						add(judgementUnderlay);
					}

					if (!isPixelStage) {
							judgementCounter = new FlxText(1170, 0, 0, "", 20);
							judgementCounter.setFormat(Paths.font("VanillaExtractRegular.ttf"), 17, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					} else {
						judgementCounter = new FlxText(1150, 0, 0, "", 20);
					judgementCounter.setFormat(Paths.font("m40.ttf"), 13, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					}
					judgementCounter.borderSize = 2;
					judgementCounter.borderQuality = 2;
					judgementCounter.scrollFactor.set();
					judgementCounter.cameras = [camHUD];
					judgementCounter.screenCenter(Y);
					judgementCounter.visible = !ClientPrefs.hideHud;
					if (ClientPrefs.marvelouses)
						judgementCounter.text = 'Marvs: ${marvelouses}\nSicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\n';
					else
						judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\n';
					add(judgementCounter);
			}
		}

		if(ClientPrefs.mechanics)
		{
			if(curStage == 'PixelWorld')
			{
				if(ClientPrefs.downScroll)
				{
					crashLives = new FlxText(600, 170, 0, "", 20);
					crashLivesIcon = new FlxSprite(550, 170);
				}else{
					crashLives = new FlxText(600, 500, 0, "", 20);
					crashLivesIcon = new FlxSprite(550, 500);
				}	
					if (!isPixelStage) {
						switch(curStage)
						{
							case 'EndlessLoop' | 'Forest' | 'Office' | 'Studio' | 'ForestNEW': 
								crashLives.setFormat(Paths.font("Retro Gaming.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
							default: 
								crashLives.setFormat(Paths.font("Retro Gaming.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						}
						} else {
						crashLives.setFormat(Paths.font("Retro Gaming.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						}
					crashLives.borderSize = 2;
					crashLives.borderQuality = 2;
					crashLives.scrollFactor.set();
					crashLives.cameras = [camHUD];
					if(ClientPrefs.language == "Spanish") crashLives.text = 'Vidas: ${crashLivesCounter}';
					else crashLives.text = 'Lives: ${crashLivesCounter}';
					add(crashLives);

					crashLivesIcon.frames = Paths.getSparrowAtlas('funkinAVI/uiAndEvents/lives-icon');
					crashLivesIcon.animation.addByPrefix('idle', 'lives-icon idle', 15);
					crashLivesIcon.animation.addByPrefix('OMFG IT GLITCHES', 'lives-icon glitchin', 15);
					crashLivesIcon.animation.play('idle');
					crashLivesIcon.scale.set(2.2, 2.2);
					crashLivesIcon.cameras = [camHUD];
					add(crashLivesIcon);
				}
				

			if(curStage == 'WaltStage')
			{
				waltText = new FlxText(0, 100, 0, "", 30);
				if (!isPixelStage) {
					switch(curStage)
					{
						case 'EndlessLoop' | 'Forest' | 'Office' | 'Studio' | 'ForestNEW': 
							waltText.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 38, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						default: 
							waltText.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					}
					} else {
					waltText.setFormat(Paths.font("Retro Gaming.ttf"), 30, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					}
				waltText.borderSize = 2;
				waltText.borderQuality = 2;
				waltText.scrollFactor.set();
				waltText.cameras = [camHUD];
				if(ClientPrefs.language == "Spanish") waltText.text = 'Spamea ESPACIO Para Ganar Vida';
				else waltText.text = 'Spam SPACE to Regain Health';
				waltText.screenCenter(X); //it's not visible by the song banner
				add(waltText);
				FlxTween.tween(waltText, {alpha: 0}, 1, {ease: FlxEase.quadInOut, startDelay: 7});
			}

			if(curStage == 'RelapseStage')
			{
				holyShitMOVEBITCH = new FlxSprite(0, -400).loadGraphic(Paths.image('funkinAVI/uiAndEvents/ohNoes'));
				holyShitMOVEBITCH.cameras = [camHUD];
				holyShitMOVEBITCH.screenCenter(X);
				holyShitMOVEBITCH.scale.set(0.25, 0.25);
				add(holyShitMOVEBITCH);
				holyShitMOVEBITCH.alpha = 0;

				if(ClientPrefs.language == "English") PRESSSPACEDUMBASS = new FlxText(0, 490, FlxG.width, "Press SPACE to Dodge!", 74);
				else PRESSSPACEDUMBASS = new FlxText(0, 490, FlxG.width, "Presiona ESPACIO para Esquivar!", 74);
				PRESSSPACEDUMBASS.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 50, FlxColor.WHITE, CENTER);
				PRESSSPACEDUMBASS.cameras = [camHUD];
				add(PRESSSPACEDUMBASS);

				FlxTween.tween(PRESSSPACEDUMBASS, {alpha: 0}, 1, {ease: FlxEase.quadInOut, startDelay: 7});
			}
		}

		cutsceneTransitionHelper = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
		add(cutsceneTransitionHelper);
		cutsceneTransitionHelper.scrollFactor.set();
		cutsceneTransitionHelper.alpha = 0;
		
		songBanner = new FlxSprite(0, 0).makeGraphic(999, 136, FlxColor.WHITE);
		songBanner.scrollFactor.set();
		songBanner.visible = !ClientPrefs.hideHud;
		songBanner.blend = ADD;
		songBanner.alpha = 0;
		songBanner.antialiasing = ClientPrefs.globalAntialiasing;
		songBanner.screenCenter(XY);
		add(songBanner);

		if(ClientPrefs.language == "English") songBannerText = new FlxText(0, 0, 600, PlayState.SONG.song + '\n' + "By: " + PlayState.SONG.composer);
		else songBannerText = new FlxText(0, 0, 600, PlayState.SONG.song + '\n' + "Por: " + PlayState.SONG.composer);
		songBannerText.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songBannerText.scrollFactor.set();
		songBannerText.borderSize = 1.25;
		songBannerText.alpha = 0;
		songBannerText.screenCenter(XY);
		songBannerText.visible = !ClientPrefs.hideHud;
		add(songBannerText);

		var filmScratch:BGSprite = new BGSprite('funkinAVI-filters/scratchShit', 0, 0, 1, 1, ['scratch thing 1'], true);
		var filmScratchGame:BGSprite = new BGSprite('funkinAVI-filters/scratchShit', 0, 0, 1, 1, ['scratch thing 1'], true);
		filmScratchGame.alpha = 0.5;

		switch(SONG.song)
		{
			case 'Isolated' | 'Lunacy':
			var isolateIntro:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 1), Std.int(FlxG.height * 1), FlxColor.BLACK);
			isolateIntro.scale.set(10, 10);
			isolateIntro.cameras = [camCustom];
			add(isolateIntro);
			FlxTween.tween(isolateIntro, {alpha: 0}, 5, {ease: FlxEase.quartInOut, startDelay: 5});
		}

		switch(curStage)
		{
			case 'EndlessLoop' | 'Forest' | 'Office' | 'Steamboat' | 'Studio' | 'ForestNEW' | 'LegacyLoop':
				add(filmScratch);
				add(filmScratchGame);
			default:
				//nothing, that's it.
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		laneunderlay.cameras = [camHUD];
		laneunderlayOpponent.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		switch(curStage)
		{
			case 'EndlessLoop' | 'Forest' | 'Office' | 'Steamboat' | 'Studio' | 'ForestNEW' | 'LegacyLoop':
				filmScratch.cameras = [camHUD];
				filmScratchGame.cameras = [camGame];
			default:
				//nothing, that's it.
		}
		blackFadeThing.cameras = [camCustom];
		cutsceneTransitionHelper.cameras = [camCustom];
		songBanner.cameras = [camCustom];
		songBannerText.cameras = [camCustom];
		doof.cameras = [camHUD];

		if(hudStyle == 'Demolition') camHUD.alpha = 0;
		
		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end
		
		var daSong:String = Paths.formatToSongPath(curSong);
		/*if (isStoryMode && !seenCutscene)
		{
			switch (daSong)
			{
				case "isolated":
					startVideo('Episode1_Intro');
					cutsceneTransitionHelper.alpha = 1;
					inCutscene = true;
					if(FlxG.keys.justPressed.SPACE)
					{
						inCutscene = false;
						seenCutscene = true;
						startCountdown();
					}
			}
		} else */if (!seenCutscene) //CUTSCENES ON FREEPLAY
		{
			switch (daSong)
			{
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					whiteScreen.blend = ADD;
					camHUD.visible = false;
					snapCamFollowToPos(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					inCutscene = true;

					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = true;
							remove(whiteScreen);
							startCountdown();
						}
					});
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					if(gf != null) gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);

				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					inCutscene = true;

					FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							remove(blackScreen);
						}
					});
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					snapCamFollowToPos(400, -2050);
					FlxG.camera.focusOn(camFollow);
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});
				case 'senpai' | 'roses' | 'thorns':
					if(daSong == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);

					/*case "malfunction":
						var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});*/

				case 'ugh' | 'guns' | 'stress':
					tankIntro();

				default:
					startCountdown();
			}
			seenCutscene = true;
		}
		else
		{
			startCountdown();
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if(ClientPrefs.pauseMusic != 'None') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');
		}

		#if desktop
		// Updating Discord Rich Presence.
		if(SONG.song == "Don't Cross!")
		{
			DiscordClient.changePresence(detailsText, SONG.song + " (You're Fucked)", iconP2.getCharacter(), true, songLength, curPortrait);
		}else{
			DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength, curPortrait);
		}
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000;
		callOnLuas('onCreatePost', []);
		
		super.create();

		Paths.clearUnusedMemory();

		for (key => type in precacheList)
		{
			//trace('Key $key is type $type');
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}
		CustomFadeTransition.nextCamera = camOther;
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
			for (note in unspawnNotes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	function set_playbackRate(value:Float):Float
		{
			if(generatedMusic)
			{
				if(vocals != null) vocals.pitch = value;
				FlxG.sound.music.pitch = value;
			}
			playbackRate = value;
			FlxAnimationController.globalSpeed = value;
			trace('Anim speed: ' + FlxAnimationController.globalSpeed);
			Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000 * value;
		//	setOnLuas('playbackRate', playbackRate);
			return value;
		}

	public function addTextToDebug(text:String) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup));
		#end
	}

	public function reloadHealthBarColors() {
		if(hudStyle != 'Vanilla')
		{
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		}else{
			healthBar.createFilledBar(FlxColor.RED,
			FlxColor.LIME);
		}
			
		healthBar.updateBar();

	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		
		if(doPush)
		{
			for (lua in luaArray)
			{
				if(lua.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}
		public function addShaderToCamera(cam:String, effect:ShaderEffect)
	{ // STOLE FROM ANDROMEDA
		if(canaddshaders) {
		switch (cam.toLowerCase())
		{
			case 'camhud' | 'hud':
				camHUDShaders.push(effect);
				var newCamEffects:Array<BitmapFilter> = []; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
				for (i in camHUDShaders)
				{
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camHUD.setFilters(newCamEffects);
			case 'camother' | 'other':
				camOtherShaders.push(effect);
				var newCamEffects:Array<BitmapFilter> = []; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
				for (i in camOtherShaders)
				{
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camOther.setFilters(newCamEffects);
			case 'camgame' | 'game':
				camGameShaders.push(effect);
				var newCamEffects:Array<BitmapFilter> = []; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
				for (i in camGameShaders)
				{
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camGame.setFilters(newCamEffects);
			default:
				if (modchartSprites.exists(cam))
				{
					Reflect.setProperty(modchartSprites.get(cam), "shader", effect.shader);
				}
				else if (modchartTexts.exists(cam))
				{
					Reflect.setProperty(modchartTexts.get(cam), "shader", effect.shader);
				}
				else
				{
					var OBJ = Reflect.getProperty(PlayState.instance, cam);
					Reflect.setProperty(OBJ, "shader", effect.shader);
				}
		}
	}
}
	
		public function removeShaderFromCamera(cam:String, effect:ShaderEffect)
	{
		if(canaddshaders) {
		switch (cam.toLowerCase())
		{
			case 'camhud' | 'hud':
				camHUDShaders.remove(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in camHUDShaders)
				{
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camHUD.setFilters(newCamEffects);
			case 'camother' | 'other':
				camOtherShaders.remove(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in camOtherShaders)
				{
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camOther.setFilters(newCamEffects);
			default:
				camGameShaders.remove(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in camGameShaders)
				{
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camGame.setFilters(newCamEffects);
		}
	}
}
	
		public function clearShaderFromCamera(cam:String)
	{
		if(canaddshaders) {
		switch (cam.toLowerCase())
		{
			case 'camhud' | 'hud':
				camHUDShaders = [];
				var newCamEffects:Array<BitmapFilter> = [];
				camHUD.setFilters(newCamEffects);
			case 'camother' | 'other':
				camOtherShaders = [];
				var newCamEffects:Array<BitmapFilter> = [];
				camOther.setFilters(newCamEffects);
			default:
				camGameShaders = [];
				var newCamEffects:Array<BitmapFilter> = [];
				camGame.setFilters(newCamEffects);
		}
	}
}
	
	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String):Void {
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = #if MODS_ALLOWED Paths.modFolders('videos/' + name + '.' + Paths.VIDEO_EXT); #else ''; #end
		#if sys
		if(FileSystem.exists(fileName)) {
			foundFile = true;
		}
		#end

		if(!foundFile) {
			fileName = Paths.video(name);
			#if sys
			if(FileSystem.exists(fileName)) {
			#else
			if(OpenFlAssets.exists(fileName)) {
			#end
				foundFile = true;
			}
		}

		if(foundFile) {
			inCutscene = true;
			var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			bg.cameras = [camHUD];
			add(bg);

			(new FlxVideo(fileName)).finishCallback = function() {
				remove(bg);
				startAndEnd();
			}
			return;
		}
		else
		{
			FlxG.log.warn('Couldnt find video file: ' + fileName);
			startAndEnd();
		}
		#end
		startAndEnd();
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function tankIntro()
	{
		var songName:String = Paths.formatToSongPath(SONG.song);
		dadGroup.alpha = 0.00001;
		camHUD.visible = false;
		//inCutscene = true; //this would stop the camera movement, oops

		var tankman:FlxSprite = new FlxSprite(-20, 320);
		tankman.frames = Paths.getSparrowAtlas('cutscenes/' + songName);
		tankman.antialiasing = ClientPrefs.globalAntialiasing;
		insert(members.indexOf(dadGroup) + 1, tankman);

		var gfDance:FlxSprite = new FlxSprite(gf.x - 107, gf.y + 140);
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		var gfCutscene:FlxSprite = new FlxSprite(gf.x - 104, gf.y + 122);
		gfCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		var picoCutscene:FlxSprite = new FlxSprite(gf.x - 849, gf.y - 264);
		picoCutscene.antialiasing = ClientPrefs.globalAntialiasing;
		var boyfriendCutscene:FlxSprite = new FlxSprite(boyfriend.x + 5, boyfriend.y + 20);
		boyfriendCutscene.antialiasing = ClientPrefs.globalAntialiasing;

		var tankmanEnd:Void->Void = function()
		{
			var timeForStuff:Float = Conductor.crochet / 1000 * 5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			moveCamera(true);
			startCountdown();

			dadGroup.alpha = 1;
			camHUD.visible = true;

			var stuff:Array<FlxSprite> = [tankman, gfDance, gfCutscene, picoCutscene, boyfriendCutscene];
			for (char in stuff)
			{
				char.kill();
				remove(char);
				char.destroy();
			}
			Paths.clearUnusedMemory();
		};

		camFollow.set(dad.x + 280, dad.y + 170);
		switch(songName)
		{
			case 'ugh':
				precacheList.set('wellWellWell', 'sound');
				precacheList.set('killYou', 'sound');
				precacheList.set('bfBeep', 'sound');
				
				var wellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell'));
				FlxG.sound.list.add(wellWellWell);

				FlxG.sound.playMusic(Paths.music('DISTORTO'), 0, false);
				FlxG.sound.music.fadeIn();

				tankman.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
				tankman.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
				tankman.animation.play('wellWell', true);
				FlxG.camera.zoom *= 1.2;

				// Well well well, what do we got here?
				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					wellWellWell.play(true);
				});

				// Move camera to BF
				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					camFollow.x += 800;
					camFollow.y += 100;
					
					// Beep!
					new FlxTimer().start(1.5, function(tmr:FlxTimer)
					{
						boyfriend.playAnim('singUP', true);
						boyfriend.specialAnim = true;
						FlxG.sound.play(Paths.sound('bfBeep'));
					});

					// Move camera to Tankman
					new FlxTimer().start(3, function(tmr:FlxTimer)
					{
						camFollow.x -= 800;
						camFollow.y -= 100;

						tankman.animation.play('killYou', true);
						FlxG.sound.play(Paths.sound('killYou'));
						
						// We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
						new FlxTimer().start(6.1, function(tmr:FlxTimer)
						{
							tankmanEnd();
						});
					});
				});

			case 'guns':
				tankman.x += 40;
				tankman.y += 10;

				var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2'));
				FlxG.sound.list.add(tightBars);

				FlxG.sound.playMusic(Paths.music('DISTORTO'), 0, false);
				FlxG.sound.music.fadeIn();

				new FlxTimer().start(0.01, function(tmr:FlxTimer) //Fixes sync????
				{
					tightBars.play(true);
				});

				tankman.animation.addByPrefix('tightBars', 'TANK TALK 2', 24, false);
				tankman.animation.play('tightBars', true);
				boyfriend.animation.curAnim.finish();

				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 4, {ease: FlxEase.quadInOut});
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2 * 1.2}, 0.5, {ease: FlxEase.quadInOut, startDelay: 4});
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 1, {ease: FlxEase.quadInOut, startDelay: 4.5});
				new FlxTimer().start(4, function(tmr:FlxTimer)
				{
					gf.playAnim('sad', true);
					gf.animation.finishCallback = function(name:String)
					{
						gf.playAnim('sad', true);
					};
				});

				new FlxTimer().start(11.6, function(tmr:FlxTimer)
				{
					tankmanEnd();

					gf.dance();
					gf.animation.finishCallback = null;
				});

			case 'stress':
				tankman.x -= 54;
				tankman.y -= 14;
				gfGroup.alpha = 0.00001;
				boyfriendGroup.alpha = 0.00001;
				camFollow.set(dad.x + 400, dad.y + 170);
				FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.y += 100;
				});
				precacheList.set('cutscenes/stress2', 'image');

				gfDance.frames = Paths.getSparrowAtlas('characters/gfTankmen');
				gfDance.animation.addByPrefix('dance', 'GF Dancing at Gunpoint', 24, true);
				gfDance.animation.play('dance', true);
				insert(members.indexOf(gfGroup) + 1, gfDance);

				gfCutscene.frames = Paths.getSparrowAtlas('cutscenes/stressGF');
				gfCutscene.animation.addByPrefix('dieBitch', 'GF STARTS TO TURN PART 1', 24, false);
				gfCutscene.animation.addByPrefix('getRektLmao', 'GF STARTS TO TURN PART 2', 24, false);
				insert(members.indexOf(gfGroup) + 1, gfCutscene);
				gfCutscene.alpha = 0.00001;

				picoCutscene.frames = AtlasFrameMaker.construct('cutscenes/stressPico');
				picoCutscene.animation.addByPrefix('anim', 'Pico Badass', 24, false);
				insert(members.indexOf(gfGroup) + 1, picoCutscene);
				picoCutscene.alpha = 0.00001;

				boyfriendCutscene.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
				boyfriendCutscene.animation.addByPrefix('idle', 'BF idle dance', 24, false);
				boyfriendCutscene.animation.play('idle', true);
				boyfriendCutscene.animation.curAnim.finish();
				insert(members.indexOf(boyfriendGroup) + 1, boyfriendCutscene);

				var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene'));
				FlxG.sound.list.add(cutsceneSnd);

				tankman.animation.addByPrefix('godEffingDamnIt', 'TANK TALK 3', 24, false);
				tankman.animation.play('godEffingDamnIt', true);

				var calledTimes:Int = 0;
				var zoomBack:Void->Void = function()
				{
					var camPosX:Float = 630;
					var camPosY:Float = 425;
					camFollow.set(camPosX, camPosY);
					camFollowPos.setPosition(camPosX, camPosY);
					FlxG.camera.zoom = 0.8;
					cameraSpeed = 1;

					calledTimes++;
					if (calledTimes > 1)
					{
						foregroundSprites.forEach(function(spr:BGSprite)
						{
							spr.y -= 100;
						});
					}
				}
				
				new FlxTimer().start(0.01, function(tmr:FlxTimer) //Fixes sync????
				{
					cutsceneSnd.play(true);
				});

				new FlxTimer().start(15.2, function(tmr:FlxTimer)
				{
					FlxTween.tween(camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});
					new FlxTimer().start(2.3, function(tmr:FlxTimer)
					{
						zoomBack();
					});
					
					gfDance.visible = false;
					gfCutscene.alpha = 1;
					gfCutscene.animation.play('dieBitch', true);
					gfCutscene.animation.finishCallback = function(name:String)
					{
						if(name == 'dieBitch') //Next part
						{
							gfCutscene.animation.play('getRektLmao', true);
							gfCutscene.offset.set(224, 445);
						}
						else
						{
							gfCutscene.visible = false;
							picoCutscene.alpha = 1;
							picoCutscene.animation.play('anim', true);
							
							boyfriendGroup.alpha = 1;
							boyfriendCutscene.visible = false;
							boyfriend.playAnim('bfCatch', true);
							boyfriend.animation.finishCallback = function(name:String)
							{
								if(name != 'idle')
								{
									boyfriend.playAnim('idle', true);
									boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
								}
							};

							picoCutscene.animation.finishCallback = function(name:String)
							{
								picoCutscene.visible = false;
								gfGroup.alpha = 1;
								picoCutscene.animation.finishCallback = null;
							};
							gfCutscene.animation.finishCallback = null;
						}
					};
				});
				
				new FlxTimer().start(19.5, function(tmr:FlxTimer)
				{
					tankman.frames = Paths.getSparrowAtlas('cutscenes/stress2');
					tankman.animation.addByPrefix('lookWhoItIs', 'TANK TALK 3', 24, false);
					tankman.animation.play('lookWhoItIs', true);
					tankman.x += 90;
					tankman.y += 6;

					new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						camFollow.set(dad.x + 500, dad.y + 170);
					});
				});

				new FlxTimer().start(31.2, function(tmr:FlxTimer)
				{
					boyfriend.playAnim('singUPmiss', true);
					boyfriend.animation.finishCallback = function(name:String)
					{
						if (name == 'singUPmiss')
						{
							boyfriend.playAnim('idle', true);
							boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
						}
					};

					camFollow.set(boyfriend.x + 280, boyfriend.y + 200);
					cameraSpeed = 12;
					FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
					
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						zoomBack();
					});
				});

				new FlxTimer().start(35.5, function(tmr:FlxTimer)
				{
					tankmanEnd();
					boyfriend.animation.finishCallback = null;
				});
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownBeginning:FlxSprite;
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public var introAlts:Array<String>;
	public var antialias:Bool;
	public static var startOnTime:Float = 0;

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if(ret != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			if(SONG.song == "Neglection") {
				if(ClientPrefs.mechanics) {
				for (i in 0...playerStrums.length) {
					playerStrums.members[0].x = 90;
					playerStrums.members[1].x = 190;
					playerStrums.members[2].x = 990;
					playerStrums.members[3].x = 1090;
					opponentStrums.members[0].x = 430;
					opponentStrums.members[1].x = 530;
					opponentStrums.members[2].x = 630;
					opponentStrums.members[3].x = 730;
					opponentStrums.members[i].alpha = 0.5;
				}
			}
			} else {
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			if(ClientPrefs.mechanics)
			{
				if(curStage == 'WaltStage')
				{
					for (i in 0...opponentStrums.length) {
						setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
						setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
						opponentStrums.members[i].visible = false;
					}
				}else{
					for (i in 0...opponentStrums.length) {
						setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
						setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
						// if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
					}
				}
			}else{
				for (i in 0...opponentStrums.length) {
					setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
					setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
					//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
				}
			}
			}
			

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			
			laneunderlay.x = playerStrums.members[0].x - 25;
			if(ClientPrefs.mechanics)
			{
				if(curStage == 'WaltStage')
				{

				}else{
					laneunderlayOpponent.x = opponentStrums.members[0].x - 25;
				}
				
				
				laneunderlay.screenCenter(Y);
				if(curStage == 'WaltStage')
				{

				}else{
					laneunderlayOpponent.screenCenter(Y);
				}
			}else{
				laneunderlayOpponent.x = opponentStrums.members[0].x - 25;
				laneunderlayOpponent.screenCenter(Y);
			}
			
			

			var swagCounter:Int = 0;

			if (skipCountdown || startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 500);
				return;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
				{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				{
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
				{
					dad.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('vintage', ['funkinAVI/intro/3', 'funkinAVI/intro/2', 'funkinAVI/intro/1', 'funkinAVI/intro/Go']);
				introAssets.set('corrupted', ['funkinAVI/intro/3-PixelWorld-pixel', 'funkinAVI/intro/2-PixelWorld-pixel', 'funkinAVI/intro/1-PixelWorld-pixel', 'funkinAVI/intro/Go-PixelWorld-pixel']);
				introAssets.set('vintage-corrupt', ['funkinAVI/intro/3-currupt', 'funkinAVI/intro/2-currupt', 'funkinAVI/intro/1-currupt', 'funkinAVI/intro/Go-currupt',]);
				introAssets.set('relapse', ['funkinAVI/intro/RelapseIntro3-pixel', 'funkinAVI/intro/RelapseIntro2-pixel', 'funkinAVI/intro/RelapseIntro1-pixel', 'funkinAVI/intro/RelapseIntroGo-pixel']);
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				switch (curStage)
				{
					case 'EndlessLoop' | 'Forest' | 'Office' | 'Steamboat' | 'ForestNEW' | 'Studio' | 'WaltStage' | 'LegacyLoop':
						introAlts = introAssets.get('vintage');
						antialias = ClientPrefs.globalAntialiasing;
					default:
						introAlts = introAssets.get('default');
						antialias = ClientPrefs.globalAntialiasing;
				}

				if(isPixelStage) {
					switch (curStage)
					{
						case 'PixelWorld':
						introAlts = introAssets.get('corrupted');
						antialias = false;
						case 'RelapseStage':
						introAlts = introAssets.get('relapse');
						antialias = false;
						default:
						introAlts = introAssets.get('pixel');
						antialias = false;
					}
				}

				// head bopping for bg characters on Mall
				if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);
	
					bottomBoppers.dance(true);
					santa.dance(true);
				}

				switch (PlayState.SONG.song)
				{
					case 'Isolated':
						if (isStoryMode)
						{
							switch (swagCounter)
							{
								case 0:
									FlxTween.tween(cutsceneTransitionHelper, {alpha: 0}, 1, {ease: FlxEase.linear});
								case 1:
									
								case 2:
									
								case 3:
									
								case 4:
							}
						}else{
							switch (swagCounter)
							{
								case 0:
									countdownBeginning = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
									countdownBeginning.scrollFactor.set();
									countdownBeginning.updateHitbox();

									countdownBeginning.screenCenter();
									countdownBeginning.antialiasing = antialias;
									add(countdownBeginning);
									FlxTween.tween(countdownBeginning, {/*y: countdownBeginning.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
										ease: FlxEase.cubeInOut,
										onComplete: function(twn:FlxTween)
										{
											remove(countdownBeginning);
											countdownBeginning.destroy();
										}
									});
									FlxG.sound.play(Paths.sound('funkinAVI/intro/intro3' + introSoundsSuffix), 0.5);
								case 1:
									camGame.zoom = 1.05;
									camHUD.zoom = 1.05;
									FlxTween.tween(camGame, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});
									FlxTween.tween(camHUD, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});
									
									countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
									countdownReady.scrollFactor.set();
									countdownReady.updateHitbox();

									countdownReady.screenCenter();
									countdownReady.antialiasing = antialias;
									add(countdownReady);
									FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
										ease: FlxEase.cubeInOut,
										onComplete: function(twn:FlxTween)
										{
											remove(countdownReady);
											countdownReady.destroy();
										}
									});
									FlxG.sound.play(Paths.sound('funkinAVI/intro/intro2' + introSoundsSuffix), 0.5);
								case 2:
									camGame.zoom = 1.1;
									camHUD.zoom = 1.1;
									FlxTween.tween(camGame, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});
									FlxTween.tween(camHUD, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});

									countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
									countdownSet.scrollFactor.set();

									countdownSet.screenCenter();
									countdownSet.antialiasing = antialias;
									add(countdownSet);
									FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
										ease: FlxEase.cubeInOut,
										onComplete: function(twn:FlxTween)
										{
											remove(countdownSet);
											countdownSet.destroy();
										}
									});
									FlxG.sound.play(Paths.sound('funkinAVI/intro/intro1' + introSoundsSuffix), 0.5);
								case 3:
									camGame.zoom = 1.15;
									camHUD.zoom = 1.15;
									FlxTween.tween(camGame, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});
									FlxTween.tween(camHUD, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});

									countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[3]));
									countdownGo.scrollFactor.set();

									countdownGo.updateHitbox();

									countdownGo.screenCenter();
									countdownGo.antialiasing = antialias;
									add(countdownGo);
									FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
										ease: FlxEase.cubeInOut,
										onComplete: function(twn:FlxTween)
										{
											remove(countdownGo);
											countdownGo.destroy();
										}
									});
									FlxG.sound.play(Paths.sound('funkinAVI/intro/introGo' + introSoundsSuffix), 0.5);
								case 4:
							}
						}
						case 'Cycled Sins':
							switch (swagCounter)
							{
								case 0:
									countdownBeginning = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
									countdownBeginning.scrollFactor.set();
									countdownBeginning.updateHitbox();

									if (PlayState.isPixelStage)
										countdownBeginning.setGraphicSize(Std.int(countdownBeginning.width * daPixelZoom));
	
									countdownBeginning.screenCenter();
									countdownBeginning.antialiasing = antialias;
									add(countdownBeginning);
									FlxTween.tween(countdownBeginning, {y: countdownBeginning.y + 100, alpha: 0}, Conductor.crochet / 1000, {
										ease: FlxEase.cubeInOut,
										onComplete: function(twn:FlxTween)
										{
											remove(countdownBeginning);
											countdownBeginning.destroy();
										}
									});
									FlxG.sound.play(Paths.sound('funkinAVI/intro/Relapse3' + introSoundsSuffix), 1);
								case 1:
									camGame.zoom = 0.85;
									camHUD.zoom = 0.85;
									FlxTween.tween(camGame, {zoom: 0.8}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});
									FlxTween.tween(camHUD, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});
									
									countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
									countdownReady.scrollFactor.set();
									countdownReady.updateHitbox();

									if (PlayState.isPixelStage)
										countdownReady.setGraphicSize(Std.int(countdownBeginning.width * daPixelZoom));
	
									countdownReady.screenCenter();
									countdownReady.antialiasing = antialias;
									add(countdownReady);
									FlxTween.tween(countdownReady, {y: countdownReady.y + 100, alpha: 0}, Conductor.crochet / 1000, {
										ease: FlxEase.cubeInOut,
										onComplete: function(twn:FlxTween)
										{
											remove(countdownReady);
											countdownReady.destroy();
										}
									});
									FlxG.sound.play(Paths.sound('funkinAVI/intro/Relapse2' + introSoundsSuffix), 1);
								case 2:
									camGame.zoom = 0.9;
									camHUD.zoom = 0.9;
									FlxTween.tween(camGame, {zoom: 0.8}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});
									FlxTween.tween(camHUD, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});
	
									countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
									countdownSet.scrollFactor.set();

									if (PlayState.isPixelStage)
										countdownSet.setGraphicSize(Std.int(countdownBeginning.width * daPixelZoom));
	
									countdownSet.screenCenter();
									countdownSet.antialiasing = antialias;
									add(countdownSet);
									FlxTween.tween(countdownSet, {y: countdownSet.y + 100, alpha: 0}, Conductor.crochet / 1000, {
										ease: FlxEase.cubeInOut,
										onComplete: function(twn:FlxTween)
										{
											remove(countdownSet);
											countdownSet.destroy();
										}
									});
									FlxG.sound.play(Paths.sound('funkinAVI/intro/Relapse1' + introSoundsSuffix), 1);
								case 3:
									camGame.zoom = 1;
									camHUD.zoom = 1;
									FlxTween.tween(camGame, {zoom: 0.8}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});
									FlxTween.tween(camHUD, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});
	
									countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[3]));
									countdownGo.scrollFactor.set();
	
									countdownGo.updateHitbox();

									if (PlayState.isPixelStage)
										countdownGo.setGraphicSize(Std.int(countdownBeginning.width * daPixelZoom));
	
									countdownGo.screenCenter();
									countdownGo.antialiasing = antialias;
									add(countdownGo);
									FlxTween.tween(countdownGo, {y: countdownGo.y + 100, alpha: 0}, Conductor.crochet / 1000, {
										ease: FlxEase.cubeInOut,
										onComplete: function(twn:FlxTween)
										{
											remove(countdownGo);
											countdownGo.destroy();
										}
									});
									FlxG.sound.play(Paths.sound('funkinAVI/intro/RelapseGo' + introSoundsSuffix), 1);
								case 4:
							}
					case 'Lunacy' | 'Delusional' | 'Twisted Grins' | 'Hunted' | 'Facade' | 'Isolated Old' | 'Mercy' | 'Isolated Legacy' | 'Lunacy Legacy' | 'Mercy Legacy':
						switch (swagCounter)
						{
							case 0:
								countdownBeginning = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
								countdownBeginning.scrollFactor.set();
								countdownBeginning.updateHitbox();

								countdownBeginning.screenCenter();
								countdownBeginning.antialiasing = antialias;
								add(countdownBeginning);
								FlxTween.tween(countdownBeginning, {/*y: countdownBeginning.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownBeginning);
										countdownBeginning.destroy();
									}
								});
								FlxG.sound.play(Paths.sound('funkinAVI/intro/intro3' + introSoundsSuffix), 0.5);
							case 1:
								camGame.zoom = 1.05;
								camHUD.zoom = 1.05;
								FlxTween.tween(camGame, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});
								FlxTween.tween(camHUD, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});
								
								countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
								countdownReady.scrollFactor.set();
								countdownReady.updateHitbox();

								countdownReady.screenCenter();
								countdownReady.antialiasing = antialias;
								add(countdownReady);
								FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownReady);
										countdownReady.destroy();
									}
								});
								FlxG.sound.play(Paths.sound('funkinAVI/intro/intro2' + introSoundsSuffix), 0.5);
							case 2:
								camGame.zoom = 1.1;
								camHUD.zoom = 1.1;
								FlxTween.tween(camGame, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});
								FlxTween.tween(camHUD, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});

								countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
								countdownSet.scrollFactor.set();

								countdownSet.screenCenter();
								countdownSet.antialiasing = antialias;
								add(countdownSet);
								FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownSet);
										countdownSet.destroy();
									}
								});
								FlxG.sound.play(Paths.sound('funkinAVI/intro/intro1' + introSoundsSuffix), 0.5);
							case 3:
								camGame.zoom = 1.15;
								camHUD.zoom = 1.15;
								FlxTween.tween(camGame, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});
								FlxTween.tween(camHUD, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});

								countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[3]));
								countdownGo.scrollFactor.set();

								countdownGo.updateHitbox();

								countdownGo.screenCenter();
								countdownGo.antialiasing = antialias;
								add(countdownGo);
								FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownGo);
										countdownGo.destroy();
									}
								});
								FlxG.sound.play(Paths.sound('funkinAVI/intro/introGo' + introSoundsSuffix), 0.5);
							case 4:
						}
					case 'Malfunction' | 'Malfunction Legacy':
						switch (swagCounter)
						{
							case 0:
								countdownBeginning = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
								countdownBeginning.scrollFactor.set();

								if (PlayState.isPixelStage)
									countdownBeginning.setGraphicSize(Std.int(countdownBeginning.width * daPixelZoom));

								countdownBeginning.updateHitbox();

								countdownBeginning.screenCenter();
								countdownBeginning.antialiasing = antialias;
								add(countdownBeginning);
								FlxTween.tween(countdownBeginning, {/*y: countdownBeginning.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownBeginning);
										countdownBeginning.destroy();
									}
								});
								FlxG.sound.play(Paths.sound('funkinAVI/intro/intro3CORRUPT' + introSoundsSuffix), 1);
							case 1:
								camGame.zoom = 1.05;
								camHUD.zoom = 1.05;
								FlxTween.tween(camGame, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});
								FlxTween.tween(camHUD, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});
								
								countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
								countdownReady.scrollFactor.set();

								if (PlayState.isPixelStage)
									countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

								countdownReady.updateHitbox();

								countdownReady.screenCenter();
								countdownReady.antialiasing = antialias;
								add(countdownReady);
								FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownReady);
										countdownReady.destroy();
									}
								});
								FlxG.sound.play(Paths.sound('funkinAVI/intro/intro2CORRUPT' + introSoundsSuffix), 1);
							case 2:
								camGame.zoom = 1.1;
								camHUD.zoom = 1.1;
								FlxTween.tween(camGame, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});
								FlxTween.tween(camHUD, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});

								countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
								countdownSet.scrollFactor.set();

								if (PlayState.isPixelStage)
									countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

								countdownSet.updateHitbox();
								countdownSet.screenCenter();
								countdownSet.antialiasing = antialias;
								add(countdownSet);
								FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownSet);
										countdownSet.destroy();
									}
								});
								FlxG.sound.play(Paths.sound('funkinAVI/intro/intro1CORRUPT' + introSoundsSuffix), 0.4);
							case 3:
								camGame.zoom = 1.15;
								camHUD.zoom = 1.15;
								FlxTween.tween(camGame, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});
								FlxTween.tween(camHUD, {zoom: 1}, Conductor.crochet / 2000, {ease: FlxEase.cubeInOut});

								countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[3]));
								countdownGo.scrollFactor.set();

								if (PlayState.isPixelStage)
									countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

								countdownGo.updateHitbox();

								countdownGo.screenCenter();
								countdownGo.antialiasing = antialias;
								add(countdownGo);
								FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownGo);
										countdownGo.destroy();
									}
								});
								FlxG.sound.play(Paths.sound('funkinAVI/intro/introGoCORRUPT' + introSoundsSuffix), 1);
							case 4:
						}
					default:
						switch (swagCounter)
						{
							case 0:
								FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
							case 1:
								countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
								countdownReady.scrollFactor.set();
								countdownReady.updateHitbox();

								if (PlayState.isPixelStage)
									countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

								countdownReady.screenCenter();
								countdownReady.antialiasing = antialias;
								add(countdownReady);
								FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownReady);
										countdownReady.destroy();
									}
								});
								FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
							case 2:
								countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
								countdownSet.scrollFactor.set();

								if (PlayState.isPixelStage)
									countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

								countdownSet.screenCenter();
								countdownSet.antialiasing = antialias;
								add(countdownSet);
								FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownSet);
										countdownSet.destroy();
									}
								});
								FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
							case 3:
								countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
								countdownGo.scrollFactor.set();

								if (PlayState.isPixelStage)
									countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

								countdownGo.updateHitbox();

								countdownGo.screenCenter();
								countdownGo.antialiasing = antialias;
								add(countdownGo);
								FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
									ease: FlxEase.cubeInOut,
									onComplete: function(twn:FlxTween)
									{
										remove(countdownGo);
										countdownGo.destroy();
									}
								});
								FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
							case 4:
						}
				}

				notes.forEachAlive(function(note:Note) {
					if(ClientPrefs.mechanics)
					{
						if(curStage == 'WaltStage')
						{
							note.copyAlpha = false;
							note.alpha = 0;
							
							if(!note.mustPress) {
								note.alpha = 0;
								note.visible = false;
							}
						}else{
							note.copyAlpha = false;
							note.alpha = 1;

							if(ClientPrefs.middleScroll && !note.mustPress) {
								note.alpha *= 0.5;
							}
						}
					}else{
						note.copyAlpha = false;
						note.alpha = 1;

						if(ClientPrefs.middleScroll && !note.mustPress) {
							note.alpha *= 0.5;
						}
					}
					
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			vocals.pitch = playbackRate;
		}
		vocals.play();
		Conductor.songPosition = time;
		songTime = time;
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.onComplete = onSongComplete;
		vocals.play();

		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBarBG, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		//
		if(hudStyle == 'Demolition')
		{
			switch(SONG.song)
			{
				case 'Isolated':
					//FlxTween.tween(camHUD, {alpha: 1}, 3, {ease: FlxEase.circInOut, startDelay: 10});
					FlxTween.tween(healthBarBG, {alpha: 1}, 0.5 * playbackRate, {ease: FlxEase.circOut});
					FlxTween.tween(healthBar, {alpha: 1}, 0.5 * playbackRate, {ease: FlxEase.circOut});
					FlxTween.tween(healthIcon, {alpha: 1}, 0.5 * playbackRate, {ease: FlxEase.circOut});
					FlxTween.tween(healthTxt, {alpha: 1}, 0.5 * playbackRate, {ease: FlxEase.circOut});
					FlxTween.tween(iconP1, {alpha: 1}, 0.5 * playbackRate, {ease: FlxEase.circOut});
					FlxTween.tween(iconP2, {alpha: 1}, 0.5 * playbackRate, {ease: FlxEase.circOut});
				case 'Lunacy':
					//FlxTween.tween(camHUD, {alpha: 1}, 3, {ease: FlxEase.circInOut, startDelay: 27});
					FlxTween.tween(healthBarBG, {alpha: 1}, 0.5 * playbackRate, {ease: FlxEase.circOut});
					FlxTween.tween(healthBar, {alpha: 1}, 0.5 * playbackRate, {ease: FlxEase.circOut});
					FlxTween.tween(healthIcon, {alpha: 1}, 0.5 * playbackRate, {ease: FlxEase.circOut});
					FlxTween.tween(healthTxt, {alpha: 1}, 0.5 * playbackRate, {ease: FlxEase.circOut});
					FlxTween.tween(iconP1, {alpha: 1}, 0.5 * playbackRate, {ease: FlxEase.circOut});
					FlxTween.tween(iconP2, {alpha: 1}, 0.5 * playbackRate, {ease: FlxEase.circOut});
				default:
					FlxTween.tween(camHUD, {alpha: 1}, 1 * playbackRate, {ease: FlxEase.circOut});
					FlxTween.tween(healthBarBG, {alpha: 1}, 0.5 * playbackRate, {ease: FlxEase.circOut});
					FlxTween.tween(healthBar, {alpha: 1}, 0.5 * playbackRate, {ease: FlxEase.circOut});
					FlxTween.tween(healthIcon, {alpha: 1}, 0.5 * playbackRate, {ease: FlxEase.circOut});
					FlxTween.tween(healthTxt, {alpha: 1}, 0.5 * playbackRate, {ease: FlxEase.circOut});
					FlxTween.tween(iconP1, {alpha: 1}, 0.5 * playbackRate, {ease: FlxEase.circOut});
					FlxTween.tween(iconP2, {alpha: 1}, 0.5 * playbackRate, {ease: FlxEase.circOut});
			}
		}

		FlxTween.tween(songBanner, {alpha: 0.5}, 1, {ease: FlxEase.circOut});
		FlxTween.tween(songBannerText, {alpha: 1}, 1, {ease: FlxEase.circOut});

		FlxTween.tween(songBanner, {alpha: 0}, 1.5, {ease: FlxEase.circIn, startDelay: 4});
		FlxTween.tween(songBannerText, {alpha: 0}, 1.5, {ease: FlxEase.circIn, startDelay: 4});

		/*switch(SONG.song)
		{
			case 'Isolated':
				camHUD.alpha = 0;
				FlxTween.tween(camHUD, {alpha: 1}, 3, {ease: FlxEase.circInOut, startDelay: 10});
			case 'Lunacy':
				camHUD.alpha = 0;
				FlxTween.tween(camHUD, {alpha: 1}, 3, {ease: FlxEase.circInOut, startDelay: 27});
		}*/

		#if desktop //for prevent curPortrait error
		switch(curSong){
			case "Isolated" | "Lunacy" | "Delusional": curPortrait = "placeholder";
			case "Malfunction": curPortrait = "malfunction";
			case "Don't Cross!": curPortrait = "placeholder";
			case "Twisted Grins" | "Facade" | "Mortiferum Risus": curPortrait = "episode2";
			case "Laugh Track": curPortrait = "placeholder";
			case "Scrapped": curPortrait = "scrapped";
			case "Mercy": curPortrait = "mercy";
			case "Bless": curPortrait = "bless";
			case "Isolated Old": curPortrait = "placeholder";
			case "Cycled Sins": curPortrait = "cycledsins";
			case "War Dilemma": curPortrait = "placeholder";
			case "Hunted": curPortrait = "hunted";
			case "Neglection": curPortrait = "placeholder";
		}
		#end

		switch(curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});

				case 'PixelWorld':
					songLength = 55 * 1000; //ye fix the shit so the timebar still visible
					//also we are not copy WI, is just for fun (jason)
		}
		
		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		if(SONG.song == "Don't Cross!")
		{
			DiscordClient.changePresence(detailsText, SONG.song + " (You're Fucked)", iconP2.getCharacter(), true, songLength, curPortrait);
		}else{
			DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength, curPortrait);
		}
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}
		
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);
		
		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		vocals.pitch = playbackRate;

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if sys
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2], event[1][i][3]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3],
						value3: newEventNote[4]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				//Note Skin Code
				var char:String;
				if(gottaHitNote)
					char = SONG.player1;
				else
					char = SONG.player2;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, char);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts
				
				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						//Note Skin Code
						var char:String;
						if(gottaHitNote)
							char = SONG.player1;
						else
							char = SONG.player2;

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true, false, char);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2], event[1][i][3]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3],
					value3: newEventNote[4]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Spotlights':
				darknessBlack = new BGSprite(null, -800, -400, 0, 0);
				darknessBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				darknessBlack.alpha = 0.25;
				darknessBlack.visible = false;
				add(darknessBlack);

				spotlight = new BGSprite('funkinAVI/uiAndEvents/spotlight', 400, -400);
				spotlight.alpha = 0.375;
				spotlight.blend = ADD;
				spotlight.visible = false;
				add(spotlight);

			case 'Philly Glow':
				blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				blammedLightsBlack.visible = false;
				insert(members.indexOf(phillyStreet), blammedLightsBlack);

				phillyWindowEvent = new BGSprite('philly/window', phillyWindow.x, phillyWindow.y, 0.3, 0.3);
				phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
				phillyWindowEvent.updateHitbox();
				phillyWindowEvent.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyWindowEvent);


				phillyGlowGradient = new PhillyGlow.PhillyGlowGradient(-400, 225); //This shit was refusing to properly load FlxGradient so fuck it
				phillyGlowGradient.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyGlowGradient);

				precacheList.set('philly/particle', 'image'); //precache particle image
				phillyGlowParticles = new FlxTypedGroup<PhillyGlow.PhillyGlowParticle>();
				phillyGlowParticles.visible = false;
				insert(members.indexOf(phillyGlowGradient) + 1, phillyGlowParticles);
		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1 && ClientPrefs.middleScroll) targetAlpha = 0.35;
			//Note Skin Code
			var char:String;
			if(player == 1)
				char = SONG.player1;
			else
				char = SONG.player2;

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player, char);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				babyArrow.y -= 100;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 100, alpha: targetAlpha}, 1, {ease: FlxEase.elasticOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				if(ClientPrefs.mechanics)
				{
					if(curStage == 'WaltStage')
					{
						if(ClientPrefs.middleScroll)
						{
							babyArrow.x += 310;
							if(i > 1) { //Up and Right
								babyArrow.x += FlxG.width / 2 + 25;
							}
						}
						babyArrow.visible = false;
						babyArrow.alpha = 0;
						opponentStrums.add(babyArrow);
						
					}else{
						if(ClientPrefs.middleScroll)
						{
							babyArrow.x += 310;
							if(i > 1) { //Up and Right
								babyArrow.x += FlxG.width / 2 + 25;
							}
						}
						opponentStrums.add(babyArrow);
					}
				}else{
					if(ClientPrefs.middleScroll)
					{
						babyArrow.x += 310;
						if(i > 1) { //Up and Right
							babyArrow.x += FlxG.width / 2 + 25;
						}
					}
					opponentStrums.add(babyArrow);
				}
				
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			if(carTimer != null) carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;
			
			if(carTimer != null) carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}
			
			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				if(SONG.song == "Don't Cross!")
				{
					DiscordClient.changePresence(detailsText, SONG.song + " (You're Fucked)", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset, curPortrait);
				}else{
					DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset, curPortrait);	
				}
			}
			else
			{
				if(SONG.song == "Don't Cross!")
				{
					DiscordClient.changePresence(detailsText, SONG.song + " (You're Fucked)", iconP2.getCharacter());
				}else{
					DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				}
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				if(SONG.song == "Don't Cross!")
				{
					DiscordClient.changePresence(detailsText, SONG.song + " (You're Fucked)", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset, curPortrait);
				}else{
					DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset, curPortrait);	
				}
			}
			else
			{
				if(SONG.song == "Don't Cross!")
				{
					DiscordClient.changePresence(detailsText, SONG.song + " (You're Fucked)", iconP2.getCharacter());
				}else{
					DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				}
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && paused)
		{
			if(SONG.song == "Don't Cross!" && ClientPrefs.mechanics)
			{
				DiscordClient.changePresence(detailsPausedText, SONG.song + " (You're Fucked)", iconP2.getCharacter(), curPortrait);
			}else if (SONG.song == 'Malfunction' && ClientPrefs.mechanics)
			{
				DiscordClient.changePresence(detailsPausedText, SONG.song + " (ERR_501)", iconP2.getCharacter(), curPortrait);
			}else{
				DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), curPortrait);
			}
		}
		#end

		var ret:Dynamic = callOnLuas('onPause', []);
		if(ret != FunkinLua.Function_Stop) {
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			/*if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				cancelMusicFadeTween();
				MusicBeatState.switchState(new GitarooPause());
			}
			else {*/
			if(FlxG.sound.music != null) {
				FlxG.sound.music.pause();
				vocals.pause();
			}

			/**
			 * ok demo im gonna say bye bye to this because:
			 * 
			 * 1.is buggy
			 * 2.you can no-clip
			 * 3.pause in delusional
			 * 4.i forgor
			 */

			/**if(ClientPrefs.language == "Spanish") {
			openSubState(new PauseSpanishState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			} else {
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}*/
			}

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		FlxG.sound.music.pitch = playbackRate;
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			vocals.pitch = playbackRate;
		}
		vocals.play();
	}

	public var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	override public function update(elapsed:Float)
	{
		/*if (FlxG.keys.justPressed.Z) SetScaleMode(1);
		if (FlxG.keys.justPressed.X) SetScaleMode(2);
		if (FlxG.keys.justPressed.C) SetScaleMode(3);
		if (FlxG.keys.justPressed.B) SetScaleMode(4);
		if (FlxG.keys.justPressed.N) SetScaleMode(5);
		if (FlxG.keys.justPressed.M) SetScaleMode(6);
		if (FlxG.keys.justPressed.COMMA) SetScaleMode(7);*/

		if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}

		if(FlxG.keys.justPressed.SPACE && shootin && canDodge) {
			dodged = true;
			canDodge = false;
			new FlxTimer().start(1, function(tmr:FlxTimer) {
				canDodge = true;
			});
		}

		callOnLuas('onUpdate', [elapsed]);

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos){
			moveCameraSection(Std.int(curStep / 16), true);
		}

		switch (curStage)
		{
			case 'WaltStage':
				if(ClientPrefs.mechanics)
				{
					if(FlxG.keys.justPressed.SPACE)
					{
						health += 0.05;
					}
				}
			//case 'PixelStage':

			case 'tank':
				moveTank(elapsed);
			case 'schoolEvil':
				if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyWindow.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;

				if(phillyGlowParticles != null)
				{
					var i:Int = phillyGlowParticles.members.length-1;
					while (i > 0)
					{
						var particle = phillyGlowParticles.members[i];
						if(particle.alpha < 0)
						{
							particle.kill();
							phillyGlowParticles.remove(particle, true);
							particle.destroy();
						}
						--i;
					}
				}
			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 130) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
			case 'mall':
				if(heyTimer > 0) {
					heyTimer -= elapsed;
					if(heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed * playbackRate, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		if(ClientPrefs.debugMode){
			if(!endingSong && !startingSong){
				if (FlxG.keys.justPressed.ONE) {
					KillNotes();
					FlxG.sound.music.onComplete();
				}
			}
			if (FlxG.keys.justPressed.TWO) {
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition = 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if(daNote.strumTime + 800 < Conductor.songPosition) {
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}
		if(FlxG.keys.justPressed.THREE && mechanics)
		{
             mechanics = false;
		} 
		else if(FlxG.keys.justPressed.THREE && !mechanics)
		{
			mechanics = true;
		}
		}

		super.update(elapsed);
		
		switch(hudStyle)
		{
			default:
				if(ClientPrefs.simplifiedScore) {
				
				if(ratingName == '?') {
					scoreTxt.text = 'Score: ' + songScore + ' ~ Misses: ' + songMisses;
				} else {
					scoreTxt.text = 'Punt ' + songScore + ' ~ Misses: ' + songMisses + ' (' + ratingFC + ')';
				} 
					} else {
				if(ratingPercent == 0) {
					if(ClientPrefs.language == "Spanish") {
					scoreTxt.text = 'Puntuacion: ' + songScore + ' | Perdidas: ' + songMisses + ' | Presicion: ?';
				} else {
					//im sorry but combo breaks is peak
					scoreTxt.text = 'Score: ' + songScore + ' | Combo Breaks: ' + songMisses + ' | Accuracy: ?'; //no way i was a dumbass all the time
				}
				} else {
					if(ClientPrefs.language == "Spanish") {
						scoreTxt.text = 'Puntuacion: ' + songScore + ' | Perdidas: ' + songMisses + ' | Presicion: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + '% ' + ' [' + ratingFC + ']';
					} else {
						scoreTxt.text = 'Score: ' + songScore + ' | Combo Breaks: ' + songMisses + ' | Accuracy: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + '% ' + ' [' + ratingFC + ']';//peeps wanted no integer rating
				}
				}

				if(SONG.song == "Isolated Old") {
						scoreTxt.text = 'Health:' + Math.round(health * 50) + "%" + ' - Score: ' + songScore + ' - Misses: ' + songMisses + ' - Rating: ' + ratingName + ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;//peeps wanted no integer rating
				}

				if(SONG.song == "Isolated Beta") {
					scoreTxt.text = "Score: " + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingName + (ratingName != '?' ? ' (${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - $ratingFC' : '');
				}

				if(SONG.song == "'Neglection") {
					scoreTxt.text = ''+healthBar.percent+'%';
				}

				if(SONG.song == "Fight or Flight") { //we don't know the song name, starved
					scoreTxt.text = 'Sacrifices: ' + deathCounter + ' | Accuracy: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + '% ' + ' [' + ratingFC + ']';//peeps wanted no integer rating
				}

				if(SONG.song == "Cycled Sins") { //Think About it Demo, that would be cool
					if (healthBar.percent > 80)
						scoreTxt.text = 'Sanity: High  | Accuracy: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%';
					else if (healthBar.percent > 20 && healthBar.percent < 80)	
						scoreTxt.text = 'Sanity: Medium  | Accuracy: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%';
					else 
						scoreTxt.text = 'Sanity: Low  | Accuracy: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%';
				}
					}

							// Info Bar
				var accuracy:Float = Highscore.floorDecimal(ratingPercent * 100, 2);
				var ratingNameTwo:String = ratingName;
				var divider:String = ' ' + '-' + ' ';
					
				if (ClientPrefs.ratingSystem == "None") {
					if(ClientPrefs.language == "Spanish") {
					scoreTxt.text = 'Puntuacion: ${songScore}' + divider + 'Perdidas: ${totalMisses}';
					} else {
						scoreTxt.text = 'Score: ${songScore}' + divider + 'Combo Breaks: ${totalMisses}';
					}
				}
			case 'Vanilla':
				if(ClientPrefs.language == "English") {
				scoreTxt.text = 'Score:' + songScore;
				} else {
				scoreTxt.text = 'Puntuacion: ' + songScore;
				}
			case 'Demolition':
				if(ClientPrefs.language == "English")
				missesTxt.text = songMisses + ' Misses';
				else
				missesTxt.text = songMisses + ' Perdidas';
				
				healthTxt.text = Math.round(health * 50) + '%';
				
				if(ratingName == '?') {
					scoreTxt.text = 'Score: ' + songScore;
				}else{	
				scoreTxt.text = 'Score: ' + songScore + ' / ' + 'Accuracy: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + '% / Rating: '+ ratingFC;
				}

				if(SONG.song == "Isolated Old") {
					scoreTxt.text = 'Score: ' + songScore + ' - Rating: ' + ratingName + ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;//peeps wanted no integer rating
			}

			if(SONG.song == "Fight or Flight") { //we don't know the song name, starved
				scoreTxt.text = 'Sacrifices: ' + deathCounter + ' | Accuracy: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + '% ' + ' [' + ratingFC + ']';//peeps wanted no integer rating
			}

			if(SONG.song == "Cycled Sins") { //Think About it Demo, that would be cool
				if (healthBar.percent > 80)
					scoreTxt.text = 'Sanity: High  | Accuracy: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%';
				else if (healthBar.percent > 20 && healthBar.percent < 80)	
					scoreTxt.text = 'Sanity: Medium  | Accuracy: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%';
				else 
					scoreTxt.text = 'Sanity: Low  | Accuracy: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%';
			}

						// Info Bar
						var accuracy:Float = Highscore.floorDecimal(ratingPercent * 100, 2);
						var ratingNameTwo:String = ratingName;
						var divider:String = ' ' + '-' + ' ';
							
						if (ClientPrefs.ratingSystem == "None") {
							if(ClientPrefs.language == "Spanish") {
							scoreTxt.text = 'Puntuacion: ${songScore}' + divider + 'Perdidas: ${totalMisses}';
							} else {
								scoreTxt.text = 'Score: ${songScore}' + divider + 'Misses: ${totalMisses}';
							}
						}
		}

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			
			if(SONG.song == 'Delusional')
				{
					//#if (desktop && !avi_debug)
					attemptsTillJumpscare -= 1;
					satanSpeaks = new FlxText(-50, 0, 0);
					satanSpeaks.setFormat(Paths.font("satanFont.ttf"), 40, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					satanSpeaks.cameras = [camHUD];
					satanSpeaks.screenCenter();
					add(satanSpeaks);
	
					//satanPopup = new FlxSprite();
					//add(satanPopup);
	
					//satanJumpscare = new FlxSprite();
					//add(satanJumpscare);
					//DO NOT USE THIS YET UNTIL WE GET THE SPRITE.
					//ok
	
					if(attemptsTillJumpscare == 20)
					{
						//satanPopUp.animation.play('boo');
						satanSpeaks.text = "What's the matter, don't you want to play?";
						//attemptsTillJumpscare -= 1;
						FlxTween.tween(satanSpeaks, {alpha: 0}, 0.5);
					}
					if(attemptsTillJumpscare == 19)
					{
						//satanPopUp.animation.play('boo');
						satanSpeaks.text = "It's pointless to go now...";
						//attemptsTillJumpscare -= 1;
						FlxTween.tween(satanSpeaks, {alpha: 0}, 0.5);
					}
					if(attemptsTillJumpscare == 18)
					{
						//satanPopUp.animation.play('boo');
						satanSpeaks.text = "We're only getting started, fellow player.";
						FlxTween.tween(satanSpeaks, {alpha: 0}, 0.5);
						//attemptsTillJumpscare -= 1;
					}
					if(attemptsTillJumpscare == 17)
					{
						//satanPopUp.animation.play('boo');
						satanSpeaks.text = "What's wrong? Don't like the hospitality?";
						FlxTween.tween(satanSpeaks, {alpha: 0}, 0.5);
						//attemptsTillJumpscare -= 1;
					}
					if(attemptsTillJumpscare == 16)
					{
						//satanPopUp.animation.play('boo');
						satanSpeaks.text = "We're only having a little bit of fun.";
						FlxTween.tween(satanSpeaks, {alpha: 0}, 0.5);
						//attemptsTillJumpscare -= 1;
					}
					if(attemptsTillJumpscare == 15)
					{
						//satanPopUp.animation.play('boo');
						satanSpeaks.text = "See? Mickey is very happy...";
						FlxTween.tween(satanSpeaks, {alpha: 0}, 0.5);
						//attemptsTillJumpscare -= 1;
					}
					if(attemptsTillJumpscare == 14)
					{
						//satanPopUp.animation.play('boo');
						satanSpeaks.text = "Don't be a party pooper, "+Paths.delusionalJumpscaretext+".";
						FlxTween.tween(satanSpeaks, {alpha: 0}, 0.5);
						//attemptsTillJumpscare -= 1;
					}
					if(attemptsTillJumpscare == 13)
					{
						//satanPopUp.animation.play('boo');
						satanSpeaks.text = "Don't stop now...";
						FlxTween.tween(satanSpeaks, {alpha: 0}, 0.5);
						//attemptsTillJumpscare -= 1;
					}
					if(attemptsTillJumpscare == 12)
					{
						//satanPopUp.animation.play('boo');
						satanSpeaks.text = "Don't worry, it will all be over soon.";
						FlxTween.tween(satanSpeaks, {alpha: 0}, 0.5);
						//attemptsTillJumpscare -= 1;
					}
					if(attemptsTillJumpscare == 11)
					{
						//satanPopUp.animation.play('boo');
						satanSpeaks.text = "Quit resisting...";
						FlxTween.tween(satanSpeaks, {alpha: 0}, 0.5);
						//attemptsTillJumpscare -= 1;
					}
					if(attemptsTillJumpscare == 10)
					{
						//satanPopUp.animation.play('boo');
						satanSpeaks.text = ".....";
						FlxTween.tween(satanSpeaks, {alpha: 0}, 0.5);
						//attemptsTillJumpscare -= 1;
					}
					if(attemptsTillJumpscare == 9)
					{
						//satanPopUp.animation.play('boo');
						satanSpeaks.text = "Stop it.";
						FlxTween.tween(satanSpeaks, {alpha: 0}, 0.5);
						//attemptsTillJumpscare -= 1;
					}
					if(attemptsTillJumpscare == 8)
					{
						//satanPopUp.animation.play('boo');
						satanSpeaks.text = "You're starting to get on my nerves, " + Paths.delusionalJumpscaretext + ".";
						FlxTween.tween(satanSpeaks, {alpha: 0}, 0.5);
						//attemptsTillJumpscare -= 1;
					}
					if(attemptsTillJumpscare == 7)
					{
						//satanPopUp.animation.play('boo');
						satanSpeaks.text = "Quit it, it gets you nowhere.";
						FlxTween.tween(satanSpeaks, {alpha: 0}, 0.5);
						//attemptsTillJumpscare -= 1;
					}
					if(attemptsTillJumpscare == 6)
					{
						//satanPopUp.animation.play('boo');
						satanSpeaks.text = "Why do you still try, " + Paths.delusionalJumpscaretext + "?";
						FlxTween.tween(satanSpeaks, {alpha: 0}, 0.5);
						//attemptsTillJumpscare -= 1;
					}
					if(attemptsTillJumpscare == 5)
					{
						//satanPopUp.animation.play('boo');
						satanSpeaks.text = "This is getting irritating now...";
						FlxTween.tween(satanSpeaks, {alpha: 0}, 0.5);
						//attemptsTillJumpscare -= 1;
					}
					if(attemptsTillJumpscare == 4)
					{
						//satanPopUp.animation.play('boo');
						satanSpeaks.text = "I'm warning you, " + Paths.delusionalJumpscaretext + ", stop what you're doing.";
						FlxTween.tween(satanSpeaks, {alpha: 0}, 0.5);
						//attemptsTillJumpscare -= 1;
					}
					if(attemptsTillJumpscare == 3)
					{
						//satanPopUp.animation.play('boo');
						satanSpeaks.text = "I know who you are, " + Paths.delusionalJumpscaretext + "...";
						FlxTween.tween(satanSpeaks, {alpha: 0}, 0.5);
						//attemptsTillJumpscare -= 1;
					}
					if(attemptsTillJumpscare == 2)
					{
						//satanPopUp.animation.play('boo');
						satanSpeaks.text = "Last warning, " + Paths.delusionalJumpscaretext + ".";
						FlxTween.tween(satanSpeaks, {alpha: 0}, 0.5);
						//attemptsTillJumpscare -= 1;
					}
					if(attemptsTillJumpscare == 1)
					{
						//satanPopUp.animation.play('boo');
						satanSpeaks.text = "Go ahead, press it again, see what happens...";
						FlxTween.tween(satanSpeaks, {alpha: 0}, 0.5);
						//attemptsTillJumpscare -= 1;
					}
					if(attemptsTillJumpscare == 0)
					{
						//satanJumpscare.animation.play('jumpscare');
						new FlxTimer().start(1.3, function(tmr:FlxTimer)
						{
							System.exit(0);
						});
					}
				//#end 
				}else{
			var ret:Dynamic = callOnLuas('onPause', []);
			if(ret != FunkinLua.Function_Stop) {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// 1 / 1000 chance for Gitaroo Man easter egg
				/*if (FlxG.random.bool(0.1))
				{
					// gitaroo man easter egg
					cancelMusicFadeTween();
					MusicBeatState.switchState(new GitarooPause());
				}
				else {*/
				if(FlxG.sound.music != null) {
					FlxG.sound.music.pause();
					vocals.pause();
				}

				if(ClientPrefs.language == "Spanish") {
				openSubState(new PauseSpanishState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				} else {
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
			    }
		
				#if desktop
				if(SONG.song == "Don't Cross!")
				{
					DiscordClient.changePresence(detailsPausedText, SONG.song + " (You're Fucked)", iconP2.getCharacter(), curPortrait);
				}else{
					DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), curPortrait);
				}
				#end
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			Application.current.window.alert('DEBUG KEYS UNAVAILABLE, NO CHEATING!');
			openChartEditor();
			//uncomment this when everything is ready
		//	System.exit(0);
			//if we could just shutdown the PC...
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		/*var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;*/
				
		if(ClientPrefs.iconBounce == "None")
		{
			var iconOffset:Int = 26;
			
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
		} else {
			switch(ClientPrefs.iconBounce)
			{
					case 'Default':
						if(hudStyle == 'Demolition')
						{
							var mult:Float = FlxMath.lerp(0.78, iconP1.scale.x, CoolUtil.boundTo(0.78 - (elapsed * 9 * playbackRate), 0, 1));
							iconP1.scale.set(mult, mult);
							iconP1.updateHitbox();

							var mult:Float = FlxMath.lerp(0.78, iconP2.scale.x, CoolUtil.boundTo(0.78 - (elapsed * 9 * playbackRate), 0, 1));
							iconP2.scale.set(mult, mult);
							iconP2.updateHitbox();

							var iconOffset:Int = 26;

							iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
							iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
						}else{
							var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
							iconP1.scale.set(mult, mult);
							iconP1.updateHitbox();

							var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
							iconP2.scale.set(mult, mult);
							iconP2.updateHitbox();

							var iconOffset:Int = 26;

							iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
							iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
						}
					
					case 'Golden Apple':
						iconP1.centerOffsets();
						iconP2.centerOffsets();

						iconP1.updateHitbox();
						iconP2.updateHitbox();

						var iconOffset:Int = 26;

						iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
						iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
			}
		}
	if(ClientPrefs.mechanics)
	{
			if(curStage == 'WaltStage')
		{
			if (healthDrain > 0 && health > 0)
			{
				if (health < 0)
				{
					health = 0;
				}
				health -= 0.0015;
				healthDrain -= 0.01;
			}
		}else{
			if (healthDrain > 0 && health > 0.1)
			{
				if (health < 0.1)
				{
					health = 0.1;
				}
				health -= 0.001;
				healthDrain -= 0.0001;
			}
		}
	}

	if(health > maxHealth)
		health = maxHealth;
	
	if (iconP1.animation.frames == 3) // fixes having less than 3 or 5 frames
		{
			if (healthBar.percent < 20)
				iconP1.animation.curAnim.curFrame = 1;
			else if (healthBar.percent > 80)
				iconP1.animation.curAnim.curFrame = 2;
			else
				iconP1.animation.curAnim.curFrame = 0;
		}
		else if(iconP1.animation.frames == 2)
		{
			if (healthBar.percent < 20)
				iconP1.animation.curAnim.curFrame = 1;
			else
				iconP1.animation.curAnim.curFrame = 0;
		}
		else if(iconP1.animation.frames == 5)
		{
			if (healthBar.percent < 10)
				iconP1.animation.curAnim.curFrame = 3;
			else if (healthBar.percent > 90)
				iconP1.animation.curAnim.curFrame = 4;
			else if (healthBar.percent < 20)
				iconP1.animation.curAnim.curFrame = 1;
			else if (healthBar.percent > 80)
				iconP1.animation.curAnim.curFrame = 2;
			else
				iconP1.animation.curAnim.curFrame = 0;
		}

		if (iconP2.animation.frames == 3)
		{
			if (healthBar.percent > 80)
				iconP2.animation.curAnim.curFrame = 1;
			else if (healthBar.percent < 20)
				iconP2.animation.curAnim.curFrame = 2;
			else
				iconP2.animation.curAnim.curFrame = 0;
		}
		else if(iconP2.animation.frames == 2)
		{
			if (healthBar.percent > 80)
				iconP2.animation.curAnim.curFrame = 1;
			else
				iconP2.animation.curAnim.curFrame = 0;
		}
		else if(iconP2.animation.frames == 5)
		{
			if (healthBar.percent > 90)
				iconP2.animation.curAnim.curFrame = 3;
			else if (healthBar.percent < 10)
				iconP2.animation.curAnim.curFrame = 4;
			else if (healthBar.percent > 80)
				iconP2.animation.curAnim.curFrame = 1;
			else if (healthBar.percent < 20)
				iconP2.animation.curAnim.curFrame = 2;
			else
				iconP2.animation.curAnim.curFrame = 0;
		}

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			Application.current.window.alert('same');
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if (curTime < 0)
						curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if (hudStyle == 'Demolition')
						songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if (secondsTotal < 0)
						secondsTotal = 0;
					else if (secondsTotal >= Math.floor(songLength / 1000))
						secondsTotal = Math.floor(songLength / 1000);

					switch (hudStyle)
					{
						case "Demolition":
							timeTxt.text = '${FlxStringUtil.formatTime(secondsTotal, false)} / ${FlxStringUtil.formatTime(Math.floor(songLength / 1000), false)}';
						default:
							timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
					}
						
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = 3000;//shit be werid on 4:3
			if(songSpeed < 1) time /= songSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if (!inCutscene) {
				if(!cpuControlled) {
					keyShit();
				} else if(boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
					boyfriend.dance();
					//boyfriend.animation.curAnim.finish();
				}
			}

			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
				if(ClientPrefs.mechanics)
				{
					if(curStage == 'WaltStage')
					{
						if(!daNote.mustPress) 
						{
							strumGroup = opponentStrums;
							strumGroup.visible = false;
						}
					}else{
						if(!daNote.mustPress) strumGroup = opponentStrums;
					}
				}else{
					if(!daNote.mustPress) strumGroup = opponentStrums;
				}
				
				var strumX:Float = strumGroup.members[daNote.noteData].x;
				var strumY:Float = strumGroup.members[daNote.noteData].y;
				var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
				var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
				var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
				var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				if(ClientPrefs.mechanics)
				{
					if(curStage == 'WaltStage')
					{
						if(!daNote.mustPress)
						{
							strumAlpha = 0;
						}else{
							strumAlpha *= daNote.multAlpha;
						}
					}else{
						strumAlpha *= daNote.multAlpha;
					}
				}else{
					strumAlpha *= daNote.multAlpha;
				}
				
				if (strumScroll) //Downscroll
				{
					daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
				}
				else //Upscroll
				{
					daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
				}

				var angleDir = strumDirection * Math.PI / 180;
				if (daNote.copyAngle){
					daNote.angle = strumAngle;
					daNote.angle += strumDirection - 90;
					if(Math.abs(strumDirection) % 90 == 0 ) daNote.angle -= strumDirection - 90;
				}
				if(daNote.isSustainNote){
					daNote.angle = strumDirection + 90;
					if(daNote.angle == 180 && strumScroll == true){
						daNote.angle = 0;
					}
				}

				if(ClientPrefs.mechanics)
				{
					if(curStage == 'WaltStage')
					{
						if(daNote.copyAlpha)
						daNote.alpha = strumAlpha;
					}else{
						if(daNote.copyAlpha)
						daNote.alpha = strumAlpha;
					}
				}else{
					if(daNote.copyAlpha)
					daNote.alpha = strumAlpha;
				}
				
				
				if(daNote.copyX)
					daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

				if(daNote.copyY)
				{
					daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

					//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
					if(strumScroll && daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end')) {
							daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
							daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
							if(PlayState.isPixelStage) {
								daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
							} else {
								daNote.y -= 19;
							}
						} 
						daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
						daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					opponentNoteHit(daNote);
				}

				if(daNote.mustPress && cpuControlled) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
						goodNoteHit(daNote);
					}
				}
				
				var center:Float = strumY + Note.swagWidth / 2;
				if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
					(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					if (strumScroll)
					{
						if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
					else
					{
						if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				// Kill extremely late notes and cause misses
				if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
				{
					if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
						noteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		checkEventNote();

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
	}
	#end

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
		for (i in shaderUpdates)
		{
			i(elapsed);
		}

		/*//suicidal malfunction stuff
			@:privateAccess
        var dadFrame = dad._frame;
        
        if (dadFrame == null || dadFrame.frame == null) return; // prevents crashes (i think???)
            
        var rect = new Rectangle(dadFrame.frame.x, dadFrame.frame.y, dadFrame.frame.width, dadFrame.frame.height);
        
        dadScrollWin.scrollRect = rect;
        dadScrollWin.x = (((dadFrame.offset.x) - (dad.offset.x / 2)) * dadScrollWin.scaleX);
        dadScrollWin.y = (((dadFrame.offset.y) - (dad.offset.y / 2)) * dadScrollWin.scaleY);        

		@:privateAccess
        var boyfriendFrame = boyfriend._frame;
        
        if (boyfriendFrame == null || boyfriendFrame.frame == null) return; // prevents crashes (i think???)
            
        var rect = new Rectangle(boyfriendFrame.frame.x, boyfriendFrame.frame.y, boyfriendFrame.frame.width, boyfriendFrame.frame.height);
        
        bfScrollWin.scrollRect = rect;
        bfScrollWin.x = (((boyfriendFrame.offset.x) - (boyfriend.offset.x / 2)) * bfScrollWin.scaleX);
        bfScrollWin.y = (((boyfriendFrame.offset.y) - (boyfriend.offset.y / 2)) * bfScrollWin.scaleY);
  }    */  

	/*function popupBfWindow(customWidth:Int, customHeight:Int, ?customX:Int, ?customY:Int, ?customName:String) {
        var display = Application.current.window.display.currentMode;
        // PlayState.defaultCamZoom = 0.5;

		if(customName == '' || customName == null){
			customName = 'Player.json';
		}

        windowBoyfriend = Lib.application.createWindow({
            title: customName,
            width: customWidth,
            height: customHeight,
            borderless: false,
            alwaysOnTop: true

        });
		if(customX == null){
			customX = -10;
		}
        FlxTween.tween(windowBoyfriend, {x: customX}, 0.4);
		windowBoyfriend.y = customY;
        if(customY == null) {
        windowBoyfriend.y = Std.int(display.height / 2);
        }
     //   windowboyfriend.stage.color = 0xFF686464;
		
        @:privateAccess
        windowBoyfriend.stage.addEventListener("keyDown", FlxG.keys.onKeyDown);
        @:privateAccess
        windowBoyfriend.stage.addEventListener("keyUp", FlxG.keys.onKeyUp);
		Windowthing.getWindowsTransparent();
        // Application.current.window.x = Std.int(display.width / 2) - 640;
        // Application.current.window.y = Std.int(display.height / 2);

		var bg = Paths.image('funkinAVI/SQUAREBOILOL/nothing', 'shared').bitmap;
        var spr = new Sprite();

        var m = new Matrix();

        spr.graphics.beginBitmapFill(bg, m);
        spr.graphics.drawRect(0, 0, bg.width, bg.height);
        spr.graphics.endFill();
		Windowthing.getWindowsTransparent();
        FlxG.mouse.useSystemCursor = true;

        //Application.current.window.resize(640, 480);



        boyfriendWin.graphics.beginBitmapFill(boyfriend.pixels, m);
        boyfriendWin.graphics.drawRect(0, 0, boyfriend.pixels.width, boyfriend.pixels.height);
        boyfriendWin.graphics.endFill();
		Windowthing.getWindowsTransparent();
		
        bfScrollWin.scrollRect = new Rectangle();
	    windowBoyfriend.stage.addChild(spr);
		Windowthing.getWindowsTransparent();
        windowBoyfriend.stage.addChild(bfScrollWin);
		Windowthing.getWindowsTransparent();
        bfScrollWin.addChild(boyfriendWin);
		Windowthing.getWindowsTransparent();
        bfScrollWin.scaleX = 5;
		Windowthing.getWindowsTransparent();
        bfScrollWin.scaleY = 5;
		Windowthing.getWindowsTransparent();
        boyfriendGroup.visible = false;
		Windowthing.getWindowsTransparent();
        // uncomment the line above if you want it to hide the dad ingame and make it visible via the windoe
        Application.current.window.focus();
		FlxG.autoPause = false;
		Windowthing.getWindowsTransparent();
	}

	/*function popupWindow(customWidth:Int, customHeight:Int, ?customX:Int, ?customY:Int, ?customName:String, ?isTransparent:Bool = false) {
        var display = Application.current.window.display.currentMode;
        // PlayState.defaultCamZoom = 0.5;

		if(customName == '' || customName == null){
			customName = 'Opponent.json';
		}

        windowDad = Lib.application.createWindow({
            title: customName,
            width: customWidth,
            height: customHeight,
            borderless: false,
            alwaysOnTop: true

        });
		if(customX == null){
			customX = -10;
		}
        FlxTween.tween(windowDad, {x: customX}, 0.4);
		windowDad.y = customY;
        if(customY == null) {
        windowDad.y = Std.int(display.height / 2);
        }
     //   windowDad.stage.color = 0xFF686464;
		
        @:privateAccess
        windowDad.stage.addEventListener("keyDown", FlxG.keys.onKeyDown);
        @:privateAccess
        windowDad.stage.addEventListener("keyUp", FlxG.keys.onKeyUp);
        // Application.current.window.x = Std.int(display.width / 2) - 640;
        // Application.current.window.y = Std.int(display.height / 2);

		var bg = Paths.image('funkinAVI/SQUAREBOILOL/nothing', 'shared').bitmap;
        var spr = new Sprite();

        var m = new Matrix();

        spr.graphics.beginBitmapFill(bg, m);
        spr.graphics.drawRect(0, 0, bg.width, bg.height);
        spr.graphics.endFill();
		Windowthing.getWindowsTransparent();
        FlxG.mouse.useSystemCursor = true;

      //  Application.current.window.resize(640, 480);



        dadWin.graphics.beginBitmapFill(dad.pixels, m);
        dadWin.graphics.drawRect(0, 0, dad.pixels.width, dad.pixels.height);
        dadWin.graphics.endFill();
        dadScrollWin.scrollRect = new Rectangle();
	    windowDad.stage.addChild(spr);
		Windowthing.getWindowsTransparent();
        windowDad.stage.addChild(dadScrollWin);
		Windowthing.getWindowsTransparent();
        dadScrollWin.addChild(dadWin);
		Windowthing.getWindowsTransparent();
        dadScrollWin.scaleX = 0.7;
		Windowthing.getWindowsTransparent();
        dadScrollWin.scaleY = 0.7;
		Windowthing.getWindowsTransparent();
        dadGroup.visible = false;
		Windowthing.getWindowsTransparent();
        // uncomment the line above if you want it to hide the dad ingame and make it visible via the windoe
        Application.current.window.focus();
		Windowthing.getWindowsTransparent();
		FlxG.autoPause = false;
		Windowthing.getWindowsTransparent();
    }*/ //rip code
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	/*
	function lol() 
		{ persistentUpdate = false;
			 paused = true;
			  cancelMusicFadeTween();
			   MusicBeatState.switchState(new OpenSong()); 
		}
		just for hard code support??
		*/

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', []);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				
				Application.current.window.title = "Funkin.avi - Game Over";

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				if(SONG.song == "Don't Cross!")
				{
					DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (You're Fucked)", iconP2.getCharacter(), curPortrait);
				}else{
					DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), curPortrait);
				}
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}
		function fadeWhiteFlash(time:Float = 0.3, color:String = '#FFFFFF') {
			if(ClientPrefs.flashing)
			{
					whiteFlashBG.alpha = 0.6;
					whiteFlashBG.color = FlxColor.fromString(color);
					whiteFlashBGFade = FlxTween.tween(whiteFlashBG, {alpha: 0}, time, {ease: FlxEase.linear});
			}
		}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			var value3:String = '';
			if(eventNotes[0].value3 != null)
				value3 = eventNotes[0].value3;

			triggerEventNote(eventNotes[0].event, value1, value2, value3);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	var lyrics:FlxText;
	
	/**
	 * Function Used For Hardcoded Events So No One Can Remove It!
	 * @param eventName The Event Name
	 * @param value1 First Value
	 * @param value2 Second Value
	 * @param value3 Third Value Used Just In Case!
	 */
	public function triggerEventNote(eventName:String, value1:String, value2:String, ?value3:String = '') {
		switch(eventName) {

			case 'Spotlights':
				var val:Null<Int> = Std.parseInt(value1);
				if(val == null) val = 0;

				switch(Std.parseInt(value1))
				{
					case 1, 2, 3: //enable and target dad
						if(val == 1) //enable
						{
							darknessBlack.visible = true;
							spotlight.visible = true;
							defaultCamZoom += 0.12;
						}

						var who:Character = dad;
						if(val > 2) who = boyfriend;
						//2 only targets dad
						spotlight.alpha = 0;
						darknessBlack.alpha = 0;
						new FlxTimer().start(0, function(tmr:FlxTimer) {
							FlxTween.tween(spotlight, {alpha: 0.375}, 1);
							FlxTween.tween(darknessBlack, {alpha: 0.25}, 0.75);
						});
						spotlight.setPosition(who.getGraphicMidpoint().x - spotlight.width / 2, who.y + who.height - spotlight.height + 50);

					default:
						darknessBlack.visible = false;
						spotlight.visible = false;
						defaultCamZoom -= 0.12;
						FlxTween.tween(spotlight, {alpha: 0}, 1, {onComplete: function(twn:FlxTween)
						{
							spotlight.visible = false;
						}});
						FlxTween.tween(darknessBlack, {alpha: 0}, 0.75, {onComplete: function(twn:FlxTween)
						{
							darknessBlack.visible = false;
						}});
				}

			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				if(ClientPrefs.events) {
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;
			}

			case 'Philly Glow':
				if(ClientPrefs.events) {
				var lightId:Int = Std.parseInt(value1);
				if(Math.isNaN(lightId)) lightId = 0;

				var chars:Array<Character> = [boyfriend, gf, dad];
				switch(lightId)
				{
					case 0:
						if(phillyGlowGradient.visible)
						{
							FlxG.camera.flash(FlxColor.WHITE, 0.15, null, true);
							FlxG.camera.zoom += 0.5;
							if(ClientPrefs.camZooms) camHUD.zoom += 0.1;

							blammedLightsBlack.visible = false;
							phillyWindowEvent.visible = false;
							phillyGlowGradient.visible = false;
							phillyGlowParticles.visible = false;
							curLightEvent = -1;

							for (who in chars)
							{
								who.color = FlxColor.WHITE;
							}
							phillyStreet.color = FlxColor.WHITE;
						}

					case 1: //turn on
						curLightEvent = FlxG.random.int(0, phillyLightsColors.length-1, [curLightEvent]);
						var color:FlxColor = phillyLightsColors[curLightEvent];

						if(!phillyGlowGradient.visible)
						{
							FlxG.camera.flash(FlxColor.WHITE, 0.15, null, true);
							FlxG.camera.zoom += 0.5;
							if(ClientPrefs.camZooms) camHUD.zoom += 0.1;

							blammedLightsBlack.visible = true;
							blammedLightsBlack.alpha = 1;
							phillyWindowEvent.visible = true;
							phillyGlowGradient.visible = true;
							phillyGlowParticles.visible = true;
						}
						else if(ClientPrefs.flashing)
						{
							var colorButLower:FlxColor = color;
							colorButLower.alphaFloat = 0.3;
							FlxG.camera.flash(colorButLower, 0.5, null, true);
						}

						for (who in chars)
						{
							who.color = color;
						}
						phillyGlowParticles.forEachAlive(function(particle:PhillyGlow.PhillyGlowParticle)
						{
							particle.color = color;
						});
						phillyGlowGradient.color = color;
						phillyWindowEvent.color = color;

						var colorDark:FlxColor = color;
						colorDark.brightness *= 0.5;
						phillyStreet.color = colorDark;

					case 2: // spawn particles
						if(!ClientPrefs.lowQuality)
						{
							var particlesNum:Int = FlxG.random.int(8, 12);
							var width:Float = (2000 / particlesNum);
							var color:FlxColor = phillyLightsColors[curLightEvent];
							for (j in 0...3)
							{
								for (i in 0...particlesNum)
								{
									var particle:PhillyGlow.PhillyGlowParticle = new PhillyGlow.PhillyGlowParticle(-400 + width * i + FlxG.random.float(-width / 5, width / 5), phillyGlowGradient.originalY + 200 + (FlxG.random.float(0, 125) + j * 40), color);
									phillyGlowParticles.add(particle);
								}
							}
						}
						phillyGlowGradient.bop();
				}
			}
			case 'Kill Henchmen':
				killHenchmen();

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Trigger BG Ghouls':
				if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;
		
						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				if(ClientPrefs.screenShake) {
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}
			}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();

				case 'Screen Fade':
					var fadeAlpha = value1;
					var timer = Std.parseFloat(value2);
	
					FlxTween.tween(blackFadeThing, {alpha: fadeAlpha}, timer, {ease: FlxEase.sineInOut}); //sine it out supermarcy*/
				/*var charType:Int = Std.parseInt(value1);
				if(Math.isNaN(charType)) charType = 0;
		
					switch(charType) {
						case 0:
							blackFadeThing.alpha = 0;
						case 1:
							blackFadeThing.alpha += 0.05;
						case 2:
							blackFadeThing.alpha -= 0.05;
						case 3:
							blackFadeThing.alpha += 1;
						//Sorry that you have to fucking spam these events to do the thing
					}*/
	
				case 'Lyrics':
					if(lyrics!=null){
						remove(lyrics);
						lyrics.destroy();
					}
					if(value2.trim()=='')value2='#FFFFFF';
					if(value1.trim()!=''){
						 lyrics = new FlxText(0, 570, 0, value1, 32);
						lyrics.cameras = [camCustom];
						lyrics.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.fromString(value2), CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						lyrics.screenCenter(X);
						lyrics.updateHitbox();
						add(lyrics);
					}
				case 'Flash Screen':
					if(ClientPrefs.flashing) { //This Demolition, is how to make flashing lights disabled
					var colorFlash:Int = Std.parseInt(value1);
					if(Math.isNaN(colorFlash)) colorFlash = 0;
			
					switch(colorFlash) {
						case 0:
							FlxG.camera.flash(FlxColor.WHITE, 3);
						case 1:
							FlxG.camera.flash(FlxColor.RED, 3);
						case 2:
							FlxG.camera.flash(FlxColor.BLUE, 3);
						case 3:
							FlxG.camera.flash(FlxColor.BLACK, 3);
						case 4:
							FlxG.camera.flash(FlxColor.CYAN, 3);
						case 5:
							FlxG.camera.flash(FlxColor.MAGENTA, 3);
						case 6:
							FlxG.camera.flash(FlxColor.PINK, 3);
						case 7:
							FlxG.camera.flash(FlxColor.ORANGE, 3);
						case 8:
							FlxG.camera.flash(FlxColor.PURPLE, 3);
						case 9:
							FlxG.camera.flash(FlxColor.LIME, 3);
					}
				}
	
				if(ClientPrefs.flashing) {
					switch(value2) {
						case 'false' | 'False':
							camHUD.visible = true;
						case 'true' | 'True':
							camHUD.visible = false;
						}
					} else {
						switch(value2) {
							case 'false' | 'False':
								FlxTween.tween(camHUD, {alpha: 1}, 1);
							case 'true' | 'True':
								FlxTween.tween(camHUD, {alpha: 0}, 1);
						}
				}
				case 'Fade Character':
					var charType:Int = Std.parseInt(value1);
					if(Math.isNaN(charType)) charType = 0;
							
					switch(charType) {
						case 0:
							dad.alpha -= 0.05;
							iconP2.alpha -= 0.05;
							opponentStrums.members[0].alpha -= 0.05;
							opponentStrums.members[1].alpha -= 0.05;
							opponentStrums.members[2].alpha -= 0.05;
							opponentStrums.members[3].alpha -= 0.05;
						case 1:
							boyfriend.alpha -= 0.05;
							iconP1.alpha -= 0.05;
							playerStrums.members[0].alpha -= 0.05;
							playerStrums.members[1].alpha -= 0.05;
							playerStrums.members[2].alpha -= 0.05;
							playerStrums.members[3].alpha -= 0.05;
						case 2:
							dad.alpha += 0.05;
							iconP2.alpha += 0.05;
							opponentStrums.members[0].alpha += 0.05;
							opponentStrums.members[1].alpha += 0.05;
							opponentStrums.members[2].alpha += 0.05;
							opponentStrums.members[3].alpha += 0.05;
						case 3:
							boyfriend.alpha += 0.05;
							iconP1.alpha += 0.05;
							playerStrums.members[0].alpha += 0.05;
							playerStrums.members[1].alpha += 0.05;
							playerStrums.members[2].alpha += 0.05;
							playerStrums.members[3].alpha += 0.05;
						//Sorry that you have to fucking spam these events to do the thing
					}
					//thx KutikiPlayz for letting me use this
					case 'Scroll Type':
					if(ClientPrefs.mechanics || mechanics)
					{
						var playerLeft:Bool = false;
						var playerDown:Bool = false;
						var playerUp:Bool = false;
						var playerRight:Bool = false;
						var playerDefault:Bool = false;
						var playerFlip:Bool = false;
						var undyne:Bool = false;
						//var flipSides:Bool = false;
						//var mixNotes:Bool = false;
	
						switch(value1) {
							case 'left' | 'Left':
								undyne = false;
								playerDefault = false;
								playerLeft = true;
								playerDown = false;
								playerUp = false;
								playerRight = false;
								playerFlip = false;
							case 'down' | 'Down':
								undyne = false;
								playerDefault = false;
								playerLeft = false;
								playerDown = true;
								playerUp = false;
								playerRight = false;
								playerFlip = false;
							case 'up' | 'Up':
								undyne = false;
								playerDefault = false;
								playerLeft = false;
								playerDown = false;
								playerUp = true;
								playerRight = false;
								playerFlip = false;
							case 'right' | 'Right':
								undyne = false;
								playerDefault = false;
								playerLeft = false;
								playerDown = false;
								playerUp = false;
								playerRight = true;
								playerFlip = false;
							case 'default' | 'Default':
								undyne = false;
								playerDefault = true;
								playerLeft = false;
								playerDown = false;
								playerUp = false;
								playerRight = false;
								playerFlip = false;
							case 'flip' | 'Flip':
								undyne = false;
								playerDefault = false;
								playerLeft = false;
								playerDown = false;
								playerUp = false;
								playerRight = false;
								playerFlip = true;
							case 'undyne' | 'Undyne':
								undyne = true;
								playerDefault = false;
								playerLeft = false;
								playerDown = false;
								playerUp = false;
								playerRight = false;
								playerFlip = false;
						}
	
						for (i in 0...playerStrums.length) {
							for(j in 0...opponentStrums.length) {
								if(playerLeft) {
									FlxTween.tween(playerStrums.members[i], {direction: 180, x: FlxG.width - 150, angle: 90}, 0.2, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[0], {y: 144}, 0.2, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[1], {y: 256}, 0.25, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[2], {y: 368}, 0.3, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[3], {y: 480}, 0.35, {ease: FlxEase.quartInOut});
									playerStrums.members[i].downScroll = false;
	
									FlxTween.tween(opponentStrums.members[j], {alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
								} else if(playerDown) {
									FlxTween.tween(playerStrums.members[i], {direction: 90, y: FlxG.height - 150, angle: 0}, 0.2, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[0], {x: 732}, 0.2, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[1], {x: 844}, 0.3, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[2], {x: 956}, 0.35, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[3], {x: 1068}, 0.2, {ease: FlxEase.quartInOut});
									playerStrums.members[i].downScroll = true;
	
									FlxTween.tween(opponentStrums.members[j], {alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
								} else if(playerUp) {
									FlxTween.tween(playerStrums.members[i], {direction: 90, y: 50, angle: 0}, 0.2, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[0], {x: 732}, 0.2, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[1], {x: 844}, 0.35, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[2], {x: 956}, 0.3, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[3], {x: 1068}, 0.2, {ease: FlxEase.quartInOut});
									playerStrums.members[i].downScroll = false;
	
									FlxTween.tween(opponentStrums.members[j], {alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
								} else if(playerRight) {
									FlxTween.tween(playerStrums.members[i], {direction: 0, x: 50, angle: 270}, 0.2, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[0], {y: 480}, 0.2, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[1], {y: 368}, 0.25, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[2], {y: 256}, 0.3, {ease: FlxEase.quartInOut});
									FlxTween.tween(playerStrums.members[3], {y: 144}, 0.35, {ease: FlxEase.quartInOut});
									playerStrums.members[i].downScroll = false;
	
									FlxTween.tween(opponentStrums.members[j], {alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
								} else if(playerDefault) {
									if(ClientPrefs.downScroll) {
										FlxTween.tween(playerStrums.members[i], {direction: 90, y: FlxG.height - 150, angle: 0}, 0.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[0], {x: 732}, 0.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[1], {x: 844}, 0.3, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[2], {x: 956}, 0.35, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[3], {x: 1068}, 0.2, {ease: FlxEase.quartInOut});
										playerStrums.members[i].downScroll = true;
									} else {
										FlxTween.tween(playerStrums.members[i], {direction: 90, y: 50, angle: 0}, 0.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[0], {x: 732}, 0.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[1], {x: 844}, 0.35, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[2], {x: 956}, 0.3, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[3], {x: 1068}, 0.2, {ease: FlxEase.quartInOut});
										playerStrums.members[i].downScroll = false;
										}
	
									FlxTween.tween(opponentStrums.members[j], {alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
									} else if(playerFlip) {
										if(ClientPrefs.downScroll) {
										FlxTween.tween(playerStrums.members[i], {direction: 90, y: 50, angle: 0}, 0.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[0], {x: 732}, 0.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[1], {x: 844}, 0.35, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[2], {x: 956}, 0.3, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[3], {x: 1068}, 0.2, {ease: FlxEase.quartInOut});
										playerStrums.members[i].downScroll = false;
									} else {
										FlxTween.tween(playerStrums.members[i], {direction: 90, y: FlxG.height - 150, angle: 0}, 0.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[0], {x: 732}, 0.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[1], {x: 844}, 0.3, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[2], {x: 956}, 0.35, {ease: FlxEase.quartInOut});
										FlxTween.tween(playerStrums.members[3], {x: 1068}, 0.2, {ease: FlxEase.quartInOut});
										playerStrums.members[i].downScroll = true;
										}
	
										FlxTween.tween(opponentStrums.members[j], {alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
									} else if(undyne) {
									FlxTween.tween(playerStrums.members[0], {direction: 180, x: 585 - 75, y: 305, angle: 0}, 0.3, {ease: FlxEase.quartInOut});
									playerStrums.members[0].downScroll = false;
									FlxTween.tween(playerStrums.members[1], {direction: 90, x: 586, y: 305 + 75, angle: 0}, 0.2, {ease: FlxEase.quartInOut});
									playerStrums.members[1].downScroll = false;
									FlxTween.tween(playerStrums.members[2], {direction: 90, x: 586, y: 305 - 75, angle: 0}, 0.36, {ease: FlxEase.quartInOut});
									playerStrums.members[2].downScroll = true;
									FlxTween.tween(playerStrums.members[3], {direction: 0, x: 585 + 75, y: 305, angle: 0}, 0.43, {ease: FlxEase.quartInOut});
									playerStrums.members[3].downScroll = false;
	
									FlxTween.tween(opponentStrums.members[j], {alpha: 0}, 0.2, {ease: FlxEase.quartInOut});
									}
								}
							}
	
						var opponentLeft:Bool = false;
						var opponentDown:Bool = false;
						var opponentUp:Bool = false;
						var opponentRight:Bool = false;
						var opponentDefault:Bool = false;
						var opponentFlip:Bool = false;
	
							switch(value2) {
								case 'left' | 'Left':
									undyne = false;
									opponentDefault = false;
									opponentLeft = true;
									opponentDown = false;
									opponentUp = false;
									opponentRight = false;
									opponentFlip = false;
								case 'down' | 'Down':
									undyne = false;
									opponentDefault = false;
									opponentLeft = false;
									opponentDown = true;
									opponentUp = false;
									opponentRight = false;
									opponentFlip = false;
								case 'up' | 'Up':
									undyne = false;
									opponentDefault = false;
									opponentLeft = false;
									opponentDown = false;
									opponentUp = true;
									opponentRight = false;
									opponentFlip = false;
								case 'right' | 'Right':
									undyne = false;
									opponentDefault = false;
									opponentLeft = false;
									opponentDown = false;
									opponentUp = false;
									opponentRight = true;
									opponentFlip = false;
								case 'default' | 'Default':
									undyne = false;
									opponentDefault = true;
									opponentLeft = false;
									opponentDown = false;
									opponentUp = false;
									opponentRight = false;
									opponentFlip = false;
								case 'flip' | 'Flip':
									undyne = false;
									opponentDefault = false;
									opponentLeft = false;
									opponentDown = false;
									opponentUp = false;
									opponentRight = false;
									opponentFlip = true;
									}
	
								for (i in 0...opponentStrums.length) {
									if(opponentLeft) {
										FlxTween.tween(opponentStrums.members[i], {direction: 180, x: FlxG.width - 150, angle: 90, alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(opponentStrums.members[0], {y: 144}, 0.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(opponentStrums.members[1], {y: 256}, 0.25, {ease: FlxEase.quartInOut});
										FlxTween.tween(opponentStrums.members[2], {y: 368}, 0.3, {ease: FlxEase.quartInOut});
										FlxTween.tween(opponentStrums.members[3], {y: 480}, 0.35, {ease: FlxEase.quartInOut});
										opponentStrums.members[i].downScroll = false;
										//allowOpponentNoteSplash = true;
									} else if(opponentDown) {
										FlxTween.tween(opponentStrums.members[i], {direction: 90, y: FlxG.height - 150, angle: 0, alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(opponentStrums.members[0], {x: 92}, 0.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(opponentStrums.members[1], {x: 204}, 0.3, {ease: FlxEase.quartInOut});
										FlxTween.tween(opponentStrums.members[2], {x: 316}, 0.35, {ease: FlxEase.quartInOut});
										FlxTween.tween(opponentStrums.members[3], {x: 428}, 0.2, {ease: FlxEase.quartInOut});
										opponentStrums.members[i].downScroll = true;
										//allowOpponentNoteSplash = true;
									} else if(opponentUp) {
										FlxTween.tween(opponentStrums.members[i], {direction: 90, y: 50, angle: 0, alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(opponentStrums.members[0], {x: 92}, 0.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(opponentStrums.members[1], {x: 204}, 0.35, {ease: FlxEase.quartInOut});
										FlxTween.tween(opponentStrums.members[2], {x: 316}, 0.3, {ease: FlxEase.quartInOut});
										FlxTween.tween(opponentStrums.members[3], {x: 428}, 0.2, {ease: FlxEase.quartInOut});
										opponentStrums.members[i].downScroll = false;
										//allowOpponentNoteSplash = true;
									} else if(opponentRight) {
										FlxTween.tween(opponentStrums.members[i], {direction: 0, x: 50, angle: 270, alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(opponentStrums.members[0], {y: 480}, 0.2, {ease: FlxEase.quartInOut});
										FlxTween.tween(opponentStrums.members[1], {y: 368}, 0.25, {ease: FlxEase.quartInOut});
										FlxTween.tween(opponentStrums.members[2], {y: 256}, 0.3, {ease: FlxEase.quartInOut});
										FlxTween.tween(opponentStrums.members[3], {y: 144}, 0.35, {ease: FlxEase.quartInOut});
										opponentStrums.members[i].downScroll = false;
										//allowOpponentNoteSplash = true;
									} else if(opponentDefault) {
										if(ClientPrefs.downScroll) {
											FlxTween.tween(opponentStrums.members[i], {direction: 90, y: FlxG.height - 150, angle: 0, alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
											FlxTween.tween(opponentStrums.members[0], {x: 92}, 0.2, {ease: FlxEase.quartInOut});
											FlxTween.tween(opponentStrums.members[1], {x: 204}, 0.3, {ease: FlxEase.quartInOut});
											FlxTween.tween(opponentStrums.members[2], {x: 316}, 0.35, {ease: FlxEase.quartInOut});
											FlxTween.tween(opponentStrums.members[3], {x: 428}, 0.2, {ease: FlxEase.quartInOut});
											opponentStrums.members[i].downScroll = true;
										} else {
											FlxTween.tween(opponentStrums.members[i], {direction: 90, y: 50, angle: 0, alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
											FlxTween.tween(opponentStrums.members[0], {x: 92}, 0.2, {ease: FlxEase.quartInOut});
											FlxTween.tween(opponentStrums.members[1], {x: 204}, 0.35, {ease: FlxEase.quartInOut});
											FlxTween.tween(opponentStrums.members[2], {x: 316}, 0.3, {ease: FlxEase.quartInOut});
											FlxTween.tween(opponentStrums.members[3], {x: 428}, 0.2, {ease: FlxEase.quartInOut});
											opponentStrums.members[i].downScroll = false;
											}
										//allowOpponentNoteSplash = true;
									} else if(opponentFlip) {
										if(ClientPrefs.downScroll) {
											FlxTween.tween(opponentStrums.members[i], {direction: 90, y: 50, angle: 0, alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
											FlxTween.tween(opponentStrums.members[0], {x: 92}, 0.2, {ease: FlxEase.quartInOut});
											FlxTween.tween(opponentStrums.members[1], {x: 204}, 0.35, {ease: FlxEase.quartInOut});
											FlxTween.tween(opponentStrums.members[2], {x: 316}, 0.3, {ease: FlxEase.quartInOut});
											FlxTween.tween(opponentStrums.members[3], {x: 428}, 0.2, {ease: FlxEase.quartInOut});
											opponentStrums.members[i].downScroll = false;
										} else {
											FlxTween.tween(opponentStrums.members[i], {direction: 90, y: FlxG.height - 150, angle: 0, alpha: 1}, 0.2, {ease: FlxEase.quartInOut});
											FlxTween.tween(opponentStrums.members[0], {x: 92}, 0.2, {ease: FlxEase.quartInOut});
											FlxTween.tween(opponentStrums.members[1], {x: 204}, 0.3, {ease: FlxEase.quartInOut});
											FlxTween.tween(opponentStrums.members[2], {x: 316}, 0.35, {ease: FlxEase.quartInOut});
											FlxTween.tween(opponentStrums.members[3], {x: 428}, 0.2, {ease: FlxEase.quartInOut});
											opponentStrums.members[i].downScroll = true;
											}
									//allowOpponentNoteSplash = true;
								}
						} //T O O  M U C H  C O D E
					}
				
				case 'BG Freaks Expression':
					if(bgGirls != null) bgGirls.swapDanceType();
	
				case 'Relapse Shoot':
					if(ClientPrefs.mechanics || mechanics)
						{
					switch(value1) {
						case 'Normal' | 'normal' | 'NORMAL':
							relapseShoot();
						case 'Fast' | 'fast' | 'FAST':
							relapseShootButFast();
						case 'Instakill' | 'instakill' | 'INSTAKILL':
							relapseShootButInstakill();
						case 'Speedy' | 'speedy' | 'SPEEDY':
							relapseShootButFuckingQuick();
						default:
							relapseShoot();
					}
				}
	
					case 'Flash Background':
						var fadeTime:Float = Std.parseFloat(value1);
						var visibility:Float = Std.parseFloat(value3);
						if(value3.trim()=='' || value3.trim()== null || value3.trim()=='null') visibility = 0.6;
						if(value2.trim()=='')value2='#FFFFFF';
						if(value1.trim()=='') fadeTime = 0;
						if(fadeTime <= 0)
						{
							if(visibility <= 0)
								fadeWhiteFlash(0.3, value2, 0.6);
							else
								fadeWhiteFlash(0.3, value2, visibility);
						}else{	
							if(visibility <= 0)
								fadeWhiteFlash(fadeTime, value2, 0.6);
							else
								fadeWhiteFlash(fadeTime, value2, visibility);
						}
	
				case 'Alter HUD Transparency':
					var alphaValue:Float = Std.parseFloat(value1);
					var timer:Float = Std.parseFloat(value2);
	
					FlxTween.tween(camHUD, {alpha: alphaValue}, timer, {ease: FlxEase.sineInOut});
	
					/*if(val2 <= 0)
					{
						hudTransitionSpeed = newValue;
					}
					else
					{
						hudTransitionTween = FlxTween.tween(this, {HUDTransitionSpeed: newValue}, val2, {ease: FlxEase.quartInOut, onComplete:
							function (twn:FlxTween)
							{
								hudTransitionTween = null;
							}
						}*/
					case 'Change Scroll Speed':
					if(ClientPrefs.mechanics)
					{
						if (songSpeedType == "constant" && ClientPrefs.events)
							return;
						var val1:Float = Std.parseFloat(value1);
						var val2:Float = Std.parseFloat(value2);
						if(Math.isNaN(val1)) val1 = 1;
						if(Math.isNaN(val2)) val2 = 0;
	
						var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;
	
						if(val2 <= 0)
						{
							songSpeed = newValue;
						}
						else
						{
							songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2, {ease: FlxEase.quartInOut, onComplete:
								function (twn:FlxTween)
								{
									songSpeedTween = null;
								}
							});
						}
					}
				
	
				case 'Set Property':
					var killMe:Array<String> = value1.split('.');
					if(killMe.length > 1) {
						Reflect.setProperty(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length-1], value2);
					} else {
						Reflect.setProperty(this, value1, value2);
					}
			case 'Alter Camera Bouncing':
					if(ClientPrefs.camZooms) {
						var BNCEIntensity:Float = Std.parseFloat(value2);
						var BNCEBeats:Float = Std.parseFloat(value1);
						if(Math.isNaN(BNCEIntensity)) BNCEIntensity = 0;
						if(Math.isNaN(BNCEBeats)) BNCEBeats = 4;
	
						zoomBeat = BNCEBeats;
						zoomBounce = BNCEIntensity;
					}
						
				case 'Cinematic Bars':
					var barSpeed:Float = Std.parseFloat(value1);
					var barThickness:Float = Std.parseFloat(value2);
	
					switch(value3)
					{
						case 'add' | 'Add' | 'ADD':
							addCinematicBars(barSpeed, barThickness); //bruh cant use ? because is only when creating a function (jason)
						case 'remove' | 'Remove' | 'REMOVE':
							removeCinematicBars(barSpeed);
					}
	
				case 'Alter Camera Zoom':
					var zoomValue:Float = Std.parseFloat(value1);
					var timeTween:Float = Std.parseFloat(value2);
	
					if(ClientPrefs.camZooms) {
					if(Math.isNaN(zoomValue)) zoomValue = 1;
					if (Math.isNaN(timeTween)) timeTween = 0.5;
	
					if(timeTween <= 0)
					{
						camGame.zoom = zoomValue;
					}else{
						camZoomTween = FlxTween.tween(camGame, {zoom: zoomValue}, timeTween, {ease: FlxEase.sineInOut, onComplete: 
							function (twn:FlxTween)
								{
									camZoomTween = null;
								}
							});
					}
					defaultCamZoom = zoomValue;
				}
	
				//need to figure out how to make notes invisible
				case 'Set Strum Visibility':
					var timer = Std.parseFloat(value3);
	
					for (i in 0...playerStrums.length) {
					switch(value1) {
					 case 'false' | 'False':
						FlxTween.tween(playerStrums.members[i], {alpha: 0}, timer, {ease: FlxEase.sineInOut});
					
					case 'true' | 'True':
						FlxTween.tween(playerStrums.members[i], {alpha: 1}, timer, {ease: FlxEase.sineInOut});
					}
					}
	
					for (i in 0...opponentStrums.length) {
						switch(value2) {
						 case 'false' | 'False':
							FlxTween.tween(opponentStrums.members[i], {alpha: 0}, timer, {ease: FlxEase.sineInOut});
						
						case 'true' | 'True':
							FlxTween.tween(opponentStrums.members[i], {alpha: 1}, timer, {ease: FlxEase.sineInOut});
						}
						}
	
					case 'Do Health Tween':
						if(ClientPrefs.mechanics || mechanics) {
						var val1 = Std.parseFloat(value1);
						var val2 = Std.parseFloat(value2);
						FlxTween.tween(this, {health: val1}, val2, {ease: FlxEase.sineInOut});
						}
	
						//test purposes only
					case 'Tween Song Lenght':
						var val1 = Std.parseFloat(value1);
						var val2 = Std.parseFloat(value2);
						if(value1 == "default")
						FlxTween.tween(this, {songLength: FlxG.sound.music.length * 1000}, 3, {ease: FlxEase.sineInOut});
						else
						FlxTween.tween(this, {songLength: val1 * 1000}, val2, {ease: FlxEase.sineInOut});
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection(?id:Int = 0, isNote:Bool = false):Void {

		if (gf != null && SONG.notes[id].gfSection)
		{
			var yOffsetB:Int = 0;
			var xOffsetB:Int = 0;
			if (ClientPrefs.camMove){
				if (gf.animation.curAnim.name.startsWith('singUP')){
					yOffsetB = -40;
					xOffsetB = 0;
				}
				else if (gf.animation.curAnim.name.startsWith('singDOWN')){
					yOffsetB = 40;
					xOffsetB = 0;
				}
				else if (gf.animation.curAnim.name.startsWith('singLEFT')){
					yOffsetB = 0;
					xOffsetB = -40;
				}
				else if (gf.animation.curAnim.name.startsWith('singRIGHT')){
					yOffsetB = 0;
					xOffsetB = 40;
				}
				else if (!gf.animation.curAnim.name.startsWith('sing')){
					yOffsetB = 0;
					xOffsetB = 0;
				}
			}
			camFollow.set(gf.getMidpoint().x + xOffsetB, gf.getMidpoint().y + yOffsetB);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[id].mustHitSection)
		{
			moveCamera(true, isNote);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false, isNote);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool, isNote:Bool = false, yOffsetB:Float = 0, xOffsetB:Float = 0, yOffsetD:Float = 0, xOffsetD:Float = 0)
	{
		if (isNote && ClientPrefs.camMove){
			if (boyfriend.animation.curAnim.name.startsWith('singUP')){
				yOffsetB = -40;
				xOffsetB = 0;
			}
			else if (boyfriend.animation.curAnim.name.startsWith('singDOWN')){
				yOffsetB = 40;
				xOffsetB = 0;
			}
			else if (boyfriend.animation.curAnim.name.startsWith('singLEFT')){
				yOffsetB = 0;
				xOffsetB = -40;
			}
			else if (boyfriend.animation.curAnim.name.startsWith('singRIGHT')){
				yOffsetB = 0;
				xOffsetB = 40;
			}
			else if (!boyfriend.animation.curAnim.name.startsWith('sing') || !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection){
				yOffsetB = 0;
				xOffsetB = 0;
			}

			if (dad.animation.curAnim.name.startsWith('singUP')){
				yOffsetD = -40;
				xOffsetD = 0;
			}
			else if (dad.animation.curAnim.name.startsWith('singDOWN')){
				yOffsetD = 40;
				xOffsetD = 0;
			}
			else if (dad.animation.curAnim.name.startsWith('singLEFT')){
				yOffsetD = 0;
				xOffsetD = -40;
			}
			else if (dad.animation.curAnim.name.startsWith('singRIGHT')){
				yOffsetD = 0;
				xOffsetD = 40;
			}
			else if (!dad.animation.curAnim.name.startsWith('sing') || PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection){
				yOffsetD = 0;
				xOffsetD = 0;
			}
		}
		
		if(isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150 + xOffsetD, dad.getMidpoint().y - 100 + yOffsetD);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100 + xOffsetB, boyfriend.getMidpoint().y - 100 + yOffsetB);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	public function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	//Any way to do this without using a different function? kinda dumb
	private function onSongComplete()
	{
		finishSong(false);
	}
	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}
		
		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement(
				['episode1', 
				'episode2', 
				'episode1_nomiss', 
				'episode2_nomiss', 
				'malfunction_nomiss', 
				'relapse_nomiss', 
				'malfunction_tryhard', 
				'episode1_SFC', 
				'episode2_SFC', 
				'episode1_suicide', 
				'episode2_suicide']);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end
		
		#if LUA_ALLOWED
		var ret:Dynamic = callOnLuas('onEndSong', []);
		#else
		var ret:Dynamic = FunkinLua.Function_Continue;
		#end

		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}

			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('funkinAVI/menu/MenuMusic'));

					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new StoryMenuState());
					FlxG.mouse.visible = true;

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					if (difficulty == null)
							difficulty = 'Hard';

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				WeekData.loadTheFirstEnabledMod();
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		ClientPrefs.saveSettings(); //maybe fix or smth
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public static function getUiSkin(?uiSkin:String = 'classic', ?file:String = '', ?alt:String = '', ?numSkin:Bool = false, ?num:Int = 0)
	{
		switch(curStage)
		{
			case 'Studio' | 'Forest' | 'EndlessLoop' | 'ForestNEW' | 'Office':
				var path:String = 'judgements/funkinAVI/'
					+ (numSkin ? 'numbers/' : '')
					+ uiSkin
					+ '/'
					+ (numSkin ? 'num' : file)
					+ (numSkin ? Std.string(num) : '')
					+ alt;
				if (!Paths.fileExists('images/' + path + '.png', IMAGE))
					path = 'judgements/funkinAVI/'
						+ (numSkin ? 'numbers/' : '')
						+ 'funkinAVI/'
						+ (numSkin ? 'num' : file)
						+ (numSkin ? Std.string(num) : '')
						+ alt;
				return path;
			default:
				var path:String = 'judgements/'
					+ (numSkin ? 'numbers/' : '')
					+ uiSkin
					+ '/'
					+ (numSkin ? 'num' : file)
					+ (numSkin ? Std.string(num) : '')
					+ alt;
				if (!Paths.fileExists('images/' + path + '.png', IMAGE))
					path = 'judgements/'
						+ (numSkin ? 'numbers/' : '')
						+ 'classic/'
						+ (numSkin ? 'num' : file)
						+ (numSkin ? Std.string(num) : '')
						+ alt;
				return path;
		}
		
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		// trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;
		
		if (ClientPrefs.keAccuracy)
			totalNotesHit += Etterna.wife3(-noteDiff, Conductor.safeZoneOffset / 166);

		// tryna do MS based judgment due to popular demand
		var daRating:String = Conductor.judgeNote(note, noteDiff / playbackRate);

			if (ClientPrefs.keAccuracy)
		{
			if(ClientPrefs.mechanics)
			{
				if(curStage == 'WaltStage')
				{
					switch (daRating)
					{
				
					case 'shit':
						score = -300;
						combo = 0;
						songMisses++;
						totalMisses++;
						health -= 0;
						shits++;
					case 'bad':
						daRating = 'bad';
						score = 0;
						health -= 0;
						bads++;
					case 'good':
						daRating = 'good';
						score = 200;
						if (health < 2)
							health += 0;
						goods++;
					case 'sick':
						if (health < 2)
							health += 0;
						sicks++;
					case "marvelous": // marvelous
						totalNotesHit += 1;
							if (health < 2)
								health += 0;
						marvelouses++;
					}
				}else{
					switch (daRating)
					{
					case 'shit':
						score = -300;
						combo = 0;
						songMisses++;
						totalMisses++;
						health -= 0.1;
						shits++;
					case 'bad':
						daRating = 'bad';
						score = 0;
						health -= 0.06;
						bads++;
					case 'good':
						daRating = 'good';
						score = 200;
						goods++;
					case 'sick':
						if (health < 2)
							health += 0.04;
						sicks++;
					case "marvelous": // marvelous
						totalNotesHit += 1;
							if (health < 2)
								health += 0.08;
						marvelouses++;
					}		
				}
			}else{
				switch (daRating)
				{
				case 'shit':
					score = -300;
					combo = 0;
					songMisses++;
					totalMisses++;
					health -= 0.1;
					shits++;
				case 'bad':
					daRating = 'bad';
					score = 0;
					health -= 0.06;
					bads++;
				case 'good':
					daRating = 'good';
					score = 200;
					goods++;
				case 'sick':
					if (health < 2)
						health += 0.04;
					sicks++;
				case "marvelous": // marvelous
					totalNotesHit += 1;
						if (health < 2)
							health += 0.08;
					marvelouses++;
				}		
			}
			
		}
		else
		{
			if(ClientPrefs.mechanics)
			{
				if(curStage == 'WaltStage')
				{
					switch(daRating)
					{
						case "shit": // shit
						totalNotesHit += 0;
						health -= 0.04;
						shits++;
						case "bad": // bad
							totalNotesHit += 0.5;
							health -= 0.01;
							bads++;
						case "good": // good
							totalNotesHit += 0.75;
							health += 0.005;
							goods++;
						case "sick": // sick
							if (!ClientPrefs.marvelouses)
								totalNotesHit += 1;
							else
								totalNotesHit += 0.95;
							health += 0.02;
							sicks++;
						case "marvelous": // marvelous
							totalNotesHit += 1;
							health += 0.015;
							marvelouses++;
					}
						
				}else{
					switch(daRating)
					{
						case "shit": // shit
						totalNotesHit += 0;
						shits++;
						case "bad": // bad
							totalNotesHit += 0.5;
							bads++;
						case "good": // good
							totalNotesHit += 0.75;
							goods++;
						case "sick": // sick
							if (!ClientPrefs.marvelouses)
								totalNotesHit += 1;
							else
								totalNotesHit += 0.95;
							sicks++;
						case "marvelous": // marvelous
							totalNotesHit += 1;
							marvelouses++;
					}
				}
			}else{
				switch(daRating)
				{
					case "shit": // shit
						totalNotesHit += 0;
						shits++;
					case "bad": // bad
						totalNotesHit += 0.5;
						bads++;
					case "good": // good
						totalNotesHit += 0.75;
						goods++;
					case "sick": // sick
						if (!ClientPrefs.marvelouses)
							totalNotesHit += 1;
						else
							totalNotesHit += 0.95;
						sicks++;
					case "marvelous": // marvelous
						totalNotesHit += 1;
						marvelouses++;
					}
			}
			
		if (ClientPrefs.marvelouses == true)
		{
			if (daRating == 'marvelous' && !note.noteSplashDisabled)
			{
				spawnNoteSplashOnNoteMarvelous(note);
			}
		}
			if (daRating == 'sick' && !note.noteSplashDisabled)
			{
				spawnNoteSplashOnNoteSick(note);
			}
			if(daRating == 'good' && !note.noteSplashDisabled)
			{
				spawnNoteSplashOnNote(note);
			}
			if(daRating == 'bad' || daRating == 'shit' && !note.noteSplashDisabled)
			{
				spawnNoteSplashOnNoteShit(note);
			}

		if (!practiceMode && !cpuControlled)
		{
			songScore += score;
			songHits++;
			totalPlayed++;
			RecalculateRating();

			if (ClientPrefs.scoreZoom && hudStyle != 'Vanilla')
			{
				if (scoreTxtTween != null)
				{
					scoreTxtTween.cancel();
				}
				scoreTxt.scale.x = 1.075;
				scoreTxt.scale.y = 1.075;
				scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween)
					{
						scoreTxtTween = null;
					}
				});
			}
		}

		/* if (combo > 60)
			daRating = 'sick';
		else if (combo > 12)
			daRating = 'good'
		else if (combo > 4)
			daRating = 'bad';
	 */

		var uiSkin:String = '';
		var altPart:String = isPixelStage ? '-pixel' : '';

		switch (ClientPrefs.uiSkin)
		{
			case 'Classic':
				uiSkin = 'classic';
			case 'Bedrock':
				uiSkin = 'bedrock';
			case 'BEAT!':
				uiSkin = 'beat';
			case 'BEAT! Gradient':
				uiSkin = 'beat-alt';
			case 'Demolition':
				uiSkin = 'demolition';
			case 'Matt :)':
				uiSkin = 'matt';
			case 'Funkin.avi':
				uiSkin = 'funkinAVI';
		}

		rating.loadGraphic(Paths.image(getUiSkin(uiSkin, daRating, altPart)));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		rating.visible = !ClientPrefs.hideHud;
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(getUiSkin(uiSkin, 'combo', altPart)));
                if(combo > 5)
 			insert(members.indexOf(strumLineNotes), comboSpr);
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.visible = !ClientPrefs.hideHud;
		comboSpr.x += ClientPrefs.comboOffset[0];
		comboSpr.y -= ClientPrefs.comboOffset[1];

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		insert(members.indexOf(strumLineNotes), rating);

		if (!isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			// Std.int(i)
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(getUiSkin(uiSkin, '', altPart, true, Std.int(i))));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
			numScore.visible = !ClientPrefs.hideHud;

			//if (combo >= 10 || combo == 0)
				insert(members.indexOf(strumLineNotes), numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {
			startDelay: Conductor.crochet * 0.001 / playbackRate
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}
	}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						if (ClientPrefs.antiMash){
							canMiss = false;
						}
						else {
							canMiss = true;
						}
					}
				});
				sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}
							
						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else if (canMiss) {
					noteMissPress(key);
					callOnLuas('noteMissPress', [key]);
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}
	
	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;
		var controlHoldArray:Array<Bool> = [left, down, up, right];
		
		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit 
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote);
				}
			});

			if (controlHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			}
			else if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;
		health -= daNote.missHealth * healthLoss;
		
		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		if(!practiceMode) songScore -= 10;
		
		totalPlayed++;
		RecalculateRating();

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char != null && char.hasMissAnimations)
		{
			var daAlt = '';
			if(daNote.noteType == 'Alt Animation') daAlt = '-alt';

			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daAlt;
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if (!boyfriend.stunned)
		{
			health -= 0.05 * healthLoss;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if(ClientPrefs.ghostTapping) return;

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
	}

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = "";

			var curSection:Int = Math.floor(curStep / 16);
			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim || note.noteType == 'Alt Animation') {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if(note.gfNote) {
				char = gf;
			}

			if(char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}

		if(curStage == 'Couch' && !note.isSustainNote || note.animation.curAnim.name.endsWith('end'))
		{
			switch(note.noteType)
			{
				case 'AVI Sing':
					new FlxTimer().start(1.5, function(tmr:FlxTimer)
					{
						aviMick.animation.play('idle');
					});
				case 'Rookie Sing':
					new FlxTimer().start(1.5, function(tmr:FlxTimer)
					{
						rookieMick.animation.play('idle');
					});
				case 'WI Sing':
					new FlxTimer().start(1.5, function(tmr:FlxTimer)
					{
						WIMick.animation.play('idle');
					});
				case 'Randy Sing':
					new FlxTimer().start(1.5, function(tmr:FlxTimer)
					{
						randyMick.animation.play('idle');
					});
				case 'Cog Sing':
					new FlxTimer().start(1.5, function(tmr:FlxTimer)
					{
						cogMick.animation.play('idle');
					});
			}
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % 4, time);
		note.hitByOpponent = true;
		note.alpha = 0;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if(note.hitCausesMiss) {
				//noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				
				if(!note.noMissAnimation)
				{
					switch(note.noteType) {

					case 'Darkness Note':
						var shadow:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('lurkingShadow'));
						//shadow.screenCenter();
						shadow.cameras = [camHUD];
						shadow.alpha = 1;
						add(shadow);
						FlxTween.tween(shadow, {alpha: 0}, 2, {ease: FlxEase.quadInOut, startDelay: 5});
						healthDrain = 0.005;
						noteMiss(note);

					case 'Instakill Note':
						if(boyfriend.animation.getByName('hurt') != null) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
						health -= 500;

					case 'Move Window Note':
						//Lib.application.window.move(FlxG.random.int(0, Std.int(Capabilities.screenResolutionX - FlxG.width)), FlxG.random.int(0, Std.int(Capabilities.screenResolutionY - FlxG.height)));

						//goes more smoother, spoiler: is amazing
						FlxTween.tween(
						Lib, 
						{'application.window.x': FlxG.random.int(0, Std.int(Capabilities.screenResolutionX - FlxG.width)), 
						'application.window.y': FlxG.random.int(0, Std.int(Capabilities.screenResolutionY - FlxG.height))}, 
						0.2, 
						{ease: FlxEase.expoInOut /**thx robtop**/}
						);

						health -= 0.02;

					case 'Fuck Strums Note':
						isDownscroll = FlxG.random.bool(50);
						notes.forEach(function(note:Note){note.downscrollNote = isDownscroll;});
						for (i in 0...playerStrums.length) {
							if (i == 0) {
								playerStrums.members[i].x = FlxG.random.int(100, Std.int(FlxG.width / 3));
								if (isDownscroll)
									playerStrums.members[i].y = FlxG.random.int(Std.int(FlxG.height / 2), FlxG.height - 100);
								else
									playerStrums.members[i].y = FlxG.random.int(0, 300);
									
							} else {
								var futurex = FlxG.random.int(Std.int(playerStrums.members[i - 1].x) + 80, Std.int(playerStrums.members[i - 1].x) + 400);
								if (futurex > FlxG.width - 100)
									futurex = FlxG.width - 100;
								playerStrums.members[i].x = futurex;
			
								playerStrums.members[i].y = FlxG.random.int(Std.int(playerStrums.members[0].y - 50), Std.int(playerStrums.members[0].y + 50));
							}
						}
						health -= 0.02;

					/*case 'One-Shot Error Note': //you can blame Yama for accidentally pitching this idea when I showed him the new Malfunction chart XD

						//demo like whats the point, is literally the same as error note bru 🗿

						if(ClientPrefs.language == "Spanish") {
							if(FlxG.random.bool(10)) Application.current.window.alert("Apestas, LMAO", 'Nota Sobre Tu Habilidad:');
							//10% of probability
							  else Application.current.window.alert("Mensaje: if(note.noteType = 'Nota De Errror') { trace('0 vidas restantes, cerrando el juego...'); }", 
							  'Error en Funkin.avi.exe!:'
							  );
							  if(ClientPrefs.restart)
								TitleState.restartGame();
								else 
								System.exit(0); 
							} else {
								if(FlxG.random.bool(10)) Application.current.window.alert("Fuck You, You Suck LMAO", 'Note About Your Skill:');
							  //10% of probability
								else Application.current.window.alert("Message: if(note.noteType = 'Error Note') { trace('0 lives left, closing game...'); }", 
								'Error On Funkin.avi.exe!:');
								if(ClientPrefs.restart)
									TitleState.restartGame();
									else 
									System.exit(0);
							}*/
						
					//tf
					case 'Flesh Note':

					case 'Error Note':
						switch(curStage)
						{
							case 'PixelWorld':
								crashLivesCounter -= 1;

								if(crashLivesCounter == -1)
								{
									endSong();
									trace('0 lives left, closing game...');
									FlxG.sound.play(Paths.sound('wiiCrash'), 1);
		                          
							if(ClientPrefs.language == "Spanish") {
								if(FlxG.random.bool(10)) Application.current.window.alert("Apestas, LMAO", 'Nota Sobre Tu Habilidad:');
								//10% of probability
								  else Application.current.window.alert("Mensaje: if(note.noteType = 'Nota De Errror') { trace('0 vidas restantes, cerrando el juego...'); }", 
								  'Error en Funkin.avi.exe!:'
								  );
								  if(ClientPrefs.restart)
									TitleState.restartGame();
									else 
									System.exit(0); 
								} else {
									if(FlxG.random.bool(10)) Application.current.window.alert("Fuck You, You Suck LMAO", 'Note About Your Skill:');
								  //10% of probability
									else Application.current.window.alert("Message: if(note.noteType = 'Error Note') { trace('0 lives left, closing game...'); }", 
									'Error On Funkin.avi.exe!:');
									if(ClientPrefs.restart)
										TitleState.restartGame();
										else 
										System.exit(0);
								}
							}
								if(ClientPrefs.language == "English") crashLives.text = 'Lives: ${crashLivesCounter}';
								else crashLives.text = 'Vidas: ${crashLivesCounter}';
								crashLivesIcon.animation.play('OMFG IT GLITCHES');
								new FlxTimer().start(0.25, function(tmr:FlxTimer)
								{
									crashLivesIcon.animation.play('idle');
								});
								FlxTween.tween(crashLives, {x: 620}, 0.01);
								FlxTween.tween(crashLivesIcon, {x: 570}, 0.01);
								FlxTween.tween(crashLives, {x: 585}, 0.01, {startDelay: 0.1});
								FlxTween.tween(crashLivesIcon, {x: 535}, 0.01, {startDelay: 0.1});
								FlxTween.tween(crashLives, {x: 610}, 0.01, {startDelay: 0.2});
								FlxTween.tween(crashLivesIcon, {x: 560}, 0.01, {startDelay: 0.2});
								FlxTween.tween(crashLives, {x: 595}, 0.01, {startDelay: 0.3});
								FlxTween.tween(crashLivesIcon, {x: 545}, 0.01, {startDelay: 0.3});
								FlxTween.tween(crashLives, {x: 600}, 0.01, {startDelay: 0.4});
								FlxTween.tween(crashLivesIcon, {x: 550}, 0.01, {startDelay: 0.4});
							default:
								endSong();
								FlxG.sound.play(Paths.sound('wiiCrash'), 1);
								Application.current.window.alert('lime.app.Application: function goodNoteHit: note.noteType = "Error Note": closing game...');
								System.exit(0);
						}
						

					case 'Flip Note':
						new FlxTimer().start(0.01, function(tmr:FlxTimer)
						{
								FlxTween.tween(camHUD, {angle: camHUD.angle = 180}, 1, {ease: FlxEase.circInOut, type: PERSIST});
						});

						new FlxTimer().start(10, function(tmr:FlxTimer)
							{
									FlxTween.tween(camHUD, {angle: camHUD.angle = 0}, 1, {ease: FlxEase.circInOut, type: PERSIST});
							});
						health -= 0;

					case 'Poison Note':
						noteMiss(note);
						healthDrain = 0.20;
						health -= 0;

					case 'Hurt Note': //Hurt note
						if(boyfriend.animation.getByName('hurt') != null) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
						noteMiss(note);
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return; 
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note);
				if(combo > 9999) combo = 9999;
			}
			health += note.hitHealth * healthGain;

			function detectSpace()
			{
				if (FlxG.keys.justPressed.SPACE)
				{
					pressCounter += 1;
					trace('tap');
					pressedSpace = true;
					detectAttack = false;
				}
			}
			
			
			health += note.hitHealth * healthGain;

			if(!note.noAnimation) {
				var daAlt = '';
				if(note.noteType == 'Alt Animation') daAlt = '-alt';
	
				var animToPlay:String = '';
				switch (Std.int(Math.abs(note.noteData)))
				{
					case 0:
						animToPlay = 'singLEFT';
						if(curStage == 'Line')
						{
							boyfriend.x -= 1.2;
							boyfriend.y += 1.2;
							boyfriend.scale.x += 0.0012;
							boyfriend.scale.y += 0.0012;
						}
						/*if(ClientPrefs.camMove)
						{
							camFollow.x -= 15;
						}*/
					case 1:
						animToPlay = 'singDOWN';
						if(curStage == 'Line')
						{
							boyfriend.x -= 1.2;
							boyfriend.y += 1.2;
							boyfriend.scale.x += 0.0012;
							boyfriend.scale.y += 0.0012;
						}
						/*if(ClientPrefs.camMove)
						{
							camFollow.y += 15;
						}*/
					case 2:
						animToPlay = 'singUP';
						if(curStage == 'Line')
						{
							boyfriend.x -= 1.2;
							boyfriend.y += 1.2;
							boyfriend.scale.x += 0.0012;
							boyfriend.scale.y += 0.0012;
						}
						/*if(ClientPrefs.camMove)
						{
							camFollow.y -= 15;
						}*/
					case 3:
						animToPlay = 'singRIGHT';
						if(curStage == 'Line')
						{
							boyfriend.x -= 1.2;
							boyfriend.y += 1.2;
							boyfriend.scale.x += 0.0012;
							boyfriend.scale.y += 0.0012;
						}
						/*if(ClientPrefs.camMove)
						{
							camFollow.x += 15;
						}*/
				}

				if(note.gfNote) 
				{
					if(gf != null)
					{
						gf.playAnim(animToPlay + daAlt, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
					boyfriend.playAnim(animToPlay + daAlt, true);
					boyfriend.holdTimer = 0;
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}
	
					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			} else {
				playerStrums.forEach(function(spr:StrumNote)
				{
					spr.playAnim('confirm', true);
				});
			note.wasGoodHit = true;
			vocals.volume = 1;
			}
		}

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNoteShit(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplashShit(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplashShit(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'NoteSplashSkin/NOTE_splashes-Better';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		
		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splashShit:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splashShit.setupNoteSplashShit(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splashShit);
	}

	function spawnNoteSplashOnNoteMarvelous(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplashMarvelous(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplashMarvelous(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'NoteSplashSkin/NOTE_splashes-Better';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		
		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splashMarv:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splashMarv.setupNoteSplashMarvelous(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splashMarv);
	}

	function spawnNoteSplashOnNoteSick(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplashSick(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplashSick(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'NoteSplashSkin/NOTE_splashes-Better';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		
		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splashSick:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splashSick.setupNoteSplashSick(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splashSick);
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'NoteSplashSkin/NOTE_splashes-Better';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		
		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	/*function SetScaleMode (screenMode:Int = -1)
		{
			// Remember: Switch block do not fall through
			// in haxe, so there's no need for "break;"
			// for each case.
			var modeText = "Unknown";
			switch (screenMode)
			{
				case 1: FlxG.scaleMode = modeBase; modeText = "base";
				case 2: FlxG.scaleMode = modeFill; modeText = "fill";
				case 3: FlxG.scaleMode = modeFixed; modeText = "fixed";
				case 4: FlxG.scaleMode = modeRatio; modeText = "ratio";
				case 5: FlxG.scaleMode = modeRelative; modeText = "relative";
				case 6: FlxG.scaleMode = modeStage; modeText = "stage size";
				case 7: FlxG.scaleMode = modePixel; modeText = "pixel perfect";
			}
	 
			// Update debug text
			if (screenMode != -1)
				SCALEdebugText.text = "screen mode : " + modeText;
		}*/

		
			/**
			 * peak
			 * @param speed 
			 * @param thickness 
			 */
			function addCinematicBars(speed:Float, ?thickness:Float = 7)
			{
				if (cinematicBars["top"] == null)
				{
					cinematicBars["top"] = new FlxSprite(0, 0).makeGraphic(FlxG.width, Std.int(FlxG.height / thickness), FlxColor.BLACK);
					cinematicBars["top"].screenCenter(X);
					cinematicBars["top"].cameras = [camBars];
					cinematicBars["top"].y = 0 - cinematicBars["top"].height; // offscreen
					add(cinematicBars["top"]);
				}
		
				if (cinematicBars["bottom"] == null)
				{
					cinematicBars["bottom"] = new FlxSprite(0, 0).makeGraphic(FlxG.width, Std.int(FlxG.height / thickness), FlxColor.BLACK);
					cinematicBars["bottom"].screenCenter(X);
					cinematicBars["bottom"].cameras = [camBars];
					cinematicBars["bottom"].y = FlxG.height; // offscreen
					add(cinematicBars["bottom"]);
				}
		
				FlxTween.tween(cinematicBars["top"], {y: 0}, speed, {ease: FlxEase.circInOut});
				FlxTween.tween(cinematicBars["bottom"], {y: FlxG.height - cinematicBars["bottom"].height}, speed, {ease: FlxEase.circInOut});
			}
		
			function removeCinematicBars(speed:Float)
			{
				if (cinematicBars["top"] != null)
				{
					FlxTween.tween(cinematicBars["top"], {y: 0 - cinematicBars["top"].height}, speed, {ease: FlxEase.circInOut});
				}
		
				if (cinematicBars["bottom"] != null)
				{
					FlxTween.tween(cinematicBars["bottom"], {y: FlxG.height}, speed, {ease: FlxEase.circInOut});
				}
			}

		function relapseShootButFast()
			{
				dodged = false;
				shootin = true;	
				ohShitHeGonnaShootButFast();
					new FlxTimer().start(0.75, function(tmr:FlxTimer){
						FlxG.sound.play(Paths.sound('funkinAVI/relapseMechs/Shoot'), 0.6);
						dad.playAnim("attack", true);
						dad.specialAnim = true;
						new FlxTimer().start(0.1, function(tmr:FlxTimer) {
						if(!dodged) {
							FlxG.camera.shake(0.05, 0.05);
							health -= 0.4;
							trace("lmfao you got shot");
							dodged = false;
						} else {
							boyfriend.playAnim('dodge');
							dodged = false;
							shootin = false;
							health += 0.05;
						}
						});
					});
			}
		
			function ohShitHeGonnaShootButFast()
			{
				FlxG.sound.play(Paths.sound('funkinAVI/relapseMechs/Reload'), 0.6);
				holyShitMOVEBITCH.alpha = 1;
				holyShitMOVEBITCH.y = -420;
				//holyShitMOVEBITCH.rotateX = 0;
				dad.playAnim("reload", true);
				dad.specialAnim = true;
				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					FlxTween.tween(holyShitMOVEBITCH, {alpha: 0, y: -400}, 0.3, {ease: FlxEase.quadInOut});
				});
				pressCounter = 0;
			}

			function relapseShootButFuckingQuick()
				{
					dodged = false;
					shootin = true;	
					ohShitHeGonnaShootButFast();
						new FlxTimer().start(0.35, function(tmr:FlxTimer){
							FlxG.sound.play(Paths.sound('funkinAVI/relapseMechs/Shoot'), 0.6);
							dad.playAnim("attack", true);
							dad.specialAnim = true;
							new FlxTimer().start(0.1, function(tmr:FlxTimer) {
							if(!dodged) {
								FlxG.camera.shake(0.05, 0.05);
								health -= 0.4;
								trace("lmfao you fucking died to a mouse");
								dodged = false;
							} else {
								boyfriend.playAnim('dodge');
								dodged = false;
								shootin = false;
								health += 0.05;
							}
							});
						});
				}

			function relapseShootButInstakill()
				{
					dodged = false;
					shootin = true;	
					ohShitHeGonnaShoot();
						new FlxTimer().start(0.5, function(tmr:FlxTimer){
							FlxG.sound.play(Paths.sound('funkinAVI/relapseMechs/Shoot'), 0.6);
							dad.playAnim("attack", true);
							dad.specialAnim = true;
							new FlxTimer().start(0.1, function(tmr:FlxTimer) {
							if(!dodged) {
								FlxG.camera.shake(0.05, 0.05);
								health = 0;
								trace("lmfao you fucking died to a mouse");
								dodged = false;
							} else {
								boyfriend.playAnim('dodge');
								dodged = false;
								shootin = false;
								health += 0.05;
							}
							});
						});
				}

	function relapseShoot()
	{
		dodged = false;
		shootin = true;	
		ohShitHeGonnaShoot();
			new FlxTimer().start(1.1, function(tmr:FlxTimer){
				FlxG.sound.play(Paths.sound('funkinAVI/relapseMechs/Shoot'), 0.6);
				dad.playAnim("attack", true);
				dad.specialAnim = true;
				new FlxTimer().start(0.1, function(tmr:FlxTimer) {
				if(!dodged) {
					FlxG.camera.shake(0.05, 0.05);
					health -= 0.4;
					trace("lmfao you got shot depsite the fact this is nerfed");
					dodged = false;
				} else {
					boyfriend.playAnim('dodge');
					dodged = false;
					shootin = false;
					health += 0.05;
				}
				});
			});
	}

	function ohShitHeGonnaShoot()
	{
		FlxG.sound.play(Paths.sound('funkinAVI/relapseMechs/Reload'), 0.6);
		holyShitMOVEBITCH.alpha = 1;
		holyShitMOVEBITCH.y = -420;
		//holyShitMOVEBITCH.rotateX = 0;
		dad.playAnim("reload", true);
		dad.specialAnim = true;
		new FlxTimer().start(0.4, function(tmr:FlxTimer)
		{
			FlxTween.tween(holyShitMOVEBITCH, {alpha: 0, y: -400}, 0.3, {ease: FlxEase.quadInOut});
		});
		pressCounter = 0;
	}


	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			if (gf != null)
			{
				gf.playAnim('hairBlow');
				gf.specialAnim = true;
			}
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		if(gf != null)
		{
			gf.danced = false; //Sets head to the correct position once the animation ends
			gf.playAnim('hairFall');
			gf.specialAnim = true;
		}
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if(gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;

				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
				var achieve:String = checkForAchievement(['roadkill_enthusiast']);
				if (achieve != null) {
					startAchievement(achieve);
				} else {
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	var tankX:Float = 400;
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankAngle:Float = FlxG.random.int(-90, 45);

	function moveTank(?elapsed:Float = 0):Void
	{
		if(!inCutscene)
		{
			tankAngle += elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}

	private var preventLuaRemove:Bool = false;
	override function destroy() {
		preventLuaRemove = true;
		for (i in 0...luaArray.length) {
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		luaArray = [];

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		FlxAnimationController.globalSpeed = 1;
		FlxG.sound.music.pitch = 1;
		super.destroy();
		if (windowDad != null)
        {
        windowDad.close();
        }

		if(windowBoyfriend != null) {
			windowBoyfriend.close();
		}

		Lib.application.window.borderless = false;
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function removeLua(lua:FunkinLua) {
		if(luaArray != null && !preventLuaRemove) {
			luaArray.remove(lua);
		}
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}

		//health bar going crazy
		if(curStep % 2 == 0 && SONG.song == "Birthday") 
			{
				timeBar.createFilledBar(FlxColor.fromRGB(FlxG.random.int(1, 255), FlxG.random.int(1, 255), FlxG.random.int(1, 255)), FlxColor.fromRGB(FlxG.random.int(1, 255), FlxG.random.int(1, 255), FlxG.random.int(1, 255)));
				healthBar.createFilledBar(FlxColor.fromRGB(FlxG.random.int(1, 255), FlxG.random.int(1, 255), FlxG.random.int(1, 255)), FlxColor.fromRGB(FlxG.random.int(1, 255), FlxG.random.int(1, 255), FlxG.random.int(1, 255)));
				
				for(i in 0...9) {
				//Player strums one
				FlxTween.color(
					playerStrums.members[i], 
					0.8, 
					FlxColor.fromRGB(FlxG.random.int(1, 255), FlxG.random.int(1, 255), FlxG.random.int(1, 255)),  
					FlxColor.fromRGB(FlxG.random.int(1, 255), FlxG.random.int(1, 255), FlxG.random.int(1, 255)),
					{ease: FlxEase.expoOut}
				);

				//opponent ones
				FlxTween.color(
					opponentStrums.members[i], 
					0.8, 
					FlxColor.fromRGB(FlxG.random.int(1, 255), FlxG.random.int(1, 255), FlxG.random.int(1, 255)),  
					FlxColor.fromRGB(FlxG.random.int(1, 255), FlxG.random.int(1, 255), FlxG.random.int(1, 255)),
					{ease: FlxEase.expoOut}
				);
				}
			}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;
	
	
	
	
	override function beatHit()
	{
		super.beatHit();
		///getting working this, counting you only see it for a minute due to songLenght bugs
		if (curBeat % 1 == 0 && SONG.song == "Malfunction" && curStage == "PixelWorld")
			{
							var prevInt:Int = funnyTimebarThing;
						
					    	funnyTimebarThing = FlxG.random.int(1, 9, [funnyTimebarThing]);
						
							switch(funnyTimebarThing)
							{
							case 1: timeBar.createFilledBar(0xFF11C700, 0xFFFFF200);

							case 2: timeBar.createFilledBar(0xFF11C700, 0xFF0008FF);

							case 3: timeBar.createFilledBar(0xFF0008FF, 0xFF11C700);

							case 4: timeBar.createFilledBar(0xFFFFF200, 0xFFFF0000);

							case 5: timeBar.createFilledBar(0xFFFF0000, 0xFFFFF200);

							case 6: timeBar.createFilledBar(0xFFC78800, 0xFFFFF4BA);

							case 7: timeBar.createFilledBar(0xFFFFF4BA, 0xFFC78800);

							case 8: timeBar.createFilledBar(0xFF2E2E2E, 0xFFB7B7B7);

							case 9: timeBar.createFilledBar(0xFFB7B7B7, 0xFF2E2E2E);
						}
				}

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				//FlxG.log.add('CHANGED BPM!');
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[Math.floor(curStep / 16)].mustHitSection);
			setOnLuas('altAnim', SONG.notes[Math.floor(curStep / 16)].altAnim);
			setOnLuas('gfSection', SONG.notes[Math.floor(curStep / 16)].gfSection);
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
		}
		if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015 * camZoomingMult;
			camHUD.zoom += 0.03 * camZoomingMult;
		}

		if(ClientPrefs.iconBounce == "None")
		{
			//Don't know why Haxe won't let me code it the other way, but apparently, it wants it to look messier, so ig
		} else {
                        iconP1.scale.set(1.2, 1.2);
			iconP2.scale.set(1.2, 1.2);

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
		
		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance();
		}

		if(ClientPrefs.iconBounce == "Golden Apple")
		{
			if(hudStyle == 'Demolition')
			{
				var funny:Float = (healthBar.percent * 0.01) + 0.01;

				//health icon bounce but epic
				if (curBeat % gfSpeed == 0) {
					curBeat % (gfSpeed * 2) == 0 ? {
						iconP1.scale.set(0.86, 0.56);
						iconP2.scale.set(0.86, 1.06);

						FlxTween.angle(iconP1, -15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
						FlxTween.angle(iconP2, 15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
					} : {
						iconP1.scale.set(0.86, 1.06);
						iconP2.scale.set(0.86, 0.56);

						FlxTween.angle(iconP2, -15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
						FlxTween.angle(iconP1, 15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
					}

					FlxTween.tween(iconP1, {'scale.x': 0.78, 'scale.y': 0.78}, Conductor.crochet / 1250 * gfSpeed, {ease: FlxEase.quadOut});
					FlxTween.tween(iconP2, {'scale.x': 0.78, 'scale.y': 0.78}, Conductor.crochet / 1250 * gfSpeed, {ease: FlxEase.quadOut});

					iconP1.updateHitbox();
					iconP2.updateHitbox();
				}	
			}else{
				var funny:Float = (healthBar.percent * 0.01) + 0.01;

				//health icon bounce but epic
				if (curBeat % gfSpeed == 0) {
					curBeat % (gfSpeed * 2) == 0 ? {
						iconP1.scale.set(1.1, 0.8);
						iconP2.scale.set(1.1, 1.3);

						FlxTween.angle(iconP1, -15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
						FlxTween.angle(iconP2, 15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
					} : {
						iconP1.scale.set(1.1, 1.3);
						iconP2.scale.set(1.1, 0.8);

						FlxTween.angle(iconP2, -15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
						FlxTween.angle(iconP1, 15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
					}

					FlxTween.tween(iconP1, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / 1250 * gfSpeed, {ease: FlxEase.quadOut});
					FlxTween.tween(iconP2, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / 1250 * gfSpeed, {ease: FlxEase.quadOut});

					iconP1.updateHitbox();
					iconP2.updateHitbox();
				}	
			}
		}

		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
		{
			dad.dance();
		}

		switch (curStage)
		{
			
			case 'WaltStage':
				if(ClientPrefs.mechanics)
				{
					healthDrain = 0.4;
				}
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});

			case 'school':
				if(!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if(heyTimer <= 0) bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
					phillyWindow.color = phillyLightsColors[curLight];
					phillyWindow.alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
			case 'PixelWorld':
				if (curBeat % 8 == 4 && FlxG.random.bool(100))
				{
					glitchTimeColors = FlxG.random.int(11, 19);
					timeBar.updateBar();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		lastBeatHit = curBeat;

		//Modcharts/Events go here

		//NOTE: Before setting the modcharts/events here, make sure you test them in the Chart Editor first, just to be safe!
		switch(SONG.song)
		{
			case 'Isolated':
				if(curStep == 0)
				{
					if (hudStyle != 'Demolition') triggerEventNote('Alter HUD Transparency', '0', '0');
					triggerEventNote('Alter Camera Zoom', '0.8', '5');
				}
				if(curStep == 64)
				{
					triggerEventNote('Alter Camera Zoom', '1.05', '5.4');
				}
				if(curStep == 128)
				{
					triggerEventNote('Alter Camera Zoom', '0.9', '1');
				}
				if(curStep == 352)
				{
					triggerEventNote('Alter Camera Zoom', '1', '0.5');
				}
				if(curStep == 360)
				{
					triggerEventNote('Alter Camera Zoom', '1.05', '0.5');
				}
				if(curStep == 368)
				{
					triggerEventNote('Alter Camera Zoom', '1.1', '0.5');
				}
				if(curStep == 376)
				{
					triggerEventNote('Alter Camera Zoom', '1.15', '0.5');
				}
				if(curStep == 384)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.09');
					triggerEventNote('Flash Screen', '0', 'False');
					triggerEventNote('Alter Camera Zoom', '0.8', '1');
				}
				if(curStep == 392)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.15');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 400)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.09');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 408)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.15');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 416)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.09');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 424)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.15');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 432)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.09');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 448)
				{
					triggerEventNote('Flash Screen', '3', 'False');
					triggerEventNote('Add Camera Zoom', '0.04', '0.09');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 456)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.15');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 464)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.09');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 472)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.15');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 480)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.09');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 488)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.15');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 496)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.09');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 504)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.15');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 512)
				{
					triggerEventNote('Flash Screen', '0', 'False');
					triggerEventNote('Add Camera Zoom', '0.04', '0.09');
				}
				if(curStep == 520)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.15');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 528)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.09');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 536)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.15');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 544)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.09');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 552)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.15');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 560)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.09');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 568)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.15');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 576)
				{
					triggerEventNote('Flash Screen', '3', 'False');
					triggerEventNote('Add Camera Zoom', '0.04', '0.09');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 584)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.15');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 592)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.09');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 600)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.15');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 608)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.09');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 616)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.15');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 624)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.09');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 632)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.15');
					triggerEventNote('Flash Background', '', '');
				}
				if(curStep == 640)
				{
					triggerEventNote('Alter Camera Zoom', '1.35', '3.8');
				}
				if(curStep == 688)
				{
					triggerEventNote('Alter Camera Zoom', '0.8', '1');
				}
				if(curStep == 704)
				{
					triggerEventNote('Alter Camera Zoom', '1.35', '3.8');
				}
				if(curStep == 752)
				{
					triggerEventNote('Alter Camera Zoom', '0.8', '1');
				}
				if(curStep == 768)
				{
					triggerEventNote('Flash Screen', '0', '');
				}
				if(curStep == 832)
				{
					triggerEventNote('Flash Screen', '3', '');
				}
				if(curStep == 896)
				{
					triggerEventNote('Flash Screen', '0', '');
					triggerEventNote('Add Camera Zoom', '0.04', '0.05');
				}
				if(curStep == 904)
				{
					triggerEventNote('Add Camera Zoom', '0.04', '0.15');
					triggerEventNote('Flash Background', '', '');
				} //Man
			case 'Delusional':
				if(curStep == 0)
				{
					addCharacterToList("mickeyinsane", 1);
					addCharacterToList("mickeygiveup", 1);
					addCharacterToList("mickey", 1);
				}
				if(curStep == 464)
				{
					triggerEventNote('Change Character', 'dad', 'mickeyinsane');
				}
     			if(curStep == 128)
				{
					triggerEventNote('Flash Screen', '3', '');
				}
			    if(curStep == 456)
				{
					if(curStage == 'Studio')
					{
						if(!ClientPrefs.flashing) {
							FlxTween.tween(camHUD, {alpha: 1}, 1);
						}
						depression.alpha = 1;
					}
				}
			case 'Mercy':
				//Insert Events here
			case 'Twisted Grins':
				//Insert Events here
			case 'Bless':
				if(curStep == 192) {
					triggerEventNote('Add Camera Zoom', '0.013', '0.014');
					triggerEventNote('Alter Camera Zoom', '1.4', '2.3');
				}

				if(curStep == 223) {
					triggerEventNote('Change Scroll Speed', '1.2', '1.6');
				}

				if(curStep == 255) {
					triggerEventNote('Flash Screen', '0', 'false');
					triggerEventNote('Alter Camera Zoom', '0.9', '1');
				} 

				if(curStep == 376) {
					triggerEventNote('Change Scroll Speed', '1.35', '1.35');
				}

				if(curStep == 624) {
					triggerEventNote('Change Scroll Speed', '1.1', '0.9');
				}

				if(curStep == 640) {
					triggerEventNote('Add Camera Zoom', '0.014', '0.015');
				}

				if(curStep == 736) {
					triggerEventNote('Change Scroll Speed', '1.4', '0.9');
				}

				if(curStep == 752) {
					triggerEventNote('Add Camera Zoom', '', '');
				}

				if(curStep == 756) {
					triggerEventNote('Add Camera Zoom', '', '');
				}

				if(curStep == 762) {
					triggerEventNote('Add Camera Zoom', '', '');
				}

				if(curStep == 766) {
					triggerEventNote('Add Camera Zoom', '', '');
				}

				if(curStep == 768) {
					triggerEventNote('Add Camera Zoom', '', '');
				}

				if(curStep == 880) {
					triggerEventNote('Change Scroll Speed', '1.15', '0.5');
				}

				if(curStep == 1024) {
					triggerEventNote('Add Camera Zoom', '', '');
					triggerEventNote('Change Scroll Speed', '0.85', '0.8');
				}


				if(curStep == 1152) {
					triggerEventNote('Add Camera Zoom', '', '');
					triggerEventNote('Change Scroll Speed', '1.2', '0.3');
				}  
				if(curStep == 2176)
				{
					vault.alpha = 0;
					chains.alpha = 0;
					vaultSpook.alpha = 0;
					vaultINVERT.alpha = 1;
					chainsINVERT.alpha = 1;
					vaultSpookINVERT.alpha = 1;
					FlxTween.tween(healthBar, {alpha: 0}, 0.6);
					FlxTween.tween(healthBarBG, {alpha: 0}, 0.6);
					FlxTween.tween(iconP1, {alpha: 0}, 0.6);
					FlxTween.tween(iconP2, {alpha: 0}, 0.6);
					FlxTween.tween(timeBar, {alpha: 0}, 0.6);
					FlxTween.tween(timeBarBG, {alpha: 0}, 0.6);
					FlxTween.tween(timeTxt, {alpha: 0}, 0.6);
					FlxTween.tween(scoreTxt, {alpha: 0}, 0.6);
					Application.current.window.borderless = true; //ALT + F4 Supermarcy
					triggerEventNote('Flash Screen', '0', '');
					triggerEventNote('Change Character', 'bf', 'bfghost');
					if(!ClientPrefs.optimization) {
					addShaderToCamera('game', new WIBloomEffect(22));
					addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
					addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
					}
				}
				if(curStep == 2432)
				{
					vault.alpha = 1;
					chains.alpha = 1;
					vaultSpook.alpha = 1;
					vaultINVERT.alpha = 0;
					chainsINVERT.alpha = 0;
					vaultSpookINVERT.alpha = 0;
					triggerEventNote('Flash Screen', '3', '');
					//triggerEventNote('Change Character', 'bf', 'GraveyandBf');
					Application.current.window.borderless = false;
					FlxTween.tween(healthBar, {alpha: 1}, 0.6);
					FlxTween.tween(healthBarBG, {alpha: 1}, 0.6);
					FlxTween.tween(iconP1, {alpha: 1}, 0.6);
					FlxTween.tween(iconP2, {alpha: 1}, 0.6);
					FlxTween.tween(timeBar, {alpha: 1}, 0.6);
					FlxTween.tween(timeBarBG, {alpha: 1}, 0.6);
					FlxTween.tween(timeTxt, {alpha: 1}, 0.6);
					FlxTween.tween(scoreTxt, {alpha: 1}, 0.6);
					clearShaderFromCamera('game');
				}
			case 'War Dilemma':
				//Insert Events here
			case 'Isolated Old':
				if(!ClientPrefs.lowQuality) {
					timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF); //Like V1, it have the default Psych Engine color
			}

			if(curStep == 3) {
				triggerEventNote('Alter Camera Zoom', '0.7', '0.5');
			}

			if(curStep == 16) {
				triggerEventNote('Alter Camera Zoom', '1.2', '9.5');
			}

			if(curStep == 96) {
				triggerEventNote('Alter Camera Zoom', '0.8', '0.3');
			}

			if(curStep == 120) {
				triggerEventNote('Alter Camera Zoom', '1.5', '0.5');
			}

			if(curStep == 128) {
				triggerEventNote('Alter Camera Zoom', '0.8', '0.5');
			}

			if(curStep == 144) {
				triggerEventNote('Alter Camera Zoom', '1.2', '5.6');
			}

			if(curStep == 192) {
				triggerEventNote('Alter Camera Zoom', '0.85', '5');
			}

			if(curStep == 256) {
				triggerEventNote('Alter Camera Zoom', '1.2', '5.8');
			}

			if(curStep == 304) {
				triggerEventNote('Alter Camera Zoom', '0.8', '3.5');
			}

			if(curStep == 336) {
				triggerEventNote('Alter Camera Zoom', '1.4', '5.8');
			}

			if(curStep == 384) {
				triggerEventNote('Alter Camera Zoom', '0.8', '2');
			}

			if(curStep == 576) {
				triggerEventNote('Alter Camera Zoom', '1.5', '7.7');
			}

			if(curStep == 640) {
				triggerEventNote('Alter Camera Zoom', '0.85', '2');
			}

			if(curStep == 656) {
				triggerEventNote('Alter Camera Zoom', '1.2', '5.8');
			}

			if(curStep == 702) {
				triggerEventNote('Alter Camera Zoom', '0.8', '2');
			}

			if(curStep == 704) {
				triggerEventNote('Alter Camera Zoom', '0.8', '2');
			}

			if(curStep == 768) {
				triggerEventNote('Alter Camera Zoom', '1.5', '20');
			}

			if(curStep == 896) {
				triggerEventNote('Alter Camera Zoom', '0.8', '5');
			}

			if(curStep == 1024) {
				triggerEventNote('Alter Camera Zoom', '0.1'/*Get real moment*/, '1');
			}

			if(curStep == 1040) {
				triggerEventNote('Alter Camera Zoom', '1.5', '30');
			}

			if(curStep == 1280) {
				triggerEventNote('Alter Camera Zoom', '0.85', '1');
			}

			//It Didn't took me an hour
			//L
			//M
			//A
			//O

			case "Don't Cross!":
				if(!ClientPrefs.lowQuality) {
					timeBar.createFilledBar(0xFF000000, 0xFFE1E1E1);
			}
			if(CoolUtil.difficultyString() == 'HARD')
			{
				if(curStep == 4) {
					triggerEventNote('Alter Camera Zoom', '2.2', '11'); //?
					FlxTween.tween(camHUD, {alpha: 0}, 1);
				}

				if(curStep == 128) {
					triggerEventNote('Alter Camera Zoom', '0.8', '1.2');
					triggerEventNote('Flash Screen', '0', 'false'); 
					FlxTween.tween(camHUD, {alpha: 1}, 1);
					//Tween Shit
				}

				if(curStep == 192) {
					triggerEventNote('Alter Camera Zoom', '1.7', '4.7'); //?
				}

				if(curStep == 256) {
					triggerEventNote('Alter Camera Zoom', '0.8', '0.8');
					triggerEventNote('Flash Screen', '0', 'false');
				}
				
				if(curStep == 351) {
					triggerEventNote('Alter Camera Zoom', '1', '0.5');  
				}

				if(curStep == 358) {
					triggerEventNote('Alter Camera Zoom', '1.1', '0.5');
				}

				if(curStep == 364) {
					triggerEventNote('Alter Camera Zoom', '1.3', '0.5');
				}

				if(curStep == 369) {
					triggerEventNote('Alter Camera Zoom', '0.8', '0.8');
				}

				if(curStep == 384) {
					triggerEventNote('Alter Camera Zoom', '0.8', '0.8');
					triggerEventNote('Flash Screen', '0', 'false');
					triggerEventNote('Scroll Type', 'flip', 'flip');

					super.beatHit();

					if(curBeat % 1 == 0) {
						triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					}
				}
			}
			case 'Cycled Sins':
               if(curStep == 503) {
				triggerEventNote('Do Health Tween', '0.3', '4');
				}

				if(curStep == 572)
				{
					if(curStage == 'RelapseStage')
					{
						if(!ClientPrefs.lowQuality) {
							timeBar.createFilledBar(0xFF4D4D4D, 0xFF9E2222);
						}
						relapseCalm.alpha = 0;
						relapseChaos.alpha = 1;
					}
				}
			
		case 'Lunacy':
		if(curStep == 20) {
           timeBarBG.alpha = 0;
		   timeBar.alpha = 0;
		   timeTxt.alpha = 0;
		   iconP1.alpha = 0;
		   iconP2.alpha = 0;
		   healthBar.alpha = 0;
		   healthBarBG.alpha = 0;
		   scoreTxt.alpha = 0;
		   if(!ClientPrefs.hideJudgement) judgementCounter.alpha = 0;
		   if(hudStyle == "Demolition")
			{
				missIcon.alpha = 0;
				missesTxt.alpha = 0;
			}

		   for(i in 0...3) {
			playerStrums.members[i].alpha = 0;
			playerStrums.members[3].alpha = 0;
			opponentStrums.members[i].alpha = 0;
			opponentStrums.members[3].alpha = 0;
		   }
		 }

			if(curStep == 128) {
				triggerEventNote('Set Strum Visibility', 'false', 'true', '3');
			}

           if(curStep == 256) {
			FlxTween.tween(timeBar, {alpha: 1}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(timeBarBG, {alpha: 1}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(timeTxt, {alpha: 1}, 1, {ease: FlxEase.sineInOut});
		   }

		   if(curStep == 288)
			{
				FlxTween.tween(scoreTxt, {alpha: 1}, 1);
				if(!ClientPrefs.hideJudgement) FlxTween.tween(judgementCounter, {alpha: 1}, 1, {ease: FlxEase.sineInOut});
			}

		   if(curStep == 384) {
			FlxTween.tween(iconP2, {alpha: 1}, 1);
		   }

		   if(curStep == 480) {
			triggerEventNote('Set Strum Visibility', 'true', 'true', '1');
			FlxTween.tween(iconP1, {alpha: 1}, 1);
			FlxTween.tween(healthBar, {alpha: 1}, 1);
			FlxTween.tween(healthBarBG, {alpha: 1}, 1);
			if(hudStyle.toLowerCase() == 'demolition')
		   {
			FlxTween.tween(missIcon, {alpha: 1}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(missesTxt, {alpha: 1}, 1, {ease: FlxEase.sineInOut});
		   }
		}

		if(curStep == 896)
		{
			triggerEventNote('Set Strum Visibility', 'false', 'false', '0.4');
			FlxTween.tween(scoreTxt, {alpha: 0}, 1);
			if(!ClientPrefs.hideJudgement) FlxTween.tween(judgementCounter, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(timeBar, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(timeBarBG, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(timeTxt, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
			if(hudStyle.toLowerCase() == 'demolition')
		   {
			FlxTween.tween(missIcon, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(missesTxt, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
		   }
		}

		if(curStep == 912)
			{
				FlxTween.tween(this, {health: 1}, 1, {ease: FlxEase.expoOut});
			}

		if(curStep == 952)
			{
					FlxTween.tween(this, {health: 0.5}, 1, {ease: FlxEase.expoOut});
			}

		if(curStep == 975)
			{
					FlxTween.tween(this, {health: 0.2}, 1, {ease: FlxEase.expoOut});
			}

			if(curStep == 1008)
				{
					triggerEventNote('Set Strum Visibility', 'true', 'true', '0.3');
					FlxTween.tween(scoreTxt, {alpha: 0}, 1);
					if(!ClientPrefs.hideJudgement) FlxTween.tween(judgementCounter, {alpha: 1}, 0.4, {ease: FlxEase.sineInOut});
					FlxTween.tween(timeBar, {alpha: 1}, 0.4, {ease: FlxEase.sineInOut});
					FlxTween.tween(timeBarBG, {alpha: 1}, 0.4, {ease: FlxEase.sineInOut});
					FlxTween.tween(timeTxt, {alpha: 1}, 0.4, {ease: FlxEase.sineInOut});
					FlxTween.tween(scoreTxt, {alpha: 1}, 0.6);
					if(hudStyle.toLowerCase() == 'demolition')
				   {
					FlxTween.tween(missIcon, {alpha: 1}, 0.4, {ease: FlxEase.sineInOut});
					FlxTween.tween(missesTxt, {alpha: 1}, 0.4, {ease: FlxEase.sineInOut});
				   }
				}

		if(curStep == 1151) {
			FlxTween.tween(scoreTxt, {alpha: 0}, 1);
			if(!ClientPrefs.hideJudgement) FlxTween.tween(judgementCounter, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(timeBar, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(timeBarBG, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(timeTxt, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(iconP1, {alpha: 1}, 1);
			FlxTween.tween(healthBar, {alpha: 1}, 1);
			FlxTween.tween(healthBarBG, {alpha: 1}, 1);
			if(hudStyle.toLowerCase() == 'demolition')
		   {
			FlxTween.tween(missIcon, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(missesTxt, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
		   }
		}

		if(curStep == 1920)
			{
			FlxTween.tween(scoreTxt, {alpha: 0}, 1);
			if(!ClientPrefs.hideJudgement) FlxTween.tween(judgementCounter, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(timeBar, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(timeBarBG, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(iconP1, {alpha: 0}, 1);
			FlxTween.tween(iconP2, {alpha: 0}, 1);
			FlxTween.tween(healthBar, {alpha: 0}, 1);
			FlxTween.tween(healthBarBG, {alpha: 0}, 1);
			for(i in 0...3) {
			playerStrums.members[i].alpha = 1;
			playerStrums.members[3].alpha = 1;
			opponentStrums.members[i].alpha = 1;
			opponentStrums.members[3].alpha = 1;
			}
			if(hudStyle.toLowerCase() == 'demolition')
		   {
			FlxTween.tween(missIcon, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(missesTxt, {alpha: 0}, 1, {ease: FlxEase.sineInOut});
		   }

		   triggerEventNote("Set Strum Visibility", 'false', 'true', '1');
			}

			if(curStep == 2032)
				triggerEventNote("Set Strum Visibility", 'true', 'false', '1');

			if(curStep == 2109)
				triggerEventNote('Tween Song Lenght', '500', '3');

			case 'Lunacy Legacy': //Streamer Build 
				addCharacterToList('mickeysadistic', 1);
			
			case 'Malfunction':
				if(curStep == 4) //for get it work
				{
					triggerEventNote('Alter Camera Zoom', '2', '2.4');
					trace('is working');
				}

				if(curStep == 20)
				{
					triggerEventNote('Alter Camera Zoom', '0.9', '1');
				}

				if(curStep == 96) {
					triggerEventNote('Alter Camera Zoom', '2.1', '5.8');
				}

				if(curStep == 160) {
					triggerEventNote('Alter Camera Zoom', '1', '0.5');
					triggerEventNote('Add Camera Zoom', '0.030', '0.04');
				}

				if(curStep == 271) {
					triggerEventNote('Alter Camera Zoom', '2', '1.8');
					}
				
				if(curStep == 287) {
					triggerEventNote('Add Camera Zoom', '0.030', '0.04');
					triggerEventNote('Alter Camera Zoom', '0.8', '0.8');
				}

				if(curStep == 292) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 296) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 300) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 304) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 308) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					}

				if(curStep == 312) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 316) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 320) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 324) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					}

				if(curStep == 328) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 332) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 336) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 340) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 344) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

                if(curStep == 348) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 352) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 356) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 360) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 364) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				//here's when i planned this thing
				if(curStep == 368) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 372) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 376) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 380) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 384) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 388) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 392) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 396) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 400) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 404) /*funny 404 thing*/ {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 408) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 412) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 416) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 420) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 424) /*funny haxe verison*/ {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 426) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 430) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 434) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 438) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 442) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}
				
				if(curStep == 446) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 450) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 454) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 458) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 462) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 466) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 470) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 474) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 478) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 482) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 486) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 490) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 494) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 498) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 502) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 506) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 510) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 514) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 518) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 522) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 526) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 530) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 534) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 538) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 544) {
					//triggerEventNote('Screen Fade', '3', '');

					threatTrail = new FlxTrail(dad, null, 10, 1, 0.6, 0.089); //Glitch Mickey looks more threatening now
					addBehindDad(threatTrail);
					threatTrail.xEnabled = true;
					threatTrail.yEnabled = true;
           		}

				if(curStep == 546) {
					//triggerEventNote('Scroll Type', 'Left', 'Right');
				}

                if(curStep == 560) {
					triggerEventNote('Flash Screen', '0', 'false');  
					//triggerEventNote('Screen Fade', '0', '');  
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');  
					//triggerEventNote('Scroll Type', 'Left', 'Right'); 
				    health = 1;
					FlxTween.tween(this, {songLength: FlxG.sound.music.length}, 3, {ease: FlxEase.circInOut});
					 }

				if(curStep == 564) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 568) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 572) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 576) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 580) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 584) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 588) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 592) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 596) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 600) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 604) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 608) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 612) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 616) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}
				
				if(curStep == 620) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 624) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 628) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 632) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 636) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 640) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 644) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 648) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 652) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 656) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if (curStep == 660) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 664) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 668) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 672) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

                if(curStep == 676) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 680) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 684) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 688) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'Up', 'Down');
				}

				if(curStep == 692) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 696) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'Down', 'Up');
				}

				if(curStep == 700) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 704) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'Up', 'Down');
				}

				if(curStep == 708) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 712) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'Down', 'Up');
				}

				if(curStep == 716) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 720) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'Up', 'Down');
				}

				if(curStep == 724) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 728) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'down', 'up');
				}

				if(curStep == 732) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 736) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'Up', 'Down');
				}

				if(curStep == 740) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 744) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
				triggerEventNote('Scroll Type', 'down', 'up');
			}

				if(curStep == 748) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 752) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				 triggerEventNote('Scroll Type', 'up', 'down');
				}
				
				if(curStep == 756) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 760) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
					triggerEventNote('Scroll Type', "down", 'up');
				}

				if(curStep == 764) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 768) {
				triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
				triggerEventNote('Scroll Type', "down", 'up');
			}

				if(curStep == 772) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 776) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');  
					triggerEventNote('Scroll Type', 'up', 'down');
				}
                
				if(curStep == 780) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}
				if(curStep == 784) {
				triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
				triggerEventNote('Scroll Type', "down", 'up');
			}

				if(curStep == 788) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 792) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
					triggerEventNote('Scroll Type', 'up', 'down');
				}

				if(curStep == 796){
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 800) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
					triggerEventNote('Scroll Type', "down", 'up');
				}

				if(curStep == 808) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 812) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 816) {
					if(ClientPrefs.mechanics)
					{
					FlxTween.tween(crashLivesIcon, {y: 1000}, 6, {ease: FlxEase.sineIn});
					FlxTween.tween(crashLivesIcon, {alpha: 0}, 2, {ease: FlxEase.sineIn});
					FlxTween.tween(crashLives, {y: 1000}, 6, {ease: FlxEase.sineIn});
					FlxTween.tween(crashLives, {alpha: 0}, 2, {ease: FlxEase.sineIn});
					}
					triggerEventNote('Alter Camera Zoom', '1.2', '0.5');
				}

				if(curStep == 824) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');  
					triggerEventNote('Flash Screen', '1', 'false'); 
					triggerEventNote('Alter Camera Zoom', '0.8', '0.7'); 
					triggerEventNote('Scroll Type', 'undyne', '');
					hereComesThePeak = true;

					Lib.application.window.borderless = true; //ALT + F4 Supermarcy 2: Electric Bobaloo (Jason)
					FlxTween.tween(scoreTxt, {alpha: 0}, 1);
					FlxTween.tween(healthBar, {alpha: 0}, 1);					
					}

				if(curStep == 828) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 832) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 832) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 836) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 840) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 844) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 848) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 852) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 856) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}
				if(curStep == 860) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}
				
				if(curStep == 864) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 868) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 872) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 876) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}
				if(curStep == 880) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 884) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 888) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 892) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 896) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 900) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 904) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}
				if(curStep == 908) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 912) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}
				if(curStep == 916) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 920) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 924) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 928) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 932) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 936) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 940) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}
				if(curStep == 952) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');  
					triggerEventNote('Flash Screen', '0', 'false');
				}

				if(curStep == 956) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 960) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 964) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 968) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 972) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 976) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 980) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 984) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 992){
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 996) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				//step 1000, and im going 3 days, send help
				if(curStep == 1000) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1004) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1008) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1012) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1016) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1020) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1024) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1028) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1032) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}
				if(curStep == 1036) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1040) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1044) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1048) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1052) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1056) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}
				if(curStep == 1060) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1064) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1068) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}
				//Happy cus is not too much copy paste (THX god)

				if(curStep == 1072) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
					 triggerEventNote('Scroll Type', 'default', 'default');
				}

				if(curStep == 1080) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
					 triggerEventNote('Scroll Type', 'right', 'left');
				}

				if(curStep == 1088) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
					 triggerEventNote('Scroll Type', 'default', 'down');
				}

				if(curStep == 1096) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');  
					triggerEventNote('Scroll Type', 'down', 'up');
				}

				if(curStep == 1104) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
					 triggerEventNote('Scroll Type', 'undyne', 'undyne');
				}

				if(curStep == 1136) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
				    triggerEventNote('Scroll Type', 'default', 'default');
					}

				if(curStep == 1144) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
					triggerEventNote('Scroll Type', 'left', 'right');
				}

				if(curStep == 1152) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
					triggerEventNote('Scroll Type', 'default', 'down');
				}

				if(curStep == 1160) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
					triggerEventNote('Scroll Type', 'down', 'up');
				}

				if(curStep == 1168) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					 triggerEventNote('Scroll Type', 'undyne', 'undyne');
					}

				if(curStep == 1176) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
					triggerEventNote('Scroll Type', 'default', 'default');
				}

				if(curStep == 1200) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');  
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1202) {
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1204) {
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1206) {
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1208) {
					triggerEventNote('Fade Character', '0', ''); 
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1216) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1224) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1232) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1240) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1248) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1256) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1264) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Alter Camera Zoom', '1.2', '3');
				}

				if(curStep == 1266) {
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1268) {
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1270) {
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');	
				}

				if(curStep == 1280) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');	
				}

				if(curStep == 1288) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');	
				}

				if(curStep == 1296) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');	
				}

				if(curStep == 1304) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');	
				}

				if(curStep == 1312) {
					triggerEventNote('Alter Camera Zoom', '1.5', '0.7');	
				}

				if(curStep == 1328) {
					triggerEventNote('Alter Camera Zoom', '0.8', '0.7');
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'right', 'left');
				}
				
				if(curBeat == 333) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 334) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 335) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1344) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'left', 'right');
				}

				if(curBeat == 336) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 337) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 338) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				} 

				if(curBeat == 339) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				} 

				if(curStep == 1385) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'undyne', 'undyne');
				}

				if(curBeat == 341) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 342) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 343) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1377) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'up', 'down');
				}

				if(curBeat == 345) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 346) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 347) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curStep == 1392) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'right', 'left');
				}

				if(curBeat == 349) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 350) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 351) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 352) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'left', 'right');
				}

				if(curBeat == 353) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 354) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 355) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 356) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'undyne', 'undyne');
				}

				if(curBeat == 357) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 358) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 359) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 360) { //XBOX 360 moment
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'up', 'down');
				}

				if(curBeat == 361) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 362) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 363) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'right', 'left');
				}

				if(curBeat == 364) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 365) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 366) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 367) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 368) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'left', 'right');
				}

				if(curBeat == 369) { //Funi number
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 370) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 371) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 372) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'undyne', 'undyne');
				}

				if(curBeat == 373) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 374) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 375) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 376) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'up', 'down');
				}

				if(curBeat == 377) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 378) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 379) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 380) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'right', 'left');
				}

				if(curBeat == 381) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 382) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 383) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 384) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'left', 'right');
				}

				if(curBeat == 385) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 386) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 387) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 388) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'undyne', 'undyne');
				}

				if(curBeat == 389) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 390) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 391) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 392) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'up', 'down');
				}

				if(curBeat == 393) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 394) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 395) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
				}

				if(curBeat == 396) {
					triggerEventNote('Add Camera Zoom', '0.13', '0.14');
					triggerEventNote('Scroll Type', 'default', 'default');
					triggerEventNote('Alter Camera Zoom', '1.2', '0.7');
				}

				if(curBeat == 398) {
					triggerEventNote('Flash Screen', '0', 'false');
					triggerEventNote('Alter Camera Zoom', '0.8', '0.9');
					triggerEventNote('Fade Character', '0', '');
					Lib.application.window.borderless = false;
					FlxTween.tween(camHUD, {alpha: 0}, 1);
				}

				if(curStep == 1592) {
					//if (windowDad != null)
						//{
						//windowDad.close();
						//}
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1594) {
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1596) {
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1597) {
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1598) {
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1599) {
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1600) {
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1601) {
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1602) {
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1603) {
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1604) {
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1605) {
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1606) {
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1607) {
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1608) {
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1609) {
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1610) {
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
					triggerEventNote('Fade Character', '0', '');
				}

				if(curStep == 1613) {
					triggerEventNote('Instant Fade Camera', 'fade', '');
				}

				case 'Malfunction Legacy': //Another 1000 of lines ik, but in legacy version it dont have some of the new stuff
						if(curStep == 4) //for get it work
						{
							triggerEventNote('Alter Camera Zoom', '2', '2.4');
							trace('is working');
						}
		
						if(curStep == 20)
						{
							triggerEventNote('Alter Camera Zoom', '0.9', '1');
						}
		
						if(curStep == 96) {
							triggerEventNote('Alter Camera Zoom', '2.1', '5.8');
						}
		
						if(curStep == 160) {
							triggerEventNote('Alter Camera Zoom', '1', '0.5');
							triggerEventNote('Add Camera Zoom', '0.030', '0.04');
						}
		
						if(curStep == 271) {
							triggerEventNote('Alter Camera Zoom', '2', '1.8');
							}
						
						if(curStep == 287) {
							triggerEventNote('Add Camera Zoom', '0.030', '0.04');
							triggerEventNote('Alter Camera Zoom', '0.8', '0.8');
						}
		
						if(curStep == 292) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 296) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 300) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 304) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 308) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							}
		
						if(curStep == 312) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 316) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 320) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 324) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							}
		
						if(curStep == 328) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 332) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 336) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 340) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 344) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 348) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 352) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 356) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 360) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 364) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						//here's when i planned this thing
						if(curStep == 368) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 372) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 376) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 380) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 384) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 388) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 392) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 396) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 400) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 404) /*funny 404 thing*/ {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 408) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 412) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 416) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 420) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 424) /*funny haxe verison*/ {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 426) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 430) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 434) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 438) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 442) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
						
						if(curStep == 446) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 450) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 454) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 458) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 462) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 466) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 470) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 474) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 478) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 482) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 486) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 490) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 494) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 498) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 502) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 506) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 510) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 514) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 518) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 522) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 526) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 530) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 534) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 538) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 544) {
							triggerEventNote('Screen Fade', '3', '');
		
							/*threatTrail = new FlxTrail(dad, null, 10, 1, 0.6, 0.089); //Glitch Mickey looks more threatening now
							insert(members.indexOf(dadGroup) - 1, threatTrail);
							threatTrail.xEnabled = true;
							threatTrail.yEnabled = true;*/
						   }
		
						if(curStep == 546) {
							triggerEventNote('Scroll Type', 'Left', 'Right');
						}
		
						if(curStep == 560) {
							/*triggerEventNote('Flash Screen', '0', 'false');  
							triggerEventNote('Screen Fade', '0', '');  
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');  
							triggerEventNote('Scroll Type', 'Left', 'Right'); */
							health = 1;
							 }
		
						if(curStep == 564) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 568) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 572) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 576) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 580) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 584) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 588) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 592) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 596) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 600) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 604) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 608) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 612) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 616) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
						
						if(curStep == 620) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 624) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 628) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 632) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 636) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 640) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 644) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 648) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 652) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 656) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if (curStep == 660) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 664) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 668) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 672) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 676) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 680) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 684) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 688) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'Up', 'Down');
						}
		
						if(curStep == 692) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 696) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'Down', 'Up');
						}
		
						if(curStep == 700) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 704) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'Up', 'Down');
						}
		
						if(curStep == 708) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 712) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'Down', 'Up');
						}
		
						if(curStep == 716) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 720) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'Up', 'Down');
						}
		
						if(curStep == 724) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 728) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'down', 'up');
						}
		
						if(curStep == 732) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 736) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'Up', 'Down');
						}
		
						if(curStep == 740) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 744) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
						triggerEventNote('Scroll Type', 'down', 'up');
					}
		
						if(curStep == 748) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 752) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						 triggerEventNote('Scroll Type', 'up', 'down');
						}
						
						if(curStep == 756) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 760) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
							triggerEventNote('Scroll Type', "down", 'up');
						}
		
						if(curStep == 764) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 768) {
						triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
						triggerEventNote('Scroll Type', "down", 'up');
					}
		
						if(curStep == 772) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 776) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');  
							triggerEventNote('Scroll Type', 'up', 'down');
						}
						
						if(curStep == 780) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
						if(curStep == 784) {
						triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
						triggerEventNote('Scroll Type', "down", 'up');
					}
		
						if(curStep == 788) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 792) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
							triggerEventNote('Scroll Type', 'up', 'down');
						}
		
						if(curStep == 796){
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 800) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
							triggerEventNote('Scroll Type', "down", 'up');
						}
		
						if(curStep == 808) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 812) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 816) {
							triggerEventNote('Alter camera Zoom', '1.2', '0.5');
						}
		
						if(curStep == 824) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');  
							triggerEventNote('Flash Screen', '1', 'false'); 
							 triggerEventNote('Alter Camera Zoom', '0.8', '0.7'); 
							 triggerEventNote('Scroll Type', 'undyne', '');
							 //its crazy time
							//popupBfWindow(500, 400, 1050, 490, SONG.player1);
							//popupWindow(500, 400, 0, 490, SONG.player2);
							//trace("dont crash");
							}
		
						if(curStep == 828) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 832) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 832) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 836) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 840) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 844) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 848) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 852) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 856) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
						if(curStep == 860) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
						
						if(curStep == 864) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 868) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 872) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 876) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
						if(curStep == 880) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 884) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 888) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 892) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 896) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 900) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 904) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
						if(curStep == 908) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 912) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
						if(curStep == 916) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 920) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 924) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 928) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 932) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 936) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 940) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
						if(curStep == 952) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');  
							triggerEventNote('Flash Screen', '0', 'false');
						}
		
						if(curStep == 956) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 960) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 964) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 968) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 972) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 976) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 980) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 984) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 992){
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 996) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						//step 1000, and im going 3 days, send help
						if(curStep == 1000) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1004) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1008) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1012) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1016) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1020) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1024) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1028) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1032) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
						if(curStep == 1036) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1040) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1044) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1048) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1052) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1056) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
						if(curStep == 1060) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1064) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1068) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
						//Happy cus is not too much copy paste (THX god)
		
						if(curStep == 1072) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
							 triggerEventNote('Scroll Type', 'default', 'default');
						}
		
						if(curStep == 1080) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
							 triggerEventNote('Scroll Type', 'right', 'left');
						}
		
						if(curStep == 1088) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
							 triggerEventNote('Scroll Type', 'default', 'down');
						}
		
						if(curStep == 1096) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');  
							triggerEventNote('Scroll Type', 'down', 'up');
						}
		
						if(curStep == 1104) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
							 triggerEventNote('Scroll Type', 'undyne', 'undyne');
						}
		
						if(curStep == 1136) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
							triggerEventNote('Scroll Type', 'default', 'default');
							}
		
						if(curStep == 1144) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
							triggerEventNote('Scroll Type', 'left', 'right');
						}
		
						if(curStep == 1152) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
							triggerEventNote('Scroll Type', 'default', 'down');
						}
		
						if(curStep == 1160) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
							triggerEventNote('Scroll Type', 'down', 'up');
						}
		
						if(curStep == 1168) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							 triggerEventNote('Scroll Type', 'undyne', 'undyne');
							}
		
						if(curStep == 1176) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14'); 
							triggerEventNote('Scroll Type', 'default', 'default');
						}
		
						if(curStep == 1200) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');  
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1202) {
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1204) {
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1206) {
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1208) {
							triggerEventNote('Fade Character', '0', ''); 
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1216) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1224) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1232) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1240) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1248) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1256) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1264) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Alter Camera Zoom', '1.2', '3');
						}
		
						if(curStep == 1266) {
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1268) {
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1270) {
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');	
						}
		
						if(curStep == 1280) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');	
						}
		
						if(curStep == 1288) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');	
						}
		
						if(curStep == 1296) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');	
						}
		
						if(curStep == 1304) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');	
						}
		
						if(curStep == 1312) {
							triggerEventNote('Alter Camera Zoom', '1.5', '0.7');	
						}
		
						if(curStep == 1328) {
							triggerEventNote('Alter Camera Zoom', '0.8', '0.7');
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'right', 'left');
						}
						
						if(curBeat == 333) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 334) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 335) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1344) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'left', 'right');
						}
		
						if(curBeat == 336) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 337) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 338) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						} 
		
						if(curBeat == 339) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						} 
		
						if(curStep == 1385) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'undyne', 'undyne');
						}
		
						if(curBeat == 341) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 342) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 343) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1377) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'up', 'down');
						}
		
						if(curBeat == 345) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 346) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 347) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curStep == 1392) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'right', 'left');
						}
		
						if(curBeat == 349) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 350) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 351) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 352) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'left', 'right');
						}
		
						if(curBeat == 353) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 354) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 355) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 356) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'undyne', 'undyne');
						}
		
						if(curBeat == 357) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 358) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 359) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 360) { //XBOX 360 moment
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'up', 'down');
						}
		
						if(curBeat == 361) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 362) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 363) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'right', 'left');
						}
		
						if(curBeat == 364) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 365) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 366) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 367) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 368) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'left', 'right');
						}
		
						if(curBeat == 369) { //Funi number
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 370) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 371) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 372) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'undyne', 'undyne');
						}
		
						if(curBeat == 373) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 374) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 375) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 376) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'up', 'down');
						}
		
						if(curBeat == 377) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 378) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 379) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 380) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'right', 'left');
						}
		
						if(curBeat == 381) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 382) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 383) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 384) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'left', 'right');
						}
		
						if(curBeat == 385) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 386) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 387) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 388) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'undyne', 'undyne');
						}
		
						if(curBeat == 389) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 390) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 391) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 392) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'up', 'down');
						}
		
						if(curBeat == 393) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 394) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 395) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
						}
		
						if(curBeat == 396) {
							triggerEventNote('Add Camera Zoom', '0.13', '0.14');
							triggerEventNote('Scroll Type', 'default', 'default');
							triggerEventNote('Alter Camera Zoom', '1.2', '0.7');
						}
		
						if(curBeat == 398) {
							triggerEventNote('Flash Screen', '0', 'false');
							triggerEventNote('Alter Camera Zoom', '0.8', '0.9');
							triggerEventNote('Fade Character', '0', '');
							FlxTween.tween(camHUD, {alpha: 0}, 1);
						}
		
						if(curStep == 1592) {
							//if (windowDad != null)
								//{
								//windowDad.close();
								//}
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1594) {
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1596) {
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1597) {
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1598) {
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1599) {
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1600) {
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1601) {
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1602) {
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1603) {
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1604) {
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1605) {
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1606) {
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1607) {
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1608) {
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1609) {
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1610) {
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
							triggerEventNote('Fade Character', '0', '');
						}
		
						if(curStep == 1613) {
							triggerEventNote('Instant Fade Camera', 'fade', '');
						}
		
			case 'Hunted':
				super.beatHit();
				triggerEventNote('Add Camera Zoom', '0.004', '0.03');
			case 'Facade':
				//Insert Events here
			case 'Scrapped':
				if(curStep == 112)
				{
					FlxG.camera.flash(FlxColor.BLACK, 2);
					dad.y = -100;
				}
				if(curStep == 416)
				{
					rsTV.visible = true;
				}
				if(curStep == 420)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 428)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 436)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 444)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 452)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 460)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 468)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 476)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 484)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 492)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 500)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 508)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 516)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 524)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 532)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 540)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 544)
				{
					FlxTween.tween(gradientBar, {'scale.y': 1.5}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 548)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 552)
				{
					FlxTween.tween(gradientBar, {'scale.y': 0}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 556)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 560)
				{
					FlxTween.tween(gradientBar, {'scale.y': 1.5}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 564)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 568)
				{
					FlxTween.tween(gradientBar, {'scale.y': 0}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 572)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 576)
				{
					FlxTween.tween(gradientBar, {'scale.y': 1.5}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 580)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 584)
				{
					FlxTween.tween(gradientBar, {'scale.y': 0}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 588)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 592)
				{
					FlxTween.tween(gradientBar, {'scale.y': 1.5}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 596)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 600)
				{
					FlxTween.tween(gradientBar, {'scale.y': 0}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 604)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 608)
				{
					FlxTween.tween(gradientBar, {'scale.y': 1.5}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 612)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 616)
				{
					FlxTween.tween(gradientBar, {'scale.y': 0}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 620)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 624)
				{
					FlxTween.tween(gradientBar, {'scale.y': 1.5}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 628)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 632)
				{
					FlxTween.tween(gradientBar, {'scale.y': 0}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 636)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 640)
				{
					FlxTween.tween(gradientBar, {'scale.y': 1.5}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 644)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 648)
				{
					FlxTween.tween(gradientBar, {'scale.y': 0}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 652)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 656)
				{
					FlxTween.tween(gradientBar, {'scale.y': 1.5}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 660)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 664)
				{
					FlxTween.tween(gradientBar, {'scale.y': 0}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 736)
				{
					FlxTween.tween(gradientBar, {'scale.y': 1.5}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 752)
				{
					FlxTween.tween(gradientBar, {'scale.y': 0}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 760)
				{
					FlxTween.tween(gradientBar, {'scale.y': 1.5}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 768)
				{
					FlxTween.tween(gradientBar, {'scale.y': 0}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 864)
				{
					FlxTween.tween(gradientBar, {'scale.y': 1.5}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 872)
				{
					FlxTween.tween(gradientBar, {'scale.y': 0}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 880)
				{
					FlxTween.tween(gradientBar, {'scale.y': 1.5}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 888)
				{
					FlxTween.tween(gradientBar, {'scale.y': 0}, 0.6, {ease: FlxEase.quadInOut});
				}
				if(curStep == 932)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}
				if(curStep == 940)
				{
					if(canaddshaders)
					{
						addShaderToCamera('hud', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('game', new ChromaticAberrationEffect(0.01));
						addShaderToCamera('hud', new TiltshiftEffect(0.5, 0));
						addShaderToCamera('game', new TiltshiftEffect(0.6, 0));
						new FlxTimer().start(0.09, function(tmr:FlxTimer)
						{
							clearShaderFromCamera('game');
							clearShaderFromCamera('hud');
							addShaderToCamera('hud', new ChromaticAberrationEffect(0.004));
							addShaderToCamera('game', new ChromaticAberrationEffect(0.005));
							addShaderToCamera('hud', new VCRDistortionEffect(0, true, false, true));
							addShaderToCamera('game', new VhsEffect(0.3, 0));
						});

					}
				}

			case 'Isolated Beta':
			timeBar.createFilledBar(0xFFFFFF, 0x000000);

			case 'Neglection':	
				for (i in 0...opponentStrums.length) {
                opponentStrums.members[i].alpha = 0.5;
				}
			}

		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);
	}

	public var closeLuas:Array<FunkinLua> = [];
	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			var ret:Dynamic = luaArray[i].call(event, args);
			if(ret != FunkinLua.Function_Continue) {
				returnVal = ret;
			}
		}

		for (i in 0...closeLuas.length) {
			luaArray.remove(closeLuas[i]);
			closeLuas[i].stop();
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating() {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				var ratings:Array<Dynamic> = [ClientPrefs.ratingSystem];
				switch (ClientPrefs.ratingSystem)
				{
					case "Bedrock":
						ratings = Ratings.bedrockRatings;
					case "Psych":
						ratings = Ratings.psychRatings;
						// GO CHECK FOREVER ENGINE OUT!! https://github.com/Yoshubs/Forever-Engine-Legacy
					case "Forever":
						ratings = Ratings.foreverRatings;
						// ALSO TRY ANDROMEDA!! https://github.com/nebulazorua/andromeda-engine
					case "Andromeda":
						ratings = Ratings.andromedaRatings;
					case "Etterna":
						ratings = Ratings.accurateRatings;
					case 'Mania':
						ratings = Ratings.maniaRatings;
				}

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratings[ratings.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratings.length-1)
					{
						if(ratingPercent < ratings[i][1])
						{
							ratingName = ratings[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			if(ClientPrefs.language == "Spanish") {
			ratingFC = "";
			if (marvelouses > 0) ratingFC = "MFC";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			else if (songMisses >= 10) ratingFC = "Limpio";
			} else {
				ratingFC = "";
				if (marvelouses > 0) ratingFC = "MFC";
				if (sicks > 0) ratingFC = "SFC";
				if (goods > 0) ratingFC = "GFC";
				if (bads > 0 || shits > 0) ratingFC = "FC";
				if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
				else if (songMisses >= 10) ratingFC = "Clear";
			}
		}
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
		if (!ClientPrefs.hideJudgement) {
			if (ClientPrefs.marvelouses)
				if(ClientPrefs.language == "Spanish") {
			judgementCounter.text = 'Marav: ${marvelouses}\nExelentes: ${sicks}\nBuenos: ${goods}\nMalos: ${bads}\nTerribles: ${shits}\n';
			} else {
				judgementCounter.text = 'Marvs: ${marvelouses}\nSicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\n';
			}
		    else
			if(ClientPrefs.language == "Spanish") {
			judgementCounter.text = 'Exelentes: ${sicks}\nBuenos: ${goods}\nMalos: ${bads}\nTerribles: ${shits}\n';
	       } else {
			judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\n';
		}
	}
	}

	#if (ACHIEVEMENTS_ALLOWED && desktop)
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if(chartingMode) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled) {
				var unlock:Bool = false;
				switch(achievementName)
				{
					case 'malfunction_tryhard':
						if(!isStoryMode && campaignMisses + songMisses < 1 && crashLivesCounter > 29 && CoolUtil.difficultyString() == 'HARD' && !changedDifficulty && !usedPractice)
						{
							if(SONG.song == 'Malfunction')
							{
								unlock = true;
									GJClient.trophieAdd(169789);		
							}
						}
					case 'episode1_SFC' | 'episode2_SFC':
						if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'SUICIDAL' && storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						{
							var weekName:String = WeekData.getWeekFileName();
							switch(weekName) //I know this is a lot of duplicated code, but it's easier readable and you can add weeks with different names than the achievement tag
							{
								case 'chapter1':
									if(achievementName == 'episode1_SFC')
									{
										unlock = true;
											GJClient.trophieAdd(170051);		
									}
								case 'chapter2':
									if(achievementName == 'episode2_SFC')
									{
										unlock = true;
											GJClient.trophieAdd(170052);
									}
							}
						}
					case 'episode1_suicide' | 'episode2_suicide':
						if(isStoryMode && CoolUtil.difficultyString() == 'SUICIDAL' && storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						{
							var weekName:String = WeekData.getWeekFileName();
							switch(weekName) //I know this is a lot of duplicated code, but it's easier readable and you can add weeks with different names than the achievement tag
							{
								case 'chapter1':
									if(achievementName == 'episode1_suicide')
									{
										unlock = true;
											GJClient.trophieAdd(170049);		
									}
								case 'chapter2':
									if(achievementName == 'episode2_suicide')
									{
										unlock = true;
									//	if(!GameJoltAPI.checkTrophy(169967))
											GJClient.trophieAdd(169967);
									}
							}
						}
					case 'episode1_nomiss' | 'episode2_nomiss' | 'malfunction_nomiss' | 'relapse_nomiss':
						if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD' && storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						{
							var weekName:String = WeekData.getWeekFileName();
							switch(weekName) //I know this is a lot of duplicated code, but it's easier readable and you can add weeks with different names than the achievement tag
							{
								case 'chapter1':
									if(achievementName == 'episode1_nomiss')
									{
										unlock = true;
				//						if(!GameJoltAPI.checkTrophy(169793))
											GJClient.trophieAdd(169793);		
									}
								case 'chapter2':
									if(achievementName == 'episode2_nomiss')
									{
										unlock = true;
							//			if(!GameJoltAPI.checkTrophy(169866))
											GJClient.trophieAdd(169866);		
									}
							}
						}
						if(!isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD' && !changedDifficulty && !usedPractice)
						{
							if(SONG.song == 'Malfunction')
							{
								if(achievementName == 'malfunction_nomiss')
								{
									unlock = true;
			//						if(!GameJoltAPI.checkTrophy(169791))
										GJClient.trophieAdd(169791);		
								}
							}
							if(SONG.song == 'Cycled Sins')
							{
								if(achievementName == 'relapse_nomiss')
								{ 
									unlock = true;
					//				if(!GameJoltAPI.checkTrophy(169790))
										GJClient.trophieAdd(169790);
								}
							}
						}
					case 'episode1' | 'episode2':
						if(isStoryMode && CoolUtil.difficultyString() == 'HARD' && storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						{
							var weekName:String = WeekData.getWeekFileName();
							switch(weekName)
							{
								case 'chapter1':
									if(achievementName == 'episode1')
									{
										unlock = true;
			//							if(!GameJoltAPI.checkTrophy(169792))
											GJClient.trophieAdd(169792);
									}
								case 'chapter2':
									if(achievementName == 'episode2') unlock = true;
								     GJClient.trophieAdd(169866);
							}
						}
					case 'ur_bad':
						if(ratingPercent < 0.2 && !practiceMode) {
							unlock = true;
						}
					case 'ur_good':
						if(ratingPercent >= 1 && !usedPractice) {
		//					if(!GameJoltAPI.checkTrophy(169967))
								GJClient.trophieAdd(169967);
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	var curLight:Int = -1;
	var curLightEvent:Int = -1;

	/*function createHUD(style:String)
		{
			switch (style)
			{
				/*case "Box Funkin":
					scoreGroup = new FlxTypedSpriteGroup<FlxText>();
	
					var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
					timeBarBG = new AttachedSprite('timeBar');
					timeBarBG.setGraphicSize(FlxG.width, 22);
					timeBarBG.y = (ClientPrefs.downScroll ? 3 : 695);
					timeBarBG.scrollFactor.set();
					timeBarBG.updateHitbox();
					timeBarBG.screenCenter(X);
					timeBarBG.alpha = 0;
					add(timeBarBG);
					timeBarBG.color = FlxColor.BLACK;
					trace(timeBarBG.width);
					trace(timeBarBG.height);
	
					timeTxt = new FlxText(0, (ClientPrefs.downScroll ? timeBarBG.y + 32 : timeBarBG.y - 32), 400, "", 20);
					timeTxt.setFormat(Paths.font("MilkyNice.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					timeTxt.alpha = 0;
					timeTxt.borderSize = 3;
					timeTxt.screenCenter(X);
					timeTxt.antialiasing = ClientPrefs.globalAntialiasing;
					updateTime = true;
	
					timeBar = new FlxBar(timeBarBG.x + 12, timeBarBG.y + 5, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 24), 13, this, 'songPercent', 0, 1);
					timeBar.scrollFactor.set();
					timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
					timeBar.numDivisions = 800; // How much lag this causes?? Should i tone it down to idk, 400 or 200?
					timeBar.alpha = 0;
					timeBar.screenCenter(X);
					add(timeBar);
					add(timeTxt);
					songTxt = new FlxText(20, (ClientPrefs.downScroll ? timeBarBG.y + 30 : timeBarBG.y - 35), 0, SONG.song, 24);
					songTxt.setFormat(Paths.font("MilkyNice.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					songTxt.scrollFactor.set();
					songTxt.borderSize = 3;
					songTxt.antialiasing = ClientPrefs.globalAntialiasing;
					scoreGroup.add(songTxt);
	
					scoreSideTxt = new FlxText(25, (ClientPrefs.downScroll ? songTxt.y + songTxt.height + 10 : songTxt.y - songTxt.height - 10 - (29 * 2)), 0, "",
						21);
					scoreSideTxt.setFormat(Paths.font("MilkyNice.ttf"), 21, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					scoreSideTxt.borderSize = 3;
					scoreSideTxt.antialiasing = ClientPrefs.globalAntialiasing;
					scoreGroup.add(scoreSideTxt);
					// trace(scoreSideTxt.height);
	
					missesTxt = new FlxText(25, (ClientPrefs.downScroll ? scoreSideTxt.y + scoreSideTxt.height - 5 : songTxt.y - songTxt.height - 10 - 29), 0, "",
						21);
					missesTxt.setFormat(Paths.font("MilkyNice.ttf"), 21, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					missesTxt.borderSize = 3;
					missesTxt.antialiasing = ClientPrefs.globalAntialiasing;
					scoreGroup.add(missesTxt);
					// trace(missesTxt.height);
	
					acurracyTxt = new FlxText(25, (ClientPrefs.downScroll ? missesTxt.y + missesTxt.height - 5 : songTxt.y - songTxt.height - 10), 0, "", 21);
					acurracyTxt.setFormat(Paths.font("MilkyNice.ttf"), 21, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					acurracyTxt.borderSize = 3;
					acurracyTxt.antialiasing = ClientPrefs.globalAntialiasing;
					scoreGroup.add(acurracyTxt);
	
					sickTxt = new FlxText(FlxG.width - 140, (ClientPrefs.downScroll ? timeBarBG.y + 35 : timeBarBG.y - 40 - (29 * 3)), 0, "", 21);
					sickTxt.setFormat(Paths.font("MilkyNice.ttf"), 21, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					sickTxt.borderSize = 3;
					sickTxt.antialiasing = ClientPrefs.globalAntialiasing;
					scoreGroup.add(sickTxt);
	
					goodTxt = new FlxText(FlxG.width - 140, (ClientPrefs.downScroll ? sickTxt.y + sickTxt.height : timeBarBG.y - 40 - (29 * 2)), 0, "", 21);
					goodTxt.setFormat(Paths.font("MilkyNice.ttf"), 21, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					goodTxt.borderSize = 3;
					goodTxt.antialiasing = ClientPrefs.globalAntialiasing;
					scoreGroup.add(goodTxt);
	
					badTxt = new FlxText(FlxG.width - 140, (ClientPrefs.downScroll ? goodTxt.y + goodTxt.height : timeBarBG.y - 40 - 29), 0, "", 21);
					badTxt.setFormat(Paths.font("MilkyNice.ttf"), 21, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					badTxt.borderSize = 3;
					badTxt.antialiasing = ClientPrefs.globalAntialiasing;
					scoreGroup.add(badTxt);
	
					shitTxt = new FlxText(FlxG.width - 140, (ClientPrefs.downScroll ? badTxt.y + badTxt.height : timeBarBG.y - 40), 0, "", 21);
					shitTxt.setFormat(Paths.font("MilkyNice.ttf"), 21, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					shitTxt.borderSize = 3;
					shitTxt.antialiasing = ClientPrefs.globalAntialiasing;
					scoreGroup.add(shitTxt);
	
					add(scoreGroup);
	
					scoreGroup.cameras = [camHUD];
					timeBar.cameras = [camHUD];
					timeBarBG.cameras = [camHUD];
					timeTxt.cameras = [camHUD];
				default:
					scoreGroup = new FlxTypedSpriteGroup<FlxText>();
	
					var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
					timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
					timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					timeTxt.scrollFactor.set();
					timeTxt.alpha = 0;
					timeTxt.borderSize = 2;
					timeTxt.visible = showTime;
					if (ClientPrefs.downScroll)
						timeTxt.y = FlxG.height - 44;
	
					if (ClientPrefs.timeBarType == 'Song Name')
					{
						timeTxt.text = SONG.song;
					}
					updateTime = showTime;
	
					timeBarBG = new AttachedSprite('timeBar');
					timeBarBG.x = timeTxt.x;
					timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
					timeBarBG.scrollFactor.set();
					timeBarBG.alpha = 0;
					timeBarBG.visible = showTime;
					timeBarBG.color = FlxColor.BLACK;
					timeBarBG.xAdd = -4;
					timeBarBG.yAdd = -4;
					add(timeBarBG);
	
					timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
						'songPercent', 0, 1);
					timeBar.scrollFactor.set();
					timeBar.createFilledBar(0xFF000000, 0xFF7D808E);
					timeBar.numDivisions = 800; // How much lag this causes?? Should i tone it down to idk, 400 or 200?
					timeBar.alpha = 0;
					timeBar.visible = showTime;
					add(timeBar);
					add(timeTxt);
					timeBarBG.sprTracker = timeBar;
	
					scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
					scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderhStyle.OUTLINE, FlxColor.BLACK);
					scoreTxt.scrollFactor.set();
					scoreTxt.borderSize = 1.25;
					scoreGroup.add(scoreTxt);
	
					add(scoreGroup);
	
					scoreGroup.cameras = [camHUD];
					timeBar.cameras = [camHUD];
					timeBarBG.cameras = [camHUD];
					timeTxt.cameras = [camHUD];
			}
		}*/
		
}


