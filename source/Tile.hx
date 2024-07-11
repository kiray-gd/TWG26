package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxTimer;

class Tile extends FlxSprite
{
    public var type:Int = 0;
	public var isTemporary:Bool = false;
	public var wasTouched:Bool = false;

	private var secondsToDisappear:Float = 1;
	private var timerToDie:FlxTimer;

	private var isRefreshing = false;
	private var refreshingTime:Int = 120;
	private var currentRefreshingTime:Int = 0;

    public function new(X:Float, Y:Float)
    {
        super(X, Y);
        // loadGraphic("assets/images/player.png", true, 16, 16);
		loadGraphic("assets/images/tilesetmain.png", true, 16, 16);
        animation.add("white", [0], 1, false);
        animation.add("default", [1], 1, false);
        animation.add("platform", [2], 1, false);
		animation.add("trapDown", [4], 1, false);
		animation.add("trapLeft", [5], 1, false);
		animation.add("trapUp", [6], 1, false);
		animation.add("trapRight", [7], 1, false);
		animation.add("temporaryPlatform", [8], 1, false);
		animation.add("fakewall", [15], 1, false);
        // this.addAnimation("run", [0, 1, 2, 3], 10, true);
        // addAnimation("idle", [0], 0, false);
        animation.play("default");
        
		timerToDie = new FlxTimer();
    }

    override public function update(elapsed:Float):Void
    {

		if (isTemporary && wasTouched)
		{
			isTemporary = false;
			this.alpha = 0.5;
			// sound shake
			timerToDie.start(secondsToDisappear, function(timer:FlxTimer)
			{
				// trace("kill tile");
				// this.kill();
				this.alpha = 0;
				this.allowCollisions = FlxDirectionFlags.NONE;
				isRefreshing = true;
			});
		}
		if (isRefreshing)
		{
			currentRefreshingTime++;
			if (currentRefreshingTime == refreshingTime)
			{
				currentRefreshingTime = 0;
				wasTouched = false;
				isTemporary = true;
				this.alpha = 1;
				isRefreshing = false;
				this.allowCollisions = FlxDirectionFlags.UP;
			}
		}

		super.update(elapsed);
    }

    public function setType(_type:Int = 0):Void{
        type = _type;
        switch type{
            case 0:
                animation.play("white");
            case 1:
                animation.play("default");
            case 2:
                animation.play("platform");
				this.setSize(16, 8);
			case 4:
				animation.play("trapDown");
				this.setSize(16, 8);
				this.offset.set(0, 8);
				this.y += 8;
			case 5:
				animation.play("trapLeft");
				this.setSize(8, 16);
				this.offset.set(0, 0);
			// this.x -= 8;
			case 6:
				animation.play("trapUp");
				this.setSize(16, 8);
			// this.offset.set(0, 8);
			// this.y += 8;
			case 7:
				animation.play("trapRight");
				this.setSize(8, 16);
				this.offset.set(8, 0);
				this.x += 8;
			case 8:
				animation.play("temporaryPlatform");
				this.setSize(16, 8);
				isTemporary = true;
			case 9:
				animation.play("fakewall");
			case 10:
				// invisible wall
				animation.play("default");
				alpha = 0;

        }
            

    }

    public function getType():Int {
        return type;
    }
}
