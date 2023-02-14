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

class CreditsState extends MusicBeatState
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
		DiscordClient.changePresence("Viewing Credits", null, null, 'icon');
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
			['Funkin.avi Dev Team'],
			['Special Thanks'],
			['Yama haki', 'yama', "You're the reason why this mod is popular now,\nthank you.", 'https://www.youtube.com/channel/UCm2eFBC_lMxkRO8JF17ArFg',	'FFFFFF'],
			[''],
			['Directors'],
			['DEMOLITIONDON96',	'demolitiondon96',	'Director Of Funkin.avi', 'https://youtube.com/c/DEMOLITIONDON96',	'FFFFFF'],
			['Nutsack',	'nutsack',	'2nd Director',	'https://twitter.com/Nutblocked',	'FFFFFF'],
			['GavinTheCartoonist', 'missing-icon', 'Co-Director Of Funkin.avi', 'https://twitter.com/AnimationFelix', 'FFFFFF'],
            ['HazeyPurple', 'haze', 'Second Co-director', 'https://twitter.com/HazeyPurple_x', 'FFFFFF'],
			[''],
			['Artists'],
			['Mr. IDK',	'idk',	'Sprite & Icon Artist', 'https://twitter.com/Mr_IDKK?t=iYM1mlQcv4_UVmxtW2kvig&s=09',	'FFFFFF'],
			['AustinTheRedDragon',	'austin',	'Creator of Mr. Smiles & Concept Artist',	'https://twitter.com/Austinthereddr3?t=ZQVsYKPA_aseqQ5EBImdWQ&s=09', 'FFFFFF'],
			['GavinTheCartoonist',	'missing-icon',	'Artist',	'https://twitter.com/AnimationFelix',	'FFFFFF'],
			['HazeyPurple', 'haze', 'Artist', 'https://twitter.com/HazeyPurple_x', 'FFFFFF'],
			['DEMOLITIONDON96',	'demolitiondon96',	'Concept Artist',	'https://youtube.com/c/DEMOLITIONDON96',	'FFFFFF'],
			['awe',	'missing-icon',	'Concept Artist',	'https://twitter.com/awesitoelpapu',	'FFFFFF'],
			['JaoXD', 'jao', 'Icon Artist', 'https://twitter.com/JaoXDDD?t=M5UEMC9nLAVOyOejPfbDJw&s=09', 'FFFFFF'],
			['Xarion', 'xarion', 'His work is epic, no joke', 'https://twitter.com/Xar1on', 'FFFFFF'],
			['HassenX', 'missing-icon', 'A Cool Animator', 'nolink', 'FFFFFF'],
			['Tycho', 'tycho', 'Cycled Sins Artwork', 'https://twitter.com/TychoFNFastral?t=nNkNFz_kCO4qMRMElrhVfA&s=09', 'FFFFFF'],
			['SirSpookySkeleton', 'spooky', 'spoopy.', 'https://twitter.com/SirSpookySkeltn?t=zdg7Urcfn5QhllZxADekpA&s=09', 'FFFFFF'],
			['Jsa010',       	'jsa010',	        "Concept Art", 'https://twitter.com/_Jsa010_',   	'FFFFFF'],
			['Z3r0', 'zero', 'Epic 3D Artist', 'nolink', 'FFFFFF'],
			['MalyPlus', 'maly', 'Pixel Artist', 'https://gamebanana.com/members/2014862', 'FFFFFF'],
			['Genorelm_lmao',	'genore',	'Artist',	'https://twitter.com/Genorelm_',	'FFFFFF'],
			['Nutsack',	'nutsack',	'Episode 1 Assets',	'https://twitter.com/Nutblocked',	'FFFFFF'],
			['kyz', 'missing-icon', 'Artist', 'nolink', 'FFFFFF'],
			['rezeo.rs', 'missing-icon', 'Artist', 'nolink', 'FFFFFF'],
			['Cheez',	'cheez',	'Animator for some characters',	'https://gamebanana.com/members/1784678',	'FFFFFF'],
			['JDrive', 'drive', 'Pretty Dope Pixel Artist', 'https://twitter.com/JimmyDetector', 'FFFFFF'],
			['BonoanAnything',	'bonoan',	'Cutscenes Animator\n(Did the trailer too)',	'https://www.youtube.com/channel/UCvSHOa48e2HJrRjwEjpx1Hw',	'FFFFFF'],
			['COOLTE3YET',	'cool',	'Thumbnail Artist for GJ & GB Pages\n(Give them credit)',	'https://gamebanana.com/members/2005084',	'FFFFFF'],
			[''],
			['Composers'],
			['FR3SHMoure',	'fresh',	'Composer of Delusional',	'https://twitter.com/FR3SHAnimates?t=woj1MCTZ95ucJ33ngNSspA&s=09', 'FFFFFF'],
			['Yama haki',	'yama', 'Did most of Tracks with help of Others',	'https://www.youtube.com/channel/UCm2eFBC_lMxkRO8JF17ArFg',	'FFFFFF'],
			['obscurity.',	'missing-icon',	'Epic Composer',	'https://twitter.com/MrObscuritylol', 'FFFFFF'],
			['Sayan Sama', 'sama',	'Composer of Mr. Smiles Tracks',	'https://gamebanana.com/members/1825237',	'FFFFFF'],
			['AzkoBlitz',	'azko',	'Composer',	'https://twitter.com/Azko57478381',	'FFFFFF'],
			['JBlitz',	'blitz',	'Composer of Cycled Sins and the Menu',	'https://twitter.com/JBlitz_',	'FFFFFF'],
			['HassenX', 'missing-icon', 'Composing one of the upcoming songs', 'nolink', 'FFFFFF'],
			['END_SELLA',	'Sella',	'Composer',	'https://www.youtube.com/c/seibichu%E3%83%84/videos',	'FFFFFF'],
			['JUSTIN X',	'justin',	'Chromatic Scale Maker',	'https://twitter.com/CbmShow',	'FFFFFF'],
			['AttackPan',	'missing-icon',	'Instrumentals for some Tracks',	'nolink',	'FFFFFF'],
			[''],
			['Charters'],
			['DEMOLITIONDON96',	'demolitiondon96',	'Did some charts',	'https://youtube.com/c/DEMOLITIONDON96',	'FFFFFF'],
			['Yama haki',	'yama',	'Charted old Isolated',	'https://www.youtube.com/channel/UCm2eFBC_lMxkRO8JF17ArFg',	'FFFFFF'],
			['Dreupy', 'dreupy', 'Charter for some of the songs', 'nolink', 'FFFFFF'],
			['Dest',	'dest',	'Charter',	'https://gamebanana.com/members/2095443',	'FFFFFF'],
			['Noppz',	'missing-icon',	'He makes pretty good charts',	'https://www.youtube.com/channel/UCuz26FymzG_4tluOooxT-xQ',	'FFFFFF'],
			['PhantomNexus',	'nexus',	'Minor Charting',	'https://twitter.com/archerthewolf2',	'FFFFFF'],
			['Zer0XD',	'missing-icon',	'funny charter.',	'https://www.youtube.com/channel/UCq9VLHYIwoCU7hnr0TK9yuA',	'FFFFFF'],
			['fakeburritos123',	'burrito',	"Charted Don't Cross! \n(Don made sure it was the best chart ever)",	'nolink',	'FFFFFF'],
			[''],
			['Voice Actors'],
			['Flaconadir',	'flacon',	'Voice Actor',	'https://twitter.com/flaconadir',	'FFFFFF'],
			['AustinTheRedDragon',	'austin',	'Voice Actor for some Cutscenes',	'https://twitter.com/Austinthereddr3?t=ZQVsYKPA_aseqQ5EBImdWQ&s=09', 'FFFFFF'],
			[''],
			['Coders'],
			['DEMOLITIONDON96',	'demolitiondon96',	"Main Coder Of Funkin.avi",	'https://youtube.com/c/DEMOLITIONDON96',	'FFFFFF'],
			['Jsa010',       	'jsa010',	        "Secondary Coder of Funkin.avi", 'https://twitter.com/_Jsa010_',   	'FFFFFF'],
		    ['Real Deal Jinx!',	    'rj', /*woah*/	    'He left but he\'s back',                                                   'https://github.com/DEMOLITIONDON96/Demolition-Engine/commits?author=RealDealJinx',	                                            '4D4DC32'],
			['Goofgoof43', 'Goofgoof', 'Pretty cool guy, I\'d say', 'nolink', 'FFFFFF'],
			//['MalyPlus', 'maly', 'Newest Coder on the Team', 'https://gamebanana.com/members/2014862', 'FFFFFF'],
			//fuck you maly, do something
			['A3ro', 'missing-icon', 'Also a new Coder', 'nolink', 'FFFFFF'],
			[''],
			['Translators'],
			['Jsa010',       	'jsa010',	        "Translated Almost The Entire Mod", 'https://twitter.com/_Jsa010_',   	'FFFFFF'],
			['DEMOLITIONDON96',	'demolitiondon96',	"Translated All The Warnings",	'https://youtube.com/c/DEMOLITIONDON96',	'FFFFFF'],
			[''],
			['Former Funkin avi members'],
			['pig69',	'missing-icon',	'Ex-artist of funkin.avi',	'nolink',	'FFFFFF'], //He was in GB credits, nothing else to do
			[''],
			['Demolition Engine Team'],
			['DEMOLITIONDON96',		'demolitiondon96',	'Creator of the Engine',			'https://youtube.com/c/DEMOLITIONDON96',	'03C6FC'],
			['Tony Time!',				'matt',				'Epic Coder \n(Did Lots of Cool Shit)',											'https://github.com/TonyTimee',			'444444'],
			['Cherif107',	'missing-icon',	'Cool Coder\nNice Guy',		'https://github.com/Cherif107',		'FFFFFF'],
			['PrismLight', 'prism', 'Minor Code',	'https://github.com/PrismLight', 	'3B3B3B',],
			['Theoyeah',	'theoyeah credit',		'Help with some code',	'https://github.com/Theoyeah',		'FFFFFF'],
			[''],
			['Extra Code'],
			['mayo78',   'missing-icon',     'Epic CPU Skin Code',        'https://github.com/mayo78',                'FFFFFF'],
			['Wither362',  'wither362',	'.mp3 & .wav file support\n(and for allowing me to add in some cool shit they made)',   'https://www.youtube.com/channel/UCsVr-qBLxT0uSWH037BmlHw',   '009BF4'],
			['lemz1',     'lemz1',            'Modchart Code for Game Window',        'https://github.com/lemz1',         '383838'],
			['Phoneguytech75', 'missing-icon', 'Note Skins :D',			'https://github.com/Phoneguytech75',	'FFFFFF'],
			['HiroMizuki',	'hiro',		'Pixel Splashes & \nScreen Resolution Code',	'https://github.com/HiroMizuki',	'3DED02'],
			['8bitjake',	'missing-icon',	'Hold Pieces Fix for Sidescroll Modcharts',	'https://github.com/ShadowMario/FNF-PsychEngine/pull/8676',		'FFFFFF'],
			['magnumsrtisswag',		'mag',	'Stage Editor',		'https://github.com/magnumsrtisswag',			'0B03FC'],
			['AlexDrar',		'missing-icon',	'Hard Code Song Shit',		'https://github.com/mayo78/PSYCHDISCUSSIONS/discussions/85',			'FFFFFF'],
			['Snow White Muffins',		'missing-icon',	'Moving Main Menu Code',		'https://www.youtube.com/watch?v=QZQJ701tAqQ',			'FFFFFF'],
			['TimothyFnf',		'missing-icon',	'Some Credit For Code',		'https://gamebanana.com/mods/370936',			'FFFFFF'],
			['KutikiPlayz',	'missing-icon',		'Scroll Type Event',		'https://github.com/KutikiPlayz',		'FFFFFF'],
			['Ash237',	'missing-icon',		'Funni Code',		'https://github.com/alexlolxp/baldi-source/commit/8bc86a45de3fba962539cab1258ebd48daf324a0',		'FFFFFF'],
			['Chimmie-mpeg',	'missing-icon',		'Chromatics for omni lol',		'https://github.com/Chimmie-mpeg/FNF-FANMADE-CHROMATIC-SCALES/tree/main/Chromatics%202.0',		'FFFFFF'],
			['NoahWantsDie',	'missing-icon',		'MIDI for omni (same i wanna die /j)',		'https://www.youtube.com/watch?v=2s5mDJrkFoc',		'FFFFFF'],
			['SaadTheDrip',	'missing-icon',		'open browser shit',		'https://github.com/mayo78/PSYCHDISCUSSIONS/discussions/611',		'FFFFFF'],
			[''],
			['Psych Engine Team'],
			['Shadow Mario',		'shadowmario',		'Main Programmer of Psych Engine',								'https://twitter.com/Shadow_Mario_',	'444444'],
			['RiverOaken',			'river',			'Main Artist/Animator of Psych Engine',							'https://twitter.com/RiverOaken',		'B42F71'],
			['shubs',				'shubs',			'Additional Programmer of Psych Engine',						'https://twitter.com/yoshubs',			'5E99DF'],
			[''],
			['Former Engine Members'],
			['bb-panzu',			'bb',				'Ex-Programmer of Psych Engine',								'https://twitter.com/bbsub3',			'3E813A'],
			[''],
			['Engine Contributors'],
			['iFlicky',				'flicky',			'Composer of Psync and Tea Time\nMade the Dialogue Sounds',		'https://twitter.com/flicky_i',			'9E29CF'],
			['SqirraRNG',			'sqirra',			'Crash Handler and Base code for\nChart Editor\'s Waveform',	'https://twitter.com/gedehari',			'E1843A'],
			['PolybiusProxy',		'proxy',			'.MP4 Video Loader Library (hxCodec)',							'https://twitter.com/polybiusproxy',	'DCD294'],
