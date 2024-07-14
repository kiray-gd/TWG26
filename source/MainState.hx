package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;

class MainState extends FlxState
{
	private var title1:FlxSprite = new FlxSprite();
	private var flxTxt:FlxText = new FlxText(190, 210, 200, "press Enter to try..");
	private var delay:Int = 60;
	private var currentDelay:Int = 0;

	override public function create()
	{
		super.create();
		FlxG.timeScale = 1;
		FlxG.camera.flash(0xFFB30000, 0.6);
		title1.loadGraphic("assets/images/bleedtitle.png", 320, 240);
		add(title1);
		flxTxt.color = 0xFFB30000;
		add(flxTxt);
		FlxG.sound.playMusic("assets/music/wakeup.ogg", 0.3, false);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		currentDelay++;
		if (currentDelay >= delay)
		{
			currentDelay = 0;
			flxTxt.visible = !flxTxt.visible;
		}
		if (FlxG.keys.pressed.ENTER)
		{
			FlxG.switchState(new PlayState());
		}
	}
}
