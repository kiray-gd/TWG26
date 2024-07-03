package;

import flixel.FlxSprite;

class Lava extends FlxSprite
{
    public var speed:Float = 14; // Скорость подъема лавы

    public function new(x:Float, y:Float)
    {
        super(x, y);
        makeGraphic(380, 800, 0xffff0000); // Создаем графику лавы (красный прямоугольник)
        // immovable = true; // Лава не движется при столкновениях
    }

    override public function update(elapsed:Float):Void
    {
        
        y -= speed * elapsed; // Поднимаем лаву вверх
        super.update(elapsed);
    }
}
