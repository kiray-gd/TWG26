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
		animation.add("door1", [9], 1, false);
		animation.add("door2", [24], 1, false);
		animation.add("door3", [25], 1, false);
		animation.add("key1", [13], 1, false);
		animation.add("key2", [22], 1, false);
		animation.add("key3", [23], 1, false);
		animation.add("exit", [10], 1, false);
		animation.add("gem1", [32], 1, false);
		animation.add("gem2", [33], 1, false);
		animation.add("gem3", [34], 1, false);
		animation.add("gem4", [35], 1, false);
		animation.add("gem5", [36], 1, false);

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
	public function setTypeAndSpec(_type:Int = 0, _spec:Int = 1):Void
	{
		type = _type;
		special = _spec;

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
				switch special
				{
					case 1:
						animation.play("door1");
					case 2:
						animation.play("door2");
					case 3:
						animation.play("door3");
				}
				canGetDamage = false;
			case 3:
				// key
				switch special
				{
					case 1:
						animation.play("key1");
					case 2:
						animation.play("key2");
					case 3:
						animation.play("key3");
				}
				canGetDamage = false;
			case 4:
				// exit
				animation.play("exit");
				canGetDamage = false;
			case 5:
				// gem
				switch special
				{
					case 1:
						animation.play("gem1");
					// canGetDamage = false;
					case 2:
						animation.play("gem2");
					// canGetDamage = false;
					case 3:
						animation.play("gem3");
					// canGetDamage = false;
					case 4:
						animation.play("gem4");
					// canGetDamage = false;
					case 5:
						animation.play("gem5");
						// canGetDamage = false;
				}
				canGetDamage = false;

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
