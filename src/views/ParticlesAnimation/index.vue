<script setup>
import {onMounted, render} from "vue";
import * as THREE from 'three'
import Base from "../Base";
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import {GUI} from "three/examples/jsm/libs/lil-gui.module.min.js"
import particlesVertexShader from './shader/vertex.glsl?raw'
import particlesFragmentShader from './shader/fragment.glsl?raw'





import gsap from 'gsap'
import { texture } from "three/examples/jsm/nodes/Nodes.js";




let base,controls,gui,clock,sizes,displacement,pTexture,picTexture1,picTexture2,picTexture3,particlesMaterial;




onMounted(()=>{
    base = new Base()
    base.camera.position.z =10
    base.camera.updateProjectionMatrix()
    controls = new OrbitControls(base.camera,base.renderer.domElement)
    //gui = new GUI({width:300})
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
     * Displacement
     */
    displacement = {}
    displacement.canvas = document.createElement('canvas')

    displacement.canvas.width = 128
    displacement.canvas.height = 128
    displacement.canvas.style.position = 'fixed'
    displacement.canvas.style.width = '256px'
    displacement.canvas.style.height = '256px'
    displacement.canvas.style.top = 0
    displacement.canvas.style.left = 0
    displacement.canvas.style.zIndex = 10
    document.body.append(displacement.canvas)

    //Context
    displacement.context = displacement.canvas.getContext('2d')
    displacement.context.fillStyle = '#000'
    displacement.context.fillRect(0,0,displacement.canvas.width,displacement.canvas.height)

    //Glow image
    displacement.glowImage = new Image()
    displacement.glowImage.src = '/sprites/circle.png'

    // window.setTimeout(()=>{
    //     displacement.context.drawImage(displacement.glowImage,20,20,32,32)
    // },1000)

    //Interactive plane
    displacement.interactivePlane = new THREE.Mesh(
        new THREE.PlaneGeometry(10,10),
        new THREE.MeshBasicMaterial({color:"red",side:THREE.DoubleSide})

    )
    displacement.interactivePlane.visible = false
    base.scene.add(displacement.interactivePlane)

    //Raycaster
    displacement.raycaster = new THREE.Raycaster()
    
    //Coordinates
    displacement.screenCursor = new THREE.Vector2(9999,9999)
    displacement.canvasCursor = new THREE.Vector2(9999,9999)
    displacement.canvasCursorPrevious = new THREE.Vector2(9999,9999)

    window.addEventListener('pointermove',(event)=>{
        displacement.screenCursor.x = (event.clientX / sizes.width) * 2 - 1
        displacement.screenCursor.y = - (event.clientY / sizes.height) * 2 + 1
    })


    //Texture
    displacement.texture = new THREE.CanvasTexture(displacement.canvas)

    

    picTexture1 = new THREE.Uniform(textureLoader.load('/panda.jpg'))
    picTexture2 = new THREE.Uniform(textureLoader.load('/longmao.jpeg'))
    picTexture3 = new THREE.Uniform(textureLoader.load('/dabai.png'))

    pTexture = picTexture1

    document.querySelector(".pic1").addEventListener("click",()=>{

        console.log(111)
        
        pTexture=picTexture1
        particlesMaterial.uniforms.uPictureTexture = pTexture
    })

    document.querySelector(".pic2").addEventListener("click",()=>{
        console.log(222)
        pTexture=picTexture2
        particlesMaterial.uniforms.uPictureTexture = pTexture
    })

    document.querySelector(".pic3").addEventListener("click",()=>{
        console.log(333)
        pTexture=picTexture3
        particlesMaterial.uniforms.uPictureTexture = pTexture
    })


   


    /**
     * Particles
     */
   
    const particlesGeometry = new THREE.PlaneGeometry(10,10,128,128)
    particlesGeometry.setIndex(null)
    particlesGeometry.deleteAttribute('normal')
    const instensitiesArray = new Float32Array(particlesGeometry.attributes.position.count)
    const anglesArray = new Float32Array(particlesGeometry.attributes.position.count)

    for(let i=0;i<particlesGeometry.attributes.position.count;i++){
        instensitiesArray[i] = Math.random()
        anglesArray[i] = Math.random() * Math.PI * 2

    }



    particlesGeometry.setAttribute('aIntensity',new THREE.BufferAttribute(instensitiesArray,1))
    particlesGeometry.setAttribute('aAngles',new THREE.BufferAttribute(anglesArray,1))

    particlesMaterial = new THREE.ShaderMaterial({

        vertexShader:particlesVertexShader,
        fragmentShader:particlesFragmentShader,
        uniforms:{
            uResolution:new THREE.Uniform(sizes.resolution),
            uPictureTexture:pTexture,
            uDisplacementTexture : new THREE.Uniform(displacement.texture)
        },
        blending:THREE.AdditiveBlending

    })

    const particles = new THREE.Points(particlesGeometry,particlesMaterial)
    base.scene.add(particles)
   


    
    
  

             

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

    displacement.raycaster.setFromCamera(displacement.screenCursor,base.camera)
    const intersections = displacement.raycaster.intersectObject(displacement.interactivePlane)
    

    

    

    if(intersections.length){
        const uv = intersections[0].uv
        displacement.canvasCursor.x = uv.x * displacement.canvas.width
        displacement.canvasCursor.y = (1-uv.y) * displacement.canvas.height
    }

    /**
     * Displacement
     */

    //Fade out
    displacement.context.globalCompositeOperation = 'source-over'
    displacement.context.globalAlpha = 0.02
    displacement.context.fillRect(0,0,displacement.canvas.width,displacement.canvas.height)

    //Speed Alpha
    const cursorDistance = displacement.canvasCursorPrevious.distanceTo(displacement.canvasCursor)
    displacement.canvasCursorPrevious.copy(displacement.canvasCursor)
    const alpha = Math.min(cursorDistance * 0.1,1)
    

    const glowSize = displacement.canvas.width * 0.25
    displacement.context.globalCompositeOperation = 'lighten'
    displacement.context.globalAlpha = alpha
    displacement.context.drawImage(
        displacement.glowImage,
        displacement.canvasCursor.x - glowSize*0.5,
        displacement.canvasCursor.y - glowSize*0.5,
        glowSize,
        glowSize
    )
    

    //Texture
    displacement.texture.needsUpdate = true

    requestAnimationFrame(update)
    
    base.update()
    
    
}

function resize(){
    base.resize();
    base.renderer.setPixelRatio(sizes.pixelRatio)
}

</script>

<template>
  <div class="container">
    <div class="pic pic1">阿宝</div>
    <div class="pic pic2">大龙猫</div>
    <div class="pic pic3">大白</div>
  </div>

  <div class="wish">WISH YOU HAPPIER IN THERE FORERVE</div>
</template>

<style scoped>
.container{
    position: absolute;
    right:30px;
    top:50px;
    padding:10px;
    z-index: 10px;
}
.container>div{
    cursor: pointer;
    float:left;
    width:50px;
    text-align: center;
    padding:5px 10px;
    border: 1px solid #333;
    border-radius: 3px;
    background-color: #000;
    color:#fff;
    margin-left: 5px;
    height: 30px;
    line-height: 30px;
    transition: all .6s;
}


.container>div:hover{
    
    background-color: #fff;
    color:#000;
    
}

.clear{
    clear:both;
}

.wish{
    position: absolute;
    width:500px;
    margin: 20px auto;
    bottom: 50px;
    left:50%;
    z-index: 10px;
    color:#fff;
    font-size: 25px;
    transform: translateX(-50%);
    font-family: Georgia, 'Times New Roman', Times, serif;
    text-shadow:  0 0 12px #b4d017;
    animation-name: slidein;
    animation-duration: 4s;
}


@keyframes slidein {
  from {
    opacity: 0;
  }

  to {
    opacity: 1;
  }
}

</style>