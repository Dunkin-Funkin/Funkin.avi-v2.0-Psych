package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import PlayState;
import Shaders;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import openfl.filters.ShaderFilter;

using StringTools;

class EpicSelectorWOOO extends MusicBeatState {

	var unfinishedText:FlxText;

	var bloomShit:WIBloomEffect;
	var chrom:ChromaticAberrationEffect;
	var blurThisShit:TiltshiftEffect;
	var greyscale:GreyscaleEffect;
	var distort:WIDistortionEffect;

	var shaders:Array<ShaderEffect> = [];

	public var timesToEnter:Int = 30;
	var debugTxt:FlxText;

	//Spooky ass Mystery Effects OooooOOOooo
	//var 

	//public var camFilter:FlxCamera;
    var freeplayCats:Array<String>;
	var fpCateBanners:FlxSprite;
	var grpCats:FlxTypedGroup<Alphabet>;
	var curSelected:Int = 0;
	var noFreeplay:FlxText;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
	var noCovers:FlxText;
	var BG:FlxSprite;
    override function create(){

		timesToEnter = 30;

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
				//freeplayCats = ['V2 Content', 'Legacy', '???'];
		/*if(FPClientPrefs.episode2FPLock == 'unlocked' && FPClientPrefs.malfunctionLock == 'beaten' && FPClientPrefs.crossinLock == 'beaten' && FPClientPrefs.warLock == 'beaten' && FPClientPrefs.sinsLock == 'beaten' && FPClientPrefs.huntedLock == 'beaten' && FPClientPrefs.blessLock == 'beaten' && FPClientPrefs.scrappedLock == 'beaten' && FPClientPrefs.mercyLock == 'beaten' && FPClientPrefs.oldisolateLock == 'beaten' && FPClientPrefs.betaisolateLock == 'beaten') //omfg, I hate this, why can't it just work some other, much more SIMPLER way?
		{
			if(ClientPrefs.language == "Spanish") freeplayCats = ['Legado', 'Jugar', 'Un Mensaje Para It', 'Cubiertas'];
			else freeplayCats = ['Legacy', 'Episodes', 'Extras', 'Covers'];
		}else*/ if (FPClientPrefs.episode1FPLock == 'unlocked')
		{
			if(ClientPrefs.language == "Spanish") freeplayCats = ['Legado', 'Jugar', 'Extras'];
			else freeplayCats = ['Legacy', 'Episodes', 'Extras'];
		} else if(FPClientPrefs.muckneyLock == "completed") {
			if(ClientPrefs.language == "Spanish") freeplayCats = ['Legado', '???', 'Extras'];
			else freeplayCats = ['Legacy', '???', 'Extras'];
			} else {
			if(ClientPrefs.language == "Spanish") freeplayCats = ['Legado', '???', '???'];
			else freeplayCats = ['Legacy', '???', '???'];
			}

        BG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		BG.updateHitbox();
		BG.screenCenter();
		add(BG);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In Freeplay", "Category Menu", null, 'icon');
		#end

		Application.current.window.title = "Funkin.avi - Freeplay: Category Menu";

        grpCats = new FlxTypedGroup<Alphabet>();
		add(grpCats);
        for (i in 0...freeplayCats.length)
        {
			var catsText:Alphabet = new Alphabet(0, (70 * i) + 250, freeplayCats[i], true, false);
            catsText.targetY = i;
			catsText.isMenuItem = true;
			grpCats.add(catsText);
		}

		leftArrow = new FlxSprite(120, 0);
		leftArrow.frames = ui_tex;
		leftArrow.angle = 90;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.screenCenter(X);
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(leftArrow);

		rightArrow = new FlxSprite(leftArrow.x, leftArrow.y + 80);
		rightArrow.frames = ui_tex;
		//Im Fucking Lazy
		rightArrow.flipX = true;
		rightArrow.screenCenter(X);
		rightArrow.flipY = true;
		rightArrow.angle = 270;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(rightArrow);

		if(ClientPrefs.language == "Spanish") {
			unfinishedText = new FlxText(907, FlxG.height - 54, 0, "Por Ahora, Esto Esta Sin Terminar, La Version Final Sera Diferente!", 25);
			unfinishedText.scrollFactor.set();
			unfinishedText.screenCenter(X);
			unfinishedText.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 25, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(unfinishedText);
			} else {
			unfinishedText = new FlxText(907, FlxG.height - 54, 0, "Currently, The category Menu is Unfinished, The Final Verion Will Be Different!", 25);
			unfinishedText.scrollFactor.set();
			unfinishedText.screenCenter(X);
			unfinishedText.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 25, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(unfinishedText);
			}

			noFreeplay = new FlxText(350, FlxG.height - 350, 0, "Beat Episode 1 First!", 30);
			noFreeplay.scrollFactor.set();
			noFreeplay.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 80, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			noFreeplay.alpha = 0;
			noFreeplay.borderSize = 3.5;
			noFreeplay.borderQuality = 3.5;
			add(noFreeplay);

			noCovers = new FlxText(350, FlxG.height - 350, 0, "Beat All Freeplay Songs!", 30);
			noCovers.scrollFactor.set();
			noCovers.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 80, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			noCovers.alpha = 0;
			noCovers.borderSize = 3.5;
			noCovers.borderQuality = 3.5;
			add(noCovers);

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

		debugTxt = new FlxText(0, 0, 0, 'Void Menu Attempts: ${timesToEnter}', 50);
		//add(debugTxt);

        changeSelection();
        super.create();
    }

