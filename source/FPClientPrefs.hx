package;

//I'm fucking lazy, pls don't kill me ourple guy team :(

#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import openfl.filters.ShaderFilter;
import WeekData;
import Shaders;
import flixel.addons.display.FlxTiledSprite;
import flixel.util.FlxSave;
import flixel.FlxCamera;
import flixel.system.FlxAssets;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FPClientPrefs
{
    public static var beatenAllDemoSongs:String = 'Incomplete';

    public static var isolatedSong:String = 'Incomplete';
    public static var lunacySong:String = 'Incomplete';
    public static var twistedSong:String = 'Incomplete';

    public static var episode1FPLock:String = 'locked';
    public static var episode2FPLock:String = 'locked';

    public static var huntedLock:String = 'locked';
    public static var oldisolateLock:String = 'locked';
    public static var betaisolateLock:String = 'locked';
    public static var malfunctionLock:String = 'locked';
    public static var revengeLock:String = 'locked';
    public static var blessLock:String = 'locked';
    public static var scrappedLock:String = 'locked';
    public static var sinsLock:String = 'locked';
    public static var warLock:String = 'locked';
    public static var crossinLock:String = 'locked';
    public static var mercyLock:String = 'locked';
    public static var pnmLock:String = 'locked';
    public static var rbLock:String = 'locked';
    public static var muckneyLock:String = "uncompleted";

    public static function lockinIt() {
        if (FlxG.save.data.beatenAllDemoSongs == null) FlxG.save.data.beatenAllDemoSongs == 'Incomplete';

        if (FlxG.save.data.isolatedSong == null) FlxG.save.data.isolatedSong == 'Incomplete';
        if (FlxG.save.data.lunacySong == null) FlxG.save.data.lunacySong == 'Incomplete';
        if (FlxG.save.data.twistedSong == null) FlxG.save.data.twistedSong == 'Incomplete';

        if (FlxG.save.data.episode1FPLock == null) FlxG.save.data.episode1FPLock = 'locked';
        if (FlxG.save.data.episode2FPLock == null) FlxG.save.data.episode2FPLock = 'locked';

        if (FlxG.save.data.huntedLock == null) FlxG.save.data.huntedLock = 'locked';
        if (FlxG.save.data.oldisolateLock == null) FlxG.save.data.oldisolateLock = 'locked';
        if (FlxG.save.data.betaisolateLock == null) FlxG.save.data.betaisolateLock = 'locked';
        if (FlxG.save.data.malfunctionLock == null) FlxG.save.data.malfunctionLock = 'locked';
        if (FlxG.save.data.revengeLock == null) FlxG.save.data.revengeLock = 'locked';
        if (FlxG.save.data.blessLock == null) FlxG.save.data.blessLock = 'locked';
        if (FlxG.save.data.scrappedLock == null) FlxG.save.data.scrappedLock = 'locked';
        if (FlxG.save.data.sinsLock == null) FlxG.save.data.sinsLock = 'locked';
        if (FlxG.save.data.warLock == null) FlxG.save.data.warLock = 'locked';
        if (FlxG.save.data.crossinLock == null) FlxG.save.data.crossinLock = 'locked';
        if (FlxG.save.data.mercyLock == null) FlxG.save.data.mercyLock = 'locked';
        if (FlxG.save.data.pnmLock == null) FlxG.save.data.pnmLock = 'locked';
        if (FlxG.save.data.rbLock == null) FlxG.save.data.rbLock = 'locked';
        if (FlxG.save.data.muckneyLock == null) FlxG.save.data.muckneyLock = "uncompleted";
        FlxG.save.flush();
    }

    public static function saveShit() {
        FlxG.save.data.beatenAllDemoSongs = beatenAllDemoSongs;

        FlxG.save.data.isolatedSong = isolatedSong;
        FlxG.save.data.lunacySong = lunacySong;
        FlxG.save.data.twistedSong = twistedSong;

        FlxG.save.data.episode1FPLock = episode1FPLock;
        FlxG.save.data.episode2FPLock = episode2FPLock;

        FlxG.save.data.huntedLock = huntedLock;
        FlxG.save.data.oldisolateLock = oldisolateLock;
        FlxG.save.data.betaisolateLock = betaisolateLock;
        FlxG.save.data.malfunctionLock = malfunctionLock;
        FlxG.save.data.revengeLock = revengeLock;
        FlxG.save.data.blessLock = blessLock;
        FlxG.save.data.scrappedLock = scrappedLock;
        FlxG.save.data.sinsLock = sinsLock;
        FlxG.save.data.warLock = warLock;
        FlxG.save.data.crossinLock = crossinLock;
        FlxG.save.data.mercyLock = mercyLock;
        FlxG.save.data.pnmLock = pnmLock;
        FlxG.save.data.rbLock = rbLock;
        FlxG.save.data.muckneyLock = muckneyLock;
        FlxG.save.flush();
    }

    public static function loadShit() {

        isolatedSong = FlxG.save.data.isolatedSong;
        lunacySong = FlxG.save.data.lunacySong;
        twistedSong = FlxG.save.data.twistedSong;

        episode1FPLock = FlxG.save.data.episode1FPLock;
        episode2FPLock = FlxG.save.data.episode2FPLock;

        huntedLock = FlxG.save.data.huntedLock;
        oldisolateLock = FlxG.save.data.oldisolateLock;
        betaisolateLock = FlxG.save.data.betaisolateLock;
        malfunctionLock = FlxG.save.data.malfunctionLock;
        revengeLock = FlxG.save.data.revengeLock;
        blessLock = FlxG.save.data.blessLock;
        scrappedLock = FlxG.save.data.scrappedLock;
        sinsLock = FlxG.save.data.sinsLock;
        warLock = FlxG.save.data.warLock;
        crossinLock = FlxG.save.data.crossinLock;
        mercyLock = FlxG.save.data.mercyLock;
        pnmLock = FlxG.save.data.pnmLock;
        rbLock = FlxG.save.data.rbLock;
        muckneyLock = FlxG.save.data.muckneyLock;
        if(isolatedSong == 'Completed' && lunacySong == 'Completed' && twistedSong == 'Completed' && huntedLock == 'beaten' && oldisolateLock == 'beaten' && malfunctionLock == 'beaten' && sinsLock == 'beaten') FlxG.save.data.beatenAllDemoSongs = 'Complete';
        FlxG.save.flush();
    }
}