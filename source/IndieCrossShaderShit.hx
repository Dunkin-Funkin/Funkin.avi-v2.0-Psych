import openfl.filters.ColorMatrixFilter;
import openfl.filters.BitmapFilter;
import flixel.FlxG;
import flixel.graphics.tile.FlxGraphicsShader;
import openfl.filters.ShaderFilter;
import flixel.system.FlxAssets.FlxShader;

class FXHandler
{
    public static var matrix:Array<Float>;
    public static var colorM:Array<Float>;

    public static function UpdateColors(?input:Array<BitmapFilter> = null):Void
    {
        trace("VALUE: " + ClientPrefs.colorblind);

        var filters:Array<BitmapFilter> = [];

        var a1:Float = 1;
        var a2:Float = 0;
        var a3:Float = 0;

        var b1:Float = 0;
        var b2:Float = 1;
        var b3:Float = 0;

        var c1:Float = 0;
        var c2:Float = 0;
        var c3:Float = 1;

        switch (ClientPrefs.colorblind)
        {
            case 'No color filter':
                trace('No color filter');
                a1 = 1; b1 = 0; c1 = 0;
                a2 = 0; b2 = 1; c2 = 0;
                a3 = 0; b3 = 0; c3 = 1;
            case 'Protanopia filter':
                trace('Protanopia filter');
                a1 = 0.567; b1 = 0.433; c1 = 0;
                a2 = 0.558; b2 = 0.442; c2 = 0;
                a3 = 0; b3 = 0.242; c3 = 0.758;
            case 'Protanomaly filter':
                trace('Protanomaly filter');
                a1 = 0.817; b1 = 0.183; c1 = 0;
                a2 = 0.333; b2 = 0.667; c2 = 0;
                a3 = 0; b3 = 0.125; c3 = 0.875;
            case 'Deuteranopia filter':
                trace('Deuteranopia filter');
                a1 = 0.625; b1 = 0.375; c1 = 0;
                a2 = 0.7; b2 = 0.3; c2 = 0;
                a3 = 0; b3 = 0; c3 = 1.0;
            case 'Deuteranomaly filter':
                trace('Deuteranomaly filter');
                a1 = 0.8; b1 = 0.2; c1 = 0;
                a2 = 0.258; b2 = 0.742; c2 = 0;
                a3 = 0; b3 = 0.142; c3 = 0.858;
            case 'Tritanopia filter':
                trace('Tritanopia filter');
                a1 = 0.95; b1 = 0.05; c1 = 0;
                a2 = 0; b2 = 0.433; c2 = 0.567;
                a3 = 0; b3 = 0.475; c3 = 0.525;
            case 'Tritanomaly filter':
                trace('Tritanomaly filter');
                a1 = 0.967; b1 = 0.033; c1 = 0;
                a2 = 0; b2 = 0.733; c2 = 0.267;
                a3 = 0; b3 = 0.183; c3 = 0.817;
            case 'Achromatopsia filter':
                trace('Achromatopsia filter');
                a1 = 0.299; b1 = 0.587; c1 = 0.114;
                a2 = 0.299; b2 = 0.587; c2 = 0.114;
                a3 = 0.299; b3 = 0.587; c3 = 0.114;
            case 'Achromatomaly filter':
                trace('Achromatomaly filter');
                a1 = 0.618; b1 = 0.320; c1 = 0.062;
                a2 = 0.163; b2 = 0.775; c2 = 0.062;
                a3 = 0.163; b3 = 0.320; c3 = 0.516;
        }

        if (input != null)
        {
            input.push(new ColorMatrixFilter(matrix));
        }
        else
        {
            filters.push(new ColorMatrixFilter(matrix));
            FlxG.game.filtersEnabled = true;
            FlxG.game.setFilters(filters);
        }
    }
}
