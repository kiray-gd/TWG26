package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class StartState extends FlxState
{

    private var title1:FlxSprite = new FlxSprite();
    private var title2:FlxSprite = new FlxSprite();
    private var titleTimer:FlxTimer = new FlxTimer();
    private var canStart:Bool = false;
    private var flxTxt:FlxText = new FlxText(110, 210, 200, "press Enter to start");
    private var delay:Int = 60;
    private var currentDelay:Int = 0;

	override public function create()
	{
		super.create();
        // начальный экран загрузки игры
        FlxG.autoPause = false;
		FlxG.mouse.visible = false;
        title1.loadGraphic("assets/images/kiraygdtitile.png", 320, 240);
        add(title1);
        FlxG.sound.play("assets/sounds/moho.ogg");
        FlxG.camera.flash(FlxColor.BLACK, 0.5);
        titleTimer.start(5, function(timer:FlxTimer)
            {
                remove(title1);
                
                title2.loadGraphic("assets/images/ducksoulstitle.png", 320, 240);
                add(title2);
                FlxG.camera.flash(FlxColor.BLACK, 0.5);
                flxTxt.alpha = 0.5;
                add(flxTxt);
                // music
                if (FlxG.sound.music == null) // don't restart the music if it's already playing
                {
                    FlxG.sound.playMusic("assets/music/midnight.ogg", 0.4, true);
                }
                canStart = true;
            });

	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

        currentDelay++;
        if(currentDelay >= delay){
            currentDelay = 0;
            flxTxt.visible = !flxTxt.visible;
        }
        if(FlxG.keys.pressed.ENTER && canStart){
            FlxG.switchState(new MainState());
        }
	}
}
