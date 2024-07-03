package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

class Enemy extends FlxSprite
{
    public var type:Int = 0;

    public function new(X:Float, Y:Float)
    {
        super(X, Y);
        // loadGraphic("assets/images/player.png", true, 16, 16);
        loadGraphic("assets/images/enemy.png", true, 16, 16);
        animation.add("idle", [0], 1, false);
        // this.addAnimation("run", [0, 1, 2, 3], 10, true);
        // addAnimation("idle", [0], 0, false);
        animation.play("idle");
        
    }

    override public function update(elapsed:Float):Void
    {
        
        super.update(elapsed);
    }

    public function setType(_type:Int = 0):Void{
        type = _type;
            
    }
}
