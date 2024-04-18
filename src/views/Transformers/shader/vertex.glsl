


void main(){
      //gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.0);

      vec4 modelPosition = modelMatrix * vec4(position,1.0);


     

      vec4 viewPosition = viewMatrix * modelPosition;
      vec4 projectedPosition = projectionMatrix * viewPosition;

      gl_Position = projectedPosition;



      #ifdef USE_SIZEATTENUATION

        bool isPerspective = isPerspectiveMatrix( projectionMatrix );

        if ( isPerspective ) gl_PointSize *= ( 1.0 / - mvPosition.z );

      #endif

      
}