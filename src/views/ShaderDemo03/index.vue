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


let base,controls,gui,clock,planeMaterial,mirror,mirror1,portalLightMaterial,portalLightMaterial1,loaderTractorFlag,loaderTractorFlag1,water,sun,sphere,planeMesh,material;


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
				cubeTextureLoader.setPath( '/MilkyWay/' );

				const cubeTexture = cubeTextureLoader.load( [
					"dark-s_nx.jpg", "dark-s_nx.jpg",
					"dark-s_ny.jpg", "dark-s_ny.jpg",
					"dark-s_nz.jpg", "dark-s_nz.jpg"
				] );

	base.scene.background = cubeTexture;





     /**
     * galaxy
     */

     const meterialParameters = {}
    meterialParameters.color = "#70c1ff"

    gui.addColor(meterialParameters,'color')
    .onChange(()=>{
        console.log(11)
        portalLightMaterial.uniforms.uColor.value.set(meterialParameters.color)
    })


     const parameters = {}
    parameters.count = 100000
    parameters.size = 0.01
    parameters.radius = 5
    parameters.branches = 3
    parameters.spin = 1
    parameters.randomness = 0.2
    parameters.randomnessPower = 3
    parameters.insideColor = "#f09275"
    parameters.outsideColor = "#1b3984"


    let geometry = null
    
    let points = null
    clock = new THREE.Clock()

    const generateGalaxy = ()=>{

        /**
         * destroy old galaxy
         */
        if(points !== null){
            geometry.dispose()
            material.dispose()
            base.scene.remove(points)
        }

        geometry = new THREE.BufferGeometry()
        const positions = new Float32Array(parameters.count*3)
        const colors = new Float32Array(parameters.count*3)
        const scales = new Float32Array(parameters.count*1)
        const randomness = new Float32Array(parameters.count * 3)

        const colorInside = new THREE.Color(parameters.insideColor)
        const colorOutside = new THREE.Color(parameters.outsideColor)

        for(let i=0;i<parameters.count;i++){
            const i3 = i*3

            //position
            const radius = Math.random() * parameters.radius
            const spinAngle = radius * parameters.spin
            const branchAngle = (i%parameters.branches)/parameters.branches * Math.PI * 2

            //randomness
            const randomX = Math.pow(Math.random(),parameters.randomnessPower)*(Math.random()<0.5?1:-1)
            const randomY = Math.pow(Math.random(),parameters.randomnessPower)*(Math.random()<0.5?1:-1)
            const randomZ = Math.pow(Math.random(),parameters.randomnessPower)*(Math.random()<0.5?1:-1)

            positions[i3+0] = Math.cos(branchAngle+spinAngle)*radius
            positions[i3+1] = Math.sin(branchAngle+spinAngle)*radius
            positions[i3+2] = 0

            

            randomness[i3+0] = randomX
            randomness[i3+1] = randomY
            randomness[i3+2] = randomZ
            
            //color

            const mixedColor = colorInside.clone()
            mixedColor.lerp(colorOutside,radius/parameters.radius)

            colors[i3+0] = mixedColor.r
            colors[i3+1] = mixedColor.g
            colors[i3+2] = mixedColor.b


            //scale
            scales[i] = Math.random()
        }

        geometry.setAttribute(
            'position',
            new THREE.BufferAttribute(positions,3)
        )

        geometry.setAttribute(
            'color',
            new THREE.BufferAttribute(colors,3)
        )

        geometry.setAttribute(
            'aScale',
            new THREE.BufferAttribute(scales,1)
        )

        geometry.setAttribute(
            'aRandomness',
            new THREE.BufferAttribute(randomness,3)
        )


        /**
         * Material
         */
        material = new THREE.ShaderMaterial({
            //size:parameters.size,
            //sizeAttenuation:true,
            depthWrite:false,
            blending:THREE.AdditiveBlending,
            vertexColors:true,
            vertexShader:galaxyVertexShader,
            fragmentShader:galaxyFragmentShader,
            uniforms:{
                uTime:{value:0},
                uSize:{value:10 * base.renderer.getPixelRatio()}
            }
        })
        /**
         * points
         */
        points = new THREE.Points(geometry,material)
        points.rotation.z = Math.PI /2 
        points.position.z = -20
        base.scene.add(points)
    }

    generateGalaxy()
    gui.add(parameters,'count').min(100).max(100000).step(100).onFinishChange(generateGalaxy)
    gui.add(parameters,'size').min(0.001).max(0.1).step(0.001).onFinishChange(generateGalaxy)
    gui.add(parameters,'radius').min(0.01).max(20).step(0.01).onFinishChange(generateGalaxy)
    gui.add(parameters,'branches').min(1).max(10).step(1).onFinishChange(generateGalaxy)
    gui.add(parameters,'spin').min(-5).max(5).step(0.001).onFinishChange(generateGalaxy)
    gui.add(parameters,'randomness').min(0).max(2).step(0.001).onFinishChange(generateGalaxy)
    gui.add(parameters,'randomnessPower').min(1).max(10).step(0.001).onFinishChange(generateGalaxy)

    gui.addColor(parameters,'insideColor').onFinishChange(generateGalaxy)
    gui.addColor(parameters,'outsideColor').onFinishChange(generateGalaxy)




    
   
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
            loaderTractorFlag = true
        }
    );




    //plane

    const planeGeometry = new THREE.BoxGeometry(1,1,1);
    planeMesh = new THREE.Mesh(planeGeometry,portalLightMaterial);
    planeMesh.position.x = -3.5
    base.scene.add(planeMesh)

    const geometryShere = new THREE.SphereGeometry( 1, 32, 16 ); 
    sphere = new THREE.Mesh( geometryShere, portalLightMaterial ); 
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
    
    
    // planeMesh.position.y = Math.sin(elapsedTime*5)
    // sphere.position.y = Math.sin(elapsedTime*5)


    if(loaderTractorFlag){
        material.uniforms.uTime.value = elapsedTime
  
        portalLightMaterial.uniforms.uTime.value = elapsedTime
        water.material.uniforms[ 'time' ].value += 1.0 / 60.0;
        planeMesh.rotation.y = elapsedTime * 0.1
        sphere.rotation.y = elapsedTime * 0.1
        planeMesh.position.y = Math.sin(elapsedTime)
        sphere.position.y = Math.sin(elapsedTime)

        mirror.position.z = -elapsedTime * 1
        sphere.position.z = -elapsedTime * 1
        planeMesh.position.z = -elapsedTime * 1

        base.camera.position.z = -elapsedTime * 0.5
        

        base.camera.lookAt(mirror.position)
    }
    
    

    
    


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