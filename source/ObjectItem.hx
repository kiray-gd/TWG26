package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxTimer;

class ObjectItem extends FlxSprite {
	public var type:Int = 0;

	private var damageTimer:FlxTimer;
	private var flickerTime:Float = 1;

	public var canGetDamage:Bool = false;

    public function new(x:Float, y:Float) {
        super(x, y);
        // this.makeGraphic(16, 16, FlxColor.GREEN);
        loadGraphic("assets/images/tilesetmain.png", true, 16, 16);
        animation.add("idle", [11], 1, false);
        animation.play("idle");
        // immovable = false;
        // gravity
		// acceleration.set(0, 600);
        
        // allowCollisions = FlxDirectionFlags.ANY;
		damageTimer = new FlxTimer();
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        // Дополнительная логика для ящика (если потребуется)
    }
	public function setType(_type:Int = 0):Void
	{
		type = _type;
		switch type
		{
			case 0:
				// cracked wall
				animation.play("idle");
				canGetDamage = true;
		}
	}

	public function onAttack():Void
	{
		if (canGetDamage && type == 0)
		{
			trace("get HIT");
			this.alpha -= 0.25;
			canGetDamage = false;
			this.color = FlxColor.RED;
			damageTimer.start(flickerTime, function(timer:FlxTimer)
			{
				canGetDamage = true;
				this.color = FlxColor.WHITE;
			});
		}
	}
}
