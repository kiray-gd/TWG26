package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using flixel.util.FlxSpriteUtil;

class Enemy extends FlxSprite
{
    public var type:Int = 0;

	public var canGetDamage:Bool = true;

	public var healthPoint:Int = 3;

	private var damageTimer:FlxTimer;
	private var flickerTime:Float = 1;

	public var isAlive:Bool = true;
	private var isMoving:Bool = false;

	private var playerSource:Player;
	private var visibilityArea:Int = 100;

    public function new(X:Float, Y:Float)
    {
		super(X, Y);
		loadGraphic("assets/images/enemys.png", true, 16, 16);
		animation.add("idle", [0], 1, false);
		animation.add("moving", [0, 1, 0, 2], 5, true);
        animation.play("idle");
		acceleration.set(0, 600);
		this.setFacingFlip(RIGHT, false, false);
		this.setFacingFlip(LEFT, true, false);
		damageTimer = new FlxTimer();
    }

    override public function update(elapsed:Float):Void
    {
		checkAlive();
		// logic
		thinkingFunction();

        super.update(elapsed);

    }

	private function checkAlive():Void
	{
		if (healthPoint <= 0)
		{
			isAlive = false;
		}
	}
	private function thinkingFunction()
	{
		// decrase velocity
		acceleration.x = 0;
		if (FlxMath.distanceBetween(this, playerSource) < visibilityArea)
		{
			isMoving = true;
			animation.play("moving");
			if (Math.abs(this.y - playerSource.y) < 20)
			{
				if (this.x < playerSource.x)
				{
					acceleration.x += 10;
					this.facing = RIGHT;
				}
				else
				{
					acceleration.x -= 10;
					this.facing = LEFT;
				}
			}
		}
		else
		{
			animation.play("idle");
			isMoving = false;
		}
	}

	public function setType(_type:Int = 0):Void
	{
		type = _type;
	}

	public function onAttack(playerPosX:Float = 0, playerPosY:Float = 0):Void
	{
		if (canGetDamage)
		{
			healthPoint -= 1;
			canGetDamage = false;
			this.alpha = 0.5;
			this.color = FlxColor.RED;
			damageTimer.start(flickerTime, function(timer:FlxTimer)
			{
				canGetDamage = true;
				this.alpha = 1;
				this.color = FlxColor.WHITE;
			});
			// чарджим в зависимости от положения игрока
			if (playerPosX > this.x)
			{
				velocity.x -= 100;
				velocity.y -= 250;
			}
			else
			{
				velocity.x += 100;
				velocity.y -= 250;
			}
		}
	}

	public function setPlayerSource(_playerSource:Player):Void
	{
		playerSource = _playerSource;
	}
}
