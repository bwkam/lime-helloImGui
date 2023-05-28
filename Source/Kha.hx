package;

import lime.utils.Float32Array;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.WebGLRenderContext;

@:enum abstract Usage(Int) to Int {
	var StaticUsage = 0;
	var DynamicUsage = 1; // Just calling it Dynamic causes problems in C++
	var ReadableUsage = 2;
}

@:allow(IndexBuffer, VertexBuffer)
class Kha {
	private static var _gl:WebGLRenderContext;

	public function new(gl:WebGLRenderContext) {
		_gl = gl;
	}
}

// this is the empty class definition to make the source compile
// the original is extern code
// todo - implement the functions that are needed for the lime example

class IndexBuffer {
	private static var _gl:WebGLRenderContext;
	private static var _stride:Int;
	private static var _ebo:GLBuffer;
	private static var _indexCount:Int;

	public function new(indexCount:Int, usage:Int, stride:Int) {
		_gl = Kha._gl;
		_stride = stride;
		_indexCount = indexCount;

		_ebo = _gl.createBuffer();
		_gl.bindBuffer(_gl.ELEMENT_ARRAY_BUFFER, _ebo);
	}

	// idk some helper funcs I think will prob need
	public function bind_buf():Void {
		_gl.bindBuffer(_gl.ELEMENT_ARRAY_BUFFER, _ebo);
	}

	public function buf_data():Void {
		_gl.bufferData(_gl.ELEMENT_ARRAY_BUFFER, new Float32Array(_indexCount),
			_gl.STREAM_DRAW); // I chose STREAM_DRAW because that was in the original cpp, but im not sure
	}

	public function delete():Void {
		_gl.bindBuffer(_gl.ELEMENT_ARRAY_BUFFER, null);
	}

	// I don't think we can easily set vertex data like this lol
	public function set():Void {}

	// still no idea counts of what
	public function count():Int {
		return 0;
	}
}

// this is the empty class definition to make the source compile
// the original is extern code
// todo - implement the functions that are needed for the lime example
class VertexBuffer {
	private static var _gl:WebGLRenderContext;
	private static var _stride:Int;
	private static var _vbo:GLBuffer;
	private static var _vertexCount:Int;

	// this will pretty much be just a bindBuffer call
	public function new(vertexCount:Int, structure:VertexStructure, usage:Int, stride:Int) {
		_gl = Kha._gl;
		_stride = stride;
		_vertexCount = vertexCount;

		_vbo = _gl.createBuffer();
		_gl.bindBuffer(_gl.ARRAY_BUFFER, _vbo);
	}

	public function bind_buf():Void {
		_gl.bindBuffer(_gl.ELEMENT_ARRAY_BUFFER, _vbo);
	}

	public function buf_data():Void {
		_gl.bufferData(_gl.ARRAY_BUFFER, new Float32Array(_vertexCount),
			_gl.STREAM_DRAW); // I chose STREAM_DRAW because that was in the original cpp, but im not sure
	}

	// binding the buffer to null is enough
	public function delete():Void {
		_gl.bindBuffer(_gl.ARRAY_BUFFER, null);
	}

	// count of what?
	public function count():Int {
		return 0;
	}

	public function stride():Int {
		return _stride;
	}
}

class VertexElement {
	public var name:String;
	public var data:VertexData;

	public function new(name:String, data:VertexData) {
		this.name = name;
		this.data = data;
	}
}

