package {
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.utils.ByteArray;
	
	import org.libspark.flartoolkit.core.FLARCode;
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.core.raster.rgb.FLARRgbRaster_BitmapData;
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	import org.libspark.flartoolkit.detector.FLARSingleMarkerDetector;
	import org.libspark.flartoolkit.pv3d.FLARBaseNode;
	import org.libspark.flartoolkit.pv3d.FLARCamera3D;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	
	[SWF(width="640",height="480", framerate="30", backgoundColor="#FFFFFF")]
	
	
	public class AugRealityDae extends Sprite
	{
		[Embed(source="marker.pat", mimeType="application/octet-stream")]
		private var marker:Class;
		[Embed(source="camera_para.dat", mimeType="application/octet-stream")]
		private var cam_params:Class;
		
		private var WIDTH:Number = 640;
		private var HEIGHT:Number = 480;
		//create FLAR params
		private var arParams:FLARParam;
		private var arMarker:FLARCode;
		//create cam params
		private var arVid:Video;
		private var arCam:Camera;
		//create BMP params
		private var arBMP:BitmapData;
		private var arRaster:FLARRgbRaster_BitmapData;
		private var arDetection:FLARSingleMarkerDetector;
		//create papervision params
		private var arScene:Scene3D;
		private var ar3dcam:FLARCamera3D;
		private var arBaseNode:FLARBaseNode;
		private var arViewport:Viewport3D;
		private var arRenderEngine:BasicRenderEngine;
		private var arTransmat:FLARTransMatResult;
		
		private var cubesBool:Boolean = false;
		
		public function AugRealityDae(){
			createFlar();	
			createCam();
			createBMP();
			createPapervision();
			createDae();
			addEventListener(Event.ENTER_FRAME, loop);
		}
		public function createFlar():void{
			arParams = new FLARParam();
			arMarker = new FLARCode(16, 16); 
			arParams.loadARParam(new cam_params() as ByteArray);
			arMarker.loadARPatt(new marker());
		}
		public function createCam():void{
			arVid = new Video(WIDTH, HEIGHT);
			arCam = Camera.getCamera();
			arCam.setMode(WIDTH, HEIGHT, 30);
			arVid.attachCamera(arCam);
			addChild(arVid);
		}
		public function createBMP():void{
			arBMP = new BitmapData(WIDTH, HEIGHT);
			arBMP.draw(arVid);
			arRaster = new FLARRgbRaster_BitmapData(arBMP);
			arDetection = new FLARSingleMarkerDetector(arParams, arMarker, 80);
		}
		public function createPapervision():void{
			arScene = new Scene3D();
			ar3dcam = new FLARCamera3D(arParams);
			arBaseNode = new FLARBaseNode();
			arRenderEngine = new BasicRenderEngine;
			arTransmat = new FLARTransMatResult;
			arViewport = new Viewport3D();
			arScene.addChild(arBaseNode, "arBaseNode");
			addChild(arViewport);
		}
		
		private function showDae():void{
			arBaseNode.getChildByName("DAE").visible=true;
		}
		private function hideDae():void{
			arBaseNode.getChildByName("DAE").visible=false;
		}
		private function metaDataHandler(infoObject:Object):void{
			trace("metaData");
		}
		private function createDae():void{
			var arMaterials:MaterialsList = new MaterialsList();
			var bm:BitmapFileMaterial = new BitmapFileMaterial("telefono.png");
			arMaterials.addMaterial(bm);
			var arDAE:DAE = new DAE();
			arDAE.load("Old_phone.dae", arMaterials);
			arDAE.rotationX = 90;
			arDAE.scale = 500;
			arScene.addChild(arBaseNode);
			arBaseNode.addChild(arDAE, "DAE");
			addChild(arViewport);
		}
		public function loop(e:Event):void{
			arBMP.draw(arVid); 
			try {
				if(arDetection.detectMarkerLite(arRaster, 80) && arDetection.getConfidence() > 0.3){
					if (cubesBool==false){
						showDae();
					}
					arDetection.getTransformMatrix(arTransmat);
					arBaseNode.setTransformMatrix(arTransmat);
					arRenderEngine.renderScene(arScene, ar3dcam, arViewport);
				}
				else{
					hideDae();
					arRenderEngine.renderScene(arScene, ar3dcam, arViewport);
				}
			}
			catch(e:Error){}
		}
	}
}
 