package{
	import com.codeazur.utils.BitArray;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamAppendBytesAction;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import n.h264.NALUnit;
	import org.osmf.net.httpstreaming.flv.FLVHeader;
	import org.osmf.net.httpstreaming.flv.FLVParser;
	import org.osmf.net.httpstreaming.flv.FLVTag;
	import org.osmf.net.httpstreaming.flv.FLVTagVideo;
	
	/**
	 * Example parsing h264 NAL unit header and patching idr_pic_id
	 * @author N
	 */
	public class Main extends Sprite {
		
		private var loader:URLLoader;
		private var data:ByteArray;
		private var parser:FLVParser;
		private var intra_frames:Vector.<FLVTagVideo>;
		private var seq_header:FLVTagVideo;
		
		public function Main() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.load(new URLRequest('v/test.flv'));
		}
		
		private function onLoadComplete(e:Event):void {
			data = loader.data as ByteArray;
			
			intra_frames = new Vector.<FLVTagVideo>();
			
			parser = new FLVParser(true);
			parser.parse(data, true, onEachFLVTag);
		}
		
		private function onEachFLVTag(flv_tag:FLVTag):Boolean {
			if (flv_tag.tagType == FLVTag.TAG_TYPE_VIDEO) {
				var video_tag:FLVTagVideo = flv_tag as FLVTagVideo;
				switch (video_tag.avcPacketType) {
					case FLVTagVideo.AVC_PACKET_TYPE_NALU:
						intra_frames.push(video_tag);
						break;
					case FLVTagVideo.AVC_PACKET_TYPE_SEQUENCE_HEADER:
						seq_header = video_tag;
						break;
				}
			}
			if (data.bytesAvailable) {
				return true
			} else {
				proceedParsing();
				return false
			}
		}
		
		private function proceedParsing():void {
			for (var i:int = 0; i < intra_frames.length; i++) {
				parseAndPatchFrame(intra_frames[i], Boolean(i % 2));
			}
			
			playVideo();
		}
		
		private function parseAndPatchFrame(frame:FLVTagVideo, even:Boolean):void {
			var h264data:ByteArray = frame.data;
			h264data.position = 0;
			
			var nal:NALUnit = new NALUnit();
			nal.read(h264data);
			
			nal.patch(even);
			
			var h264_patched:BitArray = new BitArray();
			nal.write(h264_patched);
			
			frame.data = h264_patched;
		}
		
		private function playVideo():void {
			var ba:ByteArray = new ByteArray();
			
			var h:FLVHeader = new FLVHeader();
			h.hasVideoTags = true;
			h.write(ba);
			
			seq_header.write(ba);
			
			for (var i:int = 0; i < intra_frames.length; i++) {
				intra_frames[i].write(ba);
			}
			
			var nc:NetConnection = new NetConnection();
			nc.connect(null);
			var s:NetStream = new NetStream(nc);
			s.play(null);
			
			s.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
			s.appendBytes(ba);
			
			var v:Video = new Video();
			v.attachNetStream(s);
			addChild(v);
		}
	}
	
}