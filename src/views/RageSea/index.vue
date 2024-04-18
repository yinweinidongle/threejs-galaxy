<script setup>
import {onMounted} from "vue";
import * as THREE from 'three'
import Base from "../Base";
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import {GUI} from "three/examples/jsm/libs/lil-gui.module.min.js"
import waterVertexShader from './shader/vertex.glsl?raw'
import waterFragmentShader from './shader/fragment.glsl?raw'

let base,controls,gui,clock,waterMaterial;
onMounted(()=>{
    base = new Base()
    base.camera.position.z = 5
    base.camera.updateProjectionMatrix()
    controls = new OrbitControls(base.camera,base.renderer.domElement)
    gui = new GUI({width:300})
    clock = new THREE.Clock()
    
    window.addEventListener("resize",resize)
    //createBox();

    const debugObject = {}

    debugObject.depthColor = '#56a3cd'
    debugObject.surfaceColor = '#9bd8ff'

    /**
     * Water
     */

     const waterGeometry = new THREE.PlaneGeometry(2,2,512,512)
     waterMaterial = new THREE.ShaderMaterial({
        vertexShader:waterVertexShader,
        fragmentShader:waterFragmentShader,
        uniforms:{
            uTime:{value:0},
            uBigWavesElevation:{value:0.2},
            uBigWavesFrequency:{value:new THREE.Vector2(4,1.5)},
            uBigWavesSpeed:{value:0.75},

            uSmallWavesElevation:{value:0.15},
            uSmallWavesFrequency:{value:3},
            uSmallWavesSpeed:{value:0.2},
            uSmallWavesIterations:{value:4.0},

            uDepthColor:{value:new THREE.Color(debugObject.depthColor)},
            uSurfaceColor:{value:new THREE.Color(debugObject.surfaceColor)},
            

            uColorOffset:{value:0.08},
            uColorMultiplier:{value:5},


        }
       
     })


     //Debug
     gui.add(waterMaterial.uniforms.uBigWavesElevation,'value').min(0).max(1).step(0.01).name('uBigWavesElevation')
     gui.add(waterMaterial.uniforms.uBigWavesFrequency.value,'x').min(0).max(10).step(0.01).name('uBigWavesFrequencyX')
     gui.add(waterMaterial.uniforms.uBigWavesFrequency.value,'y').min(0).max(10).step(0.01).name('uBigWavesFrequencyY')
     gui.add(waterMaterial.uniforms.uBigWavesSpeed,'value').min(0).max(4).step(0.001).name('uBigWavesSpeed')

     gui.addColor(debugObject,'depthColor').onChange(()=>{
        waterMaterial.uniforms.uDepthColor.value.set(debugObject.depthColor)
    })
     gui.addColor(debugObject,'surfaceColor').onChange(()=>{
        waterMaterial.uniforms.uSurfaceColor.value.set(debugObject.surfaceColor)
    })

    gui.add(waterMaterial.uniforms.uColorOffset,'value').min(0).max(1).step(0.001).name('uColorOffset')
    gui.add(waterMaterial.uniforms.uColorMultiplier,'value').min(0).max(10).step(0.001).name('uColorMultiplier')

    gui.add(waterMaterial.uniforms.uSmallWavesElevation,'value').min(0).max(1).step(0.001).name('uSmallWavesElevation')
    gui.add(waterMaterial.uniforms.uSmallWavesFrequency,'value').min(0).max(20).step(0.001).name('uSmallWavesFrequency')
    gui.add(waterMaterial.uniforms.uSmallWavesSpeed,'value').min(0).max(4).step(0.001).name('uSmallWavesSpeed')
    gui.add(waterMaterial.uniforms.uSmallWavesIterations,'value').min(0).max(8).step(1).name('uSmallWavesIterations')


     const water = new THREE.Mesh(waterGeometry,waterMaterial)
     water.rotation.x = -Math.PI*0.5
     base.scene.add(water)


     update()
   


});

function createBox(){
    const geometry = new THREE.BoxGeometry(1,1,1)
    const materail = new THREE.MeshBasicMaterial({color:0x00ff00})
    const cube = new THREE.Mesh(geometry,materail)
    base.scene.add(cube)
}

function update() {
    const elapsedTime = clock.getElapsedTime()

    //Update water
    waterMaterial.uniforms.uTime.value = elapsedTime


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
