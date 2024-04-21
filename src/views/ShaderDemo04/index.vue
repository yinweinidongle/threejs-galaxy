<script setup>
import {onMounted} from "vue";
import * as THREE from 'three'
import Base from "../Base";
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import {GUI} from "three/examples/jsm/libs/lil-gui.module.min.js"
import fireworksVertexShader from './shader/vertex.glsl?raw'
import fireworksFragmentShader from './shader/fragment.glsl?raw'
import { Water } from 'three/examples/jsm/objects/Water.js'
import { Sky } from 'three/examples/jsm/objects/Sky.js'
import gsap from 'gsap'




let base,controls,gui,clock,planeMaterial,mirror,mirror1,portalLightMaterial,portalLightMaterial1,loaderTractorFlag,loaderTractorFlag1,water,sun,sphere,planeMesh,sizes;


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





     
        

    //plane

    const planeGeometry = new THREE.BoxGeometry(1,1,1);
    planeMesh = new THREE.Mesh(planeGeometry,new THREE.ShaderMaterial({
            vertexShader:fireworksVertexShader,
            fragmentShader:fireworksFragmentShader
        }));
    //base.scene.add(planeMesh)

    /**
     * Sizes
     */

    sizes = {
        width:window.innerWidth,
        height:window.innerHeight,
        pixelRatio:Math.min(window.devicePixelRatio,2)
    }

    sizes.resolution = new THREE.Vector2(sizes.width * sizes.pixelRatio,sizes.height* sizes.pixelRatio)


    /**
     * Fireworks
     */
     const textureLoader = new THREE.TextureLoader()
     const texture = [
        textureLoader.load("/sprites/snowflake1.png"),
        textureLoader.load("/sprites/snowflake2.png"),
        textureLoader.load("/sprites/snowflake3.png"),
        textureLoader.load("/sprites/snowflake4.png"),
        textureLoader.load("/sprites/snowflake5.png"),

     ]
        
     
     

    const createFirework = (count,position,size,texture,radius,color)=>{
        //Geometry
        const positionArray = new Float32Array(count*3)
        const sizeArray = new Float32Array(count)
        const timeMutiplierArray = new Float32Array(count)
        for(let i = 0;i<count;i++){
            const i3 = i*3

            const spherical = new THREE.Spherical(
                radius*(0.75+Math.random()*0.25),
                Math.random()*Math.PI,
                Math.random()*Math.PI*2
            )

            const position = new THREE.Vector3()
            position.setFromSpherical(spherical) 

            positionArray[i3] = position.x
            positionArray[i3+1] = position.y
            positionArray[i3+2] = position.z

            sizeArray[i] = Math.random()

            timeMutiplierArray[i] = 1+Math.random()
        }

        const geometry = new THREE.BufferGeometry()
        geometry.setAttribute('position',new THREE.Float32BufferAttribute(positionArray,3))

        geometry.setAttribute('aSize',new THREE.Float32BufferAttribute(sizeArray,1))
        geometry.setAttribute('aTimeMutiplier',new THREE.Float32BufferAttribute(timeMutiplierArray,1))

        texture.flipY = false

        const meterial = new THREE.ShaderMaterial({
            depthWrite:false,
            blending:THREE.AdditiveBlending,
            vertexShader:fireworksVertexShader,
            fragmentShader:fireworksFragmentShader,
            uniforms:{
                uTime:{value:0},
                uSize:new THREE.Uniform(size),
                uResolution:new THREE.Uniform(sizes.resolution),
                uTexture:new THREE.Uniform(texture),
                uColor:new THREE.Uniform(color),
                uProgress:new THREE.Uniform(0)
            },
            transparent:true
        })


        //Points
        const fireworks = new THREE.Points(geometry,meterial)


        fireworks.position.copy(position)

        fireworks.position.z = -40

        base.scene.add(fireworks)

        //Destroy
        const destroy = ()=>{
            base.scene.remove(fireworks)
            geometry.dispose()
            meterial.dispose()
        }

        //Animate
        gsap.to(
            meterial.uniforms.uProgress,
            {
                value:2,
                duration:5,
                ease:'linear',
                onComplete:destroy
            }
        )
    }

    // createFirework(
    //     100,
    //     new THREE.Vector3(),
    //     0.1,
    //     texture[2],
    //     3,
    //     new THREE.Color('#8affff')
    // )

    


    const createRandomFirework = ()=>{
        const count = Math.round(40 + Math.random()*1000)
        const position = new THREE.Vector3(
            (Math.random()*10 - 0.5)*2,
            Math.random()*2+20,
            -40-(Math.random() - 0.5)
        )
        const size = 0.5 + Math.random()

        const tte = texture[Math.floor(Math.random()*texture.length)]

        const radius = 10.5 + Math.random()*3

        const color = new THREE.Color()
        color.setHSL(Math.random(),1,0.7)

        createFirework(count,position,size,tte,radius,color)
    }

    createRandomFirework()
    setInterval(createRandomFirework,2000)

    // setInterval(()=>{
    //     createFirework(
    //     100,
    //     new THREE.Vector3(),
    //     0.1,
    //     texture[2],
    //     3,
    //     new THREE.Color('#8affff')
    // )
    // },100)

    window.addEventListener('click',createRandomFirework)





    

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




     // Skybox

    

     const sky = new Sky();
				sky.scale.setScalar( 10000 );
				base.scene.add( sky );

				/// GUI

				const effectController = {
					turbidity: 1.1,
					rayleigh: 3,
					mieCoefficient: 0.005,
					mieDirectionalG: 0,
					elevation: 0,
					azimuth: 180,
					exposure: base.renderer.toneMappingExposure
				};

				function guiChanged() {

					const uniforms = sky.material.uniforms;
					uniforms[ 'turbidity' ].value = effectController.turbidity;
					uniforms[ 'rayleigh' ].value = effectController.rayleigh;
					uniforms[ 'mieCoefficient' ].value = effectController.mieCoefficient;
					uniforms[ 'mieDirectionalG' ].value = effectController.mieDirectionalG;

					const phi = THREE.MathUtils.degToRad( 90 - effectController.elevation );
					const theta = THREE.MathUtils.degToRad( effectController.azimuth );

					sun.setFromSphericalCoords( 1, phi, theta );

					uniforms[ 'sunPosition' ].value.copy( sun );

					base.renderer.toneMappingExposure = effectController.exposure;
					base.renderer.render( base.scene, base.camera );

				}


				gui.add( effectController, 'turbidity', 0.0, 20.0, 0.1 ).onChange( guiChanged );
				gui.add( effectController, 'rayleigh', 0.0, 4, 0.001 ).onChange( guiChanged );
				gui.add( effectController, 'mieCoefficient', 0.0, 0.1, 0.001 ).onChange( guiChanged );
				gui.add( effectController, 'mieDirectionalG', 0.0, 1, 0.001 ).onChange( guiChanged );
				gui.add( effectController, 'elevation', 0, 90, 0.1 ).onChange( guiChanged );
				gui.add( effectController, 'azimuth', - 180, 180, 0.1 ).onChange( guiChanged );
				gui.add( effectController, 'exposure', 0, 1, 0.0001 ).onChange( guiChanged );

				guiChanged();



                //controls limit
				// controls.maxPolarAngle = Math.PI * 0.495;
				// controls.target.set( 0, 10, 0 );
				// controls.minDistance = 40.0;
				// controls.maxDistance = 200.0;
				// controls.update();
             

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
    water.material.uniforms[ 'time' ].value += 1.0 / 60.0;
    requestAnimationFrame(update)
    
    base.update()
    
    
}

function resize(){
    base.resize();
    sizes.pixelRatio = Math.min(window.devicePixelRatio,2)
    sizes.resolution.set(sizes.width* sizes.pixelRatio,sizes.height* sizes.pixelRatio)
    base.renderer.setPixelRatio(sizes.pixelRatio)
}

</script>

<template>
  
</template>

<style scoped>

</style>