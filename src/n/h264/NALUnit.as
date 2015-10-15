/**
 * Created with IntelliJ IDEA.
 * User: antonsidorenko
 * Date: 24/11/14
 * Time: 01:30
 */
package n.h264 {
import com.codeazur.utils.BitArray;
import n.utils.BitArrayUtils;

import flash.utils.ByteArray;

public class NALUnit {

    public var size_writed:uint;
	public var size_real:uint;

    public var header:NALUnitHeader;
    public var payload:BitArray;
	private var offset:int;

    public function NALUnit() {

    }

    public function read(input:ByteArray):void {
        //4 bytes
        size_writed = input.readUnsignedInt();
		size_real = input.length - 4;

        //5 bytes
        header = new NALUnitHeader();

        var headerBitArray:BitArray = new BitArray();
        input.readBytes(headerBitArray, 0, 5);
        headerBitArray.position = 0;
        header.read(headerBitArray);
		
		headerBitArray.clear();
		
		payload = new BitArray();
        input.readBytes(payload, 0, size_real - 5);
    }
	
	public function patch(even:Boolean):void {
		offset = header.patch(even);
	}

    public function write(output:BitArray):void {
        output.writeUnsignedInt(size_writed);

        var headerBitArray:BitArray = new BitArray();
        header.write(headerBitArray);
		
        output.writeBytes(headerBitArray);
		
        output.writeBytes(payload, 0, payload.length - offset);
		
		headerBitArray.clear();
		payload.clear();
		payload = null;
    }
}
}