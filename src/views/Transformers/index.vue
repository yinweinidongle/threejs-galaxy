<script setup>
import {onMounted} from "vue";
import * as THREE from 'three'
import Base from "../Base";
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import {GUI} from "three/examples/jsm/libs/lil-gui.module.min.js"
import galaxyVertexShader from './shader/vertex.glsl?raw'
import galaxyFragmentShader from './shader/fragment.glsl?raw'

let base,controls,gui,clock,points;
let material = null
onMounted(()=>{
    base = new Base()
    base.camera.position.z = 15
    base.camera.updateProjectionMatrix()
    controls = new OrbitControls(base.camera,base.renderer.domElement)
    gui = new GUI({width:300})
    
    window.addEventListener("resize",resize)
    //createBox();

   //

   const particles = 500;

    const geometry = new THREE.BufferGeometry();

    const positions = [];
    const colors = [];

    const color = new THREE.Color();

    const n = 10, n2 = n / 2; // particles spread in the cube

    for ( let i = 0; i < particles; i ++ ) {

        // positions

        const x = Math.random() * n - n2;
        const y = Math.random() * n - n2;
        const z = Math.random() * n - n2;

        positions.push( x, y, z );

        // colors

        const vx = ( x / n ) + 0.5;
        const vy = ( y / n ) + 0.5;
        const vz = ( z / n ) + 0.5;

        color.setRGB( vx, vy, vz );

        colors.push( color.r, color.g, color.b );

    }

    geometry.setAttribute( 'position', new THREE.Float32BufferAttribute( positions, 3 ) );
    geometry.setAttribute( 'color', new THREE.Float32BufferAttribute( colors, 3 ) );

    geometry.computeBoundingSphere();

    //

    material = new THREE.ShaderMaterial({
            //size:parameters.size,
            //sizeAttenuation:true,
            depthWrite:false,
            blending:THREE.AdditiveBlending,
            vertexShader:galaxyVertexShader,
            fragmentShader:galaxyFragmentShader,
            uniforms:{
                
                uSize:new THREE.Uniform(0.4),
            }
    })

    points = new THREE.Points( geometry, material );
    base.scene.add( points );

    //


    update()


});

function createBox(){
    const geometry = new THREE.BoxGeometry(1,1,1)
    const materail = new THREE.MeshBasicMaterial({color:0x00ff00})
    const cube = new THREE.Mesh(geometry,materail)
    base.scene.add(cube)
}

function update() {

   

    requestAnimationFrame(update)
    base.update()
    controls.update()
    
}

function resize(){
    base.resize();
}

</script>

<template>
  
</template>

<style scoped>

</style>
