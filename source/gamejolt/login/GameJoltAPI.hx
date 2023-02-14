package gamejolt.login;

import flixel.FlxG;

/**
 * Connects To FlxGameJolt or TentoolsStuff in Funkin.AVI Source code
 */
 class GameJoltAPI
 {
     /**
      * Inline variable to see if the user has logged in.
      * True for logged in, false for not logged in.
      */
     public static var userLogin:Bool = false; //For User Login Achievement (Like IC)
 
     /**
      * Inline variable to see if the user wants to submit scores.
      */
     public static var leaderboardToggle:Bool;
     /**
      * Grabs user data and returns as a string, true for Username, false for Token
      * @param username Bool value
      * @return String 
      */
     public static function getUserInfo(username:Bool = true):String
     {
         if(username)return GJApi.username;
         else return GJApi.usertoken;
     }
 
     /**
      * Returns the user login status
      * @return Bool
      */
     public static function getStatus():Bool
     {
         return userLogin;
     }
 
     /**
      * Sets the game API key from GJKeys.api
      * Doesn't return anything
      */
     public static function connect() 
     {
         trace("Grabbing API keys...");
         GJApi.init(Std.int(GJKeys.id), Std.string(GJKeys.key), function(data:Bool){
             #if debug
             //Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Game " + (data ? "authenticated!" : "not authenticated..."), (!data ? "If you are a developer, check GJKeys.hx\nMake sure the id and key are formatted correctly!" : "Yay!"), false);
             #end
         });
     }
 
     /**
      * Inline function to auth the user. Shouldn't be used outside of GameJoltAPI things.
      * @param in1 username
      * @param in2 token
      * @param loginArg Used in only GameJoltLogin
      */
     public static function authDaUser(in1, in2, ?loginArg:Bool = false)
     {
         if(!userLogin)
         {
             GJApi.authUser(in1, in2, function(v:Bool)
             {
                 trace("user: "+(in1 == "" ? "n/a" : in1));
                 trace("token: "+in2);
                 if(v)
                     {
                         //Main.gjToastManager.createToast(GameJoltInfo.imagePath, in1 + " SIGNED IN!", "CONNECTED TO GAMEJOLT", false);
                         trace("User authenticated!");
                         FlxG.save.data.gjUser = in1;
                         FlxG.save.data.gjToken = in2;
                         FlxG.save.flush();
                         userLogin = true;
                         startSession();
                         if(loginArg)
                         {
                             GameJoltLoginState.login=true;
                             FlxG.switchState(new GameJoltLoginState());
                         }
                     }
                 else 
                     {
                         if(loginArg)
                         {
                             GameJoltLoginState.login=true;
                             FlxG.switchState(new GameJoltLoginState());
                         }
                         //Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Not signed in!\nSign in to save GameJolt Trophies and Leaderboard Scores!", "", false);
                         trace("User login failure!");
                         // FlxG.switchState(new GameJoltLoginState());
                     }
             });
         }
     }
     
     /**
      * Inline function to deauth the user, shouldn't be used out of GameJoltLoginState state!
      * @return  Logs the user out and closes the game
      */
     public static function deAuthDaUser()
     {
         closeSession();
         userLogin = false;
         trace(FlxG.save.data.gjUser + FlxG.save.data.gjToken);
         FlxG.save.data.gjUser = "";
         FlxG.save.data.gjToken = "";
         FlxG.save.flush();
         trace(FlxG.save.data.gjUser + FlxG.save.data.gjToken);
         trace("Logged out!");
         lime.system.System.exit(0);
     }
 
     /**
      * Give a trophy!
      * @param trophyID Trophy ID. Check your game's API settings for trophy IDs.
      */
     public static function getTrophy(trophyID:Int) /* Awards a trophy to the user! */
     {
         if(userLogin)
         {
             GJApi.addTrophy(trophyID, function(data:Map<String,String>){
                 trace(data);
                 var bool:Bool = false;
                 if (data.exists("message"))
                     bool = true;
             });
         }
     }
 
     /**
      * Checks a trophy to see if it was collected
      * @param id TrophyID
      * @return Bool (True for achieved, false for unachieved)
      */
     public static function checkTrophy(id:Int):Bool
     {
         var value:Bool = false;
         GJApi.fetchTrophy(id, function(data:Map<String, String>)
             {
                 trace(data);
                 if (data.get("achieved").toString() != "false")
                     value = true;
                 trace(id+""+value);
             });
         return value;
     }
 
     public static function pullTrophy(?id:Int):Map<String,String>
     {
         var returnable:Map<String,String> = null;
         GJApi.fetchTrophy(id, function(data:Map<String,String>){
             trace(data);
             returnable = data;
         });
         return returnable;
     }
 
     /**
      * Add a score to a table!
      * @param score Score of the song. **Can only be an int value!**
      * @param tableID ID of the table you want to add the score to!
      * @param extraData (Optional) You could put accuracy or any other details here!
      */
     public static function addScore(score:Int, tableID:Int, ?extraData:String)
     {
         if (GameJoltAPI.leaderboardToggle)
         {
             trace("Trying to add a score");
             var formData:String = extraData.split(" ").join("%20");
             GJApi.addScore(score+"%20Points", score, tableID, false, null, formData, function(data:Map<String, String>){
                 trace("Score submitted with a result of: " + data.get("success"));
                 //Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Score submitted!", "Score: " + score + "\nExtra Data: "+extraData, true);
             });
         }
         else
         {
             //Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Score not submitted!", "Score: " + score + "Extra Data: " +extraData+"\nScore was not submitted due to score submitting being disabled!", true);
         }
     }
 
     /**
      * Return the highest score from a table!
      * 
      * Usable by pulling the data from the map by [function].get();
      * 
      * Values returned in the map: score, sort, user_id, user, extra_data, stored, guest, success
      * 
      * @param tableID The table you want to pull from
      * @return Map<String,String>
      */
     public static function pullHighScore(tableID:Int):Map<String,String>
     {
         var returnable:Map<String,String>;
         GJApi.fetchScore(tableID,1, function(data:Map<String,String>){
             trace(data);
             returnable = data;
         });
         return returnable;
     }
 
     /**
      * Inline function to start the session. Shouldn't be used out of GameJoltAPI
      * Starts the session
      */
     public static function startSession()
     {
         GJApi.openSession(function()
             {
                 trace("Session started!");
                 new flixel.util.FlxTimer().start(20, function(tmr:flixel.util.FlxTimer){pingSession();}, 0);
             });
     }
 
     /**
      * Tells GameJolt that you are still active!
      * Called every 20 seconds by a loop in startSession().
      */
     public static function pingSession()
     {
         GJApi.pingSession(true, function(){trace("Ping!");});
     }
 
     /**
      * Closes the session, used for signing out
      */
     public static function closeSession()
     {
         GJApi.closeSession(function(){trace('Closed out the session');});
     }
 }
 