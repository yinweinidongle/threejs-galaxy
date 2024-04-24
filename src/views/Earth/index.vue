<script setup>
import {onMounted, render} from "vue";
import * as THREE from 'three'
import Base from "../Base";
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import {GUI} from "three/examples/jsm/libs/lil-gui.module.min.js"
import earthVertexShader from './shader/vertex.glsl?raw'
import earthFragmentShader from './shader/fragment.glsl?raw'

import atomsphereVertexShader from './shader/atomsphere/vertex.glsl?raw'
import atomsphereFragmentShader from './shader/atomsphere/fragment.glsl?raw'




import gsap from 'gsap'




let base,controls,gui,clock,earth,sunSherical,shereMaterial,earthParameters,atomsphereMaterial;

console.log(earthVertexShader)
console.log(earthFragmentShader)


onMounted(()=>{
    base = new Base()
    base.camera.position.z =4
    base.camera.updateProjectionMatrix()
    controls = new OrbitControls(base.camera,base.renderer.domElement)
    gui = new GUI({width:300})
    clock = new THREE.Clock()
    base.renderer.setClearColor('#000011')
    
    window.addEventListener("resize",resize)
    //createBox();

     // light

    const ambientLight = new THREE.AmbientLight( 0xcccccc, 1);
	base.scene.add( ambientLight );

				const directionalLight = new THREE.DirectionalLight( 0xffffff, 1 );
				directionalLight.position.set( - 1, 1, 1 );
	base.scene.add( directionalLight );


     // skybox

     const cubeTextureLoader = new THREE.CubeTextureLoader();
				cubeTextureLoader.setPath( '/MilkyWay/' );

				const cubeTexture = cubeTextureLoader.load( [
					"dark-s_nx.jpg", "dark-s_nx.jpg",
					"dark-s_ny.jpg", "dark-s_ny.jpg",
					"dark-s_nz.jpg", "dark-s_nz.jpg"
				] );

	//base.scene.background = cubeTexture;

   

    const textureLoader = new THREE.TextureLoader()
    /**
     * Earth
     */


     earthParameters = {}
     earthParameters.atmosphereDayColor = '#00aaff'
     earthParameters.atomsphereTwilightColor = '#ff6600'


     gui
        .addColor(earthParameters,'atmosphereDayColor')
        .onChange(()=>{
            shereMaterial.uniforms.uAtomsphereDayColor.value.set(earthParameters.atmosphereDayColor)
            atomsphereMaterial.uniforms.uAtomsphereDayColor.value.set(earthParameters.atmosphereDayColor)
        })

        gui
        .addColor(earthParameters,'atomsphereTwilightColor')
        .onChange(()=>{
            shereMaterial.uniforms.uAtomsphereTwilightColor.value.set(earthParameters.atomsphereTwilightColor)
            atomsphereMaterial.uniforms.uAtomsphereTwilightColor.value.set(earthParameters.atomsphereTwilightColor)
        })


    //Textures
    const earthDayTexture = textureLoader.load('/earth/2k_earth_daymap.jpg')
    earthDayTexture.colorSpace = THREE.SRGBColorSpace
    earthDayTexture.anisotropy = 8
    const earthNightTexture = textureLoader.load('/earth/2k_earth_nightmap.jpg')
    earthNightTexture.colorSpace = THREE.SRGBColorSpace
    earthNightTexture.anisotropy = 8
    const earthCloudsTexture = textureLoader.load('/earth/2k_earth_clouds.jpg')
    earthCloudsTexture.anisotropy = 8
    const earthSpecularTexture = textureLoader.load('/earth/2k_earth_specular_map.tif')
    earthSpecularTexture.anisotropy = 8

    const shereGeometry = new THREE.SphereGeometry(2,64,64)
    shereMaterial = new THREE.ShaderMaterial({
        vertexShader:earthVertexShader,
        fragmentShader:earthFragmentShader,
        uniforms:{
            uDayTexture:new THREE.Uniform(earthDayTexture),
            uNightTexture:new THREE.Uniform(earthNightTexture),
            uCloudsTexture:new THREE.Uniform(earthCloudsTexture),
            uSpecularTexture:new THREE.Uniform(earthSpecularTexture),
            uSunDirection:new THREE.Uniform(new THREE.Vector3(0,0,1)),
            uAtomsphereDayColor:new THREE.Uniform(new THREE.Color(earthParameters.atmosphereDayColor)),
            uAtomsphereTwilightColor:new THREE.Uniform(new THREE.Color(earthParameters.atomsphereTwilightColor)),
        }
    })

    earth = new THREE.Mesh(shereGeometry,shereMaterial)

    base.scene.add(earth)


    //Atomsphere
    atomsphereMaterial = new THREE.ShaderMaterial({
        side:THREE.BackSide,
        transparent:true,
        vertexShader:atomsphereVertexShader,
        fragmentShader:atomsphereFragmentShader,
        uniforms:{
            uSunDirection:new THREE.Uniform(new THREE.Vector3(0,0,1)),
            uAtomsphereDayColor:new THREE.Uniform(new THREE.Color(earthParameters.atmosphereDayColor)),
            uAtomsphereTwilightColor:new THREE.Uniform(new THREE.Color(earthParameters.atomsphereTwilightColor)),
        }
    })

    const atomshere = new THREE.Mesh(shereGeometry,atomsphereMaterial)
    atomshere.scale.set(1.04,1.04,1.04)
    base.scene.add(atomshere)


    /**
     * Sun
     */


     const debugSun = new THREE.Mesh(
        new THREE.IcosahedronGeometry(0.1,2),
        new THREE.MeshBasicMaterial()
    )

    base.scene.add(debugSun)

    sunSherical = new THREE.Spherical(1,Math.PI*0.5,0.5)
    const sunDirection = new THREE.Vector3()

    const updateSun = () =>{
        //Sun direction
        sunDirection.setFromSpherical(sunSherical)

        debugSun.position.copy(sunDirection).multiplyScalar(5)

        
        shereMaterial.uniforms.uSunDirection.value.copy(sunDirection)
        atomsphereMaterial.uniforms.uSunDirection.value.copy(sunDirection)
    }

    console.log(base.renderer.capabilities.getMaxAnisotropy())

    updateSun()


    //Tweeks
    gui
        .add(sunSherical,'phi')
        .min(0)
        .max(Math.PI)
        .onChange(updateSun)

    gui
        .add(sunSherical,'theta')
        .min(-Math.PI)
        .max(Math.PI)
        .onChange(updateSun)


    
  

             

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
    
  
    earth.rotation.y = elapsedTime * 0.05
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