package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxTimer;

class ObjectItem extends FlxSprite {
	public var type:Int = 0;

	// for keys and doors
	public var special:Int = 0;

	private var damageTimer:FlxTimer;
	private var flickerTime:Float = 1;

	public var canGetDamage:Bool = false;

    public function new(x:Float, y:Float) {
        super(x, y);
        // this.makeGraphic(16, 16, FlxColor.GREEN);
        loadGraphic("assets/images/tilesetmain.png", true, 16, 16);
        animation.add("idle", [11], 1, false);
		animation.add("bonfire", [12], 1, false);
		animation.add("door", [9], 1, false);
		animation.add("key", [13], 1, false);
		animation.add("exit", [10], 1, false);
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
			case 1:
				// bonfire
				animation.play("bonfire");
				canGetDamage = false;
			case 2:
				// door
				animation.play("door");
				canGetDamage = false;
			case 3:
				// key
				animation.play("key");
				canGetDamage = false;
			case 4:
				// exit
				animation.play("exit");
				canGetDamage = false;
		}
	}

	public function setSpecial(_spec:Int = 0)
	{
		special = _spec;
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
