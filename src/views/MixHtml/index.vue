<script setup>
import {onMounted} from "vue";
import * as THREE from 'three'
import Base from "../Base";
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import {GUI} from "three/examples/jsm/libs/lil-gui.module.min.js"
import {GLTFLoader} from 'three/examples/jsm/loaders/GLTFLoader.js'
import { DRACOLoader } from 'three/addons/loaders/DRACOLoader.js'
import {gsap} from 'gsap'

let base,controls,gui,gltfLoader,points,raycaster;


onMounted(()=>{


    /**
     * Points of interests
     */
     points = [
        {
            position:new THREE.Vector3(0,0,0),
            element:document.querySelector(".point-0")
        }
    ]

    raycaster = new THREE.Raycaster()

    base = new Base()
    base.camera.position.z = 5
    base.camera.updateProjectionMatrix()
    base.addAmbientLight(1,0xb9d5ff)
    base.addDirectionalLight(0.5,0xb9d5ff)
    controls = new OrbitControls(base.camera,base.renderer.domElement)
    gui = new GUI({width:300})
    gltfLoader = new GLTFLoader()
    update()
    window.addEventListener("resize",resize)
    //createBox();

    //Fog
    const fog = new THREE.Fog('#ffeeff',1,25)
    base.scene.fog = fog 


    // Instantiate a loader
    const loadingBarElement = document.querySelector('.loading-bar')
    const loadingManager = new THREE.LoadingManager(
        ()=>{

            gsap.delayedCall(0.5,()=>{
                gsap.to(overlayMaterial.uniforms.uAlpha,{duration:3,value:0})
                loadingBarElement.classList.add('ended')
                loadingBarElement.style.transform = ''
            })
            
        },
        //progress
        (itemUrl,itemsLoaded,itemsTotal)=>{
            console.log(itemsLoaded/itemsTotal,)
            const progressRatio = itemsLoaded/itemsTotal
            loadingBarElement.style.transform = `scaleX(${progressRatio})`
        }
    )

    const loader = new GLTFLoader(loadingManager);
    // Optional: Provide a DRACOLoader instance to decode compressed mesh data
    const dracoLoader = new DRACOLoader();
    dracoLoader.setDecoderPath( '/examples/jsm/libs/draco/' );
    loader.setDRACOLoader( dracoLoader );
    // Load a glTF resource
    loader.load(
        "/drone.glb",
        function ( gltf ) {
            gltf.scene.scale.set(3,3,3)
            gltf.scene.position.x = 0;
            gltf.scene.position.y = -0.5;
            gltf.scene.position.z = 0;
            base.scene.add( gltf.scene );
        }
    );


    


    /**
     * Overlay
     */

     const overlayGeometry = new THREE.PlaneGeometry(2,2,1,1)
     const overlayMaterial = new THREE.ShaderMaterial({
        transparent:true,
        uniforms:{
            uAlpha:{value:1.0}
        },
        vertexShader:`
            void main(){
                gl_Position = vec4(position,1.0);
            }
        `,
        fragmentShader:`

            uniform float uAlpha;
            void main(){
                gl_FragColor = vec4(0.0,0.0,0.0,uAlpha);
            }
        `

    })
     const overlay = new THREE.Mesh(overlayGeometry,overlayMaterial)
     base.scene.add(overlay)



})

function createBox(){
    const geometry = new THREE.BoxGeometry(1,1,1)
    const materail = new THREE.ShaderMaterial({
        vertexShader:`
            void main(){
                gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.0);
            }
        `,
        fragmentShader:`
            void main(){
                gl_FragColor = vec4(1.0,0.3,0.0,1.0);
            }
        `

    })
    const cube = new THREE.Mesh(geometry,materail)
    base.scene.add(cube)
}

function update() {

    requestAnimationFrame(update)
    base.update()
    controls.update()

    //mix html 
    for(const point of points){
        const screenPosition = point.position.clone()
        screenPosition.project(base.camera)

        raycaster.setFromCamera(screenPosition,base.camera)

        const intersects = raycaster.intersectObjects(base.scene.children,true)
    
        // if(intersects.length === 0){
        //     console.log(intersects)
        //     point.element.classList.add("visible")
        // }
        // else{
        //     point.element.classList.remove("visible")   
        // }
        
        const translateX = screenPosition.x * window.innerWidth * 0.5
        const translateY = screenPosition.y * window.innerHeight * 0.5


        point.element.style.transform =  `translate(${translateX}px,${translateY}px)`
    }
    
}

function resize(){
    base.resize();
}

</script>

<template>
  <div class="loading-bar"></div>

  <div class="point point-0 visible">

    <div class="label">1</div>
    <div class="text">Lorem ipsum dolor sit amet consectetur adipisicing elit </div>

  </div>

</template>

<style scoped>

.loading-bar{
    position:absolute;
    top:50%;
    width:100%;
    height:2px;
    background-color: #ffffff;
    transform: scaleX(0);
    transform-origin: top left;
    transition:transform 0.5s;
    will-change: transform;
}

.loading-bar.ended{
    transform-origin: top right;
    transition:transform 1.5s ease-in-out;
}

.point{
    position:absolute;
    top:50%;
    left:50%;
}
.point.visible .label{
    transform: scale(1,1);
}
.point .label{
    position:absolute;
    width:40px;
    height:40px;
    top:-20px;
    left: -20px;
    background:#00000077;
    border-radius: 50%;
    text-align: center;
    line-height: 40px;
    color:#ffffff;
    font-weight:100;
    font-size:14px;
    cursor:help;
    transform: scale(0,0);
    transition:transform 0.3s;
}

.point:hover .text{
    opacity: 1;
    
}


.point .text{
    position:absolute;
    top:30px;
    width:200px;
    top:30px;
    left:-120px;
    background-color: #00000077;
    color:#ffffff;
    line-height: 1.3em;
    font-weight:100;
    font-size:14px;
    padding:20px;
    border-radius: 4px;
    text-align: center;
    opacity: 0;
    transition:opacity 0.3s;
    pointer-events: none;
}



</style>
