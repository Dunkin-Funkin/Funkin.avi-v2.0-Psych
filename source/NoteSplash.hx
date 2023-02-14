package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwap = null;
	private var idleAnim:String;
	private var textureLoaded:String = null;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0) {
		super(x, y);

		switch(PlayState.curStage)
		{
			case 'RelapseStage':
				var skin:String = 'NoteSplashSkins/GREYnoteSplashes';
				if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

				loadAnims(skin);
				
				colorSwap = new ColorSwap();
				shader = colorSwap.shader;

				setupNoteSplash(x, y, note);
				antialiasing = ClientPrefs.globalAntialiasing;
			case 'WaltStage':
				var skin:String = 'NoteSplashSkins/waltSplashes';
				if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

				loadAnims(skin);
				
				colorSwap = new ColorSwap();
				shader = colorSwap.shader;

				setupNoteSplash(x, y, note);
				antialiasing = ClientPrefs.globalAntialiasing;
			case 'Studio' | 'Forest' | 'EndlessLoop' | 'ForestNEW' | 'Office':
				var skin:String = 'NoteSplashSkins/noteSplashesGREY';
				if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

				loadAnims(skin);
				
				colorSwap = new ColorSwap();
				shader = colorSwap.shader;

				setupNoteSplash(x, y, note);
				antialiasing = ClientPrefs.globalAntialiasing;
			default:
				var skin:String = 'NoteSplashSkins/noteSplashes';
				if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

				loadAnims(skin);
				
				colorSwap = new ColorSwap();
				shader = colorSwap.shader;

				setupNoteSplash(x, y, note);
				antialiasing = ClientPrefs.globalAntialiasing;
		}
	}

	public function setupNoteSplashShit(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0) {
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = 0.4;

		switch(PlayState.curStage)
		{
			case 'RelapseStage':
				if(texture == null) {
				texture = 'NoteSplashSkins/GREYnoteSplashes';
				if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;

				if(PlayState.isPixelStage) {
					texture = 'pixelUI/GREYnoteSplashes';
					if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = 'pixelUI/' + PlayState.SONG.splashSkin;
					if(animation.curAnim != null)animation.curAnim.frameRate = 12;
				}
			}
			case 'WaltStage':
				if(texture == null) {
				texture = 'NoteSplashSkins/waltSplashes';
				if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;

				if(PlayState.isPixelStage) {
					texture = 'pixelUI/noteSplashes';
					if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = 'pixelUI/' + PlayState.SONG.splashSkin;
					if(animation.curAnim != null)animation.curAnim.frameRate = 12;
				}
			}
			case 'Studio' | 'Forest' | 'EndlessLoop' | 'ForestNEW' | 'Office':
				if(texture == null) {
				texture = 'NoteSplashSkins/noteSplashesGREY';
				if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;

				if(PlayState.isPixelStage) {
					texture = 'pixelUI/noteSplashes';
					if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = 'pixelUI/' + PlayState.SONG.splashSkin;
					if(animation.curAnim != null)animation.curAnim.frameRate = 12;
				}
			}
			default:
				if(texture == null) {
					texture = 'NoteSplashSkins/NOTE_splashes-Better';
					if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
	
					if(PlayState.isPixelStage) {
						texture = 'pixelUI/NOTE_splashes-Better';
						if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = 'pixelUI/' + PlayState.SONG.splashSkin;
						if(animation.curAnim != null)animation.curAnim.frameRate = 12;
					}
			}
		}

			if(textureLoaded != texture) {
				loadAnims(texture);
			}
			colorSwap.hue = hueColor;
			colorSwap.saturation = satColor;
			colorSwap.brightness = brtColor;
			offset.set(10, 10);
	
			var animNum:Int = 1;
			animation.play('shitnote' + note + '-' + animNum, true);
			if(animation.curAnim != null)animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	public function setupNoteSplashMarvelous(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0) {
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = 1;

		switch(PlayState.curStage)
		{
			case 'RelapseStage':
				if(texture == null) {
				texture = 'NoteSplashSkins/GREYnoteSplashes';
				if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;

				if(PlayState.isPixelStage) {
					texture = 'pixelUI/GREYnoteSplashes';
					if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = 'pixelUI/' + PlayState.SONG.splashSkin;
					if(animation.curAnim != null)animation.curAnim.frameRate = 12;
				}
			}
			case 'WaltStage':
				if(texture == null) {
				texture = 'NoteSplashSkins/waltSplashes';
				if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;

				if(PlayState.isPixelStage) {
					texture = 'pixelUI/noteSplashes';
					if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = 'pixelUI/' + PlayState.SONG.splashSkin;
					if(animation.curAnim != null)animation.curAnim.frameRate = 12;
				}
			}
			case 'Studio' | 'Forest' | 'EndlessLoop' | 'ForestNEW' | 'Office':
				if(texture == null) {
				texture = 'NoteSplashSkins/noteSplashesGREY';
				if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;

				if(PlayState.isPixelStage) {
					texture = 'pixelUI/noteSplashes';
					if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = 'pixelUI/' + PlayState.SONG.splashSkin;
					if(animation.curAnim != null)animation.curAnim.frameRate = 12;
				}
			}
			default:
				if(texture == null) {
				texture = 'NoteSplashSkins/NOTE_splashes-Better';
				if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;

				if(PlayState.isPixelStage) {
					texture = 'pixelUI/NOTE_splashes-Better';
					if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = 'pixelUI/' + PlayState.SONG.splashSkin;
					if(animation.curAnim != null)animation.curAnim.frameRate = 12;
				}
			}
		}

			if(textureLoaded != texture) {
				loadAnims(texture);
			}
			colorSwap.hue = hueColor;
			colorSwap.saturation = satColor;
			colorSwap.brightness = brtColor;
			offset.set(10, 10);
	
			var animNum:Int = 1;
			animation.play('marvnote' + note + '-' + animNum, true);
			if(animation.curAnim != null)animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	public function setupNoteSplashSick(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0) {
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = 0.8;

		switch(PlayState.curStage)
		{
			case 'RelapseStage':
				if(texture == null) {
				texture = 'NoteSplashSkins/GREYnoteSplashes';
				if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;

				if(PlayState.isPixelStage) {
					texture = 'pixelUI/GREYnoteSplashes';
					if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = 'pixelUI/' + PlayState.SONG.splashSkin;
					if(animation.curAnim != null)animation.curAnim.frameRate = 12;
				}
			}
			case 'WaltStage':
				if(texture == null) {
				texture = 'NoteSplashSkins/waltSplashes';
				if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;

				if(PlayState.isPixelStage) {
					texture = 'pixelUI/noteSplashes';
					if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = 'pixelUI/' + PlayState.SONG.splashSkin;
					if(animation.curAnim != null)animation.curAnim.frameRate = 12;
				}
			}
			case 'Studio' | 'Forest' | 'EndlessLoop' | 'ForestNEW' | 'Office':
				if(texture == null) {
				texture = 'NoteSplashSkins/noteSplashesGREY';
				if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;

				if(PlayState.isPixelStage) {
					texture = 'pixelUI/noteSplashes';
					if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = 'pixelUI/' + PlayState.SONG.splashSkin;
					if(animation.curAnim != null)animation.curAnim.frameRate = 12;
				}
			}
			default:
				if(texture == null) {
					texture = 'NoteSplashSkins/NOTE_splashes-Better';
					if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
	
					if(PlayState.isPixelStage) {
						texture = 'pixelUI/NOTE_splashes-Better';
						if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = 'pixelUI/' + PlayState.SONG.splashSkin;
						if(animation.curAnim != null)animation.curAnim.frameRate = 12;
					}
			}
		}
			if(textureLoaded != texture) {
				loadAnims(texture);
			}
			colorSwap.hue = hueColor;
			colorSwap.saturation = satColor;
			colorSwap.brightness = brtColor;
			offset.set(10, 10);
	
			var animNum:Int = FlxG.random.int(1, 2);
			animation.play('sicknote' + note + '-' + animNum, true);
			if(animation.curAnim != null)animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0) {
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = 0.6;

		switch(PlayState.curStage)
		{
			case 'RelapseStage':
				if(texture == null) {
				texture = 'NoteSplashSkins/GREYnoteSplashes';
				if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;

				if(PlayState.isPixelStage) {
					texture = 'pixelUI/GREYnoteSplashes';
					if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = 'pixelUI/' + PlayState.SONG.splashSkin;
					if(animation.curAnim != null)animation.curAnim.frameRate = 12;
				}
			}
			case 'WaltStage':
				if(texture == null) {
				texture = 'NoteSplashSkins/waltSplashes';
				if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;

				if(PlayState.isPixelStage) {
					texture = 'pixelUI/noteSplashes';
					if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = 'pixelUI/' + PlayState.SONG.splashSkin;
					if(animation.curAnim != null)animation.curAnim.frameRate = 12;
				}
			}
			case 'Studio' | 'Forest' | 'EndlessLoop' | 'ForestNEW' | 'Office':
				if(texture == null) {
				texture = 'NoteSplashSkins/noteSplashesGREY';
				if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;

				if(PlayState.isPixelStage) {
					texture = 'pixelUI/noteSplashes';
					if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = 'pixelUI/' + PlayState.SONG.splashSkin;
					if(animation.curAnim != null)animation.curAnim.frameRate = 12;
				}
			}
			default:
				if(texture == null) {
				texture = 'NoteSplashSkins/NOTE_splashes-Better';
				if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;

				if(PlayState.isPixelStage) {
					texture = 'pixelUI/NOTE_splashes-Better';
					if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = 'pixelUI/' + PlayState.SONG.splashSkin;
					if(animation.curAnim != null)animation.curAnim.frameRate = 12;
				}
			}
		}

		if(textureLoaded != texture) {
			loadAnims(texture);
		}
		colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;
		offset.set(10, 10);

		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + note + '-' + animNum, true);
		if(animation.curAnim != null)animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	function loadAnims(skin:String) {
		frames = Paths.getSparrowAtlas(skin);
		for (i in 1...3) {
			animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
			animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
			animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
			animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
			animation.addByPrefix("sicknote1-" + i, "note splash diamond blue " + i, 24, false);
			animation.addByPrefix("sicknote2-" + i, "note splash diamond green " + i, 24, false);
			animation.addByPrefix("sicknote0-" + i, "note splash diamond purple " + i, 24, false);
			animation.addByPrefix("sicknote3-" + i, "note splash diamond red " + i, 24, false);
			animation.addByPrefix("marvnote1-" + i, "note splash sparkle blue " + i, 24, false);
			animation.addByPrefix("marvnote2-" + i, "note splash sparkle green " + i, 24, false);
			animation.addByPrefix("marvnote0-" + i, "note splash sparkle purple " + i, 24, false);
			animation.addByPrefix("marvnote3-" + i, "note splash sparkle red " + i, 24, false);
			animation.addByPrefix("shitnote1-" + i, "note splash electric blue " + i, 24, false);
			animation.addByPrefix("shitnote2-" + i, "note splash electric green " + i, 24, false);
			animation.addByPrefix("shitnote0-" + i, "note splash electric purple " + i, 24, false);
			animation.addByPrefix("shitnote3-" + i, "note splash electric red " + i, 24, false);
		}
	}

	override function update(elapsed:Float) {
		if(animation.curAnim != null)if(animation.curAnim.finished) kill();

		super.update(elapsed);
	}
}