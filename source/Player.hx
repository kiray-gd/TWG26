package;

import flixel.FlxG;
import flixel.FlxSprite;
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

	// for attack
	private var canAttack:Bool = true;
	private var isAttack:Bool = false;
	private var attackCoolDownTimer:FlxTimer;
	private var coolDownTime:Float = 0.4;

	// additional sprites
	public var meleeAttack:MeleeAttack;
	public var txtGUI:FlxText;
	public var typeActiveObject:Int = 1; // 1 - bonfire

	private var isWorking:Bool = false;
	private var workTimer:Int = 180;
	private var currentWprkTime:Int = 0;

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
		this.setSize(8, 16);
		this.offset.set(4, 0);

        jumpTimer = new FlxTimer();
		damageTimer = new FlxTimer();
		attackCoolDownTimer = new FlxTimer();

		// additional sprite initiation
		meleeAttack = new MeleeAttack(this.x, this.y);
		FlxG.state.add(meleeAttack);
		txtGUI = new FlxText(0, 0, 64, "keep warm");
		txtGUI.visible = false;
		FlxG.state.add(txtGUI);
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
			if (FlxG.keys.pressed.SPACE && FlxG.keys.pressed.DOWN)
			{
				isWantFall = true;
			}
			else
			{
				isWantFall = false;
			}
		}
		else if (FlxG.keys.justPressed.SPACE && canJump && touching == FLOOR)
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
		if (FlxG.keys.pressed.V && canAttack)
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
				}
			}
		}
	}

	private function activateBonfire():Void
	{
		canMove = false;
		isWorking = true;
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
			currentWprkTime = 0;
			isWorking = false;
			canMove = true;
			FlxG.camera.zoom = 1;
			FlxG.camera.flash(FlxColor.BLACK, 3);
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
			canGetDamage = false;
			this.flicker(flickerTime);
			damageTimer.start(flickerTime, function(timer:FlxTimer)
			{
				canGetDamage = true;
			});
			this.velocity.x = this.velocity.x * -1;
			this.velocity.y = this.velocity.y * -1;
		}
	}
	public function activateObject(_type:Int = 1)
	{
		typeActiveObject = _type;
		txtGUI.visible = true;
		switch _type
		{
			case 0:
				// not any object
				txtGUI.visible = false;
			case 1:
				// bonfire
				txtGUI.text = "keep warm";
		}
	}
}
