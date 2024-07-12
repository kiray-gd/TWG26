package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using flixel.util.FlxSpriteUtil;

class Player extends FlxSprite
{
	// player params
    public var canJump:Bool = true;

    private var jumpTimer:FlxTimer;
	private var jumpPower:Int = -250;
	private var isJumping:Bool = false;
	public var isAlive:Bool = true;
	private var canMove:Bool = true;

    public var isWantFall = false;
	public var canGetDamage = true;

	public var healthPoint:Int = 3;

	private var damageTimer:FlxTimer;
	private var flickerTime:Float = 2;
	// KOYOTE TIME
	private var koyotTime:Int = 20;
	private var currentKoyotTime:Int = 0;
	// for attack
	private var canAttack:Bool = true;
	private var isAttack:Bool = false;
	private var attackCoolDownTimer:FlxTimer;
	private var coolDownTime:Float = 0.4;

	// some for work
	public var isWorking:Bool = false;

	private var workTimer:Int = 180;
	private var currentWprkTime:Int = 0;
	// additional sprites
	public var meleeAttack:MeleeAttack;
	public var txtGUI:FlxText;
	public var typeActiveObject:Int = 1; // 1 - bonfire
	public var specActiveObject:Int = 0; // keys doors etc
	// gui sprites
	private var healthGroup:FlxGroup;
	private var gemsGroup:FlxGroup;

    public function new(X:Float, Y:Float)
    {
		super(X, Y);
        loadGraphic("assets/images/duck.png", true, 16, 16);
        animation.add("idle", [0], 1, false);
        animation.add("run", [0, 1, 2, 3], 10, true);
		animation.add("jump", [10], 1, false);
		animation.add("attack", [20, 21, 22, 21, 20], 20, false);

		this.setFacingFlip(RIGHT, false, false);
        this.setFacingFlip(LEFT, true, false);

		maxVelocity.set(120, 600);
		// gravity
		acceleration.set(0, 600);
		drag.set(400, 0);
		this.setSize(8, 12);
		this.offset.set(4, 4);

        jumpTimer = new FlxTimer();
		damageTimer = new FlxTimer();
		attackCoolDownTimer = new FlxTimer();

		// additional sprite initiation
		meleeAttack = new MeleeAttack(this.x, this.y);
		FlxG.state.add(meleeAttack);
		txtGUI = new FlxText(0, 0, 64, "keep warm");
		txtGUI.visible = false;
		FlxG.state.add(txtGUI);
		healthPoint = Reg.maxHealth;
		// trace("Max health: ", healthPoint);
		// gui sprites
		healthGroup = new FlxGroup();
		FlxG.state.add(healthGroup);
		gemsGroup = new FlxGroup();
		FlxG.state.add(gemsGroup);
		updateGui();
    }

    override public function update(elapsed:Float):Void
	{
		if (canMove)
		{
			controller();
		}

		if (isWorking)
		{
			workInProgress();
		}

		// is Alive?
		if (healthPoint <= 0)
		{
			isAlive = false;
		}
		// change text GUI position
		txtGUI.x = this.x - 16;
		txtGUI.y = this.y - 16;

		super.update(elapsed);
	}

