package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxDirectionFlags;

class ObjectItem extends FlxSprite {
    public function new(x:Float, y:Float) {
        super(x, y);
        // this.makeGraphic(16, 16, FlxColor.GREEN);
        loadGraphic("assets/images/tilesetmain.png", true, 16, 16);
        animation.add("idle", [11], 1, false);
        animation.play("idle");
        // immovable = false;
        // gravity
		// acceleration.set(0, 600);
        
        // allowCollisions = FlxDirectionFlags.ANY;
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        // Дополнительная логика для ящика (если потребуется)
    }
}
