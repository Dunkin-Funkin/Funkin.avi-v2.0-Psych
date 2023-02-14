package gamejolt;

// GameJolt things
import flixel.addons.ui.FlxUIState;
import haxe.iterators.StringIterator;
import TentoolsStuff as GJApi;
import gamejolt.*;

// Login things
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIInputText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import lime.system.System;
import flixel.FlxSprite;
import flixel.ui.FlxBar;

// Toast things
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.display.BitmapData;
import openfl.text.TextField;
import openfl.display.Bitmap;
import openfl.text.TextFormat;
import openfl.Lib;
import flixel.FlxG;
import openfl.display.Sprite;
import gamejolt.*;
import gamejolt.login.*;

using StringTools;

class GameJoltLoginState extends MusicBeatState
{
    var loginTexts:FlxTypedGroup<FlxText>;
    var loginBoxes:FlxTypedGroup<FlxUIInputText>;
    var loginButtons:FlxTypedGroup<FlxButton>;
    var usernameText:FlxText;
    var tokenText:FlxText;
    var usernameBox:FlxUIInputText;
    var tokenBox:FlxUIInputText;
    var signInBox:FlxButton;
    var helpBox:FlxButton;
    var logOutBox:FlxButton;
    var cancelBox:FlxButton;
    // var profileIcon:FlxSprite;
    var username1:FlxText;
    var username2:FlxText;
    // var gamename:FlxText;
    // var trophy:FlxBar;
    // var trophyText:FlxText;
    // var missTrophyText:FlxText;
    public static var charBop:FlxSprite;
    // var icon:FlxSprite;
    var baseX:Int = -190;
    public static var login:Bool = false;
    // static var trophyCheck:Bool = false;
    override function create()
    {
        if (FlxG.save.data.lbToggle != null)
        {
            GameJoltAPI.leaderboardToggle = FlxG.save.data.lbToggle;
        }

        if(!login)
        {
            FlxG.sound.playMusic(Paths.music('freakyMenu'),0);
            FlxG.sound.music.fadeIn(2, 0, 0.85);
        }

        trace(GJApi.initialized);
        FlxG.mouse.visible = true;

        Conductor.changeBPM(102);

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat', 'preload'));
		bg.setGraphicSize(FlxG.width);
		bg.antialiasing = true;
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set();
		bg.alpha = 0.25;
		add(bg);

        charBop = new FlxSprite(FlxG.width - 400, 250);
		charBop.frames = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared');
		charBop.animation.addByPrefix('idle', 'BF idle dance', 24, false);
        charBop.animation.addByPrefix('loggedin', 'BF HEY', 24, false);
        charBop.setGraphicSize(Std.int(charBop.width * 1.4));
		charBop.antialiasing = true;
        charBop.flipX = false;
		add(charBop);

        loginTexts = new FlxTypedGroup<FlxText>(2);
        add(loginTexts);

        usernameText = new FlxText(0, 125, 300, "Username:", 20);

        tokenText = new FlxText(0, 225, 300, "Token:", 20);

        loginTexts.add(usernameText);
        loginTexts.add(tokenText);
        loginTexts.forEach(function(item:FlxText){
            item.screenCenter(X);
            item.x += baseX;
            item.font = GameJoltInfo.font;
        });

        loginBoxes = new FlxTypedGroup<FlxUIInputText>(2);
        add(loginBoxes);

        usernameBox = new FlxUIInputText(0, 175, 300, null, 32, FlxColor.BLACK, FlxColor.GRAY);
        tokenBox = new FlxUIInputText(0, 275, 300, null, 32, FlxColor.BLACK, FlxColor.GRAY);

        loginBoxes.add(usernameBox);
        loginBoxes.add(tokenBox);
        loginBoxes.forEach(function(item:FlxUIInputText){
            item.screenCenter(X);
            item.x += baseX;
            item.font = GameJoltInfo.font;
        });

        if(GameJoltAPI.getStatus())
        {
            remove(loginTexts);
            remove(loginBoxes);
        }

        loginButtons = new FlxTypedGroup<FlxButton>(3);
        add(loginButtons);

        signInBox = new FlxButton(0, 475, "Sign In", function()
        {
            trace(usernameBox.text);
            trace(tokenBox.text);
            if(usernameBox.text != null || usernameBox.text != '' || tokenBox.text != null || tokenBox.text != "") //Prevent Crashes
            GJClient.setUserInfo(usernameBox.text,tokenBox.text);
        });

        helpBox = new FlxButton(0, 550, "GameJolt Token", function()
        {
            if (!GameJoltAPI.getStatus())
                openLink('https://www.youtube.com/watch?v=T5-x7kAGGnE');
            else
            {
                GJClient.toggleAutoLogin(true);
                //Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Score Submitting", "Score submitting is now " + (GameJoltAPI.leaderboardToggle ? "Enabled":"Disabled"), false);
            }
        });
        helpBox.color = FlxColor.fromRGB(84,155,149);

        logOutBox = new FlxButton(0, 625, "Log Out & Close", function()
        {
            GJClient.setUserInfo(null, null);
        });
        logOutBox.color = FlxColor.RED /*FlxColor.fromRGB(255,134,61)*/ ;

        cancelBox = new FlxButton(0,625, "Not Right Now", function()
        {
            FlxG.save.flush();
            FlxG.sound.play(Paths.sound('confirmMenu'), 0.7, false, null, true, function(){
                FlxG.save.flush();
                FlxG.switchState(GameJoltInfo.changeState);
            });
        });

        if(!GameJoltAPI.getStatus())
        {
            loginButtons.add(signInBox);
        }
        else
        {
            cancelBox.y = 475;
            cancelBox.text = "Continue";
            loginButtons.add(logOutBox);
        }
        loginButtons.add(helpBox);
        loginButtons.add(cancelBox);

        loginButtons.forEach(function(item:FlxButton){
            item.screenCenter(X);
            item.setGraphicSize(Std.int(item.width) * 3);
            item.x += baseX;
        });

        if(GameJoltAPI.getStatus())
        {
            username1 = new FlxText(0, 95, 0, "Signed in as:", 40);
            username1.alignment = CENTER;
            username1.screenCenter(X);
            username1.x += baseX;
            add(username1);

            username2 = new FlxText(0, 145, 0, "" + GJClient.getUserData() + "", 40);
            username2.alignment = CENTER;
            username2.screenCenter(X);
            username2.x += baseX;
            add(username2);
        }

        if(GameJoltInfo.font != null)
        {       
            username1.font = GameJoltInfo.font;
            username2.font = GameJoltInfo.font;
            loginBoxes.forEach(function(item:FlxUIInputText){
                item.font = GameJoltInfo.font;
            });
            loginTexts.forEach(function(item:FlxText){
                item.font = GameJoltInfo.font;
            });
        }
    }

