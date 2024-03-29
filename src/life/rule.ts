// Shader adapted from https://codepen.io/Hossein_Rafie/details/XWgNwBN.
export const fragmentShader = `\
    precision mediump float;

    // Copied from https://github.com/skeeto/webgl-game-of-life/blob/master/glsl/gol.frag.

    uniform sampler2D input_state;
    uniform vec2 resolution;

    int get(int x, int y) {
        vec2 index = (gl_FragCoord.xy + vec2(x, y)) / resolution;
        if ((index.x < 0.0 || 1.0 < index.x) || (index.y < 0.0 || 1.0 < index.y)) {
            return 0;
        }
        return int(texture2D(input_state, index).x);
    }

    void main() {
        int sum = get(-1, -1) +
                get(-1,  0) +
                get(-1,  1) +
                get( 0, -1) +
                get( 0,  1) +
                get( 1, -1) +
                get( 1,  0) +
                get( 1,  1);
        if (sum == 3) {
            gl_FragColor = vec4(1.0, 0.0, 0.0, 0.0);
        } else if (sum == 2) {
            float current = float(get(0, 0));
            gl_FragColor = vec4(current, 0.0, 0.0, 0.0);
        } else {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        }
    }
    `;
