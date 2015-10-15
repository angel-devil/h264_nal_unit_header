package n.utils {
	import com.codeazur.utils.BitArray;
	/**
	 * ...
	 * @author N
	 */
	public class BitArrayUtils {
		
		static private const LEN_TABLE:Array = [
				1,
					1,
					2,2,
					3,3,3,3,
					4,4,4,4,4,4,4,4,
					5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,
			6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,
					6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,
			7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
					7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
			7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
					7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
			8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
					8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
			8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
					8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
			8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
					8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
			8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
					8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
		];
		
		public function BitArrayUtils() {
			
		}
		
		static public function readUE(bytes:BitArray):int {
			var r:int = 0;
			var i:int = 0;
			while (bytes.readBits(1) == 0 && i < 32) {
				i++;
			}
			r = bytes.readBits(i);
			r += (1 << i) - 1;
			return r
		}
		
		static public function readSE(bytes:BitArray):int {
			var r:int = readUE(bytes);
			/*if (r & 0x01) {
				r = (r + 1) / 2;
			} else {
				r = -(r / 2);
			}*/
			if (r % 2) {
				r = (r + 1) / 2;
			} else {
				r = -r / 2;
			}
			
			return r
		}
		
		static public function writeUE(bytes:BitArray, v:int):void {
			var len:int;
			
			if (v == 0) {
				bytes.writeBits(1, 1);
			} else {
				v++;
				if (v >= 0x01000000) {
					len = 24 + LEN_TABLE[ v >> 24 ];
				} else if (v >= 0x00010000) {
					len = 16 + LEN_TABLE[ v >> 16 ];
				} else if (v >= 0x00000100) {
					len =  8 + LEN_TABLE[ v >>  8 ];
				} else {
					len = LEN_TABLE[ v ];
				}
				bytes.writeBits(2 * len - 1, v);
			}
		}
		
		static public function writeSE(bytes:BitArray, v:int):void {
			if (v <= 0) {
				writeUE(bytes, -v * 2);
			} else {
				writeUE(bytes, v * 2 - 1);
			}
		}
		
		static public function toString(bytes:BitArray):String {
			bytes.position = 0;
			bytes.resetBitsPending();
			var s:String = "";
			for (var i:int = 0; i < bytes.length * 8; i++) {
				s += bytes.readBits(1) + "";
			}
			return s
		}
		
	}

}