    override function update(elapsed:Float)
    {
        if (FlxG.save.data.lbToggle == null)
        {
            FlxG.save.data.lbToggle = false;
            FlxG.save.flush();
        }

        if(GJClient.logged)
            {
                MusicBeatState.switchState(new MainMenuState());
                //notification code sweep
                PlatformUtil.sendNotification('GameJolt INFO', 'The User Has Logged To GameJolt!');
            }

        if (GameJoltAPI.getStatus())
        {
            helpBox.text = "Toggle Autologin:\n" + (GJClient.autoLogin ? "Enabled" : "Disabled");
            helpBox.color = (GJClient.autoLogin ? FlxColor.GREEN : FlxColor.RED);
        }

        if (FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;

        if (!FlxG.sound.music.playing)
        {
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
        }

        if (FlxG.keys.justPressed.ESCAPE)
        {
            FlxG.save.flush();
            FlxG.mouse.visible = false;
            FlxG.switchState(GameJoltInfo.changeState);
        }

        super.update(elapsed);
    }

    override function beatHit()
    {
        super.beatHit();
       // charBop.animation.play((GameJoltAPI.getStatus() ? "loggedin" : "idle"));
    }
    function openLink(url:String)
    {
        #if linux
        Sys.command('/usr/bin/xdg-open', [url, "&"]);
        #else
        FlxG.openURL(url);
        #end
    }
}