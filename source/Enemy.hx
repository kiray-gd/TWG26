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

	// for serpent only
	private var jumpPower:Int = -200;
	private var canJump:Bool = true;
	private var jumpTimerCooldown:FlxTimer;

    public function new(X:Float, Y:Float)
    {
		super(X, Y);
		loadGraphic("assets/images/enemys.png", true, 16, 16);

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
		// decrase velocity
		// acceleration.x = 0;
		// acceleration.y = 0;
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
					// decrase velocity
					acceleration.x = 0;
					acceleration.y = 0;
				}
			case 1:
				// eye logic
				if (FlxMath.distanceBetween(this, playerSource) < visibilityArea)
				{
					isMoving = true;
					animation.play("moving");
					if (this.x < playerSource.x)
					{
						this.facing = LEFT;

						acceleration.x += 10;
					}
					else
					{
						this.facing = RIGHT;

						acceleration.x -= 10;
					}

					if (this.y < playerSource.y)
					{
						acceleration.y += 1;
					}
					else
					{
						acceleration.y -= 1;
					}
				}
				else
				{
					animation.play("idle");
					isMoving = false;
					// decrase velocity
					acceleration.x = 0;
					acceleration.y = 0;
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
								acceleration.x = 0;
							}
							acceleration.x += 100;
							this.facing = LEFT;
						}
						else
						{
							if (velocity.x > 0)
							{
								velocity.x = velocity.x * 0.5;
								acceleration.x = 0;
							}
							acceleration.x -= 100;
							this.facing = RIGHT;
						}
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
			case 3:
				// spider logic
				if (FlxMath.distanceBetween(this, playerSource) < visibilityArea)
				{
					isMoving = true;
					animation.play("moving");

					if (this.x < playerSource.x)
					{
						this.facing = LEFT;
					}
					else
					{
						this.facing = RIGHT;
					}
				}
				else
				{
					animation.play("idle");
					isMoving = false;
				}
			case 4:
				// ghost logic
				if (FlxMath.distanceBetween(this, playerSource) < visibilityArea)
				{
					isMoving = true;
					animation.play("moving");
					if (this.x < playerSource.x)
					{
						this.facing = LEFT;

						acceleration.x += 2;
					}
					else
					{
						this.facing = RIGHT;
						acceleration.x -= 2;
					}

					if (this.y < playerSource.y)
					{
						acceleration.y += 2;
					}
					else
					{
						acceleration.y -= 2;
					}
					// взаимодействует если рядом с игроком с игроком и стенами
					if (FlxMath.distanceBetween(this, playerSource) < 32)
					{
						this.allowCollisions = ANY;
					}
				}
				else
				{
					animation.play("idle");
					isMoving = false;
					// decrase velocity
					acceleration.x = 0;
					acceleration.y = 0;
					// не взаимодействует с объектами
					this.allowCollisions = NONE;
				}
			case 5:
				// serpent logic
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
				maxVelocity.set(10, 600);
				animation.add("idle", [0], 1, false);
				animation.add("moving", [0, 1, 0, 2], 5, true);
			case 1:
				// eye
				acceleration.set(0, 0);
				healthPoint = 1;
				price = 200;
				visibilityArea = 250;
				maxVelocity.set(15, 15);
				// change hitbox
				this.setSize(8, 8);
				this.offset.set(4, 6);
				animation.add("idle", [4, 5, 6, 7, 6, 5], 10, true, true);
				animation.add("moving", [4, 5, 6, 7, 6, 5], 30, true, true);
			case 2:
				// runer
				acceleration.set(0, 600);
				healthPoint = 4;
				price = 500;
				visibilityArea = 300;
				maxVelocity.set(120, 600);
				canHide = false;
				animation.add("idle", [8, 9, 10, 11, 10, 9], 30, true, true);
				animation.add("moving", [8, 9, 10, 11, 10, 9], 30, true, true);
			case 3:
				// spider
				acceleration.set(0, 0);
				healthPoint = 2;
				price = 100;
				visibilityArea = 300;
				maxVelocity.set(100, 100);
				animation.add("idle", [12, 13, 14, 13], 1, true, true);
				animation.add("moving", [12, 13, 14, 13], 1, true, true);
			case 4:
				// ghost
				acceleration.set(0, 0);
				healthPoint = 1;
				price = 20;
				visibilityArea = 200;
				maxVelocity.set(5, 5);
				// не взаимодействует с объектами
				this.allowCollisions = NONE;
				animation.add("idle", [16, 17, 18, 19], 10, true, true);
				animation.add("moving", [16, 17, 18, 19], 10, true, true);
			case 5:
				// serpent
				acceleration.set(0, 600);
				healthPoint = 5;
				price = 600;
				visibilityArea = 300;
				maxVelocity.set(36, 600);
				animation.add("idle", [20, 21, 22, 21], 4, true, true);
				animation.add("moving", [20, 21, 22, 21], 4, true, true);

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
