<script setup>
import {onMounted} from "vue";
import * as THREE from 'three'
import Base from "../Base";
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import {GUI} from "three/examples/jsm/libs/lil-gui.module.min.js"
import galaxyVertexShader from './shader/vertex.glsl?raw'
import galaxyFragmentShader from './shader/fragment.glsl?raw'
import {GLTFLoader} from 'three/examples/jsm/loaders/GLTFLoader.js'
import { DRACOLoader } from 'three/addons/loaders/DRACOLoader.js'

let base,controls,gui,clock,planeMaterial;
let material = null
onMounted(()=>{
    base = new Base()
    base.camera.position.z = 4
    base.camera.updateProjectionMatrix()
    controls = new OrbitControls(base.camera,base.renderer.domElement)
    gui = new GUI({width:300})
    clock = new THREE.Clock()
    
    window.addEventListener("resize",resize)
    //createBox();

     // light

     const ambientLight = new THREE.AmbientLight( 0xcccccc, 0.4 );
	base.scene.add( ambientLight );

				const directionalLight = new THREE.DirectionalLight( 0xffffff, 0.6 );
				directionalLight.position.set( - 1, 1, 1 );
	base.scene.add( directionalLight );


     // skybox

     const cubeTextureLoader = new THREE.CubeTextureLoader();
				cubeTextureLoader.setPath( '/skybox/' );

				const cubeTexture = cubeTextureLoader.load( [
					"px.jpg", "nx.jpg",
					"py.jpg", "ny.jpg",
					"pz.jpg", "nz.jpg"
				] );

	base.scene.background = cubeTexture;

   
   const planeGeometry = new THREE.PlaneGeometry(2,2,32,32)

   const count = planeGeometry.attributes.position.count
   const randoms = new Float32Array(count)

   const textureLoader = new THREE.TextureLoader()
   const flagTexture = textureLoader.load("/canada.png")

   for(let i=0;i<count;i++){
    randoms[i] = Math.random()
   }
   planeGeometry.setAttribute("aRandom",new THREE.BufferAttribute(randoms,1))

   console.log(planeGeometry)
   planeMaterial = new THREE.ShaderMaterial({
     vertexShader:galaxyVertexShader,
     fragmentShader:galaxyFragmentShader,
     side: THREE.DoubleSide,
     transparent:true,
     uniforms:{
        uFrequency:{value:new THREE.Vector2(10,5)},
        uTime:{value:0},
        uTexture:{value:flagTexture}
     }
   });

   const planeMesh = new THREE.Mesh(planeGeometry,planeMaterial)

   gui.add(planeMaterial.uniforms.uFrequency.value,'x').min(0).max(20).step(0.01).name('frequencyX')
   gui.add(planeMaterial.uniforms.uFrequency.value,'y').min(0).max(20).step(0.01).name('frequencyY')
   planeMesh.scale.y = 2/3
   base.scene.add(planeMesh)


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

    planeMaterial.uniforms.uTime.value = elapsedTime

    // const ratio = elapsedTime
    
    // points.scale.x += ratio
    // points.scale.y += ratio
    // points.scale.z += ratio

    // if(points.scale.x>3){
    //     points.scale.x = 1
    //     points.scale.y = 1
    //     points.scale.z = 1
    // }

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
