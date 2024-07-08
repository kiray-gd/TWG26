package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

using flixel.util.FlxSpriteUtil;

class Enemy extends FlxSprite
{
    public var type:Int = 0;

	public var canGetDamage = true;

	public var healthPoint:Int = 3;

	private var damageTimer:FlxTimer;
	private var flickerTime:Float = 2;

	public var isAlive:Bool = true;

    public function new(X:Float, Y:Float)
    {
        super(X, Y);
        // loadGraphic("assets/images/player.png", true, 16, 16);
        loadGraphic("assets/images/enemy.png", true, 16, 16);
        animation.add("idle", [0], 1, false);
        // this.addAnimation("run", [0, 1, 2, 3], 10, true);
        // addAnimation("idle", [0], 0, false);
        animation.play("idle");
		damageTimer = new FlxTimer();
    }

    override public function update(elapsed:Float):Void
    {
		checkAlive();
        super.update(elapsed);
    }

	private function checkAlive():Void
	{
		if (healthPoint <= 0)
		{
			isAlive = false;
		}
	}
    public function setType(_type:Int = 0):Void{
        type = _type;
            
	}

	public function onAttack():Void
	{
		if (canGetDamage)
		{
			healthPoint -= 1;
			canGetDamage = false;
			// velocity.x += 200;
			this.flicker(flickerTime);
			damageTimer.start(flickerTime, function(timer:FlxTimer)
			{
				canGetDamage = true;
			});
		}
	}
}