/*KADEDEV!!!*/			['KadeDev',				'kade',				'Fixed some cool stuff on Chart Editor\nand other PRs',			'https://twitter.com/kade0912',			'64A250'],
			['Keoiki',				'keoiki',			'Note Splash Animations',										'https://twitter.com/Keoiki_',			'D2D2D2'],
			['Nebula the Zorua',	'nebula',			'LUA JIT Fork and some Lua reworks',							'https://twitter.com/Nebula_Zorua',		'7D40B2'],
			['Smokey',				'smokey',			'Sprite Atlas Support',											'https://twitter.com/Smokey_5_',		'483D92'],
			[''],
			["Funkin' Crew"],
			['ninjamuffin99',		'ninjamuffin99',	"Programmer of Friday Night Funkin'",							'https://twitter.com/ninja_muffin99',	'CF2D2D'],
			['PhantomArcade',		'phantomarcade',	"Animator of Friday Night Funkin'",								'https://twitter.com/PhantomArcade3K',	'FADC45'],
			['evilsk8r',			'evilsk8r',			"Artist of Friday Night Funkin'",								'https://twitter.com/evilsk8r',			'5ABD4B'],
			['kawaisprite',			'kawaisprite',		"Composer of Friday Night Funkin'",								'https://twitter.com/kawaisprite',		'378FC7']
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
