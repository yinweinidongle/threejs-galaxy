uniform float uSize;
attribute float aScale;
varying vec3 vColor;
uniform float uTime;
attribute vec3 aRandomness;


void main(){
      //gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.0);

      vec4 modelPosition = modelMatrix * vec4(position,1.0);


      //spin
      float angle = atan(modelPosition.x,modelPosition.y);
      float distanceToCenter = length(modelPosition.xy);
      float angleOffset = (1.0/distanceToCenter)*uTime*0.2;
      angle += angleOffset;
      modelPosition.x = cos(angle)*distanceToCenter;
      modelPosition.y = sin(angle)*distanceToCenter;

      //randomness
      modelPosition.xyz += aRandomness;

      vec4 viewPosition = viewMatrix * modelPosition;
      vec4 projectedPosition = projectionMatrix * viewPosition;

      gl_Position = projectedPosition;

      gl_PointSize = uSize*aScale;

      vColor = color;

      #ifdef USE_SIZEATTENUATION

        bool isPerspective = isPerspectiveMatrix( projectionMatrix );

        if ( isPerspective ) gl_PointSize *= ( 1.0 / - mvPosition.z );

      #endif

      
}