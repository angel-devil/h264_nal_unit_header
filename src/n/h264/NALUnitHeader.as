package n.h264 {
	import com.codeazur.utils.BitArray;
	import n.utils.BitArrayUtils;
	/**
	 * ...
	 * @author N
	 */
	public class NALUnitHeader {
		
		//slice header
		private var nal_ref_idc:int;
		private var nal_unit_type:int;
		private var first_mb_in_slice:int;
		private var slice_type:int;
		private var pic_parameter_set_id:int;
		private var frame_num:int;
		private var idr_pic_id:int;
		
		private var no_output_of_prior_pics_flag:int;
		private var long_term_reference_flag:uint;
		
		private var slice_qp_delta:int;
		private var disable_deblocking_filter_idc:int;
		private var slice_alpha_c0_offset_div2:int;
		private var slice_beta_offset_div2:int;
		
		private var extra_bits:Array = [];
		
		public function NALUnitHeader() {
			
		}
		
		public function read(input:BitArray):void {
			input.position = 0;
			
			//forbidden_zero_bit
			input.readBits(1);
			
			nal_ref_idc = input.readBits(2);
			nal_unit_type = input.readBits(5);
			
			first_mb_in_slice = BitArrayUtils.readUE(input);
			slice_type = BitArrayUtils.readUE(input);
			pic_parameter_set_id = BitArrayUtils.readUE(input);
			frame_num = input.readBits(4);
			idr_pic_id = BitArrayUtils.readUE(input);
			
			no_output_of_prior_pics_flag = input.readBits(1);
			long_term_reference_flag = input.readBits(1);
			
			slice_qp_delta = BitArrayUtils.readSE(input);
			disable_deblocking_filter_idc = BitArrayUtils.readUE(input);
			slice_alpha_c0_offset_div2 = BitArrayUtils.readSE(input);
			slice_beta_offset_div2 = BitArrayUtils.readSE(input);
			
			while (true) {
				try {
					extra_bits.push(input.readBits(1));
				} catch (e:Error) {
					break;
				}
			}
		}
		
		public function patch(even:Boolean):int {
			if (nal_unit_type != 5) {
				return 0
			}
			
			var _offset:int = 0;
			
			switch (idr_pic_id) {
				case 0:
					if (!even) {
						var start_byte:uint = extra_bits.length % 8;
						var is_cabac:Boolean = (start_byte >= 2)? true: false;
						for (var i:int = 0; i < start_byte; i++) {
							if (extra_bits[i] == 0) is_cabac = false;
						}
						if (is_cabac) {
							//if cabac_alignment_one_bit >= 2, delete 2 bits
							idr_pic_id = 1;
							extra_bits.splice(0, 2);
						} else {
							//add 8 bits and delete 8 bits from slice_data (payload)
							idr_pic_id = 15;
							_offset += 1;
						}
					}
					break;
				case 1:
					if (even) idr_pic_id = 2;
					break;
			}
			
			return _offset
		}
		
		public function write(output:BitArray):void {
			//forbidden_zero_bit
			output.writeBits(1, 0);
			output.writeBits(2, nal_ref_idc);
			output.writeBits(5, nal_unit_type);
			
			BitArrayUtils.writeUE(output, first_mb_in_slice);
			BitArrayUtils.writeUE(output, slice_type);
			BitArrayUtils.writeUE(output, pic_parameter_set_id);
			output.writeBits(4, frame_num);
			BitArrayUtils.writeUE(output, idr_pic_id);
			
			output.writeBits(1, no_output_of_prior_pics_flag);
			output.writeBits(1, long_term_reference_flag);
			
			BitArrayUtils.writeSE(output, slice_qp_delta);
			BitArrayUtils.writeUE(output, disable_deblocking_filter_idc);
			BitArrayUtils.writeSE(output, slice_alpha_c0_offset_div2);
			BitArrayUtils.writeSE(output, slice_beta_offset_div2);
			
			var i:int;
			for (i = 0; i < extra_bits.length; i++) {
				output.writeBits(1, extra_bits[i]);
			}
		}
		
		public function toString():String {
			return [nal_ref_idc, nal_unit_type, first_mb_in_slice, slice_type, 
				pic_parameter_set_id, frame_num, idr_pic_id, no_output_of_prior_pics_flag,
				long_term_reference_flag, slice_qp_delta,
				disable_deblocking_filter_idc, slice_alpha_c0_offset_div2, 
				slice_beta_offset_div2, "|", extra_bits.join("")].join(",");
		}
	}

}