package;

import lime.graphics.opengl.GLTexture;
import lime.graphics.Image;
import haxe.io.Bytes;
import lime.graphics.opengl.GLVertexArrayObject;
import lime.graphics.WebGLRenderContext;
import lime.app.Application;
import lime.graphics.RenderContext;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.utils.Float32Array;
import lime.utils.Int32Array;
import imgui.ImGui;
import imgui.ImGui.ImDrawData;
import Kha;

class Main extends Application {
	private static var maxBufferSize:Int = 10000;
	// private static var pipeline:PipelineState;
	// private static var texunit:TextureUnit;
	private static var imguiTexture:Image;
	private static var structure:VertexStructure;
	private static var vtx:VertexBuffer;
	private static var idx:IndexBuffer;
	private static var verticesArray:Array<Float>;
	private static var indicesArray:Array<Float>;

	// Model data
	var vbo:GLBuffer;
	var ebo:GLBuffer;
	var program:GLProgram;

	// Make sure you only do initialization once
	var initialized:Bool;
	var gl:WebGLRenderContext;
	var texture:GLTexture;

	public function new() {
		super();

		initialized = false;
	}

	/**
	 * Create a GL shader.
	 * 
	 * @param gl the GL rendering context
	 * @param source GLSL source text
	 * @param type type of shader to compile, usually gl.VERTEX_SHADER or gl.FRAGMENT_SHADER
	 * @return GLShader
	 */
	function glCreateShader(gl:WebGLRenderContext, source:String, type:Int):GLShader {
		var shader = gl.createShader(type);
		gl.shaderSource(shader, source);
		gl.compileShader(shader);

		if (gl.getShaderParameter(shader, gl.COMPILE_STATUS) == 0) {
			trace(gl.getShaderInfoLog(shader));
			return null;
		}

		return shader;
	}

	/**
	 * Create a GL program with vertex and fragment shaders.
	 * @param gl the GL rendering context
	 * @param vertexSource vertex shader GLSL source
	 * @param fragmentSource fragment shader GLSL source
	 * @return Null<GLProgram> the compiled and linked program or null if unsuccessful.
	 */
	function glCreateProgram(gl:WebGLRenderContext, vertexSource:String, fragmentSource:String):Null<GLProgram> {
		var vs = glCreateShader(gl, vertexSource, gl.VERTEX_SHADER);
		var fs = glCreateShader(gl, fragmentSource, gl.FRAGMENT_SHADER);

		if (vs == null || fs == null) {
			return null;
		}

		var program = gl.createProgram();
		gl.attachShader(program, vs);
		gl.attachShader(program, fs);

		gl.deleteShader(vs);
		gl.deleteShader(fs);

		gl.linkProgram(program);

		if (gl.getProgramParameter(program, gl.LINK_STATUS) == 0) {
			trace(gl.getProgramInfoLog(program));
			trace("VALIDATE_STATUS: " + gl.getProgramParameter(program, gl.VALIDATE_STATUS));
			trace("ERROR: " + gl.getError());
			return null;
		}

		return program;
	}

	function initialize(gl:WebGLRenderContext):Void {
		this.gl = gl;

		/*
			shader code as used in kha example https://github.com/jeremyfa/imgui-hx/tree/master/test/kha/Sources/Shaders 
		 */

		// Vertex Shader
		var vs = "
			#version 300 es

			precision mediump float;

			layout (location = 0) in vec3 pos;
			layout (location = 1) in vec4 col;
			layout (location = 2) in vec2 tex;

			out vec4 fragmentColor;
			out vec2 texcoord;

			void main() {
				gl_Position = vec4(pos.x, pos.y, 0.5, 1.0);
				fragmentColor = col;
				texcoord = tex;
			}
";

		// Fragment Shader
		var fs = "
			#version 300 es

			precision mediump float;

			in vec4 fragmentColor;
			in vec2 texcoord;
			out vec4 FragColor;
			uniform sampler2D texsampler;

			void main() {
				vec4 color = texture(texsampler, texcoord);
				FragColor = vec4(fragmentColor.r, fragmentColor.g, fragmentColor.b, fragmentColor.a * color.a);
			}
";

		program = glCreateProgram(gl, vs, fs);

		texture = gl.createTexture();
		gl.bindTexture(gl.TEXTURE_2D, texture);

		// config mipmap and other options
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);

		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

		ImGui.createContext();

