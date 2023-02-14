package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import lime.app.Application;

using StringTools;

class StupidShittyNewFreeplayCategoryExample extends MusicBeatState
{
      var BG:FlxSprite;
      var BG2:FlxSprite;
      var BG3:FlxSprite;
      var tag1:FlxSprite;
      var tag2:FlxSprite;

      private var camGame:FlxCamera;

      override function create()
      {
            FlxG.mouse.visible = true;

            camGame = new FlxCamera();
            FlxG.cameras.reset(camGame);
            FlxCamera.defaultCameras = [camGame];

            transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In Freeplay", "Category Menu", null, 'icon');
		#end

            Application.current.window.title = "Funkin.avi - Freeplay: Category Menu";

            switch (FlxG.random.int(1, 3))
            {
            case 1:
            BG = new FlxSprite().loadGraphic(Paths.image('funkinAVI-freeplayBGs/Mickeybg'));
		BG.updateHitbox();
		BG.screenCenter();
		add(BG);

            case 2:
            BG2 = new FlxSprite().loadGraphic(Paths.image('funkinAVI-freeplayBGs/office'));
		BG2.updateHitbox();
		BG2.screenCenter();
		add(BG2);

            case 3:
            BG3 = new FlxSprite().loadGraphic(Paths.image('funkinAVI-freeplayBGs/forest'));
            BG3.updateHitbox();
            BG3.screenCenter();
            add(BG3);
      }

            tag1 = new FlxSprite().loadGraphic(Paths.image('BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'));
            tag1.updateHitbox();
            tag1.antialiasing = ClientPrefs.globalAntialiasing;
            tag1.screenCenter(Y);
            tag1.x -= -140; //IDK
            add(tag1);

            tag2 = new FlxSprite().loadGraphic(Paths.image('Mickey_Mouse_South_Park'));
            tag2.updateHitbox();
            tag2.antialiasing = ClientPrefs.globalAntialiasing;
            tag2.screenCenter(Y);
            tag2.x += 740; //IDK
            add(tag2); //Tony, you made me be 1 hour fixing this for nothing

            var text:FlxText = new FlxText(60, FlxG.height - 104, 0, "Choose...", 12);
		text.scrollFactor.set();
		text.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            text.screenCenter(X);
		add(text);

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

      var selectedSomethin:Bool = false;

      override function update(elapsed:Float)
            {
                  if (!selectedSomethin)
                        {
                              if (controls.BACK)
                              {
                                    selectedSomethin = true;
                                    FlxG.sound.play(Paths.sound('cancelMenu'));
                                    MusicBeatState.switchState(new MainMenuState());
                              }

                              if(FlxG.mouse.overlaps(tag1) && FlxG.mouse.justPressed){
                                    MusicBeatState.switchState(new EpisodesState());
                                    selectedSomethin = true;
                                    FlxG.sound.play(Paths.sound('confirmMenu'));
                              }

                              if(FlxG.mouse.overlaps(tag2) && FlxG.mouse.justPressed){
                                    MusicBeatState.switchState(new ExtrasState());
                                    selectedSomethin = true;
                                    FlxG.sound.play(Paths.sound('confirmMenu'));
                              }
                        }
                        super.update(elapsed);
            }
}