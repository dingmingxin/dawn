local shader = require "ejoy2d.shader"

local vs = [[
attribute vec4 position;
attribute vec2 texcoord;
attribute vec4 color;

varying vec2 v_texcoord;
varying vec4 v_color;

void main() {
	gl_Position = position + vec4(-1,1,0,0);
	v_texcoord = texcoord;
	v_color = color;
}
]]

local sky_fs = [[
uniform sampler2D texture0;
uniform vec4 far;
uniform vec4 near;

varying vec2 v_texcoord;
varying vec4 v_color;

void main() {
	float f = pow(v_texcoord.y, 0.3);
	gl_FragColor = mix(far, near, f);
}
]]

local sea_fs = [[
uniform sampler2D Texture0;
uniform float t;
uniform vec4 far;
uniform vec4 near;
uniform vec4 spec;

varying vec2 v_texcoord;
varying vec4 v_color;

void main(void)
{
	vec2 tex_scale = vec2(0.5, 15.0);
	vec2 noise_speed = vec2(0.005, -0.08);

	vec2 tc = vec2(v_texcoord.x, pow(v_texcoord.y, 0.1));
	vec2 nc = fract(tc*tex_scale + t*noise_speed);

	vec4 noise = texture2D(Texture0, nc);
	float n = mix(noise.x, noise.y, (sin(t) + 1.0) * 0.5);
	float w = (sin(tc.y*80.0 + n - t) + 1.0) * 0.5;

	vec4 base1 = near * (1.0 + n*0.1);
	vec4 base2 = mix(spec, base1, pow(w - n*0.1, 0.15));
	gl_FragColor = mix(far, base2, pow(tc.y, 3.0));
}
]]

local M = {}

function M.init()
	shader.load("sky", sky_fs, vs, {far="4f", near="4f"})
	shader.load("sea", sea_fs, vs, {t="1f", far="4f", near="4f", spec="4f"})
end

return M