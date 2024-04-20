
varying vec3 vPosition;

uniform float uTime;


float random2D(vec2 value){
  return fract(sin(dot(value.xy,vec2(12.1233432,78.2323)))*3242432.2324234);
}


void main() {
  //vec3 newPosition = modelPosition.xyz + 5 * time + randomInUnitSphere() * 5; // 更新位置
  //gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(position,1.0);

  vec4 modelPosition = modelMatrix * vec4(position,1.0);

  float glitchTime = uTime+modelPosition.y;
  float glitchStrength = sin(glitchTime) + sin(glitchTime * 3.45) + sin(glitchTime * 8.76);
  glitchStrength /= 3.0;
  glitchStrength = smoothstep(0.3,1.0,glitchStrength);
  glitchStrength *= 0.25;
  modelPosition.x += (random2D(modelPosition.xz + uTime) - 0.5) * glitchStrength; 
  modelPosition.z += (random2D(modelPosition.zx + uTime) - 0.5) * glitchStrength;
 
  gl_Position = projectionMatrix * viewMatrix * modelPosition;

  vec4 modelNormal = modelMatrix * vec4(normal,0.0);

  vPosition = modelPosition.xyz;
}