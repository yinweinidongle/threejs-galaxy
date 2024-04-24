uniform float uSize;
varying vec3 vColor;

uniform sampler2D uParticlesTexture;
attribute vec2 aParticlesUv;


void main(){

      vec4 particle = texture(uParticlesTexture,aParticlesUv);

      vec4 modelPosition = modelMatrix * vec4(position,1.0);
      vec4 viewPosition = viewMatrix * modelPosition;
      gl_Position = projectionMatrix * viewPosition;

      //Final size
      gl_PointSize = 10.0;
      vColor = vec3(1.0);

      

      
}