		initialized = true;
	}

	public override function render(context:RenderContext):Void {
		switch (context.type) {
			case WEBGL, OPENGLES, OPENGL:
				{
					var gl = context.webgl;

					if (!initialized) {
						initialize(gl);
					}

					gl.clearColor(0.0, 0.0, 0.0, 1.0);
					gl.clear(gl.COLOR_BUFFER_BIT);
					gl.useProgram(program);

					ImGui.newFrame();
					ImGui.begin('test');
					ImGui.button("clicky");
					ImGui.end();
					ImGui.showDemoWindow();
					ImGui.endFrame();
					ImGui.render();
					renderDrawList(ImGui.getDrawData());
				}
			default:
		}
	}

	var bufferCount = 0;
	var vertexStride = 8;

	private static function setVertexColor(vBuf:Float32Array, col:Int, startIdx:Int):Void {
		vBuf[startIdx + 0] = ((col >> 0) & 0xFF) / 255;
		vBuf[startIdx + 1] = ((col >> 8) & 0xFF) / 255;
		vBuf[startIdx + 2] = ((col >> 16) & 0xFF) / 255;
		vBuf[startIdx + 3] = ((col >> 24) & 0xFF) / 255;
	}

	function renderDrawList(drawData:ImDrawData) {
		var invHalfWW = 1.0 / (window.width * .5);
		var invHalfWH = 1.0 / (window.height * .5);
		bufferCount = 0;
		for (i in 0...drawData.cmdListsCount) {
			var idxOffset = 0;
			var cmdList = drawData.cmdLists[i];
			var cmdBuffer = cmdList.cmdBuffer.data;

			// vertex and index buffers we're going to grab our vertices/indices data from to push into our vertices and indices arrays
			var vtxBuffer = cmdList.vtxBuffer.data;
			var idxBuffer = cmdList.idxBuffer.data;

			for (j in 0...cmdList.cmdBuffer.size()) {
				var cmd = cmdBuffer[j];
				var it = Std.int(cmd.elemCount / 3);

				if (cmd.elemCount > maxBufferSize) {
					// todo?
					// vtx.delete();
					// idx.delete();

					// create new vbo and ebo buffers
					vtx = new VertexBuffer(cmd.elemCount, structure, gl.STATIC_DRAW, vertexStride * Float32Array.BYTES_PER_ELEMENT);
					idx = new IndexBuffer(cmd.elemCount, gl.STATIC_DRAW, vertexStride * Float32Array.BYTES_PER_ELEMENT);

					maxBufferSize = cmd.elemCount;
				}

				for (tri in 0...it) {
					var baseIdx = idxOffset + (tri * 3);

					// single indices
					var idx1 = idxBuffer[baseIdx + 0];
					var idx2 = idxBuffer[baseIdx + 1];
					var idx3 = idxBuffer[baseIdx + 2];

					// single vertices
					var vtx1 = vtxBuffer[idx1];
					var vtx2 = vtxBuffer[idx2];
					var vtx3 = vtxBuffer[idx3];

					trace("vertex 1: " + vtx1);
					trace("vertex 1: " + vtx2);
					trace("vertex 1: " + vtx3);

					// var tmul = tri * 27;
					// v[tmul + 0] = vtx1.pos.x * invHalfWW - 1;
					// v[tmul + 1] = -(vtx1.pos.y * invHalfWH - 1.0);
					// v[tmul + 2] = 0.5; // Vertex coord
					// setVertexColor(v, vtx1.col, tmul + 3); // Vertex color

					// v[tmul + 7] = vtx1.uv.x;
					// v[tmul + 8] = vtx1.uv.y; // Texture UV coord
					// v[tmul + 9] = vtx2.pos.x * invHalfWW - 1;
					// v[tmul + 10] = -(vtx2.pos.y * invHalfWH - 1.0);
					// v[tmul + 11] = 0.5;
					// setVertexColor(v, vtx2.col, tmul + 12);

					// v[tmul + 16] = vtx2.uv.x;
					// v[tmul + 17] = vtx2.uv.y;
					// v[tmul + 18] = vtx3.pos.x * invHalfWW - 1;
					// v[tmul + 19] = -(vtx3.pos.y * invHalfWH - 1.0);
					// v[tmul + 20] = 0.5;
					// setVertexColor(v, vtx3.col, tmul + 21);

					// v[tmul + 25] = vtx3.uv.x;
					// v[tmul + 26] = vtx3.uv.y;

					// ii[tri * 3 + 0] = tri * 3 + 0;
					// ii[tri * 3 + 1] = tri * 3 + 1;
					// ii[tri * 3 + 2] = tri * 3 + 2;
				}

				// following lines are replicating https://github.com/jeremyfa/imgui-hx/blob/9beef7f886b4c72100711bb039bbb6bc1674556f/test/kha/Sources/ImGuiDemo.hx#L294
				// most likely wrong
				// _g4.begin();
				// _g4.setPipeline(pipeline);

				// _g4.setTexture(texunit, tex.ref);
				// gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, image.width, image.height, 0, gl.RGB, gl.UNSIGNED_BYTE, image.src);

				// _g4.setVertexBuffer(vtx);
				// _g4.setIndexBuffer(idx);
				// vtx.bind_buf();
				// idx.bind_buf();

				// vtx.buf_data();
				// idx.buf_data();

				// _g4.scissor(Std.int(cmd.clipRect.x), Std.int(cmd.clipRect.y), Std.int(cmd.clipRect.z - cmd.clipRect.x), Std.int(cmd.clipRect.w - cmd.clipRect.y));

				// _g4.drawIndexedVertices(0, cmd.elemCount);
				// gl.vertexAttribPointer(0, 3, gl.FLOAT, false, 3 * Float32Array.BYTES_PER_ELEMENT, 0);
				// gl.enableVertexAttribArray(0);
				// gl.drawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, 0);

				// _g4.end();

				idxOffset += cmd.elemCount;
			}
		}
	}
}
