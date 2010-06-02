package couk.psyked.box2d.utils
{

    public class Box2DShapeOptions
    {
        public function Box2DShapeOptions( _density:Number = 1.0, _restitution:Number = 0.0 )
        {
            if ( _density )
            {
                density = _density;
            }
            if ( _restitution )
            {
                restitution = _restitution;
            }
        }

        public var density:Number;
        public var restitution:Number;

    }
}