	function updateCounter()
	{
		timesToEnter -= 1;
		//debugTxt.text = 'Void Menu Attempts: ${timesToEnter}';
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

    override public function update(elapsed:Float){

		if (controls.UI_UP_P && curSelected != 0) 
			changeSelection(-1);
		else if (controls.UI_UP_P && curSelected == 0) {
			updateCounter();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
		if (controls.UI_DOWN_P && curSelected != 2) 
			changeSelection(1);
		else if (controls.UI_DOWN_P && curSelected == 2) {
			updateCounter();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
		//Mouse supremacy
		
		if (controls.BACK) {
			if (timesToEnter <= 0 && FPClientPrefs.muckneyLock == "uncompleted")
			{
				MusicBeatState.switchState(new VoidState());
			}else{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}

		}

		//yay
		if(FPClientPrefs.muckneyLock != "completed") {
		if(FlxG.mouse.overlaps(rightArrow)) {
			if(FlxG.mouse.justPressed && curSelected != 2)
				changeSelection(1);
			else if(FlxG.mouse.justPressed && curSelected == 2) {
				updateCounter();
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}
			}
			/*else if(Flx.mouse.justPressed && curSelected == 2 && timesToEnter == -1)
				MusicBeatState.switchState(new VoidState());*/
			//SECRET SONG?!?!?!?!?!
		if(FlxG.mouse.overlaps(leftArrow)) {
			if(FlxG.mouse.justPressed && curSelected != 0)
				changeSelection(-1);
			else if(FlxG.mouse.justPressed && curSelected == 0) {
				updateCounter();
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}
		}
		}


        if (controls.ACCEPT){
            switch(curSelected){
				case 0:
					MusicBeatState.switchState(new LegacyState());
                case 1:
				if(FPClientPrefs.episode1FPLock == 'unlocked')
				{
					MusicBeatState.switchState(new EpisodesState());
				}else{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					noFreeplay.alpha = 1;
					FlxTween.tween(noFreeplay, {alpha: 0}, 1.5, {ease: FlxEase.quadIn, startDelay: 2});
				}
                case 2:
					//MusicBeatState.switchState(new LegacyState());
					if(FPClientPrefs.episode1FPLock == 'unlocked' || FPClientPrefs.muckneyLock == "completed")
						{
							MusicBeatState.switchState(new ExtrasState());
						}else{
							FlxG.sound.play(Paths.sound('cancelMenu'));
							noFreeplay.alpha = 1;
							FlxTween.tween(noFreeplay, {alpha: 0}, 1.5, {ease: FlxEase.quadIn, startDelay: 2});
						}
				/*case 3:
					//MusicBeatState.switchState(new CoversState());
					/*if(FPClientPrefs.episode2FPLock == 'unlocked' && FPClientPrefs.malfunctionLock == 'beaten' && FPClientPrefs.crossinLock == 'beaten' && FPClientPrefs.warLock == 'beaten' && FPClientPrefs.sinsLock == 'beaten' && FPClientPrefs.huntedLock == 'beaten' && FPClientPrefs.blessLock == 'beaten' && FPClientPrefs.scrappedLock == 'beaten' && FPClientPrefs.mercyLock == 'beaten' && FPClientPrefs.oldisolateLock == 'beaten' && FPClientPrefs.betaisolateLock == 'beaten') //omfg, I hate this, why can't it just work some other, much more SIMPLER way?
					{
						MusicBeatState.switchState(new CoversState());
					}else{
						FlxG.sound.play(Paths.sound('cancelMenu'));
						noCovers.alpha = 1;
						FlxTween.tween(noCovers, {alpha: 0}, 1.5, {ease: FlxEase.quadIn, startDelay: 2});*/
					//}
			}
            }

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = freeplayCats.length - 1;
		if (curSelected >= freeplayCats.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpCats.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}
		FlxG.sound.play(Paths.sound('funkinAVI/menu/scroll_sfx'));

		/*if(curSelected == 3)
			{
				if(FPClientPrefs.malfunctionLock != 'beaten' || FPClientPrefs.crossinLock != 'beaten' || FPClientPrefs.warLock != 'beaten' || FPClientPrefs.sinsLock != 'beaten' || FPClientPrefs.huntedLock != 'beaten' || FPClientPrefs.blessLock != 'beaten' || FPClientPrefs.scrappedLock != 'beaten' || FPClientPrefs.mercyLock != 'beaten' || FPClientPrefs.oldisolateLock != 'beaten' || FPClientPrefs.betaisolateLock != 'beaten') //omfg, I hate this, why can't it just work some other, much more SIMPLER way?))
				{	
				FlxG.camera.flash(FlxColor.BLACK, 0.6);
				FlxG.camera.shake(0.004, 99999999);
				if(ClientPrefs.funiShaders)
				{
				clearShader();
				chrom = new ChromaticAberrationEffect();
				blurThisShit = new TiltshiftEffect(0.6, 0);

				distort = new WIDistortionEffect(0.75, 0.25, false);
				distort.shader.working.value = [true];

				addShader(distort);
				addShader(chrom);
				addShader(blurThisShit);

					if (chrom != null)
				chrom.setChrome(0.005);

				if(blurThisShit != null)
				blurThisShit.setBlur(0.6);

				if (distort != null)
				distort.shader.working.value = [true];
				}
			}
		}else if(curSelected == 2 && FPClientPrefs.episode1FPLock != 'unlocked' || curSelected == 1 && FPClientPrefs.episode1FPLock != 'unlocked')
						{
							FlxG.camera.flash(FlxColor.BLACK, 0.6);
							FlxG.camera.shake(0.004, 99999999);
							if(ClientPrefs.funiShaders)
							{
							clearShader();
							chrom = new ChromaticAberrationEffect();
							blurThisShit = new TiltshiftEffect(0.6, 0);

							distort = new WIDistortionEffect(0.75, 0.25, false);
							distort.shader.working.value = [true];

							addShader(distort);
							addShader(chrom);
							addShader(blurThisShit);

								if (chrom != null)
							chrom.setChrome(0.005);

							if(blurThisShit != null)
							blurThisShit.setBlur(0.6);

							if (distort != null)
							distort.shader.working.value = [true];
							}
						}else{
							FlxG.camera.flash(FlxColor.BLACK, 0.2);
							if(ClientPrefs.funiShaders)
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

							if(!ClientPrefs.optimization) {
							if (chrom != null)
							chrom.setChrome(0.003);

							if (bloomShit != null)
							bloomShit.setSize(18.0);

							if(blurThisShit != null)
							blurThisShit.setBlur(0.4);
							}
							//uncomment these fucking pieces of shit if you feel like testing it.
							}
							FlxG.camera.shake(0.004, 0);
						}*/
	}
}