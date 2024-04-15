<script setup>
import {onMounted} from "vue";
import * as THREE from 'three'
import Base from "../Base";
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import {GUI} from "three/examples/jsm/libs/lil-gui.module.min.js"
import {GLTFLoader} from 'three/examples/jsm/loaders/GLTFLoader.js'
import { DRACOLoader } from 'three/addons/loaders/DRACOLoader.js'

let base,controls,gui,clock,group,drone,cylinder,loaderFlag,tractor,loaderTractorFlag;
let ghost1,ghost2,ghost3;
onMounted(()=>{
    base = new Base()
    base.camera.position.z = 20
    base.camera.position.y = 4
    base.camera.updateProjectionMatrix()
    base.addAmbientLight(1,0xb9d5ff)
    base.addDirectionalLight(0.5,0xb9d5ff)
    controls = new OrbitControls(base.camera,base.renderer.domElement)
    gui = new GUI({width:300})
    clock = new THREE.Clock()
    window.addEventListener("resize",resize)
    //createBox();


    // skybox

    const cubeTextureLoader = new THREE.CubeTextureLoader();
				cubeTextureLoader.setPath( '/skybox/' );

				const cubeTexture = cubeTextureLoader.load( [
					"px.jpg", "nx.jpg",
					"py.jpg", "ny.jpg",
					"pz.jpg", "nz.jpg"
				] );

	base.scene.background = cubeTexture;


    // light

    const ambientLight = new THREE.AmbientLight( 0xcccccc, 0.4 );
	base.scene.add( ambientLight );

				const directionalLight = new THREE.DirectionalLight( 0xffffff, 0.6 );
				directionalLight.position.set( - 1, 1, 1 );
	base.scene.add( directionalLight );



    //Fog
    const fog = new THREE.Fog('#262837',1,25)
    //base.scene.fog = fog 
    

    //Group
    group = new THREE.Group()
    base.scene.add(group)


    //光柱
    const geometry = new THREE.CylinderGeometry( 1, 2, 12, 42 ); 
    const material = new THREE.MeshBasicMaterial( {color: 0xffff00,opacity: 0.5,transparent: true} ); 
    cylinder = new THREE.Mesh( geometry, material ); 
    cylinder.scale.set(0.3,0.3,0.3)
    cylinder.position.y = 2.5
    cylinder.position.x = 0.38

    let cylinder1 = cylinder.clone()

    cylinder1.position.x = 0.25+3

    base.scene.add( cylinder,cylinder1 );

    group.add(cylinder)
    

    const loader = new GLTFLoader();
    // Optional: Provide a DRACOLoader instance to decode compressed mesh data
    const dracoLoader = new DRACOLoader();
    //dracoLoader.setDecoderPath( '/examples/jsm/libs/draco/' );
    dracoLoader.setDecoderPath( '/draco/' )
    loader.setDRACOLoader( dracoLoader );
    // Load a glTF resource
    loader.load(
        "/drone123.glb",
        function ( gltf ) {

            drone = gltf.scene
            drone.scale.set(0.03,0.03,0.03)
            drone.position.x = 0;
            drone.position.y = 5;
            drone.position.z = 0;
            //gltf.scene.rotation.x = Math.PI*0.1 ;

            group.add(drone)


            const model = drone.clone();
            model.position.x = 3;
            model.position.y = 5;
            model.position.z = 0;
            //model.rotation.x = Math.PI*0.1 ;
            base.scene.add( drone,model );
            //gui.add(drone.position,'x').min(0).max(20).step(0.001).name('droneX')

            loaderFlag = true
            //gui.add(group.position,'x').min(0).max(10).step(0.001).name('droneX')
        }
    );


    loader.load(
        "/tractor.glb",
        function ( gltf ) {
            tractor = gltf.scene
            tractor.scale.set(0.5,0.5,0.5)
            tractor.position.x = 5;
            tractor.position.y = 0.7;
            tractor.position.z = 5;
            tractor.rotation.y = Math.PI ;
            //gltf.scene.rotation.x = Math.PI*0.1 ;
            base.scene.add( tractor );
            loaderTractorFlag = true
        }
    );



    loader.load(
        "/farmland_0415.glb",
        function ( gltf ) {
            
            gltf.scene.position.x = 0;
            gltf.scene.position.y = -0.5;
            gltf.scene.position.z = 0;
            gltf.scene.rotation.y = Math.PI ;
            //gltf.scene.rotation.x = Math.PI*0.1 ;
            base.scene.add( gltf.scene );
        }
    );

  

    //Debug
    gui.add(base.camera.position,'z').min(10).max(30).step(0.001).name('cameraZ')
    gui.add(base.camera.position,'y').min(0).max(10).step(0.001).name('cameraY')
    

   
    


 

  

    

   

   

    update()

   


});

function createBox(){
    const geometry = new THREE.BoxGeometry(1,1,1)
    const materail = new THREE.MeshBasicMaterial({color:0x00ff00})
    const cube = new THREE.Mesh(geometry,materail)
    base.scene.add(cube)
}

function update() {

    const elapsedTime = clock.getElapsedTime()*0.5
    

    if(loaderFlag && loaderTractorFlag){
        drone.position.x = Math.sin(elapsedTime)*3
        cylinder.position.x = Math.sin(elapsedTime)*3

        drone.position.z = Math.cos(elapsedTime)*3
        cylinder.position.z = Math.cos(elapsedTime)*3

        tractor.position.z = Math.sin(elapsedTime)*3
    }

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
