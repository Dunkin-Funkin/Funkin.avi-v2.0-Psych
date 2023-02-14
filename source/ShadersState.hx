//sorry but i have to do it :(

    package;

    import flixel.FlxG;
    import flixel.FlxSprite;
    import flixel.FlxSubState;
    import flixel.text.FlxText;
    import flixel.util.FlxColor;
    import flixel.effects.FlxFlicker;
    import lime.app.Application;
    import flash.system.System;
    import flixel.addons.transition.FlxTransitionableState;
    import flixel.tweens.FlxTween;
    import flixel.util.FlxTimer;
    import openfl.filters.BitmapFilter;
    import openfl.filters.ShaderFilter;
    import Shaders;
    
    class ShadersState extends MusicBeatState
    {
        public static var leftState:Bool = false;
    
        var bloomShit:WIBloomEffect;
        var chrom:ChromaticAberrationEffect;
        var blurThisShit:TiltshiftEffect;
        var greyscale:GreyscaleEffect;
    
        var shaders:Array<ShaderEffect> = [];
    
        var blackFade:FlxSprite; //copy from DisclaimerState, whatever, it works
        var warnText:FlxText;
        override function create()
        {
            super.create();
        
            var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
            add(bg);

            warnText = new FlxText(0, 0, FlxG.width,
            "Should The Game Run Shaders?/Debe el juego ejecutar shaders?\n\nPress ENTER To Accept\nOr Press ESC For Reject Shaders/O presiona ESC para rechazar los shaders",
            32);
            warnText.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 32, FlxColor.WHITE, CENTER);
            warnText.screenCenter(Y);
            warnText.screenCenter(X);
            add(warnText);
            
            blackFade = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
            add(blackFade);
    
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
            
            FlxTween.tween(blackFade, {alpha: 0}, 1); //duplicatin' code from Disclaimer since this is BEFORE picking your language now.
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
    
        override function update(elapsed:Float)
        {
            if(!leftState) {
                var back:Bool = controls.BACK;
                if (controls.ACCEPT || back) {
                    leftState = true;
                    FlxTransitionableState.skipNextTransIn = true;
                    FlxTransitionableState.skipNextTransOut = true;
                    if(!back) {
                        ClientPrefs.funiShaders = true;
                        ClientPrefs.saveSettings();
                        FlxG.sound.play(Paths.sound('funkinAVI/menu/select_sfx'));
                        FlxTween.tween(blackFade, {alpha: 1}, 1, {
                            onComplete: function (twn:FlxTween) {
                                MusicBeatState.switchState(new FlashingState());
                            }
                        });
                    } else {
                        ClientPrefs.funiShaders = false;
                        FlxG.sound.play(Paths.sound('funkinAVI/menu/select_sfx'));
                        FlxTween.tween(blackFade, {alpha: 1}, 1, {
                            onComplete: function (twn:FlxTween) {
                                MusicBeatState.switchState(new FlashingState());
                            }
                        });
                    }
                }
            }
            super.update(elapsed);
        }
    }
    