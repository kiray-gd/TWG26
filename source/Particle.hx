package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

class Particle extends FlxSprite
{
    public var type:Int = 0;
	public var isSpot:Bool = false;

	private var speedSpotWhenTouched:Float = 0.2;
	private var speedSpotWhenFall:Float = 4;

    public function new(X:Float, Y:Float)
    {
        super(X, Y);
        // loadGraphic("assets/images/player.png", true, 16, 16);
        loadGraphic("assets/images/blood.png", true, 4, 4);
        animation.add("default", [FlxG.random.int(0, 3)], 1, false);
        animation.play("default");
        setSize(1,1);
        offset.set((width-1)/2,(height-1)/2);
    }

    override public function update(elapsed:Float):Void
	{
        super.update(elapsed);
	}
}
