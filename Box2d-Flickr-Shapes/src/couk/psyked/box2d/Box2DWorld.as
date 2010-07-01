package couk.psyked.box2d
{
	import Box2D.Collision.Shapes.b2CircleDef;
	import Box2D.Collision.Shapes.b2PolygonDef;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2DistanceJointDef;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2World;

	import couk.psyked.box2d.utils.Box2DMouseUtils;
	import couk.psyked.box2d.utils.Box2DPointUtils;
	import couk.psyked.box2d.utils.Box2DShapeOptions;
	import couk.psyked.box2d.utils.Box2DUtils;
	import couk.psyked.box2d.utils.Box2DWorldOptions;
	import couk.psyked.box2d.utils.library.Box2DShapeParser;
	import couk.psyked.box2d.utils.shape.PolygonTool;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	import wumedia.vector.VectorShapes;

	/**
	 *
	 * @author James
	 */
	public class Box2DWorld extends Sprite
	{

		/**
		 *
		 * @param world
		 * @param _options
		 */
		public function Box2DWorld( world:b2World, _options:Box2DWorldOptions )
		{
			options = _options;
			_world = world;
			worldSprite = Box2DUtils.addDebugDraw( world );
			Box2DMouseUtils.initialise( _world, options.scale, worldSprite );
			Box2DPointUtils.initialise( _world, options.scale, worldSprite );

			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		/**
		 *
		 * @default
		 */
		public var mouseInteractExclusions:Array;

		private var _animateOnEnterFrame:Boolean;

		private var _debugDraw:Boolean;

		private var _deferedMouseInteraction:Boolean;

		private var _framerateIndependantAnimation:Boolean;

		private var _mouseInteraction:Boolean;

		private var _world:b2World;

		private var fiaTimer:Timer;

		private var framerate:Number = ( 1000 / 60 );

		private var mouseDefinition:b2MouseJointDef;

		private var mouseJoint:b2MouseJoint;

		public var options:Box2DWorldOptions;

		private var worldSprite:Sprite;

		public function get world():b2World
		{
			return _world;
		}

		public function set world( value:b2World ):void
		{
			_world = value;
		}

		/**
		 *
		 * @return
		 */
		public function get animateOnEnterFrame():Boolean
		{
			return _animateOnEnterFrame;
		}

		/**
		 *
		 * @param value
		 */
		public function set animateOnEnterFrame( value:Boolean ):void
		{
			if ( value )
			{
				if ( !_animateOnEnterFrame )
				{
					addEventListener( Event.ENTER_FRAME, updateBox2D );
				}
			}
			else
			{
				if ( _animateOnEnterFrame )
				{
					removeEventListener( Event.ENTER_FRAME, updateBox2D );
				}
			}
			_animateOnEnterFrame = value;
		}

		/**
		 *
		 * @param vec
		 * @return
		 */
		public function b2Vec2ToPoint( vec:b2Vec2 ):Point
		{
			return new Point( vec.x * options.scale, vec.y * options.scale );
		}

		/**
		 *
		 * @param x
		 * @param y
		 * @param radius
		 * @param rotation
		 */
		public function createCircle( x:int, y:int, radius:int, rotation:int = 0 ):void
		{
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.position.Set( x / options.scale, y / options.scale );
			bodyDef.linearDamping = 0.25;
			bodyDef.angularDamping = 0.25;
			var shapeDef:b2CircleDef = new b2CircleDef();
			shapeDef.radius = radius / options.scale;
			shapeDef.density = 1;
			shapeDef.friction = 5;
			var body:b2Body = _world.CreateBody( bodyDef );
			body.SetAngle(( rotation % 360 ) * ( Math.PI / 180 ));
			body.CreateShape( shapeDef );
			body.SetMassFromShapes();
		}

		/*
		   private function makeComplexBody(p_body:B2Body, p_vertices:Array) : Void
		   {
		   var processedVerts = _polyTool.getTriangulatedPoly(p_vertices);

		   if(processedVerts != null) {
		   var tcount = cast(processedVerts.length / 3, Int);
		   for (i in 0...tcount) {
		   var polyDef:B2PolygonDef;
		   polyDef = new B2PolygonDef();
		   polyDef.friction = 0.5;

		   if(p_static)
		   polyDef.density = 0.0;
		   else
		   polyDef.density = 1.0;

		   polyDef.vertexCount = 3;

		   var index:int = i * 3;
		   polyDef.vertices[0].Set(processedVerts[index].x/30,processedVerts[index].y/30);
		   polyDef.vertices[1].Set(processedVerts[index+1].x/30,processedVerts[index+1].y/30);
		   polyDef.vertices[2].Set(processedVerts[index+2].x/30,processedVerts[index+2].y/30);
		   p_body.CreateShape(polyDef);
		   }
		   p_body.SetMassFromShapes();
		   _bodyCount++;
		   } else {

		   // The polygon is bad somehow. Probably overlapping segments.
		   // So let's recurse with the convex hull of the bad poly.
		   makeComplexBody(p_body, _polyTool.getConvexPoly(p_vertices), p_static);
		   }
		 } */

		/**
		 *
		 * @param x
		 * @param y
		 * @param points
		 * @param rotation
		 */
		public function createComplexPolygon( x:int, y:int, points:Array, rotation:int = 0, shapeOptions:Box2DShapeOptions = null ):void
		{
			if ( points.length < 3 )
			{
				//throw new Error( "Complex Polygons must have at least 3 points." );
				trace( "Complex Polygons must have at least 3 points." );
			}
			//todo: Re-implement this - it's really quite good.
			/* graphics.lineStyle( 1, 0xff0000 );
			   for each ( var point:Point in points )
			   {
			   graphics.lineTo( point.x, point.y );
			 } */

			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.position.Set( x / options.scale, y / options.scale );
			bodyDef.linearDamping = 0.25;
			bodyDef.angularDamping = 0.25;

			var body:b2Body = _world.CreateBody( bodyDef );
			body.SetAngle(( rotation % 360 ) * ( Math.PI / 180 ));

			// If there are more than 8 vertices, its a complex body
			if ( points.length > 8 )
			{
				makeComplexBody( body, points, shapeOptions );
			}
			else
			{
				if ( PolygonTool.isPolyConvex( points ) && PolygonTool.isPolyClockwise( points ))
				{
					makeSimpleBody( body, points, shapeOptions );
				}
				else
				{
					makeComplexBody( body, points, shapeOptions );
				}
			}
			body.SetMassFromShapes();
		}

		/**
		 *
		 * @param body1
		 * @param body2
		 * @param _a1
		 * @param _a2
		 */
		public function createDisanceJoint( body1:b2Body, body2:b2Body, _a1:Point = null, _a2:Point = null ):void
		{
			var a1:b2Vec2;
			var a2:b2Vec2;

			if ( !_a1 )
			{
				a1 = body1.GetWorldCenter();
			}
			else
			{
				a1 = new b2Vec2( _a1.x / options.scale, _a1.y / options.scale );
			}

			if ( !_a2 )
			{
				a2 = body2.GetWorldCenter();
			}
			else
			{
				a2 = new b2Vec2( _a2.x / options.scale, _a2.y / options.scale );
			}
			var jointDef:b2DistanceJointDef = new b2DistanceJointDef();
			jointDef.Initialize( body1, body2, a1, a2 );
			_world.CreateJoint( jointDef );
		}

		/**
		 * Loads the specified library file, and extracts the named library item from it, parsing it into a Box2D object.
		 *
		 * @param x
		 * @param y
		 * @param shapeName
		 * @param libraryName
		 * @param rotation
		 * @param levelOfDetail
		 */
		public function createPolyFromLibraryShape( x:int, y:int, shapeName:String, libraryName:String, rotation:int = 0, levelOfDetail:uint = 5, shapeOptions:Box2DShapeOptions = null ):void
		{

			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener( IOErrorEvent.IO_ERROR, onError );
			loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onError );
			loader.addEventListener( Event.COMPLETE, onLoaded );
			loader.load( new URLRequest( libraryName ));

			function onError( e:Event = null ):void
			{
				loader.removeEventListener( IOErrorEvent.IO_ERROR, onError );
				loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onError );
				loader.removeEventListener( Event.COMPLETE, onLoaded );

				// supress the errors for now.
			}

			function onLoaded( e:Event = null ):void
			{
				loader.removeEventListener( IOErrorEvent.IO_ERROR, onError );
				loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onError );
				loader.removeEventListener( Event.COMPLETE, onLoaded );

				VectorShapes.extractFromLibrary( loader.data, [ shapeName ]);

				//var points:Array = Box2DShapeParser.getPoints( shapeName, 1, levelOfDetail * options.scale );
				var points:Array = Box2DShapeParser.getPoints( shapeName, 1, levelOfDetail );

				if ( points )
				{
					for each ( var shapePoints:Array in points )
					{
						if ( shapePoints.length > 2 )
						{
							createComplexPolygon( x, y, shapePoints, rotation, shapeOptions );
						}
						else
						{
							trace( "Error getting points from Shape in library." );
						}
					}
				}

				if ( e )
				{
					dispatchEvent( e );
				}
			}

		}

		/**
		 *
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 * @param rotation
		 */
		public function createRectangle( x:int, y:int, width:int, height:int, rotation:int = 0 ):b2Body
		{
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.position.Set( x / options.scale, y / options.scale );
			bodyDef.linearDamping = 0.25;
			bodyDef.angularDamping = 0.25;
			var shapeDef:b2PolygonDef = new b2PolygonDef();
			shapeDef.SetAsBox( width / options.scale, height / options.scale );
			shapeDef.density = 1;
			shapeDef.friction = 5;
			var body:b2Body = _world.CreateBody( bodyDef );
			body.SetAngle(( rotation % 360 ) * ( Math.PI / 180 ));
			body.CreateShape( shapeDef );
			body.SetMassFromShapes();

			return body;
		}

		/**
		 *
		 * @param body1
		 * @param body2
		 * @param point
		 */
		public function createRevoluteJoint( body1:b2Body, body2:b2Body, point:Point ):void
		{
			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.Initialize( body1, body2, new b2Vec2( point.x / options.scale, point.y / options.scale ));
			_world.CreateJoint( jointDef );
		}

		/**
		 *
		 * @return
		 */
		public function get debugDraw():Boolean
		{
			return _debugDraw;
		}

		/**
		 *
		 * @param value
		 */
		public function set debugDraw( value:Boolean ):void
		{
			if ( value )
			{
				if ( !contains( worldSprite ))
				{
					addChild( worldSprite );
				}
			}
			else
			{
				if ( contains( worldSprite ))
				{
					removeChild( worldSprite );
				}
			}
			_debugDraw = value;
		}

		/**
		 *
		 * @param fn
		 */
		public function forEachBody( fn:Function ):void
		{
			var node:b2Body = _world.GetBodyList();

			while ( node )
			{
				var b:b2Body = node;
				node = node.GetNext();

				fn.apply( this, [ b ]);
			}
		}

		/**
		 *
		 * @return
		 */
		public function get framerateIndependantAnimation():Boolean
		{
			return _framerateIndependantAnimation;
		}

		/**
		 *
		 * @param value
		 */
		public function set framerateIndependantAnimation( value:Boolean ):void
		{
			if ( value )
			{
				if ( !_framerateIndependantAnimation )
				{
					fiaTimer = new Timer( framerate );
					fiaTimer.addEventListener( TimerEvent.TIMER, updateBox2D );
					fiaTimer.start();
				}
			}
			else
			{
				if ( _framerateIndependantAnimation )
				{
					fiaTimer.removeEventListener( TimerEvent.TIMER, updateBox2D );
					fiaTimer.stop();
					fiaTimer = null;
				}
			}
			_framerateIndependantAnimation = value;
		}

		/**
		 *
		 * @return
		 */
		public function getb2world():b2World
		{
			return _world;
		}

		/**
		 *
		 * @return
		 */
		public function get mouseInteraction():Boolean
		{
			return _mouseInteraction;
		}

		/**
		 *
		 * @param value
		 */
		public function set mouseInteraction( value:Boolean ):void
		{
			if ( stage )
			{
				if ( value )
				{
					if ( !_mouseInteraction )
					{
						// excludeUserData is an array of userData types to exclude from this behaviour
						stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
						stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
					}
				}
				else
				{
					if ( _mouseInteraction )
					{
						// excludeUserData is an array of userData types to exclude from this behaviour
						stage.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
						stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
					}
				}
				_mouseInteraction = value;
				_deferedMouseInteraction = value;
			}
			else
			{
				_deferedMouseInteraction = value;
			}
		}

		/**
		 *
		 * @param point
		 * @return
		 */
		public function pointTob2Vec2( point:Point ):b2Vec2
		{
			return new b2Vec2( point.x / options.scale, point.y / options.scale );
		}

		/**
		 *
		 * @param e
		 */
		public function updateBox2D( e:Event = null ):void
		{
			_world.Step(( 1 / 30 ), 10, 10 );

			if ( mouseJoint )
			{
				var mouseXWorldPhys:Number = mouseX / options.scale;
				var mouseYWorldPhys:Number = mouseY / options.scale;
				var p2:b2Vec2 = new b2Vec2( mouseXWorldPhys, mouseYWorldPhys );
				mouseJoint.SetTarget( p2 );
			}
		}

		internal function makeComplexBody( body:b2Body, processedVerts:Array, shapeOptions:Box2DShapeOptions = null ):void
		{
			if ( !shapeOptions )
			{
				shapeOptions = new Box2DShapeOptions();
			}
			/* var tcount:int = int( processedVerts.length / 3 );

			   for ( var i:int = 0; i < tcount; i++ )
			   {
			   var shapeDef:b2PolygonDef = new b2PolygonDef();
			   shapeDef.density = 1;
			   shapeDef.friction = 5;

			   shapeDef.vertexCount = 3;

			   var index:int = i * 3;
			   shapeDef.vertices[ 0 ].Set( processedVerts[ index ].x / 30, processedVerts[ index ].y / 30 );
			   shapeDef.vertices[ 1 ].Set( processedVerts[ index + 1 ].x / 30, processedVerts[ index + 1 ].y / 30 );
			   shapeDef.vertices[ 2 ].Set( processedVerts[ index + 2 ].x / 30, processedVerts[ index + 2 ].y / 30 );
			   body.CreateShape( shapeDef );
			   }
			   body.SetMassFromShapes();
			 body.CreateShape( shapeDef ); */
			var vertArray:Array = processedVerts.slice( 0 );

			if ( !PolygonTool.isPolyClockwise( vertArray ))
			{
				vertArray.reverse();
			}
			var polys:Array = PolygonTool.earClip( vertArray );

			if ( polys != null )
			{
				for each ( var poly:Array in polys )
				{
					//if ( poly != null )
					//{
					var shapeDef:b2PolygonDef;
					shapeDef = new b2PolygonDef();
					shapeDef.friction = 0.5;
					//shapeDef.density = 1.0;
					shapeDef.density = shapeOptions.density;
					shapeDef.vertexCount = poly.length;
					//shapeDef.userData = shapeOptions.userData;
					body.SetUserData( shapeOptions.userData );

					//var i:int = 0;
					//for each ( vertex in poly.nVertices )
					for ( var i:int = 0; i < poly.length; i++ )
					{
						shapeDef.vertices[ i ].Set( poly[ i ].x / options.scale, poly[ i ].y / options.scale );
							//trace( poly[ i ].x / options.scale, poly[ i ].y / options.scale );
							//i++;
					}
					body.CreateShape( shapeDef );
						//}
				}
				body.SetMassFromShapes();
			}
			else
			{
				makeComplexBody( body, PolygonTool.getConvexPoly( processedVerts ));
			}
		}

		internal function makeSimpleBody( p_body:b2Body, p_vertices:Array, shapeOptions:Box2DShapeOptions = null ):void
		{
			var vertArray:Array = p_vertices.slice( 0 );
			vertArray.reverse();

			var polyDef:b2PolygonDef;
			polyDef = new b2PolygonDef();
			polyDef.friction = 0.5;

			//polyDef.density = 1.0;
			polyDef.density = shapeOptions.density;
			//polyDef.userData = shapeOptions.userData;
			p_body.SetUserData( shapeOptions.userData );

			polyDef.vertexCount = p_vertices.length;
			var i:int = 0;

			for each ( var vertex:Point in vertArray )
			{
				polyDef.vertices[ i ].Set( vertex.x / options.scale, vertex.y / options.scale );
				i++;
			}
			p_body.CreateShape( polyDef );
			p_body.SetMassFromShapes();
		}

		internal function onMouseDown( e:Event ):void
		{
			//trace( Box2DMouseUtils.getTopBodyAtMouse());
			var body:b2Body = Box2DMouseUtils.getTopBodyAtMouse();

			if ( body )
			{
				var mouseJointDef:b2MouseJointDef = new b2MouseJointDef();
				mouseJointDef.body1 = _world.GetGroundBody();
				mouseJointDef.body2 = body;
				mouseJointDef.target.Set( mouseX / options.scale, mouseY / options.scale );
				mouseJointDef.maxForce = 30000;
				//mouseJointDef.timeStep = ( 1 / 30 );
				mouseJoint = _world.CreateJoint( mouseJointDef ) as b2MouseJoint;
			}
		}

		internal function onMouseUp( e:Event ):void
		{
			if ( mouseJoint )
			{
				_world.DestroyJoint( mouseJoint );
				mouseJoint = null;
			}
		}

		/**
		 *
		 * @param e
		 */
		private function onAddedToStage( e:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			mouseInteraction = _deferedMouseInteraction;
		}
	}
}