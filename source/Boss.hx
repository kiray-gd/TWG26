package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using flixel.util.FlxSpriteUtil;

class Boss extends FlxSprite
{
    public var type:Int = 1;
	// 0 - skull
	public var price:Int = 1000;
	public var canHide:Bool = true;

	public var canGetDamage:Bool = true;

	public var healthPoint:Int = 20;

	private var damageTimer:FlxTimer;
	private var flickerTime:Float = 1;

	public var isAlive:Bool = true;
	private var isMoving:Bool = false;

	private var playerSource:Player;
	private var visibilityArea:Int = 100;

	// for serpent only
	private var jumpPower:Int = -200;
	private var canJump:Bool = true;
	private var jumpTimerCooldown:FlxTimer;

    public function new(X:Float, Y:Float)
    {
		super(X, Y);
		loadGraphic("assets/images/boss.png", true, 24, 24);

		// test
		drag.set(400, 0);

		this.setFacingFlip(RIGHT, false, false);
		this.setFacingFlip(LEFT, true, false);
		damageTimer = new FlxTimer();
		jumpTimerCooldown = new FlxTimer();
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
		switch type
		{
			case 1:
				// blind knight logic
				if (FlxMath.distanceBetween(this, playerSource) < visibilityArea)
					{
						isMoving = true;
						animation.play("moving");
						if (Math.abs(this.y - playerSource.y) < 20)
						{
							if (this.x < playerSource.x)
							{
								if (velocity.x < 0)
								{
									velocity.x = 0;
									acceleration.x = 0;
								}
								acceleration.x += 24;
								this.facing = LEFT;
							}
							else
							{
								if (velocity.x > 0)
								{
									velocity.x = 0;
									acceleration.x = 0;
								}
	
								acceleration.x -= 24;
								this.facing = RIGHT;
							}
						}
						// прыжок если близко к игроку
						if (FlxMath.distanceBetween(this, playerSource) < 32 && canJump)
						{
							canJump = false;
							velocity.y += jumpPower;
							jumpTimerCooldown.start(6, function(timer:FlxTimer)
							{
								canJump = true;
							});
						}
					}
					else
					{
						animation.play("idle");
						isMoving = false;
						// decrase velocity
						acceleration.x = 0;
						// acceleration.y = 0;
					}
		}
		
	}

	public function setType(_type:Int = 1):Void
	{
		type = _type;
		switch type
		{
			case 1:
				// blind knight
				acceleration.set(0, 600);
				healthPoint = 30;
				price = 10000;
				visibilityArea = 300;
				maxVelocity.set(36, 600);
				// change hitbox
				this.setSize(22, 20);
				this.offset.set(1, 2);
				animation.add("idle", [0], 1, false, true);
				animation.add("moving", [1, 2, 3], 20, true, true);
				animation.add("waiting",[4], 1, false, true);
				animation.add("attacking",[5,6,7,7,7,7], 10, false, true);
		}

		animation.play("idle");
	}

	public function onAttack(playerPosX:Float = 0, playerPosY:Float = 0, damage:Int = 1):Void
	{
		if (canGetDamage)
		{
			healthPoint -= damage;
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

	public function onTrapCollision():Void
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
		}
	}

	public function setPlayerSource(_playerSource:Player):Void
	{
		playerSource = _playerSource;
	}
}
