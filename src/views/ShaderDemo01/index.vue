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
import { Water } from 'three/examples/jsm/objects/Water.js'


import holographicVertexShader from './shader/holographic/vertex.glsl?raw'
import holographicFragmentShader from './shader/holographic/fragment.glsl?raw'

let base,controls,gui,clock,planeMaterial,mirror,mirror1,portalLightMaterial,portalLightMaterial1,loaderTractorFlag,loaderTractorFlag1,water,sun,sphere,planeMesh;


onMounted(()=>{
    base = new Base()
    base.camera.position.z =4
    base.camera.updateProjectionMatrix()
    controls = new OrbitControls(base.camera,base.renderer.domElement)
    gui = new GUI({width:300})
    clock = new THREE.Clock()
    
    window.addEventListener("resize",resize)
    //createBox();

     // light

     const ambientLight = new THREE.AmbientLight( 0xcccccc, 1);
	//base.scene.add( ambientLight );

				const directionalLight = new THREE.DirectionalLight( 0xffffff, 1 );
				directionalLight.position.set( - 1, 1, 1 );
	//base.scene.add( directionalLight );


     // skybox

     const cubeTextureLoader = new THREE.CubeTextureLoader();
				cubeTextureLoader.setPath( '/skybox/' );

				const cubeTexture = cubeTextureLoader.load( [
					"px.jpg", "nx.jpg",
					"py.jpg", "ny.jpg",
					"pz.jpg", "nz.jpg"
				] );

	//base.scene.background = cubeTexture;




    /**
     * gui
     * 
     */
    const meterialParameters = {}
    meterialParameters.color = "#70c1ff"

    gui.addColor(meterialParameters,'color')
    .onChange(()=>{
        console.log(11)
        portalLightMaterial.uniforms.uColor.value.set(meterialParameters.color)
    })

   
   portalLightMaterial = new THREE.ShaderMaterial({
       
        vertexShader:holographicVertexShader,
        fragmentShader:holographicFragmentShader,
        
        uniforms:{
            uTime:new THREE.Uniform(0),
            uColor:new THREE.Uniform(new THREE.Color('#70c1ff'))
        },
        side:THREE.DoubleSide,
        transparent:true,
        depthWrite:false,
        blending:THREE.AdditiveBlending

       
    })

   const loader = new GLTFLoader();
    // Optional: Provide a DRACOLoader instance to decode compressed mesh data
    const dracoLoader = new DRACOLoader();
    //dracoLoader.setDecoderPath( '/examples/jsm/libs/draco/' );
    dracoLoader.setDecoderPath( '/draco/' )
    loader.setDRACOLoader( dracoLoader );
    // Load a glTF resource
    loader.load(
        "/star_ship.glb",
        function ( gltf ) {

            mirror = gltf.scene
            mirror.scale.set(1,1,1)

            gltf.scene.traverse(function(obj) {
                if (obj.isMesh) {//判断是否是网格模型
                    obj.material = portalLightMaterial
                }
            });

            mirror.material = portalLightMaterial
            mirror.rotation.y = Math.PI / 2
            console.log(mirror)
            base.scene.add( mirror );
        }
    );




    //plane

    const planeGeometry = new THREE.BoxGeometry(1,1,1);
    planeMesh = new THREE.Mesh(planeGeometry,portalLightMaterial);
    planeMesh.position.x = -3.5
    base.scene.add(planeMesh)

    const geometry = new THREE.SphereGeometry( 1, 32, 16 ); 
    sphere = new THREE.Mesh( geometry, portalLightMaterial ); 
    sphere.position.x = 3.5
    base.scene.add( sphere );




    

    // Water
    sun = new THREE.Vector3();

    const waterGeometry = new THREE.PlaneGeometry( 10000, 10000 );

    water = new Water(
        waterGeometry,
        {
            textureWidth: 512,
            textureHeight: 512,
            waterNormals: new THREE.TextureLoader().load( '/waternormals.jpg', function ( texture ) {

                texture.wrapS = texture.wrapT = THREE.RepeatWrapping;

            } ),
            sunDirection: new THREE.Vector3(),
            sunColor: 0xffffff,
            waterColor: 0x001e0f,
            distortionScale: 3.7,
            fog: base.scene.fog !== undefined
        }
    );

    water.position.y = -2
    water.rotation.x = - Math.PI / 2;

    //base.scene.add( water );

    


             

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

  
    portalLightMaterial.uniforms.uTime.value = elapsedTime
    water.material.uniforms[ 'time' ].value += 1.0 / 60.0;
    planeMesh.rotation.y = elapsedTime * 0.1
    sphere.rotation.y = elapsedTime * 0.1
    // planeMesh.position.y = Math.sin(elapsedTime*5)
    // sphere.position.y = Math.sin(elapsedTime*5)
    planeMesh.position.z = Math.sin(elapsedTime)
    sphere.position.z = Math.sin(elapsedTime)
    

    
    


    requestAnimationFrame(update)
    
    base.update()
    
    
}

function resize(){
    base.resize();
}

</script>

<template>
  
</template>

<style scoped>

</style>