<script setup>
import {onMounted, render} from "vue";
import * as THREE from 'three'
import Base from "../Base";
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import CustomShaderMaterial from 'three-custom-shader-material/vanilla'
import {GLTFLoader} from 'three/examples/jsm/loaders/GLTFLoader.js'
import { DRACOLoader } from 'three/addons/loaders/DRACOLoader.js'

import { mergeVertices } from "three/addons/utils/BufferGeometryUtils.js";


import {GUI} from "three/examples/jsm/libs/lil-gui.module.min.js"
import wobblyVertexShader from './shader/vertex.glsl?raw'
import wobblyFragmentShader from './shader/fragment.glsl?raw'
import { uniform } from "three/examples/jsm/nodes/Nodes.js";


console.log(mergeVertices)






let base,controls,gui,clock,sizes,uniforms,debugObject;




onMounted(()=>{
    base = new Base()
    base.camera.position.z =7
    base.camera.updateProjectionMatrix()
    controls = new OrbitControls(base.camera,base.renderer.domElement)
    gui = new GUI({width:300})
    clock = new THREE.Clock()
    base.renderer.setClearColor('#000011')
    base.renderer.shadowMap.enabled = true;
    window.addEventListener("resize",resize)
    //createBox();

     // light

    const ambientLight = new THREE.AmbientLight( 0xcccccc, 1);
	base.scene.add( ambientLight );

				const directionalLight = new THREE.DirectionalLight( 0xffffff, 2 );
				directionalLight.position.set( 5, 1, 1 );
                directionalLight.castShadow = true
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

    /**
     * Sizes
     */

     sizes = {
        width:window.innerWidth,
        height:window.innerHeight,
        pixelRatio:Math.min(window.devicePixelRatio,2)
    }

    const textureLoader = new THREE.TextureLoader()

    sizes.resolution = new THREE.Vector2(sizes.width * sizes.pixelRatio,sizes.height* sizes.pixelRatio)

   


   


    /**
     * Wobbly
     */
     debugObject = {}
     debugObject.colorA = '#000000'
     debugObject.colorB = '#000000'

     uniforms = {

        uTime : new THREE.Uniform(0),
        uPositionFrequency:new THREE.Uniform(0.5),
        uTimeFrequency:new THREE.Uniform(0.4),
        uStrength:new THREE.Uniform(0.3),

        uWarpPositionFrequency:new THREE.Uniform(0.38),
        uWarpTimeFrequency:new THREE.Uniform(0.12),
        uWarpStrength:new THREE.Uniform(1.7),

        uColorA: new THREE.Uniform(new THREE.Color(debugObject.colorA)),
        uColorB: new THREE.Uniform(new THREE.Color(debugObject.colorB))

     }


     //Material
     const material = new CustomShaderMaterial({

        //CSM
        baseMaterial:THREE.MeshPhysicalMaterial,

        vertexShader:wobblyVertexShader,
        fragmentShader:wobblyFragmentShader,
        silent:true,

        uniforms:uniforms,
        //MeshPhysicalMaterial
        metalness:0,
        roughness:0.5,
        color:'#ffffff',
        transmission:0,
        ior:1.5,
        thickness:1.5,
        transparent:true,
        wireframe:false,

     })

     const depthMaterial = new CustomShaderMaterial({
        baseMaterial:THREE.MeshDepthMaterial,
        vertexShader:wobblyVertexShader,
        silent:true,
        uniforms:uniforms,
        depthPacking:THREE.RGBADepthPacking
     })



     //Model
    //  const loader = new GLTFLoader();
    // // Optional: Provide a DRACOLoader instance to decode compressed mesh data
    // const dracoLoader = new DRACOLoader();
    // dracoLoader.setDecoderPath( '/examples/jsm/libs/draco/' );
    // loader.setDRACOLoader( dracoLoader );
    // // Load a glTF resource
    // loader.load(
    //     "/monkey.glb",
    //     function ( gltf ) {

    //         const wobble = gltf.scene.children[0]
    //         wobble.receiveShadow = true
    //         wobble.castShadow = true
    //         wobble.material = material
    //         wobble.customDepthMaterial = depthMaterial

            
    //         wobble.position.x = 0;
    //         wobble.position.y = 0;
    //         wobble.position.z = 3;
    //         base.scene.add( wobble );
    //     }
    // );


     //Tweaks

     gui.add(uniforms.uPositionFrequency,'value',0,2,0.001).name('uPositionFrequency')
     gui.add(uniforms.uTimeFrequency,'value',0,2,0.001).name('uTimeFrequncy')
     gui.add(uniforms.uStrength,'value',0,2,0.001).name('uStrength')

     gui.add(uniforms.uWarpPositionFrequency,'value',0,2,0.001).name('uWarpPositionFrequency')
     gui.add(uniforms.uWarpTimeFrequency,'value',0,2,0.001).name('uWarpTimeFrequency')
     gui.add(uniforms.uWarpStrength,'value',0,2,0.001).name('uWarpStrength')

     gui
        .addColor(debugObject,'colorA')
        .onChange(()=>{
            uniforms.uColorA.value.set(debugObject.colorA)
        })
    gui
        .addColor(debugObject,'colorB')
        .onChange(()=>{
            uniforms.uColorB.value.set(debugObject.colorB)
        })


     gui.add(material,'metalness',0,1,0.001)
     gui.add(material,'roughness',0,1,0.001)
     gui.add(material,'transmission',0,1,0.001)
     gui.add(material,'ior',0,10,0.001)
     gui.add(material,'thickness',0,1,0.001)
     gui.addColor(material,'color')


     let geometry = new THREE.IcosahedronGeometry(2.5,50)
    geometry = mergeVertices(geometry)
    geometry.computeTangents()
    console.log(geometry.attributes)


     const wobble = new THREE.Mesh(geometry,material)
     wobble.customDepthMaterial = depthMaterial
     wobble.receiveShadow = true;
     wobble.castShadow = true
     base.scene.add(wobble)



     const planeGeometry = new THREE.PlaneGeometry(30,30)
     const planeMaterial = new THREE.MeshLambertMaterial({color:"#ffffff",side:THREE.DoubleSide})
     const planeMesh = new THREE.Mesh(planeGeometry,planeMaterial)
     planeMesh.position.x = -6
     planeMesh.position.y = -7
     planeMesh.rotation.y = Math.PI * 0.5
     planeMesh.receiveShadow = true;
     
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

  
    uniforms.uTime.value = elapsedTime
    

    requestAnimationFrame(update)
    
    base.update()
    
    
}

function resize(){
    base.resize();
    base.renderer.setPixelRatio(sizes.pixelRatio)
}

</script>

<template>
  
</template>

<style scoped>


</style>