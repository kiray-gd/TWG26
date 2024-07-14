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
	private var attackDelay:Int = 100;
	public var isPlayerObscure:Bool = false;

	// bullets groupSource
	private var bulletGroupSource:FlxGroup;
	private var enemyGroupSource:FlxGroup;

    public function new(X:Float, Y:Float)
    {
		super(X, Y);
		// loadGraphic("assets/images/boss.png", true, 24, 24);

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
			trace(Reg.bossAlive);
			switch type
			{
				case 1:
					// если первый босс открываем меч
					Reg.weaponsAndGems[0] = true;
			}
		}
	}
	private function thinkingFunction()
	{
		switch type
		{
			case 1:
				// blind knight logic
				// Math.abs(this.y - playerSource.y) < 20
				// if (FlxMath.distanceBetween(this, playerSource) < visibilityArea && this.y + 64 > playerSource.y)
				if (FlxMath.distanceBetween(this, playerSource) < visibilityArea
					&& Math.abs(this.y - playerSource.y) < 90
					&& this.y + 64 > playerSource.y)
				{
					// игрок виден
					isPlayerObscure = true;
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
						// animation.play("idle");
						if (Math.abs(this.y - playerSource.y) < 20)
						{
							// перемещение если не задействованы таймеры движения
							isMoving = true;
							if (animation.finished)
							{
								animation.play("moving");
							}
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
						else
						{
							// игрок вне области видимости по высоте
							if (animation.finished)
							{
								animation.play("idle");
								isMoving = false;
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
					isPlayerObscure = false;
					animation.play("idle");
					isMoving = false;
					// decrase velocity
					acceleration.x = 0;
					// acceleration.y = 0;
					currentTimer1 = 0;
					currentTimer2 = 0;
				}
			case 2:
				// big eye logic
				// check distance
				if (FlxMath.distanceBetween(this, playerSource) < visibilityArea)
				{
					// игрок в поле видимости
					isPlayerObscure = true;
					angle -= 1;
					currentTimer1++;
					currentTimer2++;
					// перемещение
					// сначала двигаемся по высоте, а затем по горизонтали
					if (Math.abs(this.y - playerSource.y) > 36)
					{
						if (this.y > playerSource.y)
						{
							velocity.y -= 10;
						}
						else
						{
							velocity.y += 10;
						}
					}
					else if (Math.abs(this.x - playerSource.x) > 36)
					{
						if (this.x > playerSource.x)
						{
							velocity.x -= 10;
						}
						else
						{
							velocity.x += 10;
						}
					}
					// логика атак
					// первый таймер
					if (currentTimer1 > logicTimer1 && currentTimer1 < logicTimer1 + attackDelay)
					{
						// задержка перед атакой
						angularVelocity += 12;
						scale.set(1.3, 1.3);
					}
					else if (currentTimer1 == logicTimer1 + attackDelay)
					{
						// атака после задержки

						creatBullet("UP", this.x, this.y);
						creatBullet("RIGHT", this.x, this.y);
						creatBullet("DOWN", this.x, this.y);
						creatBullet("LEFT", this.x, this.y);
					}
					else if (currentTimer1 == logicTimer1 + attackDelay + 12)
					{
						// атака после задержки

						creatBullet("UP", this.x, this.y);
						creatBullet("RIGHT", this.x, this.y);
						creatBullet("DOWN", this.x, this.y);
						creatBullet("LEFT", this.x, this.y);
						// currentTimer1 = 0;
					}
					else if (currentTimer1 == logicTimer1 + attackDelay + 24)
					{
						// атака после задержки

						creatBullet("UP", this.x, this.y);
						creatBullet("RIGHT", this.x, this.y);
						creatBullet("DOWN", this.x, this.y);
						creatBullet("LEFT", this.x, this.y);
						// currentTimer1 = 0;
					}
					else if (currentTimer1 >= logicTimer1 + attackDelay + 96)
					{
						// атака после задержки
						creatBullet("UP", this.x, this.y);
						creatBullet("RIGHT", this.x, this.y);
						creatBullet("DOWN", this.x, this.y);
						creatBullet("LEFT", this.x, this.y);
						angularVelocity = 0;
						scale.set(1.5, 1.5);
						currentTimer1 = 0;
					}
					// логика атак
					// второй таймер
					if (currentTimer2 > logicTimer2 && currentTimer2 < logicTimer2 + attackDelay)
					{
						// задержка перед атакой
						angle -= 12;
						scale.set(1.4, 1.2);
					}
					else if (currentTimer2 > logicTimer2 + attackDelay)
					{
						// спавнм мобов
						scale.set(1.5, 1.5);
						creatSummons(this.x - 32, this.y - 16, 1);
						creatSummons(this.x, this.y - 32, 1);
						creatSummons(this.x + 32, this.y - 32, 1);
						currentTimer1 = 0;
						currentTimer2 = 0;
					}
				}
				else
				{
					// игрок вне поля видимости
					isPlayerObscure = false;
					// decrase velocity
					acceleration.x = 0;
					acceleration.y = 0;
					currentTimer1 = 0;
					currentTimer2 = 0;
				}
			case 3:
				// witch logic
				// check distance
				if (FlxMath.distanceBetween(this, playerSource) < visibilityArea)
				{
					// игрок в поле видимости
					isPlayerObscure = true;
					// angle -= 1;
					currentTimer1++;
					currentTimer2++;
					// перемещение
					// поворачиваем лицо
					if (this.x > playerSource.x)
					{
						this.facing = RIGHT;
					}
					else
					{
						this.facing = LEFT;
					}
					// сначала двигаемся по высоте, а затем по горизонтали
					if (this.y + 36 > playerSource.y)
					{
						velocity.y -= 10;
					}
					else
					{
						velocity.y += 10;
					}
					// перемещение по горизонтали
					if (Math.abs(this.x - playerSource.x) > 36)
					{
						if (this.x > playerSource.x)
						{
							velocity.x -= 10;
						}
						else
						{
							velocity.x += 10;
						}
					}
					// логика атак
					// первый таймер
					if (currentTimer1 > logicTimer1 && currentTimer1 < logicTimer1 + attackDelay)
					{
						// задержка перед атакой
						// angularVelocity += 12;
						// scale.set(1.3, 1.3);
						animation.play("attack1");
					}
					else if (currentTimer1 == logicTimer1 + attackDelay)
					{
						// атака после задержки
						creatBullet("RIGHT", this.x - 300, this.y - 24);
						creatBullet("LEFT", this.x + 300, this.y + 24);
						creatBullet("RIGHT", this.x - 324, this.y - 40);
						creatBullet("LEFT", this.x + 300, this.y + 40);
						creatBullet("DOWN", this.x - 60, this.y - 100);
						creatBullet("DOWN", this.x - 40, this.y - 100);
						creatBullet("DOWN", this.x - 20, this.y - 100);
						creatBullet("DOWN", this.x, this.y - 100);
						creatBullet("DOWN", this.x + 20, this.y - 100);
						creatBullet("DOWN", this.x + 40, this.y - 100);
						creatBullet("DOWN", this.x + 60, this.y - 100);
						currentTimer1 = 0;
						animation.play("idle");
					}
					// второй таймер
					if (currentTimer2 > logicTimer2 && currentTimer2 < logicTimer2 + attackDelay)
					{
						// задержка перед атакой
						// angle -= 12;
						velocity.set(0, 0);
						scale.set(1.6, 1.2);
					}
					else if (currentTimer2 > logicTimer2 + attackDelay)
					{
						// каст сумонов
						scale.set(1.5, 1.5);
						creatSummons(this.x, this.y + 16, 5);
						currentTimer2 = 0;
						currentTimer1 = 0;
					}
				}
				else
				{
					// игрок вне поля видимости
					animation.play("idle");
					isPlayerObscure = false;
					// decrase velocity
					acceleration.x = 0;
					acceleration.y = 0;
					currentTimer1 = 0;
					currentTimer2 = 0;
				}
					
		}
	}

	// some actions
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
				// healthPoint = 2;
				healthPoint = 20;
				price = 10000;
				visibilityArea = 300;
				maxVelocity.set(96, 600);
				jumpPower = -250;
				logicTimer1 = 360;
				logicTimer2 = 1500;
				// change hitbox
				this.setSize(22, 20);
				this.offset.set(1, 2);
				loadGraphic("assets/images/boss.png", true, 24, 24);
				animation.add("idle", [0], 60, false, true);
				animation.add("moving", [1, 2, 3], 10, true, true);
				animation.add("waiting",[4], 1, false, true);
				animation.add("attacking", [5, 6, 7, 7, 7, 7], 10, false, true);
			case 2:
				// big eye
				// acceleration.set(0, 600);
				// healthPoint = 2;
				healthPoint = 40;
				price = 10000;
				visibilityArea = 380;
				maxVelocity.set(32, 32);
				jumpPower = -250;
				logicTimer1 = 450;
				logicTimer2 = 900;
				// change hitbox
				this.setSize(16, 16);
				this.immovable = true;
				// this.offset.set(3, 3);
				loadGraphic("assets/images/boss2.png", true, 24, 24);
				animation.add("idle", [0, 1, 2, 3], 4, true, true);
				scale.set(1.5, 1.5);
			case 3:
				// witch
				healthPoint = 30;
				price = 10000;
				visibilityArea = 380;
				maxVelocity.set(64, 24);
				jumpPower = -250;
				logicTimer1 = 400;
				logicTimer2 = 666;
				// change hitbox
				this.setSize(12, 12);
				this.offset.set(4, 4);
				// this.immovable = true;
				loadGraphic("assets/images/boss3.png", true, 24, 24);
				animation.add("idle", [0, 1, 2, 3, 4, 5], 10, true, true);
				animation.add("attack1", [6], 60, false, true);
				animation.add("attack2", [7], 60, false, true);
				scale.set(1.5, 1.5);
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
