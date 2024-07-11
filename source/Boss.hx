package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
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

	public var healthPoint:Int = 10;

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

	// for boss only
	private var logicTimer1:Int = 300;
	private var currentTimer1:Int = 0;
	private var logicTimer2:Int = 400;
	private var currentTimer2:Int = 0;
	private var attackDelay:Int = 60;

	// bullets groupSource
	private var bulletGroupSource:FlxGroup;
	private var enemyGroupSource:FlxGroup;

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
			Reg.bossAlive[type - 1] = false;
			trace(Reg.bossAlive);
		}
	}
	private function thinkingFunction()
	{
		switch type
		{
			case 1:
				// blind knight logic
				if (FlxMath.distanceBetween(this, playerSource) < visibilityArea && this.y + 64 > playerSource.y)
				{
					// игрок виден
					currentTimer1++;
					currentTimer2++;

					if (currentTimer1 > logicTimer1 && currentTimer1 < logicTimer1 + attackDelay)
					{
						// wait
						animation.play("waiting");
						velocity.x = 0;
						acceleration.x = 0;
						if (this.x < playerSource.x)
						{
							this.facing = LEFT;
						}
						else
						{
							this.facing = RIGHT;
						}
					}
					else if (currentTimer1 >= logicTimer1 + attackDelay)
					{
						// some action
						currentTimer1 = 0;
						animation.play("attacking");
						creatBullet("UP", this.x, this.y);
						if (this.facing == RIGHT)
						{
							creatBullet("LEFT", this.x, this.y);
							creatBullet("LEFT", this.x, this.y - 16);
						}
						else
						{
							creatBullet("RIGHT", this.x, this.y);
							creatBullet("RIGHT", this.x, this.y - 16);
						}
					}
					else if (currentTimer2 > logicTimer2 && currentTimer2 < logicTimer2 + attackDelay)
					{
						// some action 2 wating
						// wait
						// trace("waiting 2", currentTimer2);
						animation.play("waiting");
						velocity.x = 0;
						acceleration.x = 0;
						if (this.x < playerSource.x)
						{
							this.facing = LEFT;
						}
						else
						{
							this.facing = RIGHT;
						}
					}
					else if (currentTimer2 >= logicTimer2 + attackDelay)
					{
						// action 2
						// trace("action 2");
						currentTimer1 = 0;
						currentTimer2 = 0;
						// animation.play("attacking");
						creatSummons(this.x, this.y - 32, 1);
						creatSummons(this.x, this.y - 16, 0);
					}
					else
					{
						// перемещение если не задействованы таймеры движения
						isMoving = true;
						if (animation.finished)
						{
							animation.play("moving");
						}
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
						if (FlxMath.distanceBetween(this, playerSource) < 64 && canJump)
						{
							canJump = false;
							velocity.y += jumpPower;
							jumpTimerCooldown.start(6, function(timer:FlxTimer)
							{
								canJump = true;
							});
						}
					}
				}
					else
					{
					// игрок вне области видимости
						animation.play("idle");
						isMoving = false;
						// decrase velocity
						acceleration.x = 0;
						// acceleration.y = 0;
					currentTimer1 = 0;
					currentTimer2 = 0;
				}
		}
	}

	// some actions test
	private function creatBullet(_direction:String = "UP", posX:Float, posY:Float)
	{
		var tmpBullet:FlxSprite = new FlxSprite(posX, posY);
		tmpBullet.loadGraphic("assets/images/enemyBullet.png", true, 16, 16, false);
		tmpBullet.animation.add("default", [0, 1, 2]);
		tmpBullet.animation.play("default");
		switch _direction
		{
			case "UP":
				tmpBullet.velocity.y = -200;
				tmpBullet.angle -= 90;
			case "RIGHT":
				tmpBullet.velocity.x = 200;
			case "DOWN":
				tmpBullet.velocity.y = 200;
				tmpBullet.angle += 90;
			case "LEFT":
				tmpBullet.velocity.x = -200;
				tmpBullet.angle += 180;
		}
		bulletGroupSource.add(tmpBullet);
	}

	private function creatSummons(posX:Float, posY:Float, _type:Int = 0)
	{
		var tempEnemy:Enemy = new Enemy(posX, posY);
		// tempEnemy.x = jPos * 16;
		// tempEnemy.y = iPos * 16;
		tempEnemy.immovable = false;
		tempEnemy.setType(_type);
		tempEnemy.setPlayerSource(playerSource);
		enemyGroupSource.add(tempEnemy);
	}

	public function setType(_type:Int = 1):Void
	{
		type = _type;
		switch type
		{
			case 1:
				// blind knight
				acceleration.set(0, 600);
				healthPoint = 10;
				price = 10000;
				visibilityArea = 300;
				maxVelocity.set(96, 600);
				jumpPower = -250;
				logicTimer1 = 360;
				logicTimer2 = 1500;
				// change hitbox
				this.setSize(22, 20);
				this.offset.set(1, 2);
				animation.add("idle", [0], 60, false, true);
				animation.add("moving", [1, 2, 3], 10, true, true);
				animation.add("waiting",[4], 1, false, true);
				animation.add("attacking", [5, 6, 7, 7, 7, 7], 10, false, true);
		}

		animation.play("idle");
	}

	public function setBulletGroupAndEnemyGroup(_bulletGroupSource:FlxGroup, _enemyGroupSource:FlxGroup):Void
	{
		bulletGroupSource = _bulletGroupSource;
		enemyGroupSource = _enemyGroupSource;
	}

	public function onAttack(playerPosX:Float = 0, playerPosY:Float = 0, damage:Int = 1):Void
	{
		if (canGetDamage)
		{
			trace("Boss took ", damage, " damage");
			trace("Boss health: ", healthPoint);
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
			// special tips for boss
			switch type
			{
				case 1:
					currentTimer1 += 50;
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
