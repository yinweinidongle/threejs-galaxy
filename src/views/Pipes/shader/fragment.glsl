//uniform sampler2D texture; // 用于粒子纹理的采样器

//varying float vLife; // 从顶点着色器接收的剩余生命值

void main() {
  // 根据剩余生命值计算颜色和透明度
  //vec4 color = texture2D(texture, gl_PointCoord);
  //color.a *= smoothstep(0.0, 1.0, vLife); // 随生命值降低而逐渐透明

  gl_FragColor = vec4(1.0,0.3,1.0,1.0);
}