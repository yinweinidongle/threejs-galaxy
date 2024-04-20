//uniform sampler2D texture; // 用于粒子纹理的采样器
uniform float uTime;
//varying float vLife; // 从顶点着色器接收的剩余生命值
vec2 fade(vec2 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}
vec4 permute(vec4 x){
  return mod(((x*34.0)+1.0)*x,29.0);
}
float cnoise(vec2 P){
  vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
  vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
  Pi = mod(Pi, 289.0); // To avoid truncation effects in permutation
  vec4 ix = Pi.xzxz;
  vec4 iy = Pi.yyww;
  vec4 fx = Pf.xzxz;
  vec4 fy = Pf.yyww;
  vec4 i = permute(permute(ix) + iy);
  vec4 gx = 2.0 * fract(i * 0.0243902439) - 1.0; // 1/41 = 0.024...
  vec4 gy = abs(gx) - 0.5;
  vec4 tx = floor(gx + 0.5);
  gx = gx - tx;
  vec2 g00 = vec2(gx.x,gy.x);
  vec2 g10 = vec2(gx.y,gy.y);
  vec2 g01 = vec2(gx.z,gy.z);
  vec2 g11 = vec2(gx.w,gy.w);
  vec4 norm = 1.79284291400159 - 0.85373472095314 * 
    vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
  g00 *= norm.x;
  g01 *= norm.y;
  g10 *= norm.z;
  g11 *= norm.w;
  float n00 = dot(g00, vec2(fx.x, fy.x));
  float n10 = dot(g10, vec2(fx.y, fy.y));
  float n01 = dot(g01, vec2(fx.z, fy.z));
  float n11 = dot(g11, vec2(fx.w, fy.w));
  vec2 fade_xy = fade(Pf.xy);
  vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
  float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
}
varying vec2 vUv;

float random(vec2 st){
  return fract(sin(dot(st.xy,vec2(12.9898,78.3232)))*4354.4234242);
}

void main() {
  // 根据剩余生命值计算颜色和透明度
  //vec4 color = texture2D(texture, gl_PointCoord);
  //color.a *= smoothstep(0.0, 1.0, vLife); // 随生命值降低而逐渐透明

   //pattern 3
  //float strength = vUv.x;

  //pattern 4
  //float strength = 1.0 - vUv.y;

  //pattern 6
  //float strength =  vUv.y * 10.0;

  //pattern 7
  //float strength =  mod(vUv.y * 10.0,1.0);

  //pattern 8
  // float strength =  mod(vUv.y * 10.0,1.0);
  // strength =  step(0.5,strength);

  //pattern 9
  // float strength =  mod(vUv.y * 10.0,1.0);
  // strength =  step(0.8,strength);

  //pattern 10
  // float strength =  mod(vUv.x * 10.0,1.0);
  // strength =  step(0.8,strength);

  //pattern 11
  // float strength =  step(0.9,mod(vUv.x * 10.0,1.0));
  // strength += step(0.9,mod(vUv.y * 10.0,1.0));

  //pattern 12
  // float strength =  step(0.9,mod(vUv.x * 10.0,1.0));
  // strength *= step(0.9,mod(vUv.y * 10.0,1.0));


  // float strength =  step(0.2,mod(vUv.x * 10.0,1.0));
  // strength *= step(0.9,mod(vUv.y * 10.0,1.0));

  // float barX =  step(0.9,mod(vUv.x * 10.0,1.0));
  // barX *= step(0.2,mod(vUv.y * 10.0,1.0));
  // float barY =  step(0.2,mod(vUv.x * 10.0,1.0));
  // barY *= step(0.9,mod(vUv.y * 10.0,1.0));
  // float strength = barX + barY;
  // strength = clamp(strength,0.0,1.0);

  // float barX =  step(0.9,mod(vUv.x * 10.0,1.0));
  // barX *= step(0.2,mod(vUv.y * 10.0+0.2,1.0));
  // float barY =  step(0.2,mod(vUv.x * 10.0+0.2,1.0));
  // barY *= step(0.9,mod(vUv.y * 10.0,1.0));
  // float strength = barX + barY;

  // float strength =  min(abs(vUv.y - 0.5) , abs(vUv.x - 0.5));

  // float strength = step(0.2, max(abs(vUv.y - 0.5) , abs(vUv.x - 0.5)));

  // float strength = floor(vUv.y * 10.0)/10.0;
  // strength *= floor(vUv.x * 10.0)/10.0;

  // float strength = random(vUv);

  // vec2 gridUv = vec2(
  //     floor(vUv.y * 10.0)/10.0,
  //     floor(vUv.x * 10.0 + vUv.y * 5.0)/10.0
  // );
  // float strength = random(gridUv);

  // float strength = length(vUv);
  // float strength = length(vUv-0.5);
  // float strength = distance(vUv,vec2(0.5));

  // float strength = 1.0-distance(vUv,vec2(0.5));

  // float strength = 0.01 / (distance(vUv,vec2(0.5)));

  // float strength = 0.01 / (distance(vUv,vec2(0.5)));

  // float strength = step(0.5,distance(vUv,vec2(0.5)));

  // float angle = atan(vUv.x,vUv.y);
  // float strength = angle;

 

  float strength = step(0.7,sin(cnoise(vUv*5.0)*10.0+uTime));

  vec3 blackColor = vec3(0.0);
  vec3 uvColor = vec3(vUv,0.4);
  vec3 mixColor = mix(blackColor,uvColor,strength);

  gl_FragColor = vec4(mixColor,1.0);
  
  
}