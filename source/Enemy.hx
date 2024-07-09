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
	// 0 - skull
	public var price:Int = 10;
	public var canHide:Bool = true;

	public var canGetDamage:Bool = true;

	public var healthPoint:Int = 1;

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
		switch type
		{
			case 0:
				// skull logic
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
							}
							if (Math.abs(velocity.x) < 50)
							{
								acceleration.x += 24;
							}
	
							this.facing = RIGHT;
						}
						else
						{
							if (velocity.x > 0)
							{
								velocity.x = 0;
							}
							if (Math.abs(velocity.x) < 50)
							{
								acceleration.x -= 24;
							}
	
							this.facing = LEFT;
						}
					}
				}
				else
				{
					animation.play("idle");
					isMoving = false;
				}
			case 1:
				// eye logic
				if (FlxMath.distanceBetween(this, playerSource) < visibilityArea)
				{
					isMoving = true;
					animation.play("moving");
				}
				else
				{
					animation.play("idle");
					isMoving = false;
				}
			case 2:
				// runer logic
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
								velocity.x = velocity.x * 0.5;
							}
							if (Math.abs(velocity.x) < 150)
							{
								acceleration.x += 100;
							}

							this.facing = RIGHT;
						}
						else
						{
							if (velocity.x > 0)
							{
								velocity.x = velocity.x * 0.5;
							}
							if (Math.abs(velocity.x) < 150)
							{
								acceleration.x -= 100;
							}

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
		
	}

	public function setType(_type:Int = 0):Void
	{
		type = _type;
		switch type
		{
			case 0:
				// skull
				acceleration.set(0, 600);
				healthPoint = 3;
				price = 300;
				visibilityArea = 100;
				animation.add("idle", [0], 1, false);
				animation.add("moving", [0, 1, 0, 2], 5, true);
			case 1:
				// eye
				acceleration.set(0, 0);
				healthPoint = 1;
				price = 100;
				visibilityArea = 100;
				animation.add("idle", [4, 5, 6, 7, 6, 5], 10, true, true);
				animation.add("moving", [4, 5, 6, 7, 6, 5], 20, true, true);
			case 2:
				// runer
				acceleration.set(0, 600);
				healthPoint = 4;
				price = 500;
				visibilityArea = 300;
				canHide = false;
				animation.add("idle", [8, 9, 10, 11, 10, 9], 30, true, true);
				animation.add("moving", [8, 9, 10, 11, 10, 9], 30, true, true);
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
