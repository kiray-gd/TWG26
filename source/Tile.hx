package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

class Tile extends FlxSprite
{
    public var type:Int = 0;

    public function new(X:Float, Y:Float)
    {
        super(X, Y);
        // loadGraphic("assets/images/player.png", true, 16, 16);
        loadGraphic("assets/images/testTile.png", true, 16, 16);
        animation.add("white", [0], 1, false);
        animation.add("default", [1], 1, false);
        animation.add("platform", [2], 1, false);
        animation.add("enemy", [3], 1, false);
        // this.addAnimation("run", [0, 1, 2, 3], 10, true);
        // addAnimation("idle", [0], 0, false);
        animation.play("default");
        
    }

    override public function update(elapsed:Float):Void
    {
        
        super.update(elapsed);
    }

    public function setType(_type:Int = 0):Void{
        type = _type;
        switch type{
            case 0:
                animation.play("white");
            case 1:
                animation.play("default");
            case 2:
                animation.play("platform");
            case 3:
                animation.play("enemy");
        }
            

    }

    public function getType():Int {
        return type;
    }
}
