import { Size2 } from "../math/geometry/size2";
import { NUM_CHANNELS, WebGlInputMatrix, WebGlOutputMatrix } from "./matrix";

const vertexShaderSource = `\
    attribute vec2 position; 

    void main() {
        gl_Position = vec4(position, 0.0, 1.0);
    }
    `;

// WebGL setup largely derived from
// https://observablehq.com/@mbostock/conways-game-of-life.
export class WebGlMatrixTransformer {
  public readonly canvas: HTMLCanvasElement;
  private readonly program: WebGLProgram;
  private readonly gl: WebGLRenderingContext;

  constructor(fragmentShaderSource: string) {
    this.canvas = document.createElement("canvas");

    const context = this.canvas.getContext("webgl");
    if (context === null) {
      throw new Error("Failed to get webgl context");
    }
    this.gl = context;

    this.program = this.createProgram(context, fragmentShaderSource);
    this.createFramebuffer();
  }

  public transform(matrix: WebGlInputMatrix): WebGlOutputMatrix {
    // This is important! The canvas is 300x150 by default, and unless the viewport
    // is resized to fit the incoming matrix, the part of the matrix which lies
    // outside the viewport will be ignored.
    this.gl.viewport(0, 0, matrix.size.width, matrix.size.height);

    const inputTexture = this.createTexture(matrix);
    const outputTexture = this.createTexture(matrix.minSize);
    this.attachTextureToFramebuffer(outputTexture);

    this.gl.bindTexture(this.gl.TEXTURE_2D, inputTexture);
    this.gl.uniform2f(
      this.gl.getUniformLocation(this.program, "resolution"),
      matrix.size.width,
      matrix.size.height
    );
    this.gl.drawArrays(this.gl.TRIANGLE_STRIP, 0, NUM_CHANNELS);

    const transformed = WebGlOutputMatrix.ofMinSize(matrix);
    this.gl.readPixels(
      0,
      0,
      transformed.size.width,
      transformed.size.height,
      this.gl.RGBA,
      this.gl.UNSIGNED_BYTE,
      transformed.asArray()
    );

    return transformed;
  }

  private createFramebuffer(): WebGLFramebuffer {
    const framebuffer = this.gl.createFramebuffer();
    if (framebuffer === null) {
      throw new Error("Failed to create framebuffer");
    }
    this.gl.bindFramebuffer(this.gl.FRAMEBUFFER, framebuffer);

    return framebuffer;
  }

  private createProgram(
    gl: WebGLRenderingContext,
    fragmentShaderSource: string
  ): WebGLProgram {
    const vertexShader = gl.createShader(gl.VERTEX_SHADER);
    if (vertexShader === null) {
      throw new Error("Failed to create vertex shader");
    }
    gl.shaderSource(vertexShader, vertexShaderSource);
    gl.compileShader(vertexShader);

    if (!gl.getShaderParameter(vertexShader, gl.COMPILE_STATUS)) {
      throw new Error(
        "Failed to compile vertex shader: \n\n" +
          gl.getShaderInfoLog(vertexShader)
      );
    }

    const fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
    if (fragmentShader === null) {
      throw new Error("Failed to create fragment shader");
    }
    gl.shaderSource(fragmentShader, fragmentShaderSource);
    gl.compileShader(fragmentShader);

    if (!gl.getShaderParameter(fragmentShader, gl.COMPILE_STATUS)) {
      throw new Error(
        "Failed to compile fragment shader: \n\n" +
          gl.getShaderInfoLog(fragmentShader)
      );
    }

    const program = gl.createProgram();
    if (program === null) {
      throw new Error("Failed to create WebGL program");
    }
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);

    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
      var info = gl.getProgramInfoLog(program);
      throw new Error("Could not compile WebGL program. \n\n" + info);
    }

    gl.useProgram(program);

    // Vertices, interpreted as a TRIANGLE_STRIP, to position some triangles
    // on the screen so that the fragment shader has some fragments to process.
    // These vertices have nothing to do with the state of the Life cells.
    const vertices = new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]);

    gl.bindBuffer(gl.ARRAY_BUFFER, gl.createBuffer());
    gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);

    const position = gl.getAttribLocation(program, "position");
    gl.enableVertexAttribArray(position);
    gl.vertexAttribPointer(position, 2, gl.FLOAT, false, 0, 0);

    return program;
  }

  private createTexture(input: WebGlInputMatrix | Size2): WebGLTexture {
    const texture = this.gl.createTexture();
    if (texture === null) {
      throw new Error("Failed to create texture");
    }

    const { array, size } =
      input instanceof WebGlInputMatrix
        ? { array: input.asArray(), size: input.size }
        : { array: null, size: input };

    this.gl.bindTexture(this.gl.TEXTURE_2D, texture);
    this.gl.texImage2D(
      this.gl.TEXTURE_2D,
      0,
      this.gl.RGBA,
      size.width,
      size.height,
      0,
      this.gl.RGBA,
      this.gl.UNSIGNED_BYTE,
      array
    );

    // Make the texture work even if its size is not a power of two.
    // See https://www.khronos.org/webgl/wiki/WebGL_and_OpenGL_Differences#Non-Power_of_Two_Texture_Support.
    // See also https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/Tutorial/Using_textures_in_WebGL, which notes:
    // "Without performing the below configuration, WebGL requires all samples of NPOT textures to fail by returning transparent black: rgba(0,0,0,0)."
    this.gl.texParameteri(
      this.gl.TEXTURE_2D,
      this.gl.TEXTURE_MIN_FILTER,
      this.gl.LINEAR
    );
    this.gl.texParameteri(
      this.gl.TEXTURE_2D,
      this.gl.TEXTURE_WRAP_S,
      this.gl.CLAMP_TO_EDGE
    );
    this.gl.texParameteri(
      this.gl.TEXTURE_2D,
      this.gl.TEXTURE_WRAP_T,
      this.gl.CLAMP_TO_EDGE
    );

    return texture;
  }

  private attachTextureToFramebuffer(texture: WebGLTexture) {
    this.gl.framebufferTexture2D(
      this.gl.FRAMEBUFFER,
      this.gl.COLOR_ATTACHMENT0,
      this.gl.TEXTURE_2D,
      texture,
      0
    );
  }
}