@:enum abstract VertexData(Int) {
	var Float32_1X = 0;
	var Float32_2X = 1;
	var Float32_3X = 2;
	var Float32_4X = 3;
	var Float32_4X4 = 4;
	var Int8_1X = 5;
	var UInt8_1X = 6;
	var Int8_1X_Normalized = 7;
	var UInt8_1X_Normalized = 8;
	var Int8_2X = 9;
	var UInt8_2X = 10;
	var Int8_2X_Normalized = 11;
	var UInt8_2X_Normalized = 12;
	var Int8_4X = 13;
	var UInt8_4X = 14;
	var Int8_4X_Normalized = 15;
	var UInt8_4X_Normalized = 16;
	var Int16_1X = 17;
	var UInt16_1X = 18;
	var Int16_1X_Normalized = 19;
	var UInt16_1X_Normalized = 20;
	var Int16_2X = 21;
	var UInt16_2X = 22;
	var Int16_2X_Normalized = 23;
	var UInt16_2X_Normalized = 24;
	var Int16_4X = 25;
	var UInt16_4X = 26;
	var Int16_4X_Normalized = 27;
	var UInt16_4X_Normalized = 28;
	var Int32_1X = 29;
	var UInt32_1X = 30;
	var Int32_2X = 31;
	var UInt32_2X = 32;
	var Int32_3X = 33;
	var UInt32_3X = 34;
	var Int32_4X = 35;
	var UInt32_4X = 36;
	// deprecated
	var Float1 = Float32_1X;
	var Float2 = Float32_2X;
	var Float3 = Float32_3X;
	var Float4 = Float32_4X;
	var Float4x4 = Float32_4X4;
	var Short2Norm = Int16_2X_Normalized;
	var Short4Norm = Int16_4X_Normalized;

	/**
		Return the element size of the given vertex data type in bytes.
	**/
	public static inline function getStride(vertexData:VertexData):Int {
		return switch (vertexData) {
			case Float32_1X: 4 * 1;
			case Float32_2X: 4 * 2;
			case Float32_3X: 4 * 3;
			case Float32_4X: 4 * 4;
			case Float32_4X4: 4 * 4 * 4;
			case Int8_1X: 1;
			case UInt8_1X: 1;
			case Int8_1X_Normalized: 1;
			case UInt8_1X_Normalized: 1;
			case Int8_2X: 1 * 2;
			case UInt8_2X: 1 * 2;
			case Int8_2X_Normalized: 1 * 2;
			case UInt8_2X_Normalized: 1 * 2;
			case Int8_4X: 1 * 4;
			case UInt8_4X: 1 * 4;
			case Int8_4X_Normalized: 1 * 4;
			case UInt8_4X_Normalized: 1 * 4;
			case Int16_1X: 2 * 1;
			case UInt16_1X: 2 * 1;
			case Int16_1X_Normalized: 2 * 1;
			case UInt16_1X_Normalized: 2 * 1;
			case Int16_2X: 2 * 2;
			case UInt16_2X: 2 * 2;
			case Int16_2X_Normalized: 2 * 2;
			case UInt16_2X_Normalized: 2 * 2;
			case Int16_4X: 2 * 4;
			case UInt16_4X: 2 * 4;
			case Int16_4X_Normalized: 2 * 4;
			case UInt16_4X_Normalized: 2 * 4;
			case Int32_1X: 4 * 1;
			case UInt32_1X: 4 * 1;
			case Int32_2X: 4 * 2;
			case UInt32_2X: 4 * 2;
			case Int32_3X: 4 * 3;
			case UInt32_3X: 4 * 3;
			case Int32_4X: 4 * 4;
			case UInt32_4X: 4 * 4;
		}
	}
}

// not sure, but I think that's just something to manipulate the vertex attribs of a shader, done in lime by gl.vertexAttrib* calls
// vertex attribs like col, tex, pos (look at the original Kha sample)
class VertexStructure {
	public var elements:Array<VertexElement>;
	public var instanced:Bool;

	public function new() {
		elements = new Array<VertexElement>();
		instanced = false;
	}

	// ok, so looks like vertex elem is just a vertex attrib
	public function add(name:String, data:VertexData) {
		elements.push(new VertexElement(name, data));
	}

	@:keep
	public function size():Int {
		return elements.length;
	}

	public function byteSize():Int {
		var byteSize = 0;

		for (i in 0...elements.length) {
			byteSize += dataByteSize(elements[i].data);
		}

		return byteSize;
	}

	public static function dataByteSize(data:VertexData):Int {
		switch (data) {
			case Float32_1X:
				return 1 * 4;
			case Float32_2X:
				return 2 * 4;
			case Float32_3X:
				return 3 * 4;
			case Float32_4X:
				return 4 * 4;
			case Float32_4X4:
				return 4 * 4 * 4;
			case Int8_1X, UInt8_1X, Int8_1X_Normalized, UInt8_1X_Normalized:
				return 1 * 1;
			case Int8_2X, UInt8_2X, Int8_2X_Normalized, UInt8_2X_Normalized:
				return 2 * 1;
			case Int8_4X, UInt8_4X, Int8_4X_Normalized, UInt8_4X_Normalized:
				return 4 * 1;
			case Int16_1X, UInt16_1X, Int16_1X_Normalized, UInt16_1X_Normalized:
				return 1 * 2;
			case Int16_2X, UInt16_2X, Int16_2X_Normalized, UInt16_2X_Normalized:
				return 2 * 2;
			case Int16_4X, UInt16_4X, Int16_4X_Normalized, UInt16_4X_Normalized:
				return 4 * 2;
			case Int32_1X, UInt32_1X:
				return 1 * 4;
			case Int32_2X, UInt32_2X:
				return 2 * 4;
			case Int32_3X, UInt32_3X:
				return 3 * 4;
			case Int32_4X, UInt32_4X:
				return 4 * 4;
		}
	}

	@:keep
	public function get(index:Int):VertexElement {
		return elements[index];
	}
}
