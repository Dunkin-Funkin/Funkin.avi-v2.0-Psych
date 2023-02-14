package; //little comments

//Flixel Shit
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxSprite;

//OpenFL Shit
import openfl.Lib;

//Lime Shit
import lime.app.Application;

//sometimes this is unneccesary but it feels neceesary
using StringTools;

class MemeGameOverState extends MusicBeatState
{
  var randomGameOverText:Array<String> = ['DAMN BITCH', 'i wll shoot you', 'Funkin.AVI + W.I >>>', 'Skill Issue', 'Bro do you not know how to play FNF', 'Get the mechanics right', 'pussy']; //OMG LUA?!
  var frGameOverText:FlxText;

  override function create
  {
    Application.current.window.title = "omg you found the secret game over... Stupid FNF Kid - Da Furry That Works On This Stupid Shitty Game Over State";
    frGameOverText = new FlxText(0, 0, 0, randomGameOverText, 20); //NOT STOLEN TRUST ME!!!!!!!!!!!!!!!!!!!!
    if (!PlayState.isPixelStage) {
      switch(PlayState.curStage)
      {
        case 'EndlessLoop' | 'Forest' | 'Office' | 'Studio' | 'ForestNEW' | 'LegacyLoop':
          frGameOverText.setFormat(Paths.font("NewWaltDisneyFontRegular-BPen.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        case 'PixelWorld':
          frGameOverText.setFormat(Paths.font("Retro Gaming.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        default:
          frGameOverText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
      }
      } else {
        frGameOverText.setFormat(Paths.font("Retro Gaming.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
      }
    frGameOverText.borderSize = 2;
    frGameOverText.borderQuality = 2;
    frGameOverText.scrollFactor.set();
    frGameOverText.screenCenter(X);
    add(frGameOverText);

    var bf:FlxSprite = new FlxSprite();
    bf.frames = Paths.getSparrowAtlas('meWhenIFunkOnAFridayNight', 'secrets'); //OMG SECRET HISTORY TAILS?!?!?!?!?!?!?!?!?
    bf.animation.addByPrefix('idle', 'fnf-boyfriend-friday-night-funkin', 24, true);
    bf.animation.play('idle');
    bf.screenCenter();
    bf.scale.x = 1.1;
    bf.scale.y = 1.1; //big boi
    add(bf);
  }
}
