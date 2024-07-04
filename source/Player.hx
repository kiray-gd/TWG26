package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

using flixel.util.FlxSpriteUtil;

class Player extends FlxSprite
{
	// player params
    public var canJump:Bool = true;
    public var canWallJump:Bool = false;
    private var jumpTimer:FlxTimer;
	private var jumpPower:Int = -300;

	// private var health:Int = 3;

    public var isWantFall = false;
	public var canGetDamage = true;

	public var healthPoint:Int = 3;

	private var damageTimer:FlxTimer;
	private var flickerTime:Float = 2;

    public function new(X:Float, Y:Float)
    {
        super(X, Y);
        // loadGraphic("assets/images/player.png", true, 16, 16);
        loadGraphic("assets/images/duck.png", true, 16, 16);
        animation.add("idle", [0], 1, false);
        animation.add("run", [0, 1, 2, 3], 10, true);
        animation.add("jump", [10], 1, false);
        // this.addAnimation("run", [0, 1, 2, 3], 10, true);
        // addAnimation("idle", [0], 0, false);
        
        // whenever sprite is facing RIGHT, do NOT flip the sprite's graphic
        this.setFacingFlip(RIGHT, false, false);

        // whenever sprite is facing LEFT, flip the graphic horizontally
        this.setFacingFlip(LEFT, true, false);

		maxVelocity.set(120, 600); // Максимальная скорость
		acceleration.set(0, 600); // Гравитация
        drag.set(400, 0); // Сопротивление
		// изменяем размер хитбокса
		this.setSize(8, 16);
		this.offset.set(4, 0);

        jumpTimer = new FlxTimer();
		damageTimer = new FlxTimer();
    }

    override public function update(elapsed:Float):Void
    {
        
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
        if (FlxG.keys.pressed.SPACE && FlxG.keys.pressed.DOWN == false)
        {
            if (canJump)
            {
				velocity.y = jumpPower;
                canJump = false;
            }
            else if (canWallJump)
            {
				velocity.y = jumpPower;
                velocity.x = touching == LEFT ? maxVelocity.x : -maxVelocity.x;
                canWallJump = false;
            }
        }   else if (FlxG.keys.pressed.SPACE && FlxG.keys.pressed.DOWN) {
            isWantFall = true;
        }   else {
            isWantFall = false;
        }


        // Обновление флагов прыжка
        if (isTouching(FLOOR))
        {
            canJump = true;
        }

        //обновление анимации в зависимости от линейной скорости
        if(Math.abs(velocity.y) > 10){
            animation.play("jump");
        }   else if (Math.abs(velocity.x) > 10){
            animation.play("run");
        }   else {
            animation.play("idle");
        }

        super.update(elapsed);
    }

    public function onWallCollision():Void
    {
        canWallJump = true;
        jumpTimer.start(0.2, function(timer:FlxTimer) {
            canWallJump = false;
        });
    }
	public function onTrapCollision():Void
	{
		if (canGetDamage)
		{
			healthPoint -= 1;
			canGetDamage = false;
			this.flicker(flickerTime);
			// this.alpha = 0.5;
			damageTimer.start(flickerTime, function(timer:FlxTimer)
			{
				canGetDamage = true;
				// this.alpha = 1;
			});
		}
	}
}
