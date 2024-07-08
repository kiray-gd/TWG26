package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxTimer;

class MeleeAttack extends FlxSprite {
    public function new(x:Float, y:Float, _width:Int = 16, _height:Int = 16) {
        super(x, y);
        immovable = true;
        loadGraphic("assets/images/meleeattacksprite.png", true, 24, 24, true);
        animation.add("idle", [0, 1, 2, 3], 30, false);
        visible = false;
        this.setFacingFlip(RIGHT, false, false);
        this.setFacingFlip(LEFT, true, false);
    }
    
    public function startAttack():Void {
        visible = true;
        animation.play("idle");
    }
}
