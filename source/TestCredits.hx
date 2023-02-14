package ;

import haxe.Json;
import sys.io.File;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.display.GraphicsShader;
import openfl.filters.ShaderFilter;
import sys.FileSystem;

using StringTools;

/**
 * Credits shit there
 */
typedef Credits = {
    var name:String;
    var quote:String;
    var profession:String;
	var color:FlxColor;
}

/**
 * the actual class
 * 
 */
class TestCredits extends MusicBeatState {

	var icon:FlxSprite;
	var background:FlxSprite;

	override function create() {
		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}