	private function controller():Void
	{
		// Обновление флагов прыжка
		if (isTouching(FLOOR))
		{
			canJump = true;
			currentKoyotTime = 0;
		}
		else
		{
			currentKoyotTime++;
			if (currentKoyotTime == koyotTime)
			{
				currentKoyotTime = 0;
				canJump = false;
			}
		}
		// Управление движением
		if (FlxG.keys.pressed.LEFT)
		{
			acceleration.x = -drag.x;
			this.facing = LEFT;
		}
		else if (FlxG.keys.pressed.RIGHT)
		{
			acceleration.x = drag.x;
			this.facing = RIGHT;
		}
		else
		{
			acceleration.x = 0;
		}

		// Прыжок
		if (FlxG.keys.pressed.DOWN)
		{
			// if (FlxG.keys.pressed.SPACE && FlxG.keys.pressed.DOWN)
			if (FlxG.keys.pressed.SPACE)
			{
				isWantFall = true;

			}
			else
			{
				isWantFall = false;
			}
		}
		else if (FlxG.keys.justPressed.SPACE && canJump)
		{
			isJumping = true;
			canJump = false;
			velocity.y = jumpPower;
		}
		else
		{
			isJumping = false;
		}

		// атака
		// проверяем есть ли меч в Reg
		if (!Reg.weaponsAndGems[0])
		{
			// nothing
		}
		else if (FlxG.keys.pressed.V && canAttack)
		{
			canAttack = false;
			isAttack = true;
			animation.play("attack");
			meleeAttack.startAttack();
			// meleeAttack.setPosition(this.x + 16, this.y - 8);
			if (this.facing == RIGHT)
			{
				meleeAttack.visible = true;
				meleeAttack.setPosition(this.x + 24, this.y - 8);
				meleeAttack.facing = RIGHT;
			}
			else
			{
				meleeAttack.visible = true;
				meleeAttack.setPosition(this.x - 40, this.y - 8);
				meleeAttack.facing = LEFT;
			}
			attackCoolDownTimer.start(coolDownTime, function(timer:FlxTimer)
			{
				canAttack = true;
				isAttack = false;
				meleeAttack.visible = false;
				// создаем спрайт атаки
				// tempMelee:
			});
		}

		// обновление анимации в зависимости от линейной скорости если нет анимации атаки
		if (!isAttack)
		{
			if (Math.abs(velocity.y) > 40)
			{
				animation.play("jump");
			}
			else if (Math.abs(velocity.x) > 10)
			{
				animation.play("run");
			}
			else
			{
				animation.play("idle");
			}
		}

		if (meleeAttack.animation.finished)
		{
			meleeAttack.visible = false;
		}

		// активация объектов
		if (FlxG.keys.pressed.E || FlxG.keys.pressed.ENTER)
		{
			// activate object of you nearby
			if (typeActiveObject != 0)
			{
				switch typeActiveObject
				{
					case 0:
					// nothing
					case 1:
						// bondire
						activateBonfire();
					case 3:
						// key
						Reg.keysArray.push(specActiveObject);
					case 4:
						// exit, escape, run away
						if (!Reg.bossAlive[Reg.currentMap - 1])
						{
							// txtGUI.text = "run away";
							Reg.keysArray = [];
							FlxG.switchState(new PlayState());
						}
					case 5:
						// GEM
						Reg.gems[specActiveObject - 1] = true;
						Reg.maxHealth += 1;
						Reg.bloodMax += 2500;
						// healthPoint++;
						updateGui();
						trace(Reg.gems);

				}
			}
		}
		// тестовые кнопки
		// суицид
		if (FlxG.keys.pressed.S)
		{
			healthPoint -= healthPoint;
		}
	}

	private function activateBonfire():Void
	{
		canMove = false;
		isWorking = true;
		animation.play("idle");
		velocity.set(0, 0);
		acceleration.set(0, 0);
	}

	private function workInProgress():Void
	{
		// отсчет
		currentWprkTime++;
		// изменения камеры
		FlxG.camera.zoom += 0.01;
		// условие на выключение действия\анимации
		if (currentWprkTime >= workTimer)
		{
			Reg.playerLastPosition.set(this.x, this.y);
			trace("Bonfire keeping player position at:", Reg.playerLastPosition);
			currentWprkTime = 0;
			isWorking = false;
			canMove = true;
			FlxG.camera.zoom = 1;
			FlxG.camera.flash(FlxColor.BLACK, 3);
			FlxG.switchState(new PlayState());
		}
	}

