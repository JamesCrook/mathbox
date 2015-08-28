uniform vec4 geometryClip;
attribute vec4 position4;

// External
vec3 getPosition(vec4 xyzw);

vec3 getFacePosition() {
  vec4 p = min(geometryClip, position4);
  return getPosition(p);
}