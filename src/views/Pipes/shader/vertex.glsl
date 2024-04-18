//attribute vec3 positions;

//uniform float time;
// uniform vec3 emitterPosition; // 水管出口位置
// uniform vec3 velocity; // 粒子平均速度
// uniform float spread; // 速度随机散布范围
// uniform float decayRate; // 粒子生命衰减率

//varying float vLife; // 传递给片元着色器的剩余生命值

void main() {
  //vec3 newPosition = modelPosition.xyz + 5 * time + randomInUnitSphere() * 5; // 更新位置
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.0);

  // 计算并传递剩余生命值
  //vLife = max(0.0, 6.0 - time * 4.0);
}