	public function onTrapCollision():Void
	{
		if (canGetDamage)
		{
			healthPoint -= 1;
			canGetDamage = false;
			this.flicker(flickerTime);
			damageTimer.start(flickerTime, function(timer:FlxTimer)
			{
				canGetDamage = true;
			});
		}
	}
	public function onEnemyHit():Void
	{
		if (canGetDamage)
		{
			healthPoint -= 1;
			updateGui();
			canGetDamage = false;
			this.flicker(flickerTime);
			// this.allowCollisions = FLOOR;
			damageTimer.start(flickerTime, function(timer:FlxTimer)
			{
				canGetDamage = true;
				// this.allowCollisions = ANY;
			});
			this.velocity.x = this.velocity.x * -1;
			this.velocity.y = this.velocity.y * -1;
		}
	}
	public function activateObject(_type:Int = 1, spec:Int = 0)
	{
		typeActiveObject = _type;
		specActiveObject = spec;
		txtGUI.visible = true;
		switch _type
		{
			case 0:
				// not any object
				txtGUI.visible = false;
			case 1:
				// bonfire
				txtGUI.text = "keep warm";
			case 2:
				// door
				txtGUI.text = "door closed";
			case 3:
				// key
				txtGUI.text = "take key";
			case 4:
				// exit
				if (!Reg.bossAlive[Reg.currentMap - 1])
				{
					txtGUI.text = "run away";
				}
				else
				{
					txtGUI.text = "I can't leave";
				}
			case 5:
				// gey
				txtGUI.text = "take GEM";
				// Reg.gems[spec - 1] = true;
				// trace(Reg.gems);
				
		}
	}
	public function updateGui():Void
	{
		for (elem in healthGroup)
		{
			elem.kill();
			healthGroup.remove(elem);
			// trace("Asdasdas");
		}
		for (elem in gemsGroup)
		{
			elem.kill();
			gemsGroup.remove(elem);
			// trace("Asdasdas");
		}
		// hearts
		for (i in 0...healthPoint)
		{
			var heart:FlxSprite = new FlxSprite();
			heart.loadGraphic("assets/images/guitiles.png", true, 16, 16, false);
			heart.animation.add("idle", [0], 10, false);
			heart.animation.play("idle");
			heart.x = 8 + (16 * i);
			heart.y = 214;
			heart.scrollFactor.set(0, 0);
			healthGroup.add(heart);
		}
		// weapon
		var weapon:FlxSprite = new FlxSprite();
		weapon.loadGraphic("assets/images/guitiles.png", true, 16, 16, false);
		if (Reg.weaponsAndGems[0])
		{
			weapon.animation.add("idle", [7], 10, false);
		}
		else
		{
			weapon.animation.add("idle", [8], 10, false);
		}
		weapon.animation.play("idle");
		weapon.x = 9;
		weapon.y = 196;
		weapon.scrollFactor.set(0, 0);
		gemsGroup.add(weapon);
		// gems
		for (gemIndex in 0...Reg.gems.length)
		{
			var gemSprite:FlxSprite = new FlxSprite();
			gemSprite.loadGraphic("assets/images/guitiles.png", true, 16, 16, false);
			if (Reg.gems[gemIndex])
			{
				// 	gemSprite.animation.add("idle", [Reg.gems.indexOf(gemElement)+1])
				// 	Reg.gems.indexOf(gemElement)
				switch gemIndex
				{
					case 0:
						gemSprite.animation.add("idle", [1], 10, false);
					case 1:
						gemSprite.animation.add("idle", [2], 10, false);
					case 2:
						gemSprite.animation.add("idle", [3], 10, false);
					case 3:
						gemSprite.animation.add("idle", [4], 10, false);
					case 4:
						gemSprite.animation.add("idle", [5], 10, false);
				}
			}
			else
			{
				gemSprite.animation.add("idle", [6], 10, false);
			}
			gemSprite.animation.play("idle");
			gemSprite.x = 25 + (16 * gemIndex);
			gemSprite.y = 196;
			gemSprite.scrollFactor.set(0, 0);
			gemsGroup.add(gemSprite);
		}
	}
}
