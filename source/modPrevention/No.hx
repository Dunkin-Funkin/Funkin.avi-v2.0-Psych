package modPrevention;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import lime.app.Application;
import flash.system.System;

class No extends FlxState
{
	override public function create()
	{
		super.create();
        var cryAboutIt = new FlxSprite().loadGraphic(Paths.image('Piracy/piracyscreen-2'));
        cryAboutIt.screenCenter();
        add(cryAboutIt);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
        if (FlxG.keys.justPressed.ESCAPE) {
        FlxG.sound.play(Paths.sound('wiiCrash'), 1.8);
        Application.current.window.alert('Never, but never try, to do a mod on Funkin.avi Again...');
        System.exit(0);
		}
	}
}